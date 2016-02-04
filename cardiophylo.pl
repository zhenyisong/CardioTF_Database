#!/usr/bin/perl

#use GD::Simple;
use CGI;
use DBI;
use strict;
use FileHandle;

#  @book name:
#  begining Perl web development from novice to professional
#

BEGIN {
    use CGI::Carp qw(carpout);
    open (ERRORLOG, '>>', '/home/www/website/cardiosignal/log/cgierror_log') ||
    die("Unable to open log file: $!\n");
    carpout('ERRORLOG');
}




#
# http://gunther.web66.com/FAQS/taintmode.html
# limit the ENV{PATH} only to the program installation path.
#
$ENV{'PATH'} = $ENV{'PATH'}.':/home/www/website/program';
$ENV{'DIALIGN2_DIR'} = '/home/www/website/program/dialign2_dir';
if ($ENV{'PATH'} =~ /(\/home\/www\/website\/program)/) {
    $ENV{'PATH'} = $1;
} else {
    warn ("TAINTED DATA SENT BY $ENV{'REMOTE_ADDR'}: $!");
    $ENV{'PATH'} = ""; # successful match did not occur
}


my $submit           = new CGI;
print $submit->header;
print	$submit->start_html(-title=>"search results" ,
                          -style=>{-src=>'/cardiosignal.css'},
                          -meta => {
                          'http-equiv' => 'Content-Type',
                          'content' => 'text/html; charset=utf-8',
                          });   


my $geneSequence     = $submit->param('regulatoryRegion');
my $fileName         = saveRegulatoryRegion($geneSequence);
my $outputFileName   = $fileName.'.ali';

my $commandLineParameter      = "-fn $outputFileName -n $fileName>&1";
#my $commandLineParameter       = "-fn /home/www/website/promoter.out -n /home/www/website/promoter.seq>&1";


!system("dialign $commandLineParameter")|| die "cannot execute the Dialign program $!";
my $state             = $?;


my @TFBSIndex             = $submit->param('TFBSIndex');


my $bioSeqIOHashRef = parseDialign($outputFileName);

my $matrix = getMatrixHashRefFromCardioSignal(5);
print $submit->p($matrix->{'name'});
print $submit->p($matrix->{'length'});
$matrix = parseMatrixFile($matrix);
$matrix = getNormalizedMatrix($matrix);
my $conservedMotif = scanConservedMotif($bioSeqIOHashRef,$matrix);


if(defined $conservedMotif) {
	  print "hello ,we got motif";
}
my $formatedHashTag = formatHTMLtagHashRef($conservedMotif,$matrix);

print "<div class=\introduction\"><pre>";
generatePREtag($bioSeqIOHashRef,$formatedHashTag);

print "</pre></div>";




                   						
print    $submit->end_html; 
            						
#-------------------------------------------------------------------------------
# $sth->fetchrow_hashref
# @parameter  the primary key from CardioSignal database
#             for example, MEF2 primary key is 3;
# @return
# the hash reference
# 		:matrixFile
#     :matrixLength
#     :cutoff
#  
#-------------------------------------------------------------------------------
sub getMatrixHashRefFromCardioSignal {
    my $matrixID            = shift;
    my $querySQL            = qq{SELECT matrixFile, matrixLength, 
    	                                  cutoff, matrixName   
	                               FROM   CardioMatrix  
	                               WHERE  matrixID = ?};
    my $dbh                 = connectToDatabase();
    my $sth                 = $dbh->prepare($querySQL);
    $sth->execute($matrixID);   
    my $matrixHashRef   = undef;

    while( my @array   = $sth->fetchrow_array ) {
	      $matrixHashRef->{'matrix'}       = $array[0];
	      $matrixHashRef->{'length'}       = $array[1];
	      $matrixHashRef->{'threshold'}    = $array[2];
	      $matrixHashRef->{'name'}         = $array[3];
    }                      
    
    $sth->finish();
    $dbh->disconnect();
    return $matrixHashRef;
}


#-------------------------------------------------------------------------------
# @parameter
# @return 
#      database handler
#      $dbh
#-------------------------------------------------------------------------------

