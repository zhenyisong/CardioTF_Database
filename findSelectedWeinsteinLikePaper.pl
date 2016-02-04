use Algorithm::NaiveBayes;
use Lingua::EN::Splitter qw(words);
use Lingua::EN::StopWords qw(%StopWords);
use strict;
use FileHandle;
use File::Find;

my $positive_dir = 'positive_training_data/';
my $negative_dir = 'negative_training_data/';
my $data_dir     = 'whole_weistein_journal_txt';


my $output_dir         = 'selected_whole_weinstein_txt';
my $output_file_list   =  'selected_weistein_like.pmid.list';
my $output_file_handle = FileHandle->new(">$output_file_list");

my @positive_array;
find( sub { push (@positive_array,$File::Find::name) if /\.txt$/ },$positive_dir);


my @negative_array;
find( sub { push (@negative_array,$File::Find::name) if /\.txt$/ },$negative_dir);

my @weistein_array;
find( sub { push (@weistein_array,$File::Find::name) if /\.txt$/ },$data_dir);



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


foreach my $data (@weistein_array) {
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
print "well done! The next step is run splitWeisteinPaper.pl\n";


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
