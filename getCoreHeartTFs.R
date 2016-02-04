# Author Yisong Zhen 
# since  2014-05-08
# update 2015-06-18 

#  heart_tissue_TF_FPKM.table is the output of the program
#  parseGeneFPKMfile.pl.
#
library("gplots");
library("genefilter");
library(RFLPtools);

setwd("E:\\CardioSignal\\publicData");

adult_stage_TF_RNAseq_table <- read.table("heart_tissue_TF_FPKM.table",header = FALSE, sep = "\t");

attach(adult_stage_TF_RNAseq_table);

tissue_exprs_matrix  <- cbind(V2,V3,V4,V5,V6,V7,V8,V9,V10,V11,V12,V13,V14);
rownames(tissue_exprs_matrix) <- V1;
tissue_name_list <- c('bone marrow','cerebellum','cortex','heart','intestine','kidney','liver','lung','olfactory','placenta','spleen','testes','thymus'); 
colnames(tissue_exprs_matrix) <- tissue_name_list;

log_transformed_matrix <- log(tissue_exprs_matrix + 1);
#log_transformed_matrix <- 2 * sqrt(tissue_exprs_matrix + 3/8);

# Figure 1.
setwd("E:\\CardioSignal\\publicData\\coreTFs");
coreHeartTFsname <- read.table("cardiacCoreTFs.final.table");
coreHeartTFs <- log_transformed_matrix[coreHeartTFsname$V1,];
boxplot(coreHeartTFs,cex.axis=0.8,las =1 );

# Figure 2.

NoHeartTFsname <- read.table("NoHeartTFs.table");
NoHeartTFs <- log_transformed_matrix[NoHeartTFsname$V1,];
boxplot(NoHeartTFs,cex.axis=0.8,las =1 );