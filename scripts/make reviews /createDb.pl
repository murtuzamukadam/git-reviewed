
#!/usr/bin/perl

my $mid = ' ';
my $commit = ' ';
my $temp = 1;
use strict;
while(<>) {
    
    
    if (/^mid;<(.+?)>/) {
        
	$mid = $1;
        print "$mid;";
        $temp = 0;
    
    }
    elsif (/^\s\s\s\scommit: ([0-9a-f]{40})/ && $temp == 0 ) {
        
	$commit = $1;
        print "$commit\n";
        $temp =1 ; 
    }     
     elsif (/^\s\s\s\scommit: not match/ && $temp == 0) {
        
	$commit = "not match";
        print "$commit\n";
        $temp = 1;
    }           
    
}

       