sub connectToDatabase {
	  my $database_name   = 'cardiosignal';
    my $user_name       = 'search';
    my $password        = 'googlebaidu2008';
    my $data_source			= "DBI:mysql:$database_name";
	  my $dbh             = DBI->connect("$data_source:host=localhost",
											                 $user_name,$password, 
											                {PrintError=>1, RaiseError=>1});
	  if (!$dbh) {
	      die (" Failed connecting to the database.");
	  }
	  return $dbh;
}

#-------------------------------------------------------------------------------
# @parameter
#    the value from getMatrixHashRefFromCardioSignal
# @function
#    parse the matrix file (the Position Profile from CardioSignal database
# @return
#
#-------------------------------------------------------------------------------

sub parseMatrixFile {

 #------- define variables --------
    my $matrixHashRef       = shift;
    my $matrixFileArrayRef  = undef;

    #my $matrixLength       = $matrixHashRef->{'matrixLength'};
    my @buffer              = split(/\n/,$matrixHashRef->{'matrix'});
    my $arrayLastIndex      = $#buffer;
    foreach my $row (@buffer[1..$arrayLastIndex]) {
        my (@bable) = ($row =~ /\d+/g);
        push (@{$matrixFileArrayRef}, \@bable);
    }

=head
@
how to use the data structure to get the corresponding value?
        $matrixHash->{'matrix'}->[0]->[2]
                         |------- referred to hash key "matrix"
                          see: CardioSignal database CardioMatrix table
                                  |----- is the matrix row (zero-based)
@                                      |------ the matrix column
																												A	C	G	T
=cut

    $matrixHashRef->{'matrix'} = $matrixFileArrayRef;
    return $matrixHashRef;
}

#-------------------------------------------------------------------------------
# @parameter
#      from function parseMatrixFile
# @return
#    hash reference, normalized matrixFile data
# @modified by YiSong 2011-10-17
# @modified by Yisong 2015-08-13
#-------------------------------------------------------------------------------

sub getNormalizedMatrix {

    my $matrixHashRef        = shift;
    my $backGround           = getBackGround();
    my ($maxScore,$minScore) = (0,0);

    foreach my $row ( @{$matrixHashRef->{'matrix'}} ) {
        my $rowScore = 0;

    #----- add the score of the whole row ------//
        foreach my $score ( @{$row} ) {
            $rowScore += $score;
        }
        #print  $rowScore,"\n";
        #
        # normalize the PWM
        for ( my $i = 0; $i < 4;$i++ ) {
            # modify here Yisong 2015-08-13
            $row->[$i] = log(($row->[$i] + sqrt($rowScore)/4.0)/
                         $backGround->[$i]*($rowScore
                                             + sqrt($rowScore)));
            #print $row->[$i],"\n";
        }

        # in the next to get the MAX and MIN to caculat the threshold;
        my $MAX = $row->[0];
        my $MIN = $row->[0];
        foreach(@{$row}) {
            $MAX = $_ if $MAX < $_;
            $MIN = $_ if $MIN >$_;
        }
        #print "MAX: $MAX\n";
        #print "MIN: $MIN\n";
        $maxScore += $MAX;
        $minScore += $MIN;
    }

    my $threshold = $matrixHashRef->{'threshold'};

    $threshold = $minScore + ($maxScore - $minScore)*$threshold;
    $matrixHashRef->{'threshold'} = $threshold;
    #
    # add the item 2004-12-02
    #
    $matrixHashRef->{'max'} = $maxScore;
    $matrixHashRef->{'min'} = $minScore;
    return $matrixHashRef;
}


#-------------------------------------------------
=head
@author Yisong Zhen
@version 1.0
@since 2004-11-10
@description
here is to define the background nucleic acid
likey, the GC% content at the genome scale
background nucleotide abundance
=cut
#-------------------------------------------------


sub getBackGround {

  my $background = shift;
  #-------- default value ------------//
  #-------- in the order of 'A', 'C','G','T'; ---------//

  $background ||= [0.5,0.5,0.5,0.5];
  return $background;
}


#-----------------------------------------------
# @since 2004-11-10
# description
# set the threshold of the matrix to scan the
#-----------------------------------------------

