library(ggplot2)
library(reshape2)

#June 26, 2018 by Teresita M. Porter

df <- read.csv("F2.csv", header=TRUE)

#keep just the columns for plotting
df2 <- df[,c(1,7:10)]

# order series and edit x-axis labels
df2$Facet <- factor(df2$Facet,
                    levels=c("AllGenBank","BARCODE","Freshwater","ENspecies"),
                    labels=c("All", "BARCODE", "Freshwater", "Endangered"))

# Melt so that facets can be wrapped
df3 <- melt(df2, id.vars="Facet")

# edit panel labels here
df3$variable <- factor (df3$variable,
                        levels=c("PropFullyIDNumFacet","PropLengthFullyID","PropCountryFullyID","PropLatLonFullyID"),
                        labels=c("Fully identified","500 bp+","Country","Latitude-Longitude"))

# Create bar charts with facet wrap
g <- ggplot(df3,aes(Facet, color=Facet, fill=Facet)) +
  theme(panel.border = element_blank(),
        panel.background = element_blank(),
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        strip.background = element_blank(),
        strip.text = element_text(size=11),
        axis.line = element_line(colour = "black"),
        axis.title = element_text(size=11),
        axis.text = element_text(size=11),
        axis.text.x = element_text(angle=45, hjust=1),
        axis.ticks.x = element_blank(),
        legend.position="none") +
  scale_fill_manual(values=c("violetred","orange","turquoise","red")) +
  scale_color_manual(values=c("violetred","orange","turquoise","red")) +
  geom_bar(aes(weight=value)) +
  facet_wrap(~variable, nrow=1) +
  xlab("Taxa") +
  ylab("Proportion (%)")

g

ggsave("Fig2.pdf", device="pdf")
