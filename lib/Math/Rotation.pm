package Math::Rotation;

use strict;
use warnings;

use Carp;
use Math::Quaternion;

#use Exporter;

use overload
  '~'    => \&inverse,
  'bool' => sub { 1; },    # So we can do if ($foo=Math::Quaternion->new) { .. }
  '""'   => \&stringify,
  '*'    => \&multiply,
  ;

our $VERSION = '0.01';

=head1 NAME

Math::Rotation - Perl class to represent rotations

=head1 SYNOPSIS

 use Math::Rotation;
 my $r = new Math::Rotation;  # Make a new unit rotation
 
 # Make a rotation about the axis (0,1,0)
 my $r2 = new Math::Rotation([0,1,0], 0.1);
 my $r3 = new Math::Rotation(1, 2, 3, 4);

 my $fromVector = [1,2,3];
 my $toVector = [2,3,4];
 my $r4 = new Math::Rotation($fromVector, $toVector);

 my $r5 = $r2 * $r3;
 my $r6 = ~$r5;

=head1 DESCRIPTION
=head1 METHODS

=over 1

=item B<new>

 my $r = new Math::Rotation;                   # Make a new unit rotation.
 my $r2 = new Math::Rotation(1,2,3,4);         # (x,y,z, angle)
 my $r3 = new Math::Rotation([1,2,3],4);       # (axis, angle)
 my $r3 = new Math::Rotation([1,2,3],[1,2,3]); # (fromVec, toVec)

 my $r5 = new_from_quaternion Math::Rotation(new Math::Quaternion);
=cut

sub new {
	my $self  = shift;
	my $class = ref($self) || $self;
	my $this  = bless {}, $class;

	if ( 0 == @_ ) {
		# No arguments, default to standard rotation.
		$this->private::setQuaternion( new Math::Quaternion() );
	} elsif ( 1 == @_ ) {    # rotation
		$this->private::setQuaternion( $_[0]->getQuaternion );
	} elsif ( 2 == @_ ) {

		my $arg1    = shift;
		my $reftype = ref($arg1);

		if ( "ARRAY" eq $reftype ) {
			my $arg2    = shift;
			my $reftype = ref($arg2);

			if ( !$reftype ) {    # vec1, angle

				$this->setAxisAngle( @$arg1, $arg2 );

			} elsif ( "ARRAY" eq $reftype ) {    # vec1, vec2
				$this->private::setQuaternion( eval { Math::Quaternion::rotation( $arg1, $arg2 ) }
					  || new Math::Quaternion() );
			} else {
				croak("Don't understand arguments passed to new()");
			}
		}
	} elsif ( 4 == @_ ) {    # x,y,z,angle
		$this->setAxisAngle(@_);
	} else {
		croak("Don't understand arguments passed to new()");
	}

	return $this;
}

sub new_from_quaternion {
	return $_[0]->private::new_from_quaternion( new Math::Quaternion( $_[1] ) );
}

sub private::new_from_quaternion {
	my $self  = shift;
	my $class = ref($self) || $self;
	my $this  = bless {}, $class;

	$this->private::setQuaternion(shift);

	return $this;
}

=item B<setX(x)>
	Sets the first value of the axis vector
=cut

sub setX {
	my $this = shift;
	$this->{axis}->[0] = shift;
	$this->{quaternion} = Math::Quaternion::rotation( $this->{angle}, $this->{axis} );
}

=item B<setY(y)>
	Sets the second value of the axis vector
=cut

sub setY {
	my $this = shift;
	$this->{axis}->[1] = shift;
	$this->{quaternion} = Math::Quaternion::rotation( $this->{angle}, $this->{axis} );
}

=item B<setZ(z)>
	Sets the third value of the axis vector
=cut

sub setZ {
	my $this = shift;
	$this->{axis}->[2] = shift;
	$this->{quaternion} = Math::Quaternion::rotation( $this->{angle}, $this->{axis} );
}

=item B<setAxis(x,y,z)>
	Sets axis of rotation from a 3 components @array.
=cut

