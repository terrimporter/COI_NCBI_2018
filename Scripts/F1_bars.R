library(reshape2)
library(ggplot2)
library(gridExtra)
library(scales)

# June 26, 2018 by Teresita M. Porter

# Read in file
df<-read.csv("F1.csv",header=TRUE)

# Remove 2004_2017 (last row) 
df2<-df[-nrow(df),]

# Deposited
df3<-df2[,1:3]

# Melt so two series can be plotted
df3.long <- melt(df3, id.vars="Year")

#Rename series here
df3.long$variable <- factor(df3.long$variable,
                            levels=c("FullyID", "InsuffID", "UniqueSpecies"),
                            labels=c("Fully Identified", "Insufficiently Identified", "Unique Species"))

# UniqueSpecies
df4<-df2[,c(1,4)]
# add variable so that a legend can be generated
df4$variable<-rep("Unique Species", nrow(df4))
                  
# get the value for violetred with alpha=0.5 --> #D0209080
lightvioletred <- adjustcolor("violetred", alpha.f = 0.5)

# create two bar plots
F1a<-ggplot(df3.long, aes(Year, fill=variable, color=variable)) +
  geom_bar(aes(weight=value), width=0.8, position='dodge') +
  ggtitle("a)\n") +
  theme_bw() +
  theme(panel.border = element_blank(),
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        axis.line = element_line(colour = "black"),
        axis.title = element_text(size=11),
        axis.text = element_text(size=11),
        legend.position="bottom",
        legend.title=element_blank()) +
  xlab("Year") +
  ylab("Records") +
  scale_y_continuous(limits = c(0,600000), label=comma) +
  scale_color_manual(values = c("violetred","violetred")) +
  scale_fill_manual(values = c("violetred", "white"))

F1b<-ggplot(df4, aes(Year)) +
  ggtitle("b)\n") +
  theme_bw() +
  theme(panel.border = element_blank(),
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        axis.line = element_line(colour = "black"),
        axis.title = element_text(size=11),
        axis.text = element_text(size=11),
        legend.position="bottom",
        legend.title=element_blank()) +
  geom_bar(aes(weight=UniqueSpecies, fill=variable), width=0.8) +
  scale_fill_manual(values=lightvioletred) +
  xlab("Year") +
  ylab("Unique Species") +
  scale_y_continuous(label=comma)

pdf("Fig1.pdf")
grid.arrange(F1a,F1b, nrow=2)
dev.off()
