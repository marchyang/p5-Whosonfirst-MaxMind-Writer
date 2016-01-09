package Whosonfirst::MaxMind::Data;

# THIS IS A BAD PACKAGE NAME - IT SHOULD PROBABLY JUST BE 
# Whosonfirst::Data BUT YAKS AND ALL THAT...
# (20160109/thisisaaronland)

use strict;
use warnings;
use utf8;

use File::Spec;
use File::Slurp;
use JSON::XS;

use Memoize;

memoize('_id2fname', '_id2tree', '_id2relpath', '_id2abspath', '_load');

sub _id2abspath {
    my $root = shift;
    my $id = shift;

    my $relpath = _id2relpath($id);

    return File::Spec->catdir(($root, $relpath));
}

sub _id2relpath {
    my $id = shift;

    my $fname = _id2fname($id);
    my $tree = _id2tree($id);

    return File::Spec->catfile($tree, $fname);
}

# PLEASE FOR TO BE DEALING WITH ALT FILES... SOME DAY

sub _id2fname {
    my $id = shift;
    return $id . ".geojson";
}

sub _id2tree {
    my $id = shift;

    my $tmp = $id;
    my @parts = ();

    while (length($tmp)){
	push @parts, substr($tmp, 0, 3);
	$tmp = substr($tmp, 3);
    }

    return File::Spec->catdir(@parts);
}

sub _load {
    my $path = shift;

    my $text = read_file($path);
    my $data = decode_json($text);

    return $data;
}

=head1 PACKAGE METHODS

=cut

=head2 __PACKAGE__->new($db_file)

=cut

sub new {
    my $pkg = shift;
    my $id = shift;

    # PLEASE TO MAKE ME ARGS, YEAH?

    my $self = {
	'root' => '/usr/local/mapzen/whosonfirst-data/data',
    };

    bless $self, $pkg;
    return $self;
}

=head1 OBJECT METHODS

=cut

=head2 $obj->load($wofid)

=cut

sub load {
    my $self = shift;
    my $id = shift;

    my $path = _id2abspath($self->{'root'}, $id);
    return _load($path);
}
    
return 1;

__END__

