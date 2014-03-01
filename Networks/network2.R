#=============================================================#
####
####            PART I: NETWORKS
####
#=============================================================#

# the igraph library is good for network based analyses
library(igraph)

# First lets build a network using basic formulas:

graph.onelink<-graph.formula(A-+B)

# This gives us a two species network (A and B) with one link (represented by A-+B).
#With this function the (+) sign signifies the "arrowhead".
# We can visualize our simple 2 species network with plot.igraph().

plot.igraph(graph.onelink)

# Using graph.formula() we can create any graph we want,
# as long as we are willing to write out every interaction by hand.
#Here is another simple example, a four species food chain:

graph.foodchain<-graph.formula(A-+C,B-+C,C-+D)

# and plot it:

plot.igraph(graph.foodchain)
#A and B are eaten by C while D eats C

#igraph has a function for generating random networks of varying size and connectance.

graph.random.gnp<-erdos.renyi.game(n=20,p.or.m=.5,type="gnp",directed=T)
plot.igraph(graph.random.gnp)

# We can also change the layout of the graph, here we will plot the nodes in a circle
plot.igraph(graph.random.gnp,layout=layout.circle)

# Here we have created a random directed graph with 20 species ("n") and
#a connectance ("p") of 0.5 (that is any two nodes have a 50% probability of being connected).
# By setting "type='gnp'" we tell the function to assign links with the probability "p" that we specify.
# Similarly we can set the number of links that we want in the system to a value "m" that we specify.

graph.random.gnm<-erdos.renyi.game(n=20,p.or.m=100,type="gnm",directed=T)
plot.igraph(graph.random.gnm)

# Here the number of links in the network is set to 100, and they are assigned uniformly randomly

# Rather than being truly random, many real networks exhibit some type of organization.
# Of particular note is the prevalance of scale-free networks.
# A scale free network is one whose degree distribution is such that
# a majority of nodes have relatively few links, while few nodes have many links (following a power law).
# To model scale free networks Barabasi and Albert developed the
# preferential attachment model in 1999.
# In this model new nodes are more likely to link to nodes with a higher number of links.

# In igraph we can use the barabasi.game() function:
graph.barabasi.1<-barabasi.game(n=50,power=1)

# For this graph I will introduce some new plotting tools to specify layout and vertex/edge properties.

plot.igraph(graph.barabasi.1,
            layout=layout.fruchterman.reingold,
            vertex.size=10,         # sets size of the vertex, default is 15
            vertex.label.cex=.5,    # size of the vertex label
            edge.arrow.size=.5        # sets size of the arrow at the end of the edge
)

# there are a number of different plotting parameters see
#?igraph.plotting
#for details

plot.igraph(graph.barabasi.1,
            layout=layout.fruchterman.reingold,
            vertex.size=10,
            vertex.label.cex=.5,
            edge.arrow.size=.5,
            mark.groups=list(c(1,7,4,13,10,16,15,41,42,29),
                             c(2,48,5,36,43,33,9)), # draws polygon around nodes
            mark.col=c("green","blue")
)

# In the above plot a green and blue polygon are used to highlight nodes 1 and 2 as hubs.
# The "mark.groups" argument allows you to draw a polygon of specified color
# ("mark.col") around the nodes you specify in a list.
# Because barabasi.game() will give you a different graph each time,
# the groups I have recorded will not be the same each time.

# We can use a community detection algorithm to determine the most densely connected nodes in a graph.

barabasi.community<-walktrap.community(graph.barabasi.1)

# This algorithm uses random walks to find the most densely connected subgraphs.

members<-membership(barabasi.community)
# The members() function picks out the membership vector
# (list of nodes in the most densely connected subgraph) from the communtiy object (e.g., walktrap community).

par(mar=c(.1,.1,.1,.1))    # sets the edges of the plotting area
plot.igraph(graph.barabasi.1,
            layout=layout.fruchterman.reingold,
            vertex.size=10,
            vertex.label.cex=.5,
            edge.arrow.size=.5,
            mark.groups=list(members),
            mark.col="green"
)

# With the above plot the group with the green polygon surrounding it is the nodes
# listed as being a part of the walktrap community.

