use strict;
use FileHandle;
use File::Find;

my $uniprobe_dir = '../publicData/uniprobe_All_PWMs/';
my $input_file1  = 'unipro_mouse.table';
my $input_file2  = 'mouse_human_geneID_name.final.table';

my $output_file  = 'uniprobe_mm10.table';
my $output_handle = FileHandle->new(">$output_file");

my @uniprobe_array;
find( sub { push (@uniprobe_array,$File::Find::name) if /\.pwm$/ || /\.txt$/ },$uniprobe_dir);


my $input_handle1   = FileHandle->new($input_file1);
my $unipro_hash_ref = undef;
while(my $line = $input_handle1->getline) {
	  chomp($line);
	  my @array = split(/\t/,$line);
	  $unipro_hash_ref->{$array[1]} = $array[0];
}

$input_handle1->close;

my $input_handle2        = FileHandle->new($input_file2);
my $mouse_human_hash_ref = undef;
while(my $line = $input_handle2->getline) {
	  chomp($line);
	  my @array = split(/\t/,$line);
	  $mouse_human_hash_ref->{$array[0]} = $array[3]; 
}

$input_handle2->close;

foreach my $probe_id (keys %{$unipro_hash_ref}) {
	  my $state = 0;
	  foreach my $tf_name (keys %{$mouse_human_hash_ref}) {
	  	  if(lc($unipro_hash_ref->{$probe_id}) eq lc($tf_name)) {
	  	  	    foreach my $file_name (@uniprobe_array) {
	  	  	    	  my ($tf_file_name)  = ($file_name =~ /uniprobe_All_PWMs\/.*\/(.*?)_.*\./);
	  	  	    	  my ($tf_file2_name) = ($file_name =~ /uniprobe_All_PWMs\/.*\/(.*?)\./);
	  	  	    	  #print "howho $tf_file_name\n";
	  	  	    	  if(lc($tf_name) eq lc($tf_file_name) ) {
	  	  	    	  	  $output_handle->print("$probe_id\t$tf_name\t$mouse_human_hash_ref->{$tf_name}\t$file_name\n");
	  	  	    	  	  $state = 1;
	  	  	    	  	  
	  	  	    	  } elsif (lc($tf_name) eq lc($tf_file2_name)) {
	  	  	    	  	  $output_handle->print("$probe_id\t$tf_name\t$mouse_human_hash_ref->{$tf_name}\t$file_name\n");
	  	  	    	  	  $state = 1;
	  	  	    	  }
	  	  	    }
	  	  }
	  }
	  if($state == 0) {
	  	  my $probe_state = 0;
	  	  foreach my $file_name (@uniprobe_array) {
	  	      my ($tf_file_name)  = ($file_name =~ /uniprobe_All_PWMs\/.*\/(.*?)_.*\./);
	  	  	  my ($tf_file2_name) = ($file_name =~ /uniprobe_All_PWMs\/.*\/(.*?)\./);
	  	  	  if(lc($unipro_hash_ref->{$probe_id}) eq lc($tf_file_name)){
	  	  	  	  print "$probe_id\t$unipro_hash_ref->{$probe_id}\t$file_name\n";
	  	  	  	  $probe_state = 1;
	  	  	  } elsif (lc($unipro_hash_ref->{$probe_id}) eq lc($tf_file2_name)) {
	  	  	  	  print "$probe_id\t$unipro_hash_ref->{$probe_id}\t$file_name\n";
	  	  	  	  $probe_state = 1;
	  	  	  }
	  	  }
	  	  if($probe_state == 0) {
	  	  	 print " your should recheck $probe_id\n";
	  	  }
	  }
}

$output_handle->close;