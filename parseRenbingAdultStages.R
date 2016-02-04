# Author Yisong Zhen 
# Since 2014-01-01 

#  renbing_tissue_TF_FPKM.table is the output of the program
#  parseGeneFPKMfile.pl.
#
library("gplots");
library("genefilter");
library(RFLPtools);
 
adult_stage_TF_RNAseq_table <- read.table("heart_tissue_TF_FPKM.table",header = FALSE, sep = "\t");

attach(adult_stage_TF_RNAseq_table);

tissue_exprs_matrix  <- cbind(V2,V3,V4,V5,V6,V7,V8,V9,V10,V11,V12,V13,V14);
rownames(tissue_exprs_matrix) <- V1;
tissue_name_list <- c('bonemarrow','cerebellum','cortex','heart','intestine','kidney','liver','lung','olfactory','placenta','spleen','testes','thymus'); 
colnames(tissue_exprs_matrix) <- tissue_name_list;

#log_transformed_matrix <- 2 * sqrt(tissue_exprs_matrix + 3/8);

sds <- rowSds(tissue_exprs_matrix);
sh  <- shorth(sds);

filtered_exprs_matrix <- tissue_exprs_matrix[sds>=sh, ];

hist(sds, breaks=50, col="mistyrose", xlab="standard deviation");

# read all heart expression matrix file 
#
adult_stage_TF_RNAseq_table <- read.table("heart_tissue_TF_FPKM.table",header = FALSE, sep = "\t");
attach(adult_stage_TF_RNAseq_table);
tissue_exprs_matrix  <- cbind(V2,V3,V4,V5,V6,V7,V8);
rownames(tissue_exprs_matrix) <- V1;
tissue_name_list <- c('ESC','MES','CP','CM','E14.5','8_weeks','2_months');
colnames(tissue_exprs_matrix) <- tissue_name_list;

sds <- rowSds(tissue_exprs_matrix);
sh  <- shorth(sds);

filtered_exprs_matrix <- tissue_exprs_matrix[sds>=sh, ];

hist(sds, breaks=50, col="mistyrose", xlab="standard deviation");

													
result<-hclust( as.dist( 1-cor(t( filtered_exprs_matrix ), method = 'spearman')),method='complete');

write.hclust(result, 'regeneration.result', h=5,prefix = 'csg',k=12);

genefinder(filtered_exprs_matrix, "Hey2", 10, method = "euc");

#heatmap(mtscaled[cutree(hc.rows,k=2)==2,], Colv=as.dendrogram(hc.cols), scale='none')

#heatmap.2(filtered_exprs_matrix[cutree(result, k=5)==4,], scale='none');

pdf('junk.pdf',height=250,width=45);

#rowname_lab <- rownames(filtered_exprs_matrix)[cutree(result, k=12)== 1];

heatmap.matrix <- filtered_exprs_matrix[cutree(result, k = 10)== 1,];
heatmap.rowlab <- rownames(filtered_exprs_matrix)[cutree(result, k=10)== 1];
heatmap.2(heatmap.matrix, col=redgreen(75), scale='row', 
													 Colv = FALSE, density.info='none',key=FALSE, trace='none', 
													cexRow=0.7,distfun= function(d) as.dist(1 - cor(t(d),method = 'spearman')),
													hclustfun = function(d) hclust(dist(d,method = "euclidean"), method = 'complete'),
													dendrogram = 'none',labRow = as.character(heatmap.rowlab),
													 lmat=rbind( c(0, 3), c(2,1), c(0,4) ), lhei=c(0.25, 10, 0.25 ));
													 
													 
dev.off();
#------------------------------------------------------------------------------
# to check the normalized state

