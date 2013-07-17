use strict;
use warnings;

# This test was generated via Dist::Zilla::Plugin::Test::Compile 2.005

use Test::More 0.94;



use File::Find;
use File::Temp qw{ tempdir };
use Capture::Tiny qw{ capture };

my @modules;
find(
  sub {
    return if $File::Find::name !~ /\.pm\z/;
    my $found = $File::Find::name;
    $found =~ s{^lib/}{};
    $found =~ s{[/\\]}{::}g;
    $found =~ s/\.pm$//;
    # nothing to skip
    push @modules, $found;
  },
  'lib',
);

sub _find_scripts {
    my $dir = shift @_;

    my @found_scripts = ();
    find(
      sub {
        return unless -f;
        my $found = $File::Find::name;
        # nothing to skip
        open my $FH, '<', $_ or do {
          note( "Unable to open $found in ( $! ), skipping" );
          return;
        };
        my $shebang = <$FH>;
        return unless $shebang =~ /^#!.*?\bperl\b\s*$/;
        push @found_scripts, $found;
      },
      $dir,
    );

    return @found_scripts;
}

my @scripts;
do { push @scripts, _find_scripts($_) if -d $_ }
    for qw{ bin script scripts };

{
    # fake home for cpan-testers
    # no fake requested ## local $ENV{HOME} = tempdir( CLEANUP => 1 );

    my @warnings;
    for my $module (sort @modules)
    {
        my ($stdout, $stderr, $exit) = capture {
            system($^X, '-Ilib', '-e', qq{require $module; print qq[$module ok]});
        };
        like($stdout, qr/^\s*$module ok/s, "$module loaded ok" );
        warn $stderr if $stderr;
        push @warnings, $stderr if $stderr;
    }

    if ($ENV{AUTHOR_TESTING}) { is(scalar(@warnings), 0, 'no warnings found'); }

    SKIP: {
        eval "use Test::Script 1.05; 1;";
        skip "Test::Script needed to test script compilation", scalar(@scripts) if $@;
        foreach my $file ( @scripts ) {
            my $script = $file;
            $script =~ s!.*/!!;
            script_compiles( $file, "$script script compiles" );
        }
    }
    BAIL_OUT("Compilation problems") if !Test::More->builder->is_passing;
}

done_testing;
