##Performing K-folds cross validation 

library(randomForest)
library(rcdk)
library(ROCR)

##Reading the mutagen dataset
dat1<-read.csv("mutagen.txt",sep="\t",header=F)
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
train<-cbind(cmp.finger,dat1$V3,dat1$V2)
colnames(train)[168]<-"IDs"
colnames(train)[167]<-"Outcome"


k=10 #number of folds
n= floor(nrow(train)/k)
err.vect = rep(NA,k) #vetor to put the AUC score

for (i in 1:k){
    s1 <- ((i-1)* n+1)
    s2 <- (i*n)
    subset <- s1:s2
    cv.train <- train[-subset,]
    cv.test <- train [subset,]
<<<<<<< HEAD
    #Change the model accordingly with your preference and see which model performs 
=======
    #Change the model accordingly with your preference and see which model performs better
>>>>>>> 3f81bd54cf5b4fd693ff185c5609199fff4b7606
    fit <- randomForest(x=cv.train[1:166],y= cv.train$Outcome,ntree<-500)
    prediction <- predict (fit,newdata= cv.test[1:166],type<-"prob")
    pred.rf<-prediction(prediction[,2],cv.test$Outcome)
    err.vect[i]<-performance(pred.rf,"auc")@y.values[[1]]
    print(paste("AUC for the fold",i,":",err.vect[i]))
    
}
##Printing the mean AUC 
print(paste("Average AUC:",mean(err.vect)))
