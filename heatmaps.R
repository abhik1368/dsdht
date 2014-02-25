#Sourcing from git
library(devtools)
install_github("rajarshi/cdkr/rpubchem")
library(rpubchem)
library(gplots) #for heatmaps.2
library(pheatmap) # Another type of heatmap

## Or you can Source from the github page R code using the function below
source_https <- function(url, ...) {
  # load package
  require(RCurl)
  # parse and evaluate each .R script
  sapply(c(url, ...), function(u) {
    eval(parse(text = getURL(u, followlocation = TRUE, cainfo = system.file("CurlSSL", "cacert.pem", package = "RCurl"))), envir = .GlobalEnv)
  })
}

source_https("https://raw2.github.com/rajarshi/cdkr/master/rpubchem/R/getassay.R")



aids <- find.assay.id('tuberculosis')
data <- data.frame()
# Note that pubchem does not allow to download large dataset if you get an error like below you should go to pubchem and 
# select a small Bioassay dataset.
#    Error in open.connection(file, "rt") : cannot open the connection 
#    In addition: Warning message:
#    In open.connection(file, "rt") :
#    cannot open: HTTP status was '400 Too many SIDs'
for (i in 1:1){ # Used only one Bioassay
assay<-get.assay(aids[i],quiet=TRUE)
assaydata<-assay[,c("PUBCHEM.CID","PUBCHEM.ACTIVITY.OUTCOME")]
data<-rbind(data,assaydata)
}
Active<-data[data$PUBCHEM.ACTIVITY.OUTCOME=='Active',]
Activecmp<-get.cid(Active$PUBCHEM.CID)
ActiveSmiles<-lapply(Activecmp[,3],parse.smiles)

cmp.fp = vector("list",length(ActiveSmiles))

for (i in 1:length(ActiveSmiles)){
  
  cmp.fp[[i]] = lapply(ActiveSmiles[[i]], get.fingerprint, type="extended")
  
}

fp.sim = fp.sim.matrix(unlist(cmp.fp))

fp.dist = 1 - fp.sim

hc = hclust(as.dist(fp.dist), method="single")

heatmap.2(1-fp.dist, Rowv=as.dendrogram(hc), Colv=as.dendrogram(hc), col=colorpanel(40, "darkblue", "yellow", "white"), density.info="none", trace="none")

#Using Pheatmap (this looks very nice :) )
pheatmap(1-fp.dist)
