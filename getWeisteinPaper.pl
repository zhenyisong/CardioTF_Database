use FileHandle;
use strict;

my $journal_add  = 'cardio_journal.txt';
my $journal_list = readCardioJournallist($journal_add);
my $journal_index = 'cardio_journal_index';
my $output_handle = FileHandle->new(">$journal_index");
my $counter       = 0;

foreach my $journal (@{$journal_list}) {
	        $counter++;
	        my $result = `perl ncbi_search.pl -q \'$journal\[jour\]\'  -o $counter.cardio.xml -d pubmed -r XML`;
	        $output_handle->print("$journal\t$counter\n");
          #my $query      = 'perl ncbi_search.pl -q';
          #$query         = $query." $journal\[jour\]";
          #my $query      = "$journal\[jour\]";
          #$query         = $query."  -o $journal.cardio.xml -d pubmed -r XML";
          #system($query);
          #print $journal,"\n";
          #print $query,"\n";
}

$output_handle->close;

print "you complete the journal downloading!\n";

sub readCardioJournallist {
	  my $file_name   = shift;
	  my $file_handle = FileHandle->new($file_name);
	  my $list_ref    = undef;
	  while(my $line = $file_handle->getline) {
	  	  chomp($line);
	  	  push @{$list_ref},$line;
	  	  
	  }
	  $file_handle->close;
	  return $list_ref;
}



=head
cardia_journal <- read.table('cardio_journal_distribution',head = F,sep = "\t");
top10 <- cardia_journal$V1[order(cardia_journal$V2,decreasing = T)[1:10]];
sum(cardia_journal$V2[order(cardia_journal$V2,decreasing = T)[1:10]])/sum(cardia_journal$V2);
write.table(cardia_journal$V1[cardia_journal$V2 >= 6],file = "cardio_journal.txt",quote = F,row.names = F,col.names = F);
=cut
