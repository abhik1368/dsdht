library(caret)
library(glmnet)
library(e1071)
library(RANN)

# Load the clean data
wle_training <- read.csv("data/wle_training.csv",header=TRUE)
wle_testing <- read.csv("data/wle_testing.csv",header=TRUE)

# Detect nearzero columns and remove them
wle_nearzero <- nearZeroVar(wle_training, saveMetrics = TRUE)
wle_training <- wle_training[,!wle_nearzero$nzv]
wle_testing <- wle_testing[,!wle_nearzero$nzv]

# separate y columns
wle_training_y <- as.factor(wle_training$classe)
wle_testing_y <- as.factor(wle_testing$classe)
wle_training <- wle_training[, -1]
wle_testing <- wle_testing[,-1]

# BoxCox, Center, Scale Impute and PCA
# Impute missing values using k-nearest-neighbors with k = 5
prep_model <- preProcess(wle_training,
                         method = c("BoxCox", "center", "scale", "knnImpute", "pca"),
                         thresh = 0.95,
                         k = 5
)
wle_training <- predict(prep_model, newdata = wle_training)
wle_testing <- predict(prep_model, newdata = wle_testing)

# Train the dataset "data_training" and return the trained models
glmnet_train <- function(data_training, data_training_y, lambda_params, alpha_params){
  glmnet_ctrl <- trainControl(method = "cv", number = 10)
  glmnet_grid <- expand.grid(lambda = lambda_params, alpha = alpha_params)
  glmnet_model <- train(data_training, data_training_y,
                        method = "glmnet",
                        trControl = glmnet_ctrl,
                        tuneGrid = glmnet_grid,
                        metric = "Accuracy",
                        family = "multinomial",
                        maxit = 1000000
  )

  glmnet_model
}
