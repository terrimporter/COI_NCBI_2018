library(reshape2)
library(ggplot2)
library(gridExtra)
library(scales)

#August 10, 2018 by Teresita M. Porter

# Export as CSV from Excel, fix line endings in vi %s/ctrl+v ctrl+m/\r/g
# Read in file
df<-read.csv("FS2.csv",header=TRUE)

#subset the data
barcode<-subset(df, DATASET=="BARCODE", select=Year:InsuffID)
freshwater<-subset(df, DATASET=="Freshwater", select=Year:InsuffID)
enspecies<-subset(df, DATASET=="ENspecies", select=Year:InsuffID)

#convert to long form
barcode.long<-melt(barcode, id.vars="Year")
freshwater.long<-melt(freshwater, id.vars="Year")
enspecies.long<-melt(enspecies, id.vars="Year")

#SFig2a BARCODE
SF2a<-ggplot(barcode.long, aes(Year, fill=variable, color=variable)) +
  geom_bar(aes(weight=value),width=0.8, position='dodge') +
  ggtitle("a) BARCODE\n") +
  theme_bw() +
  theme(panel.border = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.line = element_line(colour="black"),
        axis.title = element_text(size=11),
        axis.text = element_text(size=11),
        legend.position = "bottom",
        legend.title = element_blank()) +
  xlab("Year") +
  ylab("Records") +
  scale_y_continuous(limits = c(0,100000), label=comma) +
  scale_color_manual(values = c("orange","orange")) +
  scale_fill_manual(values = c("orange","white"))

#SFig2b Freshwater
SF2b<-ggplot(freshwater.long, aes(Year, fill=variable, color=variable)) +
  geom_bar(aes(weight=value),width=0.8, position='dodge') +
  ggtitle("b) Freshwater\n") +
  theme_bw() +
  theme(panel.border = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.line = element_line(colour="black"),
        axis.title = element_text(size=11),
        axis.text = element_text(size=11),
        legend.position = "bottom",
        legend.title = element_blank()) +
  xlab("Year") +
  ylab("Records") +
  scale_y_continuous(limits = c(0,410000), label=comma) +
  scale_color_manual(values = c("turquoise","turquoise")) +
  scale_fill_manual(values = c("turquoise","white"))

#SFig2c IUCN endangered species
SF2c<-ggplot(enspecies.long, aes(Year, fill=variable, color=variable)) +
  geom_bar(aes(weight=value),width=0.8, position='dodge') +
  ggtitle("c) Endangered species\n") +
  theme_bw() +
  theme(panel.border = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.line = element_line(colour="black"),
        axis.title = element_text(size=11),
        axis.text = element_text(size=11),
        legend.position = "bottom",
        legend.title = element_blank()) +
  xlab("Year") +
  ylab("Records") +
  scale_y_continuous(limits = c(0,3000), label=comma) +
  scale_color_manual(values = c("red","red")) +
  scale_fill_manual(values = c("red","white"))

pdf("SFig2.pdf")	
grid.arrange(SF2a, SF2b, SF2c, ncol=1)
dev.off()
