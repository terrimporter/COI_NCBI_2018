#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Apr 10 14:11:38 2018

@author: Teresita M. Porter
"""

import pandas as pd

# read in concatenated lat_lon_year.txt files
df = pd.read_csv('/path/to/cat.txt', sep='\t')

# add column labels
df.columns = ['species','gb','year','country','latlon','500bp','countryannot','latlonannot']

# just keep relevant columns
df2 = df[['gb','country','latlon']]

# remove duplicates (due to multi part CDS)
df3 = df2.drop_duplicates(subset='gb', keep='first', inplace=False)

# reformat country column contents
df4 = pd.DataFrame(df3.country.str.split(':',1).tolist(), 
                   columns = ['country_alone','country_details'], index=df3.index)

# add split country columns back to df3
df5 = pd.concat([df3,df4], axis=1, join_axes=[df3.index])

# just keep relevant columns
df6 = df5[['gb','country_alone','latlon']]

# change latlon column from numeric to string for splitting in next step
df6['latlon'].astype(str)

# reformat latlon column contents
df7 = df6['latlon'].str.split(' ', expand=True).rename(columns={0:'lat',1:'NS',2:'lon',3:'WE'})

# add split latlon columns back to df6
df8 = pd.concat([df6,df7], axis=1)

# just keep relevant columns
df9 = df8[['gb','country_alone','lat','NS','lon','WE']]

# chnage lat and lon columns from string to float, ignore warnings
df9['lat'] = pd.to_numeric(df9['lat'], errors='force')
df9['lon'] = pd.to_numeric(df9['lon'], errors='force')

# if NS is south, then make lat negative
df9['lat'][df9.NS == 'S'] = -df9['lat']

# if WE is west, then make lon negative
df9['lon'][df9.WE == 'W'] = -df9['lon']

# just keep relevant columns
df10 = df9[['gb','lat','lon','country_alone']]

df10.to_csv('IUCN_gg_latlon.csv', header=True, index=False)


