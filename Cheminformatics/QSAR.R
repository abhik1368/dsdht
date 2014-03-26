# Copyright (C) 2014 Abhik Seal <abhik1368@gmail.com>
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details. 

#=============================================================#
#                                                             #
#  Performing QSAR                                            #
#  Data Science Course                                        #
#  Abhik Seal, 02/26/2014                                     #
#  Some code taken from http://appliedpredictivemodeling.com/ #
#                                                             #
#                                                             #
#=============================================================#

# Remove all the history variables 
rm(list=ls()) 
#----------------------------------------------------
library(QSARdata)
library(caret)
library(gplots)
library(latticeExtra)
library(lattice)
library(ggplot2)

#----------------------------------------------------
# Function to compute RMSE and R2 
r2se<- function (obs,pred){
  rmse<-(mean((obs -pred)^2))^0.5 
  ssr<-sum((obs - pred)^2)
  sst<-sum((obs - mean(obs))^2)
  R2<-1-(ssr/sst)
  output<-list(RMSE=rmse,RSquared=R2)
  return(output)
}

#----------------------------------------------------
# Function to plot qsar results with ggplot2 
plotsar <-function(results){
 
myplot<-ggplot(results,aes(x=observed,y=predicted,color=factor(set),shape=factor(set)))+geom_point()+scale_colour_manual(values=c("blue", "yellow"))+
        theme(axis.ticks.y=element_line(size=1),axis.text.y=element_text(size=16),axis.ticks.length=unit(0.25,"cm"), 
              panel.background = element_rect(fill = "black", colour = NA))+
        theme(axis.title=element_text(size=12,face="bold",colour = 'white'),plot.background = element_rect(colour = 'black', fill = 'black'))+
        theme( legend.title = element_text(size = 12, face = "bold", hjust = 0, colour = 'white'),
              legend.background=element_rect(color="black",fill="black"),legend.text=element_text(size=12,color="white",face="bold"),
              axis.title.x = element_text(size = 12, colour = 'white', vjust = 1) ,axis.title.y = element_text(size = 12, colour = 'white'))+
        ggtitle("Predicted v/s test set QSAR results")+
        theme(plot.title=element_text(lineheight=.8,face="bold",color="white",size=14))+stat_smooth(span = 0.9)


return(myplot)
}


#----------------------------------------------------
# Loading data from QSARdata package.
# If you find error in loading the package download the tar file and 
# install via local install 
data(AquaticTox)
head(AquaticTox_Outcome)
data<-AquaticTox_QuickProp
q.data<-cbind(data,AquaticTox_Outcome$Activity)
head(q.data)
dim(q.data)
colnames(q.data)[51]<- "Activity"

q.data<-na.omit(q.data) # Omit rows for which data is not present

#----------------------------------------------------
# Data cleaning
descs <- q.data[, !apply(q.data, 2, function(x) any(is.na(x)) )]
#Near constant columns
descs <- descs[, !apply( descs, 2, function(x) length(unique(x)) == 1 )]

r2 <- which(cor(descs[2:50])^2 > .29, arr.ind=TRUE)

r2 <- r2[ r2[,1] > r2[,2] , ]
d <- descs[, -unique(r2[,2])]


#----------------------------------------------------
# Normalizing the data 
# Power tranform is a useful data transformation technique used to stabilize variance, make the data more normal distribution-like, 
# improve the validity of measures # of association such as the Pearson correlation between variables and for other data stabilization procedures

T <- preProcess(d[,2:dim(d)[2]],method = "BoxCox")
data <-predict(T,d[,2:dim(d)[2]])

#----------------------------------------------------
# Create training and test set
ind<-sample(2,nrow(data),replace=TRUE,prob=c(0.8,0.2))
s<-dim(data)[2]
trainset<-data[ind==1,2:s]
testset<-data[ind==2,2:s]

