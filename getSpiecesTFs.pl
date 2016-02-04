# author Yisong Zhen
# since 2014-05-20
# 
use strict;
use FileHandle;

my $swissGeneID = 'wingender_SwissproID_GeneID.table';
my $geneNameID  = 'zebrafish.geneID.geneName.table';
my $humanID     = 'human_zebrafish.geneID.table';
my $output_file = 'zebrafish_TF.final.table';
my $output_fh   = FileHandle->new(">$output_file");

my $swissTF_hash_ref     = readSwissHumanGeneID($swissGeneID);
my $geneName_hash_ref    = readGeneNameID($geneNameID);
my $humanID_hash_ref     = readHumanIDotherID($humanID);

foreach my $id (keys %{$swissTF_hash_ref}) {
	  my $otherid = $humanID_hash_ref->{$id};
	  my $name    = $geneName_hash_ref->{$otherid};
	  if(defined $otherid) {
	      $output_fh->print("$id\t$otherid\t$name\n");
	  }
}

$output_fh->close;
print "you complete your data!\n";

sub readSwissHumanGeneID {
	  my $file_name       = shift;
	  my $file_handle     = FileHandle->new($file_name);
	  my $geneid_hash_ref = undef;
	  while(my $line = $file_handle->getline) {
	  	  chomp $line;
	  	  my @array = split/\t/,$line;
	  	  $geneid_hash_ref->{$array[1]}++;  
	  }
	  $file_handle->close;
	  return $geneid_hash_ref;  
}

sub readGeneNameID {
	  my $file_name       = shift;
	  my $file_handle     = FileHandle->new($file_name);
	  my $geneid_hash_ref = undef;
	  while(my $line = $file_handle->getline) {
	  	  chomp $line;
	  	  my @array = split/\t/,$line;
	  	  $geneid_hash_ref->{$array[0]} = $array[1];  
	  }
	  $file_handle->close;
	  return $geneid_hash_ref;
}

sub readHumanIDotherID {
	  my $file_name       = shift;
	  my $file_handle     = FileHandle->new($file_name);
	  my $geneid_hash_ref = undef;
	  while(my $line = $file_handle->getline) {
	  	  chomp $line;
	  	  my @array = split/\t/,$line;
	  	  $geneid_hash_ref->{$array[0]} = $array[1];  
	  }
	  $file_handle->close;
	  return $geneid_hash_ref;
}