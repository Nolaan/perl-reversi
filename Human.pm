package Human;

use namespace::autoclean;

use Moose;

extends 'Player';

# Variables
has level => ( is => 'ro' ); # Allow user to choose the AI performance

# Methods

sub nextMove {
  my ($self, $c) = @_;
  #body ...
  return $self;
}

1;
