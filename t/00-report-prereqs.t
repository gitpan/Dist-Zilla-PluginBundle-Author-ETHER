#!perl

use strict;
use warnings;

# This test was generated by Dist::Zilla::Plugin::Test::ReportPrereqs 0.011

use Test::More tests => 1;

use ExtUtils::MakeMaker;
use File::Spec::Functions;
use List::Util qw/max/;

my @modules = qw(
  CPAN::Changes
  CPAN::Meta
  CPAN::Meta::Requirements
  Carp
  Config::Identity::GitHub
  Dist::Zilla
  Dist::Zilla::Plugin::Authority
  Dist::Zilla::Plugin::AutoMetaResources
  Dist::Zilla::Plugin::AutoPrereqs
  Dist::Zilla::Plugin::AutoVersion
  Dist::Zilla::Plugin::CheckPrereqsIndexed
  Dist::Zilla::Plugin::CheckSelfDependency
  Dist::Zilla::Plugin::ConfirmRelease
  Dist::Zilla::Plugin::CopyFilesFromRelease
  Dist::Zilla::Plugin::EOLTests
  Dist::Zilla::Plugin::ExecDir
  Dist::Zilla::Plugin::FileFinder::ByName
  Dist::Zilla::Plugin::GatherDir::Template
  Dist::Zilla::Plugin::GenerateFile::ShareDir
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
  Dist::Zilla::Plugin::Prereqs
  Dist::Zilla::Plugin::Prereqs::AuthorDeps
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
  Dist::Zilla::Plugin::Test::Compile
  Dist::Zilla::Plugin::Test::Kwalitee
  Dist::Zilla::Plugin::Test::MinimumVersion
  Dist::Zilla::Plugin::Test::NoTabs
  Dist::Zilla::Plugin::Test::Pod::No404s
  Dist::Zilla::Plugin::Test::PodSpelling
  Dist::Zilla::Plugin::Test::Portability
  Dist::Zilla::Plugin::Test::ReportPrereqs
  Dist::Zilla::Plugin::Test::UnusedVars
  Dist::Zilla::Plugin::Test::Version
  Dist::Zilla::Plugin::TestRelease
  Dist::Zilla::Plugin::UploadToCPAN
  Dist::Zilla::Role::BeforeRelease
  Dist::Zilla::Role::MintingProfile
  Dist::Zilla::Role::PluginBundle::Config::Slicer
  Dist::Zilla::Role::PluginBundle::Easy
  Dist::Zilla::Role::PluginBundle::PluginRemover
  Dist::Zilla::Util
  Exporter
  ExtUtils::MakeMaker
  File::Find
  File::ShareDir
  File::ShareDir::Install
  File::Spec
  File::Spec::Functions
  JSON
  List::MoreUtils
  List::Util
  Module::Build::Tiny
  Module::Runtime
  Moose
  Moose::Util
  Moose::Util::TypeConstraints
  Path::Class
  Path::Tiny
  Pod::Coverage::TrustPod
  Pod::Elemental::PerlMunger
  Pod::Elemental::Transformer::List
  Pod::Markdown
  Pod::Weaver::Plugin::StopWords
  Pod::Weaver::Plugin::Transformer
  Pod::Weaver::PluginBundle::Default
  Pod::Wordlist
  Scalar::Util
  Test::CPAN::Changes
  Test::CPAN::Meta
  Test::DZil
  Test::Deep
  Test::Deep::JSON
  Test::EOL
  Test::Fatal
  Test::File::ShareDir
  Test::MinimumVersion
  Test::Mojibake
  Test::More
  Test::NoTabs
  Test::Pod
  Test::Pod::Coverage
  Test::Pod::No404s
  Test::Portability::Files
  Test::Requires
  Test::Spelling
  Test::Vars
  Test::Warnings
  Text::Tabs
  if
  lib
  namespace::autoclean
  parent
  perl
  strict
  warnings
);

my %exclude = map {; $_ => 1 } qw(

);

my ($source) = grep { -f $_ } qw/MYMETA.json MYMETA.yml META.json/;
$source = "META.yml" unless defined $source;

# replace modules with dynamic results from MYMETA.json if we can
# (hide CPAN::Meta from prereq scanner)
my $cpan_meta = "CPAN::Meta";
my $cpan_meta_req = "CPAN::Meta::Requirements";
my $all_requires;
if ( -f $source && eval "require $cpan_meta" ) { ## no critic
  if ( my $meta = eval { CPAN::Meta->load_file($source) } ) {

    # Get ALL modules mentioned in META (any phase/type)
    my $prereqs = $meta->prereqs;
    delete $prereqs->{develop} if not $ENV{AUTHOR_TESTING};
    my %uniq = map {$_ => 1} map { keys %$_ } map { values %$_ } values %$prereqs;
    $uniq{$_} = 1 for @modules; # don't lose any static ones
    @modules = sort grep { ! $exclude{$_} } keys %uniq;

    # If verifying, merge 'requires' only for major phases
    if ( 1 ) {
      $prereqs = $meta->effective_prereqs; # get the object, not the hash
      if (eval "require $cpan_meta_req; 1") { ## no critic
        $all_requires = $cpan_meta_req->new;
        for my $phase ( qw/configure build test runtime develop/ ) {
          $all_requires->add_requirements(
            $prereqs->requirements_for($phase, 'requires')
          );
        }
      }
    }
  }
}

my @reports = [qw/Version Module/];
my @dep_errors;
my $req_hash = defined($all_requires) ? $all_requires->as_string_hash : {};

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

    if ( 1 && $all_requires ) {
      my $req = $req_hash->{$mod};
      if ( defined $req && length $req ) {
        if ( ! defined eval { version->parse($ver) } ) {
          push @dep_errors, "$mod version '$ver' cannot be parsed (version '$req' required)";
        }
        elsif ( ! $all_requires->accepts_module( $mod => $ver ) ) {
          push @dep_errors, "$mod version '$ver' is not in required range '$req'";
        }
      }
    }

  }
  else {
    push @reports, ["missing", $mod];

    if ( 1 && $all_requires ) {
      my $req = $req_hash->{$mod};
      if ( defined $req && length $req ) {
        push @dep_errors, "$mod is not installed (version '$req' required)";
      }
    }
  }
}

if ( @reports ) {
  my $vl = max map { length $_->[0] } @reports;
  my $ml = max map { length $_->[1] } @reports;
  splice @reports, 1, 0, ["-" x $vl, "-" x $ml];
  diag "\nVersions for all modules listed in $source (including optional ones):\n",
    map {sprintf("  %*s %*s\n",$vl,$_->[0],-$ml,$_->[1])} @reports;
}

if ( @dep_errors ) {
  diag join("\n",
    "\n*** WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING ***\n",
    "The following REQUIRED prerequisites were not satisfied:\n",
    @dep_errors,
    "\n"
  );
}

pass;

# vim: ts=2 sts=2 sw=2 et:
