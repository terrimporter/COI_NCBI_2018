library(reshape2)
library(ggplot2)
library(gridExtra)
library(scales)

#June 26, 2018 by Teresita M. Porter

# deposited records in 2003/2004 vs 2004/2005-2017
# Read in file
df<-read.csv("FS2.csv",header=TRUE)

# Just keep columns for fig SF2a
df2<-df[,c(1,3)]

#melt to use ggplot and get group
df2.long <- melt(df2, id.vars="Year")

#rename x axis labels here
df2.long$Year <- factor(df2.long$Year,
                   levels=c("2003_2004","2004_2017"),
                   labels=c("2004","2005-2017"))

# Just keep columns for fig SF2b
df3 <- df[,c(1,4)]

#melt to use ggplot and get group
df3.long <- melt(df3, id.vars="Year")

#rename x axis labels here
df3.long$Year <- factor(df3.long$Year,
                        levels=c("2003_2004","2004_2017"),
                        labels=c("2003","2004-2017"))

# Just keep columns for fig SF2c
df4 <- df[,c(1,5)]

#melt to use ggplot and get group
df4.long <- melt(df4, id.vars="Year")

#rename x axis labels here
df4.long$Year <- factor(df4.long$Year,
                        levels=c("2003_2004","2004_2017"),
                        labels=c("2003","2004-2017"))

# Create line plots with one series each
SF2a<-ggplot(df2.long,aes(x=Year,y=value,group=variable)) +
  ggtitle("a) BARCODE\n") +
  theme_bw() +
  theme(panel.border = element_blank(),
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        axis.line = element_line(colour = "black"),
        axis.title = element_text(size=11),
        axis.text = element_text(size=11),
        legend.position="bottom",
        legend.title=element_blank(),
        legend.text=element_text(size=11)) +
  geom_text(aes(label=comma(value)),hjust=0,vjust=1, nudge_x=0.1, nudge_y=0.1, color="black", size=3.5) +
  geom_line(color="orange") +
  geom_point(size=3, color="orange") +
  xlab("Year") +
  ylab("Records (Log10)") +
  scale_y_log10(label=comma)

SF2b<-ggplot(df3.long,aes(x=Year,y=value,group=variable)) +
  ggtitle("b) Freshwater\n") +
  theme_bw() +
  theme(panel.border = element_blank(),
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        axis.line = element_line(colour = "black"),
        axis.title = element_text(size=11),
        axis.text = element_text(size=11),
        legend.position="bottom",
        legend.title=element_blank(),
        legend.text=element_text(size=11)) +
  geom_text(aes(label=comma(value)),hjust=0,vjust=1, nudge_x=0.1, nudge_y=0.1, color="black", size=3.5) +
  geom_line(color="turquoise") +
  geom_point(size=3, color="turquoise") +
  xlab("Year") +
  ylab("Records (Log10)") +
  scale_y_log10(label=comma)

SF2c<-ggplot(df4.long,aes(x=Year,y=value,group=variable)) +
  ggtitle("c) Endangered Species\n") +
  theme_bw() +
  theme(panel.border = element_blank(),
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        axis.line = element_line(colour = "black"),
        axis.title = element_text(size=11),
        axis.text = element_text(size=11),
        legend.position="bottom",
        legend.title=element_blank(),
        legend.text=element_text(size=11)) +
  geom_text(aes(label=comma(value)),hjust=0,vjust=1, nudge_x=0.1, nudge_y=0.1, color="black", size=3.5) +
  geom_line(color="red") +
  geom_point(size=3, color="red") +
  xlab("Year") +
  ylab("Records (Log10)") +
  scale_y_log10(label=comma)

SF2d<-ggplot(df2.long, aes(x = Year, y = value)) + 
  geom_blank() + 
  theme_void()

#define subplot layout
lay <- rbind(c(1,2),
             c(3,4))

pdf("SFig2.pdf")	
grid.arrange(SF2a, SF2b, SF2c, SF2d, layout_matrix=lay)
dev.off()
