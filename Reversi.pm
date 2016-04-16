package Reversi;
use namespace::autoclean;

use Moose;

# Variables

has Board => ( is  => 'ro');
has Black => ( is  => 'ro');
has White => ( is  => 'ro');
has Turn  => ( is  => 'ro');

# Methods

sub new {
  my ($self, $c) = @_;
  # Prompt the user to choose
  # input => (1,2)
  return $self;
}

sub startGame {
  my ($self, $c) = @_;
  while(1)
  {
    1;
  }
  return;
}

sub printBoard {
  my ($self, $c) = @_;
  #body ...
  return $self;
}

1;
