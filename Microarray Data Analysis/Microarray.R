#---------------------------------------------------------------------------------------------
# Microarray Tutorial 2 
<<<<<<< HEAD
# 1. Distinction between unsupervised (PCA) and supervised classification
# 2. Training, testing and prediction

# A subtype of childhood acute lymphoblastic leukaemia with poor treatment outcome: a genome-wide # classification study (http://www.ncbi.nlm.nih.gov/pmc/articles/PMC2707020/pdf/nihms108820.pdf)
# Load the expression profiles (one row per gene, one column per sample).
#--------------------------------------------------------------------------------------------
=======
# 1. Distinction between unsupervised (clustering) and supervised classication
# 2. Training, testing and prediction

# A subtype of childhood acute lymphoblastic leukaemia with poor treatment outcome: a genome-wide 
# classification study (http://www.ncbi.nlm.nih.gov/pmc/articles/PMC2707020/pdf/nihms108820.pdf)
# Load the expression profiles (one row per gene, one column per sample).
#--------------------------------------------------------------------------------------------


>>>>>>> FETCH_HEAD
expr.matrix <- read.table("GSE13425_Norm_Whole.txt", sep = "\t", head = T, row = 1)
print(dim(expr.matrix))
pheno <- read.table('phenoData_GSE13425.tab', sep='\t', head=TRUE, row=1)
dim(pheno)
names(pheno)
print(data.frame("n"=sort(table(pheno$Sample.title),decreasing=T)))
group.abbrev <- c(
  'BCR-ABL + hyperdiploidy'='Bch',
  'BCR-ABL'='Bc',
  'E2A-rearranged (E)'='BE',
  'E2A-rearranged (E-sub)'='BEs',
  'E2A-rearranged (EP)'='BEp',
  'MLL'='BM',
  'T-ALL'='T',
  'TEL-AML1 + hyperdiploidy'='Bth',
  'TEL-AML1'='Bt',
  'hyperdiploid'='Bh',
  'pre-B ALL'='Bo'
)
sample.subtypes <- as.vector(pheno$Sample.title)
sample.labels <- group.abbrev[sample.subtypes]
names(sample.labels) <- names(expr.matrix)

## Check the label for a random selection of 10 samples. 
## Each run should give a different result
sample(sample.labels, size=10)
group.colors <- c(
  'BCR-ABL + hyperdiploidy'='cyan',
  'BCR-ABL'='black',
  'E2A-rearranged (E)'='darkgray',
  'E2A-rearranged (E-sub)'='green',
  'E2A-rearranged (EP)'='orange',
  'MLL'='#444400',
  'T-ALL'='violet',
  'TEL-AML1 + hyperdiploidy'='#000066',
  'TEL-AML1'='darkgreen',
  'hyperdiploid'='red',
  'pre-B ALL'='blue'
)

## Assign group-specific colors to patients
sample.colors <- group.colors[as.vector(pheno$Sample.title)]
names(sample.colors) <- names(expr.matrix)
sample(sample.colors,size=20)
g1 <- 236
g2 <- 1213
x <- as.vector(as.matrix(expr.matrix[g1,]))
y <- as.vector(as.matrix(expr.matrix[g2,]))
plot(x,y,
     col=sample.colors,
     type='n',
     panel.first=grid(col='black'), 
     main='Den Boer two selected genes', 
     xlab=paste('gene', g1), ylab=paste('gene', g2))
text(x, y,labels=sample.labels,col=sample.colors,pch=0.5)
legend('topright',col=group.colors, 
       legend=names(group.colors),pch=0.5,cex=0.5,bg='white',inset=0.01,x.intersp=2,xjust=0,yjust=0)

## Compute sample-wise variance
## Reducing the dimensionality of the data - feature selection
var.per.sample <- apply(expr.matrix, 2, var)
head(var.per.sample)

## Inspect the distribution of sample-wise variance
hist(var.per.sample, breaks=20)
## Compute gene-wise variance
var.per.gene <- apply(expr.matrix, 1, var)

## Inspect the distribution of gene-wise variance
hist(var.per.gene, breaks=100)
## Sort genes per decreasing variance
genes.by.decr.var <- sort(var.per.gene,decreasing=TRUE)

## Print the 5 genes with highest variance
head(genes.by.decr.var)

## Create a data frame to store gene values and ranks 
## for different selection criteria.
gene.ranks <- data.frame(var=var.per.gene)
head(gene.ranks)
## Beware, we rank according to minus variance, because 
## we want to associate the lowest ranks to the highest variances
gene.ranks$var.rank <- rank(-gene.ranks$var, ties.method='random')
head(gene.ranks)

## Check the rank of the 5 genes with highest and lowest variance, resp.
gene.ranks[names(genes.by.decr.var[1:5]),]

#1# Print the bottom 5 genes of the variance-sorted table
gene.ranks[names(tail(genes.by.decr.var)),]

## Plot the expression profiles of the two genes with highest variance
g1 <- names(genes.by.decr.var[1])
print(g1)
(g2 <- names(genes.by.decr.var[2]))

x <- as.vector(as.matrix(expr.matrix[g1,]))
y <- as.vector(as.matrix(expr.matrix[g2,]))
plot(x,y,
     col=sample.colors,
     type='n',
     panel.first=grid(col='black'), 
     main="2 genes with the highest variance", 
     xlab=paste('gene', g1), 
     ylab=paste('gene', g2))
