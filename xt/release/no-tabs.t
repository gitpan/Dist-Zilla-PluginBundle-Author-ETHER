use strict;
use warnings;

# this test was generated with Dist::Zilla::Plugin::Test::NoTabs 0.08

use Test::More 0.88;
use Test::NoTabs;

my @files = (
    'lib/Dist/Zilla/MintingProfile/Author/ETHER.pm',
    'lib/Dist/Zilla/PluginBundle/Author/ETHER.pm',
    't/00-report-prereqs.t',
    't/01-pluginbundle-basic.t',
    't/02-minter-github.t',
    't/03-pluginbundle-server.t',
    't/04-pluginbundle-installer.t',
    't/05-pluginbundle-core.t',
    't/06-airplane.t',
    't/07-minter-dzil-plugin.t',
    't/corpus/global/config.ini',
    't/lib/Helper.pm',
    't/zzz-check-breaks.t',
    'xt/author/00-compile.t',
    'xt/author/pod-spell.t',
    'xt/release/changes_has_content.t',
    'xt/release/clean-namespaces.t',
    'xt/release/cpan-changes.t',
    'xt/release/distmeta.t',
    'xt/release/eol.t',
    'xt/release/kwalitee.t',
    'xt/release/minimum-version.t',
    'xt/release/mojibake.t',
    'xt/release/no-tabs.t',
    'xt/release/pod-syntax.t',
    'xt/release/portability.t'
);

notabs_ok($_) foreach @files;
done_testing;