# Now we will play around with the "power" argument to see how that impacts the graphs.
# We will generate 4 networks with preferential attachment at varying levels.
barabasi.game.2<-barabasi.game(n=50,power=.75)
barabasi.game.3<-barabasi.game(n=50,power=.5)
barabasi.game.4<-barabasi.game(n=50,power=.25)
barabasi.game.5<-barabasi.game(n=50,power=0)

# These can be organized into a list for convenience.
barabasi.graphs<-list(barabasi.game.2,barabasi.game.3,barabasi.game.4,barabasi.game.5)

# Now lets use community detection, this time with the walktrap algorithm.
bg.community.list<-lapply(barabasi.graphs,walktrap.community)
bg.membership.list<-lapply(bg.community.list,membership)

txt<-c("a","b","c","d")    # vector for labeling the graphs

# Plot these four graphs in one window with:
par(mfrow=c(2,2),mar=c(.2,.2,.2,.2))
# The for loop here plots each graph in the list one by one into the window prepared by par.
for(i in 1:4){
  plot.igraph(barabasi.graphs[[i]],
              layout=layout.fruchterman.reingold,
              vertex.size=10,
              vertex.label.cex=.5,
              edge.arrow.size=.5,
              mark.groups=list(bg.membership.list[[i]]),
              mark.col="green",
              frame=T # the frame argument plots a box around the graph
  )
  text(1,1,txt[i]) # calls from the vector to label the graph, adds to the
  # graph that was last plotted
}

# Later we will look at the properties of these graphs to see exactly how they are different.

# Now lets play around with some node and edge attributes
V(barabasi.game.1) # This is a vector of the vertices of the graph
E(barabasi.game.1) # This is a list of all the edges


# Graphs can also be visualized as a matrix, the adjacency matrix.
# The adjacency matrix is an SxS matrix of 0s and 1s,
# where 1 indicates an interaction, and 0 is no interaction.

# The function get.adjacency() converts a graph into a matrix.
barabasi.adjacency<-get.adjacency(graph.barabasi.1)

# A number of other functions will use the adjacency matrix to calculate different network properties.

# And we can get a graph from the adjacency matrix with graph.adjacency().
# Often the data for graphs is in matrix form. Using graph.adjacency allows you
# to convert adjacency matrices into graph objects (that can then be plotted)
graph.adjacency(barabasi.adjacency)

# Similarly we can arrange the information in a number of other ways

# Edgelist
barabasi.edgelist<-get.edgelist(graph.barabasi.1)

# Adjacency list
barabasi.adjlist<-get.adjlist(graph.barabasi.1,mode="all")

# Dataframe
barabasi.data.frame<-get.data.frame(graph.barabasi.1,what="edges")


###############################################################
###############################################################
####
####            PART II: NETWORK PROPERTIES
####
###############################################################
###############################################################
# Again I will be using the igraph package
# to analyze various properties of networks
library(igraph)
# Additionally I will use the NetIndices package,
# since its function "GenInd()" outputs several network properties
library(NetIndices)
# First I'll create a network to analyze using
# the preferential attachment model (power=.5)

test.graph<-barabasi.game(100,power=.5,m=2)
# In this case we have set m=2, meaning that
# for each new node 2 new links are created

par(mar=c(.1,.1,.1,.1))
plot.igraph(test.graph,
            layout=layout.fruchterman.reingold,
            vertex.size=7,
            vertex.label.cex=.5,
            edge.arrow.size=.5)

# How large is the network (I know I set this when we made the network,
# but what if I had not?)

test.graph      # Tells me that it is an IGRAPH object with 100 nodes and 197 links,
# made with the Barabasi algorithm
V(test.graph)   # gives the vertex sequence
E(test.graph)   # gives the edge sequence (edge list)

# The "GenInd()" function requires an input of an adjacency matrix
test.graph.adj<-get.adjacency(test.graph,sparse=F)
# in older versions of igraph the default was sparse=F,
# but now you must specify, other wise you get a matrix of 1s and .s

test.graph.properties<-GenInd(test.graph.adj)

# The function output consists of 10 network properties.
# I will consider five of them here:

test.graph.properties$N            #number of nodes

test.graph.properties$Ltot        #number of links

test.graph.properties$LD        #link density (average # of links per node)

