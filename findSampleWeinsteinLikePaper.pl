use Algorithm::NaiveBayes;
use Lingua::EN::Splitter qw(words);
use Lingua::EN::StopWords qw(%StopWords);
use strict;
use FileHandle;
use File::Find;

my $positive_dir = 'positive_training_data/';
my $negative_dir = 'negative_training_data/';


my $data_dir_2008     = 'cardioSample/2008';
my $data_dir_2009     = 'cardioSample/2009';
my $data_dir_2010     = 'cardioSample/2010';
my $data_dir_2011     = 'cardioSample/2011';
my $data_dir_2012     = 'cardioSample/2012';
my $data_dir_2013     = 'cardioSample/2013';

my $output_dir         =  'cardio_paper_sample_set';
my $output_file_list   =  'weistein_like.sample.pmid.list';
my $output_file_handle = FileHandle->new(">$output_file_list");

my @positive_array;
find( sub { push (@positive_array,$File::Find::name) if /\.txt$/ },$positive_dir);


my @negative_array;
find( sub { push (@negative_array,$File::Find::name) if /\.txt$/ },$negative_dir);

my @data_array_2008;
find( sub { push (@data_array_2008,$File::Find::name) if /\.txt$/ },$data_dir_2008);

my @data_array_2009;
find( sub { push (@data_array_2009,$File::Find::name) if /\.txt$/ },$data_dir_2009);

my @data_array_2010;
find( sub { push (@data_array_2010,$File::Find::name) if /\.txt$/ },$data_dir_2010);

my @data_array_2011;
find( sub { push (@data_array_2011,$File::Find::name) if /\.txt$/ },$data_dir_2011);

my @data_array_2012;
find( sub { push (@data_array_2012,$File::Find::name) if /\.txt$/ },$data_dir_2012);

my @data_array_2013;
find( sub { push (@data_array_2013,$File::Find::name) if /\.txt$/ },$data_dir_2013);
#

my $categorizer = Algorithm::NaiveBayes->new;

foreach my $positive (@positive_array) {
	  my $string = getAbstractString($positive);
	  my $abstract_hash = invert_string($string);
	  $categorizer->add_instance( attributes => $abstract_hash,
                                label => 'positive' );
}

print "add all positive set into learning machine!\n";

foreach my $negative (@negative_array) {
	  my $string = getAbstractString($negative);
	  my $abstract_hash = invert_string($string);
	  if(! defined $abstract_hash ){
	  	  next;
	  }
	  $categorizer->add_instance( attributes => $abstract_hash,
                                label => 'negative' );

}

print "add all negative set into learning machining!\n";

$categorizer->train;


foreach my $data (@data_array_2008) {
	  my $string = getAbstractString($data);
	  my $abstract_hash = invert_string($string);
	  if(defined $abstract_hash) {
	      my $probs = $categorizer->predict( attributes => $abstract_hash );
	      #print $probs->{'positive'},"\n";
	      if ( $probs->{'positive'} >= 1 ) {
            system("cp $data $output_dir");
            $output_file_handle->print("$data\n");
        }
	  	  
	  } else {
	  	  print "the data is confused, please check $data\n";
	  	  next;
	  } 

}

foreach my $data (@data_array_2009) {
	  my $string = getAbstractString($data);
	  my $abstract_hash = invert_string($string);
	  if(defined $abstract_hash) {
	      my $probs = $categorizer->predict( attributes => $abstract_hash );
	      #print $probs->{'positive'},"\n";
	      if ( $probs->{'positive'} >= 1 ) {
            system("cp $data $output_dir");
            $output_file_handle->print("$data\n");
        }
	  	  
	  } else {
	  	  print "the data is confused, please check $data\n";
	  	  next;
	  } 

}

foreach my $data (@data_array_2010) {
	  my $string = getAbstractString($data);
	  my $abstract_hash = invert_string($string);
	  if(defined $abstract_hash) {
	      my $probs = $categorizer->predict( attributes => $abstract_hash );
	      #print $probs->{'positive'},"\n";
	      if ( $probs->{'positive'} >= 1 ) {
            system("cp $data $output_dir");
            $output_file_handle->print("$data\n");
        }
	  	  
	  } else {
	  	  print "the data is confused, please check $data\n";
	  	  next;
	  } 

}

foreach my $data (@data_array_2011) {
	  my $string = getAbstractString($data);
	  my $abstract_hash = invert_string($string);
	  if(defined $abstract_hash) {
	      my $probs = $categorizer->predict( attributes => $abstract_hash );
	      #print $probs->{'positive'},"\n";
	      if ( $probs->{'positive'} >= 1 ) {
            system("cp $data $output_dir");
            $output_file_handle->print("$data\n");
        }
	  	  
	  } else {
	  	  print "the data is confused, please check $data\n";
	  	  next;
	  } 

}

foreach my $data (@data_array_2012) {
	  my $string = getAbstractString($data);
	  my $abstract_hash = invert_string($string);
	  if(defined $abstract_hash) {
	      my $probs = $categorizer->predict( attributes => $abstract_hash );
	      #print $probs->{'positive'},"\n";
	      if ( $probs->{'positive'} >= 1 ) {
            system("cp $data $output_dir");
            $output_file_handle->print("$data\n");
        }
	  	  
	  } else {
	  	  print "the data is confused, please check $data\n";
	  	  next;
	  } 

}

foreach my $data (@data_array_2013) {
	  my $string = getAbstractString($data);
	  my $abstract_hash = invert_string($string);
	  if(defined $abstract_hash) {
	      my $probs = $categorizer->predict( attributes => $abstract_hash );
	      #print $probs->{'positive'},"\n";
	      if ( $probs->{'positive'} >= 1 ) {
            system("cp $data $output_dir");
            $output_file_handle->print("$data\n");
        }
	  	  
	  } else {
	  	  print "the data is confused, please check $data\n";
	  	  next;
	  } 

}

$output_file_handle->close;
print "well done!\n";


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
