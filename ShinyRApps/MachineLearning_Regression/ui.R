library(shiny)
source('global.R')
# Define UI for slider demo application
shinyUI(fluidPage(
  title = "Title",
  fluidRow(
    column(4,
      wellPanel(
        h4("Select Parts of the dataset"),
        # Determine how many Principle Components to use as features
        selectInput("npca", "Number of Principle Components:",
          choices = seq(5, ncol(wle_training)),
          selected = 10),
        # Choose the x column form one of the principle components
        selectInput("xcol", "xcol", names(wle_training)[1:10],
          selected = names(wle_training)[[1]]),
        # Choose the y column form one of the principle components
        selectInput("ycol", "ycol", names(wle_training)[1:10],
          selected = names(wle_training)[[2]])
      ),
      wellPanel(
        # h5("% of Variance Explained:"),
        # textOutput("varexp"),
        h5("Overall Accuracy:"),
        textOutput("accuracy")
      )
    ),

    # Show the scatterplot of chosen principle components
    column(8,
      plotOutput("p1")
    )
  ),
  fluidRow(
    column(4,
      wellPanel(
        h5("Training Parameters"),
        checkboxGroupInput("alpha", "Include Regularization Types:",
          choices = c("ridge" = "ridge", "lasso" = "lasso"),
          selected = c("ridge", "lasso")),
        sliderInput("lambda", "Regularization Parameters (Power of 10):",
          min = -5, max = 0, value = c(-3, -1), step = 0.5)
      )
    ),
    column(8,
      tabsetPanel(type = "tabs",
        tabPanel("Plot", plotOutput("p2")),
        tabPanel("ConfusionMatrix", verbatimTextOutput("cfm")),
        tabPanel("Best Model", verbatimTextOutput("model"))
      )
    )
  )
))