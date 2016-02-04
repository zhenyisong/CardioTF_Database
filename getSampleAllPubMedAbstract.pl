use strict;

my @years_list = ("2008","2009","2010","2011","2012","2013");



foreach my $year(@years_list) {
	  my $query      = "perl ncbi_search.pl -q '$year\[dp\]'  -o $year.cardio.txt -d pubmed -r XML";
	  system($query);
	  #print $query,"\n";
}

print "well done!\n";