
# http://stackoverflow.com/questions/9981929/how-to-display-all-x-labels-in-r-barplot
# http://stackoverflow.com/questions/10286473/rotating-x-axis-labels-in-r-for-barplot
# http://cran.r-project.org/doc/FAQ/R-FAQ.html#How-can-I-create-rotated-axis-labels_003f


#
#
# measurement of 13 tissues expression pattern
#

adult_stage_RNAseq_table <- read.table("genes.fpkm_tracking",header = TRUE, sep = "\t");
attach(adult_stage_RNAseq_table);
tissue_exprs_matrix <- cbind( bonemarrow_FPKM,cerebellum_FPKM,cortex_FPKM,heart_FPKM,intestine_FPKM,kidney_FPKM,liver_FPKM,lung_FPKM,olfactory_FPKM,placenta_FPKM,spleen_FPKM,testes_FPKM,thymus_FPKM );
rownames(tissue_exprs_matrix) <- gene_short_name;
tissue_name_list <- c('bonemarrow','cerebellum','cortex','heart','intestine','kidney','liver','lung','olfactory','placenta','spleen','testes','thymus'); 
colnames(tissue_exprs_matrix) <- tissue_name_list;



hey2_exprs <- tissue_exprs_matrix["Tcf15",];
par(ps = 11, cex = 1, cex.main = 1);                                       
x <- barplot(hey2_exprs, ylab = 'FPKM',xaxt = "n",  xlab = "");
#axis(1, labels = FALSE);
#text(1:13, par("usr")[3] - 0.75, srt = 60, adj = 1,labels = tissue_name_list, xpd = TRUE);
text(cex = 1, x = x - 0.35, y = - 0.2 , tissue_name_list, xpd = TRUE, srt = 39);


#-------------------- Part II ---------------------------------------------------
#  read all heart expression file
#--------------------------------------------------------------------------------

# Part II 1.0
all_stages_Heart_table <- read.table("genes.fpkm_tracking",header = TRUE, sep = "\t");
attach(all_stages_Heart_table);
heart_exprs_matrix <- cbind(ECS_FPKM, MES_FPKM, CP_FPKM, CM_FPKM, Renbing_E14.5_FPKM, Renbing_8_weeks_FPKM ,PNAS_2_months_FPKM);
rownames(heart_exprs_matrix) <- gene_short_name;
tissue_name_column <- c('embryonic stem cell','mesoderm cell','cardiac progenitor','nacent cardiomyocyte','Renbing_E14.5_heart','Renbing_8_weeks','PNAS_2_month_heart');

# PartII 2.0
hey2_exprs <- heart_exprs_matrix["4933413G19Rik,Foxm1",];
par(ps = 11, cex = 1, cex.main = 1);                                       
x <- barplot(hey2_exprs, ylab = 'FPKM',xaxt = "n",  xlab = "",main = 'Heart RNA-seq Combo');
#axis(1, labels = FALSE);
#text(1:13, par("usr")[3] - 0.75, srt = 60, adj = 1,labels = tissue_name_list, xpd = TRUE);
text(cex = 0.8, x = x - 0.35, y = -1.45, tissue_name_column, xpd = TRUE, srt = 39);



#-------------------- Part III ---------------------------------------------------
#  read four E14.5 embryonic stage tissues expression file
#---------------------------------------------------------------------------------

embryonic_stage_RNAseq_table <- read.table("genes.fpkm_tracking",header = TRUE, sep = "\t");
attach(embryonic_stage_RNAseq_table);
tissue_exprs_matrix <- cbind( E14.5_Brain_FPKM, E14.5_Heart_FPKM, E14.5_Limb_FPKM, E14.5_Liver_FPKM );
rownames(tissue_exprs_matrix) <- gene_short_name;
tissue_name_list <- c('E14.5_Brain','E14.5_Heart','E14.5_Limb','E14.5_Liver'); 
colnames(tissue_exprs_matrix) <- tissue_name_list;



hey2_exprs <- tissue_exprs_matrix["Tcf15",];
par(ps = 11, cex = 1, cex.main = 1);                                       
x <- barplot(hey2_exprs, ylab = 'FPKM',xaxt = "n",  xlab = "");
#axis(1, labels = FALSE);
#text(1:13, par("usr")[3] - 0.75, srt = 60, adj = 1,labels = tissue_name_list, xpd = TRUE);
text(cex = 1, x = x - 0.35, y = - 0.2 , tissue_name_list, xpd = TRUE, srt = 39);