use FileHandle;
use strict;

# @ previous program is
#       getCardioGOMouseHomolog.pl
# @input file name
#       cardioGO_UK_mouse_homolog_name.table
# @output file name
#       cardioGO_UK_TFs.final.table


my $cardioGO_filename     = 'cardioGO_UK_mouse_homolog_name.table';
my $TF_homologs_filename  = 'transfac.name.final.table';

my $cardioGO_output_file  = 'cardioGO_UK_TFs.final.table';
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
print "there are $count_TF in cardioGO dataset, well done!\n";



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