# http://stackoverflow.com/questions/18041948/lwp-getstore-usage
#
# @input file name
#   MGI_CV_genes.html ---> from getMGIcardiovascularGenes.pl
# 
# @output
#     MGI_CV_genes_html_bundle.result
# @previous program
#     getMGIcardiovascularGenes.pl
# @next program
#     parseMGI_HTML_Bundle.pl
#      
use LWP::UserAgent;
use strict;
use FileHandle;

my $MGI_html_file_name  = 'MGI_CV_genes.html';
my $MGI_html_bundle     = 'MGI_CV_genes_html_bundle.result';
my $output_filehandle   = FileHandle->new(">$MGI_html_bundle");

my $result_html_address = readMGIhtml($MGI_html_file_name);

my $count_url = 0;

foreach my $url(keys %{$result_html_address}) {
	  my $MGIdatabaseURL   = $url;
	  print $MGIdatabaseURL ,"\n";
	  my $browser        = LWP::UserAgent->new(from => 'zhenyisong@gmail.com',);
    my $result         = $browser->get($MGIdatabaseURL);
    die "An error occurred: ", $result->status_line() unless $result->is_success;
    $output_filehandle->print($result->content);
	  $count_url++;
}

$output_filehandle->close;
print "there are $count_url in cardiovascular genes in MGI\n";

sub readMGIhtml {
	  my $file_name     = shift;
	  my $file_handle   = FileHandle->new($file_name);
	  my $url_hash_ref  = undef;
	  while(my $line = $file_handle->getline) {
	  	my @buffer;
	  	@buffer = ($line =~ /http:\/\/www\.informatics\.jax\.org\/allele\/MGI:\d+/g);
	  	foreach my $url (@buffer) {
	  		  $url_hash_ref->{$url}++;
	  	}
	  }
	  $file_handle->close;
	  return $url_hash_ref;
}

