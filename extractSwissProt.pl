use strict;
use FileHandle;

my $swissDB = '../publicData/uniprot_sprot.dat';
my $result  = getSwissAnno($swissDB);
foreach my $geneName (keys %{$result}) {
	  print $geneName,"\t",$result->{$geneName}->[0],
	        "\t",$result->{$geneName}->[1],"\n";
}



sub getSwissAnno {
	  my $file         = shift;
    my $file_handle  = FileHandle->new($file);
    my $ac_num       = undef;
    my $state        = 0;
    my $mouse_state  = 0;
    my $geneName     = undef;
    my $geneID       = undef;
    my $mouse_result = undef; 
    while(my $line = $file_handle->getline) {
	      if($line =~ /^AC\s+(\w{6});/) {
	  	      $ac_num   = $1;
	  	      $state    = 1;
	  	      next;
	      } elsif($state == 1) {
	  	      if($line =~ /^GN\s+Name=(.*?);/) {
	  	  	   $geneName = uc $1;
	  	      }
	  	      if($line =~ /^DR\s+GeneID;\s+(\d+);/) {
	  	  	      $geneID = $1;
	  	      }
	  	      if($line =~ /^OS\s+Mus musculus/) {
	  	      	  $mouse_state = 1;
	  	      }
	  	      if($line =~/^\/\// && $mouse_state == 1) {
	  	  	      $mouse_result->{$geneName} = [$ac_num,$geneID];
	  	  	      $geneID   = undef;
	  	  	      $geneName = undef;
	  	  	      $ac_num   = undef;
	  	  	      $state    = 0; 
	  	  	      $mouse_state = 0; 	  	  
	  	      }
	      }
    }
    $file_handle->close;
    return $mouse_result;
}

