# %%
import requests 

your_location = "safegraph_functions.py"

url = "https://gist.githubusercontent.com/hathawayj/ddb41bb308aaf4e95cede353311fb4f5/raw/02184ca131c0b145931a028feba5c38f8c7e4b52/safegraph_functions.py"

response = requests.get(url)

print(response.headers.get('content-type'))

open(your_location, "wb").write(response.content)


# %%

import pandas as pd
import numpy as np
import geopandas as gpd
import folium
from plotnine import *
import safegraph_functions as sgf


# %%

# loading the data
url_loc = "https://github.com/KSUDS/p3_spatial/raw/main/SafeGraph%20-%20Patterns%20and%20Core%20Data%20-%20Chipotle%20-%20July%202021/Core%20Places%20and%20Patterns%20Data/chipotle_core_poi_and_patterns.csv"
dat = pd.read_csv(url_loc)

datl = dat.iloc[:10,:] # make smaller object for file

#%%

# making the columns change for file
list_cols = ['visits_by_day', 'popularity_by_hour']
json_cols = ['open_hours','visitor_home_cbgs', 'visitor_country_of_orgin', 'bucketed_dwell_times', 'related_same_day_brand', 'related_same_month_brand', 'popularity_by_day', 'device_type', 'visitor_home_aggregation', 'visitor_daytime_cbgs']

dat_pbd = sgf.expand_json('popularity_by_day', datl) # dataset with population by day
dat_rsdb = sgf.expand_json('related_same_day_brand', datl) # dataset seperated by the stores which people went to on the same day
dat_vbd = sgf.expand_list("visits_by_day", datl) # dataset of the visits by day, the 0 means the NA
dat_pbh = sgf.expand_list("popularity_by_hour", datl)

# %%
# What are the top three brands that Chipotle customers visit on the same day?
#Create a bar chart of the top 10 to show us.

dat_rsdb = sgf.expand_json('related_same_day_brand', dat) 

dat10 = (dat_rsdb
    .drop(columns = ['placekey']) # removes the placekey column
    .sum() # sums up the name visits of the stores
    .reset_index() #makes the chart
    .rename(columns = {'index':'brand', 0 : 'visits'}) # renames the columns
    .sort_values(by = "visits", ascending = False) # sorts the stores in order
    .assign(brand = lambda x:x.brand.str.replace("related_same_day_brand-", " ")) # removes the part of the variable name
    .head(10) # selects the first 10 rows
    .reset_index(drop=True) #drops the orginal index of the row values
)

# top 3 brands : mcdonalds, walmart, starbucks

(ggplot (dat10, aes(x='brand', y = 'visits'))+ geom_col(color= 'orange', fill = 'orange') + coord_flip())


# %%

#Over the hours in a day which has to most variability across the Chipotle brand? Which has the highest median visit rate?
# Create a boxplot by hour of the day to help answer this question

dat_pbh = sgf.expand_list("popularity_by_hour", dat)

(ggplot(dat_pbh, aes(x= "hour.astype(str).str.zfill(2)", y = "popularity_by_hour")) + geom_boxplot() + scale_y_continuous(limits = [0,100]))

# %%

# https://towardsdatascience.com/cleaning-and-extracting-json-from-pandas-dataframes-f0c15f93cb38
# https://packaging.python.org/tutorials/packaging-projects/
import pandas as pd
import json
import re

def jsonloads(x):
    if pd.isna(x):
        return None
    else:
        return json.loads(x)

#seperating the list
def createlist(x):
    try:
        return x.str.strip('][').str.split(',')
    except:
        return None

#making a series of the numbers
def rangenumbers(x):
    if x.size == 1:
        return 0 # if there is nothing (NA) in the list, then return 0
    else:
        return range(1, x.size + 1) # if there is something more than the list, then print more. (1:25 in R, range (1,25))

#list comprehesion
# my numbers - [i for i in range (1,24)]        

def expand_json(var, dat):

    rowid = dat.placekey

    parsedat = dat[var]
    loadsdat = parsedat.apply(jsonloads)
    df_wide = pd.json_normalize(loadsdat)

    # clean up store names so they work as column names
    col_names = df_wide.columns
    col_names = [re.sub(r'[^\w\s]','', x) for x in col_names] # remove non-alphanumeric characters
    col_names = [str(col).lower().replace(" ", "_") for col in col_names] # replace spaces with dashes
    col_names_long = [var + '-' + col for col in col_names] 
    
    # rename the columns
    df_wide.columns = col_names_long # add variable name to column names

    df_wide = df_wide.assign(placekey = rowid)

    out = df_wide.loc[:, ["placekey"] + col_names_long]

    return out

def expand_list(var, dat):

    dat_expand = (dat
        .assign(lvar = createlist(dat[var]))
        .filter(["placekey", "lvar"])
        .explode("lvar") # like unnest in R, makes the list longer/extended
        .reset_index(drop=True)
        .rename(columns={"lvar":var})
    )

    dat_label = (dat_expand
        .groupby('placekey')
        .transform(lambda x: rangenumbers(x))
        .reset_index(drop=True)
    )
    
    if var.find("hour") !=-1:
        dat_label.columns = ['hour'] # returns -1 if its there, and it is hour
    elif var.find("day") !=-1:
        dat_label.columns = ['day']
    else :
        dat_label.columns = ['sequence']

    out = pd.concat([dat_expand, dat_label], axis=1) # in R cbind # axis = 0 for rbind and axis = 1 for cbind
    # merging without a key is scary unless you know for sure your rows/columns are the same
    out[var] = out[var].astype(float)
    return out

# %%
