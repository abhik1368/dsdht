#The function at the top plot's scree plot using total within sum of squares in the Y
#axis and number of clusters on the X axis . It helps you to identify the number of
#clusters #for the dataset.In Kmeans we need to minimize the total within sum of squares
#and maximize between sum of squares

wssplot <- function(data, nc=15, seed=1234){
  wss <- (nrow(data)-1)*sum(apply(data,2,var))
  for (i in 2:nc){
    set.seed(seed)
    wss[i] <- sum(kmeans(data, centers=i)$withinss)}
  plot(1:nc, wss, type="b", xlab="Number of Clusters",
       ylab="Within groups sum of squares")}

#use rpubchem from https://github.com/rajarshi/cdkr/tree/master/rpubchem/R
# please source the rpubchem.R script where you have saved it.
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
movie3d(spin3d(axis=c(0,0,1)), duration=7, fps=10, movie = "colors",dir="/Users/abhikseal",type = "gif").

# If you are given a similarity matrix then how will you perform clustering based on the similarity matrix? 
# Well, It is possible to perform K-means clustering on a given similarity matrix, at first you need to center 
# the matrix and then take the eigenvalues of the matrix. The final and the most important step is multiplying 
# the first two set of eigenvectors to the square root of diagonals of the eigenvalues to get the vectors and 
# then move on with K-means . Below the code shows how to do it. The embedding plot shows distinguishable 5 clusters.

#This function returns the double centering of the inputted matrix.
mds.tau <- function(H)
{
  n <- nrow(H)
  P <- diag(n) - 1/n
  return(-0.5 * P %*% H %*% P)
}
B<-mds.tau(fpdist)
eig <- eigen(B, symmetric = TRUE)
v <- eig$values[1:2]
#convert negative values to 0.
v[v < 0] <- 0
X <- eig$vectors[, 1:2] %*% diag(sqrt(v))
library(vegan)
km <- kmeans(X,centers= 5, iter.max=1000, nstart=10000) .
#embedding using MDS
cmd<-cmdscale(fpdist)
cols <- c("steelblue", "darkred", "darkgreen", "pink","green")
ordiplot(cmd,type="n")
groups <- levels(factor(km$cluster))
#plotting the points and
for(i in seq_along(groups))
{
  points(cmd[factor(km$cluster) == groups[i], ], col = cols[i], pch = 16)
}
ordispider(cmd, factor(km$cluster), label = TRUE)
ordihull(cmd, factor(km$cluster), lty = "dotted")

# Next I will show Isomap based embedding . Though the method is naive you can work more on it. 
# You can select your number of neighbours you want for embedding.

#Some of the functions required for KNN based Embedding
#  Computes a distance data matrix.

mds.edm<- function(X) {
  
  return(as.matrix(dist(X)))
}

#  Returns an nxn 0-1 matrix KNN. KNN[i,j]=1 iff j is a neighbor of i.
#  Note that KNN may be asymmetric.We assume that D[i,j]>0 except when i=j.
graph.knn <- function(D,k) {
  
  n <- nrow(D)
  KNN <- matrix(0,nrow=n,ncol=n)
  near <- 2:(k+1)
  for (i in 1:n) {
    v <- D[i,]
    j <- order(v)
    j <- j[near]
    KNN[i,j] <- 1
  }
  return(KNN)
}

#  Assigns dissimilarity edge weights based on adjacency.
#  W[i,j] = D[i,j] if i & j are       connected, W[i,i]=0,  otherwise W[i,j] = Inf.
#
graph.dis <- function(KNN,D) {
  
  n <- nrow(KNN)
  A <- graph.adj(KNN)
  i <- which(A==0)
  D[i] <- Inf
  i <- seq(from=1,to=n^2,by=n+1)
  D[i] <- 0
  return(D)
}
#  Computes all shortest path distances for a weighted graph.
graph.short <- function(W) {
  
  n <- nrow(W)
  E <- matrix(0,nrow=n,ncol=n)
  m <- 1
  while (m < n-1) {
    for (i in 1:n) {
      for (j in 1:n) {
        E[i,j] <- min(W[i,]+W[,j])
      }
    }
    W <- E
    m <- 2*m
  }
  return(W)
}


