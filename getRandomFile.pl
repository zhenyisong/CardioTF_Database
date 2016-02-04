# since 2014-07-03
# http://www.perlmonks.org/?node_id=1869
# Fisher-Yates shuffle 

# randomly permutate @array in place
# 954 weistein positive abstract;

# 57080 negative set; we split into 2 parts;
# 45664(training_negative_set) : 11416(test_negative_set)




use File::Find;
#my $negative_dir = 'negative_raw_data';
# this is first round learning events, discarded because of too fa
# more false positive results!
##my $output_dir   = 'negative_subset_raw_data/';


my $negative_dir  = 'negative_raw_data';
my $output_dir1   = 'negative_training_data/';
my $output_dir2   = 'negative_test_data/';
#
#my $negative_dir  = 'weistein_positive_raw_data';
#my $output_dir1   = 'positive_training_data/';
#my $output_dir2   = 'positive_test_data/';

my @negative_array;
find( sub { push (@negative_array,$File::Find::name) if /\.txt$/ },$negative_dir);

fisher_yates_shuffle(\@negative_array);

#foreach my $i (0..953) {
#	  system("cp $negative_array[$i] $output_dir");
#}


foreach my $i (0..45663) {
	  system("cp $negative_array[$i] $output_dir1");
}

foreach my $i (45664..57079) {
	  system("cp $negative_array[$i] $output_dir2");
}
#
#
# Usage:
# fisher_yates_shuffle( \@array );    # permutes @array in place
#
sub fisher_yates_shuffle {
    my $array = shift;
    my $i = @$array;
    while ( --$i ) {
        my $j = int rand( $i+1 );
        @$array[$i,$j] = @$array[$j,$i];
    }
}

#fisher_yates_shuffle( \@array );    # permutes @array in place