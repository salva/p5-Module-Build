# sample.t -- a sample test file for Module::Build

use strict;
use lib $ENV{PERL_CORE} ? '../lib/Module/Build/t/lib' : 't/lib';
use MBTest;
use DistGen;

plan tests => 13;

# Ensure any Module::Build modules are loaded from correct directory
blib_load('Module::Build');

# create dist object in a temp directory
# MBTest uses different dirs for Perl core vs CPAN testing 
my $dist = DistGen->new( dir => MBTest->tmpdir );

# generate the skeleton files and also schedule cleanup
$dist->regen;
END{ $dist->remove }

# enter the test distribution directory before further testing
$dist->chdir_in;

# get a Module::Build object and test with it
my $mb;
ok( $mb = $dist->new_from_context, 
  "Default Build.PL" 
);
ok( ! $mb->needs_compiler, "needs_compiler is false" );
ok( ! exists $mb->{properties}{build_requires}{'ExtUtils::CBuilder'},
  "ExtUtils::CBuilder is not in build_requires" 
);

#--------------------------------------------------------------------------#
# try with c_source
#--------------------------------------------------------------------------#
$dist->change_build_pl({
    module_name => $dist->name,
    license => 'perl',
    c_source => 'src',
});
$dist->regen;
ok( $mb = $dist->new_from_context, 
  "Build.PL with c_source" 
);
is( $mb->c_source, 'src', "c_source is set" );
ok( $mb->needs_compiler, "needs_compiler is true" );
ok( exists $mb->{properties}{build_requires}{'ExtUtils::CBuilder'},
  "ExtUtils::CBuilder was added to build_requires" 
);

#--------------------------------------------------------------------------#
# try with xs files
#--------------------------------------------------------------------------#
$dist = DistGen->new(dir => 'MBTest', xs => 1);
$dist->regen;
$dist->chdir_in;

ok( $mb = $dist->new_from_context, 
  "Build.PL with xs files" 
);
ok( $mb->needs_compiler, "needs_compiler is true" );
ok( exists $mb->{properties}{build_requires}{'ExtUtils::CBuilder'},
  "ExtUtils::CBuilder was added to build_requires" 
);

#--------------------------------------------------------------------------#
# force needs_compiler off, despite xs modules
#--------------------------------------------------------------------------#

$dist->change_build_pl({
    module_name => $dist->name,
    license => 'perl',
    needs_compiler => 0,
});
$dist->regen;

ok( $mb = $dist->new_from_context ,
  "Build.PL with xs files, but needs_compiler => 0" 
);
is( $mb->needs_compiler, 0, "needs_compiler is false" );
ok( ! exists $mb->{properties}{build_requires}{'ExtUtils::CBuilder'}, 
  "ExtUtils::CBuilder is not in build_requires" 
);

# vim:ts=2:sw=2:et:sta:sts=2