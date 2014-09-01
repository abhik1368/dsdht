---
title       : Data Manipulation on R
subtitle    : Factor Manipulations,subset,sorting and Reshape
author      : Abhik Seal    
job         : Indiana University School of Informatics and Computing(dsdht.wikispaces.com)
framework   : io2012        # {io2012, html5slides, shower, dzslides, ...}
highlighter : highlight.js  # {highlight.js, prettify, highlight}
hitheme     : tomorrow      # 
widgets     : []            # {mathjax, quiz, bootstrap}
mode        : selfcontained # {standalone, draft}
---

## Basic Manipulating Data

So far , we've covered how to read in data from various ways like from files, internet and databases and reading various formats of files. This session we are interested to manipulate
data after reading in the file for easy data processing.

---

## Sorting and Ordering data
```sort(x,decreasing=FALSE) :``` 'sort (or order) a vector or factor (partially) into ascending or descending order.'
```order(...,decreasing=FALSE):```'returns a permutation which rearranges its first argument
into ascending or descending order, breaking ties by further arguments.'


```r
x <- c(1,5,7,8,3,12,34,2)
sort(x)
```

```
## [1]  1  2  3  5  7  8 12 34
```

```r
order(x)
```

```
## [1] 1 8 5 2 3 4 6 7
```

---

## Some examples of sorting and ordering


```r
# sort by mpg
newdata <- mtcars[order(mpg),]
head(newdata,3)
```

```
##                      mpg cyl disp  hp drat    wt  qsec vs am gear carb
## Cadillac Fleetwood  10.4   8  472 205 2.93 5.250 17.98  0  0    3    4
## Lincoln Continental 10.4   8  460 215 3.00 5.424 17.82  0  0    3    4
## Camaro Z28          13.3   8  350 245 3.73 3.840 15.41  0  0    3    4
```

```r
# sort by mpg and cyl
newdata <- mtcars[order(mpg, cyl),]
head(newdata,3)
```

```
##                      mpg cyl disp  hp drat    wt  qsec vs am gear carb
## Cadillac Fleetwood  10.4   8  472 205 2.93 5.250 17.98  0  0    3    4
## Lincoln Continental 10.4   8  460 215 3.00 5.424 17.82  0  0    3    4
## Camaro Z28          13.3   8  350 245 3.73 3.840 15.41  0  0    3    4
```

---

## Ordering with plyr


```r
library(plyr)
head(arrange(mtcars,mpg),3)
```

```
##    mpg cyl disp  hp drat    wt  qsec vs am gear carb
## 1 10.4   8  472 205 2.93 5.250 17.98  0  0    3    4
## 2 10.4   8  460 215 3.00 5.424 17.82  0  0    3    4
## 3 13.3   8  350 245 3.73 3.840 15.41  0  0    3    4
```

```r
head(arrange(mtcars,desc(mpg)),3)
```

```
##    mpg cyl disp hp drat    wt  qsec vs am gear carb
## 1 33.9   4 71.1 65 4.22 1.835 19.90  1  1    4    1
## 2 32.4   4 78.7 66 4.08 2.200 19.47  1  1    4    1
## 3 30.4   4 75.7 52 4.93 1.615 18.52  1  1    4    2
```

---

## Subsetting data


```r
set.seed(12345)
#create a dataframe 
X<-data.frame("A"=sample(1:10),"B"=sample(11:20),"C"=sample(21:30))
# Add NA VALUES
X<-X[sample(1:10),];X$B[c(1,6,10)]=NA
head(X)
```

```
##     A  B  C
## 8   4 NA 27
## 1   8 11 25
## 2  10 12 23
## 5   3 13 24
## 3   7 16 28
## 10  5 NA 26
```

---

## Basic data subsetting

```r
# Accessing only first row
X[1,]
```

```
##   A  B  C
## 8 4 NA 27
```

```r
# accessing only first column
X[,1]
```

```
##  [1]  4  8 10  3  7  5  9  1  2  6
```

```r
# accessing first row and first column
X[1,1]
```

```
## [1] 4
```

---
## And/OR's 


```r
head(X[(X$A <=6 & X$C > 24),],3)
```

```
##    A  B  C
## 8  4 NA 27
## 10 5 NA 26
## 7  2 19 29
```

```r
head(X[(X$A <=6 | X$C > 24),],3)
```

