require("reshape")
require("ggplot2")
test_data <- data.frame(
  var0 = 100 + c(0, cumsum(runif(49, -20, 20))),
  var1 = 150 + c(0, cumsum(runif(49, -10, 10))),
  date = seq.Date(as.Date("2002-01-01"), by="1 month", length.out=100))
test_data_long <- melt(test_data, id="date")  # convert to long format

ggplot(data=test_data_long,
       aes(x=date, y=value, colour=variable,group)) +
  geom_line()

d<-read.csv("ranks_PHFP4.csv",header=T)
ggplot(data=d,aes(x=Rank,y=score,colour=as.factor(d$Eta),group=as.factor(d$Eta)))+theme_bw()+geom_line()+
geom_point() +ylab("Fraction of Interactions")+theme_bw(base_size = 18)+
ggtitle(expression("Fraction of Interactions v/s Rank plot at various " *eta*"values"))+
scale_color_manual(name="",values=c("blue", "green","red"))+geom_abline(intercept=0.0,slope =0.0058,linetype="dotted")
