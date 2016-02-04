# @since    2014-03-28
# @Author Yisong Zhen

# extract Journal abbreviation from Pubmed abstract
# output
# pmid journal_name
#


use strict;
use warnings;
use File::Find;
use FileHandle;

my $output_file = 'pmid_journal_name.table';
my $output_handle = FileHandle->new(">$output_file");

my $localdir    = 'cardioSamplepapers';

my @array;
find( sub { push (@array,$File::Find::name) if /\.cardio\.txt$/ },$localdir );


foreach my $file(@array) {
	  my $journal_name_hash_ref = readJournalTitle($file);
	  
	  foreach my $pmc_id (keys %{$journal_name_hash_ref}) {
        $output_handle->print("$pmc_id\t$journal_name_hash_ref->{$pmc_id}\n");
    }
}

$output_handle->close;


sub readJournalTitle {
	 my $file_name                = shift;
   my $file_handle              = FileHandle->new($file_name);
   my $hash_ref                 = undef;
   my $pmc_id                   = undef;
   while(my $line = $file_handle->getline) {
   	     if($line =~ /\<PMID Version=\"1\"\>(\d+)\<\/PMID\>/) {
   	   	       $pmc_id = $1;
   	     }
   	     if(defined $pmc_id) {
   	     	  if($line =~ /\<ISOAbbreviation\>(.*?)\<\/ISOAbbreviation\>/) {
   	     	  	  $hash_ref->{$pmc_id} = $1;
   	     	  	  $pmc_id              = undef;
   	     	  }
   	     }
   }
   $file_handle->close;  
}