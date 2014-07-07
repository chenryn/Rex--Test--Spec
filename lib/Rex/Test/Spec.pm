package Rex::Test::Spec;

use 5.006;
use strict;
use warnings FATAL => 'all';
my @EXPORT    = qw(describe context its);
my @testFuncs = qw(ok is isnt like unlike);
my @typeFuncs = qw(pkg service file run);
push @EXPORT, @testFuncs, @typeFuncs, 'done_testing';

our ($obj, $msg);

use Test::More;

=head1 NAME

Rex::Test::Spec - Write Rex::Test like RSpec!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Rex::Test::Spec;
    describe "Nginx Test", sub {
        context run("nginx -t"), "nginx.conf testing", sub {
            is its('exit'), 0;
        };
        context file("/etc/nginx.conf"), sub {
            like its('content'), qr/listen\s+80;/;
        };
    };
    done_testing;

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 SUBROUTINES/METHODS

=head2 describe

=cut

sub describe {
    my $code = pop;
    local $msg = '';
    local $obj;
    if ( defined $_[0] and ref($_[0]) =~ m/^Rex::Test::Spec::(\w+)$/ ) {
        $msg .= sprintf "%s(%s)", $1, $_[0]->{name};
        $obj = shift;
    };
    $msg .= join(' ', @_) if scalar @_;
    $code->();
}

=head2 context

=cut

BEGIN { *context = \&describe }

=head2 its

=cut

sub its {
    my $key = shift;
    $obj->getvalue($key);
}

for my $func (@testFuncs) {
    no strict 'refs';
    no warnings;
    *$func = sub {
        Test::More->can($func)->(@_, $msg);
    };
};

BEGIN { *done_testing = \&Test::More::done_testing }

sub AUTOLOAD {
    my ($method) = our $AUTOLOAD =~ /^[\w:]+::(\w+)$/;
    return if $method eq 'DESTROY';

    eval "use $AUTOLOAD";
    die "Error loading $AUTOLOAD." if $@;
    return $AUTOLOAD->new(name => shift @_);
}

sub import {
    no strict 'refs';
    no warnings;
    for ( @EXPORT ) {
        *{"main::$_"} = \&$_;
    }
}

=head1 AUTHOR

Rao Chenlin(chenryn), C<< <rao.chenlin at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-rex-test-spec at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Rex-Test-Spec>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Rex::Test::Spec


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Rex-Test-Spec>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Rex-Test-Spec>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Rex-Test-Spec>

=item * Search CPAN

L<http://search.cpan.org/dist/Rex-Test-Spec/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2014 Rao Chenlin(chenryn).

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See L<http://dev.perl.org/licenses/> for more information.


=cut

1; # End of Rex::Test::Spec
