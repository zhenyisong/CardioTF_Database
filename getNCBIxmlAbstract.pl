#
# 
use strict;
use warnings;
use File::Find;
use FileHandle;

my $localdir  = '../publicData/negative_abstract';
my $outputdir = 'negative_raw_data/';

my @array;
find( sub { push (@array,$File::Find::name) if /\.nxml$/ },$localdir );

my $abstract_stream_all = undef;
my $abstract_count      = 0;

foreach my $file(@array) {
	  $abstract_stream_all = readNCBIxml($file);
	  my $abstract_hash_ref_all = parseXMLstream($abstract_stream_all,\$abstract_count);
	  
	  foreach my $text_id (keys %{$abstract_hash_ref_all}) {
	      my $file_name   = $outputdir.$text_id.'.txt';
	      my $file_handle = FileHandle->new(">$file_name");
	      $file_handle->print($abstract_hash_ref_all->{$text_id});
	      $file_handle->close; 
    }
}


sub parseXMLstream {
	  my $xmlStream         = shift;
	  my $abstract_hash_ref = undef;
	  my @abstract_array    = ($xmlStream =~ /\<abstract\>(.*?)\<\/abstract\>/gs);
    
    my $count             = shift; 
    foreach my $abstract (@abstract_array) {
    	  $abstract  =~ s/\\n//sg;
    	  $abstract  =~ s/<.*?>//sg;
    	  $$count++;
    	  $abstract_hash_ref->{$$count} = $abstract;
    }
    return $abstract_hash_ref;
}



sub readNCBIxml {
   my $file_name          = shift;
   my $file_handle        = FileHandle->new($file_name);
   my $xml_string_stream  = undef;
   
   while(my $line = $file_handle->getline) {
   	   $xml_string_stream = $xml_string_stream.$line;
   }
   
   $file_handle->close;
   return $xml_string_stream; 
}