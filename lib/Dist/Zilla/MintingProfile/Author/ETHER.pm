use strict;
use warnings;
package Dist::Zilla::MintingProfile::Author::ETHER;
# ABSTRACT: Mint distributions like ETHER does
# vim: set ts=8 sw=4 tw=78 et :
$Dist::Zilla::MintingProfile::Author::ETHER::VERSION = '0.083';
use Moose;
with 'Dist::Zilla::Role::MintingProfile';
use File::ShareDir;
use Path::Class;        # sadly, we still need to use Path::Class :(
use Carp;
use namespace::autoclean;

sub profile_dir
{
    my ($self, $profile_name) = @_;

    die 'minting requires perl 5.014' unless $] >= 5.013002;

    my $dist_name = 'Dist-Zilla-PluginBundle-Author-ETHER';
    my $profile_dir = dir( File::ShareDir::dist_dir($dist_name) )
                      ->subdir( 'profiles', $profile_name );

    return $profile_dir if -d $profile_dir;

    confess "Can't find profile $profile_name via $self: it should be in $profile_dir";
}

__PACKAGE__->meta->make_immutable;

__END__

=pod

=encoding UTF-8

=head1 NAME

Dist::Zilla::MintingProfile::Author::ETHER - Mint distributions like ETHER does

=head1 VERSION

version 0.083

=head1 SYNOPSIS

    dzil new -P Author::ETHER -p github Foo::Bar

or:

    #!/bin/bash
    newdist() {
        local dist=$1
        local module=`perl -we"print q{$dist} =~ s/-/::/r"`
        pushd ~/git
        dzil new -P Author::ETHER -p github $module
        cd $dist
    }
    newdist Foo-Bar

=head1 DESCRIPTION

The new distribution is packaged with L<Dist::Zilla> using
L<Dist::Zilla::PluginBundle::Author::ETHER>.

Profiles available are:

=over 4

=item *

C<github>

Creates a distribution hosted on L<github|http://github.com>, with hooks to determine the
module version and other metadata from git. Issue tracking is disabled, as RT
is selected as the bugtracker in the distribution's metadata (via the plugin
bundle).

You will be prompted to create a repository on github immediately; if you
decline, you must create one manually before you do your first C<push>.

=back

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

=cut
