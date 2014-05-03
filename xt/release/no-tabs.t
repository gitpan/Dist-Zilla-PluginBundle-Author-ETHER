use strict;
use warnings;

# this test was generated with Dist::Zilla::Plugin::Test::NoTabs 0.07

use Test::More 0.88;
use Test::NoTabs;

my @files = (
    'lib/Dist/Zilla/MintingProfile/Author/ETHER.pm',
    'lib/Dist/Zilla/PluginBundle/Author/ETHER.pm'
);

notabs_ok($_) foreach @files;
done_testing;
