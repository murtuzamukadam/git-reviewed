#!/usr/bin/perl
use Mail::MboxParser;
use strict;

use DBI;
my $thisid = ' ';
my $dbName = 'data.db';
my @tid=0;
my $dbh = DBI->connect("dbi:SQLite:dbname=$dbName", '', '') or die "Cannot connect: $DBI::errstr";

 my $parseropts = {
        enable_cache    => 1,
        enable_grep     => 1,
        cache_file_name => 'mail/cache-file',
    };
    my $mb = Mail::MboxParser->new($ARGV[0],
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
              
              open (MYFILE, '> data.tmp');
              print MYFILE "From : $from\n";
              print MYFILE "Message-Id : <$thisid>\n";
              print "$thisid\n";
              print MYFILE "Date : $date\n";
              print MYFILE "Subject: $subject\n";
              print MYFILE "Cc: $cc\n";
              print MYFILE "commit: $commitid\n\n";
              print MYFILE "$body_str";
              close (MYFILE); 
              print " thread \n";  
              my $show =`git reviewmbox '$commitid'`;
              print $show;
              
             

            } 


elsif ( $referenceid =~ /<(.*?)>/ ){
           my $reference = $1;   

 my $sth = $dbh->prepare("SELECT * FROM line where tid='$reference'");
    $sth->execute;
    my $row = $sth->fetchrow_arrayref();
    
    

        
           if ($row) {
              my ($tid, $commitid) = @$row;
              open (MYFILE, '> data.tmp');
              print MYFILE "From : $from\n";
              print MYFILE "Message-Id : <$thisid>\n";
              print "$thisid\n";
              print MYFILE "Date : $date\n";
              print MYFILE "In-Reply-To : $replyto\n";
              print MYFILE "References : $reference\n";
              print MYFILE "Subject: $subject\n";
              print MYFILE "Cc: $cc\n";
              print MYFILE "commit: $commitid\n\n";
              print MYFILE "$body_str";
              close (MYFILE);   
              print " response \n";  
              my $response =`git reviewmbox '$commitid'`;
              print $response;
            
          }
         
       }


        
}





$dbh->disconnect();
exit 0;
