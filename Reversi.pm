package Reversi;
use namespace::autoclean;

#### Modules ####
use Moose;

use 5.012;
use Human;
use Computer;
use Data::Dumper qw /Dumper/;
use List::MoreUtils qw(uniq);
##################



# Variables

has Board           => ( is  => 'rw' );
has Black           => ( is  => 'rw' );
has White           => ( is  => 'rw' );
has Turn            => ( is  => 'rw', default => '1' );
has Movables        => ( is  => 'rw' );
has PiecesPositions => ( is => 'rw' );
has scoreX          => ( is => 'rw' );
has scoreO          => ( is => 'rw' );

# Methods

sub _new {
  my ($self, $c) = @_;
  # Prompt the user to choose
  # input => (1,2)
  my $sym = 'X';
  $self->Board(
               [
                ['.','.','.','.','.','.','.','.'],
                ['.','.','.','.','.','.','.','.'],
                ['.','.','.','.','.','.','.','.'],
                ['.','.','.','X','O','.','.','.'],
                ['.','.','.','O','X','.','.','.'],
                ['.','.','.','.','.','.','.','.'],
                ['.','.','.','.','.','.','.','.'],
                ['.','.','.','.','.','.','.','.'],
               ]
              );
  $self->Movables(
                  [[5,3],
                   [4,2],
                   [3,5],
                   [2,4]]
                 );
  $self->PiecesPositions(
                         [
                          [[3,3],[4,4]], # Start position for X pieces
                          [[3,4],[4,3]]  # Start position for O pieces
                         ]
                        );
  say "Choose Player Type for X (1=> Computer, 2=> Human) :";

  while(<>)
  {
    chomp;
    if ( ($_ != 1) and ($_ != 2) ) {
     say "Choose Player Type for $sym (1=> Computer, 2=> Human) :";
     say "1 or 2!";
      next;
    } else {
      if( $sym eq 'O' )
      {
        if ( $_ eq "1" ) {
          $self->White(Computer->new( symbol => $sym, game => $self));
         say "Player White (O) is : Computer";
        } 
        elsif ( $_ eq "2" ) {
          $self->White(Human->new( symbol => $sym));
         say "Player White (O) is : Human";
        }
        last;
      }
      if ( $_ eq "1" ) {
        $self->Black(Computer->new( symbol => $sym, game => $self));
       say "Player Black (X) is : Computer";
      } 
      elsif ( $_ eq "2" ) {
        $self->Black(Human->new( symbol => $sym));
       say "Player Black (X) is : Human";
      }
      $sym = 'O';
     say "Choose Player Type for $sym (1=> Computer, 2=> Human) :";
    }
  }
  return $self;
}

sub startGame {
  my ($self, $c) = @_;
  while(1)
  {
    $self->printBoard();
    $self->printScore();
    my @move = $self->getNextPlayerMove();
    if($self->isMoveValid(@move))
    {
      $self->doMove(@move);
    }
    $self->computeMovables();
    $self->Turn(!$self->Turn());
    if(scalar @{$self->Movables()} == 0)
    {
      say "No more moves! End of Game!";
      my $sym = ( $self->scoreX > $self->scoreO ) ? 'X' : '0';
      say "Player $sym won!";
      last;
    }
  }
  return;
}

sub printScore {
  my ($self, $c) = @_;
  $self->scoreX(scalar @{${$self->PiecesPositions()}[0]});
  $self->scoreO(scalar @{${$self->PiecesPositions()}[1]});

  say "Player X : ".$self->scoreX."| Player O : ".$self->scoreO;
}

sub printBoard {
  my ($self, $c) = @_;

  # $self->cls();

  my $line_num = 0;
  my $header ="  0 1 2 3 4 5 6 7";
 say $header;

  foreach my $line_ref (@{$self->Board()}) {
   say "$line_num ".join(' ', @{$line_ref});
    $line_num++;
  }
  return;
}

sub isMoveValid {
  my ($self, @move) = @_;
  my $validity = 0;

  # Check if the length is correct
  if(scalar @move != 2 )
  {
   say "Invalid entry, passing turn!";
    return $validity;
  }

  # We create a merge of the array element 
  # to make a string comparison easily
  my $cmp_str = join '', @move;
  my $cp2;
  foreach my $possible_move (@{$self->Movables()})
  {
    $cp2 = join '', @{$possible_move};
    if( $cmp_str eq $cp2 )
    {
      # The strings match so the position is movable to
      # (it is valid) we break out of the loop
      $validity = 1;
#      say "Valid move!";
      last;
    }
  }
  return $validity;
}

