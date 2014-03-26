# Using Bioconductor packages for Retrieving data.
# Analysing sequences and accessing sequnce data from Genbank and other resources
# You can get the sequin R vignette from http://seqinr.r-forge.r-project.org/seqinr_2_0-1.pdf

# Function to check bioconductor packages
installpkg <- function (pkg){
if (!require(pkg, character.only=T)){
source("http://bioconductor.org/biocLite.R")
biocLite(pkg)
}else{
require(pkg, character.only=T)
}
}

installpkg('seqinr')

library("ggplot2")

choosebank()
choosebank(infobank = TRUE)[1:4, ]
choosebank("embl")
str(banknameSocket)
choosebank("genbank")
?query
query("completeCDS", "sp=Arabidopsis thaliana AND t=cds AND NOT k=partial")
nseq <- completeCDS$nelem
nseq #Shows number of sequences

seq <- getSequence(completeCDS$req[[1]]) # Accessing the first sequence
seq[1:20]
basecount <- table(seq)
myseqname <- getName(completeCDS$req[[1]])
myseqname
dotchart(basecount, xlim = c(0, max(basecount)), pch = 19,main=paste("Basecount of ",myseqname))

#Codon usage of the sequence from seqinR package
codonusage <- uco(seq)
dotchart.uco(codonusage, main = paste("Codon usage in", myseqname))
aacount <- table(getTrans(getSequence(completeCDS$req[[1]])))
aacount <- aacount[order(aacount)]
aacount
names(aacount) <- aaa(names(aacount))
dotchart(aacount, pch = 19, xlab = "Stop and amino-acid counts",
main = "There is only one stop codon")
abline(v = 1, lty = 2)

choosebank("swissprot")
query("leprae", "AC=Q9CD83")
leprae <- getSequence(leprae$req[[1]])
query("ulcerans", "AC=A0PQ23")
ulcerans <- getSequence(ulcerans$req[[1]])
closebank()
dotPlot(leprae, ulcerans)

#using local fasta file
hae <- read.fasta(file = "test.fasta",seqtype="AA")
length(hae)
a1<-hae[[2]]
a1
taborder <- a1[order(a1)]
names(taborder) <- aaa(names(taborder))#Convert one letter to three letter one
dotchart(table(taborder),pch=19,xlab="amino-acid-counts")
abline(v=1,lty=2)

#Compute Isoelectric point
computePI(a1)

#Compute Molecular Weight
pmw(a1)

#Creating Hydropathy scores 
data(EXP)
names(EXP$KD) <- sapply(words(), function(x) translate(s2c(x)))
kdc <- EXP$KD[unique(names(EXP$KD))]
kdc
kdc <- -kdc[order(names(kdc))]

# Hydropathy plot
hydro <- function(data, coef) { #data are sequences
f <- function(x) {
freq <- table(factor(x, levels = names(coef)))/length(x)
return(coef %*% freq) }
res <- sapply(data, f)
names(res) <- NULL
return(res)
}
a<-hydro(a1,kdc)
aa<-aaa(a1)
dat<-data.frame(aa,a)

#Using ggplot to plot hydropathy plot
library(ggplot2)
qplot(seq_along(dat$a), dat$a)+geom_line(colour="blue")+geom_hline(yintercept=1)

#Searchign for patterns in genbank
installpkg("Biostrings")
choosebank("genbank")
query("PKhs","sp=homo sapiens AND k=PRKA@")
kinase <- sapply(PKhs$req, getSequence)
PKA<-c2s(kinase[[1]])
length(kinase)
pattern<- "ggaa"
matchPattern(pattern, PKA, max.mismatch = 0) #Biostrings package
