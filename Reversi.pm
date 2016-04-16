package Reversi;
use namespace::autoclean;

#### Modules ####
use Moose;

use 5.012;
use Human;
use Computer;
use Data::Dumper qw /Dumper/;
##################



# Variables

has Board           => ( is  => 'rw' );
has Black           => ( is  => 'rw' );
has White           => ( is  => 'rw' );
has Turn            => ( is  => 'rw', default => '1' );
has Movables        => ( is  => 'rw' );
has PiecesPositions => ( is => 'rw' );

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
          $self->White(Computer->new());
          say "Player White (O) is : Computer";
        } 
        elsif ( $_ eq "2" ) {
          $self->White(Human->new());
          say "Player White (O) is : Human";
        }
        last;
      }
      if ( $_ eq "1" ) {
        $self->Black(Computer->new());
        say "Player Black (X) is : Computer";
      } 
      elsif ( $_ eq "2" ) {
        $self->Black(Human->new());
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
    my @move = $self->getNextPlayerMove();
    if($self->isMoveValid(@move))
    {
      $self->doMove(@move);
    }
    $self->computeMovables();
    $self->Turn(!$self->Turn());
    last;
  }
  return;
}

sub printBoard {
  my ($self, $c) = @_;

  $self->cls();

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
      say "Valid move!";
      say Dumper($cmp_str, $cp2);
      die;
      last;
    }
  }
  return $validity;
}

sub doMove {
  my ($self, $c) = @_;
  return;
}

sub computeMovables {
  my ($self, $c) = @_;
  
  # We keep track of the playable 'positions' for the current turn
  # by knowing what are at any given moment the piece positions
  if($self->Turn())
  {
    # X turn, Black player
    foreach my $piece_position (@{${$self->PiecesPositions()}[0]}) {
      say Dumper($piece_position);
    }

  }
  else
  {
    # O turn, White player
    foreach my $piece_position (@{${$self->PiecesPositions()}[1]}) {
      say Dumper($piece_position);
    }
      die;
  }
  return;
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
  my $clear;
  if ($^O =~ /mswin/i || $^O =~ /dos/i) {
    $clear = `cls`;
  } elsif ($^O eq 'linux') {
    $clear = `clear`;
  }
  return;
}


1;
