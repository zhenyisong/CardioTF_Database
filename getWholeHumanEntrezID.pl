# @since 2013-12-26
# @version 1.0
# the prevous program is 
#     getWholeMouseTF.pl
# the next program 
#     this is the last program!
# to check is wingender_SwissproID_GeneID.table is most updated Entrez geneID!
#

use strict;
use FileHandle;

my $homo_geneid_dir       = '../publicData/';
my $homo_geneid_filename  = 'Homo_sapiens.gene_info';
$homo_geneid_filename     = $homo_geneid_dir.$homo_geneid_filename;

my $wingender_file        = 'wingender_SwissproID_GeneID.table';

my $output_filename       = 'wingender_SwissproID_GeneName.table';
my $output_filehandle     = FileHandle->new(">$output_filename");


my $wholeHumanGeneIDgeneName_hash_ref = getWholeGeneID($homo_geneid_filename);
my $windenderGeneID_array_ref         = readWingenderID($wingender_file);

foreach my $gene_id(@{$windenderGeneID_array_ref}) {
	  if(exists $wholeHumanGeneIDgeneName_hash_ref->{$gene_id}){
	  	  $output_filehandle->print("$gene_id\t$wholeHumanGeneIDgeneName_hash_ref->{$gene_id}\n");
	  }
	  else {
	  	  print "$gene_id is old, no record in most recent Homo-geneID file!\n";
	  }
}

$output_filehandle->close;



sub getWholeGeneID {
	  my $file_name       = shift;
	  my $result_hash_ref = undef;
	  my $file_handle  = FileHandle->new($file_name);
	  while(my $line = $file_handle->getline) {
	  	  chomp $line;
	  	  if($line =~ /^9606/) {
	  	      my @buffer = split /\t/,$line;
	  	      $result_hash_ref->{$buffer[1]} = $buffer[2];
	  	  }
	  }
	  $file_handle->close;
	  return $result_hash_ref;
}

sub readWingenderID {
	  my $file_name         = shift;
	  my $result_array_ref  = undef;
	  my $file_handle       = FileHandle->new($file_name);
	  
	  while(my $line = $file_handle->getline) {
	  	  chomp $line;
	  	  my @buffer = split/\t/,$line;
	  	  push @{$result_array_ref},$buffer[1];
	  }
	  $file_handle->close;
	  return $result_array_ref; 
}