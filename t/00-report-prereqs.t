#!perl

use strict;
use warnings;

# This test was generated by Dist::Zilla::Plugin::Test::ReportPrereqs 0.013

use Test::More tests => 1;

use ExtUtils::MakeMaker;
use File::Spec::Functions;
use List::Util qw/max/;
use version;

# hide optional CPAN::Meta modules from prereq scanner
# and check if they are available
my $cpan_meta = "CPAN::Meta";
my $cpan_meta_req = "CPAN::Meta::Requirements";
my $HAS_CPAN_META = eval "require $cpan_meta"; ## no critic
my $HAS_CPAN_META_REQ = eval "require $cpan_meta_req; $cpan_meta_req->VERSION('2.120900')";

# Verify requirements?
my $DO_VERIFY_PREREQS = 1;

sub _merge_requires {
    my ($collector, $prereqs) = @_;
    for my $phase ( qw/configure build test runtime develop/ ) {
        next unless exists $prereqs->{$phase};
        if ( my $req = $prereqs->{$phase}{'requires'} ) {
            my $cmr = CPAN::Meta::Requirements->from_string_hash( $req );
            $collector->add_requirements( $cmr );
        }
    }
}

my %include = map {; $_ => 1 } qw(

);

my %exclude = map {; $_ => 1 } qw(

);

