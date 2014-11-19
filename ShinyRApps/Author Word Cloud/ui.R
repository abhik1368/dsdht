library("shiny")

# Define UI
shinyUI(pageWithSidebar(
  
  # Application title
  headerPanel("Pubmed Author Word Cloud "),
  
  sidebarPanel(
    
    # Text input for the author's name, e.g., John Smith
    textInput("aName", "Author name:", "Abhik Seal"),
    
    br(),
    
    # More text inputs for the publication years
    helpText("Search Pubmed articles published"),
    numericInput("yL", "between", 2000, min = 1900, max = 2100),    
    numericInput("yH", "and", 2013, min = 1900, max = 2100),
    
    br(),
    # Slider inputs for the number of articles retrieved (newer articles should be on the top)
    sliderInput("nR", "Resulting number of articles:", min = 1, max = 100, value = 10, step = 1),
    
    br(),
    
    # Drop-down input for the color scheme selection (RColorBrewer package for colors)
    selectInput("colSel", "Select a color scheme:", c("Accent" = "Accent", "Dark" = "Dark2", "Pastel 1" = "Pastel1", "Pastel 2" = "Pastel2", "Paired" = "Paired", "One" = "Set1", "Two" = "Set2", "Three" = "Set3"), selected = "Accent"),
    downloadButton(
      outputId = "downloadimage", 
      label    = "Download Image")
    
  ),
  
  mainPanel(
    #Plot the wordcloud here
    plotOutput("plot1", "800px", "600px")
    )
))