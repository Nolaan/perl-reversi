package Player;
use namespace::autoclean;

use Moose;

# Variables
has symbol => ( is  => 'ro');

# Methods

sub nextMove {
  my ($self, $c) = @_;
  my @move;
  return @move;
}

1;
