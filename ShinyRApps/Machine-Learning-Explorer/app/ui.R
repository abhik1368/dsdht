require(shiny);
require(shinyIncubator);
library(shinydashboard);
library(googleVis);
require(pastecs);


shinyUI(dashboardPage(
  skin = "blue",

  dashboardHeader(title = "ML Bench Beta 1.0"),
  dashboardSidebar(
    sidebarMenu(
#       sidebarSearchForm(textId = "searchText", buttonId = "searchButton",
#                     label = "Search..."),
      menuItem("Summary", tabName = "summary", icon = icon("dashboard")),
      #menuItem("Upload", tabName = "dataupload", icon = icon("upload")),
      #menuItem("Database", tabName = "database", icon = icon("database")),
      menuItem("Data Preparation", tabName = "datapreparation", icon = icon("wrench")),
      menuItem("Analysis", tabName = "analysis", icon = icon("cogs"),
        menuSubItem("Train & Validation",icon = icon("cog"), tabName = "trainvalidation"),
        menuSubItem("Features",icon = icon("cog"), tabName = "features"),
        menuSubItem("Algorithm",icon = icon("cog"), tabName = "algorithm")
        ),

      menuItem("Results", tabName = "results", icon = icon("dashboard")),
      menuItem("About", tabName = "about", icon = icon("info"))
    )

    ),
  dashboardBody(

    tabItems(
      # First tab content
      tabItem(tabName = "summary", 
        fluidRow(

          box(title = "How To Use", status = "primary", solidHeader = TRUE,
            collapsible = TRUE, width = 8,


            h4("Step 1: Upload Dataset"),
            h5("Ideally any csv file is useable.  It is recommended to perform cleaning and munging methods prior to the upload though. We intend to apply data munging/cleaning methods in this app in the near future."),
            h4("Step 2: Analyze Data"),
            h5("Current version allows the user to perform basic missing analysis."),
            h4("Step 3: Choose Pre-processing Methods"),
            h5("Basic K-Cross Validation Methods are applicable. "),
            h4("Step 4: Choose Model"),
            h5("Choose from a selection of machine learning models to run.  Selected parameters for each corresponding model are available to tune and manipulate."),
            h4("Step 5: Run Application"),
            h5("Once the model(s) have been executed, the results for each model can be viewed in the results tab for analysis.")

            )),

        fluidRow(
          box(title = "Libraries/Dependencies",status = "primary", solidHeader = TRUE,
            collapsible = TRUE, width = 8,
            h4("- The caret package was used for the backend machine learning algorithms."),
            h4("- Shiny Dashboard was used for the front end development."),
            h4("- The application is compatiable with AWS for server usage.")))),



      ######################################
      # Data Preparation Tab Contents
      ######################################

      # Second tab content
      tabItem(tabName = "datapreparation",
          fluidPage(
            tabBox(
             id = "datapreptab", 
          

            tabPanel(h4("Data"), 

              fileInput('rawInputFile','Upload Data File',accept=c('text/csv', 'text/comma-separated-values,text/plain', '.csv')),
                            uiOutput("labelSelectUI"),
                            checkboxInput('headerUI','Header',TRUE),
                            radioButtons('sepUI','Seperator',c(Comma=',',Semicolon=';',Tab='\t'),'Comma'),
                            radioButtons('quoteUI','Quote',c(None='','Double Quote'='"','Single Quote'="'"),'Double Quote')),

            tabPanel(h4("Data Analysis"), verbatimTextOutput("textmissing"), dataTableOutput("colmissing")),

            tabPanel(h4("View Data"), dataTableOutput("pre.data"))),
            infoBoxOutput("missingBox"))),


      ######################################
      # Modeling Tab Contents
      ######################################



      ##################################################################################
      ####   Training/Splitting Tab Set Contents
      ##################################################################################

      tabItem(tabName = "trainvalidation", 

        radioButtons("crossFoldTypeUI","Cross Validation Type",c("K-Fold CV"='cv',"Repeated KFold CV"="repeatedcv"),"K-Fold CV"),
        numericInput("foldsUI","Number of Folds(k)",5),
        conditionalPanel(condition="input.crossFoldTypeUI == repeatedcv",
        numericInput("repeatUI","Number of Repeats",5)),
                uiOutput("CVTypeUI"),
                radioButtons("preprocessingUI","Pre-processing Type",c('No Preprocessing'="",'PCA'="pca",'ICA'="ica"),'No Preprocessing'),
                          uiOutput("ppUI")

        ),



      ##################################################################################
      ####   Algorithm Tab Set Contents
      ##################################################################################

      tabItem(tabName = "algorithm",
        fluidRow(
          box(title = "K- Nearest Neighbor", status = "primary", solidHeader = TRUE, collapsible = TRUE, width = 11,

              checkboxInput("KNNmodelSelectionUI", "On/Off", value = FALSE),
              h4("KNN is a non-parametric method used for classification and regression.  In both cases, the input consists of the k closest training examples in the feature space. The output depends on whether k-NN is used for classification or regression."),
              uiOutput("KNNmodelParametersUI"),
                         tags$hr()
                         )
          ),

        fluidRow(
          box(title = "Boosted Logistic Regression", status = "primary", solidHeader = TRUE, collapsible = TRUE, width = 11,
              checkboxInput("LGRmodelSelectionUI", "On/Off", value = FALSE),
              h4("LogitBoost is a boosting algorithm formulated by Jerome Friedman, Trevor Hastie, and Robert Tibshirani. The original framework use the ADA boosting method in context with logistic regression."),
                  uiOutput("LGRmodelParametersUI"),
                         tags$hr()
                         )
          ),

        fluidRow(
          box(title = "Gradient Boosting Method", status = "primary", solidHeader = TRUE, collapsible = TRUE, width = 11,
              checkboxInput("GBMmodelSelectionUI", "On/Off", value = FALSE),
              h4("Gradient boosting is a machine learning technique for regression and classification problems, which produces a prediction model in the form of an ensemble of weak prediction models, typically decision trees. It builds the model in a stage-wise fashion like other boosting methods do, and it generalizes them by allowing optimization of an arbitrary differentiable loss function."),
                         uiOutput("GBMmodelParametersUI"),
                         tags$hr()
                         )
          ),


        fluidRow(
          box(title = "Neural Network", status = "primary", solidHeader = TRUE, collapsible = TRUE, width = 11,
              checkboxInput("modelSelectionUI", "On/Off", value = FALSE),
              h4("Artifical Neural Networks are a family of statistical learning models inspired by biological neural networks (the central nervous systems of animals, in particular the brain) and are used to estimate or approximate functions that can depend on a large number of inputs and are generally unknown."),
                          uiOutput("modelParametersUI"),
                          tags$hr()
            )
          ),


        uiOutput("dummyTagUI"),
        uiOutput("GBMdummyTagUI"),
        uiOutput("KNNdummyTagUI"),
        uiOutput("LGRdummyTagUI"),
        actionButton("runAnalysisUI", " Run", icon = icon("play"))),



      ############################################

      tabItem(tabName = "features", 
        fluidPage(plotOutput("caretPlotUI", width = "950px", height = "750px"))),




      ##################################################################################
      ####   Algorithm Tab Set Contents
      ##################################################################################

      tabItem(tabName = "results",
        fluidRow(
          box(title = "K-Nearest Neighbor", status = "primary", solidHeader = TRUE, collapsible = TRUE, width = 11,

              tabBox(
              tabPanel("Best Results",tableOutput("KNNbestResultsUI")),
              tabPanel("Train Results",tableOutput("KNNtrainResultsUI")),
              tabPanel("Accuracy Plot",plotOutput("KNNfinalPlotUI")))
            )
          ),

        fluidRow(
          box(title = "Logistic Regression", status = "primary", solidHeader = TRUE, collapsible = TRUE, width = 11,
           tabBox(

              tabPanel("Best Results",tableOutput("LGRbestResultsUI")),
              tabPanel("Train Results",tableOutput("LGRtrainResultsUI")),
              tabPanel("Accuracy Plot",plotOutput("LGRfinalPlotUI"))
              )
            )
          ),

        fluidRow(
          box(title = "Gradient Boosting Method", status = "primary", solidHeader = TRUE, collapsible = TRUE, width = 11,
            tabBox(

              tabPanel("Best Results",tableOutput("GBMbestResultsUI")),
              tabPanel("Train Results",tableOutput("GBMtrainResultsUI")),
              tabPanel("Accuracy Plot",plotOutput("GBMfinalPlotUI")))
            )
          ),


        fluidRow(
          box(title = "Neural Network", status = "primary", solidHeader = TRUE, collapsible = TRUE, width = 11,
            tabBox(

              tabPanel("Best Results",tableOutput("bestResultsUI")),
              tabPanel("Train Results",tableOutput("trainResultsUI")),
              tabPanel("Accuracy Plot",plotOutput("finalPlotUI"))
              )
            )
          )),

      ############################################

      tabItem(tabName = "about",
        fluidRow(
          box(title = "Contact", status = "primary", solidHeader = TRUE,
            collapsible = TRUE, width = 8,
            h4("Abhik Seal"), 
            h5("Programmer/Developer abhik1368@gmail.com")
            )),

        fluidRow(
          box(title = "Beta 1.0", status = "primary", solidHeader = TRUE,
            collapsible = TRUE, width = 8,
            h4("Version 1.0 Notes"), 
            h5("- Next version iteration will focus on data munging and cleaning as well as implementing more UI functions for feature engineering.
              The version should work relatively well with clean data."),
            h5("-Data that is not clean with mislabeled levels and factors will likely break the application or produce highly innacurate results."),
            h5("-Current version only uses Accuracy metric, next version will ideally incorporate ROC evaluation"),
            h5("-Next version will incorporate using test data to produce prediction data for kaggle competitions")
            )))
      ))


))
