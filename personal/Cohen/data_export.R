# remotes::install_github("ropensci/USAboundaries")
# remotes::install_github("ropensci/USAboundariesData")
#install.packages("sfarrow")


pacman::p_load(tidyverse, USAboundaries, sf, sfarrow)

usa <- USAboundaries::us_boundaries() %>%
    st_transform(4326)

usa_counties <- USAboundaries::us_counties() %>%
    select(-state_name) %>%
    st_transform(4326)

usa_cities <- USAboundaries::us_cities() %>%
    st_transform(4326)

sfarrow::st_write_feather(usa, "personal/Cohen/usa.feather")
sfarrow::st_write_parquet(usa, "personal/Cohen/usa.parquet")

sfarrow::st_write_feather(usa_counties, "personal/Cohen/usa_counties.feather")
sfarrow::st_write_parquet(usa_counties, "personal/Cohen/usa_counties.parquet")

sfarrow::st_write_feather(usa_cities, "personal/Cohen/usa_cities.feather")
sfarrow::st_write_parquet(usa_cities, "personal/Cohen/usa_cities.parquet")
