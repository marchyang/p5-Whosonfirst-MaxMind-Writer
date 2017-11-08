package Whosonfirst::MaxMind::Writer;

use strict;
use warnings;
use utf8;

use MaxMind::DB::Writer::Tree;
use Net::Works::Network;
use Net::Works::Address;

use File::Slurp;
use Text::CSV_XS;
use JSON::XS;
use Data::Dumper;

use Whosonfirst::MaxMind::Types;

=head1 PACKAGE METHODS

=cut

# THIS IS A BAD PACKAGE NAME...

sub update_maxmind_mmdb {
    my $pkg = shift;
    my $src = shift;
    my $dest = shift;
    my $lookup = shift;

    # $src is something like geoip.mmdb
    # $dest is something like wof.mmdb
    # $lookup is something produced by https://github.com/whosonfirst/go-whosonfirst-mmdb#wof-mmdb-lookup

    my $reader = MaxMind::DB::Reader->new('file' => $src);
    my $meta = $reader->metadata();

    my $types = Whosonfirst::MaxMind::Types->mmdb();

    for my $lang (@{$meta->languages()} ) {
	$types->{ $lang } = 'utf8_string';
    }

    my $tree = MaxMind::DB::Writer::Tree->new(
	database_type => $meta->database_type() . " - WOF",
	description => { en => 'WOF' },
	ip_version => $meta->ip_version(),
	map_key_type_callback => sub { $types->{ $_[0] } },
	# deprecated as 201711 (at least)	
	# merge_record_collisions => 1,
	# is this correct? I have no idea... (20171106/thisisaaronland)
	# https://github.com/maxmind/MaxMind-DB-Writer-perl/search?p=2&q=merge_strategy&type=&utf8=%E2%9C%93
	merge_strategy => 'recurse',
	record_size => $meta->record_size(),
	);

    my $callback = sub {
	my $ip_as_integer = shift;
	my $mask_length   = shift;
	my $data          = shift;
	
	my $address = Net::Works::Address->new_from_integer(integer => $ip_as_integer );
	my $network = Net::Works::Network->new_from_integer( 'integer' => $ip_as_integer, 'prefix_length' => $mask_length );
       
	foreach my $pl ("country", "continent", "city", "registered_country") {
		
	    if (! $data->{ $pl }){
		next;
	    }

	    my $gnid = $data->{ $pl }->{ 'geoname_id' };

	    # LOOKUP DATA FOR $gnid HERE	    
	    # $data->{ $pl }->{ 'whosonfirst_id' } = $wofid;
	}

	$tree->insert_network($network, $data);
    };

    $reader->iterate_search_tree($callback);

    # sanity check tree here?

    open my $fh, '>:raw', $dest;
    $tree->write_tree( $fh );
    close $fh;

    return 1;
}

# THIS IS ALSO A TERRIBLE PACKAGE NAME

sub build_wof_mmdb {
    my $pkg = shift;
    my $src = shift;
    my $dest = shift;
    my $lookup = shift;
    my $meta = shift;

    # $src is something like GeoLite2-Country-Blocks-IPv4.csv
    # $dest is something like wof.mmdb
    # $lookup is something produced by https://github.com/whosonfirst/go-whosonfirst-mmdb#wof-mmdb-prepare

    # remember that anything you push in to %data below needs to be
    # defined in Types.pm (20170824/thisisaaronland)

    my $types = Whosonfirst::MaxMind::Types->whosonfirst();

    $meta->{'map_key_type_callback'} = sub { $types->{ $_[0] } };
    $meta->{'merge_record_collisions'} = 1;

    my $tree = MaxMind::DB::Writer::Tree->new(%$meta);

    my $reader = Text::CSV_XS::csv(in => $src, headers => "auto");

    my $json = new JSON::XS;
    my $lookup_table = $json->decode(read_file($lookup));

    foreach my $row (@$reader){

	my $net = $row->{'network'};
	my $network = Net::Works::Network->new_from_string('string' => $net);

	my $gnid = $row->{'geoname_id'} || 0;

	my $lat = $row->{'latitude'} || 0.0;
	my $lon = $row->{'longitude'} || 0.0;

	my $wof_data = $lookup_table->{$gnid};

	if (! $wof_data){

	    my %data = (
		'gn:id' => $gnid,
		'wof:id' => 0,
		'mm:latitude' => $lat,
		'mm:longitude' => $lon,
		);
	    
	    $tree->insert_network( $network, \%data);
	    next;
	}

	# See what's going on here... it's all a bit in flux still
	# while we figure out what an "SPR" for IP lookups looks like
	# and as of this writing it's just a JSON encoded SPR from
	# go-whosonfirst-geojson-v2/feature, and that will probably
	# change (20170828/thisisaaronland)

#	foreach my $extra (@$wof_data){

	    my %data = (
		'gn:id' => $gnid,
		'mm:latitude' => $lat,
		'mm:latitude' => $lon,
		);

	    $data{'spr'} = $json->encode($wof_data);

#	    foreach my $k (keys %{$extra}) {
#		$data{$k} = $extra->{$k};
#	    }

	    $tree->insert_network($network, \%data);
#	}

    }

    # sanity check tree here?

    open my $fh, '>:raw', $dest;
    $tree->write_tree( $fh );
    close $fh;

    return 1;
}

=head1 VERSION

0.2

=head1 DATE


=head1 AUTHOR

Mapzen

=head1 SEE ALSO

=head1 BUGS

=head1 LICENSE

Copyright (c) 2015-2017, Mapzen
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
