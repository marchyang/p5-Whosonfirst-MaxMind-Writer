use strict;
use warnings;

use utf8;

# namespace::autoclean
# Math::Int64
# Math::Int128
# MaxMind::DB::Common
# Data::IEEE754
# Digest::SHA1
# Sereal::Encoder
# Moose
# MooseX::StrictConstructor
# MooseX::Params::Validate
# Net::Works

use Text::CSV_XS;

use MaxMind::DB::Writer::Tree;
use Net::Works::Network;

package Whosonfirst::MaxMind::Writer;

=head1 PACKAGE METHODS

=cut

=head2 __PACKAGE__->new($db_file)

=cut

sub new {
    my $pkg = shift;

    # continent_name,wof_id,country_iso_code,subdivision_1_name,continent_code,metro_code,geoname_id,locale_code,time_zone,subdivision_2_iso_code,country_name,city_name,subdivision_2_name,subdivision_1_iso_code

    my %types = (
	wof_name => 'utf8_string',
	wof_id => 'uint64',
	
	geoname_id => 'unit32',
	locale_code => 'utf8_string',
	continent_code => 'utf8_string',
	continent_name => 'utf8_string',
	country_name => 'utf8_string',
	);
    
    my $tree = MaxMind::DB::Writer::Tree->new(
	ip_version            => 6,
	record_size           => 24,
	database_type         => "Who's On First IP Data",
	languages             => ['en'],
	description           => { en => "Who's On First database of IP data" },
	map_key_type_callback => sub { $types{ $_[0] } },
	);

    my $self = {
	'tree' => $tree,
    };
        
    bless $self,$pkg;
    return $self;
}

=head1 OBJECT METHODS

=cut

=head2 $obj->publish($csv_file, $db_file)

=cut

sub publish {
    my $self = shift;
    my $csv_file = shift;
    my $db_file = shift;

    my $csv = Text::CSV_XS->new ({ binary => 1, auto_diag => 1 });

    # please do not die

    open my $csv_fh, "<:encoding(utf8)", $csv_file
	or die $!;

    while (my $row = $csv->getline ($csv_fh)){

	use Data::Dumper;
	print Data::Dumper::Dumper($row);

	# See notes above in new

	my %data = (
	    wof_id => $row->{'wof_id'},
	    # wof_name => "",
	    );

	my $str_network = $row->{'network'};
	my $network = Net::Works::Network->new_from_string( string => $str_network );
	
	$self->{'tree'}->insert_network($network, \%data);
    }

    close $csv_fh;

    $self->{'tree'}->write_tree($self->{'db_fh'});
}

=head1 VERSION

0.1

=head1 DATE


=head1 AUTHOR

Mapzen

=head1 SEE ALSO

=head1 BUGS

=head1 LICENSE

Copyright (c) 2015, Mapzen
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

* Neither the name of the {organization} nor the names of its
  contributors may be used to endorse or promote products derived from
  this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

=cut

return 1;

__END__

# in-progress types maps the standard (free) GeoIP databases...
# note the inclusion of whosonfirst_id

    my %types = (
	'country' => 'map',
	'continent' => 'map',
	'continent_code' => 'utf8_string',
	'code' => 'utf8_string',
	'geoname_id' => 'uint32',
	'iso_code' => 'utf8_string',
	'location' => 'map',
	'latitude' => 'double',
	'longitude' => 'double',
	'names' => 'map',
	'traits' => 'map',	# ?????
	'registered_country' => 'map',
	'subdivisions' => [ 'array', 'map' ],
	'time_zone' => 'utf8_string',
	'whosonfirst_id' => 'uint64',
	'is_satellite_provider' => 'boolean',
	'is_anonymous_proxy' => 'boolean'
    );


# stub/proof-of-concept code to build a WOF specific mmdb

#!/usr/bin/env perl

use strict;
use JSON::XS;
use Text::CSV_XS;
use LWP::Simple;
use Data::Dumper;
use Memoize;
use File::Slurp;

use MaxMind::DB::Writer::Tree;
use Net::Works::Network;

memoize('concordance', 'props');

{
    &main();
    exit();
}

