# Introduction to Microarray data analysis
# Knit R doc http://www.rpubs.com/abhik1368/12986
##########################################################
#Check installation of a package
##########################################################
installpkg <- function (pkg){
  if (!require(pkg, character.only=T)){
    source("http://bioconductor.org/biocLite.R")
    biocLite(pkg)
  }else{
    require(pkg, character.only=T)
  }
}
installpkg ("golubEsets")
installpkg ("GEOquery")
installpkg("affy")
library('pheatmap')
######################################################################################
#Download GPL file nad annotations file, put it in the current directory, and load it:
######################################################################################
gpl96 <- getGEO(filename='GPL96.annot')
Meta(gpl96)$title
colnames(Table(gpl96))
Table(gpl96)[1:10,1:4]
Table(gpl96)[1:10,c("ID","Gene title")]
Table(gpl96)[1:10,c("ID","Gene title","Gene symbol","Gene ID","GenBank Accession")]
IDs <- attr(dataTable(gpl96), "table")[,c("ID", "Gene symbol")] #create a table of ID and gene symbols

#############################################
#Read the table data
#############################################
x <- read.table("GSE7765-GPL96_series_matrix.txt",skip = 69, header = TRUE, sep = "\t", row.names = 1,fill=TRUE)
#remove the last line from the matrix
x<-x[-22284,]  
dim(x)
names(x)
round(apply(x, 2, summary))

###########################################################
#Replace the rownames with the corresponding gene symbols.
##########################################################
x<-as.matrix(x)
rows <- rownames(x)
rows[3200]
which(IDs[,1] == rows[3200])
IDs[which(IDs[,1] == rows[3200]), 2]
symb <- rep(0, length(rows))
for (i in 1:length(rows)) {
  symb[i] <- as.character(IDs[which(IDs[,1] == rows[i]), 2])
}
rownames(x) <- symb
rownames(x)[500]
logX <- log2(x)
round(apply(x, 2, summary), 3)
round(apply(logX, 2, summary), 2)

###################################################
## hist.array.1
###################################################
hist(x[,1])
hist(M.1 <- logX[,1])
hist(M.1, main="Expression values",
     xlab="Expression",
     ylab="# of spots",
     col=4)

##########################################################################################################################
# MAPlot.1
# The MA-plot is a plot of the distribution of the red/green intensity ratio ('M') plotted by the average intensity ('A'). 
# M and A are defined by the following equations.M (log ratios) and A (mean average) scale.
##########################################################################################################################
opt<-par(mfcol=c(2,1))  
plot(X1<-x[,1], Y1<-x[,4])   
d<-data.frame(X1,Y1)
abline(0,1, col="yellow")
M<-log2(X1)-log2(Y1)
A <- (log2(X1)+log2(Y1))*0.5
plot(A,M,col=densCols(A.1, M.1), pch=20, cex=0.5)
abline (h=0,col="yellow")

### Using ma.plot function from library(affy)
ma.plot( rowMeans(log2(d)), log2(X1)-log2(Y1), cex=0.5,pch=20,col=densCols(A.1, M.1)) 
  par(opt)

###################################################
## boxplot
###################################################
opt <- par(mfcol=c(1,2)) 
boxplot(x, col=c(2,3,2,3,2,3),main="Expression values for 3 control and 3 treated patients",
        xlab="Slides",
        ylab="Expression", las=2, cex.axis=0.7)
boxplot(logX, col=c(2,3,2,3,2,3), main="Expression values for 3 control and 3 treated patients",
        xlab="Slides",
        ylab="Expression", las=2, cex.axis=0.7)
abline(0,0, col="black")   
par(opt)
###################################################
### convert to Pdf
###################################################
pdf("diagnostics.pdf")
opt <- par(mfcol=c(1,2)) 
boxplot(x, col=c(2,2,2,3,3,3),main="Expression values for 3 control and 3 treated patients",
        xlab="Slides",
        ylab="Expression", las=2, cex.axis=0.7)
boxplot(logX, col=c(2,2,2,3,3,3), main="Expression values for 3 control and 3 treated patients",
        xlab="Slides",
        ylab="Expression", las=2, cex.axis=0.7)
abline(0,0, col="black")   
par(opt)
dev.off()


###################################################
### labels
###################################################
logX.cl<-c(0,1,0,1,0,1)

###################################################
### perform t test
###################################################
ttest=function(x){
  tt=t.test(x[logX.cl==0],x[logX.cl==1])
  return(c(tt$statistic,tt$p.value))}

###################################################
### compute t-test of tranformed data
###################################################
ans=apply(logX,1,ttest)
ts<- ans[1,]
pvals<-ans[2,]
###################################################
###  hist.means
###################################################
qqnorm(ts)
qqline(ts)
###################################################
###howManyGenes
###################################################
for (i in c(0.01,0.05,0.001, 0.0001, 0.00001, 0.000001, 0.0000001))
  print(paste("genes with p-values smaller than", i, length(which(pvals < i))))

###################################################################################
# genes are differentially expressed if its p-valueis under a given threshold, 
#which must be smaller than the usual 0.05 or 0.01due to multiplicity of tests Plot heatmaps
#################################################################################
a<-data.frame(which(pvals<0.01))
d<-a[,1]
data<-as.matrix(x=x[d, ])
heatmap(data,col=topo.colors(100),cexRow=0.5)
drows = dist(data, method = "minkowski")
dcols = dist(t(data), method = "minkowski")
pheatmap(data, clustering_distance_rows = drows, clustering_distance_cols = dcols)
