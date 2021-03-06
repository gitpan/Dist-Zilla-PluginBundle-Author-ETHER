use strict;
use warnings FATAL => 'all';

use Test::More;
use if $ENV{AUTHOR_TESTING}, 'Test::Warnings';
use Test::Deep;
use Test::DZil;
use Path::Class;
use Path::Tiny;
use Moose::Util 'find_meta';

use lib 't/lib';
use NoNetworkHits;
use NoPrereqChecks;

# we need the profiles dir to have gone through file munging first (for
# profile.ini), as well as get installed into a sharedir
plan skip_all => 'this test requires a built dist'
    unless -d 'blib/lib/auto/share/dist/Dist-Zilla-PluginBundle-Author-ETHER/profiles';

plan skip_all => 'minting requires perl 5.014' unless $] >= 5.013002;

my $tzil = Minter->_new_from_profile(
    [ 'Author::ETHER' => 'github' ],
    { name => 'My-New-Dist', },
    { global_config_root => dir('t/corpus/global')->absolute }, # sadly, this must quack like a Path::Class
);

# we need to stop the git plugins from doing their thing
foreach my $plugin (grep { ref =~ /Git/ } @{$tzil->plugins})
{
    next unless $plugin->can('after_mint');
    my $meta = find_meta($plugin);
    $meta->make_mutable;
    $meta->add_around_method_modifier(after_mint => sub { Test::More::note("in $plugin after_mint...") });
}

$tzil->chrome->logger->set_debug(1);
$tzil->mint_dist;
my $mint_dir = path($tzil->tempdir)->child('mint');

my @expected_files = qw(
    .ackrc
    .gitignore
    .mailmap
    Changes
    dist.ini
    CONTRIBUTING
    LICENSE
    README.pod
    weaver.ini
    lib/My/New/Dist.pm
    t/01-basic.t
);

my @found_files;
my $iter = $mint_dir->iterator({ recurse => 1 });
while (my $path = $iter->())
{
    push @found_files, $path->relative($mint_dir)->stringify if -f $path;     # ignore directories
}

cmp_deeply(
    \@found_files,
    bag(@expected_files),
    'the correct files are created',
);

my $module = path($mint_dir, 'lib/My/New/Dist.pm')->slurp_utf8;

like(
    $module,
    qr/^use strict;\nuse warnings;\npackage My::New::Dist;/m,
    'our new module has a valid package declaration',
);

like(
    $module,
    qr/\n\n\n1;\n__END__\n/m,
    'the package code ends in a generic way',
);

like(
    $module,
    do {
        my $pattern = <<SYNOPSIS;
=pod

=head1 SYNOPSIS

    use My::New::Dist;

    ...

=head1 DESCRIPTION
SYNOPSIS
        qr/\Q$pattern\E/
    },
    'our new module has a brief generic synopsis and description',
);

like(
    $module,
    qr{=head1 FUNCTIONS/METHODS},
    'our new module has a pod section for functions and methods',
);

like(
    path($mint_dir, 't', '01-basic.t')->slurp_utf8,
    qr/^use My::New::Dist;\n\nfail\('this test is TODO!'\);$/m,
    'test gets generic content',
);

like(
    path($mint_dir, 'dist.ini')->slurp_utf8,
    qr/\[\@Author::ETHER\]/,
    'plugin bundle is referenced in dist.ini',
);

like(
    path($mint_dir, '.gitignore')->slurp_utf8,
    qr'^/My-New-Dist-\*/$'ms,
    '.gitignore file is created properly, with dist name correctly inserted',
);

is(
    path($mint_dir, 'Changes')->slurp_utf8,
    <<'CHANGES',
Revision history for {{$dist->name}}

{{$NEXT}}
          - Initial release.
CHANGES
    'Changes file is created properly, with templates and whitespace preserved',
);

is(
    path($mint_dir, 'README.pod')->slurp_utf8,
    <<'README',
=pod

=head1 SYNOPSIS

    use My::New::Dist;

    ...

=head1 DESCRIPTION

...

=head1 FUNCTIONS/METHODS

=head2 C<foo>

...

=head1 SUPPORT

=for stopwords irc

Bugs may be submitted through L<the RT bug tracker|https://rt.cpan.org/Public/Dist/Display.html?Name=My-New-Dist>
(or L<bug-My-New-Dist@rt.cpan.org|mailto:bug-My-New-Dist@rt.cpan.org>).
I am also usually active on irc, as 'ether' at C<irc.perl.org>.

=head1 ACKNOWLEDGEMENTS

...

=head1 SEE ALSO

=for :list
* L<foo>

=cut
README
    'README.pod is generated and contains pod',
);

diag 'got log messages: ', explain $tzil->log_messages
    if not Test::Builder->new->is_passing;

done_testing;
