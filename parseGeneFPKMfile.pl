use strict;
use FileHandle;

#
# original input gene FPKM file is from Ren-Bing lab,
# contain 13 tissues from adult mouse. This script is to
# process this genes.fpmk_tracking data to transfer the 
# formatted result to R script.
#  adult_tissue_out

my $gene_fpkm_filename                 = 'genes.fpkm_tracking';
my $whole_TF_table_filename            = 'transfac.name.final.table';

my $output_renbing_fpkm_filename       = 'heart_tissue_TF_FPKM.table';
my $output_handle                      = FileHandle->new(">$output_renbing_fpkm_filename");

my $gene_fpkm_hash_ref                 = readGeneFPKM($gene_fpkm_filename);
my $whole_TF_array_ref                 = readWholeTFtable($whole_TF_table_filename);

foreach my $tf_name (@{$whole_TF_array_ref}) {
	  if(exists $gene_fpkm_hash_ref->{$tf_name} && defined $gene_fpkm_hash_ref->{$tf_name}) {
	      my $array_ref = $gene_fpkm_hash_ref->{$tf_name};
	      $output_handle->print($tf_name);
	      foreach my $fpkm ( @{$array_ref} ) {
	  	      $output_handle->print("\t$fpkm");
	      }
	      $output_handle->print("\n");
	  
	  }
	  
}
$output_handle->close;

print "well done!\n";

sub readGeneFPKM {
	   my $file_name         = shift;
	   my $file_handle       = FileHandle->new("$file_name");
	   my $result_hash_ref   = undef;
	   
	   while(my $line = $file_handle->getline) {
	   	    chomp $line;
	   	    my @buffer     = split /\t/,$line;
	   	    my @gene_names = split /,/,$buffer[4];
	   	    foreach my $gene(@gene_names) {
	   	        $result_hash_ref->{$gene} = [ $buffer[9],$buffer[13],$buffer[17],$buffer[21],
	   	                                       $buffer[25],$buffer[29],$buffer[33],$buffer[37],
	   	                                       $buffer[41],$buffer[45],$buffer[49],$buffer[53],
	   	                                       $buffer[57] ];
	   	                                       
          }
	   }
	   
	   $file_handle->close;
	   return $result_hash_ref;
}

sub readWholeTFtable {
		 my $file_name         = shift;
	   my $file_handle       = FileHandle->new("$file_name");
	   my $result_array_ref  = undef;
	   
	   while(my $line = $file_handle->getline) {
	   	    chomp $line;
	   	    push @{ $result_array_ref }, $line;
	   	    
	  }
	  $file_handle->close;
	  return $result_array_ref;
}