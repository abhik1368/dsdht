#The function at the top plot's scree plot using total within sum of squares in the Y
#axis and number of clusters on the X axis . It helps you to identify the number of
#clusters #for the dataset.In Kmeans we need to minimize the total within sum of squares
#and maximize between sum of squares
### wssplot function to calculate within sum of squares results
wssplot <- function(data, nc=15, seed=1234){
  wss <- (nrow(data)-1)*sum(apply(data,2,var))
  for (i in 2:nc){
    set.seed(seed)
    wss[i] <- sum(kmeans(data, centers=i)$withinss)}
  plot(1:nc, wss, type="b", xlab="Number of Clusters",
       ylab="Within groups sum of squares")}

#use rpubchem from https://github.com/rajarshi/cdkr/tree/master/rpubchem/R
source('~/Box Documents/courseraR/Rcodes/rpubchem.R')
library(rcdk)
library(fingerprint)
library(vegan)
assay<-get.assay(651593,quiet=TRUE)
data<-assay[,c("PUBCHEM.CID","PUBCHEM.ACTIVITY.OUTCOME")]
Active<-data[data$PUBCHEM.ACTIVITY.OUTCOME=='Active',]
Activecmp<-get.cid(Active$PUBCHEM.CID)
ActiveSmiles<-parse.smiles(Activecmp[,3])
fps <- lapply(ActiveSmiles, get.fingerprint, type = "pubchem")
fpmac<-fp.to.matrix(fps)
fpsim<-fp.sim.matrix(fps)
fpdist<-1-fpsim
#plotting the total within sum of squares plot with number of clusters
#and determine number of cluster centers
wssplot(fpmac)
km <- kmeans(fpmac,5,10000) # Kmeans Cluster with 5 centers and iterations =10000

#Embedding using Multidimensional Scaling
cmd<-cmdscale(fpdist)
cols <- c("steelblue", "darkred", "darkgreen", "pink","green")
ordiplot(cmd,type="n")
groups <- levels(factor(km$cluster))

for(i in seq_along(groups))
{
  points(cmd[factor(km$cluster) == groups[i], ], col = cols[i], pch = 16)
}
ordispider(cmd, factor(km$cluster), label = TRUE)
ordihull(cmd, factor(km$cluster), lty = "dotted")

#Embedding using principal components
pc<-prcomp(fpmac)
plot(pc$x[,1], pc$x[,2],col=km$cluster,pch=16)
pc<-cbind(pc$x[,1], pc$x[,2])
ordispider(pc, factor(km$cluster), label = TRUE)
ordihull(pc, factor(km$cluster), lty = "dotted")

#3D embedding with cmdscale and PCA
library(rgl)
cmd3d<-cmdscale(fpdist,k=3)
pc<-prcomp(fpmac)
pc3d<-cbind(pc$x[,1], pc$x[,2], pc$x[,3])
plot3d(pc3d, col = km$cluster,type="s",size=1,scale=0.2)
plot3d(cmd3d, col = km$cluster,type="s",size=1,scale=0.2)

#Make a movie of your 3D visualization
movie3d(spin3d(axis=c(0,0,1)), duration=7, fps=10, movie = "colors",dir="/Users/abhikseal",type = "gif")