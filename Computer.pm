package Computer;
use namespace::autoclean;

use Moose;
use Reversi;
use 5.012;
use List::Util qw/min/;
use List::MoreUtils qw(firstidx uniq);

use Data::Dumper qw/Dumper/;

extends 'Player';

# Variables
has game            => ( is => 'ro' );
has level           => ( is => 'rw', isa => 'Int' ); # Allow user to choose the AI performance
has board           => ( is => 'rw' ); # AI needs a board representation
has PiecesPositions => ( is => 'rw' );
has Movables        => ( is => 'rw', default => sub { [] });


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

  my $rand_row = int(rand(scalar @{$self->game()->Movables()}));
  @move = @{$self->game()->Movables()->[$rand_row]};
  return @move;
}

sub nextMoveDifficult {
  my ($self, $c) = @_;
  my @move = @{$self->getBestMove()};
  return @move;
}
sub getBestMove {
  my ($self, $c) = @_;
  my $bestMove;
  my @mobility;
  # The best move will be the one that minimize the opponent mobility
  # To find it, we simulate all the moves possible and look at our
  # opponent maximum moves
  # Our possible moves are stored in $self->game()->Movables()
  foreach my $position (@{$self->game()->Movables()}) {
    push @mobility, $self->getOpponentMobilityForPosition($position);
  }
  my $min   = min @mobility;
  my $index = firstidx { $_ == $min } @mobility;
  # say "Mobility : ";
  # say Dumper( @mobility );
  $bestMove = $self->game()->Movables()->[$index];
  return $bestMove;
}

sub getOpponentMobilityForPosition {
  my ($self, $position) = @_;
  my $mobility;
  # Simulate the move and compute opponent mobility
  # for position
  $self->simulateMove($position);
  $mobility = $self->computeMobilityForPosition();
  return $mobility;
}

sub simulateMove {
  my ($self, $position) = @_;
  # initialize our board
  $self->board($self->game()->Board);
  
  my @hasToFlip;
  my @vectors = ([0,1],[1,1],[1,0],[1,-1],[0,-1],[-1,-1],[-1,0],[-1,1]); # This will help us go in all direction easily, we just add the vector to move toward that direction
  my $sym = ($self->symbol() eq 'X') ? 'O' : 'X'; # Inversed !!
  
  foreach my $vector (@vectors) {
    my ($i,$j) = [$position->[0],$position->[1]];
    $i += $vector->[0];
    $j += $vector->[1];

    if( $self->isOutOfBounds($i,$j) )
    {
      # Out of bounds
      next;
    }

    while( $sym eq ${$self->board()}[$i][$j])
    {
      push @hasToFlip, [$i,$j];
      # Move to next position
      $i += $vector->[0];
      $j += $vector->[1];
      if( $self->isOutOfBounds($i,$j) )
      {
        # Out of bounds
        undef @hasToFlip; # Throw the result they are invalid
        last;
      }
    }
    if( $self->isOutOfBounds($i,$j) )
    {
      # Out of bounds
      next;
    }

    if(     ( $sym ne ${$self->board()}[$i][$j] ) 
        and ( scalar @hasToFlip == 0 )
        or  ( ${$self->board()}[$i][$j] eq '.' ) 
      )
    {
      # First cycle and found our own piece
      # abort! 
      # or we found an empty case
      undef @hasToFlip;
      next;
    }
    if(     ( $sym ne ${$self->board()}[$i][$j] ) 
        and ( scalar @hasToFlip > 0 )
        and ( ${$self->board()}[$i][$j] ne '.' ) 
      )
    {
      # We found a complete line to flip
      
      ${$self->board}[$position->[0]][$position->[1]] = ${$self->board()}[$i][$j];
      $self->flip( \@hasToFlip, ${$self->board()}[$i][$j] );
    }

  }
  return;
}

sub flip {
  my ( $self, $hasToFlip, $sym ) = @_;

  my @hasToFlip = @{$hasToFlip};
  foreach my $arrref (@hasToFlip) {
    ${$self->board()}[$arrref->[0]][$arrref->[1]] = $sym;
  }
  return;
}
  

sub computeMobilityForPosition {
  my ($self, $c) = @_;
  # For the current $self->board find 
  # the number of move our opponent has
  my $mobility;
  my @vectors = ([0,1],[1,1],[1,0],[1,-1],[0,-1],[-1,-1],[-1,0],[-1,1]); # This will help us go in all direction easily, we just add the vector to move toward that direction

  # Reset 
  $self->PiecesPositions([]);
  # Populate
  for( my $i =0; $i<=7; $i++)
  {
    for( my $j =0; $j<=7; $j++)
    {
      if(${$self->board()}[$i][$j] eq 'X')
      {
        push @{${$self->PiecesPositions()}[0]}, [$i,$j];
      }
      elsif(${$self->board()}[$i][$j] eq 'O')
      {
        push @{${$self->PiecesPositions()}[1]}, [$i,$j];
      }

    }
  }

  my $pos = ($self->symbol() eq 'X') ? 1 : 0;
  my $sym = ($self->symbol() eq 'X') ? 'O' : 'X'; # Inversed !!

  $self->Movables([]);
  foreach my $piece_position (@{${$self->PiecesPositions()}[$pos]}) {
    my $i;
    my $j;
    foreach my $vector (@vectors) {
      ($i,$j) = ($piece_position->[0]+$vector->[0],$piece_position->[1]+$vector->[1]);
      if( $self->isOutOfBounds($i,$j) )
      {
        next;
      }
      if(${$self->board}[$i][$j] ne $sym )
      {
        # we need to find the opponent piece
        next;
      } else {
        # Follow the direction until we find a .
        while(${$self->board}[$i][$j] eq $sym )
        {
          $i += $vector->[0];
          $j += $vector->[1];
          # if out of bounds abort
          if( $self->isOutOfBounds($i,$j) )
          {
            last;
          }
        }
        if( (!$self->isOutOfBounds($i,$j)) and (${$self->board}[$i][$j] eq '.') )
        {
          # Found a . in this direction
          # add the position to the list
          push @{$self->Movables()}, [$i,$j];
        }
      }

    }
    # say "Movables :";
    # say Dumper($self->Movables());
  }
  $mobility = scalar @{$self->Movables()};
  # say "Found a mobility of $mobility";
  return $mobility;
}

sub isOutOfBounds {
  my ($self, $i,$j) = @_;
  my $res = ( $i > 7 or $i<0 or $j> 7 or $j <0) ? 1 : 0;
  return $res;
}

sub unik {
  my ($self, $a) = @_;
  my @b = @{$a};
  my $c = \@b;
  my @indexes;
  my $i;
  foreach my $ref ( @{$c}) {
    # say Dumper $ref->[0];
    my $size = scalar @{$c};
    my $seen = 0;
    for($i=0; $i < $size; $i++ )
    {
      if(     ( $c->[$i][0] == $ref->[0] ) 
          and ( $c->[$i][1] == $ref->[1] ) 
      )
      {
        if($seen == 0)
        {
          $seen++;
        }elsif($seen == 1)
        {
          # say "Position $i";
          push @indexes, $i;
        }
      }
    }
  }
  # say "Indexes : ".Dumper(@indexes);
  my $turn = 0;
  @indexes = sort(uniq(@indexes));
  if(scalar @indexes)
  {
    foreach my $ind (@indexes) {

      splice @{$c}, $ind-$turn, 1;
      $turn++;
    }
    $self->Movables($c);
  }
  return;
}

sub BUILD {
  my ($self, $c) = @_;
  $self->_new($self);
  return;
}
1;
