#=============================================================#
#                                                             #
#  Networks in R                                              #
#  dsdht.wikispaces.com                                       #
#  Abhik Seal, 2/27/2014                                      #
#                                                             #
#=============================================================#


#-----------------------------------------------------------------
library(igraph)
#-----------------------------------------------------------------
# Read Files
net<-read.csv("~/data/db_prot.csv",header=TRUE,row.names=1,check.names=FALSE)

#-----------------------------------------------------------------
# Convert to matrix
net<-as.matrix(net)

#-----------------------------------------------------------------
# Projection of proteins and two proteins are connected if they one 
# more drugs
protein<-net%*%t(net)
protein[protein>0]<-1 

# Remove self loops
diag(protein)<-0

#-----------------------------------------------------------------
# Projection of drugs and two drugs are connected if they one 
# more proteins
drug<-t(net)%*%net
drug[drug>0]<-1
diag(drug)<-0

#-----------------------------------------------------------------
# Convert to igraph objects
g.Protein<-graph.adjacency(protein,mode="undirected",diag=FALSE)
g.drug<-graph.adjacency(drug,mode="undirected",diag=FALSE)

#-----------------------------------------------------------------
# decompose the graph into components
comps.d <- decompose.graph(g.drug, min.vertices=2)
comps.p <- decompose.graph(g.Protein, min.vertices=2)

#-----------------------------------------------------------------
# Calculate diameter of the each components
sapply(comps.d,diameter)
sapply(comps.p,diameter)


#-----------------------------------------------------------------
# Calculate Clusters
clusters(g.drug)
clusters(g.protein)
no.clusters(g.drug)

#cluster.distribution creates a histogram for the maximal connected component sizes.
hist(cluster.distribution(g.drug))


#----------------------------------------------------------------- 
# The vertex and edge betweenness are (roughly) defined by the number of geodesics (shortest paths) going 
# through a vertex or an edge.
bet<-data.frame(betweenness(g.drug,directed=FALSE,normalized=TRUE))
d<-rownames(drug)
bet<-data.frame(bet[,1],d)
bet<-bet[order(-bet[,1]),]

#----------------------------------------------------------------- 
# The density of a graph is the ratio of the number of edges and the number of possible edges.
graph.density(g.drug, loops=FALSE)

#----------------------------------------------------------------- 
# searching cliques
d<-cliques(g.drug,min=6)
largest.cliques(g.drug)

#-----------------------------------------------------------------
# Community detect for Drugs using fast greedy algorithm   
fg.com <- fastgreedy.community(g.drug)
# membership gives the division of the vertices, into communities. It returns a numeric vector, one value for # each vertex, the id of its community. 
membership(fg.com)
data.frame(membership(wl.com))

#-----------------------------------------------------------------
# This function tries to find densely connected subgraphs, also called communities in a graph via random walks. 
wl.com<- walktrap.community(g.drug,steps=3)
x <- which.max(sizes(wl.com))
table(membership(wl.com)) # comp
subg <- induced.subgraph(g.drug, which(membership(wl.com) == 3))
plot(subg,vertex.size=5, layout=layout.kamada.kawai,edge.width=0.3,edge.color="black")
sizes(wl.com)

#------------------------------------------------------------------
# Calculate network centralization 
centralization.degree(g.drug)$centralization # degree
centralization.closeness(g.drug, mode="all")$centralization #closeness
centralization.evcent(g.drug, directed=FALSE)$centralization # eigen vector

#------------------------------------------------------------------
#degree distribution
degree(g.drug)

# degree.distribution a numeric vector of the same length as the maximum degree plus one. The first element is the relative frequency zero # degree vertices, the second vertices with degree one, etc.
degree.distribution(g.drug)

#------------------------------------------------------------------
# The neighborhood of a given order o of a vertex v includes all vertices which are closer to v order 0 is always v itself, order 1 is v plus its immediate neighbors 
neighborhood.size(g.drug,1,node="acetaminophen")

#------------------------------------------------------------------
l <- layout.fruchterman.reingold(g.drug)
V(g.drug)$color <- fg.com$membership + 1

# plotting igraph objects
plot(g.drug,vertex.color=membership(wl.com),vertex.size=2,vertex.label=NA, layout=l,edge.width=0.3,edge.color="black")

plot(wl.com,g.drug,vertex.size=2,layout=l,edge.width=0.3,vertex.color="#ff000033",vertex.frame.color="#ff000033", edge.color="#55555533",vertex.label.cex=0.5) 


#------------------------------------------------------------------
# Exporting networks in different file formats 
# format :"edgelist", "pajek", "ncol","lgl", "graphml", "dimacs", "gml", "dot", "leda"
 write.graph(g.drug, "test.graphml", "graphml")

#------------------------------------------------------------------
# Reading foregin file formats
g<- read.graph(test.graphml,"graphml")
