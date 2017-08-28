package Whosonfirst::MaxMind::Types;

# https://metacpan.org/pod/MaxMind::DB::Writer::Tree#DATA-TYPES

use strict;
use warnings;
use utf8;

=head1 PACKAGE METHODS

=cut

=head2 __PACKAGE__->maxmind()

=cut

sub maxmind {
    my $pkg = shift;

    my %types = (
	'city' => 'map',
	'country' => 'map',
	'continent' => 'map',
	'postal' => 'map',	# maybe?
	'continent_code' => 'utf8_string',
	'code' => 'utf8_string',
	'geoname_id' => 'uint32',
	'iso_code' => 'utf8_string',
	'metro_code' => 'utf8_string',
	'location' => 'map',
	'latitude' => 'double',
	'longitude' => 'double',
	'names' => 'map',
	'traits' => 'map',	# ?????
	'registered_country' => 'map',
	'represented_country' => 'map',
	'subdivisions' => [ 'array', 'map' ],
	'time_zone' => 'utf8_string',
	'type' => 'utf8_string',
	'is_satellite_provider' => 'boolean',
	'is_anonymous_proxy' => 'boolean',
    );

    # for my $lang (@{$meta->languages()} ) {
    # $types{ $lang } = 'utf8_string';
    # }

    return \%types;
}

=head __PACKAGE__->whosonfirst()

=cut

sub whosonfirst {
    my $pkg = shift;

    my %types = (
	'gn:id' => 'uint64',
	'mm:latitude' => 'double',
	'mm:longitude' => 'double',
	'wof:id' => 'uint64',
	'wof:name' => 'utf8_string',
	'wof:placetype' => 'utf8_string',
	'wof:country' => 'utf8_string',
	'wof:repo' => 'utf8_string',
	'wof:path' => 'utf8_string',
	'mz:latitude' => 'double',
	'mz:longitude' => 'double',
	'mz:min_latitude' => 'double',
	'mz:min_longitude' => 'double',
	'mz:max_latitude' => 'double',
	'mz:max_longitude' => 'double',
	'spr' => 'utf8_string',
    );

    return \%types;
}

=head1 VERSION

0.2

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

