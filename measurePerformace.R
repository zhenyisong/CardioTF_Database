library(caret);

predictions <- read.table("test.predictions",head = FALSE);
labels      <- read.table("test.labels",head = FALSE);
pred        <- factor(predictions$V1); 
lab         <- factor(labels$V1);
table(pred, lab); 
sensitivity(pred, lab); 
specificity(pred, lab); 