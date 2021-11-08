
# # %%
# import sys
# !{sys.executable} -m pip uninstall geopandas

# # %%
# import sys
# !{sys.executable} -m pip install geopandas

# import sys
# !{sys.executable} -m pip install folium matplotlib mapclassify

# import sys
# !{sys.executable} -m pip install rtree
# %%
import pandas as pd
import numpy as np
import geopandas as gpd

import folium
import rtree

from plotnine import *
from shapely.geometry import Point

# check working directory
# import os
# os.getcwd()

# %%

census_url  = "https://www2.census.gov/geo/tiger/GENZ2018/shp/cb_2018_us_county_500k.zip"
county_shp = gpd.read_file(census_url)
# county_shp = gpd.read_file("data/cb_2018_us_county_500k.zip")

# %%

cobb_url = "https://github.com/johan/world.geo.json/raw/master/countries/USA/GA/Cobb.geo.json"
cobb_gj = gpd.read_file(cobb_url)

# %%
usa = gpd.read_parquet("usa.parquet")
county = gpd.read_parquet("usa_counties.parquet")
cities = gpd.read_parquet("usa_cities.parquet")

# %%

url_loc = "https://github.com/KSUDS/p3_spatial/raw/main/SafeGraph%20-%20Patterns%20and%20Core%20Data%20-%20Chipotle%20-%20July%202021/Core%20Places%20and%20Patterns%20Data/chipotle_core_poi_and_patterns.csv"

dat = pd.read_csv(url_loc)

# dat = pd.read_csv("SafeGraph - Patterns and Core Data - Chipotle - July 2021/Core Places and Patterns Data/chipotle_core_poi_and_patterns.csv")

dat_sp = gpd.GeoDataFrame(
    dat.filter(["placekey", "latitude", "longitude", "median_dwell"]), 
    geometry=gpd.points_from_xy(
        dat.longitude,
        dat.latitude))


#%%

dat_sp_lt100 = dat_sp.query("median_dwell < 100")

# %%

county = gpd.read_parquet("usa_counties.parquet")
c48=county.query('stusps not in ["HI", "AK", "PR"]')

base = c48.plot(color="white", edgecolor="darkgrey")
dat_sp.plot(ax=base, color="orange", markersize=5)

# %%
base_inter = c48.explore(
    style_kwds = {"fill":False, 
        "color":"darkgrey",
        "weight":.4}
)

theplot=dat_sp_lt100.explore(
    m=base_inter,
    column='median_dwell',
    cmap="Set1",
    marker_kwds={"radius":2, "fill":True},
    style_kwds={"fillOpacity":1})

folium.TileLayer('Stamen Toner', control=True).add_to(base_inter)  # use folium to add alternative tiles
folium.LayerControl().add_to(base_inter)  

theplot
theplot.save("map.html")

c48 = c48.assign(
    aland_calc = c48.geometry.to_crs(epsg = 3310).area
)
(ggplot(c48, aes(
    x="aland_calc/aland",
    fill="awater")) + 
geom_histogram())

# %% 

dat_cal = dat.query("region=='CA'")
dat_cal = gpd.GeoDataFrame(
    dat_cal.filter(["placekey", "latitude", "longitude", "median_dwell", "region"]),
        geometry=gpd.points_from_xy(dat_cal.longitude, dat_cal.latitude),
    crs='EPSG:4326')

# %%

ksu_df = pd.DataFrame({"lat":[34.037876],
        "long":[-84.58102]})
ksu = gpd.GeoDataFrame(ksu_df,
    geometry=gpd.points_from_xy(ksu_df.long, ksu_df.lat),
    crs='EPSG:4326')
point = Point(
    ksu.geometry.to_crs(epsg = 3310).x,
    ksu.geometry.to_crs(epsg = 3310).y)

 # %%

 #california wrangled
 #change the meters to degrees and use the CRS specificied to the state of california

cal = county.query("stusps == 'CA'")


calw = (cal
    .assign(
        gp_area = lambda x: x.geometry.to_crs(epsg = 3310).area,
        gp_acres = lambda x: x.gp_area * 0.000247105,
        aland_acres = lambda x: x.aland * 0.000247105,
        percent_water = lambda x: x.awater / x.aland,
        gp_center = lambda x: x.geometry.to_crs(epsg = 3310).centroid,
        gp_length = lambda x: x.geometry.to_crs(epsg = 3310).length,
        gp_distance = lambda x: x.gp_center.distance(point),
        gp_buffer = lambda x: x.geometry.to_crs(epsg = 3310).buffer(24140.2)      
))

# %% 

calw.gp_buffer.plot()
calw.gp_center.plot(color= "black")

# %%

base = calw.plot(color="white", edgecolor="darkgrey")
dat_cal.plot(ax=base, color="orange", markersize=5)

# %%

# Now count stores by county
dat_join_s1 = gpd.sjoin(dat_cal, calw)

dat_join_merge = (dat_join_s1
    .groupby("name")
    .agg(counts = ('percent_water', 'size'))
    .reset_index())

calw_join = (calw
    .merge(dat_join_merge, on="name", how="left")
    .fillna(value={"counts":0}))

# %%

base = calw_join.plot(
    edgecolor="darkgrey",
    column = "counts")
dat_cal.plot(ax=base, color="red", markersize=4)