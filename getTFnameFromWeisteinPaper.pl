use strict;
use FileHandle;

my $GNAT_result_file = '../../GNAT/weistein_style.GNAT.result';
my $TFs_whole_file   = '../mouse_human_geneID_name.final.table';
my $output_file      = 'weistein_TFs.result';
my $output_handle    = FileHandle->new(">$output_file");

my $GNAT_hash_ref = readGNATresult($GNAT_result_file);
my $TF_whole_ref  = readTFwhole($TFs_whole_file);
my $tf_count      = 0;

foreach my $gene_id  ( keys %{$TF_whole_ref}) {
	  if(exists $GNAT_hash_ref->{$gene_id}) {
	  	  $tf_count++;
	  	  my $gene_number = scalar(@{$GNAT_hash_ref->{$gene_id}});
	  	  $output_handle->print("$gene_id\t$gene_number\t$TF_whole_ref->{$gene_id}\n");
	  }
}
$output_handle->close;
print "there are $tf_count TF in literature!\n";


sub readTFwhole {
	  my $file_name = shift;
	  my $file_handle = FileHandle->new($file_name);
	  my $geneID_ref  = undef;
	  while(my $line = $file_handle->getline) {
	  	  chomp $line;
	  	  my @array = split /\t/,$line;
	  	  $geneID_ref->{$array[3]} = $array[0];
	  	  
	  }
	  $file_handle->close;
	  return $geneID_ref;
}

sub readGNATresult {
	  my $file_name   = shift;
	  my $file_handle = FileHandle->new($file_name);
	  my $geneID_ref  = undef;
	  while(my $line = $file_handle->getline) {
	  	  chomp($line);
	  	  my @array = split/\t/,$line;
	  	  if($array[4] == 10090) {
	  	  	  push @{$geneID_ref->{$array[1]}},$array[0];
	  	  	  
	  	  }
	  }
	  
	  $file_handle->close;
	  return $geneID_ref;
}
