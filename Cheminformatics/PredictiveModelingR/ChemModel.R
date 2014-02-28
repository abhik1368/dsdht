###################################################################################
#### Loading a smiles dataset and using rcdk and machine learning packages     ####
#### to build classification modelS and print respective statistical measures  ####
#### and ROC curve for the test dataset.                                       ####
###################################################################################

#loading different libraries
library(ROCR)
library(randomForest)
library(party)
library(rcdk)
library(kernlab)
library(e1071)
source('classificationsummary.R')

## Reading the smiles structures from the prefiltered dataset
dat1<-read.csv("mutagendata.smi",sep="\t",header=F)
smi <-lapply(as.character(dat1$V1),parse.smiles)
cmp.fp<-vector("list",nrow(dat1))
## generate fingerprints
for (i in 1:nrow(dat1)){
  cmp.fp[i]<-lapply(smi[[i]][1],get.fingerprint,type="maccs")
  
}
##Convert fingerprints to matrix form
fpmac<-fp.to.matrix(cmp.fp)
cmp.finger<-as.data.frame(fpmac)

#Adding Outcome column and ID columns 
dataset<-cbind(cmp.finger,dat1$V3,dat1$V2)
colnames(dataset)[168]<-"IDs"
colnames(dataset)[167]<-"Outcome"

## Make a random train and test set 80% and 20%
ind<-sample(2,nrow(dataset),replace=TRUE,prob=c(0.8,0.2))
trainset<-dataset[ind==1,]
testset<-dataset[ind==2,]

## Modeling with three algorithm Naive Bayes, Random Forest and SVM 
rf_model<-randomForest(trainset[1:166],trainset$Outcome,ntree=500,proximity=TRUE)
nb_model<-naiveBayes(trainset[1:166],trainset$Outcome)
svm_model<-ksvm(as.matrix(trainset[1:166]),as.matrix(trainset$Outcome),data=trainset,type="C-svc",C=100,scaled=TRUE,prob.model=TRUE)

#For Naive Bayes model
predict_nb<-predict(nb_model,newdata=testset,type="raw")
pred.nb<-prediction(predict_nb[,2],testset$Outcome)
nb.auc<-performance(pred.nb,'tpr','fpr')

#For Random Forest Model
#table(predict(rf), trainset$Outcome)
#print(rf)
#predict_rf<-predict(rf_model,newdata=testset)
#table(predict_rf, testset$Outcome)
predict_rf<-predict(rf_model,newdata=testset,type="prob")
pred.rf<-prediction(predict_rf[,2],testset$Outcome)
rf.auc<-performance(pred.rf,'tpr','fpr')
#For SVM Model 
predict_svm<-predict(svm_model,as.matrix(testset[1:166]),type='prob')
pred.svm<-prediction(predict_svm[,2],testset$Outcome)
svm.auc<-performance(pred.svm,'tpr','fpr')

#PLotting the ROC Curve of three algorithm

rfauc<-performance(pred.rf,"auc")@y.values[[1]]
nbauc<-performance(pred.nb,"auc")@y.values[[1]]
svmauc<-performance(pred.svm,"auc")@y.values[[1]]
Methods<- c('Random Forest','Naive Bayes','SVM')
AUCScore<-c(rfauc,nbauc,svmauc)
data.frame(Methods,AUCScore)
#PLot and adding legend 
plot(rf.auc,col='red',lty=1,main='ROC Curve Comparison of Random Forest V/s Naive Bayes')
plot(nb.auc,col='green',add=TRUE,lty=2)
plot(svm.auc,col='black',add=TRUE,lty=2)
L<-list(bquote("Random Forest"== .(rfauc)), bquote("Naive Bayes"== .(nbauc)),bquote("SVM"== .(svmauc)))
legend("bottomright",legend=sapply(L, as.expression),col=c('red','green','black'),lwd=2,bg="gray",pch=14,text.font=2,cex=0.6)

#Calculate Classification Statistics for each algorithms and put it in a dataframe
rf.label<-predict(rf_model,testset)
rfdata<-classificationsummary(rf.label,testset$Outcome,'mutagen','nonmutagen')

nb.label<-predict(nb_model,testset)
nbdata<-classificationsummary(nb.label,testset$Outcome,'mutagen','nonmutagen')

svm.label<-predict(svm_model,as.matrix(testset[1:166]))
svmdata<-classificationsummary(svm.label,testset$Outcome,'mutagen','nonmutagen')
Methods<- c('Random Forest','Naive Bayes','SVM')
AUC<-c(rfauc,nbauc,svmauc)
Accuracy<-c(rfdata$accuracy,nbdata$accuracy,svmdata$accuracy)
Sensitivity<-c(rfdata$sensitivity,nbdata$sensitivity,svmdata$sensitivity)
Specificity<-c(rfdata$specificity,nbdata$specificity,svmdata$specificity)
F1Score <- c(rfdata$F1score,nbdata$F1Score,svmdata$F1Score)
data.frame(Methods,Accuracy,Sensitivity,Specificity,AUC,F1Score)




