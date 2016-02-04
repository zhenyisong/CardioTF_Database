# http://stackoverflow.com/questions/18041948/lwp-getstore-usage
#
# @input file name
#   
#     MGI database URL define the cardiovascular genes
# @output
#     MGI_CV_genes.html
#      
use LWP::UserAgent;
use FileHandle;
use strict;

my $MGIdatabaseURL   = 'http://www.informatics.jax.org/mp/annotations/MP:0005385';
my $output_filename  = 'MGI_CV_genes.html';
my $html_result      = FileHandle->new(">$output_filename");

my $browser        = LWP::UserAgent->new(from => 'zhenyisong@gmail.com',);
my $result         = $browser->get($MGIdatabaseURL);
die "An error occurred: ", $result->status_line() unless $result->is_success;
$html_result->print($result->content);
$html_result->close;
