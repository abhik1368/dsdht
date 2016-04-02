require(shiny);
require(caret);
require(e1071);
require(randomForest);
require(nnet);
require(glmnet);
require(gbm);
library(mice);
library(VIM);
require(fastICA);
require(pastecs);
library(googleVis);
library("PASWR");
require("doMC")
source("helpers.R")

registerDoMC(cores = 2)

#code for plotting nnets, taken from: http://beckmw.wordpress.com/2013/03/04/visualizing-neural-networks-from-the-nnet-package/
# the formula of the output of train is off and doesn't work correctly though.
#Function for plotting nnets, not working right now
# require(RCurl);
# require(scales);
# 
# root.url<-'https://gist.github.com/fawda123'
# raw.fun<-paste(
#   root.url,
#   '5086859/raw/17fd6d2adec4dbcf5ce750cbd1f3e0f4be9d8b19/nnet_plot_fun.r',
#   sep='/'
# )
# script<-getURL(raw.fun, ssl.verifypeer = FALSE);
# eval(parse(text = script));
# rm('script','raw.fun');


options(shiny.maxRequestSize = 100*1024^2)

shinyServer(function(input,output,session)
{
  
  #reactive object, responsible for loading the main data
  rawInputData = reactive({
    rawData = input$rawInputFile
    headerTag = input$headerUI;
    sepTag = input$sepUI;
    quoteTag = input$quoteUI;
    
    
    if(!is.null(rawData)) {
      data = read.csv(rawData$datapath,header=headerTag,sep=sepTag,quote=quoteTag);
    } else {
      return(NULL);
    }
    
  });


output$image2 <- renderImage({
  return(list(src = "images/reuse_these_tools.png", contentType = "image/png", align = "center"))
  }, deleteFile = FALSE)



 output$missingBox <- renderValueBox({
    data = rawInputData()
    missing = sapply(data, function(x) sum(is.na(x)))
    df.missing = data.frame(missing)
    total = sum(df.missing$missing)

    valueBox(
      paste0(total), "Missing Value(s)", icon = icon("calculator"),
      color = "purple"
    )
  })

  output$stat_sum <- renderDataTable({ 
    data = rawInputData()
    df.data = stat.desc(data)
    df.data
    
  })

  output$test.clean = renderDataTable({

    pre.data = rawInputData()

    missing.data = Missingness_Analysis(data,5,5, "mean")
    clean.data = missing.data

    df.clean = data.frame(clean.data)
    df.clean

  })

   output$str.data = renderText({

    pre.data = rawInputData()

    df.clean = str(pre.data)
    df.clean

  })

  #responsible for building the model, responds to the button
  #REQUIRED, as the panel that holds the result is hidden and trainResults will not react to it, this one will  
  output$dummyTagUI = renderUI({
    dataInput = trainResults()
    if(is.null(dataInput))
      return();
    activeTab = updateTabsetPanel(session,"mainTabUI",selected="Model Results View");
    return();
  })

  output$GBMdummyTagUI = renderUI({
    dataInput = GBMtrainResults()
    if(is.null(dataInput))
      return();
    activeTab = updateTabsetPanel(session,"mainTabUI",selected="Model Results View");
    return();

  })

  output$LGRdummyTagUI = renderUI({
    dataInput = LGRtrainResults()
    if(is.null(dataInput))
      return();
    activeTab = updateTabsetPanel(session,"mainTabUI",selected="Model Results View");
    return();

  })

  output$KNNdummyTagUI = renderUI({
    dataInput = KNNtrainResults()
    if(is.null(dataInput))
      return();
    activeTab = updateTabsetPanel(session,"mainTabUI",selected="Model Results View");
    return();

  })
  
  
########### Aux Functions ##############
  output$textmissing <- renderText({ 
    
    data = rawInputData()
    
    missing = sapply(data, function(x) sum(is.na(x)))
    df.missing = data.frame(missing)
    total = sum(df.missing$missing)
    total
    
    paste("Number of Missing Values: ",total)
    
  })


  output$textmissing <- renderText({ 
    
    data = rawInputData()
    
    missing = sapply(data, function(x) sum(is.na(x)))
    df.missing = data.frame(missing)
    total = sum(df.missing$missing)
    total
    
  })
  
  output$colmissing <- renderDataTable({ 
    data = rawInputData()
    missing = sapply(data, function(x) sum(is.na(x)))
    frame.missing = data.frame(missing)
    observation = rownames(frame.missing)
    df.missing = cbind(observation, frame.missing)
    df.missing
    
  })
  
  output$pre.data <- renderDataTable({ 
    data = rawInputData()
    df.data = data.frame(data)
    df.data
    
  })

  output$summary.data <- renderDataTable({

    data = rawInputData()
    df.sum = data.frame(summary(data))
    df.sum
  })
  
###############################################

  
  #this is the function that responds to the clicking of the button
  trainResults = eventReactive(input$runAnalysisUI,{
#     #respond to the button
#     input$runAnalysisUI;
    
    #the model we are interested in
    modelTag = isolate(input$modelSelectionUI);
    
    #make sure the data are loaded
    newData = isolate(rawInputData());
    if(is.null(newData))
      return();
    
    #grab the column
    column = isolate(input$modelLabelUI);
    
    columnElement = which(colnames(newData) == column);
    
    foldsType = isolate(input$crossFoldTypeUI);
    
    folds = isolate(input$foldsUI);
    
    control = trainControl(method=foldsType,number=folds)
    
    if(foldsType == "repeatedcv")
    {
      numberOfRepeats = isolate(input$repeatUI);
      control = trainControl(method=foldsType,number=folds,repeats=numberOfRepeats);
    }
    
    preprocessType = isolate(input$preprocessingUI);
    
    #build the equation
    form = as.formula(paste(column," ~ .",sep=""));
    
    kFolds = isolate(input$foldsUI);
    
    foldType = isolate(input$crossFoldTypeUI);
    
    if(preprocessType == "")
      preprocessType = NULL;
    
    results = NULL;
    
    results = withProgress(session, min=1, max=2, {
      setProgress(message = 'Neural Net in progress...')
    
      setProgress(value = 1)
      
      #choose the view based on the model
     if(modelTag == TRUE) {
        
        #familyData = isolate(input$nnModelTypeUI);
        nnRange = isolate(input$nnSizeUI);
        numNN = isolate(input$nnSizeRangeUI);
        nnDecayRange = isolate(input$nnDecayUI);
        numnnDecayRange = isolate(input$nnDecayRangeUI);
        
        gridding = expand.grid(.size=seq(nnRange[1],nnRange[2],length.out=numNN),.decay=seq(nnDecayRange[1],nnDecayRange[2],length.out=numnnDecayRange));
        
        results = train(form,data=newData,tuneGrid=gridding,method="nnet",trControl=control,preProcess=preprocessType);
        return(results);
        
      }

      setProgress(value = 2);
    });
    
    return(results);
    
  })


  GBMtrainResults = eventReactive(input$runAnalysisUI,{
#     #respond to the button
#     input$runAnalysisUI;
    
    #the model we are interested in
    modelTag = isolate(input$GBMmodelSelectionUI);
    
    #make sure the data are loaded
    newData = isolate(rawInputData());
    if(is.null(newData))
      return();
    
    #grab the column
    column = isolate(input$modelLabelUI);
    
    columnElement = which(colnames(newData) == column);
    
    foldsType = isolate(input$crossFoldTypeUI);
    
    folds = isolate(input$foldsUI);
    
    control = trainControl(method=foldsType,number=folds)
    
    if(foldsType == "repeatedcv")
    {
      numberOfRepeats = isolate(input$repeatUI);
      control = trainControl(method=foldsType,number=folds,repeats=numberOfRepeats);
    }
    
    preprocessType = isolate(input$preprocessingUI);
    
    
    
    #build the equation
    form = as.formula(paste(column," ~ .",sep=""));
    
    kFolds = isolate(input$foldsUI);
    
    foldType = isolate(input$crossFoldTypeUI);
    
    if(preprocessType == "")
      preprocessType = NULL;
    
    results = NULL;
    
    results = withProgress(session, min=1, max=2, {
      setProgress(message = 'GB Method in progress...')
    
      setProgress(value = 1)
      
      
      #choose the view based on the model
     if(modelTag == TRUE) {
        
        #familyData = isolate(input$gbmModelTypeUI);
        n.trees = isolate(input$gbmNTrees);
        shrinkage = isolate(input$gbmShrinkage);
        n.minobsinnode = isolate(input$gbmMinTerminalSize);
        interaction.depth = isolate(input$gbmInteractionDepth);

        
        gridding = expand.grid(n.trees = seq(1:n.trees),interaction.depth = c(1, 5, 9), shrinkage = shrinkage, n.minobsinnode = n.minobsinnode)
        
        
      
        
        results = train(form,data=newData,tuneGrid=gridding,method="gbm",trControl=control,preProcess=preprocessType);
        return(results);
        
      }

      setProgress(value = 2);
    });
    
    return(results);
     
  })



LGRtrainResults = eventReactive(input$runAnalysisUI,{
#     #respond to the button
#     input$runAnalysisUI;
    
    #the model we are interested in
    modelTag = isolate(input$LGRmodelSelectionUI);
    
    #make sure the data are loaded
    newData = isolate(rawInputData());
    if(is.null(newData))
      return();
    
    #grab the column
    column = isolate(input$modelLabelUI);
    
    columnElement = which(colnames(newData) == column);
    
    foldsType = isolate(input$crossFoldTypeUI);
    
    folds = isolate(input$foldsUI);
    
    control = trainControl(method=foldsType,number=folds)
    
    if(foldsType == "repeatedcv")
    {
      numberOfRepeats = isolate(input$repeatUI);
      control = trainControl(method=foldsType,number=folds,repeats=numberOfRepeats);
    }
    
    preprocessType = isolate(input$preprocessingUI);
    
    
    
    #build the equation
    form = as.formula(paste(column," ~ .",sep=""));
    
    kFolds = isolate(input$foldsUI);
    
    foldType = isolate(input$crossFoldTypeUI);
    
    if(preprocessType == "")
      preprocessType = NULL;
    
    results = NULL;
    
    results = withProgress(session, min=1, max=2, {
      setProgress(message = 'Boosted Logit in progress...')
    
      setProgress(value = 1)
      
      
      #choose the view based on the model
     if(modelTag == TRUE) {
        

        nIter = isolate(input$logregIter);
        
        gridding = expand.grid(nIter = seq(1:nIter))
        
  
        
        results = train(form,data=newData,tuneGrid=gridding,method="LogitBoost",trControl=control,preProcess=preprocessType);
        return(results);
        
        
        
      }

      setProgress(value = 2);
    });
    
    return(results);
    
    
    
  })


KNNtrainResults = eventReactive(input$runAnalysisUI,{
#     #respond to the button
#     input$runAnalysisUI;
    
    #the model we are interested in
    modelTag = isolate(input$KNNmodelSelectionUI);
    
    #make sure the data are loaded
    newData = isolate(rawInputData());
    if(is.null(newData))
      return();
    
    #grab the column
    column = isolate(input$modelLabelUI);
    
    columnElement = which(colnames(newData) == column);
    
    foldsType = isolate(input$crossFoldTypeUI);
    
    folds = isolate(input$foldsUI);
    
    control = trainControl(method=foldsType,number=folds)

    #ctrl = trainControl(method = "repeatedcv", repeats = 5)
    #ctrl <- trainControl(method="repeatedcv",repeats = input$repeatUI)
    
    if(foldsType == "repeatedcv")
    {
      numberOfRepeats = isolate(input$repeatUI);
      control = trainControl(method=foldsType,number=folds,repeats=numberOfRepeats);
    }
    
    preprocessType = isolate(input$preprocessingUI);
    
    #build the equation
    form = as.formula(paste(column," ~ .",sep=""));
    
    kFolds = isolate(input$foldsUI);
    
    foldType = isolate(input$crossFoldTypeUI);
    
    if(preprocessType == "")
      preprocessType = NULL;
    
    results = NULL;
    
    results = withProgress(session, min=1, max=2, {
      setProgress(message = 'KNN in progress...')
    
      setProgress(value = 1)
      
      
      #choose the view based on the model
     if(modelTag == TRUE) {
        

        tuneLength = isolate(input$knnTuneLength);

        ctrl <- trainControl(method = "repeatedcv", repeats = 5)

        results = train(form, data = newData, method = "knn", tuneLength = tuneLength, trControl = ctrl)

        return(results);  
      }

      setProgress(value = 2);
    });
    return(results);
  })


  #responsible for displaying the full results
  output$trainResultsUI = renderTable({
    data = trainResults();
    if(is.null(data))
      return();
    data$results
  })

  output$GBMtrainResultsUI = renderTable({
    data = GBMtrainResults();
    if(is.null(data))
      return();
    data$results
  })

  output$LGRtrainResultsUI = renderTable({
    data = LGRtrainResults();
    if(is.null(data))
      return();
    data$results
  })


  output$KNNtrainResultsUI = renderTable({
    data = KNNtrainResults();
    if(is.null(data))
      return();
    data$results
  })
  
  #the one that matches the best
  output$bestResultsUI = renderTable({
    data = trainResults();
    if(is.null(data))
      return();
    data$results[as.numeric(rownames(data$bestTune)[1]),];
  })

  #the one that matches the best
  output$GBMbestResultsUI = renderTable({
    data = GBMtrainResults();
    if(is.null(data))
      return();
    data$results[as.numeric(rownames(data$bestTune)[1]),];
  })

  output$LGRbestResultsUI = renderTable({
    data = LGRtrainResults();
    if(is.null(data))
      return();
    data$results[as.numeric(rownames(data$bestTune)[1]),];
  })


    #the one that matches the best
  output$KNNbestResultsUI = renderTable({
    data = KNNtrainResults();
    if(is.null(data))
      return();
    data$results[as.numeric(rownames(data$bestTune)[1]),];
  })
  
  #a feature plot using the caret package
  output$caretPlotUI = renderPlot({
    data = rawInputData();
    column = input$modelLabelUI;
    
    
    #check if the data is loaded first
    if(is.null(data)){
      return()
    } else {
      columnElement = which(colnames(data) == column);  
      
      p = featurePlot(x=data[,-columnElement],y=data[,columnElement],plot="pairs",auto.key=T);
      print(p);
    }
  })
  
  #the results graph of the caret output
  output$finalPlotUI = renderPlot({
    data = trainResults();
    if(is.null(data)){
      return();
    } else {
      
      #the model we are interested in
      modelTag = isolate(input$modelSelectionUI);

      if (modelTag == TRUE){
      
      
      #grab the column
        column = isolate(input$modelLabelUI);
      
      #build the equation
        form = as.formula(paste(column," ~ .",sep=""));
        par(mfrow=c(2,1));
        p = plot(data);
        print(p);
        }else{

        return()
    }
      
    }
  })

  output$LGRfinalPlotUI = renderPlot({
    data = LGRtrainResults();
    if(is.null(data)){
      return();
    } else {
      
      #the model we are interested in
      modelTag = isolate(input$LGRmodelSelectionUI);

      if (modelTag == TRUE) {
      
      
      #grab the column
        column = isolate(input$modelLabelUI);
      
      #build the equation
        form = as.formula(paste(column," ~ .",sep=""));
        par(mfrow=c(2,1));
        p = plot(data);
        print(p);
    } else {
      return()
    }
      
      #       if(modelTag == "nn")
      #       {
      #       data$finalModel$call$formula = form;
      #       
      #       
      #       plot(data$finalModel);
      #       
      #       } else if(modelTag == "rf")
      #       {
      #         plot(data$finalModel);  
      #       }
      
    }
  })

  output$GBMfinalPlotUI = renderPlot({
    data = GBMtrainResults();
    if(is.null(data)){
      return();
    } else {
      
      #the model we are interested in
      modelTag = isolate(input$GBMmodelSelectionUI);
      
      if(modelTag == TRUE){
      #grab the column
        column = isolate(input$modelLabelUI);
      
      #build the equation
        form = as.formula(paste(column," ~ .",sep=""));
        par(mfrow=c(2,1));
        p = plot(data);
        print(p);
      
      }else{
        return()
      }
      #       if(modelTag == "nn")
      #       {
      #       data$finalModel$call$formula = form;
      #       
      #       
      #       plot(data$finalModel);
      #       
      #       } else if(modelTag == "rf")
      #       {
      #         plot(data$finalModel);  
      #       }
      
    }
  })
   output$KNNfinalPlotUI = renderPlot({
    data = KNNtrainResults();
    if(is.null(data)){
      return();
    } else {
      
      #the model we are interested in
      modelTag = isolate(input$KNNmodelSelectionUI);

      if(modelTag ==TRUE){
      
      
      #grab the column
       column = isolate(input$modelLabelUI);
      
      #build the equation
       form = as.formula(paste(column," ~ .",sep=""));
       par(mfrow=c(2,1));
       p = plot(data);
       print(p);
     }else{
      return()
     }
      
      #       if(modelTag == "nn")
      #       {
      #       data$finalModel$call$formula = form;
      #       
      #       
      #       plot(data$finalModel);
      #       
      #       } else if(modelTag == "rf")
      #       {
      #         plot(data$finalModel);  
      #       }
      
    }
  })

  #simple datatable of the data
  output$rawDataView = renderDataTable({
    newData = rawInputData();
    if(is.null(newData))
      return();
    newData;
  });
  
  #responsible for selecting the label you want to regress on
  output$labelSelectUI = renderUI({
    
    data = rawInputData();
    #check if the data is loaded first
    if(is.null(data)){
      return(helpText("Choose a file to load"))
    } else {
      return(selectInput("modelLabelUI","Select Target Feature",colnames(data),colnames(data)[1]));
    }
  });
  
  #a dynamic table responsible for building the input types to the model
  output$modelParametersUI = renderUI({
    
    modelTag = input$modelSelectionUI;
    
    if (modelTag == TRUE) {
      tagList(
              sliderInput("nnSizeUI","NN Size",min=1,max=25,value=c(1,5)),
              numericInput("nnSizeRangeUI","NN Size Range",5),
              sliderInput("nnDecayUI","NN Decay",min=0.0,max=1.0,value=c(0,0.1),step=0.001),
              numericInput("nnDecayRangeUI","NN Decay Range",5))      
    }
    
  })


  output$GBMmodelParametersUI = renderUI({
    
    modelTag = input$GBMmodelSelectionUI;
    
    if (modelTag == TRUE) {
      tagList(
              sliderInput("gbmNTrees","NN Size",min=1,max=25,value=c(1,5)),
              numericInput("gbmInteractionDepth","Interaction Depth",5),
              sliderInput("gbmShrinkage","Shrinkage",min=0.0,max=5.0,value=c(0,1), step = 0.1),
              numericInput("gbmMinTerminalSize","n.minobsinnode",0))      
    }
    
  })

  output$LGRmodelParametersUI = renderUI({
    
    modelTag = input$LGRmodelSelectionUI;
    
    if (modelTag == TRUE) {
      tagList(
              numericInput("logregIter","Number of Iterations",5))   
    }
    
  })

  output$KNNmodelParametersUI = renderUI({
    
    modelTag = input$KNNmodelSelectionUI;
    
    if (modelTag == TRUE) {
      tagList(
              numericInput("knnTuneLength","Tune Length",20))
    }
    
  })
})