package Player;
use namespace::autoclean;

use Moose;

# Variables
has symbol => ( is  => 'ro');

# Methods

sub new {
  my ($self, $c) = @_;
  #body ... 
}

sub nextMove {
  my ($self, $c) = @_;
  #body ...  
  return $self;
}

1;
