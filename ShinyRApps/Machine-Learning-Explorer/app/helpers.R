impute.na <- function(x){
  return (sapply(x, function(f){is.na(f)<-which(f == '');f}))
}

col.mean<- function(x){
  return (sapply(x, function(f) mean(f)))
}

pMiss <- function(x){
  sum(is.na(x))/length(x)*100
}

Missingness_Analysis <- function(data,MISSING_COLS_FOR_REMOVAL,MISSING_ROWS_FOR_REMOVAL,missingUI){

  #swap blanks with NA
  data[data == ""] <- NA

  #Checking for more than 5% missing values in cols
  badcols = apply(data,2,pMiss)
  if(sum(badcols)>0){
    removecols=names(badcols[badcols>=MISSING_COLS_FOR_REMOVAL])
    data <- data[,-which(names(data) %in% removecols)]
    #AGGR PLOT GOES HERE eval(call(aggr,data,col=c('navyblue','red'), numbers=TRUE, sortVars=TRUE, labels=names(data)))
      print("removing columns")
  }

  #Checking for more than 5% missing values in rows
  badrows = apply(data,1,pMiss)
  if(sum(badrows[which(badrows>=MISSING_ROWS_FOR_REMOVAL)])){

    data <- data[which(badrows<=MISSING_ROWS_FOR_REMOVAL),]
    #eval(call(execute_function,data,col=c('navyblue','red'), numbers=TRUE, sortVars=TRUE, labels=names(data)))
      print("Removing rows")
  }

  odata <- data
  missingCols <- apply(odata,2,pMiss)
  compColNames <- names(odata[missingCols==0])  #no missing data
  missColNames <- names(odata[missingCols>0])  # any missing data

  if(length(missColNames)!=0){
    #colnames(odata)[sapply(odata, class)=="character"]
    for (i in 1:length(missColNames)){
      gdata <- odata[,c(compColNames)]
      bdata <- odata[,c(missColNames)]

      #move the current columns from "Bad columns" to "good columns"
      current_var <- missColNames[i]
      gdata[,current_var] <- bdata[,current_var]
      bdata[,current_var] <- NULL

      #only train and test using complete columns
      train <- gdata[!is.na(gdata[,current_var]),]
      test  <- gdata[is.na(gdata[,current_var]),]

      if(missingUI=="knn"){
        regression_formula <- as.formula(paste(current_var," ~ .",sep=""))

        kknn1 <- kknn(regression_formula, train, test, k = 1, distance = 1)
        a1 <- data.frame(test = kknn1$fitted.values, TYPE = "kmeans k=1 dist=1")

        colnames(a1)[1] <- current_var

        odata[current_var][is.na(odata[current_var])] <- a1[,current_var]

      } else {  #if(Method=="avg")
        MeanValue <- lapply(odata[current_var][!is.na(odata[current_var]),],mean)
        odata[current_var][is.na(odata[current_var])] <- MeanValue

        Message_to_slack <- paste("Replaced NAs in column '",current_var,"' with the value ",MeanValue,sep='')
        print(Message_to_slack)
      }
    }
  } else {
      print("No missing data, so we don't need KNN.")
  }

  data <- odata

  return(data)
}
