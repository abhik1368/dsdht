###################################################
# Title: Clinical Data Analysis using R
# Code from Dr. DG. Chen edited by Abhik Seal
###################################################
dat = read.csv("dbpdata.csv",header=TRUE)

# create the difference
dat$diff = dat$DBP5-dat$DBP1
# print the first a few observation
head(dat)

# call boxplot
boxplot(diff~TRT, dat, xlab="Treatment", ylab="DBP Changes")

# call t-test with equal variance 
t.test(diff~TRT, dat, var.equal=T)

# Welch test
t.test(diff~TRT, dat, var.equal=F)

# Ftest
var.test(diff~TRT, dat)

wilcox.test(diff~TRT, dat)

# data from treatment A
diff.A = dat[dat$TRT=="A",]$diff
# data from treatment B
diff.B = dat[dat$TRT=="B",]$diff
# call t.test for one-sided test
t.test(diff.A, diff.B,alternative="less")

# bootstrap to test the significance of the dierence in DBP treatment group means
# load the library "bootstrap"
library(bootstrap)
# define a function to calculate the mean difference 
#	between treatment groups A to B:
mean.diff = function(bn,dat) 
  diff(tapply(dat[bn,]$diff, dat[bn,]$TRT,mean))

# number of bootstrap
nboot     = 1000
# call "bootstrap" function
boot.mean = bootstrap(1:dim(dat)[1], nboot, mean.diff,dat)

# extract the mean differences  
x = boot.mean$thetastar
# calcualte the bootstrap quantiles
x.quantile = quantile(x, c(0.025,0.5, 0.975))
# show the quantiles
print(x.quantile)
# make a histogram
hist(boot.mean$thetastar, xlab="Mean Differences", main="")
# add the vertical lines for the quantiles 
abline(v=x.quantile,lwd=2, lty=c(4,1,4)) 

# To see mean changes the months following baseline
aggregate(dat[,3:7], list(TRT=dat$TRT), mean)

#call reshape
Dat = reshape(dat, direction="long", 
varying=c("DBP1","DBP2","DBP3","DBP4","DBP5"),
 idvar = c("Subject","TRT","Age","Sex","diff"),sep="")
colnames(Dat) = c("Subject","TRT","Age","Sex","diff","Time","DBP")
Dat$Time = as.factor(Dat$Time)
head(Dat)

# one-way ANOVA to test the null hypotheses that the means of DBP at all five times of measurement are equal
# test treatment "A"
datA   = Dat[Dat$TRT=="A",]
test.A = aov(DBP~Time, datA)
summary(test.A)
# test treatment "B"
datB   = Dat[Dat$TRT=="B",]
test.B = aov(DBP~Time, datB)
summary(test.B)

# To understand the nature of the differences across time, multiple range testing
TukeyHSD(test.A)
TukeyHSD(test.B)

# statistical signicance of the interaction betweeb A and B
mod2 = aov(DBP~ TRT*Time, Dat)
summary(mod2)

# plot the interactions between TRT and Time
par(mfrow=c(2,1),mar=c(5,3,1,1))
with(Dat,interaction.plot(Time,TRT,DBP,las=1,legend=T))
with(Dat,interaction.plot(TRT,Time,DBP,las=1,legend=T))

# Use multiple comparison approach for testing main effects. 
TukeyHSD(aov(DBP ~ TRT*Time,Dat))