test.graph.properties$C            #the connectance of the graph
# This function measures connectance as L/(N*(N-1)) where L is links, and N is nodes
# Connectance can also be calculated as L/(N^2)

# The degree of a node refers to the number of links associated with a node.
# Degree can be measured as the links going in ("in degree"), out ("out degree"), or both.
# The degree() function takes a graph input and gives the degree of specified nodes.
# With the argument "v=V(graph)" you tell the function to give the degree of all nodes in the graph,
# while the "mode" argument specifies in, out, or both.

in.deg.testgraph<-degree(test.graph,v=V(test.graph),mode="in")
out.deg.testgraph<-degree(test.graph,v=V(test.graph),mode="out")
all.deg.testgraph<-degree(test.graph,v=V(test.graph),mode="all")

# Degree distribution is the cumulative frequency of nodes with a given degree
# this, like degree() can be specified as "in", "out", or "all"
deg.distr<-degree.distribution(test.graph,cumulative=T,mode="all")

# Using the power.law.fit() function I can fit a power law to the degree distribution
power<-power.law.fit(all.deg.testgraph)

# The output of the power.law.fit() function tells me what the exponent of the power law is ($alpha)
# and the log-likelihood of the parameters used to fit the power law distribution ($logLik)
# Also, it performs a Kolmogov-Smirnov test to test whether the given degree distribution could have
# been drawn from the fitted power law distribution.
# The function thus gives me the test statistic ($KS.stat) and p-vaule ($KS.p) for that test

# Then I can plot the degree distribution
plot(deg.distr,log="xy",
     ylim=c(.01,10),
     bg="black",pch=21,
     xlab="Degree",
     ylab="Cumulative Frequency")

# And the expected power law distribution
lines(1:20,10*(1:20)^((-power$alpha)+1))

# Graphs typically have a Poisson distribution (if they are random),
# power law (preferential attachment), or truncated power law (many real networks) degree distribution

# Diameter is essentially the longest path between two vertices
diameter(test.graph)
# Gives me the length of the diameter while

nodes.diameter<-get.diameter(test.graph)
# Gives me the labels for each node that participates in the diameter

# I can look at the diameter graphically also
# First I will define the node and edge attributes
V(test.graph)$color<-"skyblue"
# I want all the nodes to be skyblue
V(test.graph)$size<-7
# I want all the nodes to be size=7
V(test.graph)[nodes.diameter]$color<-"darkgreen"
V(test.graph)[nodes.diameter]$size<-10
V(test.graph)[nodes.diameter]$label.color<-"white"
# but the nodes in the diameter should be darkgreen and larger than the rest
# with a white label instead of black
# this will make the diameter pop out of the larger network
E(test.graph)$color<-"grey"
# all non-diameter edges will be grey
E(test.graph,path=nodes.diameter)$color<-"darkgreen"
E(test.graph,path=nodes.diameter)$width<-2
# Edges in the diameter will be darkgreen and a little extra wide

# If you do not set the attributes of all of the nodes and edges then it will
# default such that you only see what you have defined

# Now when I plot the diameter will be larger than everything else, and darkgreen instead
# of grey/blue
par(mar=c(.1,.1,.1,.1))
plot.igraph(test.graph,
            layout=layout.fruchterman.reingold,
            vertex.label.cex=.5,
            edge.arrow.size=.5)

# Clustering coefficient is the proportion of
# a nodes neighbors that can be reached by other neighbors
# in igraph this property is apparently called "transitivity"

transitivity(test.graph)
# gives the clustering coefficient of the whole network

transitivity(test.graph,type="local")
# gives the clustering coefficient of each node

# Betweenness is the number of shortest paths between two nodes that go through each node of interest

graph.betweenness<-betweenness(test.graph,v=V(test.graph))
graph.edge.betweenness<-edge.betweenness(test.graph,e=E(test.graph))

# Closeness refers to how connected a node is to its neighbors

graph.closeness<-closeness(test.graph,vids=V(test.graph))

# Clustering coefficient, betweenness, and closeness
# all describe the small world properties of the network.
# A network with small world properties is one in which
# it takes a relatively short path to get from one node to the next
# (e.g., six degrees of separation)

