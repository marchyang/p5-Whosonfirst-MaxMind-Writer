use strict;
use warnings;

use utf8;

use Text::CSV_XS;

use MaxMind::DB::Writer::Tree;
use Net::Works::Network;

package Whosonfirst::MaxMind::Writer;

=head1 PACKAGE METHODS

=cut

=head2 __PACKAGE__->new($cfg)

=cut

sub new {
    my $pkg = shift;
    my $cfg = shift;

    # Move MaxMind DB object constructure stuff in here?

    my $self = {};
        
    bless $self,$pkg;
    return $self;
}

=head1 OBJECT METHODS

=cut

=head2 $obj->publish_csv_file($csv_file, $db_file)

=cut

sub publish_csv_file {
    my $self = shift;
    my $csv_file = shift;
    my $db_file = shift;

    my $csv = Text::CSV_XS->new ({ binary => 1, auto_diag => 1 });

    # please do not die

    open my $csv_fh, "<:encoding(utf8)", $csv_file
	or die $!;

    while (my $row = $csv->getline ($fh)){

    }

    close $csv_fh;

    open my $db_fh, '>:raw', $db_file;
    $tree->write_tree($db_fh);

    close $dh_fh;

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
