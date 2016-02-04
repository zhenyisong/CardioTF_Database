PNAS_RNA_seq <- read.table("genes.fpkm_tracking",header = TRUE,sep = "\t");
cardioGenes <- subset(PNAS_RNA_seq,Sham_FPKM >= 1);
caridioGenename <- cardioGenes$gene_short_name;
write.table(caridioGenename,file = 'PNAS_adult.data',row.names = FALSE);
