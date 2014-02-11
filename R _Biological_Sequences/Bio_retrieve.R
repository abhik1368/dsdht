#using gene and protein sequences to perform basic statiscs.
#you require seqinr and Biostrings package. To install Bioconductor packages use this site
#http://www.bioconductor.org/install/
#For seqinR manual look at Vignette of seqinR @ http://seqinr.r-forge.r-project.org/seqinr_2_0-1.pdf

installpkg <- function (pkg){
  if (!require(pkg, character.only=T)){
    source("http://bioconductor.org/biocLite.R")
    biocLite(pkg)
  }else{
    require(pkg, character.only=T)
  }
}

installpkg('seqinr')
install.packages('ggplot2')
library(ggplot2)
choosebank()
choosebank(infobank = TRUE)[1:4, ]
choosebank("embl")
str(banknameSocket)
choosebank("genbank")
?query
query("completeCDS", "sp=Arabidopsis thaliana AND t=cds AND NOT k=partial")
nseq <- completeCDS$nelem
#The sequences are obtained with the function getSequence()
seq <- getSequence(completeCDS$req[[1]])
seq[1:20]

#Basecount
basecount <- table(seq)
myseqname <- getName(completeCDS$req[[1]])
myseqname
dotchart(basecount, xlim = c(0, max(basecount)), pch = 19,
         main = paste("Base count in", myseqname))


#dinucleotide count
dinuclcount <- count(seq, 2)
dotchart(dinuclcount[order(dinuclcount)], xlim = c(0, max(dinuclcount)),
         pch = 19, main = paste("Dinucleotide count in", myseqname))
#codon usage stats. Codons are grouped by amino acid. Black dots represent synonymous codons
#amino acid count
codonusage <- uco(seq)
dotchart.uco(codonusage, main = paste("Codon usage in", myseqname))
#Amino Acid count chart  
aacount <- table(getTrans(getSequence(completeCDS$req[[1]])))
aacount <- aacount[order(aacount)]
names(aacount) <- aaa(names(aacount))
dotchart(aacount, pch = 19, xlab = "Stop and amino-acid counts",
         main = "There is only one stop codon")
abline(v = 1, lty = 2)
closebank()
#Performing dotPlot from swissprot
choosebank("swissprot") 
query("leprae", "AC=Q9CD83")
leprae <- getSequence(leprae$req[[1]])
query("ulcerans", "AC=A0PQ23")
ulcerans <- getSequence(ulcerans$req[[1]])
closebank()
dotPlot(leprae, ulcerans)

hae <- read.fasta(file = "test.fasta",seqtype="AA")
#how many fasta sequences
length(hae)
a1<-hae[[2]]
a1
#count number of amino acids.
a<-table(a1)
taborder <- a[order(a)]

names(taborder) <- aaa(names(taborder))#Convert one letter to three letter one

dotchart(taborder,pch=19,xlab="amino-acid-counts")
abline(v=1,lty=2)

#Isoelectric point. The function computePI computes the
#theoretical isoelectric point of a protein, which is the pH at which the protein
#has a neutral charge
computePI(a1)
#Compute Molecular Weight
pmw(a1)
#getting the hydropathy coefficients
data(EXP)
words()
names(EXP$KD) <- sapply(words(), function(x) translate(s2c(x)))
kdc <- EXP$KD[unique(names(EXP$KD))]
kdc <- -kdc[order(names(kdc))]


hydro <- function(data, coef) { #data are sequences
  f <- function(x) {
    freq <- table(factor(x, levels = names(coef)))/length(x)
    return(coef %*% freq) }
  res <- sapply(data, f)
  names(res) <- NULL
  return(res)
}

a<-hydro(a1,kdc)
#get amino acids name
aa<-aaa(a1)
dat<-data.frame(aa,a)
#plot hydropathy plot
library(ggplot2)
qplot(seq_along(dat$a), dat$a)+geom_line(colour="blue")+geom_hline(yintercept=1)

##matching patterns
choosebank("genbank")
installpkg('Biostrings')
query("PKhs","sp=homo sapiens AND k=PRKA@")
kinase <- sapply(PKhs$req, getSequence)
length(kinase)
PKA<-c2s(kinase[[1]])
pattern<- "ggaa"
matchPattern(pattern, PKA, max.mismatch = 0) #Biostrings package




