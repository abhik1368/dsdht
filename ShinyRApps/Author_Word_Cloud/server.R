library("shiny")
library("XML")
library("stringr")
library("RCurl")
library("wordcloud")
library("tm")

shinyServer(function(input, output) {
  output$plot1 <- reactivePlot(function() {
    
    getAbstracts <- function(author, dFrom, dTill, nRecs)
    {
      #For more details about Pubmed queries see: http://www.ncbi.nlm.nih.gov/books/NBK25500/
      
      #Text search - basic URL
      eSearch <- "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&term="
      #Data record download - basic URL
      eDDownload <- "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&id="
      
      #In case of multiple words (e.g., first and the last name), add "+" sign in between them 
      aL <- str_replace(author, " ", "+")
      #Add the search keyword - author
      aQ <- paste(aL, "[author]", sep = "")
      
      #Format the publication date and add the search keyword - pdat
      #If only one year is provided, use that year, otherwise use year_1:year_2
      dQ <- ""
      
      if ((str_length(dFrom) > 0) & (str_length(dTill) > 0))
      {
        d1 <- paste(dFrom, dTill, sep = ":")
        dQ <- paste(d1, "[pdat]", sep = "")
      }
      
      if ((str_length(dFrom) > 0) & (str_length(dTill) == 0))
        dQ <- paste(dFrom, "[pdat]", sep = "")
      
      if ((str_length(dTill) > 0) & (str_length(dFrom) == 0))
        dQ <- paste(dTill, "[pdat]", sep = "")
      
      #Add two seqrch queries together
      hlpQ1 <- aQ  
      
      if (str_length(dQ) > 0)    
        hlpQ1 <- paste(aQ, dQ, sep = "+")
      
      #Add the max number of retrieved articles at the end of the query
      rmQ <- paste("&retmax=", nRecs, sep="")
      hlpQ2 <- paste(hlpQ1, rmQ, sep="")
      
      #Finalize the query and serch Pubmed
      searchUrl <- paste(eSearch, hlpQ2, sep = "" )
      #Wait - to ensure that all requests will be processed
      Sys.sleep(3)    
      hlpURL <- getURL(searchUrl)
      #The result is in form of XML document - you can paste the searchUrl in the browser to see/download it
      doc <- xmlTreeParse(hlpURL, asText = TRUE)     
      IdlistHlp = xmlValue(doc[["doc"]][["eSearchResult"]][["IdList"]])
      
      #I am sure there is more elegant way (i.e., a function) to proccess this, but I was lazy to search for it
      if (length(IdlistHlp) > 0)
      {
        Idlist <- c()
        
        #Each ID is 8 digits long
        for(k in 1:(str_length(IdlistHlp)/8))
          Idlist <- c(Idlist, str_sub(IdlistHlp, start = 8*(k-1) + 1, end = k*8))
        
        #Once we retrieved articles' IDs for the author/dates, we can process them and get abstracts             
        Sys.sleep(2)
        hlp1 <- paste(eDDownload, paste(Idlist, collapse = ",", sep = ""), sep = "")
        hlp2 <- paste(hlp1, "&rettype=abstract", sep = "")
        testDoc <- xmlTreeParse(hlp2, useInternalNodes = TRUE)
        topFetch <-xmlRoot(testDoc)
        abst <- xpathSApply(topFetch, "//Abstract", xmlValue)
      }
      
      #In case that nothing was found
      if (length(IdlistHlp) == 0)
        abst = c("Zero", "Articles", "Found")
      
      abst
    }
    
    plotWC <- function(abstracts, nc, cs)
    {
      #Once we have abstracts, we can create a document corpus
      abstTxt <- Corpus(VectorSource(abstracts))
      
      text2.corpus = tm_map(abstTxt, removePunctuation)
      text2.corpus = tm_map(text2.corpus, content_transformer(tolower))
      text2.corpus = tm_map(text2.corpus, removeWords, stopwords("english"))
      
      #Transform it into a matrix and sort based on the total word occurence
      tdm <- TermDocumentMatrix(text2.corpus)
      m <- as.matrix(tdm)
      v <- sort(rowSums(m),decreasing=TRUE)
      d <- data.frame(word = names(v),freq=v)
      
      #Select the color scheme
      pal2 <- brewer.pal(nc, cs)
      
      #And plot the cloud
      wordcloud(d$word,d$freq, scale=c(8,.2), min.freq = 3, max.words=100, random.order = FALSE, rot.per=.15, color = pal2, vfont=c("sans serif","plain"))
      
    }
    
    #Function to determine number of colors per each scheme
    colNum <- function(type) {
      switch(type,
             Accent = 8,
             Dark2 = 12,
             Pastel1 = 9,
             Pastel2 = 8,
             Paired = 12,
             Set1 = 9,
             Set2 = 8,
             Set3 = 12
      )
    }
    
    # Get inputs, download abstracts, and create a corresponding wordcloud 
    
    numCol <- colNum(input$colSel)
    plotWC(getAbstracts(input$aName, input$yL, input$yH, input$nR), numCol, input$colSel)
    
    # Include a downloadable file of the plot in the output list.
    output$downloadimage <- downloadHandler(
      filename = "shinyPlot.pdf",
      # The argument content below takes filename as a function
      # and returns what's printed to it.
      content = function(con) {
        pdf(con)
        print(plotWC(getAbstracts(input$aName, input$yL, input$yH, input$nR), numCol, input$colSel))
        dev.off(which=dev.cur())
      }
    )
  })
  
})