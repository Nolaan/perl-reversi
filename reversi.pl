#!/usr/bin/perl -w

use strict;
use warnings;
use 5.012;

#### Modules ####
#################

#### Packages ###
use Reversi;
#################

#Variables

##########

my $game = Reversi->new();
$game->startGame();