# Every graph can be decomposed into its component n-node subgraphs.
# In particular there are 13 unique ways to arrange 3 nodes in directed graphs.
# Here are the adjacency matrices for each of the 13 subgraphs
s1<-matrix(c(0,1,0,0,0,1,0,0,0),nrow=3,ncol=3)
s2<-matrix(c(0,1,1,0,0,1,0,0,0),nrow=3,ncol=3)
s3<-matrix(c(0,1,0,0,0,1,1,0,0),nrow=3,ncol=3)
s4<-matrix(c(0,0,1,0,0,1,0,0,0),nrow=3,ncol=3)
s5<-matrix(c(0,1,1,0,0,0,0,0,0),nrow=3,ncol=3)
d2<-matrix(c(0,1,1,1,0,1,0,0,0),nrow=3,ncol=3)
d1<-matrix(c(0,1,1,0,0,1,0,1,0),nrow=3,ncol=3)
d3<-matrix(c(0,0,1,1,0,0,1,0,0),nrow=3,ncol=3)
d4<-matrix(c(0,0,0,1,0,1,0,1,0),nrow=3,ncol=3)
d5<-matrix(c(0,1,1,0,0,1,1,0,0),nrow=3,ncol=3)
d6<-matrix(c(0,1,1,1,0,1,1,1,0),nrow=3,ncol=3)
d7<-matrix(c(0,1,1,1,0,1,1,0,0),nrow=3,ncol=3)
d8<-matrix(c(0,1,1,1,0,0,1,0,0),nrow=3,ncol=3)

# I then make the 13 matrices into a list
subgraph3.mat<-list(s1,s2,s3,s4,s5,d1,d2,d3,d4,d5,d6,d7,d8)
# And convert the matrices into graph objects
subgraph3.graph<-lapply(subgraph3.mat,graph.adjacency)

# Here I have created a simple for loop to go through the list of subgraphs
# and count how many times that subgraph appears in the larger test.graph
subgraph.count<-c()
for(i in 1:13){
  subgraph.count[i]<-
    graph.count.subisomorphisms.vf2(test.graph,subgraph3.graph[[i]])
}

#Plotting the subgraphs (not provided online)
labs<-c("s1","s2","s3","s4","s5","d1","d2","d3","d4","d5","d6","d7","d8")
sub.mat<-matrix(c(1,2,1,3,2,1),nrow=3,ncol=2)
jpeg("~/Desktop/Subgraph2.jpeg",width=1200,height=(600),quality=100,pointsize=40)
par(mfrow=c(2,4),mar=c(.01,.01,.01,.01))
for(i in 6:13){
  plot.igraph(subgraph3.graph[[i]],layout=sub.mat,vertex.label.cex=.5,
              edge.arrow.size=.5)
  text(0,0,label=labs[i])
}
dev.off()

###############################################################
###############################################################
####
####            PART III: FOOD WEBS
####
###############################################################
###############################################################
library(igraph)
library(NetIndices)
# Kim N. Mouritsen, Robert Poulin, John P. McLaughlin and David W. Thieltges. 2011.
# Food web including metazoan parasites for an intertidal ecosystem in New Zealand.
# Ecology 92:2006.

# Website: http://esapubs.org/archive/ecol/E092/173/

# Otago Harbour: intertidal mudflat
otago.links.data<-read.csv("~/Desktop/Projects/FoodwebAlpha/Data/Otago_Data_Links.csv")
otago.nodes.data<-read.csv("~/Desktop/Projects/FoodwebAlpha/Data/Otago_Data_Nodes.csv")

# Column names for data
colnames(otago.links.data)
colnames(otago.nodes.data)

# Convert the data into a graph object using the first 2 columns of the dataset as an edgelist
otago.graph<-graph.edgelist(as.matrix(otago.links.data[,1:2]))
# Create graph object of just predator prey links
otago.graph.p<-graph.edgelist(as.matrix(otago.links.data[1:1206,1:2]))

# Get the web into matrix form
otago.adjmatrix<-get.adjacency(otago.graph,sparse=F)
otago.adjmatrix.p<-get.adjacency(otago.graph.p,sparse=F)

# Get the basic network indices from the matrices with GenInd()
ind.otago<-GenInd(otago.adjmatrix)
ind.otago.p<-GenInd(otago.adjmatrix.p)

