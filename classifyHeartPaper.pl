use Algorithm::NaiveBayes;
use Lingua::EN::Splitter qw(words);
use Lingua::EN::StopWords qw(%StopWords);
use strict;
use FileHandle;
use File::Find;

my $positive_dir = '';
my $negative_dir = '';

my $data_dir     = '';

my $output_file  = '';

my @positive_array;
find( sub { push (@positive_array,$File::Find::name) if /\.txt$/ },$positive_dir);

=head
my @negative_array;
find( sub { push (@negative_array,$File::Find::name) if /\.txt$/ },$negative_dir);
=cut

my @data_array;
find( sub { push (@data_array,$File::Find::name) if /\.txt$/ },$data_dir);


my $categorizer = Algorithm::NaiveBayes->new;

foreach my $positive (@positive_array) {
	  my $string = getAbstractString($positive);
	  my $abstract_hash = undef;
	  invert_string($string, 0, $abstract_hash);
	  $categorizer->add_instance( attributes => $abstract_hash,
                                label => "positive" );
}

=head
foreach my $negative (@negative_array) {
	  my $string = getAbstractString($negative);
	  my $abstract_hash = undef;
	  invert_string($string, 0, $abstract_hash);
	  $categorizer->add_instance( attributes => $abstract_hash,
                                label => "negative" );
}
=cut

$categorizer->train;

my $output_filehandle = FileHandle->new(">$output_file");

foreach my $data (@data_array) {
	  my $string = getAbstractString($data);
	  my $abstract_hash = undef;
	  invert_string($string, 0, $abstract_hash);
	  my $probs = $categorizer->predict( attributes => $abstract_hash );
	  if ( $probs->{'positive'} > 0.5 ) {
        # Probably interesting
        $output_filehandle->print("$data\n");
    }
}
$output_filehandle->close;

print "well done!\n";


sub getAbstractString {
	   my $file_name      = shift;
	   my $file_handle    = FileHanlde->new("$file_name");
	   my $abstractString = undef;
	   while(my $line = $file_hanlde->getline) {
	   	  $abstractString .= $line;
	   }
	   $file_handle->close;
	   $abstractString =~ s/\\n//gs;
	   return $abstractString;
}




sub invert_string {
    my ($string, $weight, $hash) = @_;
    my @buffer = grep { !$StopWords{$_} } words(lc($string));
    foreach my $w (@buffer) {
    	  $hash->{$w}++;
    }
    return $hash;
}