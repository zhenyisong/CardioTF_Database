# @since 2013-12-26
# @version 1.0
# the previous program is 
#      getWholeName.pl
# the next program is
#     getWholeHumanEntrezID.pl
#
# input file is
# 			mouse_homolog_TF_name.table   ------>getWingenderMouseHomolog.pl
#       gene_gtf_name.table  ---->getWholeName.pl

# the output file is 
#      transfac.name.table
# this is not the final result.
# the final result is manually updated with missed gene name!
# printout is held to search the current gene offical name in mm10 genes.gtf file!
#

use strict;
use FileHandle;

my $tf_table_name        = 'mouse_homolog_TF_name.table';
my $genename_table_name  = 'gene_gtf_name.table';

my $output_table_name    = 'transfac.name.table';
my $output_file_handle   = FileHandle->new(">$output_table_name");



my $tf_array_ref         = getTFname($tf_table_name);
my $genename_hash_ref    = getGeneNameTable($genename_table_name);

my $count = 0;
my $name  = 0;

foreach my $tf_name( @{$tf_array_ref} ) {
	  if(exists $genename_hash_ref->{$tf_name}) {
	  	  $output_file_handle->print("$tf_name\n");
	  	  $name++;
	  }
	  else {
	  	  print " mouse gene $tf_name have no gene.gtf record!\n";
	  	  $count++;
	  }
}
print "there $count TF no name in gene.gtf record!\n";
print "there are $name have name in gene.gtf file!\n";
$output_file_handle->close;


sub getTFname {
	  my $file_name        = shift;
	  my $file_handle      = FileHandle->new($file_name);
	  my $tf_array_ref     = undef;
	  while(my $line = $file_handle->getline) {
	  	  chomp $line;
        push @{$tf_array_ref},$line;
	  }
	  $file_handle->close;
	  return $tf_array_ref;
}


sub getGeneNameTable {
	  my $file_name         = shift;
	  my $file_handle       = FileHandle->new($file_name);
	  my $genename_hash_ref = undef;
	  while(my $line = $file_handle->getline) {
	  	  chomp $line;
	  	  my @buffer = split /\t/,$line;
	  	  $genename_hash_ref->{$buffer[1]}++;
	  }
	  $file_handle->close;
	  return $genename_hash_ref;
}