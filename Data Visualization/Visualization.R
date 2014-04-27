Exploring Data with R Plots
====================================
library(ggplot2)
library(gcookbook) 
 
1. Scatter Plots and line plots 
======================================================================== 
plot(mtcars$wt,mtcars$mpg)
plot(cars$dist~cars$speed, # y~x
     main="Relationship between car distance & speed", #Plot Title
     xlab="Speed (miles per hour)", #X axis title
     ylab="Distance travelled (miles)", #Y axis title
     xlim=c(0,30), #Set x axis limits from 0 to 30 ylim=c(0,140), #Set y axis limits from 0 to  30140  xaxs="i", #Set x axis style as internal 
     yaxs="i", #Set y axis style as internal  
     col="red", #Set the colour of plotting symbol to red 
     pch=19) #Set the plotting symbol to filled dots

# Let's draw vertical error bars with 5% errors on our cars scatterplot using arrows function
 plot(mpg~disp,data=mtcars)
 
 arrows(x0=mtcars$disp,
        y0=mtcars$mpg*0.95,
        x1=mtcars$disp,
        y1=mtcars$mpg*1.05,
        angle=90,
        code=3,
        length=0.04,
        lwd=0.4)
 
 # how to draw histograms in the top and right margins of a bivariate scatter plot
 
 layout(matrix(c(2,0,1,3),2,2,byrow=TRUE), widths=c(3,1), heights=c(1,3), TRUE)
 par(mar=c(5.1,4.1,0.1,0))
 plot(cars$dist~cars$speed, # y~x
      xlab="Speed (miles per hour)", #X axis title
      ylab="Distance travelled (miles)", #Y axis title
      xlim=c(0,30), #Set x axis limits from 0 to 30 ylim=c(0,140), #Set y axis limits from 0 to  30140  xaxs="i", #Set x axis style as internal 
      yaxs="i", #Set y axis style as internal  
      col="red", #Set the colour of plotting symbol to red 
      pch=19) #Set the plotting symbol to filled dots
 
 par(mar=c(0,4.1,3,0))
 hist(cars$speed,ann=FALSE,axes=FALSE,col="black",border="white")
 
 yhist <- hist(cars$dist,plot=FALSE)
 par(mar=c(5.1,0,0.1,1))
 barplot(yhist$density,
         horiz=TRUE,space=0,axes=FALSE,
         col="black",border="white")
 
 
 

# if you see qplot() or ggplot() it means plotting the graphs using ggplot2 library 
# All are equivalent :
qplot(mtcars$wt, mtcars$mpg)

qplot(wt, mpg, data=mtcars)

ggplot(mtcars, aes(x=wt, y=mpg)) + geom_point()

# Multiple lines in a plot
plot(pressure$temperature, pressure$pressure, type="l")
plot(pressure$temperature, pressure$pressure, type="l")
points(pressure$temperature, pressure$pressure)

lines(pressure$temperature, pressure$pressure/2, col="red")
points(pressure$temperature, pressure$pressure/2, col="red")

# All are equivalent :
qplot(temperature, pressure, data=pressure, geom="line")
ggplot(pressure, aes(x=temperature, y=pressure)) + geom_line()

# Lines and points together
qplot(temperature, pressure, data=pressure, geom=c("line", "point"))
ggplot(pressure, aes(x=temperature, y=pressure)) + geom_line() + geom_point()

# From gcookbook I am using heightweight dataset to group data points by 
# variables, The grouping variable must be categorical—in other words, a factor 
# or character vector.
ggplot(heightweight, aes(x=ageYear, y=heightIn, shape=sex, colour=sex)) +
geom_point()
# Other shapes and color can be used by scale_shape_manual() scale_colour_manual()
  
# Change shape of points  
 ggplot(heightweight, aes(x=ageYear, y=heightIn)) + geom_point(shape=3)
 
 # Change point size sex is categorical 
 ggplot(heightweight, aes(x=ageYear, y=heightIn, shape=sex)) +
   geom_point(size=3) + scale_shape_manual(values=c(1, 4))

