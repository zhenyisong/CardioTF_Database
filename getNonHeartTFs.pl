use strict;
use FileHandle;

my $microarrayTFs = 'cardiac_lineage_TF.result';
my $cardioUKtfs   = 'cardioGO_UK_TFs.final.table';
my $mgiTFs        = 'MGI_TFs.final.table';
my $pubmedTFs     = 'pubmed.TFs.final.table';
my $allTFs        = 'transfac.name.final.table';
my $output_file   = 'non_cardiacTFs.final.table';
my $output_handle = FileHandle->new(">$output_file");

my $microarray_filehandle   = FileHandle->new($microarrayTFs);
my $microarrayTFSs_hash_ref = undef;
while(my $line = $microarray_filehandle->getline) {
	  chomp $line;
	  $microarrayTFSs_hash_ref->{$line}++;
}
$microarray_filehandle->close;

my $cardioUK_filehandle     = FileHandle->new($cardioUKtfs);
my $cardioUK_hash_ref       = undef;
while(my $line = $cardioUK_filehandle ->getline) {
	  chomp $line;
	  $cardioUK_hash_ref->{$line}++;
}
$cardioUK_filehandle->close;


my $mgiTFs_filehandle     = FileHandle->new($mgiTFs);
my $mgiTFs_hash_ref       = undef;
while(my $line = $mgiTFs_filehandle->getline) {
	  chomp $line;
	  $mgiTFs_hash_ref->{$line}++;
}
$mgiTFs_filehandle->close;

my $pubmedTFs_filehandle     = FileHandle->new($pubmedTFs);
my $pubmedTFs_hash_ref       = undef;
while(my $line = $pubmedTFs_filehandle->getline) {
	  chomp $line;
	  $pubmedTFs_hash_ref->{$line}++;
}
$pubmedTFs_filehandle->close;


my $allTFs_filehandle     = FileHandle->new($allTFs);
my $allTFs_hash_ref       = undef;
while(my $line = $allTFs_filehandle->getline) {
	  chomp $line;
	  $allTFs_hash_ref->{$line}++;
}
$allTFs_filehandle->close;

my $non_tf_num = 0;
foreach my $tf (keys %{$allTFs_hash_ref}) {
	  if(!exists $cardioUK_hash_ref->{$tf} &&
	     !exists $mgiTFs_hash_ref->{$tf} &&
	     !exists $pubmedTFs_hash_ref->{$tf} &&
	     !exists $microarrayTFSs_hash_ref->{$tf}) {
	     $output_handle->print("$tf\n");	
	     $non_tf_num++;
	  }
}
$output_handle->close;

print "now, you can read all $non_tf_num NON heart TFs!\n";