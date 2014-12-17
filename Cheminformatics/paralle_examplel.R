#' ---
#' title: "Use multiple cores on a machine with doParallel"
#' ---

#' See CRAN Task View: High-Performance and Parallel Computing
#'
#' (http://cran.r-project.org/web/views/HighPerformanceComputing.html)


# install.packages("doParallel")
library(doParallel)

#' Register multi-core backend
registerDoParallel()
#' If you have more cores: `registerDoParallel(cores=10)`
#'
#' How many workers do we have?
getDoParWorkers()


#' ## Example 1: Create random numbers in parallel (%dopar%)
system.time(
  r <- foreach(i = 1:1000, .combine=rbind) %dopar% rgamma(100, 1)
)

#' Doing this on a single core is even faster (%do%)! The reason is that it is relatively expensive to create the parallel processes and the parallelized code is very fast.
system.time(
  r <- foreach(i = 1:1000, .combine=rbind) %do% rgamma(100, 1))


#' ## Example 2: Comparison of several classification methods using resampling
#'
#' Here the paralellized code does more and using multiple cores speeds up the computation significantly.

# install.packages(c("caret", "klaR", "nnet", "rpart", "e1071"))
library(caret)
library(MASS)
library(klaR)
library(nnet)
library(e1071)
library(rpart)

#' We use the iris data set (we shuffle it first)
data(iris)
x <- iris[sample(1:nrow(iris)),]

#' Make the data a little messy
x <- cbind(x, useless = rnorm(nrow(x)))
x[,1] <- x[,1] + rnorm(nrow(x))
x[,2] <- x[,2] + rnorm(nrow(x))
x[,3] <- x[,3] + rnorm(nrow(x))

head(x)

#' Helper function to calculate the missclassification rate
posteriorToClass <- function(predicted) {
  colnames(predicted$posterior)[apply(predicted$posterior,
                                      MARGIN=1, FUN=function(x) which.max(x))]
}

missclassRate <- function(predicted, true) {
  confusionM <- table(true, predicted)
  n <- length(true)
  
  tp <- sum(diag(confusionM))
  (n - tp)/n
}


#' Evaluation function which randomly selects 10% for testing
#' and the rest for training and then creates and evaluates
#' all models.
evaluation <- function() {
  ## 10% for testing
  testSize <- floor(nrow(x) * 10/100)
  test <- sample(1:nrow(x), testSize)
  
  train_data <- x[-test,]
  test_data <- x[test, -5]
  test_class <- x[test, 5]
  
  ## create model
  model_knn3 <- knn3(Species~., data=train_data)
  model_lda <- lda(Species~., data=train_data)
  model_nnet <- nnet(Species~., data=train_data, size=10, trace=FALSE)
  model_nb <- NaiveBayes(Species~., data=train_data)
  model_svm <- svm(Species~., data=train_data)
  model_rpart <- rpart(Species~., data=train_data)
  
  ## prediction
  predicted_knn3 <- predict(model_knn3 , test_data, type="class")
  predicted_lda <- posteriorToClass(predict(model_lda , test_data))
  predicted_nnet <- predict(model_nnet, test_data, type="class")
  predicted_nb <- posteriorToClass(predict(model_nb, test_data))
  predicted_svm <- predict(model_svm, test_data)
  predicted_rpart <- predict(model_rpart, test_data, type="class")
  
  predicted <- list(knn3=predicted_knn3, lda=predicted_lda,
                    nnet=predicted_nnet, nb=predicted_nb, svm=predicted_svm,
                    rpart=predicted_rpart)
  
  ## calculate missclassifiaction rate
  sapply(predicted, FUN=
           function(x) missclassRate(true= test_class, predicted=x))
}



#' Now we run the evaluation
runs <- 100

#' Run sequential (with %do%)
stime <- system.time({
  sr <- foreach(1:runs, .combine = rbind) %do% evaluation()
})

#' Run parallel on all cores (with %dopar%)
ptime <- system.time({
  pr <- foreach(1:runs, .combine = rbind) %dopar% evaluation()
})

#' Compare times
timing <- rbind(sequential = stime, parallel = ptime)
timing

barplot(timing[, "elapsed"], col="gray", ylab="Elapsed time [s]")

#' Compare results
r <- rbind(sequential=colMeans(sr),parallel=colMeans(pr))
r

#' Plot results
cols <- gray(c(.4,.8))
barplot(r, beside=TRUE, col=cols, ylab="Avg. Miss-Classification Rate")
legend("topright", rownames(r), col=cols, pch=15)