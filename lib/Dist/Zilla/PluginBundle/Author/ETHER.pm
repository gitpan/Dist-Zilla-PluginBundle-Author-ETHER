use strict;
use warnings;
package Dist::Zilla::PluginBundle::Author::ETHER;
BEGIN {
  $Dist::Zilla::PluginBundle::Author::ETHER::AUTHORITY = 'cpan:ETHER';
}
{
  $Dist::Zilla::PluginBundle::Author::ETHER::VERSION = '0.022';
}
# git description: v0.021-5-g1f77b45

# ABSTRACT: A plugin bundle for distributions built by ETHER

use Moose;
with
    'Dist::Zilla::Role::PluginBundle::Easy',
    'Dist::Zilla::Role::PluginBundle::PluginRemover' => { -version => '0.102' },
    'Dist::Zilla::Role::PluginBundle::Config::Slicer';

use Dist::Zilla::Util;
use Module::Runtime 'use_module';
use Moose::Util::TypeConstraints;
use namespace::autoclean;

# Note: no support yet for depending on a specific version of the plugin
has installer => (
    is => 'ro', isa => 'Str',
    lazy => 1,
    default => sub {
        exists $_[0]->payload->{installer}
            ? $_[0]->payload->{installer}
            : 'ModuleBuildTiny';
    },
);

has server => (
    is => 'ro', isa => enum([qw(github gitmo p5sagit none)]),
    lazy => 1,
    default => sub {
        exists $_[0]->payload->{server}
            ? $_[0]->payload->{server}
            : 'github';
    },
);

my %installer_args = (
    ModuleBuildTiny => { ':version' => '0.004' },
);

