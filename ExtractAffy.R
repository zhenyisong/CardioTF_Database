# Author Yisong Zhen
# Since 2013-12-31
# Original data is from NCBI GEO database:
# 		http://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE1479
#
# To select genes which are expressed by MAS5 alorithm
# verified in any one of stages
# saved file:
#      cardiogenomics.data
#      any gene symbol on one line
#
# methods:
# http://blog.csdn.net/hzs106/article/details/12016363
# http://www.biostars.org/p/52725/
# 

library(affy);
library(annotate);
library(mouse4302.db);

raw.data <- ReadAffy();
mas5calls.data <- mas5calls(raw.data);
mas5calls.exprs <- exprs(mas5calls.data);
head(mas5calls.exprs);
probeID.set <- apply(mas5calls.exprs, 1, function(x) any(x == "P"));
present.probes.names <- names( probeID.set[probeID.set] );

gene.name.set <- c();

for( i in 1:length(present.probes.names)) {
    gene.name <-mget(present.probes.names[i],mouse4302SYMBOL);
    gene.name.set <-c(gene.name.set,gene.name);
}
write.table(gene.name.set,file="cardiogenomics.data",col.names = FALSE);