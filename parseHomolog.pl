# @since   2013-12-26
# @update  2014-03-17
# @version 1.0
# ftp://ftp.ncbi.nih.gov/pub/HomoloGene/README

# @input data
# the required data from NCBI homology data
# the  address is here:
# ftp://ftp.ncbi.nih.gov/pub/HomoloGene/build67/homologene.data
# @previouse program is 
#			parseWingender.pl if you want to generate wigender data
#     or/
#     parseCardioGO_UK.pl
# @the next program
#    getWingenderMouseHomolog.pl if you want to generate wigender data
#    
#			
# @the output file is
#  	human_mouse.geneID.table
#			the first column is human EntrezGeneID and second 
#   	column is its homolog mouse EntrezGeneID
#		mouse.geneID.geneName.table
#   	the first is mouse EntrezGeneID
#   	the second column is Gene Offical Name;

use strict;
use FileHandle;

my $homolog_dir         = '/N/u/shoulab/Mason/genomedata/cardiosignal/publicData/';
my $homolog_filename    = 'homologene.data';
$homolog_filename       = $homolog_dir.$homolog_filename;


# this can be changed to other
#
#
my $output_filename     ='human_frog.geneID.table';
my $output_filehandle   = FileHandle->new(">$output_filename");



my $homolog_result      = getHomologID($homolog_filename);
my $cluster_count       = 0;
my $cluster_mouse_count  = 0;
foreach my $homolo_group_id (keys %{$homolog_result}) {
	  if(exists $homolog_result->{$homolo_group_id}->{'9606'} ) {
	  	  if(scalar @{$homolog_result->{$homolo_group_id}->{'9606'}} >= 2) {
	  	  	 $cluster_count++;
	  	  }
	  	  foreach my $human_id (@{$homolog_result->{$homolo_group_id}->{'9606'}}) {
	  	  	  if(exists $homolog_result->{$homolo_group_id}->{'8364'}) {
	  	  	      if(scalar @{$homolog_result->{$homolo_group_id}->{'8364'}} >= 2) {
	  	  	  	      $cluster_mouse_count++; 
	  	  	      }
	  	  	      foreach my $mouse_id(@{$homolog_result->{$homolo_group_id}->{'8364'}}) {
	  	  	  	      $output_filehandle->print("$human_id\t$mouse_id\n");
	  	  	      }
	  	  	  }
	  	  }
	  }
}

$output_filehandle->close;

print "there are $cluster_count in homology cluster\n";
print "there are $cluster_mouse_count in mouse homology cluster\n";

#
#  you can change the output here
#  mouse.geneID.geneName.table;
my $output_second_filename     = 'frog.geneID.geneName.table';
my $output_second_filehandle   = FileHandle->new(">$output_second_filename");
my $mouse_id_genename_hash_ref = getGeneIDGeneName($homolog_filename);

foreach my $mouse_id (keys %{$mouse_id_genename_hash_ref}) {
	  $output_second_filehandle->print("$mouse_id\t$mouse_id_genename_hash_ref->{$mouse_id}\n");
	  
}
$output_second_filehandle->close;



sub getHomologID {
	  my $file_name          = shift;
	  my $result_hash_ref    = undef;
	  my $file_handle        = FileHandle->new("$file_name");
	  
	  while(my $line = $file_handle->getline) {
	  	  chomp $line;
	  	  my @buffer = split /\t/,$line;
	  	  if($buffer[1] == 9606) {
	  	  	  push @{ $result_hash_ref->{$buffer[0]}->{'9606'} }, $buffer[2];
	  	  }
	  	  if($buffer[1] == 8364) {
	  	  	  push @{ $result_hash_ref->{$buffer[0]}->{'8364'} }, $buffer[2];
	  	  }
	  }
	  
	  $file_handle->close;
	  return $result_hash_ref;
	  
}

#
#  you change the taxomiy ID here to extract corresponding 
#  gene_id gene_name pairs.
#  mouse_taxomy_id = 8364;
#  human_taxomy_id = 9606;
#  zebrafish_taxomy_id = 8364;
#  ciona = 8364
sub getGeneIDGeneName {
	  my $file_name          = shift;
	  my $result_hash_ref    = undef;
	  my $file_handle        = FileHandle->new("$file_name");
	  
	  while(my $line = $file_handle->getline) {
	  	  chomp $line;
	  	  my @buffer = split /\t/,$line;
	  	  if($buffer[1] == 8364) {
	  	  	  $result_hash_ref->{$buffer[2]} = $buffer[3];
	  	  }
	  }
	  
	  $file_handle->close;
	  return $result_hash_ref;
	  
}


