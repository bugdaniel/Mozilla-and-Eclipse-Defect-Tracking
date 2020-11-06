#!/usr/bin/env Rscript
# Copyright (c) 2015. All rights reserved.
####################################################################################################
# Proj: Business Analytics Assignment 5
# Desc: Predicting whether a bug will be fixed based on various bug-inherent features
# Auth: Gaegauf Luca, Salamanca Daniel
# Date: 2015/12/14
####################################################################################################
# Clear environment
rm(list = ls())
.libPaths(c( .libPaths(), "~/LucaLibrary"))

# Set up workspace 
setwd("/Users/LucaPuppy/Documents/Uni Economics/M_Semester_9/Business_Analytics/EX5/Eclipse")
# setwd("~/Desktop/")

# Load libraries
library(data.table)
library(ROCR)
library(pROC)
library(FSelector)
library(caret)
library(klaR)
library(MASS)

# Read and format data #############################################################################
dt.input <- as.data.table(read.table("outputFile.dat", header = FALSE, 
                                     col.names = c("id", "fixed", "reopened", "successRateAssignee", "timeOpened",
                                                   "successRateReporter", "assignmentNumber", "editionNumber", "linux",
                                                   "macOS", "all", "P1", "P2", "P3", "P4", "P5")))

# Format data
dt.input$fixed <- as.factor(make.names(dt.input$fixed))
dt.input$reopened <- as.factor(make.names(dt.input$reopened))
dt.input$linux <- as.factor(make.names(dt.input$linux))
dt.input$macOS <- as.factor(make.names(dt.input$macOS))
dt.input$all <- as.factor(make.names(dt.input$all))
dt.input$P1 <- as.factor(make.names(dt.input$P1))
dt.input$P2 <- as.factor(make.names(dt.input$P2))
dt.input$P3 <- as.factor(make.names(dt.input$P3))
dt.input$P4 <- as.factor(make.names(dt.input$P4))
dt.input$P5 <- as.factor(make.names(dt.input$P5))
str(dt.input)

# Check the balance of the label
prop.table(table(dt.input$fixed))

# Set the DV variable and the id variable name
DV.var <- "fixed"
ID.var <- "id"

# Preprocessing ####################################################################################
# Set formula
formuWithPrior <- as.simple.formula(names(dt.input)[!(names(dt.input) %in% c(ID.var, DV.var))], "fixed")

# Sample data in train and test set
set.seed(123457)
train_ind <- createDataPartition(dt.input[[DV.var]], p = 0.6, list = FALSE)
trainset <- dt.input[train_ind, ]
testset <- dt.input[-train_ind, ]

# Run a baseline logistic model with the priority features.
log.withPrior.model <- glm(formu, data = trainset[, names(testset) != ID.var, with = FALSE], family = binomial(link = 'logit'))
log.withPrior.probs <- predict(log.withPrior.model, testset[, names(testset) != DV.var, with = FALSE], type = "response")
log.withPrior.ROC <- roc(response = testset[[DV.var]], predictor = log.withPrior.probs, levels = levels(testset[[DV.var]]))
# We can see from these results that the classification into priority class is
# done with relative accuracy. For the rest of the models we are going to
# exclude the priority features. This is because we aim to improve the
# prioritization process.

# Modelling ########################################################################################
# Sample the subset into a 60/40 train/test set
set.seed(123457)
train_ind <- createDataPartition(dt.input[[DV.var]], p = 0.6, list = FALSE)
trainset <- dt.input[train_ind, ]
testset <- dt.input[-train_ind, ]
rm(train_ind)

# Set the control. Due to the computational cost, we are going to use a simple
# cross validation technique for the modelling process. We however include the
# opportunity to use a repeated cross validation technique instead.
control <- trainControl(
  method = 'cv', # Hash for repeated cross validation
  #method = 'repeatedcv', # Unhash
  number = 3,
  #repeats = 5,
  savePredictions = TRUE,
  classProbs = TRUE,
  index = createFolds(trainset$fixed, 3), # Hash
  #index = createMultiFolds(trainset$fixed, k = 3, times = 5), # Unhash
  summaryFunction = twoClassSummary
)

