# @since 2013-12-26
# @version 1.0

# the output is all gene name mentioned in mm10
# gene.gtf file.
# mm10 gene file may contain multiple-gene names in one cloumn, these gene names may be 
# seperated by ','.
#
# the previous program is 
#       getWingenderMouseHomolog.pl
#        or/
#       getCardioGOMouseHomolog.pl
# the next program is 
#      getWholeMouseTF.pl
#      or/
#      getWholeMouseCardioGO_UK.pl
# the required file is
#     mm10 genes.gtf
# the output file is
#     gene_gtf_name.table

use strict;
use FileHandle;



my $ucsc_dir           = '/N/u/shoulab/Mason/genomedata/genome/Mus_musculus/UCSC/mm10/Annotation/Genes/';
my $gene_anno_filename = 'genes.gtf';
$gene_anno_filename    = $ucsc_dir.$gene_anno_filename;
my $output_filename    = 'gene_gtf_name.table';
my $output_filehandle  = FileHandle->new(">$output_filename"); 


my $genenameWhole_hash_ref = getWholeName($gene_anno_filename);

foreach my $genename (keys %{$genenameWhole_hash_ref }) {
	  $output_filehandle->print("$genename\t$genenameWhole_hash_ref->{$genename}\n");
}

$output_filehandle->close;
print "well done\n";


sub getWholeName {
	  my $file_name                 = shift;
	  my $genename_hash_ref         = undef;
	  my $gene_gtf_filehandle       = FileHandle->new($file_name);
	  while(my $line = $gene_gtf_filehandle->getline) {
	  	  if($line =~ /gene_name \"(.*?)\"/) {
	  	  	  my $genename       = uc $1;
	  	  	  $genename_hash_ref->{$genename} = $1;
	  	  }
	  }
	  $gene_gtf_filehandle->close;
	  return $genename_hash_ref;
}