sub setAxis {
	my $this = shift;
	@{ $this->{axis} } = @_;
	$this->{quaternion} = Math::Quaternion::rotation( $this->{angle}, $this->{axis} );
}

=item B<setAngle(angle)>
	Sets angle of rotation in radiants.
=cut

sub setAngle {
	my $this = shift;
	$this->{angle} = shift;
	$this->{quaternion} = Math::Quaternion::rotation( $this->{angle}, $this->{axis} );
}

=item B<setAxisAngle(x,y,z, angle)>
	Sets value of rotation from axis angle.
=cut

sub setAxisAngle {
	my $this = shift;
	$this->{axis}       = [ @_[ 0, 1, 2 ] ];
	$this->{angle}      = $_[3];
	$this->{quaternion} = Math::Quaternion::rotation( $this->{angle}, $this->{axis} );
}

=item B<setQuaternion(Math::Quaternion)>
	Sets value of rotation from a quaternion.
=cut

sub setQuaternion {
	my $this = shift;
	$this->private::setQuaternion( eval { new Math::Quaternion(shift) } || new Math::Quaternion() );
}

sub private::setQuaternion {
	my $this = shift;
	my $q    = shift;
	$this->{quaternion} = $q;
	@{ $this->{axis} } = $q->rotation_axis;
	$this->{angle} = $q->rotation_angle;
}

=item B<getX>
	Returns the first value of the axis vector.
=cut

sub getX { $_[0]->{axis}->[0] }

=item B<getX>
	Returns the second value of the axis vector.
=cut

sub getY { $_[0]->{axis}->[1] }

=item B<getX>
	Returns the third value of the axis vector
=cut

sub getZ { $_[0]->{axis}->[2] }

=item B<getAxis>
	Returns the axis of rotation as an @array.
=cut

sub getAxis { @{ $_[0]->{axis} } }

=item B<getAngle>
	Returns corresponding 3D rotation angle in radians.
=cut

sub getAngle { $_[0]->{angle} }

=item B<getAxisAngle>
	Returns corresponding 3D rotation (x, y, z, angle).
=cut

sub getAxisAngle {
	my $this = shift;
	return (
		$this->getAxis,
		$this->getAngle
	);
}

=item B<getQuaternion>
	Returns corresponding Math::Quaternion.
=cut

sub getQuaternion { new Math::Quaternion( $_[0]->{quaternion} ) }

=item B<inverse>
	Returns a Math::Rotation object whose value is the inverse of this object's rotation.
=cut

# (1,2,3, 4) -> (1,2,3, -4)
sub inverse { $_[0]->private::new_from_quaternion( $_[0]->{quaternion}->inverse ) }

=item B<multiply(Math::Rotation)>
	Returns an Math::Rotation whose value is the object multiplied by the passed Math::Rotation.
=cut

sub multiply { $_[0]->private::new_from_quaternion( $_[1]->{quaternion}->multiply( $_[0]->{quaternion} ) ) }

=item B<multVec(x,y,z)>
	Returns an @array whose value is the 3D vector (x,y,z) multiplied by the matrix corresponding to this object's rotation.
=cut

sub multVec {
	my $this = shift;
	return $this->{quaternion}->rotate_vector(@_);
}

=item B<slerp(destRotation, t)>
	Returns a Math::Rotation object whose value is the spherical linear interpolation between this object's
	rotation and destRotation at value 0 <= t <= 1. For t = 0, the value is this object's rotation.
	For t = 1, the value is destRotation.
=cut

sub slerp { $_[0]->private::new_from_quaternion( $_[0]->{quaternion}->slerp( $_[1]->{quaternion}, $_[2] ) ) }

=item B<stringify>
Returns a string representation of the rotation. This is used
to overload the '""' operator, so that rotations may be
freely interpolated in strings.

	my $q = new Math::Rotation(1,2,3,4);
	print $q->stringify;                # "1 2 3 4"
	print "$q";                         # "1 2 3 4"

=cut

sub stringify {
	my $this = shift;
	return join " ", $this->getAxisAngle;
}
