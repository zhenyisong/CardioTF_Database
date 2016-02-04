use strict;
use FileHandle;
use File::Find;


my $xBaseHuman_dir    = '../publicData/';
my $input_file1 = 'BirdBase.txt';
my $input_file2 = 'mouse_human_geneID_name.final.table';
my $input_file3 = 'human_chicken.geneID.table';
my $output_file = 'bird_human_geneID_name_TF.final.table';


my $output_handle = FileHandle->new(">$output_file");

my $xbaseResult = parseBirdBase($xBaseHuman_dir.$input_file1);
my $humanChicken = parseHumanChickenTable($input_file3);
my $humanResult = parseHumanTFfinaltable($input_file2);

foreach my $geneID (keys %{$humanResult}) {
	  if(exists $humanChicken->{$geneID}) {
	  	  if( exists $xbaseResult->{$humanChicken->{$geneID}}) {
	  	      $output_handle->print("$geneID\t$humanResult->{$geneID}\t$humanChicken->{$geneID}\t");
	  	      $output_handle->print("$xbaseResult->{$humanChicken->{$geneID}}->[0]\t$xbaseResult->{$humanChicken->{$geneID}}->[1]\n");
	  	  }
	  }
}

$output_handle->close;

sub parseBirdBase {
	  my $fileName   = shift;
	  my $filehandle = FileHandle->new($fileName);
	  my $result     = undef;
	  while(my $line = $filehandle->getline) {
	  	  chomp $line;
	  	  my @buffer = split/\t/,$line;
	  	  $result->{$buffer[0]} = [$buffer[1],$buffer[2]];
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

sub parseHumanChickenTable {
	  my $fileName   = shift;
	  my $filehandle = FileHandle->new($fileName);
	  my $result     = undef;
	  while(my $line = $filehandle->getline) {
	  	  chomp $line;
	  	  my @buffer = split/\t/,$line;
	  	  $result->{$buffer[0]} = $buffer[1];
	  }
	  $filehandle->close;
	  return $result;  
	  
}


