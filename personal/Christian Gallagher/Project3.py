#%%
import pandas as pd
import numpy as np
import geopandas as gpd
import folium
import rtree
import pygeos
from shapely.geometry import Point
from plotnine import *
#%%
usa = gpd.read_parquet("/Users/christiangallagher/Documents/STAT 4490/p3_CoheGallLee/personal/Christian Gallagher/data/usa.parquet")
county = gpd.read_parquet("/Users/christiangallagher/Documents/STAT 4490/p3_CoheGallLee/personal/Christian Gallagher/data/usa_counties.parquet")
cities = gpd.read_parquet("/Users/christiangallagher/Documents/STAT 4490/p3_CoheGallLee/personal/Christian Gallagher/data/usa_cities.parquet")
#%%
july = pd.read_csv("/Users/christiangallagher/Documents/STAT 4490/p3_CoheGallLee/Data folder/core_poi-patterns_07_2021.csv")
aug = pd.read_csv("/Users/christiangallagher/Documents/STAT 4490/p3_CoheGallLee/Data folder/core_poi-patterns_08_2021.csv")
sep = pd.read_csv("/Users/christiangallagher/Documents/STAT 4490/p3_CoheGallLee/Data folder/core_poi-patterns_09_2021.csv")
data = pd.concat([july,aug,sep])
data = data.query("region=='GA'")
#%%
data_sp = gpd.GeoDataFrame(
    data.filter(["placekey", "latitude", "longitude", "raw_visit_counts"]), 
    geometry=gpd.points_from_xy(
        data.longitude,
        data.latitude))
#%%      
data_ga = data.query("region=='GA'")
data_ga = gpd.GeoDataFrame(
    data_ga.filter(["placekey", "latitude", "longitude", "raw_vistit_counts", "region"]),
        geometry=gpd.points_from_xy(data_ga.longitude, data_ga.latitude),
    crs='EPSG:4326')
#%%    
ga = county.query("stusps == 'GA'")
base = ga.plot(color="white", edgecolor="darkgrey")
data_sp.plot(ax=base, color="red", markersize=5)
#%%  
ksu_df = pd.DataFrame({"lat":[34.037876],
        "long":[-84.58102]})
ksu = gpd.GeoDataFrame(ksu_df,
    geometry=gpd.points_from_xy(ksu_df.long, ksu_df.lat),
    crs='EPSG:4326')
point = Point(
    ksu.geometry.to_crs(epsg = 3310).x,
    ksu.geometry.to_crs(epsg = 3310).y)

ga = ga.assign(
    aland_calc = ga.geometry.to_crs(epsg = 3310).area
)
ga2 = (ga
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
#%%
ga2.gp_buffer.plot()
ga2.gp_center.plot(color= "black")
base = ga2.plot(color="white", edgecolor="darkgrey")
data_ga.plot(ax=base, color="red", markersize=5)
#%%
data_join = gpd.sjoin(data_ga, ga2)

data_join_merge = (data_join
    .groupby("name")
    .agg(counts = ('percent_water', 'size'))
    .reset_index())

ga_join = (ga2
    .merge(data_join_merge, on="name", how="left")
    .fillna(value={"counts":0}))
#%%
base = ga_join.plot(
    edgecolor="darkgrey",
    column = "counts",
    legend=True)
data_ga.plot(ax=base, color="red", markersize=2)
#%% 
dat_sp_lt100 = data_sp.query("raw_visit_counts > 1")

base_inter = ga_join.explore(
    column = 'counts',
    style_kwds = { 
        "color":"darkgrey",
        "weight":.4}
)

theplot=dat_sp_lt100.explore(
    m=base_inter,
    column='raw_visit_counts',
    legend = False,
    cmap="Set1",
    marker_kwds={"radius":2, "fill":True},
    style_kwds={"fillOpacity":1})

folium.TileLayer('Stamen Toner', control=True).add_to(base_inter)  # use folium to add alternative tiles
folium.LayerControl().add_to(base_inter)  

theplot

theplot.save("map.html")
    
# %%
