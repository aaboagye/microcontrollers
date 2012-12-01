#!/usr/bin/perl -w
use strict;

die "AAAAAAAAAH\n" unless defined $ARGV[0];

my %sym;
my $s = "\t\t";

while (<>) {
    if (/\w\:([^\s]+)\s+PUBLIC\s+([^\s]+)/) { 
        if (defined $sym{$1}) {
            print STDERR "ignored duplicate: $2 at $1\n";
        }
        else {
            $sym{$1} = $2;
            print "$2${s}EQU$s$1\n"
                 ."public${s}$2\n";
        }
    }
    elsif (/CODE\s+([^\s]+H)\s+0+([^\s]+)H\s+ABSOLUTE/) {
        print "CSEG AT $1\n"
             ."DS      $2\n";
    }
    elsif (/DATA\s+([^\s]+H)\s+[^\s]+\s+[^\s]+\s+\?DT\?_MICROSDREAD\?SD_11A/) {
        print "?_MICROSDREAD?BYTE${s}EQU$s$1\n"
             ."public${s}?_MICROSDREAD?BYTE\n";
    }
}
print "end\n";

__END__
