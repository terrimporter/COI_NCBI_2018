library(tidyverse)
library(gridExtra)
library(grid)
library(scales)

#June 26, 2018 by Teresita M. Porter

#import records from 2003 to 2017 some of which contain lat/lon and country annotations
#df contains spotty lat/lon and country annot
df<-read.csv('AllEukaryota_gg_latlon.csv', header=T)

#add column labels
names(df)<-c("gb","latitude", "longitude","country_alone")

#count number of records per country
#df2 contains one row per country with num records
df2<-as.data.frame(table(df$country_alone))

#add column labels
names(df2)<-c("country_alone","records")

#get lat and lon to draw world country polygons
wm<-map_data("world")
#each group number corresponds to a country

#mege map data with df2 that contains records/country
wm_records <- left_join(wm, df2, by=c("region"="country_alone"))

#set NA to zero
wm_records$records[is.na(wm_records$records)]<-0

#just look at region & records
wm_region_records<-wm_records[,c("region","records")]

#just look at unique region+record
wm_unique<-unique(wm_region_records)

#get quantiles
quantile(wm_unique$records, c(0.05, 0.25, 0.75, 0.95), na.rm=TRUE)
#5% percentile = 0 records, 
#25% percentile = 36 records, 
#75% percentile = 1354 records, 
#95% percentile = 12393 records

#get average
mean(wm_unique$records, na.rm=TRUE)
#average = 3963 records per country

#use quantiles to put country records into bins for discrete color mapping
wm_records$bins <- cut(wm_records$records, 
                        breaks=c(0, 36, 1354, 12393, 400000), 
                        # 1-36, 37-1354, 1355-12393, 12394-400000
                        limits=c(0,400000),
                        labels=c("-25%","Average","+25%","+45%"))
#add a new factor level for countries with no records
levels(wm_records$bins)<-c(levels(wm_records$bins),"No records")
wm_records$bins[is.na(wm_records$bins)]<-"No records"

#########################################################################
#draw map1 with countries colored
mp<-ggplot() +
  theme_void() +
  theme(legend.position = "none") +
  geom_polygon(data=wm_records, aes(x=long, y=lat, group=group, fill=bins), color=NA) +
  coord_equal() +
  scale_fill_manual(values = c('#C44923','#E4A054','#E1DFBD','#5EBEAC','#0C5B61'),
                    limits = c("No records","-25%","Average","+25%", "+45%"),
					          na.value="#C44923") +
  #Tropic of Cancer
  geom_label(aes(x=-180, y=28, label="23º N"), 
           hjust=0, color="black", label.size=NA, size=3) +
  geom_hline(yintercept=23.4369, color="darkgray", linetype="dashed") +
  #Tropic of Capricorn
  geom_label(aes(x=-180, y=-18, label="23º S"), 
             hjust=0, color="black", label.size=NA, size=3) +
  geom_hline(yintercept=-23.4369, color="darkgray", linetype="dashed")
 
# prep for bar chart
#use quantiles to put UNIQUE country records into bins for discrete color mapping
wm_unique$bins <- cut(wm_unique$records, 
                       breaks=c(0, 36, 1354, 12393, 400000), 
                       # 1-36, 37-1354, 1355-12393, 12394-400000
                       limits=c(0,400000),
                       labels=c("-25%","Average","+25%","+45%"))

#add a new factor level for unique countries with no records
levels(wm_unique$bins)<-c(levels(wm_unique$bins),"No records")
wm_unique$bins[is.na(wm_unique$bins)]<-"No records"

#first sort by records (descending)
wm_unique_sorted<-wm_unique[order(wm_unique$records),]

#reindex
wm_unique_sorted$order<-1:nrow(wm_unique_sorted)

