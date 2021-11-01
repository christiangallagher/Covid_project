

# %%
# # installing geopandas
import sys
!{sys.executable} -m pip install geopandas


# conda install [-c channel] [package...]
# conda install -c conda-forge gdal

#%%
# installing pygeos
# import sys
# !{sys.executable} -mpip install pygeos


# %%

!{sys.executable} -m pip install wheel
!{sys.executable} -m pip install pipwin
!{sys.executable} -m pipwin install numpy
!{sys.executable} -m pipwin install pandas
!{sys.executable} -m pipwin install shapely
!{sys.executable} -m pipwin install gdal
!{sys.executable} -m pipwin install fiona
!{sys.executable} -m pipwin install pyproj
!{sys.executable} -m pipwin install six
!{sys.executable} -m pipwin install rtree
!{sys.executable} -m pipwin install geopandas
!{sys.executable} -m pipwin install pyarrow


# %%
import pandas as pd
import numpy as np
import geopandas as gpd


# %%
gpd.read_file()
# %%

census_url  = "https://www2.census.gov/geo/tiger/GENZ2018/shp/cb_2018_us_county_500k.zip"
county_shp = gpd.read_file(census_url)
# county_shp = gpd.read_file("data/cb_2018_us_county_500k.zip")

# %%

county = gpd.read_parquet("Cohen/usa_counties.parquet")
cities = gpd.read_parquet("Cohen/usa_cities.parquet")

# %%
gpd.read_feather("Cohen/usa_counties.feather")
# %%
