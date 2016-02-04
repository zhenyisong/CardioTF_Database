# next program
# measurePerformance.pl
use Algorithm::NaiveBayes;
use Lingua::EN::Splitter qw(words);
use Lingua::EN::StopWords qw(%StopWords);
use strict;
use FileHandle;
use File::Find;

# positive_training_data = 764;
# negative_training_data = 764;
# negative_test_data     = 190

my $training_dir1  = 'negative_training_data';
my $training_dir2  = 'positive_training_data';
my $test_dir1      = 'negative_test_data';
my $test_dir2      = 'positive_test_data';

my $output_predictions  = FileHandle->new(">test.predictions");
my $output_labels       = FileHandle->new(">test.labels");

my @training_array;
find( sub { push (@training_array,$File::Find::name) if /\.txt$/ },$training_dir1);
find( sub { push (@training_array,$File::Find::name) if /\.txt$/ },$training_dir2);



my @test_array;
find( sub { push (@test_array,$File::Find::name) if /\.txt$/ },$test_dir1);
find( sub { push (@test_array,$File::Find::name) if /\.txt$/ },$test_dir2);


my $categorizer = Algorithm::NaiveBayes->new;

foreach my $i (0..$#training_array) {
	  #print $training_array[$i],"\n";
    my $string        = getAbstractString($training_array[$i]);
	  my $abstract_hash = invert_string($string);
	  if($training_array[$i] =~ /weistein/) {
	      $categorizer->add_instance( attributes => $abstract_hash,
                                        label => 'positive' );
	  } else {

	      $categorizer->add_instance( attributes => $abstract_hash,
                                        label => 'negative' );
	  }
	  
}
$categorizer->train;

foreach my $i (0..$#test_array) {
	  #print "$test_array[$i]\n";
	  my $string        = getAbstractString($test_array[$i]);
	  my $abstract_hash = invert_string($string);
	  my $probs = $categorizer->predict( attributes => $abstract_hash );
	  if($probs->{'positive'} >= 1) {
	  	  $output_predictions->print("P\n");
	  }
	  else {
	  	  $output_predictions->print("N\n");
	  }
	  if($test_array[$i] =~ /weistein/) {
		    $output_labels->print("P\n");
	  }
	  else {
		    $output_labels->print("N\n");
	  }
}

$output_predictions->close;
$output_labels->close;
print "complete measuring the performance of machine learning!\n";

sub getAbstractString {
	   my $file_name      = shift;
	   my $file_handle    = FileHandle->new($file_name);
	   my $abstractString = undef;
	   while(my $line = $file_handle->getline) {
	   	  $abstractString .= $line;
	   }
	   $file_handle->close;
	   $abstractString =~ s/\\n//gs;
	   return $abstractString;
}




sub invert_string {
    my ($string, $weight, $hash) = @_;
    my @buffer = grep { !$StopWords{$_} }@{ words(lc($string))};
    foreach my $w (@buffer) {
        $hash->{$w}++;
    }
    return $hash;
}