# Set the formula without the priority features
formuWithoutPrior <- as.simple.formula(names(dt.input)[!(names(dt.input) %in% c(ID.var, DV.var, "P1", "P2", "P3", "P4", "P5"))], "fixed")

# The following section takes the following form:
# Naive Bayes -------------------------------------------------------------
# Train the model
set.seed(123457)
nb.model <- train(formuWithoutPrior, data = trainset[, names(testset) != ID.var, with = FALSE], method = "nb", metric = "ROC", trControl = control)
# Use the trained model to predict on the test features
nb.probs <- predict(nb.model, testset[, names(testset) != DV.var, with = FALSE], type = "prob")
# Compare the predictions to the test labels
nb.ROC <- roc(response = testset[[DV.var]], predictor = nb.probs$X1, levels = levels(testset[[DV.var]]))
# Get AUC score
nb.ROC$auc

# Logistic regression -----------------------------------------------------
log.model <- glm(formuWithoutPrior, data = trainset[, names(testset) != ID.var, with = FALSE], family = binomial(link = 'logit'))
log.probs <- predict(log.model, testset[, names(testset) != DV.var, with = FALSE], type = "response")
log.ROC <- roc(response = testset[[DV.var]], predictor = log.probs, levels = levels(testset[[DV.var]]))
log.ROC$auc

# Support vector machine --------------------------------------------------
# Linear SVM
set.seed(123457)
svm.lin.model <- train(formuWithoutPrior, data = trainset[, names(testset) != ID.var, with = FALSE], method = "svmLinear", metric = "ROC", trControl = control)
svm.lin.probs <- predict(svm.lin.model, testset[, names(testset) != DV.var, with = FALSE], type = "prob")
svm.lin.ROC <- roc(response = testset[[DV.var]], predictor = svm.lin.probs$X1, levels = levels(testset[[DV.var]]))
svm.lin.ROC$auc

# Plot preliminary results ------------------------------------------------
pdf(file="ROC_3models.pdf", width = 4.7, height = 4.7)
plot.roc(nb.ROC, type = "l", col = "firebrick", main = "ROC")
plot.roc(log.ROC, add = TRUE, col = "green3")
plot.roc(svm.lin.ROC, add = TRUE, col = "orange2")

legend('bottomright', paste(c('Naive Bayes', 'logistic Reg', 'SVM linear'), 
                            round(c(nb.ROC$auc, log.ROC$auc, svm.lin.ROC$auc), 3), sep = ": "), 
       lty = 1, 
       col = c("firebrick", "green3", "orange2"),
       bty = 'n', 
       cex = 0.8)
dev.off()

# Radial
set.seed(123457)
svm.rad.model <- train(formuWithoutPrior, data = trainset, method = "svmRadial", metric = "ROC", trControl = control)
svm.rad.probs <- predict(svm.rad.model, testset[, names(testset) != DV.var, with = FALSE], type = "prob")
svm.rad.ROC <- roc(response = testset[[DV.var]], predictor = svm.rad.probs$X1, levels = levels(testset[[DV.var]]))
svm.rad.ROC$auc

# Bagged: Random forest ---------------------------------------------------
set.seed(123457)
rf.model <- train(formuWithoutPrior, data = trainset[, names(testset) != ID.var, with = FALSE], method = "rf", metric = "ROC", trControl = control)
rf.probs <- predict(rf.model, testset[, names(testset) != DV.var, with = FALSE], type = "prob")
rf.ROC <- roc(response = testset[[DV.var]], predictor = rf.probs$X1, levels = levels(testset[[DV.var]]))
rf.ROC$auc

# Boosted: Gradient boosting machine --------------------------------------
set.seed(123457)
gbm.model <- train(formuWithoutPrior, data = trainset[, names(testset) != ID.var, with = FALSE], method = "gbm", metric = "ROC", trControl = control)
gbm.probs <- predict(gbm.model, testset[, names(testset) != DV.var, with = FALSE], type = "prob")
gbm.ROC <- roc(response = testset[[DV.var]], predictor = gbm.probs$X1, levels = levels(testset[[DV.var]]))
gbm.ROC$auc

