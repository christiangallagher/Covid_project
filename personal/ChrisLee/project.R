#Test Project Stuff
#Cartograms

library(tidyverse)
library(sf)
library(jsonlite)
library(USAboundaries)
library(leaflet)

httpgd::hgd()
httpgd::hgd_browse()

json_to_tibble <- function(x){
    if(is.na(x))  return(x)
    parse_json(x) %>%
    enframe() %>%
    unnest(value)
}

bracket_to_tibble <- function(x){
    value <- str_replace_all(x, "\\[|\\]", "") %>%
        str_split(",", simplify = TRUE) %>%
        as.numeric()

    name <- seq_len(length(value))

    tibble::tibble(name = name, value = value)
}

dat1 <-  read.csv("Data folder/core_poi-patterns_07_2021.csv")

dat2 <- read.csv("Data folder/core_poi-patterns_08_2021.csv")

dat3 <- read.csv("Data folder/core_poi-patterns_09_2021.csv")

sites <- read.csv("Data folder/Covid_Testing_Sites.csv", fileEncoding = 'UTF-8-BOM')

cases <- read.csv("https://raw.githubusercontent.com/nytimes/covid-19-data/master/rolling-averages/us-counties-2021.csv")

glimpse(cases)

glimpse(sites)

realdat <- rbind(dat1, dat2, dat3)

realdat <- realdat %>% filter(region == "GA")

glimpse(dat1)

glimpse(dat2)

glimpse(dat3)


datNest <- realdat %>%
    mutate(
        visits_by_day = map(visits_by_day, ~bracket_to_tibble(.x)),
        )
datNest <- datNest %>%
    select(placekey, latitude, longitude, street_address,
        city, region, postal_code,
        raw_visit_counts:visits_by_day, parent_placekey, placekey)

glimpse(datNest)

datNest %>%
    select(placekey, location_name, latitude, longitude, city, region, device_type) %>%
    unnest(device_type) %>%
    filter(!is.na(name)) %>%
    pivot_wider(names_from = name, values_from = value)

plotdat <- dat1Nest %>% st_as_sf(coords = c("longitude", "latitude"), crs = 4326)

plotsites <- sites %>% st_as_sf(coords = c("X", "Y"), crs = 4326)

select(plotdat, street_address, region, geometry)

ggplot() +
    geom_sf(data = filter(plotdat, region == "GA"))

#st_within and contains

bounds <- USAboundaries::us_counties(states = "Georgia")

dat_in_county <- datNest %>%
    st_as_sf(coords = c("longitude", "latitude"), crs = 4326)

dat_in_county <- st_join(dat_in_county, bounds, join = st_within)

select(dat_in_county, street_address, region, geometry)

ggplot() +
    geom_sf(data = bounds) +
    geom_sf(data = filter(dat_in_county, region == "GA"))

datNest %>% view(visits_by_day)

dat_in_county %>%
ggplot() +
    geom_sf(aes(fill = (raw_visit_counts))) + 
    scale_fill_continuous(trans = "sqrt") +
    geom_sf(data = bounds) +
    geom_sf(data = filter(dat_in_county, region == "GA"))
    theme_bw()

glimpse(dat_in_county)