sub doMove {
  my ($self, @move) = @_;
  # We now have to propagate the changes to 
  # the Board and some variables
  # we take the accepted move position and flip
  # all the opposite piece we can matching the 4 
  # straight lines intersecting the move coordinates
  my @hasToFlip;
  my @vectors = ([0,1],[1,1],[1,0],[1,-1],[0,-1],[-1,-1],[-1,0],[-1,1]); # This will help us go in all direction easily, we just add the vector to move toward that direction
  my $sym = ($self->Turn()) ? 'O' : 'X'; # Inversed !!
  
  foreach my $vector (@vectors) {
    my ($i,$j) = @move;
    $i += $vector->[0];
    $j += $vector->[1];
#    say "We coming from $move[0],$move[1] ";

    if( $self->isOutOfBounds($i,$j) )
    {
      # Out of bounds
      next;
    }

#    say "Doing with : ".$sym." and ".${$self->Board()}[$i][$j];
    while( $sym eq ${$self->Board()}[$i][$j])
    {
      push @hasToFlip, [$i,$j];
#      say "Pushing $i $j";
      # Move to next position
      $i += $vector->[0];
      $j += $vector->[1];
      if( $self->isOutOfBounds($i,$j) )
      {
        # Out of bounds
        undef @hasToFlip; # Throw the result they are invalid
#        say "Got out of bounds";
        last;
      }
    }
    if( $self->isOutOfBounds($i,$j) )
    {
      # Out of bounds
      next;
    }

    if(     ( $sym ne ${$self->Board()}[$i][$j] ) 
        and ( scalar @hasToFlip == 0 )
        or  ( ${$self->Board()}[$i][$j] eq '.' ) 
      )
    {
      # First cycle and found our own piece
      # abort! 
      # or we found an empty case
#      say "Found nothing, emptying and resetting";
      undef @hasToFlip;
      next;
    }
    if(     ( $sym ne ${$self->Board()}[$i][$j] ) 
        and ( scalar @hasToFlip > 0 )
        and ( ${$self->Board()}[$i][$j] ne '.' ) 
      )
    {
      # We found a complete line to flip
#      say "Found what to flip";
      ${$self->Board}[$move[0]][$move[1]] = ${$self->Board()}[$i][$j];
      $self->flip( \@hasToFlip, ${$self->Board()}[$i][$j] );
    }

  }
  return;
}

sub flip {
  my ( $self, $hasToFlip, $sym ) = @_;

  my @hasToFlip = @{$hasToFlip};
  # say "Flipping! $sym";
  # say Dumper(@hasToFlip);
  foreach my $arrref (@hasToFlip) {
#    say "arrref : $arrref->[0],$arrref->[1]";
#    say "changing ${$self->Board()}[$arrref->[0]][$arrref->[1]] to  $sym";
    # die;
    ${$self->Board()}[$arrref->[0]][$arrref->[1]] = $sym;
  }
  return;
}

sub computeMovables {
  my ($self, $c) = @_;
  
  # We keep track of the playable 'positions' for the current turn
  # by knowing what are at any given moment the piece positions
  
  # Reset 
  $self->PiecesPositions([]);
  # Populate
  for( my $i =0; $i<=7; $i++)
  {
    for( my $j =0; $j<=7; $j++)
    {
      if(${$self->Board()}[$i][$j] eq 'X')
      {
        push @{${$self->PiecesPositions()}[0]}, [$i,$j];
      }
      elsif(${$self->Board()}[$i][$j] eq 'O')
      {
        push @{${$self->PiecesPositions()}[1]}, [$i,$j];
      }

    }
  }
  # Reset movables too
  $self->Movables([]);
  if(!$self->Turn())
  {
    # X turn, Black player
    # search for O tiles
    $self->populateMovable('O');
  }
  else
  {
    # O turn, White player
    # search for X tiles
    $self->populateMovable('X');
  }
  return;
}

sub populateMovable {
  my ($self, $sym) = @_;
  my $pos = ($sym eq 'O') ? 0 : 1; # player X searching for O tiles

  my @vectors = ([0,1],[1,1],[1,0],[1,-1],[0,-1],[-1,-1],[-1,0],[-1,1]); # This will help us go in all direction easily, we just add the vector to move toward that direction

  foreach my $piece_position (@{${$self->PiecesPositions()}[$pos]}) {
    my $i;
    my $j;
    foreach my $vector (@vectors) {
      ($i,$j) = ($piece_position->[0]+$vector->[0],$piece_position->[1]+$vector->[1]);
      if( $self->isOutOfBounds($i,$j) )
      {
        next;
      }
      if(${$self->Board}[$i][$j] ne $sym )
      {
        # we need to find the opponent piece
        next;
      } else {
        # Follow the direction until we find a .
        while(${$self->Board}[$i][$j] eq $sym )
        {
          $i += $vector->[0];
          $j += $vector->[1];
          # if out of bounds abort
          if( $self->isOutOfBounds($i,$j) )
          {
            last;
          }
        }
        if( (!$self->isOutOfBounds($i,$j)) and (${$self->Board}[$i][$j] eq '.') )
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
  # say "Movables : ";
  # say Dumper($self->Movables());
  # die;
}
sub isOutOfBounds {
  my ($self, $i,$j) = @_;
  my $res = ( $i > 7 or $i<0 or $j> 7 or $j <0) ? 1 : 0;
  return $res;
}
sub getNextPlayerMove {
  my ($self, $c) = @_;
  my @move;
  if($self->Turn())
  {
    # 1 for Black player
   @move = $self->Black->nextMove(); 
  }
  else
  {
    # 0 for White player
   @move = $self->White->nextMove(); 
  }
  return @move
}

sub BUILD {
  my ($self, $c) = @_;
  $self->_new($self);
  return;
}

sub cls {
  my ($self, $c) = @_;
  system $^O eq 'MSWin32' ? 'cls' : 'clear';
  return;
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


1;
