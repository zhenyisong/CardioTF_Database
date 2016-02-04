use FileHandle;
use strict;

my $abstract_2008 = 'cardioSample/2008.cardio.txt';
my $abstract_2009 = 'cardioSample/2009.cardio.txt';
my $abstract_2010 = 'cardioSample/2010.cardio.txt';
my $abstract_2011 = 'cardioSample/2011.cardio.txt';
my $abstract_2012 = 'cardioSample/2012.cardio.txt';
my $abstract_2013 = 'cardioSample/2013.cardio.txt';

my $hash_ref_2008 = readNCBIxml($abstract_2008);
my $hash_ref_2009 = readNCBIxml($abstract_2009);
my $hash_ref_2010 = readNCBIxml($abstract_2010);
my $hash_ref_2011 = readNCBIxml($abstract_2011);
my $hash_ref_2012 = readNCBIxml($abstract_2012);
my $hash_ref_2013 = readNCBIxml($abstract_2013);

my $journal_name_counter_ref = undef;


my $pmid_list_ref     = readPMIDlist('weistein_like.sample.pmid.list');
my $output_filehandle = FileHandle->new(">cardio_journal_distribution");


foreach my $pmid (@{$pmid_list_ref}) {
	 if(exists $hash_ref_2008->{$pmid} ){
	 	  $journal_name_counter_ref->{$hash_ref_2008->{$pmid}}++;
	 } elsif(exists $hash_ref_2009->{$pmid}) {
	 	  $journal_name_counter_ref->{$hash_ref_2009->{$pmid}}++;
	 } elsif(exists $hash_ref_2010->{$pmid}) {
	 	  $journal_name_counter_ref->{$hash_ref_2010->{$pmid}}++;
	 } elsif(exists $hash_ref_2011->{$pmid}) {
	 	  $journal_name_counter_ref->{$hash_ref_2011->{$pmid}}++;
	 } elsif(exists $hash_ref_2012->{$pmid}){
	 	  $journal_name_counter_ref->{$hash_ref_2012->{$pmid}}++;
	 } elsif(exists $hash_ref_2013->{$pmid}) {
	 	  $journal_name_counter_ref->{$hash_ref_2013->{$pmid}}++;
	 } 
}

foreach my $journal_name(keys %{$journal_name_counter_ref}) {
	  $output_filehandle->print("$journal_name\t$journal_name_counter_ref->{$journal_name}\n");
}

$output_filehandle->close;
print "well done!\n";



sub readPMIDlist {
	  my $file_name    = shift;
	  my $file_handle  = FileHandle->new($file_name);
	  my $id_array_ref = undef;
	  
	  while(my $line = $file_handle->getline) {
	  	  if($line =~ /\/(\d+)\.txt$/) {
	  	  	  push @{$id_array_ref},$1;
	  	  }
	  }
	  $file_handle->close;
	  return $id_array_ref;
}

sub readNCBIxml {
	
   my $file_name                = shift;
   my $file_handle              = FileHandle->new($file_name);
   my $output_dir               = shift;
   my $pmcid_journal_hash_ref   = undef;
   my $pmc_id                   = undef;
   my $journal                  = undef;

   

   
   while(my $line = $file_handle->getline) {

   	   if($line =~ /\<PMID Version=\"1\"\>(\d+)\<\/PMID\>/) {
   	   	   $pmc_id = $1;
   	   	   
   	   }
   	   if(defined $pmc_id) {
   	   	    if($line =~ /\<ISOAbbreviation\>(.*?)\<\/ISOAbbreviation\>/) {
   	   	    	  $journal = $1;
   	   	    	  $journal  =~ s/\.//sg;
    	          $journal  = uc($journal);
   	   	  	    $pmcid_journal_hash_ref->{$pmc_id} = $journal;
   	   	  	    $pmc_id  = undef; 
   	   	  	    $journal = undef;
   	   	  	    next;   
   	   	    }
   	   }
   }
   
   $file_handle->close;
   return $pmcid_journal_hash_ref;
}