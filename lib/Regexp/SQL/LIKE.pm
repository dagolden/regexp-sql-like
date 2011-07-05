use 5.008001;
use strict;
use warnings;

package Regexp::SQL::LIKE;
# ABSTRACT: Translate SQL LIKE pattern to a regular expression

# Dependencies
use autodie 2.00;
use Sub::Exporter
  -setup => { exports => [ qw/to_regexp/ ] };

=func to_regexp

  my $re = to_regexp( "Hello %" );

This function converts an SQL LIKE pattern into an equivalent regular
expression.  A C<%> character matches any number of characters like C<.*> and a
C<.> character matchs a single character.  Backspaces may be used to escape
C<%>, C<.> and C<\> itself:

  to_regexp( "Match literal \%" );

All other characters are run through C<quotemeta()> to sanitize them.

The function returns a compiled regular expression.

=cut

sub to_regexp {
  my ($like);
  my $re = '';

  my %anchors = (
    start => substr($like, 0,1) ne '%',
    end   => substr($like,-1,1) ne '%',
  );

  # split out tokens with backslashes before wildcards so
  # we can figure out what is actually being escaped
  my @parts = split qr{(\\*[.%])}, $like;

  for my $p ( @parts ) {
    next unless length $p;
    my $backslash_count =()= $p =~ m{\\}g; 
    my $wild_count =()= $p =~ m{[%.]}g; 
    if ($wild_count) {
      if ( $backslash_count && $backslash_count % 2 ) {
        # odd slash count, so wild card is escaped 
        my $last = substr( $p, -2, 2, '');
        $p =~ s{\\\\}{\\};
        $re .= quotemeta( $p . substr($last, -1, 1) );
      }
      elsif ( $backslash_count ) {
        # even slash count, they only escape themselves
        my $last = substr( $p, -1, 1, '');
        $p =~ s{\\\\}{\\};
        $re .= quotemeta( $p ) . ( $last eq '%' ? '.*' : '.' );
      }
      else { # just a wildcard, no escaping
        $re .= $p eq '%' ? '.*' : '.';
      }
    }
    else {
      # no wildcards so apply any escapes freely
      $p =~ s{\\(.)}{$1}g;
      $re .= quotemeta( $p );
    }
  }

  substr( $re, 0, 0, '^' ) if $anchors{start};
  $re .= '$' if $anchors{end};

  return qr/$re/;
}

1;

__END__

=for Pod::Coverage method_names_here

=begin wikidoc

= SYNOPSIS

  use Regexp::SQL::LIKE 'to_regexp';

  my $re = to_regexp( "Hello %" ); # returns qr/^Hello .*/

= DESCRIPTION

This module converts an SQL LIKE pattern to its Perl regular expression
equivalent.

Currently, only {%} and {.} wildcards are supported and only {\ } is
supported as an escape character.

No functions are exported by default.  You may rename function on import as
follows:

  use Regexp::SQL::Like to_regexp => { -as => 'regexp_from_like' };

See [Sub::Exporter] for more details on import customization.

=end wikidoc

=cut

