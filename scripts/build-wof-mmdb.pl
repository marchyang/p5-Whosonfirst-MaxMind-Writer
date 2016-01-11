#!/usr/bin/env perl

use strict;
use warnings;

use Getopt::Std;
use Whosonfirst::MaxMind::Writer;

{
    &main();
    exit();
}

sub main {

    my %opts = ();

    getopts('s:d:', \%opts);

    my $src = $opts{'s'};
    my $dest = $opts{'d'};

    if ((! $src) || (! $dest)){
	print "source or destination parameters are missing\n";
	return 0;
    }

    if (! -e $src){
	print "source does not exist\n";
	return 0;
    }

    my $meta = {
	database_type => "WOF",
	description => { en => 'WOF' },
	ip_version => 4,
	record_size => 32,
    };

    my $ok = Whosonfirst::MaxMind::Writer->build_wof_mmdb($src, $dest, $meta);
    
    print "done ($ok)";
    return $ok;
}