# Add static prereqs to the included modules list
my $static_prereqs = do { my $x = {
       'configure' => {
                        'requires' => {
                                        'ExtUtils::MakeMaker' => '6.30',
                                        'File::ShareDir::Install' => '0.03',
                                        'Module::Build::Tiny' => '0.035'
                                      }
                      },
       'develop' => {
                      'recommends' => {
                                        'Dist::Zilla::PluginBundle::Author::ETHER' => '0.056'
                                      },
                      'requires' => {
                                      'Dist::Zilla' => '5.015',
                                      'Dist::Zilla::Plugin::ContributorsFromGit' => '0',
                                      'Dist::Zilla::Plugin::GitHub::Update' => '0',
                                      'Dist::Zilla::Plugin::GithubMeta' => '0',
                                      'Dist::Zilla::Plugin::MakeMaker::Fallback' => '0.008',
                                      'Dist::Zilla::Plugin::MetaResources' => '0',
                                      'Dist::Zilla::Plugin::ModuleBuildTiny' => '0.004',
                                      'Dist::Zilla::Plugin::MungeFile::WithDataSection' => '0',
                                      'Dist::Zilla::Plugin::Prereqs' => '0',
                                      'Dist::Zilla::Plugin::Test::CheckBreaks' => '0',
                                      'Dist::Zilla::Plugin::Test::CleanNamespaces' => '0',
                                      'Dist::Zilla::PluginBundle::Author::ETHER' => '0.019',
                                      'File::Spec' => '0',
                                      'IO::Handle' => '0',
                                      'IPC::Open3' => '0',
                                      'Pod::Elemental::Transformer::List' => '0',
                                      'Pod::Weaver::Plugin::StopWords' => '0',
                                      'Pod::Weaver::Plugin::Transformer' => '0',
                                      'Pod::Weaver::PluginBundle::Default' => '0',
                                      'Pod::Weaver::Section::Contributors' => '0',
                                      'Pod::Wordlist' => '1.09',
                                      'Test::CPAN::Changes' => '0.19',
                                      'Test::CPAN::Meta' => '0',
                                      'Test::CleanNamespaces' => '>= 0.04, != 0.06',
                                      'Test::EOL' => '0',
                                      'Test::Kwalitee' => '1.12',
                                      'Test::MinimumVersion' => '0',
                                      'Test::Mojibake' => '0',
                                      'Test::More' => '0.94',
                                      'Test::NoTabs' => '0',
                                      'Test::Pod' => '1.41',
                                      'Test::Pod::No404s' => '0',
                                      'Test::Spelling' => '0.19',
                                      'Test::Vars' => '0.004',
                                      'Test::Warnings' => '0'
                                    }
                    },
       'runtime' => {
                      'recommends' => {
                                        'Config::Identity::GitHub' => '0',
                                        'Dist::Zilla::Plugin::GitHub::Update' => '0',
                                        'Dist::Zilla::Plugin::GithubMeta' => '0',
                                        'Dist::Zilla::Plugin::MakeMaker' => '0',
                                        'Dist::Zilla::Plugin::MakeMaker::Fallback' => '0.008',
                                        'Dist::Zilla::Plugin::ModuleBuildTiny' => '0.004',
                                        'Pod::Coverage::TrustPod' => '0',
                                        'Pod::Wordlist' => '1.09',
                                        'Test::CPAN::Changes' => '0',
                                        'Test::CPAN::Meta' => '0',
                                        'Test::EOL' => '0',
                                        'Test::MinimumVersion' => '0',
                                        'Test::Mojibake' => '0',
                                        'Test::NoTabs' => '0',
                                        'Test::Pod' => '1.41',
                                        'Test::Pod::Coverage' => '1.08',
                                        'Test::Pod::No404s' => '0',
                                        'Test::Spelling' => '0.19',
                                        'Test::Vars' => '0.004'
                                      },
                      'requires' => {
                                      'CPAN::Changes' => '0.23',
                                      'Carp' => '0',
                                      'Dist::Zilla' => '4.300038',
                                      'Dist::Zilla::Plugin::Authority' => '0',
                                      'Dist::Zilla::Plugin::AutoMetaResources' => '0',
                                      'Dist::Zilla::Plugin::AutoPrereqs' => '0',
                                      'Dist::Zilla::Plugin::AutoVersion' => '0',
                                      'Dist::Zilla::Plugin::CheckPrereqsIndexed' => '0',
                                      'Dist::Zilla::Plugin::CheckSelfDependency' => '0',
                                      'Dist::Zilla::Plugin::CheckStrictVersion' => '0',
                                      'Dist::Zilla::Plugin::ConfirmRelease' => '0',
                                      'Dist::Zilla::Plugin::CopyFilesFromRelease' => '0',
                                      'Dist::Zilla::Plugin::EOLTests' => '0',
                                      'Dist::Zilla::Plugin::ExecDir' => '0',
                                      'Dist::Zilla::Plugin::FileFinder::ByName' => '0',
                                      'Dist::Zilla::Plugin::GatherDir::Template' => '0',
                                      'Dist::Zilla::Plugin::GenerateFile::ShareDir' => '0',
                                      'Dist::Zilla::Plugin::Git::Check' => '0',
                                      'Dist::Zilla::Plugin::Git::CheckFor::CorrectBranch' => '0.004',
                                      'Dist::Zilla::Plugin::Git::CheckFor::MergeConflicts' => '0.008',
                                      'Dist::Zilla::Plugin::Git::Commit' => '2.020',
                                      'Dist::Zilla::Plugin::Git::Describe' => '0',
                                      'Dist::Zilla::Plugin::Git::GatherDir' => '2.016',
                                      'Dist::Zilla::Plugin::Git::Init' => '0',
                                      'Dist::Zilla::Plugin::Git::NextVersion' => '0',
                                      'Dist::Zilla::Plugin::Git::Push' => '0',
                                      'Dist::Zilla::Plugin::Git::PushInitial' => '0',
                                      'Dist::Zilla::Plugin::Git::Remote::Check' => '0',
                                      'Dist::Zilla::Plugin::Git::Tag' => '0',
                                      'Dist::Zilla::Plugin::GitHub::Create' => '0.35',
                                      'Dist::Zilla::Plugin::GitHub::Update' => '0',
                                      'Dist::Zilla::Plugin::GithubMeta' => '0',
                                      'Dist::Zilla::Plugin::InstallGuide' => '0',
                                      'Dist::Zilla::Plugin::InstallRelease' => '0',
                                      'Dist::Zilla::Plugin::Keywords' => '0.004',
                                      'Dist::Zilla::Plugin::License' => '0',
                                      'Dist::Zilla::Plugin::MakeMaker' => '0',
                                      'Dist::Zilla::Plugin::MakeMaker::Fallback' => '0.008',
                                      'Dist::Zilla::Plugin::Manifest' => '0',
                                      'Dist::Zilla::Plugin::ManifestSkip' => '0',
                                      'Dist::Zilla::Plugin::MetaConfig' => '0',
                                      'Dist::Zilla::Plugin::MetaJSON' => '0',
                                      'Dist::Zilla::Plugin::MetaNoIndex' => '0',
                                      'Dist::Zilla::Plugin::MetaProvides::Package' => '1.15000002',
                                      'Dist::Zilla::Plugin::MetaTests' => '0',
                                      'Dist::Zilla::Plugin::MetaYAML' => '0',
                                      'Dist::Zilla::Plugin::MinimumPerl' => '0',
                                      'Dist::Zilla::Plugin::ModuleBuildTiny' => '0.004',
                                      'Dist::Zilla::Plugin::MojibakeTests' => '0',
                                      'Dist::Zilla::Plugin::NextRelease' => '4.300018',
                                      'Dist::Zilla::Plugin::PkgVersion' => '5.010',
                                      'Dist::Zilla::Plugin::PodCoverageTests' => '0',
                                      'Dist::Zilla::Plugin::PodSyntaxTests' => '0',
                                      'Dist::Zilla::Plugin::PodWeaver' => '4.005',
                                      'Dist::Zilla::Plugin::Prereqs' => '0',
                                      'Dist::Zilla::Plugin::Prereqs::AuthorDeps' => '0',
                                      'Dist::Zilla::Plugin::PromptIfStale' => '0.004',
                                      'Dist::Zilla::Plugin::PruneCruft' => '0',
                                      'Dist::Zilla::Plugin::Readme' => '0',
                                      'Dist::Zilla::Plugin::ReadmeAnyFromPod' => '0.133290',
                                      'Dist::Zilla::Plugin::Run::AfterBuild' => '0',
                                      'Dist::Zilla::Plugin::Run::AfterMint' => '0',
                                      'Dist::Zilla::Plugin::RunExtraTests' => '0.019',
                                      'Dist::Zilla::Plugin::ShareDir' => '0',
                                      'Dist::Zilla::Plugin::TemplateModule' => '0',
                                      'Dist::Zilla::Plugin::Test::CPAN::Changes' => '0.008',
                                      'Dist::Zilla::Plugin::Test::ChangesHasContent' => '0',
                                      'Dist::Zilla::Plugin::Test::Compile' => '2.036',
                                      'Dist::Zilla::Plugin::Test::Kwalitee' => '2.06',
                                      'Dist::Zilla::Plugin::Test::MinimumVersion' => '2.000003',
                                      'Dist::Zilla::Plugin::Test::NoTabs' => '0',
                                      'Dist::Zilla::Plugin::Test::Pod::No404s' => '0',
                                      'Dist::Zilla::Plugin::Test::PodSpelling' => '2.006001',
                                      'Dist::Zilla::Plugin::Test::Portability' => '0',
                                      'Dist::Zilla::Plugin::Test::ReportPrereqs' => '0',
                                      'Dist::Zilla::Plugin::Test::UnusedVars' => '0',
                                      'Dist::Zilla::Plugin::TestRelease' => '0',
                                      'Dist::Zilla::Plugin::UploadToCPAN' => '0',
                                      'Dist::Zilla::Plugin::VerifyPhases' => '0',
                                      'Dist::Zilla::Role::BeforeRelease' => '0',
                                      'Dist::Zilla::Role::MintingProfile' => '0',
                                      'Dist::Zilla::Role::PluginBundle::Config::Slicer' => '0',
                                      'Dist::Zilla::Role::PluginBundle::Easy' => '0',
                                      'Dist::Zilla::Role::PluginBundle::PluginRemover' => '0.102',
                                      'Dist::Zilla::Util' => '0',
                                      'File::ShareDir' => '0',
                                      'List::MoreUtils' => '0',
                                      'Module::Runtime' => '0',
                                      'Moose' => '0',
                                      'Moose::Util::TypeConstraints' => '0',
                                      'Path::Class' => '0',
                                      'Pod::Elemental::PerlMunger' => '0.200001',
                                      'Pod::Elemental::Transformer::List' => '0',
                                      'Pod::Markdown' => '1.500',
                                      'Pod::Weaver::Plugin::StopWords' => '0',
                                      'Pod::Weaver::Plugin::Transformer' => '0',
                                      'Pod::Weaver::PluginBundle::Default' => '4.000',
                                      'Test::Portability::Files' => '0.06',
                                      'Test::Spelling' => '0.19',
                                      'Test::Vars' => '0.004',
                                      'Text::Tabs' => '2013.0426',
                                      'namespace::autoclean' => '0',
                                      'perl' => '5.013002',
                                      'strict' => '0',
                                      'warnings' => '0'
                                    }
                    },
       'test' => {
                   'recommends' => {
                                     'CPAN::Meta' => '0',
                                     'CPAN::Meta::Requirements' => '2.120900'
                                   },
                   'requires' => {
                                   'Exporter' => '0',
                                   'ExtUtils::MakeMaker' => '0',
                                   'File::Find' => '0',
                                   'File::Spec' => '0',
                                   'File::Spec::Functions' => '0',
                                   'JSON' => '0',
                                   'List::Util' => '0',
                                   'Moose::Util' => '0',
                                   'PadWalker' => '0',
                                   'Path::Tiny' => '0',
                                   'Test::DZil' => '0',
                                   'Test::Deep' => '0',
                                   'Test::Deep::JSON' => '0',
                                   'Test::Fatal' => '0',
                                   'Test::File::ShareDir' => '0',
                                   'Test::More' => '0',
                                   'Test::Requires' => '0',
                                   'Test::Warnings' => '0.005',
                                   'if' => '0',
                                   'lib' => '0',
                                   'parent' => '0',
                                   'perl' => '5.013002',
                                   'version' => '0'
                                 }
                 }
     };
  $x;
 };

