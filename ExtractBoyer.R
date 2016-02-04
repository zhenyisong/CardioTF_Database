# Boyer dataset,
# saved file:
#
boyer_RNA_seq <- read.table("genes.fpkm_tracking",header = TRUE,sep = "\t");
cardioGenes <- subset(boyer_RNA_seq,CP_FPKM >= 1 | CM_FPKM >= 1);
caridioGenename <- cardioGenes$gene_short_name;
write.table(caridioGenename,file = 'boyer.data',row.names = FALSE);