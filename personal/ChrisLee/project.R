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

glimpse(dat1)

glimpse(dat2)

glimpse(dat3)


dat1Nest <- dat1 %>%
    mutate(
        visits_by_day = map(visits_by_day, ~bracket_to_tibble(.x)),
        ) 
dat1Nest <- dat1Nest %>%
    select(placekey, latitude, longitude, street_address,
        city, region, postal_code,  
        raw_visit_counts:visits_by_day, parent_placekey, placekey)

glimpse(dat1Nest)

plotdat <- dat1Nest %>% st_as_sf(coords = c("longitude", "latitude"), crs = 4326)

select(plotdat, street_address, region, geometry)

ggplot() +
    geom_sf(data = filter(plotdat, region == "GA"))