#----------------------------------------------------
# Use OLS to model the data
y.test <- testset$Activity
q.ols <- lm(Activity ~ . , data=trainset)
vif( lm(Activity ~ . , data=trainset))
#----------------------------------------------------
# Summarizing results
summary(q.ols)
pred.ols.train<-predict(q.ols,trainset) #predict train set
pred.ols.test<-predict(q.ols,testset) #predict test set

rlmValues <- data.frame(obs = y.test,pred = pred.ols.test)
r2se(rlmValues$obs,rlmValues$pred)

#----------------------------------------------------
# Plot the results 
y<-xyplot(trainset$Activity ~ pred.ols.train, 
       type = c('g', 'p'),  xlab = "Predicted", ylab = "Observed",
       panel = function(x,y, ...){ 
         panel.xyplot(x,y,...)
         panel.lines(x, predict(q.ols), col = 'black', lwd = 2) 
       } 
) 


y+as.layer(xyplot(y.test ~ pred.ols.test,pch=17,col="black"))


#----------------------------------------------------
# Using Partial Least Squares 
# Partial least squares regression (PLS regression) is a statistical method 
# inds a linear regression model by projecting the predicted variables and 
# the observable variables to a new space.
# PLS regression is particularly suited when the matrix of predictors has more 
# variables than observations, and when there is multicollinearity among X values
# Difference between Principal component regression(PCR) and PLS is,PCR is based 
# on the spectral decomposition of t(X)%*%X and PLS is based on t(X)%*%Y 
#----------------------------------------------------
# install.packages('pls')
library(pls)

#----------------------------------------------------
q.data<-na.omit(q.data)
descs <- q.data[, !apply(q.data, 2, function(x) any(is.na(x)) )]
descs <- descs[, !apply( descs, 2, function(x) length(unique(x)) == 1 )]


#----------------------------------------------------
# Preprocessing data and normalizing data

T<-preProcess(descs[,2:dim(descs)[2]],method = "BoxCox")
data<- predict(T,descs[,2:dim(descs)[2]])


#----------------------------------------------------
# split train and test set
ind<-sample(2,nrow(data),replace=TRUE,prob=c(0.8,0.2))
trainsetX<-data[ind==1,2:dim(data)[2]]
trainY<-trainsetX$Activity
testsetX<-data[ind==2,2:dim(data)[2]]
testY<- testsetX$Activity

#----------------------------------------------------
# Use pls to model the data
plsFit <- plsr(Activity ~ ., data = trainsetX)

# Using the first ten components
pls.test<-data.frame(predict(plsFit, testsetX, ncomp = 1:10))
pls.train<-data.frame(predict(plsFit, trainsetX, ncomp = 1:10))

#----------------------------------------------------
# Summarizing results of test set
rlmValues <- data.frame(obs = testY,pred = pls.test$Activity.10.comps)
r2se(rlmValues$obs,rlmValues$pred)

#----------------------------------------------------
# Another way of plotting the data Create a dataframe 
# for train and test set results
train.results<-data.frame(observed=trainY,predicted=pls.train$Activity.5.comps,set="train")
test.results <- data.frame(observed=testY,predicted=pls.test$Activity.5.comps,set="test")
results<-rbind(train.results,test.results)

plotsar(results)



#----------------------------------------------------
# Use plsTune to tune the model with 5 folds cross validation 
# 10 components used as tunelength set to 10
set.seed(100)
ctrl <- trainControl(method = "cv",number=5)
plsTune <- train(trainsetX, trainY,
                 method = "pls",
                 ## The default tuning grid evaluates
                 ## components 1... tuneLength
                 tuneLength = 15,
                 trControl = ctrl,
                 preProc = "BoxCox")

#----------------------------------------------------
# plot results of plstune
plot(plsTune)
plsPredTrain<- predict(plsTune,trainsetX)
plsPredTest <- predict(plsTune,testsetX)

