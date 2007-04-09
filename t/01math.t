#!/usr/bin/perl -w
use Test::More tests => 30;
use strict;

BEGIN {
	$| = 1;
	chdir 't' if -d 't';
	unshift @INC, '../lib';
	use_ok('Math::Rotation');
}

my ( $r, $r1, $r2 );
my ( $x, $y,  $z );

ok( $r = new Math::Rotation, "$r new Math::Rotation()" );

ok( ( $r = Math::Rotation->new->stringify ) eq "0 0 1 0", "$r Math::Rotation->new->stringify" );

ok( $r = new Math::Rotation( [ 0, 0, 1 ], 0 ), "$r new Math::Rotation([0, 0, 1],0)" );

ok( $r = new Math::Rotation( 0, 0, 1, 0 ), "$r new Math::Rotation( 0, 0, 1, 0 )" );

ok( $r = new Math::Rotation( [ 0, 0, 1 ], [ 0, 0, 1 ] ), "$r new Math::Rotation([0, 0, 1], [0, 0, 1])" );

ok( $r = new Math::Rotation( [ 1, 0, 1 ], [ 0, 0, 1 ] ), "$r new Math::Rotation([1, 0, 1], [0, 0, 1])" );

ok( $r = new Math::Rotation( [ 1, 1, 1 ], [ 0, 0, 1 ] ), "$r new Math::Rotation([1, 1, 1], [0, 0, 1])" );

ok( $r1 = new Math::Rotation( 1, 2, 3, 4 ), "$r1 new Math::Rotation( 1, 2, 3, 4 )" );

ok( $r2 = new Math::Rotation( 1, 2, 4, 8 ), "$r2 new Math::Rotation( 1, 2, 4, 8 )" );

ok( $r = $r1->inverse, "$r inverse" );

ok( $r = $r1->multiply($r2), "$r multiply" );

ok( ( $x, $y, $z ) = $r1->multVec( 1, 1, 1 ), "$x, $y, $z multVec" );

ok( $r = $r1->slerp( $r2, 1 / 3 ), "$r slerp" );

$r2->setX(2);
ok( $r = $r2, "$r2 setX" );
ok( $r = $r1->multiply($r2), "$r multiply" );

$r2->setY(2);
ok( $r = $r2, "$r2 setY" );
ok( $r = $r1->multiply($r2), "$r multiply" );

$r2->setZ(2);
ok( $r = $r2, "$r2 setZ" );
ok( $r = $r1->multiply($r2), "$r multiply" );

$r2->setAxis( 2, 3, 4 );
ok( $r = $r2, "$r2 setAxis" );
ok( $r = $r1->multiply($r2), "$r multiply" );

$r2->setAngle(8);
ok( $r = $r2, "$r2 setAngle" );
ok( $r = $r1->multiply($r2), "$r multiply" );

$r2->setAxisAngle( 5, 6, 7, 8 );
ok( $r = $r2, "$r2 setAxisAngle" );
ok( $r = $r1->multiply($r2), "$r multiply" );
ok( $r = $r1 * $r2, "$r multiply" );


$r2->setAxisAngle( 5, 6, 7, 8 );
ok( $r = $r2, "$r2 setAxisAngle" );
ok( $r = $r1->multiply($r2), "$r multiply" );
ok( $r = ~($r1 * $r2), "$r multiply" );

__END__
foreach my $c ( 1 .. 3 )
{
	is( $c, $c, "$c accuracy = 12" );
}