######################################################################
# draw bar chart1 with majority of country data, plot everything except top 5%
bar<-ggplot(data=wm_unique_sorted, 
            aes(x=order,
                y=records, 
                fill=bins)) +
  geom_bar(stat="identity") +
  scale_x_continuous(name="Country",limits=c(1,240), labels=NULL) +
  scale_y_continuous(name="Records",
                     breaks=c(0, 5000, 10000, 15000), 
                     labels=c("0","5,000", "10,000", "15,000"),
                     limits=c(0,15000)) +
  theme(plot.margin=margin(0,0,0,2,"cm"),
        axis.ticks.x=element_blank(),
        legend.key.width=unit(0.75,"cm"),
        legend.key.height=unit(0.25,"cm"),
        legend.position=c(0.5,1),
        legend.justification=c(0.5,1),
        legend.margin=margin(t=0,unit='cm'),
        legend.direction="horizontal",
        legend.title=element_text(size=9),
        legend.text=element_text(size=9),
        panel.grid=element_blank(),
        panel.background = element_blank(),
        axis.line.y=element_line(color="black"),
        axis.line.x=element_line(color="black"),
        axis.title.x=element_text(size=9),
        axis.title.y=element_text(size=9)) +
  scale_fill_manual(values = c('#C44923','#E4A054','#E1DFBD','#5EBEAC','#0C5B61'),
                    limits = c("No records","-25%","Average","+25%", "+45%"),
                    labels = NULL,
                    na.value="#C44923") +
  guides(fill = guide_legend(reverse = F, 
                             title="Average records: 3,963\n\U25BC",
                             title.position="top",
                             title.hjust=0.5,
                             label=TRUE,
                             label.hjust=0,
                             label.vjust=1,
                             label.position="bottom")) +
  annotate("text",x=120,y=10500,label="|         |         |         |\n5th   25th   75th   95th\nPercentiles", size=3, hjust=0.5, vjust=0.5)

top5<-tail(wm_unique_sorted, 13)

######################################################################
# draw bar chart2 with just top 5% plotted
bar2<-ggplot(data=top5, 
            aes(x=order,
                y=records, 
                fill=bins)) +
  geom_bar(stat="identity", width=1) +
  scale_x_continuous(name="Country", 
                     breaks=c(240,241,242,243,244,245,246,247,248,249,250,251,252), 
                     labels=c("Italy","Mexico","France","India","Spain","Brazil","Japan","Germany","China","Australia","Costa Rica","USA","Canada")) +
  scale_y_continuous(name="Records", labels=NULL,
                     limits=c(0,500000)) +
  coord_flip() +
  geom_text(aes(label=comma(records)), hjust=-0.15, size=3) +
  theme(plot.margin=margin(0,2,0,0,"cm"),
        axis.ticks.x=element_blank(),
        legend.position="none",
        panel.grid=element_blank(),
        panel.background = element_blank(),
        axis.line.y=element_line(color="black"),
        axis.line.x=element_line(color="black"),
        axis.title.x=element_text(size=9),
        axis.title.y=element_blank()) +
  scale_fill_manual(values = c('#C44923','#E4A054','#E1DFBD','#5EBEAC','#0C5B61'),
                    limits = c("No records","-25%","Average","+25%", "+45%"),
                    na.value="#C44923")

#######################################################################################
#draw map2 with countries outlined but not filled in, plot points where avail only
mp2<-ggplot() +
  geom_polygon(data=wm_records, aes(x=long, y=lat, group=group), color="lightgrey", fill="lightgrey") +
  geom_point(data=df, mapping=aes(x=longitude, y=latitude, shape="."), 
             show.legend=FALSE, color="violetred", size=0.15) +
  theme_void() +
  theme(legend.position = "none",
        legend.title=element_text(size=9),
        legend.key.width=unit(2.5,"cm")) +
  coord_equal() +
  #Tropic of Cancer
  geom_label(aes(x=-180, y=28, label="23º N"), 
             hjust=0, color="black", label.size=NA, size=3) +
  geom_hline(yintercept=23.4369, color="darkgray", linetype="dashed") +
  #Tropic of Capricorn
  geom_label(aes(x=-180, y=-18, label="23º S"), 
             hjust=0, color="black", label.size=NA, size=3) +
  geom_hline(yintercept=-23.4369, color="darkgray", linetype="dashed") 

#File size is ridiculous so print individually and stick them together later after editing

#use cairo_pdf here to render unicode character for filled triangle
cairo_pdf("Fig4.pdf", family="sans")

lay <- rbind(c(1,1),
             c(2,3),
             c(4,4))

grid.arrange(mp, bar, bar2, mp2, layout_matrix=lay)

dev.off()
