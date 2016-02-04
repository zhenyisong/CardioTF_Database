use strict;
use FileHandle;

my $uniprobe_file = '../publicData/uniprob.annotation';
my $input_handle  = FileHandle->new($uniprobe_file);

my $output_file   = 'unipro_mouse.table';
my $output_handle = FileHandle->new(">$output_file");

while(my $line = $input_handle->getline) {
	  if($line =~ /Mus musculus/) {
	  	  my @array = split(/\s+/,$line);
	  	  $output_handle->print("$array[0]\t$array[1]\n");
	  }
}
$output_handle->close;
$input_handle->close;