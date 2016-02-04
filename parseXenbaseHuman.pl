use strict;
use FileHandle;
use File::Find;


my $xBaseHuman_dir    = '../publicData/';
my $input_file1 = 'XenbaseGeneHumanOrthologMapping.txt';
my $input_file2 = 'mouse_human_geneID_name.final.table';
my $output_file = 'frog_human_geneID_name_TF.final.table';

my $output_handle = FileHandle->new(">$output_file");

my $xbaseResult = parseXenBase($xBaseHuman_dir.$input_file1);
my $humanResult = parseHumanTFfinaltable($input_file2);

foreach my $geneID (keys %{$humanResult}) {
	  if(exists $xbaseResult->{$geneID}) {
	  	  $output_handle->print("$geneID\t$humanResult->{$geneID}\t");
	  	  $output_handle->print("$xbaseResult->{$geneID}->[0]\t$xbaseResult->{$geneID}->[1]\t$xbaseResult->{$geneID}->[2]\n");
	  }
}

$output_handle->close;

sub parseXenBase {
	  my $fileName   = shift;
	  my $filehandle = FileHandle->new($fileName);
	  my $result     = undef;
	  while(my $line = $filehandle->getline) {
	  	  chomp $line;
	  	  my @buffer = split/\t/,$line;
	  	  $result->{$buffer[0]} = [$buffer[1],$buffer[2],$buffer[3]];
	  }
	  $filehandle->close;
	  return $result;  
}

sub parseHumanTFfinaltable {
	  my $fileName   = shift;
	  my $filehandle = FileHandle->new($fileName);
	  my $result     = undef;
	  while(my $line = $filehandle->getline) {
	  	  chomp $line;
	  	  my @buffer = split/\t/,$line;
	  	  $result->{$buffer[1]} = $buffer[2];
	  }
	  $filehandle->close;
	  return $result;  
}