sub setThreshold {
  my $threshold  = shift;
  $threshold   ||= 0.90;
  return $threshold;
}

#-------------------------------------------------------------------------------
=head

@author Yisong Zhen
@sicne 2004-11-11
@version 1.0
@param
  the matrix anonymous hash from the readMAtrixFile
@return the hash reference of the matrix
description
get the normalize the matrix using the equation from
PMID:11544200
=cut
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# @parameter
#    the string of bio sequence
#    change all letter to up case, thus follwoing PWM can work!!!!!
# @return 
#    the array of bio sequence
#-------------------------------------------------------------------------------
sub stringToArray {
    my $bioString       = shift;
    my $bioArrayRef     = undef;

    while ($bioString   =~ s/(\S)//) {
    	  my $letter = uc $1;
        push(@{$bioArrayRef}, $letter);
    }

    return $bioArrayRef;
}

#-------------------------------------------------------------------------------
# @parameter
#     bioseq: BioString
#     matrix: Normalized PWM
# @return
# the reference array of the position
# of certain matrix
# string comparsion is case-sensitive !!!!!!!
#-------------------------------------------------------------------------------

sub scanBioSeqByPWM {

# ---- store the string of the biosequence ------//
    my $bioSeq      = shift;
    my $bioArrayRef = stringToArray($bioSeq);
    my $matrix      = shift;
    my $scanResult  = undef;;

#--------- score the bioSeq ------------------//

    my ($positiveScore,$negativeScore) = (0,0);
#
    for (my $i = 0;$i <scalar @{$bioArrayRef};$i++) {
        ($positiveScore,$negativeScore) = (0,0);
        for (my $j = 0;$j < $matrix->{'length'}; $j++) {
            if (defined $bioArrayRef->[$i+$j]) {
                if($bioArrayRef->[$i + $j] eq 'A') {
                    $positiveScore += $matrix->{'matrix'}->[$j]->[0];
                    $negativeScore +=
                    $matrix->{'matrix'}->[$matrix->{'length'} - $j - 1]->[3];
                } elsif($bioArrayRef->[$i + $j] eq 'C') {
                    $positiveScore += $matrix->{'matrix'}->[$j]->[1];
                    $negativeScore +=
                    $matrix->{'matrix'}->[$matrix->{'length'} - $j - 1]->[2];

                } elsif($bioArrayRef->[$i + $j] eq 'G') {
                    $positiveScore += $matrix->{'matrix'}->[$j]->[2];
                    $negativeScore +=
                    $matrix->{'matrix'}->[$matrix->{'length'} - $j - 1]->[1];
                } elsif($bioArrayRef->[$i + $j] eq 'T') {
                    $positiveScore += $matrix->{'matrix'}->[$j]->[3];
                    $negativeScore +=
                    $matrix->{'matrix'}->[$matrix->{'length'} - $j - 1]->[0];
                } else {
                    my $average = $matrix->{'matrix'}->[$j]->[0];
                    for(my $k=1; $k <= 4; $k++) {
                        if($average >= $matrix->{'matrix'}->[$j]->[$k]) {
                            $average = $matrix->{'matrix'}->[$j]->[$k];
                        }
                    }
                    $positiveScore += $average;
                    $negativeScore += $average;
                }
           } else {

               my $average = $matrix->{'matrix'}->[$j]->[0];
               for(my $k=1; $k <= 4; $k++) {
                   if($average >= $matrix->{'matrix'}->[$j]->[$k]) {
                       $average = $matrix->{'matrix'}->[$j]->[$k];
                   }
               }
               $positiveScore += $average;
               $negativeScore += $average;
           }
    }#--------- end the for cycle ----------//

    if( $positiveScore >=  $matrix->{'threshold'} ||
                         $negativeScore >=  $matrix->{'threshold'} ) {
        push(@{$scanResult},($i + 1));
    }
  }
  return $scanResult;
}

