# The data for this project come from this source: http://groupware.les.inf.puc-rio.br/har. 
# If you use the document you create for this class for any purpose please cite them as they have been 
# very generous in allowing their data to be used for this kind of assignment.

# Human Activity Recognition

# What you should submit
# The goal of your project is to predict the manner in which they did the exercise. 
# This is the "classe" variable in the training set. You may use any of the other variables 
# to predict with. You should create a report describing how you built your model, how you 
# used cross validation, what you think the expected out of sample error is, and why you made 
# the choices you did. You will also use your prediction model to predict 20 different test cases.

# Reproducibility
# Due to security concerns with the exchange of R code, your code will not be run during the 
# evaluation by your classmates. Please be sure that if they download the repo, they will be 
# able to view the compiled HTML version of your analysis.
# required package: lattice
# required package: ggplot2

library(caret)
library(rpart)
library(rpart.plot)
library(RColorBrewer)
library(randomForest)

# Setting a seed number for Reproducibility
set.seed(99876)

# 
# Pull the Training data into the trainData variable into a memory data frame
#
trainData <- read.table("https://d396qusza40orc.cloudfront.net/predmachlearn/pml-training.csv",
                         header=TRUE, sep=",", na.strings=c("NA","#DIV/0!",""), dec=".", strip.white=TRUE)

summary(trainData)

#
# Pull the Test data into the testData variable into a memory dataframe
#
testData <- read.table("https://d396qusza40orc.cloudfront.net/predmachlearn/pml-testing.csv",
                       header=TRUE, sep=",", na.strings=c("NA","#DIV/0!",""), dec=".", strip.white=TRUE)
summary(testData)

#
# Now, let us partition the trainData into myTrain and myTest for analysis and formula fitting
#
myTrain <- createDataPartition(y=trainData$classe, p=0.60, list=FALSE)
myTraining <- trainData[myTrain, ]
myTesting <- trainData[-myTrain, ]

dim(myTraining) 
dim(myTesting)

#
# Now I want to cleanup the near zero variance
# Get rid of the near zero variances as they will cause poor results in my final
# prediction model.
#
myTrainingNZV <- nearZeroVar(myTraining, saveMetrics=TRUE)
myTrainingCleanup <- myTraining[!myTrainingNZV$nzv]

dim(myTrainingCleanup)

#
# Get rid of the first column.  X is a sequential number for each row so not really going to help 
# come up with a predictive model
#
myTrainingCleanup <- myTrainingCleanup[c(-1)]

