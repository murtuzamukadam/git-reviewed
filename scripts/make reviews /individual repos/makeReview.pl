#!/usr/bin/perl
use Mail::MboxParser;
use strict;

use DBI;
my $thisid = ' ';
my $dbName = 'data.db';
my $dbName1 = 'check.db';
my $email = ' ';
my @tid=0;
my $dbh = DBI->connect("dbi:SQLite:dbname=$dbName", '', '') or die "Cannot connect: $DBI::errstr";
my $dbh1 = DBI->connect("dbi:SQLite:dbname=$dbName1", '', '') or die "Cannot connect: $DBI::errstr";
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
       my $referenceid = $msg->header->{references}, "\n";
       my $from = $msg->header->{from}, "\n";
       my $replyto = $msg->get_field('in-reply-to'), "\n";
       my $date = $msg->header->{date},"\n";
       my $to = $msg->header->{to},"\n";  
       my $subject = $msg->header->{subject},"\n";
       my $cc = $msg->header->{cc},"\n";   
       my $thisid = $msg->id;
       my $body = $msg->body;
       my $body_str = $body->as_string || '<No message text>';
       my $sth = $dbh->prepare("SELECT * FROM line where tid='$thisid'");
       $sth->execute;
       my $row = $sth->fetchrow_arrayref();
    
       if ($row) {
               my ($tid, $commitid) = @$row;
               my $sth1 = $dbh1->prepare("SELECT * FROM line where commitid='$commitid'");
               $sth1->execute;
               my $row1 = $sth1->fetchrow_array();
            
               if($row1){
                 open (MYFILE, '> /tmp/data.tmp');
                 print MYFILE "From : $from\n";
                 print MYFILE "commit: $commitid\n";
                   if ( $from =~ /<(.*?)>/ ){
  		      $email = $1; 
		   }
                 print MYFILE "Message-Id : <$thisid>\n";
                 print MYFILE "Date : $date\n";
                 print MYFILE "Subject: $subject\n";
                 if(length($referenceid ne 0)) {
                  
                     print MYFILE "References: $referenceid\n";
                 }

                 if(length($replyto ne 0)) {
                     print MYFILE "$replyto\n";
                 }        
                 print MYFILE "Cc: $cc\n";
                 
                 print MYFILE "$body_str";
                 close (MYFILE); 
                 print "$from\n";
                 $subject =~ tr/'/-/;
                 my $show =`git reviewmbox '$commitid' '$from' '$date' '$email' '$subject'`;
                 print $show;
         
             
              }
          } 


       elsif ( $referenceid =~ /<(.*?)>/ ){
            
               my $reference = $1;   
               my $sth = $dbh->prepare("SELECT * FROM line where tid='$reference'");
               $sth->execute;
               my $row = $sth->fetchrow_arrayref();       
               if ($row) {
                   my ($tid, $commitid) = @$row;
                   my ($tid, $commitid) = @$row;
                   my $sth1 = $dbh1->prepare("SELECT * FROM line where commitid='$commitid'");
                   $sth1->execute;
                   my $row1 = $sth1->fetchrow_array();
                 
                   if($row1){
                      open (MYFILE, '> /tmp/data.tmp');
                      print MYFILE "From : $from\n";
                      print MYFILE "commit: $commitid\n";
                      if ( $from =~ /<(.*?)>/ ){
		       
   		          $email = $1;
    		  
		     }
                   print MYFILE "Message-Id : <$thisid>\n";
                   print MYFILE "Date : $date\n";
                   print MYFILE "Subject: $subject\n";
                   print MYFILE "$replyto\n";
                   print MYFILE "References : $referenceid\n";
                   print MYFILE "Cc: $cc\n";
                   
                   print MYFILE "$body_str";
                   close (MYFILE);
                   print "$from\n";
                   $subject =~ tr/'/-/;           
                   my $response =`git reviewmbox '$commitid' '$from' '$date' '$email' '$subject'`;
                   print $response;
             
                   }
       
               }
         }

        
    }
}
$dbh->disconnect();
exit 0;
