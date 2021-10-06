pacman::p_load(tidyverse, sf, jsonlite)

json_to_tibble <- function(x) {
    if (is.na(x))  return(x)
    parse_json(x) %>%
    enframe() %>%
    unnest(value)
}

dat <- read_csv("SafeGraph - Patterns and Core Data - Chipotle - July 2021/Core Places and Patterns Data/chipotle_core_poi_and_patterns.csv") # nolint

dat %>%
    slice(5:10) %>%
    pull(popularity_by_day)

datNest <- dat %>% # nolint
    slice(1:25) %>% # for the example
    mutate(
        visitor_country_of_origin = map(visitor_country_of_origin, ~json_to_tibble(.x)), # nolint
        bucketed_dwell_times = map(bucketed_dwell_times, ~json_to_tibble(.x)),
        related_same_day_brand = map(related_same_day_brand, ~json_to_tibble(.x)), # nolint
        related_same_month_brand = map(related_same_month_brand, ~json_to_tibble(.x)), # nolint
        popularity_by_hour = map(popularity_by_hour, ~json_to_tibble(.x)),
        popularity_by_day = map(popularity_by_day, ~json_to_tibble(.x)),
        device_type = map(device_type, ~json_to_tibble(.x)),
        visitor_home_cbgs = map(visitor_home_cbgs, ~json_to_tibble(.x)),
        visitor_home_aggregation = map(visitor_home_aggregation, ~json_to_tibble(.x)), # nolint
        visitor_daytime_cbgs = map(visitor_daytime_cbgs, ~json_to_tibble(.x))
        )

datNest %>% slice(1:5) %>% select(placekey, location_name, latitude, longitude, city, region, device_type) # nolint

dat %>% slice(1:5) %>% select(placekey, location_name, latitude, longitude, city, region, device_type) # nolint

datNest %>%
    slice(1:5) %>%
    select(placekey, location_name, latitude, longitude, city, region, device_type) %>% # nolint
    unnest(device_type) %>%
    filter(!is.na(name)) %>%
    pivot_wider(names_from = name, values_from = value)

# making every row as a store for the popularity
datNest %>%
    slice(1:5) %>%
    select(placekey, location_name, latitude, longitude, city, region, popularity_by_day) %>% # nolint
    unnest(popularity_by_day) %>%
    filter(!is.na(name)) %>%
    pivot_wider(names_from = name, values_from = value)

#when you do unnest two variables together, it will repeat the rows 
datNest %>%
    slice(1:5) %>%
    select(placekey, location_name, latitude, longitude, city, region, device_type, popularity_by_day) %>% # nolint
    unnest(popularity_by_day) %>%
    filter(!is.na(name)) %>%
    pivot_wider(names_from = name, values_from = value) %>%
    unnest(device_type)

#if we want to do unnesting together, then we should do two different unnests and join them together by key # nolint

dat %>%
    slice(2:3) %>%
    pull(visits_by_day)