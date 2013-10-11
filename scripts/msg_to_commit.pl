#!/usr/bin/perl
use Mail::MboxParser;
#cat 2012-07 | ./searchMatch.pl | ./msg_to_commit.pl
use strict;

open (MYFILE, '/tmp/mailmatch.out');
my @input;
while(my $line = <MYFILE>) {
	push @input, $line;
}

my $line;
my $email;
while (@input) {

	$line = shift @input;
	
	if ($line =~ /^mid;\<(.*?)\>/) {
		my $msgid = $1;
		shift @input;
		$line = shift @input;
		if ($line =~ /^\s*commit: ([0-9a-f]{40})/) {
			my $commitid = $1;
			#print "Id=$msgid\n";
                        #print "commitid=$commit\n";
                        my $parseropts = {
        enable_cache    => 1,
        enable_grep     => 1,
        cache_file_name => 'mail/cache-file',
     };
#foreach my $arg(@ARGV){
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
       #my $sth = $dbh->prepare("SELECT * FROM line where tid='$thisid'");
       #$sth->execute;
       #my $row = $sth->fetchrow_arrayref();
         
       if ($msgid eq $thisid) {
              #print "$msgid -----------------> $thisid\n";
              #my ($tid, $commitid) = @$row;
              open (MYFILE, '> /tmp/data.tmp');
              print  MYFILE "From : $from\n";
              if ( $from =~ /<(.*?)>/ )
		{
  		   $email = $1;
    	          
		}
              print  MYFILE "Message-Id : <$thisid>\n";
              print  MYFILE "Date : $date\n";
              print  MYFILE "Subject: $subject\n";
              if(length($referenceid ne 0)) {
                  
                  print MYFILE "References: $referenceid\n";
                  }

              if(length($replyto ne 0)) {
                 print MYFILE "$replyto\n";
                }        
              print MYFILE "Cc: $cc\n";
              print MYFILE "commit: $commitid\n\n";
              print MYFILE "$body_str";
              close (MYFILE); 
              $subject =~ tr/'/-/;
              if ($from =~ /^[A-z]/  ) {
              my $show =`git reviewmbox '$commitid' '$from' '$date' '$email' '$subject'`;
              print $show;
              }
             

          } 


elsif ( $referenceid =~ /<(.*?)>/ ){
             my $reference = $1;   
             #my $sth = $dbh->prepare("SELECT * FROM line where tid='$reference'");
             #$sth->execute;
             #my $row = $sth->fetchrow_arrayref();       
              if ($msgid eq $reference) {
                #print "$msgid -----------------> $reference\n";
              #  my ($tid, $commitid) = @$row;
                open (MYFILE, '> /tmp/data.tmp');
                print MYFILE "From : $from\n";
                if ( $from =~ /<(.*?)>/ )
		 {
   		   $email = $1;
    		  
		 }
               print MYFILE "Message-Id : <$thisid>\n";
               print MYFILE "Date : $date\n";
               print MYFILE "Subject: $subject\n";
               print MYFILE "$replyto\n";
               print MYFILE "References : $referenceid\n";
               print MYFILE "Cc: $cc\n";
               print MYFILE "commit: $commitid\n\n";
               print MYFILE "$body_str";
               close (MYFILE);
                $subject =~ tr/'/-/;
               if ($from =~ /^[A-z]/ ) {   
               my $response =`git reviewmbox '$commitid' '$from' '$date' '$email' '$subject'`;
               print $response;
               }
              }
       
       }


        
}
}
}
}
