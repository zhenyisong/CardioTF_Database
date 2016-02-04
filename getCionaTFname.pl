use strict;
use FileHandle;

my $file_dir = '../publicData/';
my $cionaOrthologs = $file_dir.'ci_hs_orthologs.txt';
my $cionaHuman     = $file_dir.'ensembl_entrez.ciona';
my $humanTF        = 'mouse_human_geneID_name.final.table';

my $orthologs      = readCionaOrthologs($cionaOrthologs);
my $c_human        = readCionaHumanTable($cionaHuman);
my $humanTFhash    = readHumanTF($humanTF);
my $output_handle   = FileHandle->new(">ciona_TF.table");

foreach my $ciona (keys %{$orthologs}) {
	  #print "$ciona\t$orthologs->{$ciona}->[2]\t$orthologs->{$ciona}->[3]\n";
	  if($orthologs->{$ciona}->[2] >= 0.5 && $orthologs->{$ciona}->[3] >= 0.5) {
	  	   #print "$c_human->{$ciona}\t$humanTFhash->{$c_human->{$ciona}}\n";
	  	   if(exists $c_human->{$ciona} && exists $humanTFhash->{$c_human->{$ciona}->[0]}) {
	  	   	    $output_handle->print("$orthologs->{$ciona}->[0]\t$orthologs->{$ciona}->[1]\t$orthologs->{$ciona}->[2]\t$orthologs->{$ciona}->[3]\t$c_human->{$ciona}->[0]\t$humanTFhash->{$c_human->{$ciona}->[0]}\n");
	  	   }
	  }
}

$output_handle->close;



sub readHumanTF {
	  my $file  = shift;
	  my $file_handle = FileHandle->new($file);
	  my $result      = undef;
	  while(my $line = $file_handle->getline) {
	  	  chomp $line;
	  	  my @buffer = split/\t/,$line;
	  	  #print "$buffer[1]\t$buffer[2]\n";
	  	  $result->{$buffer[1]} = $buffer[2];
	  }
	  $file_handle->close;
	  return $result;
}

sub readCionaOrthologs {
	  my $file  = shift;
	  my $file_handle = FileHandle->new($file);
	  my $result      = undef;
	  while(my $line = $file_handle->getline) {
	  	  chomp $line;
	  	  my @buffer = split/\t/,$line;
	  	  #print "$buffer[0]\t$buffer[1]\t$buffer[3]\t$buffer[4]\n";
	  	  $result->{$buffer[0]} = [$buffer[1],$buffer[2],$buffer[3],$buffer[4]];
	  }
	  $file_handle->close;
	  return $result;
}

sub readCionaHumanTable {
    my $file        = shift;
    my $file_handle = FileHandle->new($file);
    my $result      = undef;
    while(my $line  = $file_handle->getline) {
    	  chomp $line;
    	  $line =~ s/\"//g;
    	  my @buffer = split/\t/,$line;
    	  #print "$buffer[0]\t$buffer[1]\n";
    	  $result->{$buffer[0]} = [$buffer[1],$buffer[2]];  
    }
    $file_handle->close;
    return $result;
}