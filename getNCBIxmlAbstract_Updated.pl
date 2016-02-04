# @since    2014-03-10
# @update   2014-04-28
# @Author Yisong Zhen
# pubmed_result_for_functional_elements.xml
# find . -type f -name 'whole_weistein_journal_txt*.txt' -exec rm {} \;

use strict;
use warnings;
use File::Find;
use FileHandle;

my $localdir    = 'whole_weistein_journal_xml';
my $outputdir   = 'whole_weistein_journal_txt/';


my @array;
find( sub { push (@array,$File::Find::name) if /\.cardio\.xml$/ },$localdir );


foreach my $file(@array) {
	  readNCBIxml($file,$outputdir);
}

print "you are well-done, finishing weistein-like data processing!\n";


sub readNCBIxml {
	
   my $file_name                = shift;
   my $file_handle              = FileHandle->new($file_name);
   my $output_dir               = shift;
   my $pmcid_abstract_hash_ref  = undef;
   my $pmc_id                   = undef;
   my $text                     = undef;
   my $abstract                 = undef;
   my $state                    = undef;
   

   
   while(my $line = $file_handle->getline) {

   	   if($line =~ /\<PMID Version=\"1\"\>(\d+)\<\/PMID\>/) {
   	   	   $pmc_id = $1;
   	   	   
   	   }
   	   if(defined $pmc_id) {
   	   	    if($line =~ /\<Abstract\>(.*?)\<\/Abstract\>/) {
   	   	    	  $abstract = $1;
   	   	    	  $abstract  =~ s/\\n//sg;
    	          $abstract  =~ s/<.*?>//sg;
   	   	  	    $pmcid_abstract_hash_ref->{$pmc_id} = $abstract;
   	   	  	    $pmc_id = undef; 
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
   	   	  	    ($abstract) = ($text =~ /\<Abstract\>(.*?)\<\/Abstract\>/gs);
   	   	  	    $abstract  =~ s/\\n//sg;
    	          $abstract  =~ s/<.*?>//sg;
    	          
    	          if($abstract eq '') {
    	              $text    = undef;
   	   	  	        $abstract = undef;
   	   	  	        $pmc_id   = undef;
   	   	  	        $state    = undef;
   	   	  	        next;
    	          } else {
    	          	  #$pmcid_abstract_hash_ref->{$pmc_id} = $abstract;
    	          	  my $file_name   = $output_dir.$pmc_id.'.txt';
	                  my $output_file_handle = FileHandle->new(">$file_name");
	                  $output_file_handle->print($abstract);
	                  $output_file_handle->close; 
    	          	  $text    = undef;
   	   	  	        $abstract = undef;
   	   	  	        $pmc_id   = undef;
   	   	  	        $state    = undef;
   	   	  	        next;
    	          }
    	          
   	   	  	    

   	   	    } 
   	   }
   }
   
   $file_handle->close;
}


