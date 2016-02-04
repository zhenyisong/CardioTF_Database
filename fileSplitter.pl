use strict;
use File::Find;

# split functional elements literature into two parts
# 

my $localdir  = 'functional_elemental_raw_data';
my $dataset_I = 'fe_raw_data_I';
my $dataset_II = 'fe_raw_data_II';
my @array;
find( sub { push (@array,$File::Find::name) if /\.txt$/ },$localdir );

my $command = undef;
foreach my $file(@array) {
    my $file_state = int(rand(2));  
    #print $file_state,"\n";
    if($file_state == 1) {
    	  $command = "cp $file $dataset_I";
    	  system($command);
    }
    else {
    	  $command = "cp $file $dataset_II";
    	  system($command);
    }
}