# Boosted: Extreme gradient boost -----------------------------------------
# Linear
set.seed(123457)
xgb.lin.model <- train(formuWithoutPrior, data = trainset[, names(testset) != ID.var, with = FALSE], method = "xgbLinear", metric = "ROC", trControl = control)
xgb.lin.probs <- predict(xgb.lin.model, testset[, names(testset) != DV.var, with = FALSE], type = "prob")
xgb.lin.ROC <- roc(response = testset[[DV.var]], predictor = xgb.lin.probs$X1, levels = levels(testset[[DV.var]]))
xgb.lin.ROC$auc

# Tree
set.seed(123457)
xgb.tre.model <- train(formuWithoutPrior, data = trainset[, names(testset) != ID.var, with = FALSE], method = "xgbTree", metric = "ROC", trControl = control)
xgb.tre.probs <- predict(xgb.tre.model, testset[, names(testset) != DV.var, with = FALSE], type = "prob")
xgb.tre.ROC <- roc(response = testset[[DV.var]], predictor = xgb.tre.probs$X1, levels = levels(testset[[DV.var]]))
xgb.tre.ROC$auc

# Plot the ROCs -----------------------------------------------------------
pdf(file="ROC_allModels.pdf", width = 4.7, height = 4.7)
plot.roc(nb.ROC, type = "l", col = "firebrick", main = "ROC")
plot.roc(log.ROC, add = TRUE, col = "green3")
plot.roc(svm.lin.ROC, add = TRUE, col = "orange2")
plot.roc(svm.rad.ROC, add = TRUE, col = "pink")
plot.roc(rf.ROC, add = TRUE, col = "cyan")
plot.roc(gbm.ROC, add = TRUE, col = "black")
plot.roc(xgb.lin.ROC, add = TRUE, col = "grey")
plot.roc(xgb.tre.ROC, add = TRUE, col = "navy")

legend('bottomright', paste(c('Naive Bayes', 'logistic Reg', 'SVM linear', 
                              'SVM radial', 'Random Forest',
                              'gbm', 'XGLin', 'XGBoost'), 
                            round(c(nb.ROC$auc, log.ROC$auc, svm.lin.ROC$auc,
                                    svm.rad.ROC$auc, rf.ROC$auc,
                                    gbm.ROC$auc, xgb.lin.ROC$auc, xgb.tre.ROC$auc), 3), sep = ": "), 
       lty = 1, 
       col = c("firebrick", "green3", "orange2", "pink", "cyan", "black", "grey", "navy"),
       bty = 'n', 
       cex = 0.8)
dev.off()

# Variable importance -----------------------------------------------------
varImp(nb.model)
varImp(log.model)
varImp(svm.lin.model)
varImp(svm.red.model)
varImp(rf.model)
varImp(gbm.model)
varImp(xgb.lin.model)
varImp(xgb.tre.model)

# Identifying bugs with high likelihood of being fixed --------------------
# We use the naive Bayes because out of the 3 prescribed models it performed the best.
# Collect the sensitivities, and specificities for each threshold
nb.predictor <- data.table(thresh = nb.ROC$thresholds, sens = nb.ROC$sensitivities, spec = nb.ROC$specificities)

# Determine the threshold value where sensitivity == specificity 
# THRESHOLD == 0.565
treshold <- unique(round(nb.predictor[round(sens,4) == round(spec,4), thresh], 3))

# Based on this threshold, predict which bugs are likely to be fixed.
nb.probs <- data.table(id = testset$id, probFixed = nb.probs$X1, trueState = testset$fixed)
nb.probs[, predState := ifelse(probFixed >= treshold, "fixed", "unfixed")]
nb.probs$trueState <- as.character(nb.probs$trueState)
nb.probs[, trueState := ifelse(trueState == "X1", "fixed", "unfixed")]
confusionMatrix(data = nb.probs[, predState], reference = nb.probs[, trueState], positive = "fixed")

# Export the results
write.csv(nb.probs, file = "predBugsFixed_NaiveBayes.csv")
####################################################################################################
#                                               END                                                #
####################################################################################################