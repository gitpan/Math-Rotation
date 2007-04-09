use Module::Build;

my $b = Module::Build->new
  (
	module_name => 'Math::Rotation',
	dist_author => 'Holger Seelig <holger.seelig@yahoo.de>',
	license     => 'perl',
	requires    => {
		'strict'   => 0,
		'warnings' => 0,
		'constant' => 0,
		'overload' => 0,

		#'Exporter'     => 0,
		'Carp' => 0,

		'Math::Quaternion' => 0,
	},
	recommends => {
		'Test::Pod'           => '1.0',
		'Test::Pod::Coverage' => '1.0',
	},
	build_requires => {
		'Test::More' => 0,
	},
	create_makefile_pl => 'traditional',
	sign               => 1,
	#   conflicts => {},
	#   script_files => ['bin/tk-motion.pl'],
  );

$b->create_build_script;

#perltidy -se -l=96 -et 4 -nbbc -nbbb -dsm -ce -fnl
__END__