delete $static_prereqs->{develop} if not $ENV{AUTHOR_TESTING};
$include{$_} = 1 for map { keys %$_ } map { values %$_ } values %$static_prereqs;

# Merge requirements for major phases (if we can)
my $all_requires;
if ( $DO_VERIFY_PREREQS && $HAS_CPAN_META_REQ ) {
    $all_requires = $cpan_meta_req->new;
    _merge_requires($all_requires, $static_prereqs);
}


# Add dynamic prereqs to the included modules list (if we can)
my ($source) = grep { -f } 'MYMETA.json', 'MYMETA.yml';
if ( $source && $HAS_CPAN_META ) {
  if ( my $meta = eval { CPAN::Meta->load_file($source) } ) {
    my $dynamic_prereqs = $meta->prereqs;
    delete $dynamic_prereqs->{develop} if not $ENV{AUTHOR_TESTING};
    $include{$_} = 1 for map { keys %$_ } map { values %$_ } values %$dynamic_prereqs;

    if ( $DO_VERIFY_PREREQS && $HAS_CPAN_META_REQ ) {
        _merge_requires($all_requires, $dynamic_prereqs);
    }
  }
}
else {
  $source = 'static metadata';
}

my @modules = sort grep { ! $exclude{$_} } keys %include;
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

    if ( $DO_VERIFY_PREREQS && $all_requires ) {
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

    if ( $DO_VERIFY_PREREQS && $all_requires ) {
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

# vim: ts=4 sts=4 sw=4 et:
