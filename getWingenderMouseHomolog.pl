# @since   2013-12-26
# @update  
# @version 1.0

# @the previous program is 
#     parseHomolog.pl
# @the next program is 
#			getWholeName.pl
#    

# @the required input from is
#     wingender_SwissproID_GeneID.table
#             this file has been already updated to include the GeneID from 
#							wingender_SwissID_NoGeneID.table
#     mouse.geneID.geneName.table
#  
# @the output file is 
#     mouse_homolog_TF_name.table
#        this file contain all Wingender TF mouse homolog gene name, 
#        may not the most recent gene offical name, so should mapping
#        to gene.gtf file from mm10.
# 

use strict;
use FileHandle;

my $wingendder_filename    = 'wingender_SwissproID_GeneID.table';
my $human_mouse_filename   = 'human_mouse.geneID.table';
my $mouse_genename_file    = 'mouse.geneID.geneName.table';
my $human_genename_file    = 'human.geneID.geneName.table';


#
#  output_file
#  Add another output file
#  This is mouse_Human_geneID_geneName.table
#  
#  
my $output_filename            = 'mouse_homolog_TF_name.table';
my $output_filehandle          = FileHandle->new(">$output_filename");

my $output_filename_second     = 'mouse_Human_geneID_geneName.table';
my $output_second_filehandle   = FileHandle->new(">$output_filename_second");

my $wingender_geneid       = getWingerderGeneID($wingendder_filename);
my $human_mouse_id         = getHumanMouseID($human_mouse_filename);
my $mouse_genename         = getMouseGenename($mouse_genename_file);
my $human_genename         = getMouseGenename($human_genename_file);

my $tf_wholename_hash_ref  = undef;
my $homolog_count          = 0;
my $homolog_all_count      = 0;

foreach my $gene_id (@{$wingender_geneid} ) {
	  if(exists $human_mouse_id->{$gene_id}) {
	  	  $homolog_count++;
	  	  foreach my $mouse_id(@{$human_mouse_id->{$gene_id}}){
	  	  	  $output_second_filehandle->print("$gene_id\t$human_genename->{$gene_id}\t$mouse_id\t$mouse_genename->{$mouse_id}\n");
	  	  	  $tf_wholename_hash_ref->{$mouse_genename->{$mouse_id}}++;
	  	  	  if($tf_wholename_hash_ref->{$mouse_genename->{$mouse_id}} >= 2) {
	  	  	  	  print $mouse_id,"\t there are same names\n";
	  	  	  }
	  	  	  $homolog_all_count++;
	  	  }
	  }
}


$output_second_filehandle->close;

my $total_TF_count = 0;
foreach my $tf_name (keys %{$tf_wholename_hash_ref} ) {
	  $output_filehandle->print("$tf_name\n");
}

$output_filehandle->close;
print "there are human $homolog_count TF have counterpart in mouse\n";
print "there are $homolog_all_count TF mouse homolog\n";
print "well done!\n";




sub getWingerderGeneID {
	  my $file_name     = shift;
	  my $gene_id_ref   = undef;
	  my $file_handle   = FileHandle->new($file_name);
	  while(my $line = $file_handle->getline) {
	  	  chomp $line;
	  	  my @buffer = split/\t/,$line;
	  	  push @{$gene_id_ref},$buffer[1];
	  }
	  $file_handle->close;
	  return $gene_id_ref;  
}

sub getHumanMouseID {
	  my $file_name              = shift;
	  my $human_mouse_hash_ref   = undef;
	  my $file_handle            = FileHandle->new($file_name);
	  while(my $line = $file_handle->getline) {
	  	  chomp $line;
	  	  my @buffer = split/\t/,$line;
	  	  push @{$human_mouse_hash_ref->{$buffer[0]}},$buffer[1];
	  }
	  $file_handle->close;
	  return $human_mouse_hash_ref; 
	  
}

sub getMouseGenename {
	  my $file_name              = shift;
	  my $mouse_hash_ref   = undef;
	  my $file_handle            = FileHandle->new($file_name);
	  
	  while(my $line = $file_handle->getline) {
	  	  chomp $line;
	  	  my @buffer = split/\t/,$line;
	  	  $mouse_hash_ref->{$buffer[0]} = $buffer[1];
	  }
	  $file_handle->close;
	  return $mouse_hash_ref; 
}
