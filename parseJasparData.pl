use strict;
use FileHandle;

my $input_file    = '../publicData/jaspar.taxonomy';

my $output_file   = 'jaspar_id_taxonomy.table';
my $output_handle = FileHandle->new(">$outpuft_ile");

my $jaspar_handle = FileHandle->new($input_file);
while(my $line = $jaspar_handle->getline) {
	  $line =~ s/^\W+//;
	  #print $line,"\n";
	  if($line =~ /MA\d+/) {
	  	  my @array = split/\s+/,$line;
	  	  $output_handle->print("$array[0]\t$array[1]\t$array[2]\n");
	  }
}

$jaspar_handle->close;
$output_handle->close;