# $Id: Build.PL,v 1.16 2008/02/08 08:03:17 asc Exp $

use strict;
use Module::Build;

my $build = Module::Build->new(module_name => 'Whosonfirst::MaxMind::Writer',
			              dist_author => 'Mapzen',
			              dist_abstract => 'Perl libraries for working with MaxMindDB databases and Who\'s On First document',
			              dist_version_from => 'lib/Whosonfirst/MaxMind/Writer.pm',
			              license           => 'perl',
			       requires => {
				         'namespace::autoclean'   => '0',
				         'Math::Int64'   => '0',
				         'Math::Int128'   => '0',
				         'MaxMind::DB::Common'   => '0',
				         'Data::IEEE754'   => '0',
				         'Digest::SHA1'   => '0',
				         'Sereal::Encoder'   => '0',
				         'Moose'   => '0',
				         'MooseX::StrictConstructor'   => '0',
				         'MooseX::Params::Validate'   => '0',
				         'Net::Works'   => '0',
			       },
			       build_requires => {
				      'Test::Simple' => '0.47',
			       },
			              create_readme      => 1,
			       create_makefile_pl => 'passthrough');

$build->create_build_script();