text(x, y,labels=sample.labels,col=sample.colors,pch=0.5)
legend('topright',col=group.colors, 
       legend=names(group.colors),pch=0.5,cex=0.5,bg='white',inset=0.01,x.intersp=2,xjust=0,yjust=0)

library(stats) 

## Perform the PCA transformation
expr.prcomp <- prcomp(t(expr.matrix),cor=TRUE)

## Analyze the content of the prcomp result: 
## the result of the method prcomp() is an object 
## belonging to the class "prcomp"
class(expr.prcomp) 
attributes(expr.prcomp)
plot(expr.prcomp, main='Variance  per component', xlab='Component')
sd.per.pc <- expr.prcomp$sdev
var.per.pc <- sd.per.pc^2

## Display the percentage of total variance explained by each 
sd.per.pc.percent <- sd.per.pc/sum(sd.per.pc)
var.per.pc.percent <- var.per.pc/sum(var.per.pc)
barplot(var.per.pc.percent[1:10], main='Percent of variance  per component'
        , xlab='Component', ylab='Percent variance', col='#BBDDFF')
biplot(expr.prcomp,var.axes=FALSE,
       panel.first=grid(col='black'), 
       main=paste('PCA Plot ',
                  ncol(expr.matrix), 'samples *', nrow(expr.matrix), 'genes', sep=' '), 
       xlab='First component', ylab='Second component')

plot(expr.prcomp$x[,1:2],
     col=sample.colors,
     type='n',
     panel.first=grid(col='black'), 
     main=paste('PCA Plot; ',
                ncol(expr.matrix), 'samples *', nrow(expr.matrix), 'genes', sep=' '), 
     xlab='PC1', ylab='PC2')
text(expr.prcomp$x[,1:2],labels=sample.labels,col=sample.colors,pch=0.5)
legend('bottomleft',col=group.colors, 
       legend=names(group.colors),pch=1,cex=0.7,bg='white',bty='o')
## Plot components PC2 and PC3
plot(expr.prcomp$x[,2:3],
     col=sample.colors,
     type='n',
     panel.first=grid(col='black'), 
     main=paste('PCA Plot',
                ncol(expr.matrix), 'samples *', nrow(expr.matrix), 'genes', sep=' '), 
     xlab='PC2', ylab='PC3')
text(expr.prcomp$x[,2:3],labels=sample.labels,col=sample.colors,pch=0.5)     
legend('bottomleft',col=group.colors, 
       legend=names(group.colors),pch=1,cex=0.7,bg='white',bty='o')

## Load the library containing the linear discriminant analysis function
library(MASS)

## Create a list of gene names sorted by decreasing variance
sorted.names <- rownames(gene.ranks)[order(gene.ranks$var, decreasing=TRUE)]

## Select the 20 top-ranking genes sorted by decreasing variance
top.variables <- 20
selected.genes <- sorted.names[1:top.variables]
## Train the classifier
lda.classifier <- lda(t(expr.matrix[selected.genes,]),sample.labels,CV=FALSE) 

## Use the MASS:lda() function with the cross-validation option
lda.loo <- lda(t(expr.matrix[selected.genes,]),sample.labels,CV=TRUE) 

## Collect the LOO prediction result in a vector
loo.predicted.class <- as.vector(lda.loo$class)
print(loo.predicted.class)
table(loo.predicted.class)

## Build a contingency table of known versus predicted class
lda.loo.xtab <- table(sample.labels, loo.predicted.class)
print(lda.loo.xtab)

library(lattice)
levelplot(lda.loo.xtab)

## Compute the hit rate
hits <- sample.labels == loo.predicted.class
errors <- sample.labels != loo.predicted.class

## Compute the number of hits 
## (we need to omit NA values because LDA fails to assign a group to some objects).
(nb.hits <- sum(na.omit(hits))) 
(nb.pred <- length(na.omit(hits))) 
(hit.rate <- nb.hits / nb.pred ) 

## Permute the training labels
sample.labels.perm <- as.vector(sample(sample.labels))

## Compare original training groups and permuted labels.
table(sample.labels, sample.labels.perm)

## Run LDA in cross-validation (LOO) mode with the permuted labels
lda.loo.labels.perm <- lda(t(expr.matrix[selected.genes,]),sample.labels.perm,CV=TRUE) 

## Build a contingency table of known versus predicted class
loo.predicted.class.labels.perm <- as.vector(lda.loo.labels.perm$class)
lda.loo.labels.perm.xtab <- table(sample.labels.perm, loo.predicted.class.labels.perm)
print(lda.loo.labels.perm.xtab)

## Levelplot uses a nice color palette
levelplot(lda.loo.labels.perm.xtab)


## Compute the number of hits 
## (we need to omit NA values because LDA fails to assign a group to some objects).
hits.label.perm <- sample.labels.perm == loo.predicted.class.labels.perm
(nb.hits.label.perm <- sum(na.omit(hits.label.perm))) ## This gives 25 this time, but should give different results at each trial
(nb.pred.label.perm <- length(na.omit(hits.label.perm))) ## This should give 187
(hit.rate.label.perm <- nb.hits.label.perm / nb.pred.label.perm ) ## This gives 0.13 this time, should give different results at each trial