```
##   A  B  C
## 8 4 NA 27
## 1 8 11 25
## 5 3 13 24
```

---

## select Non NA values Data Frame

```r
# select the dataframe without NA values in B column
head(X[which(X$B!='NA'),],4)
```

```
##    A  B  C
## 1  8 11 25
## 2 10 12 23
## 5  3 13 24
## 3  7 16 28
```

```r
# select those which have values > 14
head(X[which(X$B>11),],4)
```

```
##    A  B  C
## 2 10 12 23
## 5  3 13 24
## 3  7 16 28
## 4  9 20 30
```

---


```r
# creating a data frame with 2 variables
data <- data.frame(x1=c(2,3,4,5,6),x2=c(5,6,7,8,1))
list_data<-list(dat=data,vec.obj=c(1,2,3))
list_data
```

```
## $dat
##   x1 x2
## 1  2  5
## 2  3  6
## 3  4  7
## 4  5  8
## 5  6  1
## 
## $vec.obj
## [1] 1 2 3
```

```r
# accessing second element of the list_obj objects
list_data[[2]]
```

```
## [1] 1 2 3
```

---

## Factors

Factors are used to represent categorical data, and can also be used for ordinal data (ie
categories have an intrinsic ordering) Note that R reads in character strings as factors by default in functions like read.table()'The function factor is used to encode a vector as a factor (the terms 'category' and 'enumerated type' are also used for factors). If argument ordered is TRUE, the factor levels are assumed to be
ordered. For compatibility with S there is also a function ordered.'is.factor, is.ordered, as.factor and as.ordered are the membership and coercion functions for these classes.

---

## Factors
Suppose we have a vector of case-control status

```r
cc=factor(c("case","case","case","control","control","control"))
cc
```

```
## [1] case    case    case    control control control
## Levels: case control
```

```r
levels(cc)=c("control","case")
cc
```

```
## [1] control control control case    case    case   
## Levels: control case
```

---

## Factors

Factors can be converted to numericor charactervery easily

```r
x=factor(c("case","case","case","control","control","control"),levels=c("control","case"))
as.character(x)
```

```
## [1] "case"    "case"    "case"    "control" "control" "control"
```

```r
as.numeric(x)
```

```
## [1] 2 2 2 1 1 1
```

---

## Cut 

Now that we know more about factors, cut()will make more sense:

```r
x=1:100
cx=cut(x,breaks=c(0,10,25,50,100))
head(cx)
```

```
## [1] (0,10] (0,10] (0,10] (0,10] (0,10] (0,10]
## Levels: (0,10] (10,25] (25,50] (50,100]
```

```r
table(cx)
```

```
## cx
##   (0,10]  (10,25]  (25,50] (50,100] 
##       10       15       25       50
```

---

## Cut

We can also leave off the labels

```r
cx=cut(x,breaks=c(0,10,25,50,100),labels=FALSE)
head(cx)
```

```
## [1] 1 1 1 1 1 1
```

```r
table(cx)
```

```
## cx
##  1  2  3  4 
## 10 15 25 50
```

---

## Cut

```r
cx=cut(x,breaks=c(10,25,50),labels=FALSE)
head(cx)
```

```
## [1] NA NA NA NA NA NA
```

```r
table(cx)
```

```
## cx
##  1  2 
## 15 25
```

```r
table(cx,useNA="ifany")
```

```
## cx
##    1    2 <NA> 
##   15   25   60
```

---

## Adding to data frames

```r
m1=matrix(1:9,nrow=3,ncol=3,byrow=FALSE)
m1
```

```
##      [,1] [,2] [,3]
## [1,]    1    4    7
## [2,]    2    5    8
## [3,]    3    6    9
```

```r
m2=matrix(1:9,nrow=3,ncol=3,byrow=TRUE)
m2
```

```
##      [,1] [,2] [,3]
## [1,]    1    2    3
## [2,]    4    5    6
## [3,]    7    8    9
```

---

## Adding using cbind
You can add columns (or another matrix/data frame) to a data frame or matrix
using cbind()('column bind'). You can also add rows (or another matrix/data frame) using
rbind()('row bind').
Note that the vector you are adding has to have the same length as the number of rows (for
cbind()) or the number of columns (rbind())

```r
cbind(m1,m2)
```

```
##      [,1] [,2] [,3] [,4] [,5] [,6]
## [1,]    1    4    7    1    2    3
## [2,]    2    5    8    4    5    6
## [3,]    3    6    9    7    8    9
```

