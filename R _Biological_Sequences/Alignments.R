#Sequence Alignments in R Global and Local alignments using Dynamic programming
#This part shows you to code the famous global and local alignment algorithms and
#using the Biostrings package to perform the alignments.
#If you want to study the algorithms use David Mount Book on Bioinformatics:Sequence and Genome Analysis(http://www.amazon.com/Bioinformatics-Sequence-Analysis-David-Mount/dp/0879697121)

##Using Recursion 
x<-numeric()
x[1]<-1
for (i in 2:10) {x[i]<- 2*x[i-1]-10}
x[10]

library(seqinr)
x <- s2c("GAATTC"); y <- s2c("GATTA");
s <- matrix(data=NA,nrow=length(y),ncol=length(x))
for (i in 1:(nrow(s))) 
  for (j in 1:(ncol(s)))
      {
        if (y[i]==x[j]) s[i,j]<- 2 
            else s[i,j]<- -1 
      }
rownames(s) <- c(y); colnames(s) <- c(x)

F <- matrix(data=NA,nrow=(length(y)+1),ncol=(length(x)+1))
rownames(F) <- c("",y); colnames(F) <- c("",x)
d <- 2
F[,1] <- -seq(0,length(y)*d,d); F[1,] <- -seq(0,length(x)*d,d)
for (i in 2:(nrow(F)))
  for (j in 2:(ncol(F)))
  {
    F[i,j] <- max(c(F[i-1,j-1]+s[i-1,j-1],F[i-1,j]-d,F[i,j-1]-d))
  }
F

#Global ALignment using Needle Man Wunsch Algorithm
library(Biostrings)
s1<-"GAATTC"
s2<-"GATTA"
sigma <- nucleotideSubstitutionMatrix(match = 2, mismatch = -1, baseOnly = TRUE)
globalAligns <- pairwiseAlignment(s1,s2,substitutionMatrix = sigma, gapOpening = 0,
                                     gapExtension = -2, scoreOnly = FALSE)
globalAligns

#Getting the BLOSUM62 substitution Matrix and perform global alignemnt 
file <- "ftp://ftp.ncbi.nih.gov/blast/matrices/BLOSUM62"
BLOSUM62 <- as.matrix(read.table(file, check.names=FALSE))
x <- s2c("HEAGAWGHEEAS"); y <- s2c("PAWHEAE") 
s <- BLOSUM62[y,x]
#Gap penalty
d <- 8
F <- matrix(data=NA,nrow=(length(y)+1),ncol=(length(x)+1))
m<-length(y)*d
n<-length(x)*d
F[1,] <- -seq(0,n,d); F[,1] <- -seq(0,m,d)
rownames(F) <- c("",y); colnames(F) <- c("",x)
for (i in 2:(nrow(F)))
  for (j in 2:(ncol(F)))
  {
    F[i,j] <- max(c(F[i-1,j-1]+s[i-1,j-1],F[i-1,j]-d,F[i,j-1]-d))
  }
F

#using the Biostring packages
s<-pairwiseAlignment(AAString("HEAGAWGHEEAS"), AAString("PAWHEAE"),substitutionMatrix = "BLOSUM62",gapOpening = 0, 
                  gapExtension = -8,scoreOnly = FALSE)
score<-score(s)
#To illustrate how the probability of alignment scores larger than 1 can be computed we sample
#randomly from the names of the amino acids, seven for y and 10 for x and
#compute the maximum alignment score. This is repeated 1000 times and the
#probability of optimal alignment scores greater than your score is estimated by the
#corresponding proportion.

probscore <- double()
for (i in 1:1000) {
  x <- c2s(sample(rownames(BLOSUM62),7, replace=TRUE))
  y <- c2s(sample(rownames(BLOSUM62),10, replace=TRUE))
  probscore[i] <- pairwiseAlignment(AAString(x), AAString(y),
                                       substitutionMatrix = "BLOSUM62",gapOpening = 0, gapExtension = -8,
                                       scoreOnly = TRUE)
}

#The probability of scores larger than your optimal score
sum(probscore>score)/1000

#local alignment 
x <- s2c("MSSSEEVSWISWF"); y <- s2c("MSIKSESISWF")
s <- BLOSUM62[y,x]; d <- 8
F <- matrix(data=NA,nrow=(length(y)+1),ncol=(length(x)+1))
F[1,] <- 0 ; F[,1] <- 0
rownames(F) <- c("",y); colnames(F) <- c("",x)
for (i in 2:(nrow(F)))
  for (j in 2:(ncol(F)))
  {
    F[i,j] <- max(c(0,F[i-1,j-1]+s[i-1,j-1],F[i-1,j]-d,F[i,j-1]-d))
  }

#The Final matrix and the optimal score 
s<-F[nrow(F),ncol(F)]

s<-pairwiseAlignment(AAString("HEAGAWGHEEAS"), AAString("PAWHEAE"),substitutionMatrix = "BLOSUM62",gapOpening = 0, 
                  gapExtension = -8,scoreOnly = FALSE,type="local")

probscore <- double()
for (i in 1:1000) {
  x <- c2s(sample(rownames(BLOSUM62),7, replace=TRUE))
  y <- c2s(sample(rownames(BLOSUM62),10, replace=TRUE))
  probscore[i] <- pairwiseAlignment(AAString(x), AAString(y),
                                    substitutionMatrix = "BLOSUM62",gapOpening = 0, gapExtension = -8,
                                    scoreOnly = TRUE,type="local")
}
score<-score(s)
sum(probscore>score)/1000