# Represent a third continuous variable using color or size.

 ggplot(heightweight, aes(x=weightLb, y=heightIn, fill=ageYear)) +
   geom_point(shape=21, size=2.5) +
   scale_fill_gradient(low="black", high="white", breaks=12:17,
                       guide=guide_legend())
 
# Adding Fitted Regression Model Lines 
 
sp <- ggplot(heightweight, aes(x=ageYear, y=heightIn)) 
sp + geom_point() + stat_smooth(method=lm)

# Adding annotations to regression plot
model <- lm(heightIn ~ ageYear, heightweight)
summary(model)
# First generate prediction data
 pred <- predictvals(model, "ageYear", "heightIn")
 sp <- ggplot(heightweight, aes(x=ageYear, y=heightIn)) + geom_point() +
   geom_line(data=pred)
 sp + annotate("text", label="r^2=0.42", x=16.5, y=52,parse=TRUE)
 
# Scatter plot matrix and correlation matrix
# using mtcars dataset and first five variables 
library(corrplot) 
pairs(mtcars[,1:5])
mcor <- cor(mtcars)
corrplot(mcor)

# Correlation matrix with colored squares and black, rotated labels
corrplot(mcor, method="shade", shade.col=NA, tl.col="black", tl.srt=45)

# create a three-dimensional (3D) scatter plot.
library(rgl) 
plot3d(mtcars$wt, mtcars$disp, mtcars$mpg, type="s", size=0.75, lit=FALSE)
 
# add vertical segments to help give a sense of the spatial positions of the points
 
 interleave <- function(v1, v2) as.vector(rbind(v1,v2))
 # Plot the points
 plot3d(mtcars$wt, mtcars$disp, mtcars$mpg,
        xlab="Weight", ylab="Displacement", zlab="MPG",
        size=.75, type="s", lit=FALSE)
 # Add the segments
 segments3d(interleave(mtcars$wt, mtcars$wt),
            interleave(mtcars$disp, mtcars$disp),
            interleave(mtcars$mpg, min(mtcars$mpg)),
            alpha=0.4, col="blue")
 
 
2. Bar graphs and Histograms 
======================================================================== 

barplot(BOD$demand, names.arg=BOD$Time)
barplot(table(mtcars$cyl))
   
qplot(BOD$Time, BOD$demand, geom="bar", stat="identity")
qplot(factor(BOD$Time), BOD$demand, geom="bar", stat="identity")

# cyl is continuous here
qplot(mtcars$cyl)

# Treat cyl as discrete
qplot(factor(mtcars$cyl))

# Bar graph of values. This uses the BOD data frame, with the 
#"Time" column for x values and the "demand" column for y values.
qplot(Time, demand, data=BOD, geom="bar", stat="identity")
# This is equivalent to:
ggplot(BOD, aes(x=Time, y=demand)) + geom_bar(stat="identity")


# Bar graph of counts
qplot(factor(cyl), data=mtcars)
ggplot(mtcars, aes(x=factor(cyl))) + geom_bar(fill="white",color="black")
 
hist(mtcars$mpg)

# Specify approximate number of bins with breaks
hist(mtcars$mpg, breaks=10)
ggplot(mtcars, aes(x=mpg)) + geom_histogram(binwidth=4,fill="white", colour="black")

# Change the x axis origin using origin parameter 
ggplot(mtcars, aes(x=mpg)) + geom_histogram(binwidth=4,fill="white", colour="black",origin=20)

# histograms of multiple groups of data 
library(MASS)
 ggplot(heightweight, aes(x=heightIn)) + geom_histogram(fill="white", colour="black") +
   facet_grid(sex ~ .)
 hw<-heightweight
 
 # Using plyr and revalue() to change the names on sex variable
 library(plyr)
 hw$sex<- revalue(hw$sex,c("f"="Female","m"="Male"))
 
 # Using facetting
 ggplot(hw, aes(x=heightIn)) + geom_histogram(fill="white", colour="black") +
   facet_grid(sex ~ .)
 
 ggplot(hw, aes(x=heightIn, y = ..density.. ,fill=sex)) + geom_histogram(position="identity",alpha=0.4)+theme_bw()+geom_density(alpha=0.3)
 
