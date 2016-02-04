# I updated the mouse_human_geneID_name.final.table manually on 2014-03-26

use strict;
use FileHandle;

#my $file_dir    = '/N/u/shoulab/Mason/genomedata/cardiosignal/publicData/';
my $input_file1 = 'transfac.name.final.table';
#$input_file1    = $file_dir.$input_file1;
my $input_file2 = 'mouse_Human_geneID_geneName.table';
#$input_file2    = $file_dir.$input_file2;

my $output_file   = 'mouse_human_geneID_name.final.table';
my $output_handle = FileHandle->new(">$output_file");

my $mm10 = readMM10final($input_file1);
my $human_mouse = readHumanMousetable($input_file2);

foreach my $tf (keys %{$mm10}) {
	  if(exists $human_mouse->{$tf}) {
	  	  $output_handle->print("$tf\t$human_mouse->{$tf}\n");
	  }
	  else {
	  	  print "your need add this $tf in the final table\n";
	  }
}

$output_handle->close;


sub readMM10final {
	  my $file_name   = shift;
	  my $file_handle = FileHandle->new($file_name);
	  my $hash_ref    = undef;
	  while(my $line  = $file_handle->getline) {
	  	 chomp($line);
	  	 $hash_ref->{$line}++;
		  
	  }
	  $file_handle->close;
	  return $hash_ref;
}

sub readHumanMousetable {
	  my $file_name = shift;
	  my $file_handle = FileHandle->new($file_name);
	  my $hash_ref    = undef;
	  while(my $line = $file_handle->getline) {
	  	  chomp($line);
	  	  my @array = split(/\t/,$line);
	  	  $hash_ref->{$array[3]} = $line;
	  }
	  $file_handle->close;
	  return $hash_ref;
}