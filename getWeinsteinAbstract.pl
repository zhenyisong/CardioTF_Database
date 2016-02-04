use strict;
use warnings;
use FileHandle;
use File::Find;


my $localdir  = '../publicData/weistein_all_abstract';
my $outputdir = 'weistein_positive_raw_data/';

my @array;
find( sub { push (@array,$File::Find::name) if /\.txt$/ },$localdir );


my $counter_abstract = 0;
foreach my $meeting (@array) {
	   $counter_abstract++;
	   my $abstract_hash_all = readWeinsteinAbstract($meeting,\$counter_abstract);
	   foreach my $text_id (keys %{$abstract_hash_all}) {
	       my $file_name   = $outputdir.'weistein_'.$text_id.'.txt';
	       my $file_handle = FileHandle->new(">$file_name");
	       $file_handle->print($abstract_hash_all->{$text_id});
	       $file_handle->close;
	   }  
}

sub readWeinsteinAbstract {
	  my $file_name         = shift;
	  my $file_handle       = FileHandle->new($file_name);
	  my $all_abstract      = undef;
	  my $abstract_hash_ref = undef;
	  while(my $line = $file_handle->getline) {
	  	  $all_abstract .= $line;
	  }
	  $file_handle->close;
	  $all_abstract =~ s/\\n//gs;
	  my @abstracts = ($all_abstract =~ /Abstract-(.*?)\/\//gs);
	  my $count = shift;
	  foreach my $text (@abstracts) {
	  	  $$count++;
	  	  $abstract_hash_ref->{$$count} = $text;
	  }
	  return $abstract_hash_ref;
}

