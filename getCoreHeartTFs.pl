use strict;
use FileHandle;

my $microarrayTFs = 'cardiac_lineage_TF.result';
my $cardioUKtfs   = 'cardioGO_UK_TFs.final.table';
my $mgiTFs        = 'MGI_TFs.final.table';
my $pubmedTFs     = 'weistein_TFs.result';
my $all_TFs       = 'transfac.name.final.table';
my $output_file   = 'cardiacCoreTFs.final.table';
my $output_file1  = 'NoHeartTFs.table';
my $output_handle = FileHandle->new(">$output_file");
my $output_handle1 = FileHandle->new(">$output_file1");

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
	  my @buffer = split/\t/,$line;
	  $pubmedTFs_hash_ref->{$buffer[2]}++;
}
$pubmedTFs_filehandle->close;

my $all_TFs_filehandle       = FileHandle->new($all_TFs);
my $all_TFs_hash_ref         = undef;
while(my $line = $all_TFs_filehandle->getline) {
	   chomp $line;
	   $all_TFs_hash_ref->{$line}++;
}
$all_TFs_filehandle->close;

foreach my $tf (keys %{$microarrayTFSs_hash_ref}) {
	  if(exists $cardioUK_hash_ref->{$tf} &&
	     exists $mgiTFs_hash_ref->{$tf} &&
	     exists $pubmedTFs_hash_ref->{$tf}) {
	     $output_handle->print("$tf\n");	
	  }
}
$output_handle->close;

foreach my $tf (keys %{$all_TFs_hash_ref}) {
	  if(!exists $cardioUK_hash_ref->{$tf} &&
	     !exists $mgiTFs_hash_ref->{$tf} &&
	     !exists $pubmedTFs_hash_ref->{$tf} &&
	     !exists $microarrayTFSs_hash_ref->{$tf}) {
	     $output_handle1->print("$tf\n");	
	  }
}
$output_handle1->close;

print "now, you can read all core heart TFs!\n";