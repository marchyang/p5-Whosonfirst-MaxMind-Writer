#!/usr/bin/env perl

use strict;
use warnings;

use Data::Dumper;
use Getopt::Std;

use MaxMind::DB::Reader;
use Scalar::Util 'reftype';

{
    &main();
    exit();
}

sub main {

    my %opts = ();

    getopts('s:', \%opts);

    my $src = $opts{'s'};

    if (! $src){
	print "source parameter is missing\n";
	return 0;
    }

    if (! -e $src){
	print "source does not exist\n";
	return 0;
    }

    my $reader = MaxMind::DB::Reader->new(file => $src);
    # my $meta = $reader->metadata();

    my %report = ();

    my $callback = sub {
	    my $ip_as_integer = shift;		# ignore
	    my $mask_length   = shift;		# ignore
	    my $data          = shift;

	    &reporter("", $data, \%report);
    };

    $reader->iterate_search_tree($callback);

    print Dumper(\%report);
}

sub reporter {
    my $parent = shift;
    my $subject = shift;
    my $report = shift;
    
    my %scalars = (
	'latitude' => 'double',
	'longitude' => 'double',
	'geoname_id' => 'uint64',
	);

    my %arrays = (
	'HASH' => 'map',
	);

    my $isa = ref($subject) || ref(\$subject);
    
    if ($isa eq "HASH"){
	
	foreach my $k (keys %$subject){
	    
	    if (! $report->{$k}){
		$report->{$k} = "map";
	    }
	    
	    &reporter($k, $subject->{$k}, $report);
	}
    }

    elsif ($isa eq "ARRAY"){

	if (! $report->{$parent}){

	    my $first = $subject->[0];
	    my $first_isa = ref($first) || ref(\$first);

	    my $type = $arrays{$first_isa} || $first_isa;
	    $report->{$parent} = [ 'array', $type ];
	}

	foreach my $item (@$subject){
	    &reporter("", $item, $report);
	}
    }

    elsif ($isa eq "SCALAR"){
	
	if (! $report->{$parent}){

	    my $type = $scalars{$parent} || "utf8_string";
	    $report->{$parent} = $type;
	}
    }
    
    else {
	print "SUBJECT ($parent) IS A $isa\n";
	print Dumper($subject);
	exit();
    }

}

__END__

./scripts/inspect-mmdb.pl -s /usr/local/mapzen/maxmind-data/GeoLite2-City.mmdb
    $VAR1 = { 
          'es' => 'map',
          'ru' => 'map',
          'geoname_id' => 'map',
          'ja' => 'map',
          'names' => 'map',
          'metro_code' => 'map',
          'code' => 'map',
          'de' => 'map',
          'en' => 'map',
          'longitude' => 'map',
          'registered_country' => 'map',
          'time_zone' => 'map',
          'iso_code' => 'map',
          'type' => 'map',
          'country' => 'map',
          'pt-BR' => 'map',
          'traits' => 'map',
          'postal' => 'map',
          'city' => 'map',
          'continent' => 'map',
          'latitude' => 'map',
          'represented_country' => 'map',
          'fr' => 'map',
          'subdivisions' => 'map',
          'is_satellite_provider' => 'map',
          'is_anonymous_proxy' => 'map',
          'zh-CN' => 'map',
          'location' => 'map'
};
