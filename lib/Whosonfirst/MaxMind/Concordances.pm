package Whosonfirst::MaxMind::Concordances;

use LWP::Simple;
use JSON::XS;
use Memoize;

memoize('_query');

=head1 PACKAGE METHODS

=cut

=head2 __PACKAGE__->new($db_file)

=cut

sub new {
    my $pkg = shift;

    # PLEASE MAKE ME ARGS...

    my $self = {
	'host' => 'localhost',
	'port' => 8228,
    };

    bless $self, $pkg;
    return $self;
}

=head1 OBJECT METHODS

=cut

=head2 $obj->lookup($src, $id)

=cut

sub lookup {
    my $self = shift;
    my $src = shift;
    my $id = shift;

    # PLEASE MAKE ME A PROPER URI THING

    my $uri = "http://localhost:8228?k=" . $src . "id&v=" . $id;

    return _query($uri);
}

sub _query {
    my $uri = shift;

    my $rsp = get($uri);

    if ($rsp eq "") {
	return -1;
    }

    my $data = decode_json($rsp);

    my $first = $data->[0];
    return $first->{'wof:id'};
}

return 1;

__END__
