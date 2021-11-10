# %%
import pandas as pd
import numpy as np
import geopandas as gpd

import folium
import rtree

from plotnine import *
from shapely.geometry import Point


# %%
county = gpd.read_parquet("usa_counties.parquet")
cities = gpd.read_parquet("usa_cities.parquet")

# %%
#census_url  = "https://www2.census.gov/geo/tiger/GENZ2018/shp/cb_2018_us_county_500k.zip"
#county = gpd.read_file(census_url)
# %%
url_loc = "https://github.com/KSUDS/p3_spatial/raw/main/SafeGraph%20-%20Patterns%20and%20Core%20Data%20-%20Chipotle%20-%20July%202021/Core%20Places%20and%20Patterns%20Data/chipotle_core_poi_and_patterns.csv"

dat = pd.read_csv(url_loc)
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
cal = county.query("stusps == 'CA'")
# %%
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
calw.gp_center.plot()
calw.gp_buffer.plot()
# %%
base = calw.plot(color="white", edgecolor="darkgrey")
dat_cal.plot(ax=base, color="red", markersize=5)
# %%
# we want to plot filled counties by count.
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
    column = "counts", legend=True)
dat_cal.plot(ax=base, color="red", markersize=2)


# %%
base_inter = calw_join.explore(
    column = 'counts',
    style_kwds = { 
        "color":"darkgrey",
        "weight":.4}
)

base_inter.save("plot.html")
# %%
theplot = dat_cal.explore(
    m=base_inter,
    marker_kwds={"radius":2, "fill":True},
    style_kwds={"fillOpacity":1})

theplot.save("plot.html")
# %%

folium.TileLayer('Stamen Toner', control=True).add_to(base_inter)  # use folium to add alternative tiles
folium.LayerControl().add_to(base_inter)  

theplot
# %%
theplot.save("plot.html")

# %%