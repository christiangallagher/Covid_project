library(tidyverse)
library(sf)
library(jsonlite)

#install.packages('sf')

json_to_tibble <- function(x) {
    if(is.na(x))  return(x)
    parse_json(x) %>%
    enframe() %>%
    unnest(value)
}

dat <- read_csv("SafeGraph - Patterns and Core Data - Chipotle - July 2021/Core Places and Patterns Data/chipotle_core_poi_and_patterns.csv")

dat %>%
    slice(5:10) %>%
    pull(popularity_by_day)

datNest <- dat %>%
    slice(1:25) %>% # for the example
    mutate(
        visitor_country_of_origin = map(visitor_country_of_origin, ~json_to_tibble(.x)),
        bucketed_dwell_times = map(bucketed_dwell_times, ~json_to_tibble(.x)),
        related_same_day_brand = map(related_same_day_brand, ~json_to_tibble(.x)),
        related_same_month_brand = map(related_same_month_brand, ~json_to_tibble(.x)),
        popularity_by_hour = map(popularity_by_hour, ~json_to_tibble(.x)),
        popularity_by_day = map(popularity_by_day, ~json_to_tibble(.x)),
        device_type = map(device_type, ~json_to_tibble(.x)),
        visitor_home_cbgs = map(visitor_home_cbgs, ~json_to_tibble(.x)),
        visitor_home_aggregation = map(visitor_home_aggregation, ~json_to_tibble(.x)),
        visitor_daytime_cbgs = map(visitor_daytime_cbgs, ~json_to_tibble(.x))
        )

datNest %>% slice(1:5) %>% 
    select(placekey, location_name, latitude, longitude, city, region, device_type) %>%
    unnest(device_type) %>%
    filter(!is.na(name)) %>%
    pivot_wider(names_from = name, values_from = value)

datNest %>% slice(1:5) %>% 
    select(placekey, location_name, latitude, longitude, city, region, popularity_by_day) %>%
    unnest(popularity_by_day) %>%
    filter(!is.na(name)) %>%
    pivot_wider(names_from = name, values_from = value)

dat <- read_rds("chipotle_nested.rds")

dat <- dat %>%
    st_as_sf(coords = c("longitude", "latitude"), crs = 4326)

select(dat, street_address, region, geometry)

cal <-USAboundaries::us_counties(states = "California")

cal

ggplot() +
    geom_sf(data = cal) +
    geom_sf(data = filter(dat, region == "CA"))

ggplot() +
    geom_sf(data = cal, aes(fill = awater)) +
    geom_sf_text(data = cal, aes(label = name), color = "grey")

cal %>%
    select(-9) %>% # has state_name twice, removing one
    mutate(
        sf_area = st_area(geometry),
        sf_middle = st_centroid(geometry)
    )

chipotle_in_county <- st_join(dat, cal, join = st_within)

chipotle_in_county %>%
    as_tibble() %>%
    count(geoid, name)

ksu <- tibble(latitude = 34.037876, longitude = -84.58102) %>%
    st_as_sf(coords = c("longitude", "latitude"), crs = 4326)

# https://epsg.io/4326 units are degrees
calw <- cal %>%
    st_transform(3310) %>% # search https://spatialreference.org/ref/?search=california&srtext=Search. Units are in meters for buffer.
    filter(name != "San Francisco") %>%
    mutate(
        aland_acres = aland * 0.000247105,
        awater_acres = awater * 0.000247105,
        percent_water = 100 * (awater / aland),
        sf_area = st_area(geometry),
        sf_center = st_centroid(geometry),
        sf_length = st_length(geometry),
        sf_distance = st_distance(sf_center, ksu),
        sf_buffer = st_buffer(sf_center, 24140.2), # 24140.2 is 15 miles
        sf_intersects = st_intersects(., filter(., name == "Los Angeles"), sparse = FALSE)
        )