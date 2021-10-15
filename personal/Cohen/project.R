pacman::p_load(tidyverse, sf, USAboundaries, leaflet)
#install.packages("USAboundariesData", repos = "http://packages.ropensci.org", type = "source") #nolint

httpgd::hgd()
httpgd::hgd_browse()

july <- read_csv("Data folder/core_poi-patterns_07_2021.csv")
aug <- read_csv("Data folder/core_poi-patterns_08_2021.csv")
sep <- read_csv("Data folder/core_poi-patterns_09_2021.csv")

hi <- aug %>% st_as_sf(coords = c("longitude", "latitude"), crs = 4326)

select(hi, street_address, region, geometry)

ggplot() +
    geom_sf(data = filter(hi, region == "GA"))
