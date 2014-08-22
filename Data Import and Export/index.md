---
title       : Data Handling in R
subtitle    : Getting,Reading and Cleaning data
author      : Abhik Seal
job         : Indiana University School of Informatics and Computing(dsdht.wikispaces.com)
framework   : io2012        # {io2012, html5slides, shower, dzslides, ...}
highlighter : highlight.js  # {highlight.js, prettify, highlight}
hitheme     : tomorrow      # 
widgets     : [mathjax]            # {mathjax, quiz, bootstrap}
mode        : selfcontained # {standalone, draft}
--- 
## Get/set your working directory

* A basic component of working with data is knowing your working directory
* The two main commands are ```getwd()``` and ```setwd()```. 
* Be aware of relative versus absolute paths
  * __Relative__ - ```setwd("./data")```, ```setwd("../")```
  * __Absolute__ - ```setwd("/Users/datasc/data/")```
* Important difference in Windows ```setwd("C:\\Users\\datasc\\Downloads")```

---
## Checking for and creating directories

* ```file.exists("directoryName")``` will check to see if the directory exists
* ```dir.create("directoryName")``` will create a directory if it doesn't exist
* Here is an example checking for a "data" directory and creating it if it doesn't exist


```r
if(!file.exists("data")){
  dir.create("data")
}
```

---

## Reading data files 

* From Internet
* Reading local files
* Reading Excel Files
* Reading XML
* Reading JSON
* Reading MySQL
* Reading HDF5
* Reading from other resources

We wil look at each of the methods 

---

## Getting data from Internet 
* Use of download.file() 
* Useful for downloading tab-delimited, csv, and other files


```r
fileUrl <- "http://dashboard.healthit.gov/data/data/NAMCS_2008-2013.csv"
download.file(fileUrl,destfile="./data/NAMCS.csv",method="curl")
list.files("./data")
```

