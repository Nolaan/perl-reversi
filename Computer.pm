package Computer;
use namespace::autoclean;

use Moose;
use 5.012;

extends 'Player';

# Variables
has level => ( is => 'rw', isa => 'Int' ); # Allow user to choose the AI performance


# Methods

sub _new {
  my ($self, $c) = @_;
  say "Choose level 1, easy; 2 difficult";
  while(<>)
  {
    chomp;
    if ( ($_ != 1) and ($_ != 2) ) {
      say "Choose level 1, easy; 2 difficult";
      say "1 or 2!";
      next;
    } else {
      $self->level($_);
      last;
    }
  }
  return $self;
}

sub nextMove {
  my ($self, $c) = @_;
  my @move;
  if($self->level == 1)
  {
    @move = $self->nextMoveEasy();
  }
  else
  {
    @move = $self->nextMoveDifficult();
  }
  return @move;
}

sub nextMoveEasy {
  my ($self, $c) = @_;
  my @move;
  return @move;
}

sub nextMoveDifficult {
  my ($self, $c) = @_;
  my @move;
  return @move;
}

sub BUILD {
  my ($self, $c) = @_;
  $self->_new($self);
}
1;
