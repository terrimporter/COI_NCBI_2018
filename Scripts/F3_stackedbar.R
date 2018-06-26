library(ggplot2)
library(reshape2)
library(scales)
library(gridExtra)

#June 26, 2018 by Teresita M. Porter

# read in csv file
df <- read.csv("F3.csv", header=TRUE)

# keep just the rows for the first plot
df2 <- df[1,1:3]

# melt so ggplot can be used
df2.long <- melt(df2, id.vars="Facet")

# edit panel labels here
df2.long$variable <- factor(df2.long$variable,
                        levels=c("NonFacetNumRecords","FacetNumRecords"),
                        labels=c("Not BARCODE", "BARCODE"))

# keep just the rows for the second plot
df3 <- df[2,1:3]

# melt so ggplot can be used
df3.long <- melt(df3, id.vars="Facet")

# edit panel labels here
df3.long$variable <- factor(df3.long$variable,
                            levels=c("NonFacetNumRecords","FacetNumRecords"),
                            labels=c("Not Freshwater","Freshwater"))

# keep just the rows for the third plot
df4 <- df[3,1:3]

#melt so ggplot can be used
df4.long <- melt(df4, id.vars="Facet")

# edit panel labels here
df4.long$variable <- factor(df4.long$variable,
                             levels=c("NonFacetNumRecords","FacetNumRecords"),
                             labels=c("COI not in NCBI nucleotide database","COI in NCBI nucleotide database"))
df4.long$Facet <- factor(df4.long$Facet,
                             levels=c("ENspecies"),
                             labels=c("Endangered"))

lightorange <- adjustcolor("orange", alpha.f=0.5)

F3a <- ggplot(data=df2.long, aes(Facet, fill=variable, color=variable)) +
  geom_bar(aes(weight=value)) +
  coord_flip() +
  ggtitle("a)\n") +
  theme_bw() +
  theme(panel.border = element_blank(),
        panel.background = element_blank(),
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        axis.line = element_line(colour = "black"),
        axis.title = element_text(size=11),
        axis.text = element_text(size=11),
        axis.ticks.y = element_blank(),
        axis.text.y = element_blank(),
		    axis.title.y = element_blank(),
        legend.position = "top",
        legend.title = element_blank(),
        legend.text = element_text(size=11)) +
  guides(col = guide_legend(reverse=TRUE),
         fill = guide_legend(reverse=TRUE)) +
  scale_y_continuous(label=comma) +
  scale_fill_manual(values=c(lightorange,"orange")) +
  scale_color_manual(values=c(lightorange,"orange")) +
  ylab("CO1 NCBI Nucleotide Records")

lightturquoise <- adjustcolor("turquoise", alpha.f=0.5)

F3b <- ggplot(data=df3.long, aes(Facet, fill=variable, color=variable)) +
  geom_bar(aes(weight=value)) +
  coord_flip() +
  ggtitle("b)\n") +
  theme_bw() +
  theme(panel.border = element_blank(),
        panel.background = element_blank(),
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        axis.line = element_line(colour = "black"),
        axis.title = element_text(size=11),
        axis.text = element_text(size=11),
        axis.ticks.y = element_blank(),
        axis.text.y = element_blank(),
		    axis.title.y = element_blank(),
        legend.position = "top",
        legend.title = element_blank(),
        legend.text = element_text(size=11)) +
  guides(col = guide_legend(reverse=TRUE),
         fill = guide_legend(reverse=TRUE)) +
  scale_y_continuous(label=comma) +
  scale_fill_manual(values=c(lightturquoise,"turquoise")) +
  scale_color_manual(values=c(lightturquoise,"turquoise")) +
  ylab("CO1 NCBI Nucleotide Records")

lightred <- adjustcolor("red", alpha.f=0.5)

F3c <- ggplot(data=df4.long, aes(Facet, fill=variable, color=variable)) +
  geom_bar(aes(weight=value)) +
  coord_flip() +
  ggtitle("c)\n") +
  theme_bw() +
  theme(panel.border = element_blank(),
        panel.background = element_blank(),
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        axis.line = element_line(colour = "black"),
        axis.title = element_text(size=11),
        axis.text = element_text(size=11),
        axis.ticks.y = element_blank(),
        axis.text.y = element_blank(),
		    axis.title.y = element_blank(),
        legend.position = "top",
        legend.title = element_blank(),
        legend.text = element_text(size=11)) +
  guides(col = guide_legend(reverse=TRUE),
         fill = guide_legend(reverse=TRUE)) +
  scale_y_continuous(label=comma) +
  scale_fill_manual(values=c(lightred,"red")) +
  scale_color_manual(values=c(lightred,"red")) +
  ylab("IUCN Endangered Species")

pdf("Fig3.pdf") 
grid.arrange(F3a, F3b, F3c, ncol=1)
dev.off()
