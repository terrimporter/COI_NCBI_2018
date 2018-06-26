library(ggplot2)
library(reshape2)
library(scales)
library(gridExtra)

#June 26, 2018 by Teresita M. Porter

# read in csv file
df <- read.csv("FS1.csv", header=TRUE)

# create labels for hirozontal bars
labels <- df$TargetTaxaNumRecords

SF1 <- ggplot(data=df, aes(TargetTaxa, reverse=TRUE, fill=TargetTaxa)) +
  geom_bar(aes(weight=TargetTaxaNumRecords)) +
  coord_flip() +
  geom_text(aes(y=TargetTaxaNumRecords, label=comma(TargetTaxaNumRecords, size=10)), hjust="inward") +
  theme_bw() +
  theme(panel.border = element_blank(),
        panel.background = element_blank(),
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        axis.line = element_line(colour = "black"),
        axis.title = element_text(size=11),
        axis.text = element_text(size=11),
        legend.position = "none") +
  scale_y_continuous(label=comma) +
  scale_x_discrete(limits = rev(levels(df$TargetTaxa))) +
  scale_fill_manual(values = c(rep("turquoise", each=15))) +
  scale_color_manual(values = c(rep("turquoise", each=15))) +
  ylab("CO1 GenBank Records") +
  xlab("Freshwater biomonitoring target taxa")

ggsave("SFig1.pdf", device="pdf") 
