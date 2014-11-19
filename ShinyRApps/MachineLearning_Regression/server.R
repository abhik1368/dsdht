library(shiny)
library(ggplot2)
source("global.R")
# Define server logic for slider examples
shinyServer(function(input, output, session) {

  observe({
    # When number of Principle Components changes,
    # update the xcol selection for visualization
    updateSelectInput(session, "xcol",
      label = "xcol",
      choices = names(data_testing()),
      selected = names(data_testing())[[1]])

    # Same as xcol; for ycol
    updateSelectInput(session, "ycol",
                      label = "ycol",
                      choices = names(data_testing())[1:input$npca],
                      selected = names(data_testing())[[2]])
  })

  # Select only parts of the data
  data_training <- reactive({
    wle_training[, 1:input$npca]
  })

  data_testing <- reactive({
    wle_testing[, 1:input$npca]
  })

  # Training
  trained_model <- reactive({
    inalpha <- c(ridge = 0, lasso = 1)[input$alpha]
    print (input$alpha)
    inlambda <- 10^(seq(input$lambda[1], input$lambda[2], 0.1))
     glmnet_train(data_training(), wle_training_y, inlambda, inalpha)
  })

  # Make prediction based on trained_model(); Using the best one by default
  pred_testing_y <- reactive({
    predict(trained_model(), newdata = data_testing())
  })

  # Show the model of training process
  output$model <- renderPrint({
    trained_model()
  })

  # Show the confusion matrix of prediction
  output$cfm <- renderPrint({
    confusionMatrix(pred_testing_y(), wle_testing_y)
  })

  # Show Overall Accuracy
  output$accuracy <- renderText({
    confusionMatrix(pred_testing_y(), wle_testing_y)$overall["Accuracy"]
  })

  output$p1 <- renderPlot({
    df <- cbind(pred_classe = pred_testing_y(), classe = wle_testing_y, data_testing())
    p <- ggplot(df, aes_string(x = input$xcol, y = input$ycol))
    p <- p + geom_point(aes(color = pred_classe), size = 4)
    p <- p + geom_point(aes(color = classe))
    p <- p + scale_color_discrete(name = "Classe") + theme_bw()
    p <- p + theme(axis.line = element_line(colour = "black")) +
             theme(panel.grid.minor = element_line(colour = "black", size = 0.1), 
                  panel.grid.major = element_line(colour = "black", size = 0.1))
    p
  })

  output$p2 <- renderPlot({
    p <- ggplot(trained_model())
    p <- p + scale_x_log10()
    p <- p + scale_color_discrete(labels = c("ridge", "lasso"), name = "Type") + theme_bw()
    p <- p + theme(axis.line = element_line(colour = "black")) +
      theme(panel.grid.minor = element_line(colour = "black", size = 0.1), 
            panel.grid.major = element_line(colour = "black", size = 0.1))
    
    p
  })

})
