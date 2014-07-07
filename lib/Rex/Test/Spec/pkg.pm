package Rex::Test::Spec::pkg;

use strict;
use warnings;

use Rex -base;

sub new {
  my $that  = shift;
  my $proto = ref($that) || $that;
  my $self  = {@_};

  bless( $self, $proto );

  my ( $pkg, $file ) = caller(0);

  return $self;
}

sub ensure {
  my ( $self ) = @_;
  my @packages = installed_packages;
  my $ret;
  for my $p (@packages) {
    if ($p->{name} eq $self->{name}) {
      $ret = 'installed';
      $self->{version} = $p->{version};
    }
  }
  return $ret;
}

sub version {
  my ( $self ) = @_;
  $self->ensure unless $self->{version};
  $self->{version};
}

sub getvalue {
  my ( $self, $key ) = @_;
  return $self->$key;
}

1;