#-------------------------------------------------------------------------------
# @parameter
#   $bioSeq:BioSeqIOHashRef from parseDilagn;
#   $normalizedPWM matrix
# @return 
#  conserved position array reference
#
#
#-------------------------------------------------------------------------------
sub scanConservedMotif {
	  my $bioSeqIOHashRef  = shift;
	  my @seqIndexArray    = keys %{$bioSeqIOHashRef};
	  my $matrix           = shift;
	  my $matrixLength     = $matrix->{'length'};
	  my $seqID            = shift @seqIndexArray;
	  
	  my $bioSeq           = $bioSeqIOHashRef->{$seqID};
	  my $stringLength     = length $bioSeq;
	  
	  my $resultHashRef    = undef;
	  my $resultArrayRef   = undef;
	  
	  my $siteFind         = scanBioSeqByPWM($bioSeq,$matrix);
	  #print $bioSeq,"\n";
	
	  if(defined $siteFind) {
	  	  #print "hello word!\n";
	  	  foreach my $position (@{$siteFind}) {
	  	  	  foreach $seqID (@seqIndexArray) {
	  	  	  	  my $bioString      = $bioSeqIOHashRef->{$seqID};
	  	  	  	  my $stringStart    = $position - 1;
	  	  	  	  my $motif          = substr($bioString,
	  	  	  	                              $stringStart,
	  	  	  	                              $matrixLength);
	  	  	  	  my $motifFind      = scanBioSeqByPWM($motif,$matrix);
	  	  	  	  
	  	  	  	  if(defined $motifFind) {
	  	  	  	  	  $resultHashRef->{$position} = 1;
							  	 
							  }
							  else {
							      $resultHashRef->{$position} = 0;
							  	  last;
							  }
	  	  	  }
	  	  }
	  }
	  else {
	  	  #print "no conserved site!\n";
	  	  return $resultArrayRef;
	  }
	  
	  foreach my $position (keys %{$resultHashRef}) {
	  	  if($resultHashRef->{$position}) {
	  	  	  push(@{$resultArrayRef}, $position);
	  	  }
	  }
	  return $resultArrayRef;
}





#-------------------------------------------------------------------------------
# @parameter
#    output file name of DIALIGN program with absolute path
# 
# @return
#    hash reference
#    $result->{$seqID} = $bioSeq;
#-------------------------------------------------------------------------------

sub parseDialign {
	  my $fileName = shift;
	  my $fh       = FileHandle->new($fileName, "r");
	  my $state    = 0;
	  my $result   = undef;
	  while( my $line = $fh->getline ) {
	  	  chomp $line;
	  	  if($line =~ /Alignment \(DIALIGN format\)/) {
	  	  	  $state = 1;
	  	  }
	  	  if($state) {
	  	  	  if($line =~ /^(\S+)\s+(\d+)\s+(.*)/) {
	  	  	  	  my $seqName = $1;
	  	  	  	  my $string  = $3;
	  	  	  	  $string =~ s/\s+//g;
	  	  	  	  #$string =~ s/-/N/g;
	  	  	  	  $result->{$seqName} .= $string;
	  	  	  }
	  	  }
	  }
	  $fh->close;
	  #$result->{'hello'}="kitty";
	  return $result;
}


#-------------------------------------------------------------------------------
# @parameter
#  $submit->param('regulatoryRegion');
#  the FASTA sequences; no name conflict
#  should judge the name
# @return
# the random file name where we save the FASTA sequences;
# with aboslute path;
#
# get the FASTA format sequence from website
# deposit the sequences in randomGenerateFile.
# the iput sequence is get by parameter->regulatoryRegion
#-------------------------------------------------------------------------------

sub saveRegulatoryRegion {
	  my $bioSeqInput = shift;
	  my @buffer      = split(/\n/,$bioSeqInput);
	  my $seqName     = undef;
	  my $fileName    = undef;
	  my $result      = undef;
	  foreach my $line (@buffer) {
	  	  chomp $line;
	  	  if($line =~ /^>(\w+)/) {
	  	  	  $seqName = $1;
	  	  	  next;
	  	  }
	  	  else {
	  	  	  $line =~ s/\s+//g;
	  	  	  $line =~ s/\W+//g;  
	  	  }
	  	  $result->{$seqName} .=$line;
	  	  	
	  }
	  $fileName = generateRandomFileName();
	  my $rootFileDir = '/home/www/website/cardiosignal/temp/';
    $fileName       =$rootFileDir.$fileName;
	  my $fh = FileHandle->new(">$fileName");
	  foreach my $seqID (keys %{$result}) {
	  	  $fh->print(">$seqID\n");
	  	  $fh->print("$result->{$seqID}\n");
	  }
	  $fh->close;
	  return $fileName;  
}

