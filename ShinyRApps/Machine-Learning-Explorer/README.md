# Machine Learning Explorer in Shiny
Shiny toolkit for data science modeling using machine learning

### Collaborators
Avi Yashchin  
Jospeh Lee  

## Introduction
This shiny application is an exploratory toolkit using R.  The purpose fo this project was to learn, exercise, and implement R code as well as an interactive front end using Shiny. 


![Alt text](img/image1.png)

## How to Run
There are two ways to run the program.     
##### Run on Server
  Go to the following link[...]
  
##### Run Locally  
  * Clone this repo to your local machine
  * Download the following list of R packages or make sure you have recent versions if you already have them.
```
require(shiny);
require(shinyIncubator);
library(shinydashboard);
require(pastecs);
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
library(googleVis);
library("PASWR");
require("doMC")
source("helpers.R")

```

  * Open the terminal and 'cd' to the MLExplorerShiny folder and activate R console. 
  * If R studio was used then change the studio directory to appropriate folder using setwd().  
Once you are at the correct directory run the following R command. 

```
runApp("app") 
```
You may need to import the shiny package prior to the runApp() call. 

```
library(shiny)
```

Alternatively you can display code in parallel to the app by using the following instead of the latter:

```
runApp("app",display.mode = "showcase")
```


