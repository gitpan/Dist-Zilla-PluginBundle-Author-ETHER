use strict;
use warnings;
package Dist::Zilla::PluginBundle::Author::ETHER;
BEGIN {
  $Dist::Zilla::PluginBundle::Author::ETHER::AUTHORITY = 'cpan:ETHER';
}
# git description: v0.062-3-g789aeb6
$Dist::Zilla::PluginBundle::Author::ETHER::VERSION = '0.063';
# ABSTRACT: A plugin bundle for distributions built by ETHER
# KEYWORDS: author bundle distribution tool
# vim: set ts=8 sw=4 tw=78 et :

use Moose;
with
    'Dist::Zilla::Role::PluginBundle::Easy',
    'Dist::Zilla::Role::PluginBundle::PluginRemover' => { -version => '0.102' },
    'Dist::Zilla::Role::PluginBundle::Config::Slicer';

use Dist::Zilla::Util;
use Moose::Util::TypeConstraints;
use List::MoreUtils qw(any first_index);
use Module::Runtime 'use_module';
use namespace::autoclean;

sub mvp_multivalue_args { qw(installer copy_file_from_release) }

# Note: no support yet for depending on a specific version of the plugin --
# but [PromptIfStale] generally makes that unnecessary
has installer => (
    isa => 'ArrayRef[Str]',
    lazy => 1,
    default => sub {
        exists $_[0]->payload->{installer}
            ? $_[0]->payload->{installer}
            : [ 'MakeMaker::Fallback', 'ModuleBuildTiny' ];
    },
    traits => ['Array'],
    handles => { installer => 'elements' },
);

has server => (
    is => 'ro', isa => enum([qw(github gitmo p5sagit catagits none)]),
    lazy => 1,
    default => sub {
        exists $_[0]->payload->{server}
            ? $_[0]->payload->{server}
            : 'github';
    },
);

foreach my $option (qw(airplane surgical_podweaver))
{
    has $option => (
        is => 'ro', isa => 'Bool',
        lazy => 1,
        default => sub {
            exists $_[0]->payload->{$option}
                ? $_[0]->payload->{$option}
                : 0;
        },
    );
}

has copy_file_from_release => (
    isa => 'ArrayRef[Str]',
    lazy => 1,
    default => sub {
        exists $_[0]->payload->{copy_file_from_release}
            ? $_[0]->payload->{copy_file_from_release}
            : [ qw(README.md LICENSE CONTRIBUTING) ];
    },
    traits => ['Array'],
    handles => { copy_files_from_release => 'elements' },
);

has _requested_version => (
    is => 'ro', isa => 'Str',
    lazy => 1,
    default => sub {
        exists $_[0]->payload->{':version'}
            ? $_[0]->payload->{':version'}
            : '0';
    },
);

# configs are applied when plugins match ->isa($key) or ->does($key)
my %extra_args = (
    'Dist::Zilla::Plugin::ModuleBuildTiny' => { ':version' => '0.004' },
    'Dist::Zilla::Plugin::MakeMaker::Fallback' => { ':version' => '0.008' },
    # default_jobs is no-op until Dist::Zilla 5.014
    'Dist::Zilla::Role::TestRunner' => { default_jobs => 9 },
);

# plugins that use the network when they run
my @network_plugins = qw(
    PromptIfStale
    Test::Pod::LinkCheck
    Test::Pod::No404s
    Git::Remote::Check
    CheckPrereqsIndexed
    UploadToCPAN
    Git::Push
);
my %network_plugins;
@network_plugins{ map { Dist::Zilla::Util->expand_config_package_name($_) } @network_plugins } = () x @network_plugins;

around BUILDARGS => sub
{
    my $orig = shift;
    my $self = shift;
    my $args = $self->$orig(@_);

    # remove 'none' from installer list
    return $args if not exists $args->{payload}{installer};
    @{$args->{payload}{installer}} = grep { $_ ne 'none' } @{$args->{payload}{installer}};
    return $args;
};

