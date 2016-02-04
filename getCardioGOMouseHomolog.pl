# @since 2014-02-08
# @version 1.0

# the previous program is 
#     parseHomolog.pl
# the next program is 
#			getWholeName.pl
#    

# the required input from is
#     cardioGO_UK_SwissproID_GeneID.table
#							the above file has already been manually edited and have full of EntrezGeneID 
#							with their corresponding swiss-pro primary keys.
#     mouse.geneID.geneName.table
#             this file is from the program parseHomoog.pl
#  
# the output file is 
#     cardioGO_UK_mouse_homolog_name.table
#        this file contain all CardioGO_UK mouse homolog gene name, 
#        may not the most recent gene offical name, so should mapping
#        to gene.gtf file from mm10.
# 

use strict;
use FileHandle;

my $wingendder_filename    = 'cardioGO_UK_SwissproID_GeneID.table';
my $human_mouse_filename   = 'human_mouse.geneID.table';
my $mouse_genename_file    = 'mouse.geneID.geneName.table';

my $output_filename        = 'cardioGO_UK_mouse_homolog_name.table';
my $output_filehandle      = FileHandle->new(">$output_filename");

my $wingender_geneid       = getWingerderGeneID($wingendder_filename);
my $human_mouse_id         = getHumanMouseID($human_mouse_filename);
my $mouse_genename         = getMouseGenename($mouse_genename_file);

my $tf_wholename_hash_ref  = undef;
my $homolog_count          = 0;
my $homolog_all_count      = 0;

foreach my $gene_id (@{$wingender_geneid} ) {
	  if(exists $human_mouse_id->{$gene_id}) {
	  	  $homolog_count++;
	  	  foreach my $mouse_id(@{$human_mouse_id->{$gene_id}}){
	  	  	  $tf_wholename_hash_ref->{$mouse_genename->{$mouse_id}}++;
	  	  	  if($tf_wholename_hash_ref->{$mouse_genename->{$mouse_id}} >= 2) {
	  	  	  	  print $mouse_id,"\t there are same names\n";
	  	  	  }
	  	  	  $homolog_all_count++;
	  	  }
	  }
}

my $total_TF_count = 0;
foreach my $tf_name (keys %{$tf_wholename_hash_ref} ) {
	  $output_filehandle->print("$tf_name\n");
}

$output_filehandle->close;
print "there are human $homolog_count CardioGO_UK proteins have counterpart in mouse\n";
print "there are $homolog_all_count  mouse homolog of CardioGO_UK proteins\n";
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
	  my $mouse_hash_ref         = undef;
	  my $file_handle            = FileHandle->new($file_name);
	  
	  while(my $line = $file_handle->getline) {
	  	  chomp $line;
	  	  my @buffer = split/\t/,$line;
	  	  $mouse_hash_ref->{$buffer[0]} = $buffer[1];
	  }
	  $file_handle->close;
	  return $mouse_hash_ref; 
}
