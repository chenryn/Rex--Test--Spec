package Rex::Test::Spec;

use 5.006;
use strict;
use warnings FATAL => 'all';
my @EXPORT    = qw(describe context its it);
my @testFuncs = qw(ok is isnt like unlike is_deeply);
my @typeFuncs = qw(cron file gateway group iptables 
    pkg port process routes run service sysctl user);
push @EXPORT, @testFuncs, @typeFuncs, 'done_testing';

our ($obj, $msg);

use Test::More;

=head1 NAME

Rex::Test::Spec - Write Rex::Test like RSpec!

=head1 VERSION

Version 0.02

=cut

our $VERSION = '0.02';


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Rex::Test::Spec;
    describe "Nginx Test", sub {
        context run("nginx -t"), "nginx.conf testing", sub {
            like its('stdout'), qr/ok/;
        };
        context file("/etc/nginx.conf"), sub {
            is its('ensure'), 'present';
            like its('content'), qr/listen\s+80;/;
        };
        context service("nginx"), sub {
            is its('ensure'), 'running';
        };
        context pkg("nginx"), sub {
            is its('ensure'), 'present';
            is its('version'), '1.5.8';
        };
        context cron, sub {
            like its('www'), 'logrotate';
        };
        context gateway, sub {
            is its('value'), '192.168.0.1';
        };
        context group('www'), sub {
            ok its('ensure');
        };
        context iptables, sub {
        };
        context port(80), sub {
            is its('bind'), '0.0.0.0';
            is its('proto'), 'tcp';
            is its('command'), 'nginx';
        };
        context process('nginx'), sub {
            like its('command'), qr(nginx -c /etc/nginx.conf);
            ok its('mem') > 1024;
        };
        context routes, sub {
            is_deeply its(1), {
                destination => $dest,
                gateway     => $gw,
                genmask     => $genmask,
                flags       => $flags,
                mss         => $mss,
                irtt        => $irtt,
                iface       => $iface,
            };
        };
        context sysctl, sub {
            is its('vm.swapiness'), 1;
        };
        context user('www'), sub {
            ok its('ensure');
            is its('home'), '/var/www/html';
            is its('shell'), '/sbin/nologin';
            is_deeply its('belong_to'), ['www', 'nogroup'];
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
    return $obj->getvalue(@_);
}

BEGIN { *it = \&its }

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
    my @args = @_;
    unshift @args, 'name' if scalar @args == 1;
    return $AUTOLOAD->new(@args);
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
