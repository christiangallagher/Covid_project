remotes::install_github("ropensci/USAboundaries")
remotes::install_github("ropensci/USAboundariesData")
install.packages("sfarrow")

library(USAboundaries)
library(USAboundariesData)
library(tidyverse)
library(sf)
library(sfarrow)

usa <- USAboundaries::us_boundaries() %>%
    st_transform(4326)

usa_counties <- USAboundaries::us_counties() %>%
    select(-state_name) %>%
    st_transform(4326)

usa_cities <- USAboundaries::us_cities() %>%
    st_transform(4326)

# sfarrow::st_write_feather(usa, "personal/ChrisLee/usa.feather")
# sfarrow::st_write_parquet(usa, "personal/ChrisLee/usa.parquet")

sfarrow::st_write_feather(usa_counties, "personal/ChrisLee/usa_counties.feather")
sfarrow::st_write_parquet(usa_counties, "personal/ChrisLee/usa_counties.parquet")

sfarrow::st_write_feather(usa_cities, "personal/ChrisLee/usa_cities.feather")
sfarrow::st_write_parquet(usa_cities, "personal/ChrisLee/usa_cities.parquet")