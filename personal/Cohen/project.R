pacman::p_load(tidyverse, sf, USAboundaries, leaflet)
#install.packages("USAboundariesData", repos = "http://packages.ropensci.org", type = "source") #nolint

httpgd::hgd()
httpgd::hgd_browse()

july <- read_csv("Data folder/core_poi-patterns_07_2021.csv")
aug <- read_csv("Data folder/core_poi-patterns_08_2021.csv")
sep <- read_csv("Data folder/core_poi-patterns_09_2021.csv")

dat_aug <- aug %>% st_as_sf(coords = c("longitude", "latitude"), crs = 4326)

ga <- us_counties(states = "Georgia") %>%
    select(countyfp, countyns, name, aland, awater, state_abbr, geometry)

ga %>%
    mutate(
        states_area = aland + awater,
        sf_area = st_area(geometry)) %>%
    select(name, states_area, aland, sf_area, awater)

ksu <- tibble(latitude = 34.037876, longitude = -84.58102) %>%
    st_as_sf(coords = c("longitude", "latitude"), crs = 3310)


gaw <- ga %>%
    st_transform(3310) %>%
    mutate(
        aland_acres = aland * 0.000247105,
        awater_acres = awater * 0.000247105,
        percent_water = 100 * (awater / aland),
        sf_area = st_area(geometry),
        sf_center = st_centroid(geometry),
        sf_length = st_length(geometry),
        sf_distance = st_distance(sf_center, ksu),
        sf_buffer = st_buffer(sf_center, 24140.2), # 24140.2 is 15 miles
    )

ggplot(data = gaw) +
    geom_sf(aes(geometry = sf_buffer), fill = "white") +
    geom_sf(aes(geometry = sf_center), color = "darkgrey") +
    geom_sf_text(aes(label = name), color = "lightgrey") +
    geom_sf(data = filter(dat, region == "GA"), color = "black") +
    theme_bw()

ggplot(data = gaw) +
    geom_sf(aes(geometry = sf_buffer), fill = NA) +
    geom_sf(aes(geometry = sf_center), color = "darkgrey") +
    geom_sf_text(aes(label = name), color = "lightgrey") +
    geom_sf(data = filter(dat, region == "GA"), color = "black") + 
    theme_bw()

covid_cases <- st_join(dat_aug, ga, join = st_within) %>%
    select(placekey, visits_by_day, city, region, geometry, raw_visitor_counts, location_name, countyfp) # nolint

covid_cases_count <- covid_cases %>%
    as_tibble() %>%
    count(countyfp, location_name) %>%
    filter(!is.na(countyfp)) # drop the NA counts.

gaw <- gaw %>%
    left_join(covid_cases_count, fill = 0)

gaw %>%
ggplot() +
    geom_sf(aes(fill = n)) +
    scale_fill_continuous(trans = "sqrt") +
    geom_sf(data = filter(dat, region == "GA"), color = "white", shape = "x") +
    theme_bw() +
    theme(legend.position = "bottom") +
    labs(fill = "Number of Hospitals")