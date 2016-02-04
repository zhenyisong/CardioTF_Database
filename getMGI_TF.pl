use FileHandle;
use strict;

# @ previous program is
#       getWholeMouse_MGI_genes.gtf.pl
# @input file name
#       MGI.genes.gtf.name.table
#				transfac.name.final.table
# @output file name
#       MGI_TFs.final.table


my $cardioGO_filename     = 'MGI.genes.gtf.name.table';
my $TF_homologs_filename  = 'transfac.name.final.table';

my $cardioGO_output_file  = 'MGI_TFs.final.table';
my $output_file_handle    = FileHandle->new(">$cardioGO_output_file");

my $count_TF              = 0;

my $cardioGO_hash_ref     = readTFs_final($cardioGO_filename);
my $TFs_hash_ref          = readTFs_final($TF_homologs_filename);

foreach my $gene(keys %{$cardioGO_hash_ref}) {
	  if( exists $TFs_hash_ref->{$gene}) {
	  	  $count_TF++;
	  	  $output_file_handle->print("$gene\n");
	  }
}

$output_file_handle->close;
print "there are $count_TF in MGI dataset, well done!\n";



sub readTFs_final {
	  my $file_name         = shift;
	  my $file_handle       = FileHandle->new($file_name);
	  my $TF_index_hash_ref = undef;
	  while(my $line = $file_handle->getline) {
	  	  chomp $line;
	  	  $TF_index_hash_ref->{$line}++;
	  	  
	  }
	  $file_handle->close;
	  return $TF_index_hash_ref;  
}