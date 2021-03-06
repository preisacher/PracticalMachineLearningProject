# The data for this project come from this source: http://groupware.les.inf.puc-rio.br/har. 
# If you use the document you create for this class for any purpose please cite them as they have been 
# very generous in allowing their data to be used for this kind of assignment.

# Human Activity Recognition

# In this exercise I am going to predict the manner in which the people we have data for 
# did the exercise they ended up doing.  The variable that indicates this exercise is 
# called "classe" in the training set and that is what I will be predicting.
# The data in this analysis all came from source: http://groupware.les.inf.puc-rio.br/har.
# who have been very generous in allowing their data to be used for this kind of exercise.
# I will be using use the other variables (other than "classe") to predict with. 
# This is my report describing how I built my model, and how Iused cross validation, 
# what I think the expected out of sample error is, and why I made the choices I did. 
# I will also use my prediction model to predict 20 different test cases.
#
# Reproducibility
# Due to security concerns with the exchange of R code, my code will not be run during the 
# evaluation by you, my classmates. You will be be able to view the 
# compiled HTML version of my analysis which I will publish under Rpubs and provide a link.
#

library(caret)
library(rpart)
library(rpart.plot)
library(RColorBrewer)
library(randomForest)

set.seed(54321)

# 
# Pull the Training data into the trainData variable in memory
#
trainData <- read.table("https://d396qusza40orc.cloudfront.net/predmachlearn/pml-training.csv",
                        header=TRUE, sep=",", na.strings=c("NA","#DIV/0!",""), dec=".", strip.white=TRUE)

dim(trainData)

#
# Pull the Test data into the testData variable in memory
#
testData <- read.table("https://d396qusza40orc.cloudfront.net/predmachlearn/pml-testing.csv",
                       header=TRUE, sep=",", na.strings=c("NA","#DIV/0!",""), dec=".", strip.white=TRUE)
dim(testData)


# Cleaning the Data
# Now I want to cleanup the near zero variance
# Get rid of the near zero variances as they will cause poor results in my final
# prediction model.

trainingNZV <- nearZeroVar(trainData, saveMetrics=TRUE)
trainingCleanup <- trainData[!trainingNZV$nzv]
dim(trainingCleanup)

# Get rid of the first column.  X is a sequential number for each row so not really going to help 
# with predicting anything.

trainingCleanup <- trainingCleanup[c(-1)]

# Now, i want to get rid of variables with too many Null values. 
# For Variables that have more than a 30% threshold of Null values; I’m going to leave them out:

trainingFinal <- trainingCleanup
for(a in 1:length(trainingCleanup)) {
  if(sum(is.na(trainingCleanup[,a]))/nrow(trainingCleanup) >= .3 ) { 
    for(b in 1:length(trainingFinal)) {
      if(length(grep(names(trainingCleanup[a]), names(trainingFinal)[b]))==1) { 
        trainingFinal <- trainingFinal[,-b] 
      }   
    } 
  }
}

dim(trainingFinal)

# Partition the data for model fitting
# Now, I want to partition the trainData into a training set and a testing set
# for analysis and formula fitting.

myTrainingPartition <- createDataPartition(y=trainingFinal$classe, p=0.60, list=FALSE)
myTraining <- trainingFinal[myTrainingPartition, ]
myTesting <- trainingFinal[-myTrainingPartition, ]

dim(myTraining) 
dim(myTesting)

# I will now take the columns from myTraining that I am going to use
# in the model and only keep those columns from the testData that match.

clean <- colnames(myTraining[, -58]) 
testData <- testData[clean]

# Making sure to sync with the same class between myTraining and the testData

testData <- rbind(myTraining[2, -58] , testData) 
testData <- testData[-1,]

# Finding the best fit prediction model
# Trying the ML algorithms for prediction: Decision Tree

fit.dt <- rpart(classe ~ ., data=myTraining, method="class")

# Predicting in-sample error

predictions.dt <- predict(fit.dt, myTesting, type = "class")

# Here is the confusionMatrix to see the results of Decision Tree

confusionMatrix(predictions.dt, myTesting$classe)

# Using ML algorithms for prediction: Random Forests

fit.rf <- randomForest(classe ~. , data=myTraining)

# Predicting in-sample error

predictions.rf <- predict(fit.rf, myTesting, type = "class")

# Here is the confusionMatrix to see the results of Random Forest

confusionMatrix(predictions.rf, myTesting$classe)

plot(fit.rf)

# Plot showing the Mean Decrease Gini values indicating those predictors that are stronger 
# (with the lower values)

varImpPlot(fit.rf)

# Choice of best fit is:
# Random Forests is a better fit for predicting in this case
# Here is the prediction 
# Random Forests gave an Accuracy in the myTesting dataset of 99.87% which 
# was more accurate that from the Decision Tree. 
#
# The expected out-of-sample error is 100-99.87 = 0.13%.
#
# Since the sample error is low, this suggests to me that my prediction model is accurate
# and therefore, a good fit.

# Predictions of test data

predictions.rf.test <- predict(fit.rf, testData, type = "class")
predictions.rf.test
