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
    my $db_file = shift;

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

    # please don't die...

    open my $db_fh, '>:raw', $db_file
	or die $!;

    my $self = {
	'tree' => $tree,
	'db_fh' => $db_fh
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
