#!perl

use strict;
use warnings;

use Test::More tests => 1;

use ExtUtils::MakeMaker;
use File::Spec::Functions;
use List::Util qw/max/;

my @modules = qw(
  CPAN::Changes
  Dist::Zilla
  Dist::Zilla::Plugin::Authority
  Dist::Zilla::Plugin::AutoMetaResources
  Dist::Zilla::Plugin::AutoPrereqs
  Dist::Zilla::Plugin::CheckPrereqsIndexed
  Dist::Zilla::Plugin::ConfirmRelease
  Dist::Zilla::Plugin::CopyFilesFromBuild
  Dist::Zilla::Plugin::EOLTests
  Dist::Zilla::Plugin::ExecDir
  Dist::Zilla::Plugin::FileFinder::ByName
  Dist::Zilla::Plugin::GatherDir::Template
  Dist::Zilla::Plugin::GenerateFile
  Dist::Zilla::Plugin::Git::Check
  Dist::Zilla::Plugin::Git::CheckFor::CorrectBranch
  Dist::Zilla::Plugin::Git::CheckFor::MergeConflicts
  Dist::Zilla::Plugin::Git::Commit
  Dist::Zilla::Plugin::Git::Describe
  Dist::Zilla::Plugin::Git::GatherDir
  Dist::Zilla::Plugin::Git::Init
  Dist::Zilla::Plugin::Git::NextVersion
  Dist::Zilla::Plugin::Git::Push
  Dist::Zilla::Plugin::Git::PushInitial
  Dist::Zilla::Plugin::Git::Remote::Check
  Dist::Zilla::Plugin::Git::Tag
  Dist::Zilla::Plugin::GitHub::Create
  Dist::Zilla::Plugin::GitHub::Update
  Dist::Zilla::Plugin::GithubMeta
  Dist::Zilla::Plugin::InstallGuide
  Dist::Zilla::Plugin::InstallRelease
  Dist::Zilla::Plugin::License
  Dist::Zilla::Plugin::MakeMaker
  Dist::Zilla::Plugin::MakeMaker::Fallback
  Dist::Zilla::Plugin::Manifest
  Dist::Zilla::Plugin::ManifestSkip
  Dist::Zilla::Plugin::MetaConfig
  Dist::Zilla::Plugin::MetaJSON
  Dist::Zilla::Plugin::MetaNoIndex
  Dist::Zilla::Plugin::MetaProvides::Package
  Dist::Zilla::Plugin::MetaTests
  Dist::Zilla::Plugin::MetaYAML
  Dist::Zilla::Plugin::MinimumPerl
  Dist::Zilla::Plugin::ModuleBuildTiny
  Dist::Zilla::Plugin::MojibakeTests
  Dist::Zilla::Plugin::NextRelease
  Dist::Zilla::Plugin::PkgVersion
  Dist::Zilla::Plugin::PodCoverageTests
  Dist::Zilla::Plugin::PodSyntaxTests
  Dist::Zilla::Plugin::PodWeaver
  Dist::Zilla::Plugin::PromptIfStale
  Dist::Zilla::Plugin::PruneCruft
  Dist::Zilla::Plugin::Readme
  Dist::Zilla::Plugin::ReadmeAnyFromPod
  Dist::Zilla::Plugin::Run::AfterBuild
  Dist::Zilla::Plugin::Run::AfterMint
  Dist::Zilla::Plugin::RunExtraTests
  Dist::Zilla::Plugin::ShareDir
  Dist::Zilla::Plugin::TemplateModule
  Dist::Zilla::Plugin::Test::CPAN::Changes
  Dist::Zilla::Plugin::Test::ChangesHasContent
  Dist::Zilla::Plugin::Test::CheckDeps
  Dist::Zilla::Plugin::Test::Compile
  Dist::Zilla::Plugin::Test::Kwalitee
  Dist::Zilla::Plugin::Test::MinimumVersion
  Dist::Zilla::Plugin::Test::NoTabs
  Dist::Zilla::Plugin::Test::Pod::No404s
  Dist::Zilla::Plugin::Test::PodSpelling
  Dist::Zilla::Plugin::Test::ReportPrereqs
  Dist::Zilla::Plugin::Test::UnusedVars
  Dist::Zilla::Plugin::Test::Version
  Dist::Zilla::Plugin::TestRelease
  Dist::Zilla::Plugin::UploadToCPAN
  Dist::Zilla::Role::MintingProfile::ShareDir
  Dist::Zilla::Role::PluginBundle::Config::Slicer
  Dist::Zilla::Role::PluginBundle::Easy
  Dist::Zilla::Role::PluginBundle::PluginRemover
  Dist::Zilla::Util
  ExtUtils::MakeMaker
  File::Find
  File::ShareDir::Install
  File::Spec
  File::Spec::Functions
  IO::Handle
  IPC::Open3
  List::MoreUtils
  List::Util
  Module::Runtime
  Moose
  Moose::Util
  Moose::Util::TypeConstraints
  Path::Class
  Path::Tiny
  Pod::Coverage::TrustPod
  Pod::Elemental::Transformer::List
  Pod::Weaver::Plugin::Encoding
  Pod::Weaver::Plugin::StopWords
  Pod::Weaver::Plugin::Transformer
  Pod::Weaver::PluginBundle::Default
  Pod::Wordlist
  Test::CPAN::Changes
  Test::CPAN::Meta
  Test::CheckDeps
  Test::DZil
  Test::Deep
  Test::Deep::JSON
  Test::EOL
  Test::MinimumVersion
  Test::Mojibake
  Test::More
  Test::NoTabs
  Test::Pod
  Test::Pod::Coverage
  Test::Pod::No404s
  Test::Requires
  Test::Spelling
  Test::Vars
  Test::Warnings
  Text::Tabs
  if
  namespace::autoclean
  perl
  strict
  warnings
);

# replace modules with dynamic results from MYMETA.json if we can
# (hide CPAN::Meta from prereq scanner)
my $cpan_meta = "CPAN::Meta";
if ( -f "MYMETA.json" && eval "require $cpan_meta" ) { ## no critic
  if ( my $meta = eval { CPAN::Meta->load_file("MYMETA.json") } ) {
    my $prereqs = $meta->prereqs;
    delete $prereqs->{develop};
    my %uniq = map {$_ => 1} map { keys %$_ } map { values %$_ } values %$prereqs;
    $uniq{$_} = 1 for @modules; # don't lose any static ones
    @modules = sort keys %uniq;
  }
}

my @reports = [qw/Version Module/];

for my $mod ( @modules ) {
  next if $mod eq 'perl';
  my $file = $mod;
  $file =~ s{::}{/}g;
  $file .= ".pm";
  my ($prefix) = grep { -e catfile($_, $file) } @INC;
  if ( $prefix ) {
    my $ver = MM->parse_version( catfile($prefix, $file) );
    $ver = "undef" unless defined $ver; # Newer MM should do this anyway
    push @reports, [$ver, $mod];
  }
  else {
    push @reports, ["missing", $mod];
  }
}

if ( @reports ) {
  my $vl = max map { length $_->[0] } @reports;
  my $ml = max map { length $_->[1] } @reports;
  splice @reports, 1, 0, ["-" x $vl, "-" x $ml];
  diag "Prerequisite Report:\n", map {sprintf("  %*s %*s\n",$vl,$_->[0],-$ml,$_->[1])} @reports;
}

pass;

# vim: ts=2 sts=2 sw=2 et:
