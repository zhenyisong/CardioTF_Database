# since 2014-03-10
# Author Yisong Zhen
# pubmed_result_for_functional_elements.xml

use strict;
use warnings;
use File::Find;
use FileHandle;

my $localdir  = '../publicData/pmc_oz';
my $outputdir = 'pmc_oz_abstract/';

my @array;
find( sub { push (@array,$File::Find::name) if /\.nxml$/ },$localdir );


foreach my $file(@array) {
	  my $abstract_in_journal_hash_ref = readNCBIxml($file);
	  
	  foreach my $pmc_id (keys %{$abstract_in_journal_hash_ref}) {
	      my $file_name   = $outputdir.$pmc_id.'.txt';
	      my $file_handle = FileHandle->new(">$file_name");
	      $file_handle->print($abstract_in_journal_hash_ref->{$pmc_id});
	      $file_handle->close; 
    }
}


sub readNCBIxml {
	
   my $file_name                = shift;
   my $file_handle              = FileHandle->new($file_name);
   my $pmcid_abstract_hash_ref  = undef;
   my $pmc_id                   = undef;
   my $text                     = undef;
   my $abstract                 = undef;
   my $state                    = undef;
   

   
   while(my $line = $file_handle->getline) {

   	   if($line =~ /\<article-id pub-id-type=\"pmc\"\>(\d+)\<\//) {
   	   	   $pmc_id = $1;
   	   	   
   	   }
   	   if(defined $pmc_id) {
   	   	    if($line =~ /\<abstract\>(.*?)\<\/abstract\>/) {
   	   	    	  $abstract = $1;
   	   	    	  $abstract  =~ s/\\n//sg;
    	          $abstract  =~ s/<.*?>//sg;
    	          $abstract  =~ s/^\W+//;
    	          $abstract  =~ s/\W+$//;
    	          if(defined $abstract) {
    	          	   $pmcid_abstract_hash_ref->{$pmc_id} = $abstract;
    	          	   $pmc_id = undef; 
   	   	  	         $abstract = undef;
   	   	  	         next;   
    	          }
    	          else {   	   	  	    
    	          	$pmc_id = undef; 
   	   	  	      $abstract = undef;
   	   	  	      next;      	          	  
    	          }
   	   	  	   

   	   	    }
   	   	    if($line =~ /\<abstract\>/) {
   	   	  	    $text .= $line;
   	   	  	    $state = 1;
   	   	    } 
   	   	    if(defined $state) {
   	   	    	  $text .=$line;
   	   	    }
   	   	    if($line =~ /\<\/Abstract\>/) {
   	   	  	    ($abstract) = ($text =~ /\<abstract\>(.*?)\<\/abstract\>/gs);
   	   	  	    $abstract  =~ s/\\n//sg;
    	          $abstract  =~ s/<.*?>//sg;
    	          $abstract  =~ s/^\W+//;
    	          $abstract  =~ s/\W+$//;
    	          if(defined $abstract) {
    	          	  $pmcid_abstract_hash_ref->{$pmc_id} = $abstract;
    	          	  $text    = undef;
   	   	  	        $abstract = undef;
   	   	  	        $pmc_id   = undef;
   	   	  	        $state    = undef;
   	   	  	        next;
    	          }
    	          else {
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
   return $pmcid_abstract_hash_ref
}