# Now to plot these two webs to get a feel for what we are dealing with
par(mar=c(.1,.1,.1,.1))
plot.igraph(otago.graph,vertex.label=NA,vertex.size=3,edge.arrow.size=.25,layout=layout.circle)
plot.igraph(otago.graph.p,vertex.label=NA,vertex.size=3,edge.arrow.size=.25,layout=layout.circle)

# The NetIndices package also has a function to get some of the trophic properties of the food web
# TrophInd() takes in an adjacency matrix and gives an output of the trophic level of each node,
# as well as an index of the degree of omnivory for each node

troph.otago<-TrophInd(otago.adjmatrix)
troph.otago.p<-TrophInd(otago.adjmatrix.p)

# An interesting aside, by adding parasites to the web it increases the trophic level of all species in
# this web.

plot(troph.otago[1:123,1]~troph.otago.p[,1],xlab="Level Without Parasites",ylab="Level With Parasites")
abline(a=0,b=1)

# An interesting use for this trophic level function is to then use trophic level as a plotting parameter.
# This way, I can plot the food web nodes according to trophic height. I think that this adds greatly to a plot
# of a food web, since you can gain more information about the trophic structure of the web by simply
# glancing at the plot.

# First we need to create a two-column matrix identifying the x and y values for each node.
layout.matrix.1<-matrix(
  nrow=length(V(otago.graph)),  # Rows equal to the number of vertices
  ncol=2
)
layout.matrix.1[,1]<-runif(length(V(otago.graph))) # randomly assign along x-axis
layout.matrix.1[,2]<-troph.otago$TL # y-axis value based on trophic level

layout.matrix.1p<-matrix(
  nrow=length(V(otago.graph.p)),  # Rows equal to the number of vertices
  ncol=2
)
layout.matrix.1p[,1]<-runif(length(V(otago.graph.p)))
layout.matrix.1p[,2]<-troph.otago.p$TL

# Now we can use these matrices to define the layout instead of using the circle layout

par(mar=c(.1,.1,.1,.1),mfrow=c(1,2))

plot.igraph(otago.graph,
            vertex.label.cex=.35,
            vertex.size=3,
            edge.arrow.size=.25,
            layout=layout.matrix.1)

plot.igraph(otago.graph.p,
            vertex.label.cex=.35,
            vertex.size=3,
            edge.arrow.size=.25,
            layout=layout.matrix.1p)


# I am still working on the best way to plot the nodes along the x-axis. You may notice that using
# runif() means that there is some chance that two nodes with the same trophic level
# will be right on top of one another

# It is also a bit interesting to see how the inclusion of parasites impacts community detection
wtc.otago<-walktrap.community(otago.graph)
wtc.otago.p<-walktrap.community(otago.graph.p)

par(mar=c(.1,.1,.1,.1),mfrow=c(1,2))

plot.igraph(otago.graph,
            vertex.label.cex=.35,
            vertex.size=3,
            edge.arrow.size=.25,
            layout=layout.matrix.1,
            mark.groups=wtc.otago$membership,
            mark.col="green")

plot.igraph(otago.graph.p,
            vertex.label.cex=.35,
            vertex.size=3,
            edge.arrow.size=.25,
            layout=layout.matrix.1p,
            mark.groups=wtc.otago.p$membership,
            mark.col="green")


# It is clear that the increase in the connectivity of the web with parasites has led to
# a larger densely connected community

# The degree distribution of a food web can tell us a lot about the amount of specialization and
# generalization in the web (in degree), as well as vulnerability (out degree)

deg.otago<-degree(otago.graph)
deg.otago.p<-degree(otago.graph.p)

# Using the degree distribution gives a better way to visualize any differences
# Looking at the in degree tells us about how general the diets of consumers are
dd.otago.in<-degree.distribution(otago.graph,mode="in",cumulative=T)
dd.otago.in.p<-degree.distribution(otago.graph.p,mode="in",cumulative=T)

# Out degree is a measure of the vulnerability of organisms, telling us how many consumers
# eat each species.
dd.otago.out<-degree.distribution(otago.graph,mode="out",cumulative=T)
dd.otago.out.p<-degree.distribution(otago.graph.p,mode="out",cumulative=T)

