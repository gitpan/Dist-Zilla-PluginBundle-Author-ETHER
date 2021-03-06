use strict;
use warnings FATAL => 'all';

# patch modules that hit the network, to be sure we don't do this during
# testing.
{
    use HTTP::Tiny;
    package # hide from AutoPrereqs-provides heuristic
        HTTP::Tiny;
    no warnings 'redefine';
    sub get { die "HTTP::Tiny::get called for $_[1]" }
    sub mirror { die "HTTP::Tiny::mirror called for $_[1]" }
}
1;