3. Box plots 
 ======================================================================== 
  # Formula syntax
boxplot(len ~ supp, data = ToothGrowth)

# Put interaction of two variables on x-axis
boxplot(len ~ supp + dose, data = ToothGrowth)

qplot(supp, len, data=ToothGrowth, geom="boxplot")
ggplot(ToothGrowth, aes(x=supp, y=len)) + geom_boxplot()

 # Adding notches
ggplot(ToothGrowth, aes(x=supp, y=len)) + geom_boxplot(notch=TRUE)
 
# Adding mean
 ggplot(ToothGrowth, aes(x=supp, y=len)) + geom_boxplot() + stat_summary(fun.y="mean", geom="point", shape=24, size=4, fill="white")
 

 # Using three separate vectors
qplot(interaction(supp, dose), len, data=ToothGrowth, geom="boxplot")
# This is equivalent to:
ggplot(ToothGrowth, aes(x=interaction(supp, dose), y=len)) + geom_boxplot()

 
# Violin plots are a way of comparing multiple data distributions
# Use the heightweight datasets 
 p <- ggplot(heightweight, aes(x=sex, y=heightIn))
 p + geom_violin(trim=FALSE,adjuts=2)+geom_boxplot(width=.1, fill="Grey", outlier.colour=NA)+theme_bw()+stat_summary(fun.y="mean", geom="point", shape=24, size=4, fill="white")
 
 
4. Plotting curves
======================================================================== 
curve(x^3 - 5*x, from=-4, to=4)

  # Plot a user-defined function
  myfun <- function(xvar) {
    1/(1 + exp(-xvar + 10))
  }
curve(myfun(x), from=0, to=20)
# Add a line:
curve(1-myfun(x), add = TRUE, col = "red")

# This sets the x range from 0 to 20
qplot(c(0,20), fun=myfun, stat="function", geom="line")
# This is equivalent to:
ggplot(data.frame(x=c(0, 20)), aes(x=x)) + stat_function(fun=myfun, geom="line")

 
5. Miscellaneous plots 
======================================================================== 
# Making Density Plot of Two-Dimensional Data   
p <- ggplot(faithful, aes(x=eruptions, y=waiting))
p + geom_point() + stat_density2d()   
p + stat_density2d(aes(colour=..level..))

p + stat_density2d(aes(fill=..density..), geom="raster", contour=FALSE)
 
 # With points, and map density estimate to alpha
p + geom_point() + stat_density2d(aes(alpha=..density..), geom="tile", contour=FALSE)
 
# Pie Chart
 library(RColorBrewer)
 slices <- c(10, 12,4, 16, 8)
 lbls <- c("IN", "AK", "ID", "MA", "MO")
 pie(slices, labels = lbls, main="Pie Chart of Countries",col=brewer.pal(7,"Set1"))
 
 # Pie Chart with Percentages
 slices <- c(10, 12, 4, 16, 8) 
 lbls <- c("IN", "AK", "ID", "MA", "MO")
 pct <- round(slices/sum(slices)*100)
 lbls <- paste(lbls, pct) # add percents to labels 
 lbls <- paste(lbls,"%",sep="") # ad % to labels 
 pie(slices,labels = lbls, col=rainbow(length(lbls)),
     main="Pie Chart of US States")
 
 # 3D Pie chart
 library(plotrix)
 slices <- c(10, 12, 4, 16, 8) 
 lbls <- c("IN", "AK", "ID", "MA", "MO")
 pie3D(slices,labels=lbls,explode=0.1,
       main="Pie Chart of Countries ",col=brewer.pal(7,"Set1")) 
 