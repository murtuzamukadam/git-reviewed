#!/usr/bin/perl

#cat 2012-07 | ./searchMatch.pl | ./msg_to_commit.pl
use strict;

my @input;
while(my $line = <>) {
	push @input, $line;
}

my $line;
while (@input) {

	$line = shift @input;
	
	if ($line =~ /^mid;(\<.*?\>)/) {
		my $msg = $1;
		shift @input;
		$line = shift @input;
		if ($line =~ /^\s*commit:\s(\w+)\s/) {
			my $commit = $1;
			print "$msg -> $commit\n";
		}
			
	}

}
		


