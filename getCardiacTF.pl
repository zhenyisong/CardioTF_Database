use strict;
use FileHandle;

#
# the input file is at the first part
# the output file contain the heart lineage TF
#     conservative calculation
#  		cardiac_lineage_TF.result
#


#--------- -------------------------------------------------------------------------------
#  input file: 
#  	 the file to parse 
#--------- -------------------------------------------------------------------------------

my $cardiogeomics_filename        = 'cardiogenomics.data';
my $boyer_filename                = 'boyer.data';
my $renbing_adult_filename        = 'renbing_adult.data';
my $renbing_embryonic_filename    = 'renbing_embryonic.data';
my $pnas_adult_filename           = 'PNAS_adult.data';
my $cardiacTF_whole_filename      = 'transfac.name.final.table';

#--------- -------------------------------------------------------------------------------
## generate file handle here
#--------- -------------------------------------------------------------------------------

my $boyer_genename_hash_ref       =  readRNA_seqNamedata($boyer_filename);
my $renbing_adult_hash_ref        =  readRNA_seqNamedata($renbing_adult_filename);
my $renbing_embryonic_hash_ref    =  readRNA_seqNamedata($renbing_embryonic_filename);
my $pnas_adult_hash_ref           =  readRNA_seqNamedata($pnas_adult_filename);
my $cardicTF_whole_hash_ref       =  readCardiacTFNameSet($cardiacTF_whole_filename);
my $cardiogenomics_hash_ref       =  readCardiogenomics($cardiogeomics_filename);


my $cardiacTF_count               = 0;
my $non_cardiacTF_count           = 0;

#--------- -------------------------------------------------------------------------------
# output file
#--------- -------------------------------------------------------------------------------
my $output_filename               = 'cardiac_lineage_TF.result';
my $output_filehandle             = FileHandle->new(">$output_filename");

my $heart_TF_name_hash_ref        = undef;
foreach my $symbol (keys %{$cardicTF_whole_hash_ref }) {
	  if( exists $boyer_genename_hash_ref->{$symbol} &&
	      exists $renbing_adult_hash_ref->{$symbol} &&
	      exists $renbing_embryonic_hash_ref->{$symbol} &&
	      exists $pnas_adult_hash_ref->{$symbol}) {
	      $cardiacTF_count++;
	      $heart_TF_name_hash_ref->{$symbol}++;
	     	
	  } else {
	  	  #print $symbol,"\n";
	  	  $non_cardiacTF_count++;
	  }
}

foreach my $genename (keys %{$heart_TF_name_hash_ref}) { 
	  $output_filehandle->print("$genename\n");
}
$output_filehandle->close;

my $no_heart_TFs_ref     = undef;
my $no_heart_count       = 0;
foreach my $symbol (keys %{$cardicTF_whole_hash_ref }) {
	  if( ! exists $boyer_genename_hash_ref->{$symbol} &&
	      ! exists $renbing_adult_hash_ref->{$symbol} &&
	      ! exists $renbing_embryonic_hash_ref->{$symbol} &&
	      ! exists $pnas_adult_hash_ref->{$symbol}) {
	      $no_heart_count++;
	    $no_heart_TFs_ref->{$symbol}++;}
}

print "there are $no_heart_count expressed in heart tissue at different stages!\n";

#foreach my $cardio_gene(keys %{$cardiogenomics_hash_ref}) {
#	  if( !exists $heart_TF_name_hash_ref->{$cardio_gene}
#	  	 && exists $cardicTF_whole_hash_ref->{$cardio_gene}) {
#	  	  print "$cardio_gene not in the RNA-seq data!\n";
#	  }
#}
#
#foreach my $cardio_gene(keys %{$heart_TF_name_hash_ref}) {
#	  if( !exists $cardiogenomics_hash_ref->{$cardio_gene}) {
#	  	  print "$cardio_gene not in the cardiogenomics data!\n";
#	  }
#}
#
print "there are $cardiacTF_count heart TF\n";
print "there are $non_cardiacTF_count non heart TFs\n";


sub readRNA_seqNamedata {
	  my $file_name          = shift;
	  my $genename_hash_ref  = undef;
	  my $file_handle        = FileHandle->new($file_name);
	  
	  while(my $line = $file_handle->getline) {
	  	  chomp $line;
	  	  my ($gene_cluster) = ($line =~ /\"(.*?)\"/);
	  	  my @gene_names   = split/,/,$gene_cluster;
	  	  foreach my $gene_name(@gene_names) {
	  	  	  $genename_hash_ref->{$gene_name}++;
	  	  }
	  }
	  $file_handle->close;
	  return $genename_hash_ref;
}

sub readCardiacTFNameSet {
	  my $file_name          = shift;
	  my $genename_hash_ref  = undef;
	  my $file_handle        = FileHandle->new($file_name);
	  
	  while(my $line = $file_handle->getline) {
	  	  chomp $line;
	  	  $genename_hash_ref->{$line}++;
	  }
	  
	  $file_handle->close;
	  return $genename_hash_ref;
}

sub readCardiogenomics {
		my $file_name          = shift;
	  my $genename_hash_ref  = undef;
	  my $file_handle        = FileHandle->new($file_name);
	  while(my $line = $file_handle->getline) {
	  	  chomp $line;
	  	  my @buffer = ($line =~ /\"(.*?)\"/g);
	  	  foreach my $gene_name(@buffer) {
	  	  	  $genename_hash_ref->{$gene_name}++;
	  	  }
	  }
	  $file_handle->close;
	  return $genename_hash_ref;
}
