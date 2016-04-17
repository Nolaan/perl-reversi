package Human;

use namespace::autoclean;

use Moose;
use 5.012;

use Data::Dumper qw/Dumper/;

extends 'Player';

# Variables

# Methods

sub nextMove {
  my ($self, $c) = @_;
  my @move;
  say "Player ".$self->symbol." give your next move position, row number and column number separated by space : ";
  say "Example : 5 4";

  my $entry = <>;
  chomp $entry;
  @move = split ' ',$entry; # Split the default variable $_ (the topic)
  say Dumper($entry);
  return @move;
}

1;