sub configure
{
    my $self = shift;

    my %extra_develop_requires;

    my @plugins = (
        # VersionProvider
        [ 'Git::NextVersion'    => { version_regexp => '^v([\d._]+)(-TRIAL)?$' } ],

        # BeforeBuild
        [ 'EnsurePrereqsInstalled' ],
        [ 'PromptIfStale' => 'build' => { phase => 'build', module => [ $self->meta->name ] } ],
        [ 'PromptIfStale' => 'release' => { phase => 'release', check_all_plugins => 1, check_all_prereqs => 1 } ],

        # ExecFiles, ShareDir
        [ 'ExecDir'             => { dir => 'script' } ],
        'ShareDir',

        # Finders
        [ 'FileFinder::ByName' => Examples => { dir => 'examples' } ],
        [ 'FileFinder::ByName' => ExtraTestFiles => { dir => 'xt' } ],

        # Gather Files
        [ 'Git::GatherDir'      => { ':version' => '2.016', exclude_filename => [ $self->copy_files_from_release ] } ],
        qw(MetaYAML MetaJSON License Readme Manifest),
        [ 'GenerateFile::ShareDir' => 'generate CONTRIBUTING' => { -dist => 'Dist-Zilla-PluginBundle-Author-ETHER', -filename => 'CONTRIBUTING' } ],

        [ 'Test::Compile'       => { ':version' => '2.039', bail_out_on_fail => 1, xt_mode => 1,
            script_finder => [qw(:ExecFiles @Author::ETHER/Examples)] } ],
        [ 'Test::NoTabs'        => { 'version' => '0.08', finder => [qw(:InstallModules :ExecFiles @Author::ETHER/Examples :TestFiles @Author::ETHER/ExtraTestFiles)] } ],
        'EOLTests',
        'MetaTests',
        [ 'Test::CPAN::Changes' => { ':version' => '0.008' } ],
        'Test::ChangesHasContent',
        [ 'Test::MinimumVersion' => { ':version' => '2.000003', max_target_perl => '5.008001' } ],
        'PodSyntaxTests',
        'PodCoverageTests',
        'Test::PodSpelling',
        #[Test::Pod::LinkCheck]     many outstanding bugs
        'Test::Pod::No404s',
        'Test::Kwalitee',
        'MojibakeTests',
        [ 'Test::ReportPrereqs' => { verify_prereqs => 1 } ],
        'Test::Portability',


        # Munge Files
        'Git::Describe',
        [ PkgVersion            => { ':version' => '5.010', die_on_existing_version => 1, die_on_line_insertion => 1 } ],
        [ 'Authority'           => { authority => 'cpan:ETHER' } ],
        [
            ($self->surgical_podweaver ? 'SurgicalPodWeaver' : 'PodWeaver') => {
                replacer => 'replace_with_comment',
                post_code_replacer => 'replace_with_nothing',
            }
        ],
        [ 'NextRelease'         => { ':version' => '4.300018', time_zone => 'UTC', format => '%-8v  %{yyyy-MM-dd HH:mm:ss\'Z\'}d%{ (TRIAL RELEASE)}T' } ],
        [ 'ReadmeAnyFromPod'    => { type => 'markdown', filename => 'README.md', location => 'build' } ],

        # MetaData
        $self->server eq 'github'
            ? ( 'GithubMeta', do { $extra_develop_requires{'Dist::Zilla::Plugin::GithubMeta'} = 0; () }) : (),
        [ 'AutoMetaResources'   => { 'bugtracker.rt' => 1,
              $self->server eq 'gitmo' ? ( 'repository.gitmo' => 1 )
            : $self->server eq 'p5sagit' ? ( 'repository.p5sagit' => 1 )
            : $self->server eq 'catagits' ? ( 'repository.catagits' => 1 )
            : ()
        } ],
        # (Authority)
        [ 'MetaNoIndex'         => { directory => [ qw(t xt), grep { -d } qw(examples share corpus) ] } ],
        [ 'MetaProvides::Package' => { meta_noindex => 1, ':version' => '1.15000002', finder => ':InstallModules' } ],
        'MetaConfig',
        [ 'Keywords'            => { ':version' => '0.004' } ],
        #[ContributorsFromGit]

        # Register Prereqs
        # (MakeMaker or other installer)
        'AutoPrereqs',
        'Prereqs::AuthorDeps',
        'MinimumPerl',
        [ 'Prereqs' => installer_requirements => {
                '-phase' => 'develop', '-relationship' => 'requires',
                'Dist::Zilla' => Dist::Zilla->VERSION,
                $self->meta->name => $self->_requested_version,

                # this is useless for "dzil authordeps", as by the time this
                # runs, we're already trying to load the installer plugin --
                # but it is useful for people doing "cpanm --with-develop"
                ( map {
                    my $plugin = Dist::Zilla::Util->expand_config_package_name($_);
                    my $args = $self->_extra_plugin_args($plugin);
                    $plugin => 0,    # plugin at version 0, if nothing more specific found
                    map {
                        defined $args->{$_}{':version'} ? ( $_ => $args->{$_}{':version'} ) : ()
                    } keys %$args;
                } $self->installer ),
            } ],
        [ 'Prereqs' => pluginbundle_version => {
                '-phase' => 'develop', '-relationship' => 'recommends',
                $self->meta->name => $self->VERSION,
            } ],

        # Test Runner
        [ 'RunExtraTests' => { ':version' => '0.019', %{ $extra_args{'Dist::Zilla::Role::TestRunner'} } } ],

        # Install Tool
        ( map {
            [ $_ => +{
                map { %$_ }
                values %{ $self->_extra_plugin_args(Dist::Zilla::Util->expand_config_package_name($_)) }
              }
            ]
         } $self->installer ),
        'InstallGuide',

        # After Build
        'CheckSelfDependency',
        [ 'Run::AfterBuild' => { run => q{if [[ `dirname %d` != .build ]]; then test -e .ackrc && grep -q -- '--ignore-dir=%d' .ackrc || echo '--ignore-dir=%d' >> .ackrc; fi; if [[ %d =~ '^%n-\d' ]]; then ln -sFn %d .latest; fi} } ],

        # Before Release
        [ 'CheckStrictVersion' => { decimal_only => 1 } ],
        [ 'Git::Check'          => 'initial check' => { allow_dirty => [''] } ],
        'Git::CheckFor::MergeConflicts',
        [ 'Git::CheckFor::CorrectBranch' => { ':version' => '0.004', release_branch => 'master' } ],
        [ 'Git::Remote::Check'  => { branch => 'master', remote_branch => 'master' } ],
        'CheckPrereqsIndexed',
        'TestRelease',
        [ 'Git::Check'          => 'after tests' => { allow_dirty => [''] } ],
        # (ConfirmRelease)

        # Releaser
        'UploadToCPAN',

        # After Release
        [ 'CopyFilesFromRelease' => { filename => [ $self->copy_files_from_release ] } ],
        [ 'Git::Commit'         => { ':version' => '2.020', add_files_in => ['.'], allow_dirty => [ 'Changes', $self->copy_files_from_release ], commit_msg => '%N-%v%t%n%n%c' } ],
        [ 'Git::Tag'            => { tag_format => 'v%v%t', tag_message => 'v%v%t' } ],
        $self->server eq 'github' ? (
            [ 'GitHub::Update' => { metacpan => 1 } ],
            do { $extra_develop_requires{'Dist::Zilla::Plugin::GitHub::Update'} = 0; () },
        ) : (),
        'Git::Push',
        [ 'InstallRelease'      => { install_command => 'cpanm .' } ],
    );

    if ($self->airplane)
    {
        warn "building in airplane mode - plugins requiring the network are skipped, and releases are not permitted\n";
        @plugins = grep {
            my $plugin = Dist::Zilla::Util->expand_config_package_name(
                !ref($_) ? $_ : ref eq 'ARRAY' ? $_->[0] : die 'wtf'
            );
            not grep { $_ eq $plugin }
            map { Dist::Zilla::Util->expand_config_package_name($_) }
            @network_plugins;
        } @plugins;

        # allow our uncommitted dist.ini edit which sets 'airplane = 1'
        push @{ $plugins[ first_index { ref eq 'ARRAY' && $_->[0] eq 'Git::Check' } @plugins ][-1]{allow_dirty} }, 'dist.ini';

        $extra_develop_requires{'Dist::Zilla::Plugin::BlockRelease'} = 0;

        # halt release after pre-release checks, but before ConfirmRelease
        push @plugins, 'BlockRelease';
    }

    push @plugins, (
        [ 'Prereqs' => via_options => {
            '-phase' => 'develop', '-relationship' => 'requires',
            %extra_develop_requires
          } ]
    ) if keys %extra_develop_requires;

    push @plugins, (
        # listed late, to allow all other plugins which do BeforeRelease checks to run first.
        'ConfirmRelease',
    );

    push @plugins, (
        # listed last, to be sure we run at the very end of each phase
        [ 'VerifyPhases' => 'PHASE VERIFICATION' ],
    ) if ($ENV{USER} // '') eq 'ether';

    $self->add_plugins(@plugins);

    # check for a bin/ that should probably be renamed to script/
    warn 'bin/ detected - should this be moved to script/, so its contents can be installed into $PATH?'
        if -d 'bin' and any { $_ eq 'ModuleBuildTiny' } $self->installer;
}

# returns a subhash of %extra_args where keys match isa or does checks
sub _extra_plugin_args
{
    my ($self, $plugin) = @_;
    use_module($plugin);
    my @keys = grep { $plugin->isa($_) or $plugin->does($_) } keys %extra_args;

    my %slice;
    @slice{@keys} = @extra_args{@keys};
    \%slice;
}

__PACKAGE__->meta->make_immutable;

__END__

=pod

=encoding UTF-8

=head1 NAME

Dist::Zilla::PluginBundle::Author::ETHER - A plugin bundle for distributions built by ETHER

=head1 VERSION

version 0.063

=head1 SYNOPSIS

In your F<dist.ini>:

    [@Author::ETHER]

=head1 DESCRIPTION

This is a L<Dist::Zilla> plugin bundle. It is approximately equivalent to the
following F<dist.ini> (following the preamble):

    ;;; VersionProvider
    [Git::NextVersion]
    version_regexp = ^v([\d._]+)(-TRIAL)?$

    ;;; BeforeBuild
    [EnsurePrereqsInstalled]
    [PromptIfStale / build]
    phase = build
    module = Dist::Zilla::Plugin::Author::ETHER
    [PromptIfStale / release]
    phase = release
    check_all_plugins = 1
    check_all_prereqs = 1


    ;;; ExecFiles, ShareDir
    [ExecDir]
    dir = script

    [ShareDir]


    ;;; Finders
    [FileFinder::ByName / Examples]
    dir = examples
    [FileFinder::ByName / ExtraTestFiles]
    dir = xt

    ;;; Gather Files
    [Git::GatherDir]
    :version = 2.016
    exclude_filename = README.md
    exclude_filename = LICENSE
    exclude_filename = CONTRIBUTING

    [MetaYAML]
    [MetaJSON]
    [License]
    [Readme]
    [Manifest]
    [GenerateFile::ShareDir]
    -dist = Dist-Zilla-PluginBundle-Author-ETHER
    -filename = CONTRIBUTING

    [Test::Compile]
    :version = 2.039
    bail_out_on_fail = 1
    xt_mode = 1
    script_finder = :ExecFiles
    script_finder = Examples

    [Test::NoTabs]
    :version = 0.08
    finder = :InstallModules
    finder = :ExecFiles
    finder = Examples
    finder = :TestFiles
    finder = ExtraTestFiles

    [EOLTests]
    [MetaTests]
    [Test::CPAN::Changes]
    :version = 0.008
    [Test::ChangesHasContent]
    [Test::MinimumVersion]
    :version = 2.000003
    max_target_perl = 5.008001
    [PodSyntaxTests]
    [PodCoverageTests]
    [Test::PodSpelling]
    ;[Test::Pod::LinkCheck]     many outstanding bugs
    [Test::Pod::No404s]
    [Test::Kwalitee]
    [MojibakeTests]
    [Test::ReportPrereqs]
    verify_prereqs = 1
    [Test::Portability]


    ;;; Munge Files
    [Git::Describe]
    [PkgVersion]
    :version = 5.010
    die_on_existing_version = 1
    die_on_line_insertion = 1
    [Authority]
    authority = cpan:ETHER

    [PodWeaver] (or [SurgicalPodWeaver])
    :version = 4.005
    replacer = replace_with_comment
    post_code_replacer = replace_with_nothing

    [NextRelease]
    :version = 4.300018
    time_zone = UTC
    format = %-8v  %{uyyy-MM-dd HH:mm:ss'Z'}d%{ (TRIAL RELEASE)}T
    [ReadmeAnyFromPod]
    type = markdown
    filename = README.md
    location = build


    ;;; MetaData
    [GithubMeta]    ; (if server = 'github' or omitted)
    [AutoMetaResources]
    bugtracker.rt = 1
    ; (plus repository.* = 1 if server = 'gitmo' or 'p5sagit')

    ; (Authority)

    [MetaNoIndex]
    directory = t
    directory = xt
    directory = examples

    [MetaProvides::Package]
    meta_noindex = 1
    :version = 1.15000002
    finder = :InstallModules

    [MetaConfig]
    [Keywords]
    :version = 0.004

    ;;; Register Prereqs
    [AutoPrereqs]
    [Prereqs::AuthorDeps]
    [MinimumPerl]

    [Prereqs / installer_requirements]
    -phase = develop
    -relationship = requires
    Dist::Zilla = <version used to built the pluginbundle>
    Dist::Zilla::PluginBundle::Author::ETHER = <version specified in dist.ini>

    [Prereqs / pluginbundle_version]
    -phase = develop
    -relationship = recommends
    Dist::Zilla::PluginBundle::Author::ETHER = <current installed version>

    ;;; Test Runner
    [RunExtraTests]
    :version = 0.019
    default_jobs = 9
    # <specified installer(s)>


    ;;; Install Tool
    <specified installer(s)>
    [InstallGuide]


    ;;; After Build
    [CheckSelfDependency]

    [Run::AfterBuild]
    run = if [[ `dirname %d` != .build ]]; then test -e .ackrc && grep -q -- '--ignore-dir=%d' .ackrc || echo '--ignore-dir=%d' >> .ackrc; fi; if [[ %d =~ '^%n-\d' ]]; then ln -sFn %d .latest; fi


    ;;; Before Release
    [Git::Check / initial check]
    allow_dirty =

    [Git::CheckFor::MergeConflicts]

    [Git::CheckFor::CorrectBranch]
    :version = 0.004
    release_branch = master

    [Git::Remote::Check]
    branch = master
    remote_branch = master

    [CheckStrictVersion]
    decimal_only = 1

    [CheckPrereqsIndexed]
    [TestRelease]
    [Git::Check / after tests]
    allow_dirty =
    ;(ConfirmRelease)


    ;;; Releaser
    [UploadToCPAN]


    ;;; AfterRelease
    [CopyFilesFromRelease]
    filename = README.md
    filename = LICENSE
    filename = CONTRIBUTING

    [Git::Commit]
    :version = 2.020
    add_files_in = .
    allow_dirty = Changes
    allow_dirty = README.md
    allow_dirty = LICENSE
    allow_dirty = CONTRIBUTING
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

    ; listed last, to be sure we run at the very end of each phase
    [VerifyPhases / PHASE VERIFICATION]

=for Pod::Coverage configure mvp_multivalue_args

=for stopwords metacpan

The distribution's code is assumed to be hosted at L<github|http://github.com>;
L<RT|http://rt.cpan.org> is used as the issue tracker.
The home page in the metadata points to L<github|http://github.com>,
while the home page on L<github|http://github.com> is updated on release to
point to L<metacpan|http://metacpan.org>.
The version and other metadata is derived directly from the local git repository.

=head1 OPTIONS / OVERRIDES

=head2 version

Use C<< V=<version> >> in the shell to override the version of the distribution being built;
otherwise the version is
incremented from the last git tag.

=head2 pod coverage

Subs can be considered "covered" for pod coverage tests by adding a directive to pod,
as described in L<Pod::Coverage::TrustPod>:

    =for Pod::Coverage foo bar baz

=head2 spelling stopwords

=for stopwords Stopwords

Stopwords for spelling tests can be added by adding a directive to pod (as
many as you'd like), as described in L<Pod::Spell/ADDING STOPWORDS>:

    =for stopwords foo bar baz

=head2 installer

=for stopwords ModuleBuildTiny

The installer back-end(s) to use (can be specified more than once); defaults
to L<C<ModuleBuildTiny>|Dist::Zilla::Plugin::ModuleBuildTiny>
and L<C<MakeMaker::Fallback>|Dist::Zilla::Plugin::MakeMaker::Fallback>
(which generates a F<Build.PL> for normal use, and
F<Makefile.PL> as a fallback, containing an upgrade warning).

You can select other backends (by plugin name, without the C<[]>), with the
C<installer> option, or 'none' if you are supplying your own, as a separate
plugin.

Encouraged choices are:

    installer = ModuleBuildTiny
    installer = MakeMaker
    installer = =inc::Foo (if no configs are needed for this plugin)
    installer = none (if you are including your own later on, with configs)

=head2 server

If provided, must be one of:

=over 4

=item *

C<github>

(default)
metadata and release plugins are tailored to L<github|http://github.com>.

=item *

C<gitmo>

metadata and release plugins are tailored to
L<gitmo@git.moose.perl.org|http://git.moose.perl.org>.

=item *

C<p5sagit>

metadata and release plugins are tailored to
L<p5sagit@git.shadowcat.co.uk|http://git.shadowcat.co.uk>.

=item *

C<catagits>

metadata and release plugins are tailored to
L<catagits@git.shadowcat.co.uk|http://git.shadowcat.co.uk>.

=item *

C<none>

no special configuration of metadata (relating to repositories etc) is done --
you'll need to provide this yourself.

=back

=head2 airplane

A boolean option, that when set, removes the use of all plugins that use the
network (generally for comparing metadata against PAUSE, and querying the
remote git server), as well as blocking the use of the C<release> command.
Defaults to false.

=head2 copy_file_from_release

A file, to be present in the build, which is copied back to the source
repository at release time and committed to git. Can be repeated more than
once. Defaults to: F<README.md>, F<LICENSE>, F<CONTRIBUTING>.

=head2 surgical_podweaver

=for stopwords PodWeaver SurgicalPodWeaver

A boolean option, that when set, uses
L<[SurgicalPodWeaver]|Dist::Zilla::Plugin::SurgicalPodWeaver> instead of
L<[PodWeaver]|Dist::Zilla::Plugin::SurgicalPodWeaver>, but with all the same
options. Defaults to false.

=for stopwords customizations

=head2 other customizations

This bundle makes use of L<Dist::Zilla::Role::PluginBundle::PluginRemover> and
L<Dist::Zilla::Role::PluginBundle::Config::Slicer> to allow further customization.
Plugins are not loaded until they are actually needed, so it is possible to
C<--force>-install this plugin bundle and C<-remove> some plugins that do not
install or are otherwise problematic.

=head1 NAMING SCHEME

=for stopwords KENTNL

This distribution follows best practices for author-oriented plugin bundles; for more information,
see L<KENTNL's distribution|Dist::Zilla::PluginBundle::Author::KENTNL/NAMING-SCHEME>.

=head1 SUPPORT

=for stopwords irc

Bugs may be submitted through L<the RT bug tracker|https://rt.cpan.org/Public/Dist/Display.html?Name=Dist-Zilla-PluginBundle-Author-ETHER>
(or L<bug-Dist-Zilla-PluginBundle-Author-ETHER@rt.cpan.org|mailto:bug-Dist-Zilla-PluginBundle-Author-ETHER@rt.cpan.org>).
I am also usually active on irc, as 'ether' at C<irc.perl.org>.

=head1 AUTHOR

Karen Etheridge <ether@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Karen Etheridge.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=head1 CONTRIBUTORS

=over 4

=item *

Randy Stauner <rwstauner@cpan.org>

=item *

Сергей Романов <sromanov@cpan.org>

=back

=cut
