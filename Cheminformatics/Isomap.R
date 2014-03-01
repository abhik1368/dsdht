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