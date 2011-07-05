use 5.010;
use strict;
use warnings;
use Test::More 0.92;
use re qw(regexp_pattern);

my @cases = (
  [ 'Hello'       => '^Hello$'      => "Plain text" ],
  [ 'Hello %'     => '^Hello\ .*'    =>  "Trailing wildcard" ],
  [ '% World'     => '.*\ World$'    =>  "Trailing wildcard" ],
);

use Regexp::SQL::LIKE qw/to_regexp/;

for my $c ( @cases ) {
  my ( $like, $expect, $label) = @$c;
  my ($pat, $mods) = regexp_pattern(to_regexp($like));
  is ($pat, $expect, $label );
}

done_testing;
