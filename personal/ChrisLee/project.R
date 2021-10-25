#Test Project Stuff
#Cartograms

library(tidyverse)
library(sf)
library(jsonlite)
library(USAboundaries)
library(leaflet)
library(tibbletime)

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

sites <- read.csv("Data folder/WalgreensSites.csv")

glimpse(sites)
cases <- read.csv("https://raw.githubusercontent.com/nytimes/covid-19-data/master/rolling-averages/us-counties-2021.csv")

cases <- cases %>% filter(state =="Georgia")

cases <- cases %>% filter(date >= as.Date("2021-07-01"), date <= as.Date("2021-09-30"))

glimpse(cases)
#glimpse(cases)

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

plotdat <- datNest %>% st_as_sf(coords = c("longitude", "latitude"), crs = 4326)

plotsites <- sites %>% st_as_sf(coords = c("X", "Y"), crs = 4326)

select(plotdat, street_address, region, geometry)

ggplot() +
    geom_sf(data = filter(plotdat, region == "GA"))

#st_within and contains

bounds <- USAboundaries::us_counties(states = "Georgia")

glimpse(bounds)
dat_in_county <- datNest %>%
    st_as_sf(coords = c("longitude", "latitude"), crs = 4326)

dat_in_county <- st_join(dat_in_county, bounds, join = st_within)
glimpse(dat_in_county)
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

wal1 <- read.csv("Data folder/PharmacyJuly.csv")
wal2 <- read.csv("Data folder/PharmacyAugust.csv")
wal3 <- read.csv("Data folder/PharmacyJuly.csv")

pharm <- rbind(wal1, wal2, wal3)

pharm <- pharm %>% filter(brands == "Walgreens")


glimpse(pharm)
glimpse(sites)
write.csv(pharm, "personal\\ChrisLee\\pharm.csv", row.names = TRUE)
write.csv(sites, "personal\\ChrisLee\\sites.csv", row.names = TRUE)

cases %>%
ggplot() +
    geom_sf(data = bounds) +
    theme_bw()

ggplot(data = casbounds) +
  geom_sf(data = casbounds)


glimpse(cases)

glimpse(bounds)

rename(cases, name = county)

glimpse(cases)

bounds <- dplyr::rename(bounds, georgia = state_name)

bounds <- bounds[, !duplicated(colnames(bounds))]

colnames(bounds)[6] <- "county"

casbounds <- merge(cases,bounds,by="county")

glimpse(casbounds)

cbg <- casbounds %>% group_by(county)

eh <- cbg %>% summarise(pcc=sum(cases_avg_per_100k))

glimpse(eh)
glimpse(bounds)

countycases <- merge(bounds, eh, by="county")

glimpse(countycases)

ggplot() +
    geom_sf(data = countycases, aes(fill = pcc)) +
    scale_fill_viridis_c(trans = "sqrt", alpha = .4)

glimpse(realdat)

#Do cases correlate with number of testing sites in the county?
#Do cases correlate with number of hospital visits?
#How do we even begin plotting by date?  I guess we don't really do sf, but more just temporal plots
#So many lingering questions

allsites <- read_csv("Data folder/Covid_Testing_Sites.csv")

glimpse(allsites)
