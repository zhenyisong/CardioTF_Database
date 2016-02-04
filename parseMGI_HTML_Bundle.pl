use strict;
use FileHandle;
#
#
# @previous program
#    getMGI_CV_genes.pl
# @next program
#    getWholeMouse_MGI_genes_gtf.pl
#
# @input
#    MGI_CV_genes_html_bundle.result
# @output
#    MGI_CV_gene_name_set.result
#
my $gene_file_name              = 'MGI_CV_genes_html_bundle.result';
my $all_MGI_gene_names_hash_ref = readMGI_Bundle_html($gene_file_name);
my $output_MGI_gene_name_set    = 'MGI_CV_gene_name_set.result';
my $output_file_handle          = FileHandle->new(">$output_MGI_gene_name_set");
foreach my $gene_name (keys %{$all_MGI_gene_names_hash_ref}) {
	  $output_file_handle->print("$gene_name\n");
}

$output_file_handle->close;


sub readMGI_Bundle_html {
	  my $file_name         = shift;
	  my $file_handle       = FileHandle->new($file_name);
	  my $MGI_gene_hash_ref = undef;
	  while(my $line = $file_handle->getline) {
	  	  my @buffer;
	  	  @buffer = ($line =~ /<a href='http:\/\/www\.informatics\.jax\.org\/marker\/MGI:\d+'.*?>(.*?)<\/a>/g);
	  	  foreach my $gene_name (@buffer) {
	  	  	  $MGI_gene_hash_ref->{$gene_name}++;
	  	  }
	  }
	  
	  $file_handle->close;
	  return $MGI_gene_hash_ref;
	  
}