d_ij<-mds.edm(fpmac)
#Select 5 neighbours
g<-graph.knn(d_ij,5)
dis<-graph.dis(g,d_ij)
#compute all shortest paths
g.short<-graph.short(dis)
#MDS with the distance matrix
cmd<-cmdscale(g.short)
km <- kmeans(fpmac,5,10000)
cols <- c("steelblue", "darkred", "darkgreen", "pink")
groups <- levels(factor(km$cluster))
ordiplot(cmd,type="n")
library(vegan)
for(i in seq_along(groups))
{
  points(cmd[factor(km$cluster) == groups[i], ], col = cols[i], pch = 16)
}
ordispider(cmd, factor(km$cluster), label = TRUE)
ordihull(cmd, factor(km$cluster), lty = "dotted")

#The code below shows clustering based on different sets of descriptors from rcdk .First I select some of the
#descriptors for some of them are physicochemical some are path based and topological and then generate a matrix
#or a dataframe of the #descriptors

desc.names <- c("org.openscience.cdk.qsar.descriptors.molecular.BCUTDescriptor",
                "org.openscience.cdk.qsar.descriptors.molecular.MDEDescriptor",
                "org.openscience.cdk.qsar.descriptors.molecular.CPSADescriptor",
                "org.openscience.cdk.qsar.descriptors.molecular.XLogPDescriptor",
                "org.openscience.cdk.qsar.descriptors.molecular.KappaShapeIndicesDescriptor",
                "org.openscience.cdk.qsar.descriptors.molecular.GravitationalIndexDescriptor",
                "org.openscience.cdk.qsar.descriptors.molecular.TPSADescriptor",
                "org.openscience.cdk.qsar.descriptors.molecular.WeightedPathDescriptor")
prefix <- gsub("org.openscience.cdk.qsar.descriptors.molecular","", desc.names)
prefix <- gsub("Descriptor", "", prefix)
desc.list <- list()
for (i in 1:length(ActiveSmiles)) {
  tmp <- c()
  data.names<-c()
  for (j in 1:length(desc.names))
  {
    values <- eval.desc(ActiveSmiles[[i]], desc.names[j])
    tmp <- c(tmp, values)
    if (i == 1)
      data.names <- c(data.names, paste(prefix[j],1:length(values), sep="."))
  }
  desc.list[[i]] <- tmp
}
desc.data <- as.data.frame(do.call("rbind", desc.list))
#remove columns which are NA
desc.data<-desc.data[ , ! apply(desc.data , 2 , function(x) all(is.na(x)) ) ]

#convert list to a matrix
desc.mat = matrix(unlist(desc.data), nrow=857)
desc.mat(is.na(desc.mat)]=0
wssplot(desc.mat)
fpdist<-as.matrix(dist(desc.mat))
cmd<-cmdscale(fpdist)
cols <- c("steelblue", "darkred", "yellow", "pink")
km <- kmeans(desc.mat),4,10000) # Kmeans Cluster with 5 centers and iterations =10000
library(vegan)
ordiplot(cmd,type="n")
groups <- levels(factor(km$cluster))
for(i in seq_along(groups))
{
  points(cmd[factor(km$cluster) == groups[i], ], col = cols[i], pch = 16)
}
ordispider(cmd, factor(km$cluster), label = TRUE)
ordihull(cmd, factor(km$cluster), lty = "dotted")
library(rgl)
cmd3d<-cmdscale(fpdist,k=3)
plot3d(cmd3d, col = km$cluster,type="s",size=1,scale=0.2)

# Clustering big datasets in R can be done using variety of ways.Packages like bigmemory, biganalytics, bigml 
# being created to perform the task.Further tools are still under development . You can cluster million of 
# rows using these packages.Below an example is shown using the Iris data. The species column is changed to 
# factor because the bigkmeans function accepts bigmatrix object where every column should be numeric. 
# I have converted Iris data the species column to numeric form and applied k-means to it. Currently the
# Macqueen's algorithm is supported .

install.packages('bigml')
install.packages('bigmemory')
install.packages('biganalytics')
library(biganalytics)
library(bigmemory)
Y<-as.big.matrix(as.matrix(data.frame(iris[1:4],Species=as.numeric (factor(iris$Species)))))
#Kmeans with 3 clusters
k<-bigkmeans(Y[,1:4], 3, iter.max = 10000, nstart = 1)


