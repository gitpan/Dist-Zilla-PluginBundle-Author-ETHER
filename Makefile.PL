
use strict;
use warnings;

use 5.006;

use ExtUtils::MakeMaker 6.30;

use File::ShareDir::Install;
install_share module => "Dist::Zilla::MintingProfile::Author::ETHER", "profiles";


my %WriteMakefileArgs = (
  "ABSTRACT" => "A plugin bundle for distributions built by ETHER",
  "AUTHOR" => "Karen Etheridge <ether\@cpan.org>",
  "BUILD_REQUIRES" => {},
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.30",
    "File::ShareDir::Install" => "0.03"
  },
  "DISTNAME" => "Dist-Zilla-PluginBundle-Author-ETHER",
  "EXE_FILES" => [],
  "LICENSE" => "perl",
  "NAME" => "Dist::Zilla::PluginBundle::Author::ETHER",
  "PREREQ_PM" => {
    "Dist::Zilla::Plugin::Authority" => 0,
    "Dist::Zilla::Plugin::AutoMetaResources" => 0,
    "Dist::Zilla::Plugin::AutoPrereqs" => 0,
    "Dist::Zilla::Plugin::CheckPrereqsIndexed" => 0,
    "Dist::Zilla::Plugin::ConfirmRelease" => 0,
    "Dist::Zilla::Plugin::CopyFilesFromBuild" => 0,
    "Dist::Zilla::Plugin::EOLTests" => 0,
    "Dist::Zilla::Plugin::ExecDir" => 0,
    "Dist::Zilla::Plugin::Git::Check" => 0,
    "Dist::Zilla::Plugin::Git::CheckFor::CorrectBranch" => 0,
    "Dist::Zilla::Plugin::Git::CheckFor::MergeConflicts" => 0,
    "Dist::Zilla::Plugin::Git::Commit" => 0,
    "Dist::Zilla::Plugin::Git::Describe" => 0,
    "Dist::Zilla::Plugin::Git::GatherDir" => 0,
    "Dist::Zilla::Plugin::Git::NextVersion" => 0,
    "Dist::Zilla::Plugin::Git::Push" => 0,
    "Dist::Zilla::Plugin::Git::Remote::Check" => 0,
    "Dist::Zilla::Plugin::Git::Tag" => 0,
    "Dist::Zilla::Plugin::GithubMeta" => 0,
    "Dist::Zilla::Plugin::InstallGuide" => 0,
    "Dist::Zilla::Plugin::InstallRelease" => 0,
    "Dist::Zilla::Plugin::License" => 0,
    "Dist::Zilla::Plugin::MakeMaker" => 0,
    "Dist::Zilla::Plugin::Manifest" => 0,
    "Dist::Zilla::Plugin::ManifestSkip" => 0,
    "Dist::Zilla::Plugin::MetaConfig" => 0,
    "Dist::Zilla::Plugin::MetaJSON" => 0,
    "Dist::Zilla::Plugin::MetaNoIndex" => 0,
    "Dist::Zilla::Plugin::MetaProvides::Package" => 0,
    "Dist::Zilla::Plugin::MetaTests" => 0,
    "Dist::Zilla::Plugin::MetaYAML" => 0,
    "Dist::Zilla::Plugin::MinimumPerl" => 0,
    "Dist::Zilla::Plugin::NextRelease" => "4.300018",
    "Dist::Zilla::Plugin::NoTabsTests" => 0,
    "Dist::Zilla::Plugin::PkgVersion" => 0,
    "Dist::Zilla::Plugin::PodCoverageTests" => 0,
    "Dist::Zilla::Plugin::PodSyntaxTests" => 0,
    "Dist::Zilla::Plugin::PodWeaver" => 0,
    "Dist::Zilla::Plugin::PruneCruft" => 0,
    "Dist::Zilla::Plugin::Readme" => 0,
    "Dist::Zilla::Plugin::ReadmeAnyFromPod" => 0,
    "Dist::Zilla::Plugin::RunExtraTests" => 0,
    "Dist::Zilla::Plugin::ShareDir" => 0,
    "Dist::Zilla::Plugin::Test::CPAN::Changes" => "0.008",
    "Dist::Zilla::Plugin::Test::ChangesHasContent" => 0,
    "Dist::Zilla::Plugin::Test::CheckDeps" => "0.005",
    "Dist::Zilla::Plugin::Test::Compile" => "2.001",
    "Dist::Zilla::Plugin::Test::MinimumVersion" => "2.000003",
    "Dist::Zilla::Plugin::Test::Pod::No404s" => 0,
    "Dist::Zilla::Plugin::Test::PodSpelling" => 0,
    "Dist::Zilla::Plugin::Test::UnusedVars" => 0,
    "Dist::Zilla::Plugin::Test::Version" => 0,
    "Dist::Zilla::Plugin::TestRelease" => 0,
    "Dist::Zilla::Plugin::UploadToCPAN" => 0,
    "Dist::Zilla::Role::MintingProfile::ShareDir" => 0,
    "Dist::Zilla::Role::PluginBundle::Config::Slicer" => 0,
    "Dist::Zilla::Role::PluginBundle::Easy" => 0,
    "Dist::Zilla::Role::PluginBundle::PluginRemover" => "0.102",
    "Moose" => 0,
    "Pod::Elemental::Transformer::List" => 0,
    "Pod::Weaver::Plugin::Encoding" => 0,
    "Pod::Weaver::Plugin::StopWords" => 0,
    "Pod::Weaver::Plugin::Transformer" => 0,
    "Pod::Weaver::PluginBundle::Default" => 0,
    "Text::Tabs" => "2013.0426",
    "strict" => 0,
    "warnings" => 0
  },
  "TEST_REQUIRES" => {
    "File::Find" => 0,
    "File::Temp" => 0,
    "Test::CheckDeps" => "0.002",
    "Test::More" => "0.88"
  },
  "VERSION" => "0.004",
  "test" => {
    "TESTS" => "t/*.t"
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.63_03) } ) {
  my $tr = delete $WriteMakefileArgs{TEST_REQUIRES};
  my $br = $WriteMakefileArgs{BUILD_REQUIRES};
  for my $mod ( keys %$tr ) {
    if ( exists $br->{$mod} ) {
      $br->{$mod} = $tr->{$mod} if $tr->{$mod} > $br->{$mod};
    }
    else {
      $br->{$mod} = $tr->{$mod};
    }
  }
}

unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);

{
package
MY;
use File::ShareDir::Install qw(postamble);
}


