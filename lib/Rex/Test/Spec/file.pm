package Rex::Test::Spec::file;

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
  return is_file($self->{name});
}

sub content {
  my ( $self ) = @_;
  return cat($self->{name}) || undef;
}

sub getvalue {
  my ( $self, $key ) = @_;
  return $self->$key;
}

1;
