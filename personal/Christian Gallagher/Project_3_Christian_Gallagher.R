library(tidyverse)
library(sf)
library(jsonlite)
library(USAboundaries)
library(leaflet)
library(ggspatial)
library(lubridate)


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

path4 <- "/Users/christiangallagher/Documents/STAT 4490/p3_CoheGallLee/Data folder/Covid_Testing_Sites.csv"
testing <- read_csv(path4) %>%
  filter(X > -85.5, Y > 29)

path5 <- "/Users/christiangallagher/Documents/SUB-IP-EST2019-ANNRES-13.csv"
city_pop <- read_csv(path5) 

city_pop2019 <- city_pop %>%
  select("name", "pop2019")


data <- rbind(July21,Sep21,Aug21)
data <- data %>%
  filter(region == "GA") 

data <- data %>%
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

df$date_range_start <- date(df$date_range_start)

df <- merge(df, city_pop2019, by.x = "city", by.y = "name")

tab2 <- df %>%
  group_by(city, date_range_start)

tab2 <- tab2 %>%
  summarize(n = sum(raw_visit_counts, na.rm = TRUE))

tab3 <- merge(tab2, city_pop2019, by.x = "city", by.y = "name")


ggplot() +
  geom_sf(data = ga) +
  geom_sf(data = tab3, color = "cyan",
          aes(size = (n/pop2019)*100)) +
  annotation_scale(location = "tr", width_hint = 0.25) +
  annotation_north_arrow(location = "tr", which_north = "true", 
                         pad_x = unit(0.75, "cm"), pad_y = unit(0.75, "cm"),
                         style = north_arrow_fancy_orienteering) +
  labs(size = "Proportional Visit Count") +
  theme_bw() 


tab <- df%>% #looking at blairsville
  select("city", "raw_visit_counts", "pop2019") %>%
  filter(city == "Blairsville")
#########  

ggplot() +
  geom_sf(data = ga) +
  geom_sf(data = na.omit(tab3), color = alpha("green", 0.4),
          aes(size = (n/pop2019)*100)) +
  facet_grid(cols = vars(date_range_start))+
  labs(size = "Proportional Visit Count") +
  theme_bw() 

