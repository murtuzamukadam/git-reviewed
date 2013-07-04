#!/usr/bin/perl

use strict;

my $cid = '';
my $file = '';
while(<>) {
    chomp;
    if (/^commit ([0-9a-f]{40})/) {
	$cid = $1;
    } elsif (/^\+\+\+ (.+)$/) {
	$file = $1;
    } elsif (/^\-\-\- (.+)$/) {
	; # ignore the before file
    } elsif (/^(\+|\-)(.+)$/) {
	my $type = $1;
	my $rest = $2;
	$rest =~ s/;/<semi>/g;
	print "$cid;$file;$type;$rest\n" if $rest =~ /[a-zA-Z0-9]/;
    } else {
	; #ignore
    }
}
