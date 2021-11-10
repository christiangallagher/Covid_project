import requests 

your_location = "safegraph_functions.py"

url = "https://gist.githubusercontent.com/hathawayj/ddb41bb308aaf4e95cede353311fb4f5/raw/017a2512a4da5f0c25c69465327e938f43f41b9a/safegraph_functions.py"

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
url_loc = "https://github.com/KSUDS/p3_spatial/raw/main/SafeGraph%20-%20Patterns%20and%20Core%20Data%20-%20Chipotle%20-%20July%202021/Core%20Places%20and%20Patterns%20Data/chipotle_core_poi_and_patterns.csv"
dat = pd.read_csv(url_loc)

datl = dat.iloc[:10,:]
# %%
list_cols = ['visits_by_day', 'popularity_by_hour']
json_cols = ['open_hours','visitor_home_cbgs', 'visitor_country_of_orgin', 'bucketed_dwell_times', 'related_same_day_brand', 'related_same_month_brand', 'popularity_by_day', 'device_type', 'visitor_home_aggregation', 'visitor_daytime_cbgs']

dat_pbd = sgf.expand_json('popularity_by_day', datl)
dat_rsdb = sgf.expand_json('related_same_day_brand', datl)
dat_vbd = sgf.expand_list("visits_by_day", datl)
dat_pbh = sgf.expand_list("popularity_by_hour", datl)
# %%
dat_rsdb.info
# %%
dat_rsdb = sgf.expand_json('related_same_day_brand', dat)
# %%
(dat_rsdb.drop(columns = ["placekey"])
    .sum()
    .reset_index()
    .rename(columns = {"index":"brand", 0:"visits"})
    .sort_values(by = "visits", ascending = False)
    .assign(brand = lambda x: x.brand.str.replace
    ("related_same_day_brand-", ""))
    .head(20)
    .reset_index(drop=True)
    .plot.bar(x="brand", y="visits")
)
# %%
# he might make us do that, this plot but ordered correctly
dat20 = (dat_rsdb.drop(columns = ["placekey"])
    .sum()
    .reset_index()
    .rename(columns = {"index":"brand", 0:"visits"})
    .sort_values(by = "visits", ascending = False)
    .assign(brand = lambda x: x.brand.str.replace
    ("related_same_day_brand-", ""))
    .head(20)
    .reset_index(drop=True)
)
# %%
