library(tidyverse)
library(sf)
library(jsonlite)
library(USAboundaries)
library(leaflet)

json_to_tibble <- function(x){
  if(is.na(x))  return(x)
  parse_json(x) %>%
    enframe() %>%
    unnest(value)
}
path1 <- "/Users/christiangallagher/Documents/Data folder/core_poi-patterns_07_2021.csv"
July21 <- read_csv(path1)
path2 <- "/Users/christiangallagher/Documents/Data folder/core_poi-patterns_09_2021.csv"
Sep21 <- read_csv(path2)
path3 <- "/Users/christiangallagher/Documents/Data folder/core_poi-patterns_08_2021.csv"
Aug21 <- read_csv(path3)

data <- rbind(July21,Sep21,Aug21)
data <- data %>%
  filter(region == "GA")

data <- data %>%
  #slice(1:25) %>% # for the example
  mutate(
    open_hours = map(open_hours, ~json_to_tibble(.x)),
    visits_by_day = map(visits_by_day, ~json_to_tibble(.x)),
    visitor_home_cbgs = map(visitor_home_cbgs, ~json_to_tibble(.x)),
    visitor_country_of_origin = map(visitor_country_of_origin, ~json_to_tibble(.x)),
    bucketed_dwell_times= map(bucketed_dwell_times, ~json_to_tibble(.x)),
    related_same_day_brand = map(related_same_day_brand, ~json_to_tibble(.x)),
    related_same_month_brand = map(related_same_month_brand, ~json_to_tibble(.x)),
    popularity_by_hour = map(popularity_by_hour, ~json_to_tibble(.x)),
    popularity_by_day = map(popularity_by_day, ~json_to_tibble(.x)),
    device_type = map(device_type, ~json_to_tibble(.x)),
    visitor_home_aggregation = map(visitor_home_aggregation, ~json_to_tibble(.x)),
    visitor_daytime_cbgs= map(visitor_daytime_cbgs, ~json_to_tibble(.x)),
  ) 

ga <- USAboundaries::us_counties(states = "Georgia") %>%
  select(countyfp, countyns, name, aland, awater, state_abbr, geometry)
df <- data %>%
  st_as_sf(coords = c("longitude", "latitude"), crs = 4326)

ggplot() +
  geom_sf(data = ga) +
  geom_sf(data = df) +
  theme_bw()


df2 <- data %>%
  pull(popularity_by_day) %>%
  group_by(popularity_by_day)




dat_wc <- st_join(data, ga, join = st_within)

days_week_long <- dat_wc %>%
  as_tibble() %>% # notice this line to break the sf object rules.
  rename(name_county = name) %>%
  unnest(popularity_by_day) %>%
  select(placekey, city, region, contains("raw"),
         name, value, geometry, countyfp, name_county)

days_week <-  days_week_long %>%
  pivot_wider(names_from = name, values_from = value)

visits_day_join <- days_week %>%
  group_by(countyfp, name_county) %>%
  summarise(
    count = n(),
    Monday = sum(Monday, na.rm = TRUE) / count,
    Tuesday = sum(Tuesday, na.rm = TRUE) / count,
    Wednesday = sum(Wednesday, na.rm = TRUE) / count,
    Thursday = sum(Thursday, na.rm = TRUE) / count,
    Friday = sum(Friday, na.rm = TRUE) / count,
    Saturday = sum(Saturday, na.rm = TRUE) / count,
    Sunday = sum(Sunday, na.rm = TRUE) / count,
  ) %>%
  ungroup()


ggplot() +
  geom_sf(data = ga) +
  geom_sf(data = df2) +
  theme_bw()

dat%>%
  slice(5:10) %>%
  pull(popularity_by_day)

datNest %>%
  slice(1:5) %>%
  select(placekey, location_name, latitude, longitude, city, region, device_type) %>%
  unnest(device_type) %>%
  pivot_wider(names_from = name, values_from = value)




