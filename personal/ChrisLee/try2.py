# %%
import sys
!{sys.executable} -m pip install wheel pipwin pyarrow folium mapclassify rtree
!{sys.executable} -m pipwin install gdal 
!{sys.executable} -m pipwin install pyproj
!{sys.executable} -m pipwin install fiona
!{sys.executable} -m pipwin install shapely
!{sys.executable} -m pip install geopandas
# %%
import pandas as pd
import numpy as np
import geopandas as gpd
# %%
census_url  = "https://www2.census.gov/geo/tiger/GENZ2018/shp/cb_2018_us_county_500k.zip"
county_shp = gpd.read_file(census_url)
# %%
county = gpd.read_parquet("data/usa_counties.parquet")
cities = gpd.read_parquet("data/usa_cities.parquet")
# %%
