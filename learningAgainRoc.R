library(ROCR);
# https://stat.ethz.ch/pipermail/r-help/2009-March/193207.html
# http://stats.stackexchange.com/questions/29719/how-to-determine-best-cutoff-point-and-its-confidence-interval-using-roc-curve-i
# http://stats.stackexchange.com/questions/44820/replicating-a-plot-from-the-rocr-website
# https://hopstat.wordpress.com/2014/12/19/a-small-introduction-to-the-rocr-package/
predictions <- read.table("output.predictions",head = FALSE);
labels      <- read.table("output.labels",head = FALSE);
pred    <- prediction( as.matrix(predictions), as.matrix(labels) );
perf <- performance(pred,"tpr","fpr");
plot(perf);
plot(perf,lwd=3,avg="vertical",spread.estimate="boxplot",colorize=T,add=TRUE);


# Figure 1.
perf <- performance( pred, "tpr", "fpr" );
plot( perf,colorize=T);



perf <- performance(pred, "cal", window.size=50);
plot(perf);

# Figure 2.

perf <- performance(pred, "prec", "rec");
plot(perf, colorize=T);

perf <- performance(pred, "acc")
plot(perf, avg= "vertical", spread.estimate="boxplot", show.spread.at= seq(0.1, 0.9, by=0.1));

perf.acc<-performance(pred,"acc");

cutoff_list = c()
acc_list    = c()
for(i in 1:10) {
    cutoff.list.acc     <- unlist(perf.acc@x.values[[i]]);
    optimal.cutoff.acc  <-cutoff.list.acc[which.max(perf.acc@y.values[[i]])];
    cutoff_list = c(cutoff_list,optimal.cutoff.acc)
    acc_list    = c(acc_list, max(perf.acc@y.values[[i]]))
}
mean(cutoff_list)
sd(cutoff_list)
mean(acc_list)
sd(acc_list)

# determine the cutoff 2015-05-25
# In some applications of ROC curves, you want the point closest 
# to the TPR of \(1\) and FPR of \(0\). This cut point is ¡°optimal¡± 
# in the sense it weighs both sensitivity and specificity equally. 
# To deterimine this cutoff, you can use the code below. 
cost.perf = performance(pred, "cost")
pred@cutoffs[[1]][which.min(cost.perf@y.values[[1]])]


auc.tmp <- performance(pred,"auc"); 
auc <- as.numeric(auc.tmp@y.values);
#------------------------------------------------------------------
# second way use accuracy to determine the cutoff
# 2015-05-25
#------------------------------------------------------------------
# determine the parameter
perf.acc <- performance(pred, "acc");
acc.rocr<-max(perf.acc@y.values[[1]]);   # accuracy using rocr

#find cutoff list for accuracies
cutoff.list.acc <- unlist(perf.acc@x.values[[1]])

#find optimal cutoff point for accuracy
optimal.cutoff.acc<-cutoff.list.acc[which.max(perf.acc@y.values[[1]])];
optimal.cutoff.acc;
#------------------------------------------------------------------

#find optimal cutoff fpr, as numeric because a list is returned
optimal.cutoff.fpr<-which(perf.fpr@x.values[[1]]==as.numeric(optimal.cutoff.acc));

# find cutoff list for fpr
cutoff.list.fpr <- unlist(perf.fpr@y.values[[1]]);
# find fpr using rocr
fpr.rocr<-cutoff.list.fpr[as.numeric(optimal.cutoff.fpr)]

#find optimal cutoff fnr
optimal.cutoff.fnr<-which(perf.fnr@x.values[[1]]==as.numeric(optimal.cutoff.acc))
#find list of fnr
cutoff.list.fnr <- unlist(perf.fnr@y.values[[1]])
#find fnr using rocr
fnr.rocr<-cutoff.list.fnr[as.numeric(optimal.cutoff.fnr)]


density_plot <- function(pred, pos=NULL, 
                         legend=c('negative', 'positive'), colors=c("red", "green")){

  stopifnot(require('ROCR'))
  stopifnot(length(pred@predictions)==1) #Multiple runs not supported
  lev <- levels(pred@labels[[1]])
  stopifnot(length(lev)==2) #Only binary classification supported for now

  if (is.null(pos)){
    pos <- lev[2]
  }
  neg <- setdiff(lev, pos)

  neg_col = colors[1]
  pos_col = colors[2]

  neg_dens <- density(pred@predictions[[1]][pred@labels[[1]]==neg])
  pos_dens <- density(pred@predictions[[1]][pred@labels[[1]]==pos])
  top <- ceiling(max(neg_dens$y, pos_dens$y))

  plot(0,0,type="n", xlim= c(0,1), ylim=c(0,top),
       xlab="Cutoff", ylab="Density",
       main="How well do the predictions separate the classes?")
  lines(neg_dens, col=neg_col)
  lines(pos_dens, col=pos_col)
  legend(0, top, legend=legend, col=c(neg_col,pos_col), lty=1)
}