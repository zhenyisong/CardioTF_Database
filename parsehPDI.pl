use strict;
use FileHandle;
use File::Find;


my $hPDI_dir    = '../publicData/pwm_hPDI/';
my $input_file1 = 'mouse_human_geneID_name.final.table';
my $output_file = 'human_hPDI.table';

my $output_handle = FileHandle->new(">$output_file");

my $input_handle = FileHandle->new("$input_file1");
my $human_hash_ref = undef;
while(my $line = $input_handle->getline) {
	  chomp($line);
	  my @array = split(/\t/,$line);
	  $human_hash_ref->{$array[2]} = $array[1];
}
$input_handle->close;

my @pwm_array;
find( sub { push (@pwm_array,$File::Find::name) if /\.output$/ },$hPDI_dir);

foreach my $tf_name(@pwm_array) {
	  #print $tf_name,"\n";
	  my ($tf_new) = ($tf_name =~ /publicData\/pwm_hPDI\/(.*?)\.output/);
	  my $state = 0;
	  foreach my $tf(keys %{$human_hash_ref}){
	  	  if(lc($tf_new) eq lc($tf)) {
	  	  	  $state = 1;
	  	  	  $output_handle->print("$tf_new\t$tf\t$human_hash_ref->{$tf}\n");
	  	  }
	  }
	  if($state == 0) {
	  	   print "there are not find\t",$tf_name,"\t$tf_new\n";
	  }
	  
}

$output_handle->close;
