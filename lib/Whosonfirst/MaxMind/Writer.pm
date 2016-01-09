package Whosonfirst::MaxMind::Writer;

use strict;
use warnings;
use utf8;

# PLEASE MAKE SURE THESE ARE ALL LISTED AS DEPENDECIES
# IN Build.PL
#
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

use MaxMind::DB::Writer::Tree;
use Net::Works::Network;
use Net::Works::Address;

use Text::CSV_XS;

use Whosonfirst::MaxMind::Types;
use Whosonfirst::MaxMind::Concordances;
use Whosonfirst::MaxMind::PointInPoly;
use Whosonfirst::MaxMind::Data;		# REMEMBER - terrible package name...

=head1 PACKAGE METHODS

=cut

# THIS IS A BAD PACKAGE NAME...

sub update_maxmind_mmdb {
    my $pkg = shift;
    my $src = shift;
    my $dest = shift;

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
	merge_record_collisions => 1,
	record_size => $meta->record_size(),
	);

    my $concordances = Whosonfirst::MaxMind::Concordances->new();

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
	    my $wofid = $concordances->lookup('gn:id', $gnid);
	    
	    $data->{ $pl }->{ 'whosonfirst_id' } = $wofid;
	}

	$tree->insert_network($network, $data);
    };

    $reader->iterate_search_tree($callback);

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
    my $meta = shift;

    my $types = Whosonfirst::MaxMind::Types->whosonfirst();

    $meta->{'map_key_type_callback'} = sub { $types->{ $_[0] } };
    $meta->{'merge_record_collisions'} = 1;

    my $tree = MaxMind::DB::Writer::Tree->new(%$meta);

    my $reader = Text::CSV_XS::csv(in => $src, headers => "auto");

    my @placetypes = ("locality", "localadmin", "region", "macroregion", "disputed", "country", "continent");

    my $pip = Whosonfirst::MaxMind::PointInPoly->new()
    my $wof = Whosonfirst::MaxMind::Data->new()

    foreach my $row (@$reader){

	my $net = $row->{'network'};
	my $network = Net::Works::Network->new_from_string('string' => $net);

	my $gnid = $row->{'geoname_id'} || 0;

	my $lat = $row->{'latitude'};
	my $lon = $row->{'longitude'};

	my $wof_id = -1;

	foreach my $pt (@placetypes){

	    $wof_id = $pip->lookup($lat, $lon, $pt);

	    if ($wof_id != -1){
		last;
	    }
	}

	if ($wof_id == -1){
	    $wof_id = concordance($gnid);
	}

	if ($wof_id == -1){

	    my %data = (
		'geoname_id' => $gnid,
		'whosonfirst_id' => 0,
		'mm_latitude' => $lat,
		'mm_longitude' => $lon,
		);
	    
	    $tree->insert_network( $network, \%data);
	    next;
	}

	# SEE THIS - UNDER THE HOOD WE END UP memoize-ing
	# EVERYTHING INCLUDING THE GEOMETRY. PLEASE MAKE
	# THIS LESS STUPID... (20160109/thisisaaronland)

	my $wof_data = $wof->load($wof_id);

	my $props = $wof_data->{'properties'};
	my $hiers = $props->{'wof:hierarchy'};

	foreach my $h (@$hiers){

	    my $pt = $props->{'wof:placetype'};
	    my $id = $props->{'wof:id'};

	    my %data = (
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
		$data{'lbl_latitude'} = $props->{'lbl:latitude'};
		$data{'lbl_longitude'} = $props->{'lbl:longitude'};
	    }

	    foreach my $t (@placetypes){

		my $k = $t . "_id";
		my $v = $h->{$k} || 0;

		if ($v == -1){
		    $v = 0;	# grrrrnnn
		}
		
		$data{$k} = $v;
	    }
	    
	    $tree->insert_network($network, \%deta);
	}

    }

    open my $fh, '>:raw', $dest;
    $tree->write_tree( $fh );
    close $fh;

    return 1;
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
