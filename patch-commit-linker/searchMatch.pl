#!/usr/bin/perl


use strict;
use DBI;

my $dbName = 'lineslinus.db';

my $binPath = Get_Execution_Path();


my $dbh = DBI->connect(          
    "dbi:SQLite:dbname=${binPath}$dbName", 
    "",                          
    "",                          
    { RaiseError => 1 },         
) or die $DBI::errstr;

my $THRESHOLD = 0;



my %cids;
my $messageId = '';
my $prevEmpty = 1;
my $line = '';
my $lineType = '';
my $file = '';
my $matched = 0;
my $total = 0;
my @noMatches;
while (<>) {
    chomp;
    if (/^From / and $prevEmpty) {
	if ($matched > 0) {
	    Report();
	}
	$messageId = '';
	$prevEmpty = 0;
	$file = '';
	$line = '';
	$total = 0;
	$matched = 0;
	%cids = ();
	@noMatches = ();
    } elsif ($_ eq "") {
	$prevEmpty = 1;
    } elsif (/^message\-id:\s*(.+)$/i) {
	$messageId = $1;
#	print "Message id [$messageId]\n";
    } elsif (/^\+\+\+ (.+)$/) {
	$file = $1;
    } elsif (/^\-\-\- (.+)$/) {
	; do nothing
    } elsif (/^\-(.+)$/ and $file ne '') {
	Do_Matching_Line('-', $1);
    } elsif (/^\+(.+)$/ and $file ne '') {
	Do_Matching_Line('+', $1);
    } else {
	die if /^Message-ID/i;
	;
    }
}
Report();
$dbh->disconnect();
exit 0;

sub Report
{
    my $prop = $matched * 1.0 / ($total==0?1:$total);
    if ($prop > $THRESHOLD) {
	my $commitsCount = scalar (keys %cids);
	print "mid;$messageId;cids;$commitsCount;tot;$total;match;$matched;prop;", $prop, "\n" ;
	
	my @bestCids = Best_Cids(\%cids);
	print "    Bestcids: ", scalar(@bestCids), "\n";
#		foreach my $c (keys %cids) {
	foreach my $c (@bestCids) {
	    my $count = Count_Lines_In_Commit($c);
	    if ($count <= $total) {
		print "    $c -> $cids{$c};", $count, ";\n";
	    }
	}
	foreach my $m (@noMatches) {
	    print " not match [$m]\n";
	}
    }
}

sub Count_Lines_In_Commit
{
    my ($cid) = @_;
    return Simple_Query("select count(*) from (select linetype, line from line where cid = '$cid') as rip");
}

sub Do_Matching_Line
{
    my ($lineType, $line) = @_;
    return unless $line =~ /[a-zA-Z]/;
    my @matches = Find_Match_Line($file, $line, $lineType);
    $total++;
    if (scalar(@matches) == 0) {
	; # no matches
	push(@noMatches, $line);

    } else {
	foreach my $c (Find_Match_Line($file, $line, $lineType)) {
	    $cids{$c}++;
	}
	$matched++;
    }
    
}

sub Find_Match_Line
{
    my ($file, $line, $type)  = @_;
    
    die unless $type eq '+' or $type eq '-';
    
    $line =~ s/;/<semi>/g;

    return Simple_Array_Query("select distinct cid from line where linetype = ? and filename = ? and line = ?", $type, $file, $line);
}




sub Get_Execution_Path
{
    my $path = $0;
    if ($path =~ m@/@) {
       $path =~ s@/[^/]+$@/@;
    } else {
       $path = ""
    }
    print "path[$path]\n";
    return $path;
}


sub Simple_Query
{
    my ($query, @parms) = @_;
    my $q = $dbh->prepare($query);
    $q->execute(@parms);
    return $q->fetchrow_array();

}

sub Simple_Array_Query
{
    my ($query, @parms) = @_;
    my @result;
    my $q = $dbh->prepare($query);
    $q->execute(@parms);
    while (my $item = $q->fetchrow_array()) {
        push @result, $item;
    }
    return @result;
}

sub Best_Cids
{
    my ($cids) = @_;
    if (scalar(%$cids) == 0) {
	return undef;
    }
    my @ordered = Sort_Hash($cids);
    foreach my $c (@ordered) {
#	print "----->$c -> $$cids{$c}\n";
    }

    my @returnVals;
    my $last =0;
    foreach my $t (@ordered) {
	if ($$cids{$t} >= $last) {
	    push(@returnVals, $t);
	    $last = $$cids{$t};
	} else {
	    return @returnVals;
	}
    }
    return @returnVals;
}

sub Sort_Hash
{
    my ($h) = @_;

    return (sort {$$h{$b} <=> $$h{$a}} keys %$h);
}
