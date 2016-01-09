package Whosonfirst::MaxMind::PointInPoly;

use LWP::Simple;
use JSON::XS;
use Memoize;

memoize('_pip');

sub _pip {
    my $uri = shift;

    my $rsp = get($uri);

    if ($rsp eq ""){
	return -1;
    }

    my $data = decode_json($rsp);

    if (scalar(@$data) eq 0){
	return -1;
    }

    return $data->[0]->{'Id'};
}

=head1 PACKAGE METHODS

=cut

=head2 __PACKAGE__->new($db_file)

=cut

sub new {
    my $pkg = shift;

    # PLEASE MAKE ME ARGS...

    my $self = {
	'host' => 'localhost',
	'port' => 11111,
    };

    bless $self, $pkg;
    return $self;
}

=head1 OBJECT METHODS

=cut

=head2 $obj->get_by_latlon($lat, $lon, $placetype)

=cut

sub lookup {
    my $self = shift;
    my $lat = shift;
    my $lon = shift;
    my $pt = shift;

    # PLEASE USE $self PROPS
    # PLEASE MAKE ME A PROPER URI THING

    my $uri = "http://localhost:1111/$pt?latitude=$lat&longitude=$lon";
    return _pip($uri);
}

return 1;

__END__
