#Test Project Stuff
#Cartograms
install.packages('stringdist')

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

sites <- read.csv("Data folder/Testing_Sites_GA.csv")

countypop <- read.csv("Data folder/countyPop.csv")

colnames(countypop)[1] <- "county"

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

bounds <- bounds[, !duplicated(colnames(bounds))]

colnames(bounds)[6] <- "county"

casbounds <- merge(cases,bounds,by="county")

glimpse(bounds)

glimpse(casbounds)

cbg <- casbounds %>% group_by(county)

eh <- cbg %>% summarise(pcc=sum(cases_avg_per_100k))

sitebounds <- merge(bounds, sites, by="county")

sbp <- merge(sitebounds, countypop, by="county")

sbpg <- sbp %>% group_by(county) %>% summarise(sites = n(), pop = pop2021)

finaltry <- merge(sbpg, countypop, by="county") %>% summarise(sitespercap = pop2021/sites, county=county, sites=sites, geometry=geometry)

sitebg <- sitebounds %>% group_by(county) 

ehsites <- sitebg %>% summarise(sites = n())

glimpse(ehsites)


glimpse(eh)

glimpse(bounds)

countycases <- merge(bounds, eh, by="county")


glimpse(countycases)

testplot <- ggplot() +
    geom_sf(data = countycases, aes(fill = pcc)) +
    scale_fill_viridis_c(option = "magma", trans = "sqrt", alpha = .65)

testplot

testsites <- ggplot() +
    geom_sf(data = ehsites, aes(fill= sites)) +
    scale_fill_viridis_c(option = "magma", trans = "sqrt")

testsites

testsitespercap <- ggplot() +
    geom_sf(data = finaltry, aes(fill= sitespercap)) +
    scale_fill_viridis_c(option = "magma", trans = "sqrt")

testsitespercap

testplot %>% ggsave(file = "testplot.png")

glimpse(realdat)

realdat %>% group_by(city)


glimpse(countycases)



#Do cases correlate with number of testing sites in the county?
#Do cases correlate with number of hospital visits?
#How do we even begin plotting by date?  I guess we don't really do sf, but more just temporal plots
#So many lingering questions

testplot

dat2 <- datNest %>%
    st_as_sf(coords = c("longitude", "latitude"), crs = 4326)

states <- us_states() %>%
    filter(!state_name %in% c("Alaska", "Hawaii", "Puerto Rico")) %>%
    st_transform(4326)

dat_space <- dat2 %>%
    select(placekey, street_address, city, stusps = region, raw_visitor_counts) %>%
    filter(!is.na(raw_visitor_counts)) %>%
    group_by(stusps) %>%
    summarise(
        total_visitors = sum(raw_visitor_counts, na.rm = TRUE),
        per_store = mean(raw_visitor_counts, na.rm = TRUE),
        n_stores = n(),
        across(geometry, ~ sf::st_combine(.)),
    ) %>%
    rename(locations = geometry) %>%
    as_tibble()

states <- states %>%
    left_join(dat_space) 

dat_time <- dat2 %>%
    as_tibble() %>%
    select(placekey, street_address, city, region, raw_visitor_counts, visits_by_day) %>%
    filter(!is.na(raw_visitor_counts)) %>%
    unnest(visits_by_day) %>%
    rename(dayMonth = name, dayCount = value) %>%
    group_by(region, dayMonth) %>%
    summarize(
        dayAverage = mean(dayCount),
        dayCount = sum(dayCount),
        stores = length(unique(placekey))) %>%
    mutate(
        stores_label = c(stores[1], rep(NA, length(stores) - 1))
    )

dat_time %>%
    ggplot(aes(x = dayMonth, y = dayAverage)) +
    geom_point() +
    geom_smooth() +
    geom_text(
        aes(label = stores_label),
            x = -Inf, y = Inf,
            hjust = "left", vjust = "top") +
    facet_geo(~region, grid = "us_state_grid2", label = "name")

dat_time %>%
    ggplot(aes(x = dayMonth, y = dayAverage)) +
    geom_point() +
    geom_smooth() +
    geom_text(aes(label = stores_label),
        x = -Inf, y = Inf,
        hjust = "left", vjust = "top") +
    coord_cartesian(ylim = c(5, 25)) +
    facet_geo(~region, grid = "us_state_grid2", label = "name")

glimpse(dat_time)

glimpse(realdat)

glimpse(datNest)