sub generateRandomFileName() {
	  my ($sec,$min,$hour,$mday,$mon,$year_off,$wday,$yday,$isdat) = localtime();
    my $randomTime   = $sec.$min.$hour.$mday.$mon.$year_off.$wday.$yday.$isdat;
    my $range        = 10000;
    my $randomNumber = int(rand($range));
    my $randomFileName = $randomTime.$randomNumber;
    return $randomFileName;
}

#-------------------------------------------------------------------------------
# @parameter
# conservedMotifArrayRef
# the array reference of conserved motif position;
# the result of scanConservedMotif<- function
# @return
# the hash reference

sub formatHTMLtagHashRef {
    my $conservedMotifArrayRef   = shift;
    my $matrix                   = shift;
    my $formatedHTML             = shift;
    $formatedHTML                ||= undef;
    my $matrixLength             = $matrix->{'length'};
    
    foreach my $position (@{$conservedMotifArrayRef}) {
    	  my $htmlTag  = "<span class=\"motif\">";
        push(@{$formatedHTML->{$position}}, $htmlTag);
        $position  = $position + $matrixLength;
        $htmlTag   = "</span>";
        push(@{$formatedHTML->{$position}}, $htmlTag);
    	  
    }
    return $formatedHTML; 
}

sub seqIO2HashArrayRef {
	  my $bioSeqIOHashRef      = shift;
	  my $bioSeqIOHashArrayRef = undef;
	  foreach my $ID (keys %{$bioSeqIOHashRef}) {
	      my $string = $bioSeqIOHashRef->{$ID};
	      while ($string   =~ s/(\S)//) {
    	      my $letter = $1;
            push(@{$bioSeqIOHashArrayRef->{$ID}}, $letter);
        }
	  }
	  return $bioSeqIOHashArrayRef;
}

sub generatePREtag {
	  my $bioSeqIOHashRef      = shift;
	  my $bioSeqIOHashArrayRef = seqIO2HashArrayRef($bioSeqIOHashRef);
	  my @seqIDs               = keys %{$bioSeqIOHashArrayRef};
	  my $seqLength            = length($bioSeqIOHashRef->{$seqIDs[0]});
	  #my $lastStringIndex      = $seqLength - 1;
	  my $outputStringLength   = 70;
	  my $formatedHTMLtagHash  = shift;
	  my $state                = 0;
	  my $tims                 = int(($seqLength - $seqLength%$outputStringLength)/$outputStringLength);
	  if($seqLength%$outputStringLength){
	  	  $tims = $tims + 1;
	  }
	  
	  
	  for(my $i=0; $i < $tims;$i++) {
	  	  if($i != 0) {
	  	  	  print "\n\n";
	  	  }
	  	  my $startP = $i*$outputStringLength;
	  	  my $endP   = $startP + $outputStringLength;
	  	  if($endP > $seqLength) {
	  	  	  $endP = $seqLength;
	  	  }
	  	  foreach my $ID (@seqIDs) {
	  	  	  for(my $j = $startP;$j < $endP; $j++) {
	  	  	      if($j == $startP) {
	  	  	      	  print $ID,"\t\t";
	  	  	      }
	  	  	      my $motifPosition = $j + 1;
	  	          if(exists $formatedHTMLtagHash->{$motifPosition}) {
	  	  		          foreach my $item (@{$formatedHTMLtagHash->{$motifPosition}}) {
	  	  		  	          print $item;
	  	  		          }
	  	  	     }
	  	  	     print $bioSeqIOHashArrayRef->{$ID}->[$j];
	  	  	
	  	      }
	  	      print "\n";
	  	  }
	  	  
	  }
	  
}