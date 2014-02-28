library(rcdk)
library(RColorBrewer)
library(gplots)
library(pheatmap)

#read in the test dataset of compounds and targets
data<-read.csv("testKinase.csv",header=T)

#parse the smiles from the compounds
Smiles<-lapply(as.character(data[,2]),parse.smiles)

#Generate murcko scaffolds
frags<-lapply(Smiles,get.murcko.fragments,single.framework = TRUE)

#unlisting
fworks<-lapply(frags,function(x) x[[1]]$frameworks)
frag.freq<-data.frame(table(unlist(fworks)))
frag.freq$index<-1:nrow(frag.freq)
#build a look up table
dat<-data.frame()
for ( i in 1:length(fworks))
{
  if(length(fworks[i])>=1)
  {
    set<-cbind(fworks[[i]][1],data$PUBCHEM_SID[i])
    dat<-rbind(dat,set)
  }
}

colnames(dat)<-c("scaffold","mid")
#Query scaffold
query<-'c1nc(nc(c1)c3c[nH]c2ncccc23)NC4CCCCC4'

#Subset molecules from the main set with a given scaffold
ids<-subset(dat,scaffold == query)
depvs<-subset(data,PUBCHEM_SID %in% ids$mid)[,3:174]
depvs<-cbind(pubchemid=ids$mid,depvs)

#For pedagogical purposes converting blank activity values to 0
depvs[is.na(depvs)]<-0

#Plotting the heat maps of compound id's and Targets
heatmap.2(as.matrix(depvs[,2:50]), dendrogram="col",col=redgreen(75),cexRow=0.9,scale="none",density.info="none", trace="none",labRow=depvs[,1])

rownames(depvs)<-depvs[,1]
pheatmap(as.matrix(depvs[,2:50]),show_rownames=T,color = colorRampPalette(c("navy", "white", "firebrick3"))(50))

#-------------------------------------------------------#
# Working with full dataset and matched molecular pairs #
# taken from Rajarshi's code                            #
#-------------------------------------------------------#
#read in the test dataset of compounds and targets
data<-read.csv("testKinase.csv",header=T)

#parse the smiles from the compounds
Smiles<-lapply(as.character(data[,2]),parse.smiles)
fps<-lapply(Smiles,get.fingerprint,'extended')
cmp.fp = vector("list",length(Smiles))

for (i in 1:length(Smiles)){
  
  cmp.fp[[i]] = lapply(Smiles[[i]], get.fingerprint, type="extended")
  
}
fp.sim = fp.sim.matrix(unlist(cmp.fp))
idxs<-which(fp.sim > 0.95,arr.ind=TRUE)
idxs <- idxs[idxs[,1] > idxs[,2],]

rownames(data)<-data[,1]
data[is.na(data)]<-0

#matched molecular pairs
mps<-t(apply(idxs,1,function(x){
  apply(data,2,function(z){
    d<-abs(z[x[1]]-z[x[2]])
    ifelse(d >=1,d,NA)
  })  
}))
dim(mps)
mps[is.na(mps)]<-0
rownames(mps)<-mps[,1]
pheatmap(mps[1:20,2:100],cluster_rows=FALSE,color=colorRampPalette(rev(c("#D73027", "#FC8D59", "#FEE090", "#FFFFBF", "#E0F3F8", "#91BFDB", "#4575B4")))(100),border_color="black",fontsize=12)