sub configure
{
    my $self = shift;

    $self->add_plugins(
        # VersionProvider
        [ 'Git::NextVersion'    => { version_regexp => '^v([\d._]+)(-TRIAL)?$' } ],

        # BeforeBuild
        [ 'PromptIfStale' => 'build' => { phase => 'build', module => [ blessed($self) ] } ],
        [ 'PromptIfStale' => 'release' => { phase => 'release', check_all_plugins => 1 } ],

        # ExecFiles, ShareDir
        [ 'ExecDir'             => { dir => 'script' } ],
        'ShareDir',

        # Finders
        [ 'FileFinder::ByName' => Examples => { dir => 'examples' } ],

        # Gather Files
        [ 'Git::GatherDir'      => { exclude_filename => 'LICENSE' } ],
        qw(MetaYAML MetaJSON License Readme Manifest),
        [ 'Test::Compile'       => { ':version' => '2.023', fail_on_warning => 'author', bail_out_on_fail => 1, script_finder => [qw(:ExecFiles @Author::ETHER/Examples)] } ],
        [ 'Test::CheckDeps'     => { ':version' => '0.007', fatal => 1, level => 'suggests' } ],
        'NoTabsTests',
        'EOLTests',
        'MetaTests',
        [ 'Test::Version'       => { is_strict => 1 } ],
        [ 'Test::CPAN::Changes' => { ':version' => '0.008' } ],
        'Test::ChangesHasContent',
        'Test::UnusedVars',
        [ 'Test::MinimumVersion' => { ':version' => '2.000003', max_target_perl => '5.008008' } ],
        'PodSyntaxTests',
        'PodCoverageTests',
        'Test::PodSpelling',
        #[Test::Pod::LinkCheck]     many outstanding bugs
        'Test::Pod::No404s',
        [ 'Test::Kwalitee'      => { ':version' => '2.06' } ],
        [ 'MojibakeTests' ],

        # Prune Files
        'PruneCruft',
        'ManifestSkip',
        # (ReadmeAnyFromPod)

        # Munge Files
        # (Authority)
        'Git::Describe',
        [ PkgVersion            => { ':version' => '4.300036', die_on_existing_version => 1 } ],
        'PodWeaver',
        [ 'NextRelease'         => { ':version' => '4.300018', time_zone => 'UTC', format => '%-8V  %{yyyy-MM-dd HH:mm:ss\'Z\'}d (%U)' } ],

        # MetaData
        $self->server eq 'github' ? ( [ 'GithubMeta' ] ) : (),
        [ 'AutoMetaResources'   => { 'bugtracker.rt' => 1,
              $self->server eq 'gitmo' ? ( 'repository.gitmo' => 1 )
            : $self->server eq 'p5sagit' ? ( 'repository.p5sagit' => 1 )
            : ()
        } ],
        [ 'Authority'           => { authority => 'cpan:ETHER' } ],
        [ 'MetaNoIndex'         => { directory => [ qw(t xt examples) ] } ],
        [ 'MetaProvides::Package' => { meta_noindex => 1 } ],
        'MetaConfig',
        #[ContributorsFromGit]

        # Register Prereqs
        # (MakeMaker or other installer)
        'AutoPrereqs',
        'MinimumPerl',
        [ 'Prereqs' => 'Test::CheckDeps, indirect' => {
                '-phase' => 'test', '-relationship' => 'requires',
                'CPAN::Meta::Check' => '0.007',
                } ],
        [ 'Prereqs' => installer_requirements => {
                '-phase' => 'develop', '-relationship' => 'requires',
                'Dist::Zilla' => Dist::Zilla->VERSION,
                blessed($self) => $self->VERSION,
                # this is mostly pointless as by the time this runs, we're
                # already trying to load the installer plugin
                $self->installer ne 'none'
                    ? ( Dist::Zilla::Util->expand_config_package_name($self->installer) =>
                        ($installer_args{$self->installer} // {})->{':version'} // 0
                    )
                    : (),
            } ],

        # Install Tool
        [ 'ReadmeAnyFromPod'    => { type => 'markdown', filename => 'README.md', location => 'root' } ],
        $self->installer ne 'none'
            ? [ $self->installer => $installer_args{$self->installer} // () ]
            : (),
        'InstallGuide',

        # After Build
        [ 'CopyFilesFromBuild'  => { copy => 'LICENSE' } ],
        [ 'Run::AfterBuild' => { run => q!if [[ %d =~ %n ]]; then test -e .ackrc && grep -q -- '--ignore-dir=%d' .ackrc || echo '--ignore-dir=%d' >> .ackrc; fi! } ],

        # Test Runner
        'RunExtraTests',

        # Before Release
        [ 'Git::Check'          => { allow_dirty => [ qw(README.md LICENSE) ] } ],
        'Git::CheckFor::MergeConflicts',
        [ 'Git::CheckFor::CorrectBranch' => { ':version' => '0.004', release_branch => 'master' } ],
        [ 'Git::Remote::Check'  => { branch => 'master', remote_branch => 'master' } ],
        'CheckPrereqsIndexed',
        'TestRelease',
        # (ConfirmRelease)

        # Releaser
        'UploadToCPAN',

        # After Release
        [ 'Git::Commit'         => { allow_dirty => [ qw(Changes README.md LICENSE) ], commit_msg => '%N-%v%t%n%n%c' } ],
        [ 'Git::Tag'            => { tag_format => 'v%v%t', tag_message => 'v%v%t' } ],
        $self->server eq 'github' ? ( [ 'GitHub::Update' => { metacpan => 1 } ] ) : (),
        'Git::Push',
        [ 'InstallRelease'      => { install_command => 'cpanm .' } ],

        # listed late, to allow all other plugins which do BeforeRelease checks to run first.
        'ConfirmRelease',
    );

    # check for a bin/ that should probably be renamed to script/
    warn 'bin/ detected - should this be moved to script/, so its contents can be installed into $PATH?' if -d 'bin';
}

__PACKAGE__->meta->make_immutable;

__END__

=pod

=encoding utf-8

=for :stopwords Karen Etheridge metacpan Stopwords ModuleBuildTiny github metadata
customizations KENTNL's irc

=head1 NAME

Dist::Zilla::PluginBundle::Author::ETHER - A plugin bundle for distributions built by ETHER

=head1 VERSION

version 0.022

=head1 SYNOPSIS

In C<dist.ini>:

    [@Author::ETHER]

=head1 DESCRIPTION

This is a L<Dist::Zilla> plugin bundle. It is approximately equivalent to the
following C<dist.ini> (following the preamble):

    ;;; VersionProvider
    [Git::NextVersion]
    version_regexp = ^v([\d._]+)(-TRIAL)?$

    ;;; BeforeBuild
    [PromptIfStale / build]
    phase = build
    module = Dist::Zilla::Plugin::Author::ETHER
    [PromptIfStale / release]
    phase = release
    check_all_plugins = 1


    ;;; ExecFiles, ShareDir
    [ExecDir]
    dir = script

    [ShareDir]


    ;;; Gather Files
    [Git::GatherDir]
    exclude_filename = LICENSE

    [MetaYAML]
    [MetaJSON]
    [License]
    [Readme]
    [Manifest]

    [FileFinder::ByName / Examples]
    dir = examples

    [Test::Compile]
    :version = 2.023
    fail_on_warning = author
    bail_out_on_fail = 1
    script_finder = :ExecFiles
    script_finder = Examples

    [Test::CheckDeps]
    :version = 0.007
    fatal = 1
    level = suggests

    [NoTabsTests]
    [EOLTests]
    [MetaTests]
    [Test::Version]
    [Test::CPAN::Changes]
    [Test::ChangesHasContent]
    [Test::UnusedVars]

    [Test::MinimumVersion]
    :version = 2.000003
    max_target_perl = 5.008008

    [PodSyntaxTests]
    [PodCoverageTests]
    [Test::PodSpelling]
    ;[Test::Pod::LinkCheck]     many outstanding bugs
    [Test::Pod::No404s]
    [Test::Kwalitee]
    [MojibakeTests]


    ;;; Munge Files
    ; (Authority)
    [Git::Describe]
    [PkgVersion]
    :version = 4.300036
    die_on_existing_version = 1

    [PodWeaver]
    [NextRelease]
    :version = 4.300018
    time_zone = UTC
    format = %-8V  %{yyyy-MM-dd HH:mm:ss'Z'}d (%U)


    ;;; MetaData
    [GithubMeta]    ; (if server = 'github' or omitted)
    [AutoMetaResources]
    bugtracker.rt = 1
    ; (plus repository.* = 1 if server = 'gitmo' or 'p5sagit')

    [Authority]
    authority = cpan:ETHER

    [MetaNoIndex]
    directory = t
    directory = xt
    directory = examples

    [MetaProvides::Package]
    meta_noindex = 1

    [MetaConfig]


    ;;; Register Prereqs
    [AutoPrereqs]
    [MinimumPerl]

    [Prereqs / Test::CheckDeps, indirect]
    -phase = test
    -relationship = requires
    CPAN::Meta::Check = 0.007

    [Prereqs / installer_requirements]
    -phase = develop
    -relationship = requires
    Dist::Zilla = <version used to built this bundle>
    Dist::Zilla::PluginBundle::Author::ETHER = <our own version>


    ;;; Install Tool
    [ReadmeAnyFromPod]
    type = markdown
    filename = README.md
    location = root

    <specified installer> or [ModuleBuildTiny]
    [InstallGuide]


    ;;; After Build
    [CopyFilesFromBuild]
    copy = LICENSE

    [Run::AfterBuild]
    run => if [[ %d =~ %n ]]; then test -e .ackrc && grep -q -- '--ignore-dir=%d' .ackrc || echo '--ignore-dir=%d' >> .ackrc; fi


    ;;; TestRunner
    [RunExtraTests]


    ;;; Before Release
    [Git::Check]
    allow_dirty = README.md
    allow_dirty = LICENSE

    [Git::CheckFor::MergeConflicts]

    [Git::CheckFor::CorrectBranch]
    :version = 0.004
    release_branch = master

    [Git::Remote::Check]
    branch = master
    remote_branch = master

    [CheckPrereqsIndexed]
    [TestRelease]
    ;(ConfirmRelease)


    ;;; Releaser
    [UploadToCPAN]


    ;;; AfterRelease
    [Git::Commit]
    allow_dirty = Changes
    allow_dirty = README.md
    allow_dirty = LICENSE
    commit_msg = %N-%v%t%n%n%c

    [Git::Tag]
    tag_format = v%v%t
    tag_message = v%v%t

    [GitHub::Update]    ; (if server = 'github' or omitted)
    metacpan = 1

    [Git::Push]

    [InstallRelease]
    install_command = cpanm .


    ; listed late, to allow all other plugins which do BeforeRelease checks to run first.
    [ConfirmRelease]

=for Pod::Coverage configure mvp_multivalue_args

The distribution's code is assumed to be hosted at L<github|http://github.com>;
L<RT|http://rt.cpan.org> is used as the issue tracker.
The home page in the metadata points to L<github|http://github.com>,
while the home page on L<github|http://github.com> is updated on release to
point to L<metacpan|http://metacpan.org>.
The version and other metadata is derived directly from the local git repository.

=head1 OPTIONS / OVERRIDES

=head2 version

Use C<< V=<version> >> to override the version of the distribution being built;
otherwise the version is
incremented from the last git tag.

=head2 pod coverage

Subs can be considered "covered" for pod coverage tests by adding a directive to pod:

    =for Pod::Coverage foo bar baz

=head2 spelling stopwords

Stopwords for spelling tests can be added by adding a directive to pod (as
many as you'd like), as described in L<Pod::Spelling/ADDING STOPWORDS>:

    =for stopwords foo bar baz

=head2 installer

The installer back-end selected by default is (currently)
L<[ModuleBuildTiny]|Dist::Zilla::Plugin::ModuleBuildTiny>.
You can select other backends (by plugin name, without the C<[]>), with the
C<installer> option, or 'none' if you are supplying your own, as a separate
plugin.

Encouraged choices are:

    installer = ModuleBuildTiny
    installer = MakeMaker
    installer = =inc::Foo (if no configs are needed for this plugin)
    installer = none

=head2 server

=over 4

=item *

C<github>

(default)
metadata and release plugins are tailored to L<github|http://github.com>.

=item *

C<gitmo>

metadata and release plugins are tailored to
L<http://git.moose.perl.org|gitmo@git.moose.perl.org>.

=item *

C<p5sagit>

metadata and release plugins are tailored to
L<http://git.shadowcat.co.uk|p5sagit@git.shadowcat.co.uk>.

=item *

C<none>

no special configuration of metadata (relating to repositories etc) is done --
you'll need to provide this yourself.

=back

=head2 other customizations

This bundle makes use of L<Dist::Zilla::Role::PluginBundle::PluginRemover> and
L<Dist::Zilla::Role::PluginBundle::Config::Slicer> to allow further customization.

=head1 NAMING SCHEME

This distribution follows best practices for author-oriented plugin bundles; for more information,
see L<KENTNL's distribution|Dist::Zilla::PluginBundle::Author::KENTNL/NAMING-SCHEME>.

=head1 SUPPORT

Bugs may be submitted through L<the RT bug tracker|https://rt.cpan.org/Public/Dist/Display.html?Name=Dist-Zilla-PluginBundle-Author-ETHER>
(or L<bug-Dist-Zilla-PluginBundle-Author-ETHER@rt.cpan.org|mailto:bug-Dist-Zilla-PluginBundle-Author-ETHER@rt.cpan.org>).
I am also usually active on irc, as 'ether' at C<irc.perl.org>.

=head1 AUTHOR

Karen Etheridge <ether@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Karen Etheridge.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