```
## [1] "NAMCS.csv"
```
Data from [Healthit.gov](http://dashboard.healthit.gov/data/)

---
## Getting data from Internet 
Reading the data using read.csv()

```r
data<-read.csv("http://dashboard.healthit.gov/data/data/NAMCS_2008-2013.csv")
head(data,2)
```

```
##    Region Period Adoption.of.Basic.EHRs..Overall.Physician.Practices
## 1 Alabama   2013                                                0.48
## 2  Alaska   2013                                                0.50
##   Adoption.of.Basic.EHRs..Primary.Care.Providers
## 1                                           0.50
## 2                                           0.52
##   Adoption.of.Basic.EHRs..Rural.Providers
## 1                                    0.54
## 2                                    0.37
##   Adoption.of.Basic.EHRs..Small.Practices
## 1                                    0.40
## 2                                    0.39
##   Percent.of.office.based.physicians.with.computerized.capability.to.view.lab.results
## 1                                                                                0.74
## 2                                                                                0.75
##   Percent.of.office.based.physicians.with.capability.to.send.orders.for.lab.tests.electronically
## 1                                                                                           0.48
## 2                                                                                           0.67
##   Percent.of.office.based.physicians.with.EHR.EMR.that.can.automatically.graph.a.specific.patent.s.lab.results.over.time
## 1                                                                                                                   0.38
## 2                                                                                                                   0.46
##   Percent.of.office.based.physicians.with.capability.to.exchange.secure.messages.with.patients
## 1                                                                                         0.38
## 2                                                                                         0.44
##   Percent.of.office.based.physicians.with.capability.to.provide.patients.with.clinical.summaries.for.each.visit
## 1                                                                                                          0.56
## 2                                                                                                          0.73
```

---

## Some notes about download.file()

* If the url starts with _http_ you can use download.file()
* If the url starts with _https_ on Windows you may be ok
* If the url starts with _https_ on Mac you may need to set _method="curl"_
* If the file is big, this might take a while
* Be sure to record when you downloaded. 

---

## Loading flat files - read.table()

* This is the main function for reading data into R
* Flexible and robust but requires more parameters
* Reads the data into RAM - big data can cause problems
* Important parameters _file_, _header_, _sep_, _row.names_, _nrows_
* Related: _read.csv()_, _read.csv2()_
* Both _read.table()_ and _read.fwf()_ use scan to read the file, and then process the results of scan. They are very convenient, but sometimes it is better to use scan directly

---

## Example data


```r
fileUrl <- "http://dashboard.healthit.gov/data/data/NAMCS_2008-2013.csv"
download.file(fileUrl,destfile="./data/NAMCS.csv",method="curl")
list.files("./data")
```

```
## [1] "NAMCS.csv"
```

```r
Data <- read.table("./data/NAMCS.csv")
```

```
## Error: line 2 did not have 87 elements
```

```r
head(Data,2)
```

```
## Error: object 'Data' not found
```

---

## Example parameters

read.csv sets _sep=","_ and _header=TRUE_ 

```r
cameraData <- read.table("./data/NAMCS.csv",sep=",",header=TRUE)
```
same as

```r
cameraData <- read.csv("./data/NAMCS.csv")
head(cameraData)
```

```
##       Region Period Adoption.of.Basic.EHRs..Overall.Physician.Practices
## 1    Alabama   2013                                                0.48
## 2     Alaska   2013                                                0.50
## 3    Arizona   2013                                                0.51
## 4   Arkansas   2013                                                0.46
## 5 California   2013                                                0.54
## 6   Colorado   2013                                                0.39
##   Adoption.of.Basic.EHRs..Primary.Care.Providers
## 1                                           0.50
## 2                                           0.52
## 3                                           0.63
## 4                                           0.55
## 5                                           0.61
## 6                                           0.44
##   Adoption.of.Basic.EHRs..Rural.Providers
## 1                                    0.54
## 2                                    0.37
## 3                                    0.62
## 4                                    0.38
## 5                                    0.42
## 6                                    0.34
##   Adoption.of.Basic.EHRs..Small.Practices
## 1                                    0.40
## 2                                    0.39
## 3                                    0.44
## 4                                    0.45
## 5                                    0.43
## 6                                    0.32
##   Percent.of.office.based.physicians.with.computerized.capability.to.view.lab.results
## 1                                                                                0.74
## 2                                                                                0.75
## 3                                                                                0.80
## 4                                                                                0.77
## 5                                                                                0.74
## 6                                                                                0.77
##   Percent.of.office.based.physicians.with.capability.to.send.orders.for.lab.tests.electronically
## 1                                                                                           0.48
## 2                                                                                           0.67
## 3                                                                                           0.51
## 4                                                                                           0.57
## 5                                                                                           0.55
## 6                                                                                           0.58
##   Percent.of.office.based.physicians.with.EHR.EMR.that.can.automatically.graph.a.specific.patent.s.lab.results.over.time
## 1                                                                                                                   0.38
## 2                                                                                                                   0.46
## 3                                                                                                                   0.53
## 4                                                                                                                   0.53
## 5                                                                                                                   0.50
## 6                                                                                                                   0.51
##   Percent.of.office.based.physicians.with.capability.to.exchange.secure.messages.with.patients
## 1                                                                                         0.38
## 2                                                                                         0.44
## 3                                                                                         0.57
## 4                                                                                         0.42
## 5                                                                                         0.58
## 6                                                                                         0.46
##   Percent.of.office.based.physicians.with.capability.to.provide.patients.with.clinical.summaries.for.each.visit
## 1                                                                                                          0.56
## 2                                                                                                          0.73
## 3                                                                                                          0.76
## 4                                                                                                          0.70
## 5                                                                                                          0.69
## 6                                                                                                          0.69
```

---

## Some more important parameters

* _quote_ - you can tell R whether there are any quoted values quote="" means no quotes.
* _na.strings_ - set the character that represents a missing value. 
* _nrows_ - how many rows to read of the file (e.g. nrows=10 reads 10 lines).
* _skip_ - number of lines to skip before starting to read

_People face trouble with reading flat files those have quotation marks ` or " placed in data values, setting quote="" often resolves these_.

---

## read.xlsx(), read.xlsx2() {xlsx package}


```r
library(xlsx)
Data <- read.xlsx("./data/ADME_genes.xlsx",sheetIndex=1,header=TRUE)
```
## Reading specific rows and columns

```r
colIndex <- 2:3
rowIndex <- 1:4
dataSub <- read.xlsx("./data/ADME_genes.xlsx",sheetIndex=1,
                              colIndex=colIndex,rowIndex=rowIndex)
```

---

## Further notes
* The _write.xlsx_ function will write out an Excel file with similar arguments.
* _read.xlsx2_ is much faster than _read.xlsx_ but for reading subsets of rows may be slightly unstable. 
* The XLConnect is a Java-based solution, so it is cross platform and returns satisfactory results. For large data sets it may be very slow.
* xlsReadWrite is very fast: it doesn't support .xlsx files
* gdata package provides a good cross platform solutions. It is available for Windows, Mac or Linux. gdata requires you to install additional Perl libraries. Perl is usually already installed in Linux and Mac, but sometimes require more effort in Windows platforms.
* In general it is advised to store your data in either a database
or in comma separated files (.csv) or tab separated files (.tab/.txt) as they are easier to distribute.
* I found on the [web](http://housesofstones.com/blog/2013/06/20/quickly-read-excel-xlsx-worksheets-into-r-on-any-platform/#.U_YVTLxdduE) a self made function to easily import xlsx files. It should work in all platforms and use XML

```r
source("https://gist.github.com/schaunwheeler/5825002/raw/3526a15b032c06392740e20b6c9a179add2cee49/xlsxToR.r")
xlsxToR = function("myfile.xlsx", header = TRUE)
```

---

## Working with XML 

* Extensible markup language
* Frequently used to store structured data
* Particularly widely used in internet applications
* Extracting XML is the basis for most web scraping
* Components
  * Markup - labels that give the text structure
  * Content - the actual text of the document

[http://en.wikipedia.org/wiki/XML](http://en.wikipedia.org/wiki/XML)

---
## Read the file into R


```r
library(XML)
fileUrl <- "http://www.w3schools.com/xml/simple.xml"
doc <- xmlTreeParse(fileUrl,useInternal=TRUE)
rootNode <- xmlRoot(doc)
xmlName(rootNode)
```

```
## [1] "breakfast_menu"
```

```r
names(rootNode)
```

```
##   food   food   food   food   food 
## "food" "food" "food" "food" "food"
```

---

## Directly access parts of the XML document


```r
rootNode[[1]]
```

```
## <food>
##   <name>Belgian Waffles</name>
##   <price>$5.95</price>
##   <description>Two of our famous Belgian Waffles with plenty of real maple syrup</description>
##   <calories>650</calories>
## </food>
```

```r
rootNode[[1]][[1]]
```

```
## <name>Belgian Waffles</name>
```

* Go for a tour of [XML package](http://www.omegahat.org/RSXML/Tour.pdf)
* Official XML tutorials [short](http://www.omegahat.org/RSXML/shortIntro.pdf), [long](http://www.omegahat.org/RSXML/Tour.pdf)
* [An outstanding guide to the XML package](http://www.stat.berkeley.edu/~statcur/Workshop2/Presentations/XML.pdf)


---

## JSON

* Javascript Object Notation
* Lightweight data storage
* Common format for data from application programming interfaces (APIs)
* Similar structure to XML but different syntax/format
* Data stored as
  * Numbers (double)
  * Strings (double quoted)
  * Boolean (_true_ or _false_)
  * Array (ordered, comma separated enclosed in square brackets _[]_)
  * Object (unorderd, comma separated collection of key:value pairs in curley brackets _{}_)


[http://en.wikipedia.org/wiki/JSON](http://en.wikipedia.org/wiki/JSON)

---

## Example JSON file

<img class=center src=/Users/abhikseal/Data_Handle/images/json.png height=350>


---

## Reading data from JSON {jsonlite package}


```r
library(jsonlite)
# Using chembl api
jsonData <- fromJSON("https://www.ebi.ac.uk/chemblws/compounds/CHEMBL1.json")
names(jsonData)
```

```
## [1] "compound"
```

```r
jsonData$compound$chemblId
```

```
## [1] "CHEMBL1"
```

```r
jsonData$compound$stdInChiKey
```

```
## [1] "GHBOEFUAGSHXPO-XZOTUCIWSA-N"
```

---

## Writing data frames to JSON


```r
myjson <- toJSON(iris, pretty=TRUE)
cat(myjson)
```

```
## [
## 	{
## 		"Sepal.Length" : 5.1,
## 		"Sepal.Width" : 3.5,
## 		"Petal.Length" : 1.4,
## 		"Petal.Width" : 0.2,
## 		"Species" : "setosa"
## 	},
## 	{
## 		"Sepal.Length" : 4.9,
## 		"Sepal.Width" : 3,
## 		"Petal.Length" : 1.4,
## 		"Petal.Width" : 0.2,
## 		"Species" : "setosa"
## 	},
## 	{
## 		"Sepal.Length" : 4.7,
## 		"Sepal.Width" : 3.2,
## 		"Petal.Length" : 1.3,
## 		"Petal.Width" : 0.2,
## 		"Species" : "setosa"
## 	},
## 	{
## 		"Sepal.Length" : 4.6,
## 		"Sepal.Width" : 3.1,
## 		"Petal.Length" : 1.5,
## 		"Petal.Width" : 0.2,
## 		"Species" : "setosa"
## 	},
## 	{
## 		"Sepal.Length" : 5,
## 		"Sepal.Width" : 3.6,
## 		"Petal.Length" : 1.4,
## 		"Petal.Width" : 0.2,
## 		"Species" : "setosa"
## 	},
## 	{
## 		"Sepal.Length" : 5.4,
## 		"Sepal.Width" : 3.9,
## 		"Petal.Length" : 1.7,
## 		"Petal.Width" : 0.4,
## 		"Species" : "setosa"
## 	},
## 	{
## 		"Sepal.Length" : 4.6,
## 		"Sepal.Width" : 3.4,
## 		"Petal.Length" : 1.4,
## 		"Petal.Width" : 0.3,
## 		"Species" : "setosa"
## 	},
## 	{
## 		"Sepal.Length" : 5,
## 		"Sepal.Width" : 3.4,
## 		"Petal.Length" : 1.5,
## 		"Petal.Width" : 0.2,
## 		"Species" : "setosa"
## 	},
## 	{
## 		"Sepal.Length" : 4.4,
## 		"Sepal.Width" : 2.9,
## 		"Petal.Length" : 1.4,
## 		"Petal.Width" : 0.2,
## 		"Species" : "setosa"
## 	},
## 	{
## 		"Sepal.Length" : 4.9,
## 		"Sepal.Width" : 3.1,
## 		"Petal.Length" : 1.5,
## 		"Petal.Width" : 0.1,
## 		"Species" : "setosa"
## 	},
## 	{
## 		"Sepal.Length" : 5.4,
## 		"Sepal.Width" : 3.7,
## 		"Petal.Length" : 1.5,
## 		"Petal.Width" : 0.2,
## 		"Species" : "setosa"
## 	},
## 	{
## 		"Sepal.Length" : 4.8,
## 		"Sepal.Width" : 3.4,
## 		"Petal.Length" : 1.6,
## 		"Petal.Width" : 0.2,
## 		"Species" : "setosa"
## 	},
## 	{
## 		"Sepal.Length" : 4.8,
## 		"Sepal.Width" : 3,
## 		"Petal.Length" : 1.4,
## 		"Petal.Width" : 0.1,
## 		"Species" : "setosa"
## 	},
## 	{
## 		"Sepal.Length" : 4.3,
## 		"Sepal.Width" : 3,
## 		"Petal.Length" : 1.1,
## 		"Petal.Width" : 0.1,
## 		"Species" : "setosa"
## 	},
## 	{
## 		"Sepal.Length" : 5.8,
## 		"Sepal.Width" : 4,
## 		"Petal.Length" : 1.2,
## 		"Petal.Width" : 0.2,
## 		"Species" : "setosa"
## 	},
## 	{
## 		"Sepal.Length" : 5.7,
## 		"Sepal.Width" : 4.4,
## 		"Petal.Length" : 1.5,
## 		"Petal.Width" : 0.4,
## 		"Species" : "setosa"
## 	},
## 	{
## 		"Sepal.Length" : 5.4,
## 		"Sepal.Width" : 3.9,
## 		"Petal.Length" : 1.3,
## 		"Petal.Width" : 0.4,
## 		"Species" : "setosa"
## 	},
## 	{
## 		"Sepal.Length" : 5.1,
## 		"Sepal.Width" : 3.5,
## 		"Petal.Length" : 1.4,
## 		"Petal.Width" : 0.3,
## 		"Species" : "setosa"
## 	},
## 	{
## 		"Sepal.Length" : 5.7,
## 		"Sepal.Width" : 3.8,
## 		"Petal.Length" : 1.7,
## 		"Petal.Width" : 0.3,
## 		"Species" : "setosa"
## 	},
## 	{
## 		"Sepal.Length" : 5.1,
## 		"Sepal.Width" : 3.8,
## 		"Petal.Length" : 1.5,
## 		"Petal.Width" : 0.3,
## 		"Species" : "setosa"
## 	},
## 	{
## 		"Sepal.Length" : 5.4,
## 		"Sepal.Width" : 3.4,
## 		"Petal.Length" : 1.7,
## 		"Petal.Width" : 0.2,
## 		"Species" : "setosa"
## 	},
## 	{
## 		"Sepal.Length" : 5.1,
## 		"Sepal.Width" : 3.7,
## 		"Petal.Length" : 1.5,
## 		"Petal.Width" : 0.4,
## 		"Species" : "setosa"
## 	},
## 	{
## 		"Sepal.Length" : 4.6,
## 		"Sepal.Width" : 3.6,
## 		"Petal.Length" : 1,
## 		"Petal.Width" : 0.2,
## 		"Species" : "setosa"
## 	},
## 	{
## 		"Sepal.Length" : 5.1,
## 		"Sepal.Width" : 3.3,
## 		"Petal.Length" : 1.7,
## 		"Petal.Width" : 0.5,
## 		"Species" : "setosa"
## 	},
## 	{
## 		"Sepal.Length" : 4.8,
## 		"Sepal.Width" : 3.4,
## 		"Petal.Length" : 1.9,
## 		"Petal.Width" : 0.2,
## 		"Species" : "setosa"
## 	},
## 	{
## 		"Sepal.Length" : 5,
## 		"Sepal.Width" : 3,
## 		"Petal.Length" : 1.6,
## 		"Petal.Width" : 0.2,
## 		"Species" : "setosa"
## 	},
## 	{
## 		"Sepal.Length" : 5,
## 		"Sepal.Width" : 3.4,
## 		"Petal.Length" : 1.6,
## 		"Petal.Width" : 0.4,
## 		"Species" : "setosa"
## 	},
## 	{
## 		"Sepal.Length" : 5.2,
## 		"Sepal.Width" : 3.5,
## 		"Petal.Length" : 1.5,
## 		"Petal.Width" : 0.2,
## 		"Species" : "setosa"
## 	},
## 	{
## 		"Sepal.Length" : 5.2,
## 		"Sepal.Width" : 3.4,
## 		"Petal.Length" : 1.4,
## 		"Petal.Width" : 0.2,
## 		"Species" : "setosa"
## 	},
## 	{
## 		"Sepal.Length" : 4.7,
## 		"Sepal.Width" : 3.2,
## 		"Petal.Length" : 1.6,
## 		"Petal.Width" : 0.2,
## 		"Species" : "setosa"
## 	},
## 	{
## 		"Sepal.Length" : 4.8,
## 		"Sepal.Width" : 3.1,
## 		"Petal.Length" : 1.6,
## 		"Petal.Width" : 0.2,
## 		"Species" : "setosa"
## 	},
## 	{
## 		"Sepal.Length" : 5.4,
## 		"Sepal.Width" : 3.4,
## 		"Petal.Length" : 1.5,
## 		"Petal.Width" : 0.4,
## 		"Species" : "setosa"
## 	},
## 	{
## 		"Sepal.Length" : 5.2,
## 		"Sepal.Width" : 4.1,
## 		"Petal.Length" : 1.5,
## 		"Petal.Width" : 0.1,
## 		"Species" : "setosa"
## 	},
## 	{
## 		"Sepal.Length" : 5.5,
## 		"Sepal.Width" : 4.2,
## 		"Petal.Length" : 1.4,
## 		"Petal.Width" : 0.2,
## 		"Species" : "setosa"
## 	},
## 	{
## 		"Sepal.Length" : 4.9,
## 		"Sepal.Width" : 3.1,
## 		"Petal.Length" : 1.5,
## 		"Petal.Width" : 0.2,
## 		"Species" : "setosa"
## 	},
## 	{
## 		"Sepal.Length" : 5,
## 		"Sepal.Width" : 3.2,
## 		"Petal.Length" : 1.2,
## 		"Petal.Width" : 0.2,
## 		"Species" : "setosa"
## 	},
## 	{
## 		"Sepal.Length" : 5.5,
## 		"Sepal.Width" : 3.5,
## 		"Petal.Length" : 1.3,
## 		"Petal.Width" : 0.2,
## 		"Species" : "setosa"
## 	},
## 	{
## 		"Sepal.Length" : 4.9,
## 		"Sepal.Width" : 3.6,
## 		"Petal.Length" : 1.4,
## 		"Petal.Width" : 0.1,
## 		"Species" : "setosa"
## 	},
## 	{
## 		"Sepal.Length" : 4.4,
## 		"Sepal.Width" : 3,
## 		"Petal.Length" : 1.3,
## 		"Petal.Width" : 0.2,
## 		"Species" : "setosa"
## 	},
## 	{
## 		"Sepal.Length" : 5.1,
## 		"Sepal.Width" : 3.4,
## 		"Petal.Length" : 1.5,
## 		"Petal.Width" : 0.2,
## 		"Species" : "setosa"
## 	},
## 	{
## 		"Sepal.Length" : 5,
## 		"Sepal.Width" : 3.5,
## 		"Petal.Length" : 1.3,
## 		"Petal.Width" : 0.3,
## 		"Species" : "setosa"
## 	},
## 	{
## 		"Sepal.Length" : 4.5,
## 		"Sepal.Width" : 2.3,
## 		"Petal.Length" : 1.3,
## 		"Petal.Width" : 0.3,
## 		"Species" : "setosa"
## 	},
## 	{
## 		"Sepal.Length" : 4.4,
## 		"Sepal.Width" : 3.2,
## 		"Petal.Length" : 1.3,
## 		"Petal.Width" : 0.2,
## 		"Species" : "setosa"
## 	},
## 	{
## 		"Sepal.Length" : 5,
## 		"Sepal.Width" : 3.5,
## 		"Petal.Length" : 1.6,
## 		"Petal.Width" : 0.6,
## 		"Species" : "setosa"
## 	},
## 	{
## 		"Sepal.Length" : 5.1,
## 		"Sepal.Width" : 3.8,
## 		"Petal.Length" : 1.9,
## 		"Petal.Width" : 0.4,
## 		"Species" : "setosa"
## 	},
## 	{
## 		"Sepal.Length" : 4.8,
## 		"Sepal.Width" : 3,
## 		"Petal.Length" : 1.4,
## 		"Petal.Width" : 0.3,
## 		"Species" : "setosa"
## 	},
## 	{
## 		"Sepal.Length" : 5.1,
## 		"Sepal.Width" : 3.8,
## 		"Petal.Length" : 1.6,
## 		"Petal.Width" : 0.2,
## 		"Species" : "setosa"
## 	},
## 	{
## 		"Sepal.Length" : 4.6,
## 		"Sepal.Width" : 3.2,
## 		"Petal.Length" : 1.4,
## 		"Petal.Width" : 0.2,
## 		"Species" : "setosa"
## 	},
## 	{
## 		"Sepal.Length" : 5.3,
## 		"Sepal.Width" : 3.7,
## 		"Petal.Length" : 1.5,
## 		"Petal.Width" : 0.2,
## 		"Species" : "setosa"
## 	},
## 	{
## 		"Sepal.Length" : 5,
## 		"Sepal.Width" : 3.3,
## 		"Petal.Length" : 1.4,
## 		"Petal.Width" : 0.2,
## 		"Species" : "setosa"
## 	},
## 	{
## 		"Sepal.Length" : 7,
## 		"Sepal.Width" : 3.2,
## 		"Petal.Length" : 4.7,
## 		"Petal.Width" : 1.4,
## 		"Species" : "versicolor"
## 	},
## 	{
## 		"Sepal.Length" : 6.4,
## 		"Sepal.Width" : 3.2,
## 		"Petal.Length" : 4.5,
## 		"Petal.Width" : 1.5,
## 		"Species" : "versicolor"
## 	},
## 	{
## 		"Sepal.Length" : 6.9,
## 		"Sepal.Width" : 3.1,
## 		"Petal.Length" : 4.9,
## 		"Petal.Width" : 1.5,
## 		"Species" : "versicolor"
## 	},
## 	{
## 		"Sepal.Length" : 5.5,
## 		"Sepal.Width" : 2.3,
## 		"Petal.Length" : 4,
## 		"Petal.Width" : 1.3,
## 		"Species" : "versicolor"
## 	},
## 	{
## 		"Sepal.Length" : 6.5,
## 		"Sepal.Width" : 2.8,
## 		"Petal.Length" : 4.6,
## 		"Petal.Width" : 1.5,
## 		"Species" : "versicolor"
## 	},
## 	{
## 		"Sepal.Length" : 5.7,
## 		"Sepal.Width" : 2.8,
## 		"Petal.Length" : 4.5,
## 		"Petal.Width" : 1.3,
## 		"Species" : "versicolor"
## 	},
## 	{
## 		"Sepal.Length" : 6.3,
## 		"Sepal.Width" : 3.3,
## 		"Petal.Length" : 4.7,
## 		"Petal.Width" : 1.6,
## 		"Species" : "versicolor"
## 	},
## 	{
## 		"Sepal.Length" : 4.9,
## 		"Sepal.Width" : 2.4,
## 		"Petal.Length" : 3.3,
## 		"Petal.Width" : 1,
## 		"Species" : "versicolor"
## 	},
## 	{
## 		"Sepal.Length" : 6.6,
## 		"Sepal.Width" : 2.9,
## 		"Petal.Length" : 4.6,
## 		"Petal.Width" : 1.3,
## 		"Species" : "versicolor"
## 	},
## 	{
## 		"Sepal.Length" : 5.2,
## 		"Sepal.Width" : 2.7,
## 		"Petal.Length" : 3.9,
## 		"Petal.Width" : 1.4,
## 		"Species" : "versicolor"
## 	},
## 	{
## 		"Sepal.Length" : 5,
## 		"Sepal.Width" : 2,
## 		"Petal.Length" : 3.5,
## 		"Petal.Width" : 1,
## 		"Species" : "versicolor"
## 	},
## 	{
## 		"Sepal.Length" : 5.9,
## 		"Sepal.Width" : 3,
## 		"Petal.Length" : 4.2,
## 		"Petal.Width" : 1.5,
## 		"Species" : "versicolor"
## 	},
## 	{
## 		"Sepal.Length" : 6,
## 		"Sepal.Width" : 2.2,
## 		"Petal.Length" : 4,
## 		"Petal.Width" : 1,
## 		"Species" : "versicolor"
## 	},
## 	{
## 		"Sepal.Length" : 6.1,
## 		"Sepal.Width" : 2.9,
## 		"Petal.Length" : 4.7,
## 		"Petal.Width" : 1.4,
## 		"Species" : "versicolor"
## 	},
## 	{
## 		"Sepal.Length" : 5.6,
## 		"Sepal.Width" : 2.9,
## 		"Petal.Length" : 3.6,
## 		"Petal.Width" : 1.3,
## 		"Species" : "versicolor"
## 	},
## 	{
## 		"Sepal.Length" : 6.7,
## 		"Sepal.Width" : 3.1,
## 		"Petal.Length" : 4.4,
## 		"Petal.Width" : 1.4,
## 		"Species" : "versicolor"
## 	},
## 	{
## 		"Sepal.Length" : 5.6,
## 		"Sepal.Width" : 3,
## 		"Petal.Length" : 4.5,
## 		"Petal.Width" : 1.5,
## 		"Species" : "versicolor"
## 	},
## 	{
## 		"Sepal.Length" : 5.8,
## 		"Sepal.Width" : 2.7,
## 		"Petal.Length" : 4.1,
## 		"Petal.Width" : 1,
## 		"Species" : "versicolor"
## 	},
## 	{
## 		"Sepal.Length" : 6.2,
## 		"Sepal.Width" : 2.2,
## 		"Petal.Length" : 4.5,
## 		"Petal.Width" : 1.5,
## 		"Species" : "versicolor"
## 	},
## 	{
## 		"Sepal.Length" : 5.6,
## 		"Sepal.Width" : 2.5,
## 		"Petal.Length" : 3.9,
## 		"Petal.Width" : 1.1,
## 		"Species" : "versicolor"
## 	},
## 	{
## 		"Sepal.Length" : 5.9,
## 		"Sepal.Width" : 3.2,
## 		"Petal.Length" : 4.8,
## 		"Petal.Width" : 1.8,
## 		"Species" : "versicolor"
## 	},
## 	{
## 		"Sepal.Length" : 6.1,
## 		"Sepal.Width" : 2.8,
## 		"Petal.Length" : 4,
## 		"Petal.Width" : 1.3,
## 		"Species" : "versicolor"
## 	},
## 	{
## 		"Sepal.Length" : 6.3,
## 		"Sepal.Width" : 2.5,
## 		"Petal.Length" : 4.9,
## 		"Petal.Width" : 1.5,
## 		"Species" : "versicolor"
## 	},
## 	{
## 		"Sepal.Length" : 6.1,
## 		"Sepal.Width" : 2.8,
## 		"Petal.Length" : 4.7,
## 		"Petal.Width" : 1.2,
## 		"Species" : "versicolor"
## 	},
## 	{
## 		"Sepal.Length" : 6.4,
## 		"Sepal.Width" : 2.9,
## 		"Petal.Length" : 4.3,
## 		"Petal.Width" : 1.3,
## 		"Species" : "versicolor"
## 	},
## 	{
## 		"Sepal.Length" : 6.6,
## 		"Sepal.Width" : 3,
## 		"Petal.Length" : 4.4,
## 		"Petal.Width" : 1.4,
## 		"Species" : "versicolor"
## 	},
## 	{
## 		"Sepal.Length" : 6.8,
## 		"Sepal.Width" : 2.8,
## 		"Petal.Length" : 4.8,
## 		"Petal.Width" : 1.4,
## 		"Species" : "versicolor"
## 	},
## 	{
## 		"Sepal.Length" : 6.7,
## 		"Sepal.Width" : 3,
## 		"Petal.Length" : 5,
## 		"Petal.Width" : 1.7,
## 		"Species" : "versicolor"
## 	},
## 	{
## 		"Sepal.Length" : 6,
## 		"Sepal.Width" : 2.9,
## 		"Petal.Length" : 4.5,
## 		"Petal.Width" : 1.5,
## 		"Species" : "versicolor"
## 	},
## 	{
## 		"Sepal.Length" : 5.7,
## 		"Sepal.Width" : 2.6,
## 		"Petal.Length" : 3.5,
## 		"Petal.Width" : 1,
## 		"Species" : "versicolor"
## 	},
## 	{
## 		"Sepal.Length" : 5.5,
## 		"Sepal.Width" : 2.4,
## 		"Petal.Length" : 3.8,
## 		"Petal.Width" : 1.1,
## 		"Species" : "versicolor"
## 	},
## 	{
## 		"Sepal.Length" : 5.5,
## 		"Sepal.Width" : 2.4,
## 		"Petal.Length" : 3.7,
## 		"Petal.Width" : 1,
## 		"Species" : "versicolor"
## 	},
## 	{
## 		"Sepal.Length" : 5.8,
## 		"Sepal.Width" : 2.7,
## 		"Petal.Length" : 3.9,
## 		"Petal.Width" : 1.2,
## 		"Species" : "versicolor"
## 	},
## 	{
## 		"Sepal.Length" : 6,
## 		"Sepal.Width" : 2.7,
## 		"Petal.Length" : 5.1,
## 		"Petal.Width" : 1.6,
## 		"Species" : "versicolor"
## 	},
## 	{
## 		"Sepal.Length" : 5.4,
## 		"Sepal.Width" : 3,
## 		"Petal.Length" : 4.5,
## 		"Petal.Width" : 1.5,
## 		"Species" : "versicolor"
## 	},
## 	{
## 		"Sepal.Length" : 6,
## 		"Sepal.Width" : 3.4,
## 		"Petal.Length" : 4.5,
## 		"Petal.Width" : 1.6,
## 		"Species" : "versicolor"
## 	},
## 	{
## 		"Sepal.Length" : 6.7,
## 		"Sepal.Width" : 3.1,
## 		"Petal.Length" : 4.7,
## 		"Petal.Width" : 1.5,
## 		"Species" : "versicolor"
## 	},
## 	{
## 		"Sepal.Length" : 6.3,
## 		"Sepal.Width" : 2.3,
## 		"Petal.Length" : 4.4,
## 		"Petal.Width" : 1.3,
## 		"Species" : "versicolor"
## 	},
## 	{
## 		"Sepal.Length" : 5.6,
## 		"Sepal.Width" : 3,
## 		"Petal.Length" : 4.1,
## 		"Petal.Width" : 1.3,
## 		"Species" : "versicolor"
## 	},
## 	{
## 		"Sepal.Length" : 5.5,
## 		"Sepal.Width" : 2.5,
## 		"Petal.Length" : 4,
## 		"Petal.Width" : 1.3,
## 		"Species" : "versicolor"
## 	},
## 	{
## 		"Sepal.Length" : 5.5,
## 		"Sepal.Width" : 2.6,
## 		"Petal.Length" : 4.4,
## 		"Petal.Width" : 1.2,
## 		"Species" : "versicolor"
## 	},
## 	{
## 		"Sepal.Length" : 6.1,
## 		"Sepal.Width" : 3,
## 		"Petal.Length" : 4.6,
## 		"Petal.Width" : 1.4,
## 		"Species" : "versicolor"
## 	},
## 	{
## 		"Sepal.Length" : 5.8,
## 		"Sepal.Width" : 2.6,
## 		"Petal.Length" : 4,
## 		"Petal.Width" : 1.2,
## 		"Species" : "versicolor"
## 	},
## 	{
## 		"Sepal.Length" : 5,
## 		"Sepal.Width" : 2.3,
## 		"Petal.Length" : 3.3,
## 		"Petal.Width" : 1,
## 		"Species" : "versicolor"
## 	},
## 	{
## 		"Sepal.Length" : 5.6,
## 		"Sepal.Width" : 2.7,
## 		"Petal.Length" : 4.2,
## 		"Petal.Width" : 1.3,
## 		"Species" : "versicolor"
## 	},
## 	{
## 		"Sepal.Length" : 5.7,
## 		"Sepal.Width" : 3,
## 		"Petal.Length" : 4.2,
## 		"Petal.Width" : 1.2,
## 		"Species" : "versicolor"
## 	},
## 	{
## 		"Sepal.Length" : 5.7,
## 		"Sepal.Width" : 2.9,
## 		"Petal.Length" : 4.2,
## 		"Petal.Width" : 1.3,
## 		"Species" : "versicolor"
## 	},
## 	{
## 		"Sepal.Length" : 6.2,
## 		"Sepal.Width" : 2.9,
## 		"Petal.Length" : 4.3,
## 		"Petal.Width" : 1.3,
## 		"Species" : "versicolor"
## 	},
## 	{
## 		"Sepal.Length" : 5.1,
## 		"Sepal.Width" : 2.5,
## 		"Petal.Length" : 3,
## 		"Petal.Width" : 1.1,
## 		"Species" : "versicolor"
## 	},
## 	{
## 		"Sepal.Length" : 5.7,
## 		"Sepal.Width" : 2.8,
## 		"Petal.Length" : 4.1,
## 		"Petal.Width" : 1.3,
## 		"Species" : "versicolor"
## 	},
## 	{
## 		"Sepal.Length" : 6.3,
## 		"Sepal.Width" : 3.3,
## 		"Petal.Length" : 6,
## 		"Petal.Width" : 2.5,
## 		"Species" : "virginica"
## 	},
## 	{
## 		"Sepal.Length" : 5.8,
## 		"Sepal.Width" : 2.7,
## 		"Petal.Length" : 5.1,
## 		"Petal.Width" : 1.9,
## 		"Species" : "virginica"
## 	},
## 	{
## 		"Sepal.Length" : 7.1,
## 		"Sepal.Width" : 3,
## 		"Petal.Length" : 5.9,
## 		"Petal.Width" : 2.1,
## 		"Species" : "virginica"
## 	},
## 	{
## 		"Sepal.Length" : 6.3,
## 		"Sepal.Width" : 2.9,
## 		"Petal.Length" : 5.6,
## 		"Petal.Width" : 1.8,
## 		"Species" : "virginica"
## 	},
## 	{
## 		"Sepal.Length" : 6.5,
## 		"Sepal.Width" : 3,
## 		"Petal.Length" : 5.8,
## 		"Petal.Width" : 2.2,
## 		"Species" : "virginica"
## 	},
## 	{
## 		"Sepal.Length" : 7.6,
## 		"Sepal.Width" : 3,
## 		"Petal.Length" : 6.6,
## 		"Petal.Width" : 2.1,
## 		"Species" : "virginica"
## 	},
## 	{
## 		"Sepal.Length" : 4.9,
## 		"Sepal.Width" : 2.5,
## 		"Petal.Length" : 4.5,
## 		"Petal.Width" : 1.7,
## 		"Species" : "virginica"
## 	},
## 	{
## 		"Sepal.Length" : 7.3,
## 		"Sepal.Width" : 2.9,
## 		"Petal.Length" : 6.3,
## 		"Petal.Width" : 1.8,
## 		"Species" : "virginica"
## 	},
## 	{
## 		"Sepal.Length" : 6.7,
## 		"Sepal.Width" : 2.5,
## 		"Petal.Length" : 5.8,
## 		"Petal.Width" : 1.8,
## 		"Species" : "virginica"
## 	},
## 	{
## 		"Sepal.Length" : 7.2,
## 		"Sepal.Width" : 3.6,
## 		"Petal.Length" : 6.1,
## 		"Petal.Width" : 2.5,
## 		"Species" : "virginica"
## 	},
## 	{
## 		"Sepal.Length" : 6.5,
## 		"Sepal.Width" : 3.2,
## 		"Petal.Length" : 5.1,
## 		"Petal.Width" : 2,
## 		"Species" : "virginica"
## 	},
## 	{
## 		"Sepal.Length" : 6.4,
## 		"Sepal.Width" : 2.7,
## 		"Petal.Length" : 5.3,
## 		"Petal.Width" : 1.9,
## 		"Species" : "virginica"
## 	},
## 	{
## 		"Sepal.Length" : 6.8,
## 		"Sepal.Width" : 3,
## 		"Petal.Length" : 5.5,
## 		"Petal.Width" : 2.1,
## 		"Species" : "virginica"
## 	},
## 	{
## 		"Sepal.Length" : 5.7,
## 		"Sepal.Width" : 2.5,
## 		"Petal.Length" : 5,
## 		"Petal.Width" : 2,
## 		"Species" : "virginica"
## 	},
## 	{
## 		"Sepal.Length" : 5.8,
## 		"Sepal.Width" : 2.8,
## 		"Petal.Length" : 5.1,
## 		"Petal.Width" : 2.4,
## 		"Species" : "virginica"
## 	},
## 	{
## 		"Sepal.Length" : 6.4,
## 		"Sepal.Width" : 3.2,
## 		"Petal.Length" : 5.3,
## 		"Petal.Width" : 2.3,
## 		"Species" : "virginica"
## 	},
## 	{
## 		"Sepal.Length" : 6.5,
## 		"Sepal.Width" : 3,
## 		"Petal.Length" : 5.5,
## 		"Petal.Width" : 1.8,
## 		"Species" : "virginica"
## 	},
## 	{
## 		"Sepal.Length" : 7.7,
## 		"Sepal.Width" : 3.8,
## 		"Petal.Length" : 6.7,
## 		"Petal.Width" : 2.2,
## 		"Species" : "virginica"
## 	},
## 	{
## 		"Sepal.Length" : 7.7,
## 		"Sepal.Width" : 2.6,
## 		"Petal.Length" : 6.9,
## 		"Petal.Width" : 2.3,
## 		"Species" : "virginica"
## 	},
## 	{
## 		"Sepal.Length" : 6,
## 		"Sepal.Width" : 2.2,
## 		"Petal.Length" : 5,
## 		"Petal.Width" : 1.5,
## 		"Species" : "virginica"
## 	},
## 	{
## 		"Sepal.Length" : 6.9,
## 		"Sepal.Width" : 3.2,
## 		"Petal.Length" : 5.7,
## 		"Petal.Width" : 2.3,
## 		"Species" : "virginica"
## 	},
## 	{
## 		"Sepal.Length" : 5.6,
## 		"Sepal.Width" : 2.8,
## 		"Petal.Length" : 4.9,
## 		"Petal.Width" : 2,
## 		"Species" : "virginica"
## 	},
## 	{
## 		"Sepal.Length" : 7.7,
## 		"Sepal.Width" : 2.8,
## 		"Petal.Length" : 6.7,
## 		"Petal.Width" : 2,
## 		"Species" : "virginica"
## 	},
## 	{
## 		"Sepal.Length" : 6.3,
## 		"Sepal.Width" : 2.7,
## 		"Petal.Length" : 4.9,
## 		"Petal.Width" : 1.8,
## 		"Species" : "virginica"
## 	},
## 	{
## 		"Sepal.Length" : 6.7,
## 		"Sepal.Width" : 3.3,
## 		"Petal.Length" : 5.7,
## 		"Petal.Width" : 2.1,
## 		"Species" : "virginica"
## 	},
## 	{
## 		"Sepal.Length" : 7.2,
## 		"Sepal.Width" : 3.2,
## 		"Petal.Length" : 6,
## 		"Petal.Width" : 1.8,
## 		"Species" : "virginica"
## 	},
## 	{
## 		"Sepal.Length" : 6.2,
## 		"Sepal.Width" : 2.8,
## 		"Petal.Length" : 4.8,
## 		"Petal.Width" : 1.8,
## 		"Species" : "virginica"
## 	},
## 	{
## 		"Sepal.Length" : 6.1,
## 		"Sepal.Width" : 3,
## 		"Petal.Length" : 4.9,
## 		"Petal.Width" : 1.8,
## 		"Species" : "virginica"
## 	},
## 	{
## 		"Sepal.Length" : 6.4,
## 		"Sepal.Width" : 2.8,
## 		"Petal.Length" : 5.6,
## 		"Petal.Width" : 2.1,
## 		"Species" : "virginica"
## 	},
## 	{
## 		"Sepal.Length" : 7.2,
## 		"Sepal.Width" : 3,
## 		"Petal.Length" : 5.8,
## 		"Petal.Width" : 1.6,
## 		"Species" : "virginica"
## 	},
## 	{
## 		"Sepal.Length" : 7.4,
## 		"Sepal.Width" : 2.8,
## 		"Petal.Length" : 6.1,
## 		"Petal.Width" : 1.9,
## 		"Species" : "virginica"
## 	},
## 	{
## 		"Sepal.Length" : 7.9,
## 		"Sepal.Width" : 3.8,
## 		"Petal.Length" : 6.4,
## 		"Petal.Width" : 2,
## 		"Species" : "virginica"
## 	},
## 	{
## 		"Sepal.Length" : 6.4,
## 		"Sepal.Width" : 2.8,
## 		"Petal.Length" : 5.6,
## 		"Petal.Width" : 2.2,
## 		"Species" : "virginica"
## 	},
## 	{
## 		"Sepal.Length" : 6.3,
## 		"Sepal.Width" : 2.8,
## 		"Petal.Length" : 5.1,
## 		"Petal.Width" : 1.5,
## 		"Species" : "virginica"
## 	},
## 	{
## 		"Sepal.Length" : 6.1,
## 		"Sepal.Width" : 2.6,
## 		"Petal.Length" : 5.6,
## 		"Petal.Width" : 1.4,
## 		"Species" : "virginica"
## 	},
## 	{
## 		"Sepal.Length" : 7.7,
## 		"Sepal.Width" : 3,
## 		"Petal.Length" : 6.1,
## 		"Petal.Width" : 2.3,
## 		"Species" : "virginica"
## 	},
## 	{
## 		"Sepal.Length" : 6.3,
## 		"Sepal.Width" : 3.4,
## 		"Petal.Length" : 5.6,
## 		"Petal.Width" : 2.4,
## 		"Species" : "virginica"
## 	},
## 	{
## 		"Sepal.Length" : 6.4,
## 		"Sepal.Width" : 3.1,
## 		"Petal.Length" : 5.5,
## 		"Petal.Width" : 1.8,
## 		"Species" : "virginica"
## 	},
## 	{
## 		"Sepal.Length" : 6,
## 		"Sepal.Width" : 3,
## 		"Petal.Length" : 4.8,
## 		"Petal.Width" : 1.8,
## 		"Species" : "virginica"
## 	},
## 	{
## 		"Sepal.Length" : 6.9,
## 		"Sepal.Width" : 3.1,
## 		"Petal.Length" : 5.4,
## 		"Petal.Width" : 2.1,
## 		"Species" : "virginica"
## 	},
## 	{
## 		"Sepal.Length" : 6.7,
## 		"Sepal.Width" : 3.1,
## 		"Petal.Length" : 5.6,
## 		"Petal.Width" : 2.4,
## 		"Species" : "virginica"
## 	},
## 	{
## 		"Sepal.Length" : 6.9,
## 		"Sepal.Width" : 3.1,
## 		"Petal.Length" : 5.1,
## 		"Petal.Width" : 2.3,
## 		"Species" : "virginica"
## 	},
## 	{
## 		"Sepal.Length" : 5.8,
## 		"Sepal.Width" : 2.7,
## 		"Petal.Length" : 5.1,
## 		"Petal.Width" : 1.9,
## 		"Species" : "virginica"
## 	},
## 	{
## 		"Sepal.Length" : 6.8,
## 		"Sepal.Width" : 3.2,
## 		"Petal.Length" : 5.9,
## 		"Petal.Width" : 2.3,
## 		"Species" : "virginica"
## 	},
## 	{
## 		"Sepal.Length" : 6.7,
## 		"Sepal.Width" : 3.3,
## 		"Petal.Length" : 5.7,
## 		"Petal.Width" : 2.5,
## 		"Species" : "virginica"
## 	},
## 	{
## 		"Sepal.Length" : 6.7,
## 		"Sepal.Width" : 3,
## 		"Petal.Length" : 5.2,
## 		"Petal.Width" : 2.3,
## 		"Species" : "virginica"
## 	},
## 	{
## 		"Sepal.Length" : 6.3,
## 		"Sepal.Width" : 2.5,
## 		"Petal.Length" : 5,
## 		"Petal.Width" : 1.9,
## 		"Species" : "virginica"
## 	},
## 	{
## 		"Sepal.Length" : 6.5,
## 		"Sepal.Width" : 3,
## 		"Petal.Length" : 5.2,
## 		"Petal.Width" : 2,
## 		"Species" : "virginica"
## 	},
## 	{
## 		"Sepal.Length" : 6.2,
## 		"Sepal.Width" : 3.4,
## 		"Petal.Length" : 5.4,
## 		"Petal.Width" : 2.3,
## 		"Species" : "virginica"
## 	},
## 	{
## 		"Sepal.Length" : 5.9,
## 		"Sepal.Width" : 3,
## 		"Petal.Length" : 5.1,
## 		"Petal.Width" : 1.8,
## 		"Species" : "virginica"
## 	}
## ]
```

[http://www.r-bloggers.com/new-package-jsonlite-a-smarter-json-encoderdecoder/](http://www.r-bloggers.com/new-package-jsonlite-a-smarter-json-encoderdecoder/)

---

## Further resources

* [http://www.json.org/](http://www.json.org/)
* A good tutorial on jsonlite - [http://www.r-bloggers.com/new-package-jsonlite-a-smarter-json-encoderdecoder/](http://www.r-bloggers.com/new-package-jsonlite-a-smarter-json-encoderdecoder/)
* [jsonlite vignette](http://cran.r-project.org/web/packages/jsonlite/vignettes/json-mapping.pdf)

---

## mySQL

* Free and widely used open source database software
* Widely used in internet based applications
* Data are structured in 
  * Databases
  * Tables within databases
  * Fields within tables
* Each row is called a record

[http://en.wikipedia.org/wiki/MySQL](http://en.wikipedia.org/wiki/MySQL)
[http://www.mysql.com/](http://www.mysql.com/)

---

## Step 2 - Install RMySQL Connector

* On a Mac: ```install.packages("RMySQL")```
* On Windows: 
  * Official instructions - [http://biostat.mc.vanderbilt.edu/wiki/Main/RMySQL](http://biostat.mc.vanderbilt.edu/wiki/Main/RMySQL) (may be useful for Mac/UNIX users as well)
  * Potentially useful guide - [http://www.ahschulz.de/2013/07/23/installing-rmysql-under-windows/](http://www.ahschulz.de/2013/07/23/installing-rmysql-under-windows/)  

---

## UCSC MySQL
<img class=center src=/Users/abhikseal/Data_Handle/images/ucsc.png height=375>
[http://genome.ucsc.edu/goldenPath/help/mysql.html](http://genome.ucsc.edu/goldenPath/help/mysql.html)

---


## Connecting and listing databases


```r
library(DBI)
library(RMySQL)

ucscDb <- dbConnect(MySQL(),user="genome", 
                    host="genome-mysql.cse.ucsc.edu")
result <- dbGetQuery(ucscDb,"show databases;"); dbDisconnect(ucscDb);
```

```
## [1] TRUE
```

```r
head(result)
```

```
##             Database
## 1 information_schema
## 2            ailMel1
## 3            allMis1
## 4            anoCar1
## 5            anoCar2
## 6            anoGam1
```


---

## Connecting to hg19 and listing tables


```r
library(RMySQL)
hg19 <- dbConnect(MySQL(),user="genome", db="hg19",
                    host="genome-mysql.cse.ucsc.edu")
allTables <- dbListTables(hg19)
length(allTables)
```

```
## [1] 11006
```

```r
allTables[1:5]
```

```
## [1] "HInv"         "HInvGeneMrna" "acembly"      "acemblyClass"
## [5] "acemblyPep"
```

---

## Get dimensions of a specific table


```r
dbListFields(hg19,"affyU133Plus2")
```

```
##  [1] "bin"         "matches"     "misMatches"  "repMatches"  "nCount"     
##  [6] "qNumInsert"  "qBaseInsert" "tNumInsert"  "tBaseInsert" "strand"     
## [11] "qName"       "qSize"       "qStart"      "qEnd"        "tName"      
## [16] "tSize"       "tStart"      "tEnd"        "blockCount"  "blockSizes" 
## [21] "qStarts"     "tStarts"
```

```r
dbGetQuery(hg19, "select count(*) from affyU133Plus2")
```

```
##   count(*)
## 1    58463
```


---

## Read from the table


```r
affyData <- dbReadTable(hg19, "affyU133Plus2")
head(affyData)
```

```
##   bin matches misMatches repMatches nCount qNumInsert qBaseInsert
## 1 585     530          4          0     23          3          41
## 2 585    3355         17          0    109          9          67
## 3 585    4156         14          0     83         16          18
## 4 585    4667          9          0     68         21          42
## 5 585    5180         14          0    167         10          38
## 6 585     468          5          0     14          0           0
##   tNumInsert tBaseInsert strand        qName qSize qStart qEnd tName
## 1          3         898      -  225995_x_at   637      5  603  chr1
## 2          9       11621      -  225035_x_at  3635      0 3548  chr1
## 3          2          93      -  226340_x_at  4318      3 4274  chr1
## 4          3        5743      - 1557034_s_at  4834     48 4834  chr1
## 5          1          29      -    231811_at  5399      0 5399  chr1
## 6          0           0      -    236841_at   487      0  487  chr1
##       tSize tStart  tEnd blockCount
## 1 249250621  14361 15816          5
## 2 249250621  14381 29483         17
## 3 249250621  14399 18745         18
## 4 249250621  14406 24893         23
## 5 249250621  19688 25078         11
## 6 249250621  27542 28029          1
##                                                                   blockSizes
## 1                                                          93,144,229,70,21,
## 2              73,375,71,165,303,360,198,661,201,1,260,250,74,73,98,155,163,
## 3                 690,10,32,33,376,4,5,15,5,11,7,41,277,859,141,51,443,1253,
## 4 99,352,286,24,49,14,6,5,8,149,14,44,98,12,10,355,837,59,8,1500,133,624,58,
## 5                                       131,26,1300,6,4,11,4,7,358,3359,155,
## 6                                                                       487,
##                                                                                                  qStarts
## 1                                                                                    34,132,278,541,611,
## 2                        87,165,540,647,818,1123,1484,1682,2343,2545,2546,2808,3058,3133,3206,3317,3472,
## 3                   44,735,746,779,813,1190,1195,1201,1217,1223,1235,1243,1285,1564,2423,2565,2617,3062,
## 4 0,99,452,739,764,814,829,836,842,851,1001,1016,1061,1160,1173,1184,1540,2381,2441,2450,3951,4103,4728,
## 5                                                     0,132,159,1460,1467,1472,1484,1489,1497,1856,5244,
## 6                                                                                                     0,
##                                                                                                                                      tStarts
## 1                                                                                                             14361,14454,14599,14968,15795,
## 2                                     14381,14454,14969,15075,15240,15543,15903,16104,16853,17054,17232,17492,17914,17988,18267,24736,29320,
## 3                               14399,15089,15099,15131,15164,15540,15544,15549,15564,15569,15580,15587,15628,15906,16857,16998,17049,17492,
## 4 14406,20227,20579,20865,20889,20938,20952,20958,20963,20971,21120,21134,21178,21276,21288,21298,21653,22492,22551,22559,24059,24211,24835,
## 5                                                                         19688,19819,19845,21145,21151,21155,21166,21170,21177,21535,24923,
## 6                                                                                                                                     27542,
```

---

## Select a specific subset


```r
query <- dbSendQuery(hg19, "select * from affyU133Plus2 where misMatches between 1 and 3")
affyMis <- fetch(query); quantile(affyMis$misMatches)
```

```
##   0%  25%  50%  75% 100% 
##    1    1    2    2    3
```

```r
affyMisSmall <- fetch(query,n=10); dbClearResult(query);
```

```
## [1] TRUE
```

```r
dim(affyMisSmall)
```

```
## [1] 10 22
```

```r
# close connection
dbDisconnect(hg19)
```

```
## [1] TRUE
```

---

## Further resources

* RMySQL vignette [http://cran.r-project.org/web/packages/RMySQL/RMySQL.pdf](http://cran.r-project.org/web/packages/RMySQL/RMySQL.pdf)
* [R data import and export](http://cran.r-project.org/doc/manuals/R-data.pdf)
* [Set up R odbc with postgres](http://hiltmon.com/blog/2013/09/18/setup-odbc-for-r-on-os-x/)
*  A nice blog post summarizing some other commands [http://www.r-bloggers.com/mysql-and-r/](http://www.r-bloggers.com/mysql-and-r/)

---

## HDF5

* Used for storing large data sets
* Supports storing a range of data types
* Heirarchical data format
* _groups_ containing zero or more data sets and metadata
  * Have a _group header_ with group name and list of attributes
  * Have a _group symbol table_ with a list of objects in group
* _datasets_ multidimensional array of data elements with metadata
  * Have a _header_ with name, datatype, dataspace, and storage layout
  * Have a _data array_ with the data

[http://www.hdfgroup.org/](http://www.hdfgroup.org/)

---
## R HDF5 package
The rhdf5 package works really well, although it is not in CRAN. To install it:

```r
source("http://bioconductor.org/biocLite.R")
```

```
## Bioconductor version 2.13 (BiocInstaller 1.12.1), ?biocLite for help
## A newer version of Bioconductor is available after installing a new
##   version of R, ?BiocUpgrade for help
```

```r
biocLite("rhdf5")
```

```
## BioC_mirror: http://bioconductor.org
## Using Bioconductor version 2.13 (BiocInstaller 1.12.1), R version 3.0.3.
## Installing package(s) 'rhdf5'
```

```
## 
## The downloaded binary packages are in
## 	/var/folders/pm/jg6blwt55b71g8jl64wfw8ch0000gn/T//RtmpuYnNzs/downloaded_packages
```

---

## Creating an HDF5 file and group hierarchy

```r
library(rhdf5)
h5createFile("myhdf5.h5")
```

```
## [1] TRUE
```

```r
h5createGroup("myhdf5.h5","foo")
```

```
## [1] TRUE
```

```r
h5createGroup("myhdf5.h5","baa")
```

```
## [1] TRUE
```

```r
h5createGroup("myhdf5.h5","foo/foobaa")
```

```
## [1] TRUE
```

```r
h5ls("myhdf5.h5")
```

```
##   group   name     otype dclass dim
## 0     /    baa H5I_GROUP           
## 1     /    foo H5I_GROUP           
## 2  /foo foobaa H5I_GROUP
```

---
## hdf5 continued 

```r
h5ls("myhdf5.h5")
```

```
##   group   name     otype dclass dim
## 0     /    baa H5I_GROUP           
## 1     /    foo H5I_GROUP           
## 2  /foo foobaa H5I_GROUP
```
Saving multiple objects to an HDF5 file

```r
A = 1:7; B = 1:18; D = seq(0,1,by=0.1)
h5save(A, B, D, file="newfile2.h5")
h5dump("newfile2.h5")
```

```
## $A
## [1] 1 2 3 4 5 6 7
## 
## $B
##  [1]  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18
## 
## $D
##  [1] 0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0
```

---

## Reading from other resources 
foreign package

* Loads data from Minitab, S, SAS, SPSS, Stata,Systat
* Basic functions _read.foo_
  * read.arff (Weka)
  * readline() read from console
  * read.dta (Stata)
  * read.clipboard() 
  * read.mtp (Minitab)
  * read.octave (Octave)
  * read.spss (SPSS)
  * read.xport (SAS)
* See the help page for more details [http://cran.r-project.org/web/packages/foreign/foreign.pdf](http://cran.r-project.org/web/packages/foreign/foreign.pdf)

---

## Reading images

* jpeg - [http://cran.r-project.org/web/packages/jpeg/index.html](http://cran.r-project.org/web/packages/jpeg/index.html)
* readbitmap - [http://cran.r-project.org/web/packages/readbitmap/index.html](http://cran.r-project.org/web/packages/readbitmap/index.html)
* png - [http://cran.r-project.org/web/packages/png/index.html](http://cran.r-project.org/web/packages/png/index.html)
* EBImage (Bioconductor) - [http://www.bioconductor.org/packages/2.13/bioc/html/EBImage.html](http://www.bioconductor.org/packages/2.13/bioc/html/EBImage.html)

---

## Reading GIS data

* rgdal - [http://cran.r-project.org/web/packages/rgdal/index.html](http://cran.r-project.org/web/packages/rgdal/index.html)
* rgeos - [http://cran.r-project.org/web/packages/rgeos/index.html](http://cran.r-project.org/web/packages/rgeos/index.html)
* raster - [http://cran.r-project.org/web/packages/raster/index.html](http://cran.r-project.org/web/packages/raster/index.html)

---

## Reading music data

* tuneR - [http://cran.r-project.org/web/packages/tuneR/](http://cran.r-project.org/web/packages/tuneR/)
* seewave - [http://rug.mnhn.fr/seewave/](http://rug.mnhn.fr/seewave/)

---

## Acknowledgemnt 

* Jeff Leek University of Washington and Coursera [Getting and Cleaning data ](https://class.coursera.org/getdata-006)
* [R For Natural Resources Course](http://science.nature.nps.gov/im/datamgmt/statistics/r/rcourse/index.cfm)
* [R Data import comprehensive guide](http://cran.r-project.org/doc/manuals/r-release/R-data.html)

---