sub main {

    # https://metacpan.org/pod/MaxMind::DB::Writer::Tree#DATA-TYPES

    my %types = (
	'whosonfirst_id' => 'uint64',
	'geoname_id' => 'uint64',
	'name' => 'utf8_string',
	'placetype' => 'utf8_string',
	'neighbourhood_id' => 'uint64',
	'locality_id' => 'uint64',
	'localadmin_id' => 'uint64',
	'region_id' => 'uint64',
	'macroregion_id' => 'uint64',
	'disputed_id' => 'uint64',
	'country_id' => 'uint64',
	'continent_id' => 'uint64',
	'mm_latitude' => 'double',
	'mm_longitude' => 'double',
	'geom_latitude' => 'double',
	'geom_longitude' => 'double',
	'geom_bbox' => 'utf8_string',
	'lbl_latitude' => 'double',
	'lbl_longitude' => 'double',
    );

    my $tree = MaxMind::DB::Writer::Tree->new(
	database_type => "WOF",
	description => { en => 'WOF' },
	ip_version => 4,
	map_key_type_callback => sub { $types{ $_[0] } },
	merge_record_collisions => 1,
	record_size => 24,
	);

    my $csv = "/usr/local/mapzen/maxmind-data/GeoLite2-City-CSV_20150901/GeoLite2-City-Blocks-IPv4.csv";
    my $reader = Text::CSV_XS::csv(in => $csv, headers => "auto");

    my @placetypes = ("locality", "localadmin", "region", "macroregion", "disputed", "country", "continent");

    my $counter = 0;

    foreach my $row (@$reader){

	$counter += 1;

	my $net = $row->{'network'};
	my $network = Net::Works::Network->new_from_string('string' => $net);

	my $gnid = $row->{'geoname_id'};

	my $lat = $row->{'latitude'};
	my $lon = $row->{'longitude'};

	my $wof_id = -1;

	foreach my $t (@placetypes){
	    $wof_id = reversegeo($t, $lat, $lon);

	    if ($wof_id != -1){
		last;
	    }
	}

	if ($wof_id == -1){
	    print "MISSING AFTER REVERSEGEO\n";
	    $wof_id = concordance($gnid);
	}

	if ($wof_id == -1){
	    print "MISSING AFTER CONCORDANCE\n";

	    my %meta = (
		'geoname_id' => $gnid,
		'whosonfirst_id' => 0,
		);
	    
	    $tree->insert_network( $network, \%meta);
	    next;
	}

	#

	my $props = props($wof_id);

	my $hiers = $props->{'wof:hierarchy'};

	foreach my $h (@$hiers){

	    my $pt = $props->{'wof:placetype'};
	    my $id = $props->{'wof:id'};

	    my %meta = (
		'geoname_id' => $gnid,
		'whosonfirst_id' => $id,
		'name' => $props->{'wof:name'} || "Un-named $pt #$id",
		'placetype' => $pt,
		'mm_latitude' => $lat,
		'mm_longitude' => $lon,
		'geom_bbox' => $props->{'geom:bbox'},
		'geom_latitude' => $props->{'geom:latitude'},
		'geom_longitude' => $props->{'geom:longitude'},
		);

	    if (($props->{'lbl:latitude'}) && ($props->{'lbl:longitude'})){
		$meta{'lbl_latitude'} = $props->{'lbl:latitude'},
		$meta{'lbl_longitude'} => $props->{'lbl:longitude'},		
	    }

	    foreach my $t (@placetypes){

		my $k = $t . "_id";
		my $v = $h->{$k} || 0;

		if ($v == -1){
		    $v = 0;	# grrrrnnn
		}

		$meta{$k} = $v;
	    }
	    
	    $tree->insert_network( $network, \%meta);
	}

	if ($counter == 100000){
	    last;
	}

    }

    my $filename = "wof-csv.mmdb";

    open my $fh, '>:raw', $filename;
    $tree->write_tree( $fh );
    close $fh;
}

sub props {
    my $wof_id = shift;

    my $tmp = $wof_id;
    my @parts = ();

    while (length($tmp)){
	push @parts, substr($tmp, 0, 3);
	$tmp = substr($tmp, 3);
    }

    my $fname = $wof_id . ".geojson";
    my $tree = join("/", @parts);

    my $path = "/usr/local/mapzen/whosonfirst-data/data/" . $tree . "/" . $fname;

    my $text = read_file($path);
    my $data = decode_json($text);

    my $props = $data->{'properties'};
    return $props;
}

sub reversegeo {
    my $target = shift;
    my $lat = shift;
    my $lon = shift;

    my $url = "http://localhost:1111/$target?latitude=$lat&longitude=$lon";
    # print "$url\n";

    my $rsp = get($url);

    if ($rsp eq ""){
	return -1;
    }

    my $data = decode_json($rsp);

    if (scalar(@$data) eq 0){
	return -1;
    }

    return $data->[0]->{'Id'};
}

sub concordance {
    my $gnid = shift;

    my $rsp = get("http://localhost:10001?k=gn:id&v=" . $gnid);

    if ($rsp eq "") {
	return -1;
    }

    my $data = decode_json($rsp);

    my $first = $data->[0];
    return $first->{'wof:id'};
}