#----------------------------------------------------
# Predict the values of train and test set
plsValues1 <- data.frame(obs = trainY, pred = plsPredTrain)
plsValues2 <- data.frame(obs = testY, pred = plsPredTest)

#----------------------------------------------------
# Calculate RMSE and R Squared
r2se(plsValues1$obs,plsValues1$pred)
r2se(plsValues2$obs,plsValues2$pred)

#----------------------------------------------------
# Plot the regression plots of train and test set.

y<-xyplot(trainsetX$Activity ~ plsPredTrain, 
          type = c('g', 'p'),  xlab = "Predicted", ylab = "Observed",
          panel = function(x,y, ...){ 
            panel.xyplot(x,y,...)
            panel.lines(x, predict(plsTune), col = 'black', lwd = 2) 
          } 
) 


y+as.layer(xyplot(testY ~ plsPredTest,pch=17,col="black"))
  
#----------------------------------------------------
# Ridge Regression
#---------------------------------------------------- 
# Ridge-regression models can be created using the lm.ridge function in the
# MASS package or the enet function in the elasticnet package. When calling
# the enet function, the lambda argument specifies the ridge-regression penalty
# RR tells you if your estimates are stable or not. It also tells which variables 
# causing problems .

library(elasticnet)
library(AppliedPredictiveModeling)
data(solubility)
#solTrainXtrans,solTrainY
# solTestXtrans,solTestY

ridgeModel <- enet(x = as.matrix(trainsetX), y = trainY,lambda = 0.01)
ridgetest  <- predict(ridgeModel, newx = as.matrix(testsetX),
                     s = 1, mode = "fraction",type = "fit")
ridgetrain <- predict(ridgeModel, newx = as.matrix(trainsetX),
                      s = 1, mode = "fraction",type = "fit")


ridgeval1<-data.frame(obs = trainY, pred = ridgetrain$fit)
ridgeval2<-data.frame(obs = testY, pred = ridgetest$fit)
r2se(ridgeval1$obs,ridgeval1$pred)
r2se(ridgeval2$obs,ridgeval2$pred)


#----------------------------------------------------
# Creating dataframe for plotting

train.results<-data.frame(observed=trainY,predicted=ridgetrain$fit,set="train")
test.results <- data.frame(observed=testY,predicted=ridgetest$fit,set="test")
results<-rbind(train.results,test.results)

plotsar(results)


#----------------------------------------------------
# model tunning with ridge regression
ridgeGrid <- data.frame(lambda = seq(0, .1, length = 15))
set.seed(100)
ridgeRegFit <- train(solTrainXtrans, solTrainY,
                       method = "ridge",
                       ## Fir the model over many penalty values
                       tuneGrid = ridgeGrid,
                       trControl = ctrl,
                       ## put the predictors on the same scale
                       preProc = c("center", "scale"))
ridgeRegFit

enetModel <- enet(x = as.matrix(solTrainXtrans), y = solTrainY,
                  lambda = 0.02, normalize = TRUE)

enetPred1 <- predict(enetModel, newx = as.matrix(solTestXtrans),
                    s = 1, mode = "fraction",
                    type = "fit")
enetPred2 <- predict(enetModel, newx = as.matrix(solTrainXtrans),
                    s = 1, mode = "fraction",
                    type = "fit")


names(enetPred)
head(enetPred$fit)

#----------------------------------------------------
# Plot Results
rrpred1 <- data.frame(observed= solTestY, predicted = enetPred1$fit,set="test")
rrpred2 <- data.frame(observed = solTrainY, predicted = enetPred2$fit,set="train")

r2se(rrpred1$observed,rrpred1$predicted)
results<-rbind(rrpred2,rrpred1)
plotsar(results)


#----------------------------------------------------
# To determine which predictors are used in the model, the predict method is
# used with type = "coefficients"
enetCoef<- predict(enetModel, newx = as.matrix(solTestXtrans),
                   s = .1, mode = "fraction",
                   type = "coefficients")

tail(enetCoef$coefficients)