adult_stage_RNAseq_table <- read.table("genes.fpkm_tracking",header = TRUE, sep = "\t");
attach(adult_stage_RNAseq_table);
all_tissue_exprs_matrix <- cbind( bonemarrow_FPKM,cerebellum_FPKM,cortex_FPKM,heart_FPKM,intestine_FPKM,kidney_FPKM,liver_FPKM,lung_FPKM,olfactory_FPKM,placenta_FPKM,spleen_FPKM,testes_FPKM,thymus_FPKM );
rownames(all_tissue_exprs_matrix) <- gene_short_name;
tissue_name_list <- c('bonemarrow','cerebellum','cortex','heart','intestine','kidney','liver','lung','olfactory','placenta','spleen','testes','thymus'); 
colnames(all_tissue_exprs_matrix) <- tissue_name_list;

#log_transformed_matrix <- 2 * sqrt(all_tissue_exprs_matrix + 3/8);

log_transformed_matrix <- 2 * sqrt(all_tissue_exprs_matrix + 3/8);

log_transformed_matrix <- log(tissue_exprs_matrix);

#------------------------------------------------------------------------------
# all TF across 13 tissues heatmap
#------------------------------------------------------------------------------

# this may not work! I discard the code later. Yisong Zhen
#

pdf(file = "zhen3.temp.pdf");
#all_TFs_transformed_matrix <- 2 * sqrt(tissue_exprs_matrix + 3/8);

heatmapResult<-heatmap.2(filtered_exprs_matrix, col=redgreen(75), scale='row', 
													Rowv = TRUE,Colv = TRUE, density.info='none',key=FALSE, trace='none', 
													cexRow=0.1,distfun= function(d) as.dist(1 - cor(t(d),method = 'spearman')),
													hclustfun = function(d) hclust(dist(d,method = "euclidean"), method = 'complete'),
													dendrogram = 'column',
													lmat=rbind( c(0, 3), c(2,1), c(0,4) ), lhei=c(0.25, 10, 0.25 ) );
dev.off();

													
write.csv(all_TFs_transformed_matrix, file = 'zhen3.temp');
													
#------------------------------------------------------------------------------
													
													



hey2_exprs <- tissue_exprs_matrix["Tcf15",];
par(ps = 11, cex = 1, cex.main = 1);                                       
barplot(hey2_exprs, names.arg = tissue_name_list,ylab = 'FPKM');


#---------------------------------------------------------------------------------------
# Figure 
#


heart_TF_name <- read.table('cardiac_lineage_TF.result',header = FALSE,sep = "\t");
heart_TF_exprs_matrix <- tissue_exprs_matrix[as.character(heart_TF_name$V1),];

tao_vector <- apply(heart_TF_exprs_matrix, 1 , tissue_tao);

tissue_tao <- function (x)  {
   max_value <- max(x);
   sum = 0;
   N <- length(x);
   for( i in 1:N) {
      sum = sum + ( 1 - x[i]/max_value );
   }
   return (sum/(N - 1));
}

heart_TF_exprs_matrix_new <- cbind(heart_TF_exprs_matrix,tao_vector);

#write.csv(heart_TF_exprs_matrix_new, file = "zhen3.temp");

#hr <- hclust(as.dist(1 - cor(t(heart_TF_exprs_matrix), method='pearson')), method='complete');

transformed_matrix <- 2 * sqrt(heart_TF_exprs_matrix + 3/8);
transformed_matrix <- heart_TF_exprs_matrix;
log_transformed_matrix <- log(heart_TF_exprs_matrix);
boxplot(log_transformed_matrix);
boxplot(transformed_matrix );

heatmapResult<-heatmap.2( transformed_matrix, col=redgreen(75), scale='row', 
													Rowv = TRUE,Colv = TRUE, density.info='none',key=FALSE, trace='none', 
													cexRow=0.1,distfun= function(d) as.dist(1 - cor(t(d),method = 'spearman')),
													hclustfun = function(d) hclust(dist(d,method = "euclidean"), method = 'complete'),
													dendrogram = 'column',labRow=heart_TF_name$V1,
													lmat=rbind( c(0, 3), c(2,1), c(0,4) ), lhei=c(0.25, 10, 0.25 ) );
