#!/usr/bin/perl
use Mail::MboxParser;
use strict;
use DBI;


open (MYFILE, '> commits.in');
my $thisid = ' ';
my $dbName = 'data.db';
my $email = ' ';
my @tid=0;
my $dbh = DBI->connect("dbi:SQLite:dbname=$dbName", '', '') or die "Cannot connect: $DBI::errstr";
my $parseropts = {
        enable_cache    => 1,
        enable_grep     => 1,
        cache_file_name => 'mail/cache-file',
     };
foreach my $arg(@ARGV){
my $mb = Mail::MboxParser->new($arg,
                                    decode     => 'ALL',
                                    parseropts => $parseropts);


    for my $msg ($mb->get_messages) {
       
	my $from = $msg->header->{from};      
        my $thisid = $msg->id;        
        my $referenceid = $msg->header->{references};
        my $reference;
        if ($referenceid =~ /<(.*?)>/ ){
             $reference = $1;   
        }
        
        if ($from =~ /David\sMiller/) {
             my $sth = $dbh->prepare("SELECT commitid FROM line where tid='$thisid'");
             $sth->execute;
             my $commitid = $sth->fetchrow_array();
             my $sth = $dbh->prepare("SELECT * FROM line where commitid='$commitid'");
             $sth->execute;
             my $row = $sth->fetchrow_arrayref();
             if ($row) {
                my ($tid, $commitid) = @$row;
                print MYFILE "$commitid\n"
            }
         
        else{
             my $sth = $dbh->prepare("SELECT commitid FROM line where tid='$reference'");
             $sth->execute;
             my $commitid = $sth->fetchrow_array();
             my $sth = $dbh->prepare("SELECT * FROM line where commitid='$commitid'");
             $sth->execute;
             my $row = $sth->fetchrow_arrayref();
             if ($row) {
                my ($tid, $commitid) = @$row;
                print MYFILE "$commitid\n"
             }
           
           }
        }
     }
}
   
$dbh->disconnect();
exit 0;