# And finally the degree ("all") simply tells us about how well connected that species is
# within the network
dd.otago<-degree.distribution(otago.graph,mode="all",cumulative=T)
dd.otago.p<-degree.distribution(otago.graph.p,mode="all",cumulative=T)

par(mfrow=c(2,2))
plot(dd.otago.in,xlim=c(0,80))
plot(dd.otago.out,xlim=c(0,80))
plot(dd.otago.in.p,xlim=c(0,80))
plot(dd.otago.out.p,xlim=c(0,80))


power.fit<-power.law.fit(deg.otago)
power.fit.p<-power.law.fit(deg.otago.p)


par(mfrow=c(1,2))
plot(dd.otago,log="xy")
lines(1:180,10*(1:180)^((-power.fit$alpha)+1))

plot(dd.otago.p,log="xy")
lines(1:100,10*(1:100)^((-power.fit.p$alpha)+1))


# I can look at the diameter of the two versions of the web
# For food webs the diameter is going to be the longest food chain
# since energy only flows in one direction, the diameter will read from
# basal species to top predator.

get.diameter(otago.graph)
get.diameter(otago.graph.p)

# I think that here it is interesting to note that the diameter of the predator-prey only
# food web (which we expect to be smaller) is not a subset of the diameter for the
# larger parasites included network

# The next few properties are all related to the small world-ness of the network:

transitivity(otago.graph)
transitivity(otago.graph.p)

# Betweenness is the number of shortest paths going through a specified node or edge

otago.between<-betweenness(otago.graph)
otago.between.p<-betweenness(otago.graph.p)

plot(otago.between[1:123]~otago.between.p)
abline(a=0,b=1)

otago.edge.between<-edge.betweenness(otago.graph)
otago.edge.between.p<-edge.betweenness(otago.graph.p)

closeness(otago.graph)

# Here are the adjacency matrices for each of the 13 subgraphs again
s1<-matrix(c(0,1,0,0,0,1,0,0,0),nrow=3,ncol=3)
s2<-matrix(c(0,1,1,0,0,1,0,0,0),nrow=3,ncol=3)
s3<-matrix(c(0,1,0,0,0,1,1,0,0),nrow=3,ncol=3)
s4<-matrix(c(0,0,1,0,0,1,0,0,0),nrow=3,ncol=3)
s5<-matrix(c(0,1,1,0,0,0,0,0,0),nrow=3,ncol=3)
d2<-matrix(c(0,1,1,1,0,1,0,0,0),nrow=3,ncol=3)
d1<-matrix(c(0,1,1,0,0,1,0,1,0),nrow=3,ncol=3)
d3<-matrix(c(0,0,1,1,0,0,1,0,0),nrow=3,ncol=3)
d4<-matrix(c(0,0,0,1,0,1,0,1,0),nrow=3,ncol=3)
d5<-matrix(c(0,1,1,0,0,1,1,0,0),nrow=3,ncol=3)
d6<-matrix(c(0,1,1,1,0,1,1,1,0),nrow=3,ncol=3)
d7<-matrix(c(0,1,1,1,0,1,1,0,0),nrow=3,ncol=3)
d8<-matrix(c(0,1,1,1,0,0,1,0,0),nrow=3,ncol=3)

# Turn them into a convenient list
subgraph3.mat<-list(s1,s2,s3,s4,s5,d1,d2,d3,d4,d5,d6,d7,d8)
# And then into a list of graph objects
subgraph3.graph<-lapply(subgraph3.mat,graph.adjacency)

# Count the number of the 13 different 3-node subgraphs in the two webs
subgraph.freq.otago<-c()
subgraph.freq.otago.p<-c()
for(i in 1:13){
  subgraph.freq.otago[i]<-
    graph.count.subisomorphisms.vf2(otago.graph,subgraph3.graph[[i]])
  subgraph.freq.otago.p[i]<-
    graph.count.subisomorphisms.vf2(otago.graph.p,subgraph3.graph[[i]])
}

plot(subgraph.freq.otago,type="o",lty=3, xlab="Subgraph",ylab="Frequency")
points(subgraph.freq.otago.p,type="o",lty=2)

plot(subgraph.freq.otago~subgraph.freq.otago.p)
abline(a=0,b=1)