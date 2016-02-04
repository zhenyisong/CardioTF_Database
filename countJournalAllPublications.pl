# @since    2016-10-17
# @update   2016-10-17
# @Author Yisong Zhen
# This script is to find all publications of a journal
# the output was sent to normarlize the cardiac pulication rate of a journal
# This program is adapted from 
# getNCBIxmlAbstract_Updated.pl 

use strict;
use warnings;
use File::Find;
use FileHandle;
use List::Util qw(first max maxstr min minstr reduce shuffle sum);


my $working_dir = '/home/zhenyisong/learning_heart/learning_again';
chdir $working_dir;


my $journal_index_filename = 'cardio_journal_index';
my $journal_index_hash     = readJournalIndex($journal_index_filename);
my $localdir               = 'whole_weistein_journal_xml';
my $output_file            = 'journal_publication_count';
my $output_handle          = FileHandle->new(">$output_file");


my @array;
find( sub { push (@array,$File::Find::name) if /\.cardio\.xml$/ },$localdir );


foreach my $file(@array) {
      my ($j_index)            = ($file =~ /(\d+)/);
      #print $j_index,"\n";
	  my ($count,$interval)    = readNCBIxml($file);
      #print "count is $count\n";
      #print "interval is $interval\n";
      my $journal_name         = $journal_index_hash->{$j_index};
      $output_handle->print($journal_name);
      $output_handle->print("\t");
      $output_handle->print($j_index);
      $output_handle->print("\t");
      $output_handle->print($count);
      $output_handle->print("\t");
      $output_handle->print($interval);
      $output_handle->print("\n");
}

$output_handle->close;

print "you are well-done, finishing counting the journal number!\n";


sub readJournalIndex {
    my $file_name   = shift;
    my $file_handle = FileHandle->new($file_name);
    my $result      = undef;
    while(my $line = $file_handle->getline) {
        chomp $line;
        my ($journal_name, $j_index) = split(/\t/, $line);
        $result->{$j_index}          = $journal_name;  
    }
    $file_handle->close;
    return $result;
}


sub readNCBIxml {
	
   my $file_name                = shift;
   my $file_handle              = FileHandle->new($file_name);
   my $output_dir               = shift;
   my $pmcid_abstract_hash_ref  = undef;
   my $pmc_id                   = undef;
   my $text                     = undef;
   my $abstract                 = undef;
   my $state                    = undef;

   my $journal_num              = 0;
   my @time_interval            = ();
 

   
   while(my $line = $file_handle->getline) {
       my $year_state = 0;
       if($line =~ /<DateCreated>/) {
           $year_state = 1;
       }
       if($line =~ /<\/DateCreated>/) {
           $year_state = 0; 
       }
       if($year_state && $line =~ /<Year>(\d{4})<\/Year>/) {
           push @time_interval,$1;
           $year_state = 0;
       }
       

   	   if($line =~ /\<PMID Version=\"1\"\>(\d+)\<\/PMID\>/) {
   	   	   $pmc_id = $1;
   	   	   
   	   }
   	   if(defined $pmc_id) {
   	   	    if($line =~ /\<Abstract\>(.*?)\<\/Abstract\>/) {
   	   	    	  $abstract  = $1;
   	   	    	  $abstract  =~ s/\\n//sg;
    	          $abstract  =~ s/<.*?>//sg;
   	   	  	      $pmcid_abstract_hash_ref->{$pmc_id} = $abstract;
   	   	  	      $pmc_id   = undef; 
   	   	  	      $abstract = undef;
   	   	  	      next;   
   	   	    }
   	   	    if($line =~ /\<Abstract\>/) {
   	   	  	    $text .= $line;
   	   	  	    $state = 1;
   	   	    } 
   	   	    if(defined $state) {
   	   	    	  $text .=$line;
   	   	    }
   	   	    if($line =~ /\<\/Abstract\>/) {
   	   	  	    #print $text,"iooio\n";
   	   	  	     ($abstract)   = ($text =~ /\<Abstract\>(.*?)\<\/Abstract\>/gs);
   	   	  	      $abstract    =~ s/\\n//sg;
    	          $abstract    =~ s/<.*?>//sg;
    	          
    	          if($abstract eq '') {
    	              $text     = undef;
   	   	  	          $abstract = undef;
   	   	  	          $pmc_id   = undef;
   	   	  	          $state    = undef;
   	   	  	          next;
    	          } else {
    	          	  #$pmcid_abstract_hash_ref->{$pmc_id} = $abstract;
    	          	  #my $file_name   = $output_dir.$pmc_id.'.txt';
	                  #my $output_file_handle = FileHandle->new(">$file_name");
	                  #$output_file_handle->print($abstract);
	                  #$output_file_handle->close;
                      $journal_num++; 
    	          	  $text        = undef;
   	   	  	          $abstract    = undef;
   	   	  	          $pmc_id      = undef;
   	   	  	          $state       = undef;
   	   	  	          next;
    	          }
    	          
   	   	  	    

   	   	    } 
   	   }
   }
   my $interval = 0;
   if(scalar @time_interval != 0 ){
       my $max      = max @time_interval;
       my $min      = min @time_interval;
       $interval = $max - $min;
   }
   $file_handle->close;
   return ($journal_num, $interval);
}


