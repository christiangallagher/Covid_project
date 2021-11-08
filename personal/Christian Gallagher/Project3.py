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
    data.filter(["placekey", "latitude", "longitude", "median_dwell"]), 
    geometry=gpd.points_from_xy(
        data.longitude,
        data.latitude))
#%%      
data_ga = data.query("region=='GA'")
data_ga = gpd.GeoDataFrame(
    data_ga.filter(["placekey", "latitude", "longitude", "median_dwell", "region"]),
        geometry=gpd.points_from_xy(data_ga.longitude, data_ga.latitude),
    crs='EPSG:4326')
#%%    
ga = county.query("stusps == 'GA'")
base = ga.plot(color="white", edgecolor="darkgrey")
data_sp.plot(ax=base, color="red", markersize=5)
#%%  
