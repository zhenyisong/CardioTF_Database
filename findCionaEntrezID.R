library(biomaRt);
mart<- useDataset("hsapiens_gene_ensembl", useMart("ensembl"));
ciona.human <- read.csv('ci_hs_orthologs.csv',header = T);
genes <- ciona.human$ensemble_id;
human.EntrezID.ciona <- getBM(filters= "ensembl_gene_id", attributes= c("ensembl_gene_id", "entrezgene", "description"),values=genes,mart= mart);
write.table(human.EntrezID.ciona,file = 'ensembl_entrez.ciona',row.names = F, col.names = F,sep = "\t");