---

##  Reshape data 
Datasets layout could be long or wide. In long-layout, multiple rows represent a 
single subject's record, whereas in wide-layout, a single row represents a single 
subject's record. In doing some statistical analysis sometimes we require wide data 
and sometimes long data, so that we can easily reshape the data to meet the requirements 
of statistical analysis. Data reshaping is just a rearrangement of the form of the 
data—it does not change the content of the dataset. This section mainly focuses 
the melt and cast paradigm of reshaping datasets, which is implemented in the 
reshape contributed package. Later on, this same package is reimplemented 
with a new name, reshape2, which is much more time and memory efficient 
(the Reshaping Data with the reshape Package paper, by Wickham, which can be 
found at (http://www.jstatsoft.org/v21/i12/paper))

---

Wide data has a column for each variable. For example, this is wide-format data:

```r
#   ozone   wind  temp
# 1 23.62 11.623 65.55
# 2 29.44 10.267 79.10
# 3 59.12  8.942 83.90
# 4 59.96  8.794 83.97
```
Data in long format 

```r
#    variable  value
# 1     ozone 23.615
# 2     ozone 29.444
# 3     ozone 59.115
# 4     ozone 59.962
# 5      wind 11.623
# 6      wind 10.267
# 7      wind  8.942
# 8      wind  8.794
# 9      temp 65.548
# 10     temp 79.100
# 11     temp 83.903
# 12     temp 83.968
```

---

## reshape 2 Package

"In reality, you need long-format data much more commonly than wide-format data. For example, ggplot2 requires long-format data plyr requires long-format data, and most modelling functions (such as lm(), glm(), and gam()) require long-format data. But people often find it easier to record their data in wide format."

reshape2 is based around two key functions: melt and cast:
```melt``` takes wide-format data and melts it into long-format data.
```cast``` takes long-format data and casts it into wide-format data.

---

## Melt


```r
library(reshape2)
head(airquality,2)
```

```
##   ozone solar.r wind temp month day
## 1    41     190  7.4   67     5   1
## 2    36     118  8.0   72     5   2
```

```r
aql <- melt(airquality) # [a]ir [q]uality [l]ong format
head(aql,5)
```

```
##   variable value
## 1    ozone    41
## 2    ozone    36
## 3    ozone    12
## 4    ozone    18
## 5    ozone    NA
```

---

By default, melt has assumed that all columns with numeric values are variables with values. Maybe here we want to know the values of ozone, solar.r, wind, and temp for each month and day. We can do that with melt by telling it that we want month and day to be “ID variables”. ID variables are the variables that identify individual rows of data.


```r
m <- melt(airquality, id.vars = c("month", "day"))
head(m,4)
```

```
##   month day variable value
## 1     5   1    ozone    41
## 2     5   2    ozone    36
## 3     5   3    ozone    12
## 4     5   4    ozone    18
```

---

# Melt also allow us to control the column names in long data format


```r
m <- melt(airquality, id.vars = c("month", "day"),
  variable.name = "climate_variable", 
  value.name = "climate_value")
head(m)
```

```
##   month day climate_variable climate_value
## 1     5   1            ozone            41
## 2     5   2            ozone            36
## 3     5   3            ozone            12
## 4     5   4            ozone            18
## 5     5   5            ozone            NA
## 6     5   6            ozone            28
```

---

## Long- to wide-format data: the cast functions

In reshape2 there are multiple cast functions. Since you will most commonly work with data.frame objects, we’ll explore the dcast function. (There is also acast to return a vector, matrix, or array.)
dcast uses a formula to describe the shape of the data. 


```r
m <- melt(airquality, id.vars = c("month", "day"))
aqw <- dcast(m, month + day ~ variable)
head(aqw)
```

```
##   month day ozone solar.r wind temp
## 1     5   1    41     190  7.4   67
## 2     5   2    36     118  8.0   72
## 3     5   3    12     149 12.6   74
## 4     5   4    18     313 11.5   62
## 5     5   5    NA      NA 14.3   56
## 6     5   6    28      NA 14.9   66
```
Here, we need to tell dcast that month and day are the ID variables.

Besides re-arranging the columns, we’ve recovered our original data.

---

## Data Manipulation Using plyr

For large-scale data, we can split the dataset, perform the manipulation or analysis, 
and then combine it into a single output again. This type of split using default R is not 
much efficient, and to overcome this limitation, Wickham, in 2011, developed an R package 
called plyr in which he efficiently implemented the split-apply-combine strategy. We can compare
this strategy to map-reduce strategy for processing large amount of data.

In the coming slides i will give example of the split-apply-combine strategy using
* Without Loops
* With Loops
* Using plyr package

---

## Without loops
I am using the iris dataset here

1. Split the iris dataset into three parts.
2. Remove the species name variable from the data.
3. Calculate the mean of each variable for the three different parts separately.
4. Combine the output into a single data frame.


```r
iris.set <- iris[iris$Species=="setosa",-5]
iris.versi <- iris[iris$Species=="versicolor",-5]
iris.virg <- iris[iris$Species=="virginica",-5]
# calculating mean for each piece (The apply step)
mean.set <- colMeans(iris.set)
mean.versi <- colMeans(iris.versi)
mean.virg <- colMeans(iris.virg)
# combining the output (The combine step)
mean.iris <- rbind(mean.set,mean.versi,mean.virg)
# giving row names so that the output could be easily understood
rownames(mean.iris) <- c("setosa","versicolor","virginica")
```

---

## With Loops


```r
mean.iris.loop <- NULL
for(species in unique(iris$Species))
    {
      iris_sub <- iris[iris$Species==species,]
      column_means <- colMeans(iris_sub[,-5])
      mean.iris.loop <- rbind(mean.iris.loop,column_means)
    } 
# giving row names so that the output could be easily understood
rownames(mean.iris.loop) <- unique(iris$Species)
```
NB: In the split-apply-combine strategy is that each piece should be independent of the other. The strategy wont work if one piece is dependent upon one another.

---

## Using plyr


```r
library (plyr)
ddply(iris,~Species,function(x) colMeans(x[,-
which(colnames(x)=="Species")]))
```

```
##      Species Sepal.Length Sepal.Width Petal.Length Petal.Width
## 1     setosa        5.006       3.428        1.462       0.246
## 2 versicolor        5.936       2.770        4.260       1.326
## 3  virginica        6.588       2.974        5.552       2.026
```

```r
mean.iris.loop
```

```
##            Sepal.Length Sepal.Width Petal.Length Petal.Width
## setosa            5.006       3.428        1.462       0.246
## versicolor        5.936       2.770        4.260       1.326
## virginica         6.588       2.974        5.552       2.026
```

---

## Merging data frames

```r
# Make a data frame mapping story numbers to titles
stories <- read.table(header=T, text='
   storyid  title
    1       lions
    2      tigers
    3       bears
')

# Make another data frame with the data and story numbers (no titles)
data <- read.table(header=T, text='
    subject storyid rating
          1       1    6.7
          1       2    4.5
          1       3    3.7
          2       2    3.3
          2       3    4.1
          2       1    5.2
')
```

---

## Merge the two data frames

```r
merge(stories, data, "storyid")
```

```
##   storyid  title subject rating
## 1       1  lions       1    6.7
## 2       1  lions       2    5.2
## 3       2 tigers       1    4.5
## 4       2 tigers       2    3.3
## 5       3  bears       1    3.7
## 6       3  bears       2    4.1
```
If the two data frames have different names for the columns you want to match on, the names can be specified:

```r
# In this case, the column is named 'id' instead of storyid
stories2 <- read.table(header=T, text='
   id       title
    1       lions
    2      tigers
    3       bears ')
merge(x=stories2, y=data, by.x="id", by.y="storyid")
```

```
##   id  title subject rating
## 1  1  lions       1    6.7
## 2  1  lions       2    5.2
## 3  2 tigers       1    4.5
## 4  2 tigers       2    3.3
## 5  3  bears       1    3.7
## 6  3  bears       2    4.1
```

---

## Resources and Materials used

* [Data Manipulation with R by Phil Spector](http://link.springer.com/book/10.1007%2F978-0-387-74731-6)
* [Getting and Cleaning data Coursera Course](https://class.coursera.org/getdata-006/lecture)
* [plyr by Hadley Wickham ](http://plyr.had.co.nz/)
* [Andrew Jaffe Notes ](http://www.biostat.jhsph.edu/~ajaffe/rsummer2014.html)
* [R cookbok](http://www.cookbook-r.com/)

---

---

---
