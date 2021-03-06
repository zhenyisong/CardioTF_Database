# @since 2014-02-07
# @version 1.0
# http://www.uniprot.org/manual/accession_numbers
# http://www.uniprot.org/manual/gene_name
# this is the first program to run to extract full TF names from
# 1.
# http://wiki.geneontology.org/index.php/Defining_CV-associated_gene_list
# 2.
# http://www.ucl.ac.uk/cardiovasculargeneontology
# the following program is to run parseCardioGO_UK.pl
# the required input file:
#     most recent version of swiss pro database:
#					uniprot_sprot.dat
#     unzipped gz file named: 
#          gene_association.goa_bhf-ucl
#     
# the output file is:
#  		cardioGO_UK_SwissproID_GeneID.table
# 		cardioGO_UK_SwissID_NoGeneID.table
#
# @result
# cardioGO_UK_SwissproID_GeneID.table
# 			the first line is the primary key of swisspro ID,
#       the second line is the EntrezGeneID
# I manualy  edit the cardioGO_UK_SwissproID_GeneID.table and
# added the cardioGO_UK_SwissID_NoGeneID.table into cardioGO_UK_SwissproID_GeneID.table
#
#
# this is the first program in this project
#@!
# now the second program you should run is:
#		parseHomolog.pl
#   the result from above program has been already generated.

use strict;
use FileHandle;

my $input_filedir                 = '../publicData/';
my $input_filename                = 'gene_association.goa_bhf-ucl';
$input_filename                   = $input_filedir.$input_filename;
                                  
                                  
my $swisspro_dir                  = '../publicData/';
my $swisspro_file                 = 'uniprot_sprot.dat';
$swisspro_file                    = $swisspro_dir.$swisspro_file;

my $output_file                   ='cardioGO_UK_SwissproID_GeneID.table';
my $output_filehandle             = FileHandle->new(">$output_file");

my $output_second_file            = 'cardioGO_UK_NoGeneID.table';
my $output_second_filehandle      = FileHandle->new(">$output_second_file");                                  


my $protein_id_hash_ref           = getProteinID($input_filename);
#my $protein_id_genename_hash_ref  = getGeneName($swisspro_file);
my $protein_id_geneid_hash_ref    = getGeneID($swisspro_file);

my $protein_id_count              = 0;
my $protein_id_nogene_count       = 0;

my @protein_id_array              = keys %{$protein_id_hash_ref};


foreach my $protein_id(@protein_id_array ) {
	  if(exists $protein_id_geneid_hash_ref->{$protein_id} && defined $protein_id_geneid_hash_ref->{$protein_id} ) {
	      $output_filehandle->print("$protein_id\t$protein_id_geneid_hash_ref->{$protein_id}\n");
	      $protein_id_count++;
	  }
	  else {
	  	  $output_second_filehandle->print("$protein_id\n");
	  	  $protein_id_nogene_count++;
	  }
}
$output_filehandle->close;
$output_second_filehandle->close;

my $total_swisspro  = scalar @protein_id_array;

print "there are $total_swisspro CardioGO_UK proteins \n";
print "there are $protein_id_count protein which have NCBI geneID!\n";
print "there are $protein_id_nogene_count protein which have no NCBI geneID!\n";

sub getProteinID {
	  my $input_filename     = shift;
    my $file_linenumber    = 0;
    my $file_content       = undef;
    my $input_filehandle   = FileHandle->new($input_filename);

    while (my $line = $input_filehandle->getline ) {
	      chomp $line;
	      $file_content->{$file_linenumber} = $line;
	      $file_linenumber++;
    }
    $input_filehandle->close;

	  my $unipro_id_hash_ref  = undef;
	  foreach my $index(0..$file_linenumber) {
	      my $protein = undef;
	  	  if(exists $file_content->{$index}) {
	  	  	  ($protein) = ($file_content->{$index} =~ /^UniProtKB\t(\w{6})/);
	  	  }

	  	  $unipro_id_hash_ref->{$protein}++;

    }
    
    return $unipro_id_hash_ref;
}

sub getGeneName {
	  my $swisspro_database             = shift;
	  my $swiss_handle                  = FileHandle->new($swisspro_database);
	  my $state                         = 0;
	  my @protein_id                    = ();
	  my $protein_id_genename_hash_ref  = ();
	  my $gene_name                     = undef;
	  while(my $line = $swiss_handle->getline) {
	  	  chomp $line;
	      if($line =~ /^ID\s+/) {
	      	  $state = 1;
	      }

	  	  if($state == 1) {
	  	  	  if($line =~ /^AC\s+/) {
                push @protein_id,($line =~ /(\w{6});/g);
	  	      }
	  	  	  if($line =~ /^GN\s+/) {
	  	  	  	  ($gene_name) = ($line =~ /Name=(\w+)/);
	  	  	  }
	  	  }
	  	  if($line =~ /^\/\//) {
	  	  	  foreach my $protein(@protein_id) {
	  	  	  	 $protein_id_genename_hash_ref->{$protein} = $gene_name; 
	  	  	  }
	  	  	  $state      = 0;
	  	  	  @protein_id = ();
	  	  	  $gene_name  = '';
	  	  }
	  }
	  
	  $swiss_handle->close;
	  return $protein_id_genename_hash_ref;	  
}

sub getGeneID {
    my $swisspro_database             = shift;
	  my $swiss_handle                  = FileHandle->new($swisspro_database);
	  my $state                         = 0;
	  my @protein_id                    = ();
	  my $protein_id_geneid_hash_ref    = ();
	  my $gene_id                       = undef;
	  
	  while(my $line = $swiss_handle->getline) {
	  	  chomp $line;
	      if($line =~ /^ID\s+/) {
	      	  $state = 1;
	      }

	  	  if($state == 1) {
	  	  	  if($line =~ /^AC\s+/) {
                push @protein_id,($line =~ /(\w{6});/g);
	  	      }
	  	  	  if($line =~ /^DR\s+GeneID;\s+(\d+);/) {
	  	  	  	  $gene_id = $1;
	  	  	  }
	  	  }
	  	  if($line =~ /^\/\//) {
	  	  	  foreach my $protein(@protein_id) {
	  	  	  	 $protein_id_geneid_hash_ref->{$protein} = $gene_id; 
	  	  	  }
	  	  	  $state      = 0;
	  	  	  @protein_id = ();
	  	  	  $gene_id    = undef;
	  	  }
	  }
	  
	  $swiss_handle->close;
	  return $protein_id_geneid_hash_ref;	
}