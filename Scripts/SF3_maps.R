library(tidyverse)
library(gridExtra)
library(ggpubr)

#June 26, 2018 by Teresita M. Porter

#import records from 2003 to 2017 some of which contain lat/lon and country annotations
#df contains spotty lat/lon and country annot
#Import EukaryotaBarcode here
df<-read.csv('EukaryotaBarcode_gg_latlon.csv', header=T)
names(df)<-c("gb","latitude", "longitude","country_alone")

#Import Freshwater here
df2<-read.csv('freshwater_gg_latlon.csv', header=T)
names(df2)<-c("gb","latitude", "longitude","country_alone")

#Import IUCN endangered here
df3<-read.csv('IUCN_gg_latlon.csv', header=T)
names(df3)<-c("gb","latitude", "longitude","country_alone")

#count number of records per country
#df.1 contains one row per country with num/prop records
df.1<-as.data.frame(table(df$country_alone))
names(df.1)<-c("country_alone","records")

#count number of records per country
#df2.1 contains one row per country with num/prop records
df2.1<-as.data.frame(table(df2$country_alone))
names(df2.1)<-c("country_alone","records")

#count number of records per country
#df3.1 contains one row per country with num/prop records
df3.1<-as.data.frame(table(df3$country_alone))
names(df3.1)<-c("country_alone","records")

#Only need to do this ONCE
#get lat and lon to draw world country polygons
wm<-map_data("world")

#create Eukaryota BARCODE map
#mege map data with df.1 that contains records and records_prop
wm.1 <- left_join(wm, df.1, by=c("region"="country_alone"))

#draw map
mp.1 <- ggplot() +
  ggtitle("a) BARCODE\n") +
  theme_void() +
  theme(legend.position = "right",
        legend.title = element_blank()) +
  #color countries by num records with country annot
  geom_polygon(data=wm.1, aes(x=long, y=lat, group=group, fill=records)) +
  coord_equal() +
  scale_fill_gradient(trans="log", low="black", high="lightgray", na.value="black",
                      breaks=c(1,400,4000,40000,400000),
                      labels=c("1","0.4K","4K","40K","400K"),
                      limits=c(1,400000)) 

#add points for records with lat/lon annot from Eukaryota BARCODE CO1 Records
mp.1 <- mp.1 + 
  geom_point(data=df, mapping=aes(x=longitude, y=latitude, shape="."), 
             show.legend=FALSE, color="orange", size=0.15) 

#outline tropics
mp.1 <- mp.1 +
	#Tropic of Cancer
  	geom_label(aes(x=-180, y=28, label="Cancer"), 
             hjust=0, color="black", label.size=NA, size=3) +
  	geom_hline(yintercept=23.4369, color="darkgray", linetype="dashed") +
  	#Tropic of Capricorn
  	geom_label(aes(x=-180, y=-18, label="Capricorn"), 
             hjust=0, color="black", label.size=NA, size=3) +
  	geom_hline(yintercept=-23.4369, color="darkgray", linetype="dashed")

#create Freshwater map
#mege map data with df2.1 that contains records and records_prop
wm.2 <- left_join(wm, df2.1, by=c("region"="country_alone"))

#draw map
mp.2 <- ggplot() +
  ggtitle("b) Freshwater\n") +
  theme_void() +
  theme(legend.position = "right",
        legend.title = element_blank()) +
  #color countries by num records with country annot
  geom_polygon(data=wm.2, aes(x=long, y=lat, group=group, fill=records)) +
  coord_equal() +
  scale_fill_gradient(trans="log", low="black", high="lightgray", na.value="black",
                      breaks=c(1,400,4000,40000,400000),
                      labels=c("1","0.4K","4K","40K","400K"),
                      limits=c(1,400000)) 

#add points for records with lat/lon annot from Freshwater CO1 Records
mp.2 <- mp.2 + 
  geom_point(data=df2, mapping=aes(x=longitude, y=latitude, shape="."), 
             show.legend=FALSE, color="turquoise", size=0.15) 

#outline tropics
mp.2 <- mp.2 +
	#Tropic of Cancer
  	geom_label(aes(x=-180, y=28, label="Cancer"), 
             hjust=0, color="black", label.size=NA, size=3) +
  	geom_hline(yintercept=23.4369, color="darkgray", linetype="dashed") +
  	#Tropic of Capricorn
  	geom_label(aes(x=-180, y=-18, label="Capricorn"), 
             hjust=0, color="black", label.size=NA, size=3) +
  	geom_hline(yintercept=-23.4369, color="darkgray", linetype="dashed")

#create IUCN map
#mege map data with df3.1 that contains records and records_prop
wm.3 <- left_join(wm, df3.1, by=c("region"="country_alone"))

#draw map
mp.3 <- ggplot() +
  ggtitle("c) Endangered Species\n") +
  theme_void() +
  theme(legend.position = "right",
        legend.title = element_blank()) +
  #color countries by num records with country annot
  geom_polygon(data=wm.3, aes(x=long, y=lat, group=group, fill=records)) +
  coord_equal() +
  scale_fill_gradient(trans="log", low="black", high="lightgray", na.value="black",
                      breaks=c(1,400,4000,40000,400000),
                      labels=c("1","0.4K","4K","40K","400K"),
                      limits=c(1,400000)) 

#add points for records with lat/lon annot from IUCN CO1 Records
mp.3 <- mp.3 + 
  geom_point(data=df3, mapping=aes(x=longitude, y=latitude, shape="."), 
             show.legend=FALSE, color="red", size=0.15) 

#outline tropics
mp.3 <- mp.3 +
	#Tropic of Cancer
  	geom_label(aes(x=-180, y=28, label="Cancer"), 
             hjust=0, color="black", label.size=NA, size=3) +
  	geom_hline(yintercept=23.4369, color="darkgray", linetype="dashed") +
  	#Tropic of Capricorn
  	geom_label(aes(x=-180, y=-18, label="Capricorn"), 
             hjust=0, color="black", label.size=NA, size=3) +
  	geom_hline(yintercept=-23.4369, color="darkgray", linetype="dashed")

#Print all three maps in one figure
pdf("SFig3_maps.pdf")
grid.arrange(mp.1, mp.2, mp.3, ncol=1)
dev.off()
