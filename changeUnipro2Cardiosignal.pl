use FileHandle;
use File::Find;
use strict;

my $unipro_dir  = '../publicData/uniprobe_All_PWMs/';
my @unipro_array;
find( sub { push (@unipro_array,$File::Find::name) if /\.txt$/ || /\.pwm$/ },$unipro_dir);

foreach my $pwm_file(@unipro_array) {
	  my $file_handle  = FileHandle->new($pwm_file);
	  my $pwm_hash_ref = undef;
	  print $pwm_file,"\n";
	  
	  while(my $line = $file_handle->getline()) {
	  	  if($line =~ /^A/) {
	  	  	  my @buffer = split/\t/,$line;
	  	  	  $pwm_hash_ref->{"A"} = [@buffer[1..$#buffer]];
	  	  }
	  	  if($line =~ /^C/) {
	  	  	  my @buffer = split/\t/,$line;
	  	  	  $pwm_hash_ref->{"C"} = [@buffer[1..$#buffer]];
	  	  }
	  	  if($line =~ /^G/) {
	  	  	  my @buffer = split/\t/,$line;
	  	  	  $pwm_hash_ref->{"G"} = [@buffer[1..$#buffer]];
	  	  }
	  	  if($line =~ /^T/) {
	  	  	  my @buffer = split/\t/,$line;
	  	  	  $pwm_hash_ref->{"T"} = [@buffer[1..$#buffer]];
	  	  }
	  }
	  $file_handle->close;
	  my $array_index = scalar @{$pwm_hash_ref->{"T"}};
	  $array_index    = $array_index - 1;
	  my $newfile     = $pwm_file.'_cardiosignal_indiana';
	  my $cardiosignal_filehandle = FileHandle->new(">$newfile");
	  $cardiosignal_filehandle->print("A\tC\tG\tT\n");
	  foreach my $i (0..$array_index) {
	  	  
	  	  my $A = int ($pwm_hash_ref->{'A'}->[$i] * 100);
	  	  my $C = int ($pwm_hash_ref->{'C'}->[$i] * 100);
	  	  my $G = int ($pwm_hash_ref->{'G'}->[$i] * 100);
	  	  my $T = int ($pwm_hash_ref->{'T'}->[$i] * 100);
	  	  if($A + $C + $G + $T == 100 ) {
	  	  	  $cardiosignal_filehandle->print("$A\t$C\t$G\t$T\n");
	  	  } elsif($A + $C + $G + $T > 100 ) {
	  	  	 my $residue = $A + $C + $G + $T - 100;
	  	  	 my $max     = findMax($A,$C,$G,$T);
	  	  	 if($A == $max) {
	  	  	 	  $A = $A - $residue;
	  	  	 } elsif($G == $max) {
	  	  	 	  $G = $G - $residue;
	  	  	 } elsif($C == $max) {
	  	  	 	  $C = $C - $residue;
	  	  	 } elsif($T == $max) {
	  	  	 	  $T = $T - $residue;
	  	  	 }
	  	  	 $cardiosignal_filehandle->print("$A\t$C\t$G\t$T\n");
	  	  	 
	  	  } elsif( $A + $C + $G + $T < 100) {
	  	  	 my $residue = $A + $C + $G + $T - 100;
	  	  	 my $max     = findMax($A,$C,$G,$T);
	  	  	 if($A == $max) {
	  	  	 	  $A = $A - $residue;
	  	  	 } elsif($G == $max) {
	  	  	 	  $G = $G - $residue;
	  	  	 } elsif($C == $max) {
	  	  	 	  $C = $C - $residue;
	  	  	 } elsif($T == $max) {
	  	  	 	  $T = $T - $residue;
	  	  	 }
	  	  	 $cardiosignal_filehandle->print("$A\t$C\t$G\t$T\n");
	  	  }
	  }
	  
}

sub findMax {
    my ($max, @vars) = @_;
    for (@vars) {
        $max = $_ if $_ > $max;
    }
    return $max;
}

sub findMin {
    my ($min, @vars) = @_;
    for (@vars) {
        $min = $_ if $_ < $min;
    }
    return $min;
}