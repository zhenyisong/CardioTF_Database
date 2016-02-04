setwd("E:\\CardioSignal\\publicData")
renbing_RNA_seq <- read.table("genes.fpkm_tracking",header = TRUE,sep = "\t");
cardioGenes <- subset(renbing_RNA_seq,heart_FPKM >= 1);
caridioGenename <- cardioGenes$gene_short_name;
write.table(caridioGenename,file = 'renbing_adult.data',row.names = FALSE);
#
# part II
#
renbing_RNA_seq <- read.table("genes.fpkm_tracking",header = TRUE,sep = "\t");
cardioGenes <- subset(renbing_RNA_seq,E14.5_Heart_FPKM >= 1);
caridioGenename <- cardioGenes$gene_short_name;
write.table(caridioGenename,file = 'renbing_embryonic.data',row.names = FALSE);