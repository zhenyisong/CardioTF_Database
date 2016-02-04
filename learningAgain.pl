# next program
# measurePerformance.pl
use Algorithm::NaiveBayes;
use Lingua::EN::Splitter qw(words);
use Lingua::EN::StopWords qw(%StopWords);
use strict;
use FileHandle;
use File::Find;

# positive_training_data = 764;
# negative_training_data = 45664;
# 45664 + 764 = 46428
# 46428/2     = 23214

my $training_dir1  = 'negative_training_data';
my $training_dir2  = 'positive_training_data';
my $predictions    = undef;
my $labels				 = undef;
my $output_predictions = FileHandle->new(">output.predictions");
my $output_labels       = FileHandle->new(">output.labels");

my @training_array;
find( sub { push (@training_array,$File::Find::name) if /\.txt$/ },$training_dir1);
find( sub { push (@training_array,$File::Find::name) if /\.txt$/ },$training_dir2);

#print $#training_array,"\n";

#exit(0);

#print $#training_array,"\t all array files\n";

foreach my $i (0..4) {
	  fisher_yates_shuffle(\@training_array);
		my $categorizer1 = Algorithm::NaiveBayes->new;
		foreach my $j (0..23213) {
		    my $string        = getAbstractString($training_array[$j]);
	      my $abstract_hash = invert_string($string);
	      if($training_array[$j] =~ /weistein/) {
	          $categorizer1->add_instance( attributes => $abstract_hash,
                                        label => 'positive' );
	      } else {

	      	  $categorizer1->add_instance( attributes => $abstract_hash,
                                        label => 'negative' );
	      }
		}
		$categorizer1->train;
		foreach my $j (23214..46427) {
		    my $string        = getAbstractString($training_array[$j]);
	      my $abstract_hash = invert_string($string);
	      my $probs = $categorizer1->predict( attributes => $abstract_hash );
	      push @{$predictions->{$i*2 + 1}},$probs->{'positive'};
	      if($training_array[$j] =~ /weistein/) {
	          push @{$labels->{$i*2 + 1}},'P'; 
	      }
	      else {
	      	  push @{$labels->{$i*2 + 1}},'N';
	      }
		}
		
		# reverse entire training validation relationship
		
		my $categorizer2 = Algorithm::NaiveBayes->new;
		foreach my $j (23214..46427) {
		    my $string        = getAbstractString($training_array[$j]);
	      my $abstract_hash = invert_string($string);
	      if($training_array[$j] =~ /weistein/) {
	          $categorizer2->add_instance( attributes => $abstract_hash,
                                        label => 'positive' );
	      } else {

	      	  $categorizer2->add_instance( attributes => $abstract_hash,
                                        label => 'negative' );
	      }
		}
		$categorizer2->train;
		foreach my $j (0..23213) {
		    my $string        = getAbstractString($training_array[$j]);
	      my $abstract_hash = invert_string($string);
	      my $probs = $categorizer2->predict( attributes => $abstract_hash );
	      push @{$predictions->{$i*2 + 2}},$probs->{'positive'};
	      if($training_array[$j] =~ /weistein/) {
	          push @{$labels->{$i*2 + 2}},'P'; 
	      }
	      else {
	      	  push @{$labels->{$i*2 + 2}},'N';
	      }
		}
		  
}

# output the final matrix;
#
foreach my $i (0..46427) {
    foreach my $j (1..9) {
        $output_predictions->print("$predictions->{$j}->[$i]\t");  
    }
    $output_predictions->print("$predictions->{10}->[$i]\n"); 
}

foreach my $i (0..46427) {
    foreach my $j (1..9) {
        $output_labels->print("$labels->{$j}->[$i]\t");  
    }
    $output_labels->print("$labels->{10}->[$i]\n"); 
}

$output_predictions->close;
$output_labels->close;
print "complete learning  the parameters\n";


sub fisher_yates_shuffle {
    my $array = shift;
    my $i = @$array;
    while ( --$i ) {
        my $j = int rand( $i+1 );
        @$array[$i,$j] = @$array[$j,$i];
    }
}

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