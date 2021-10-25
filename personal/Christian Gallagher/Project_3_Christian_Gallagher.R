library(tidyverse)
library(sf)
library(jsonlite)
library(USAboundaries)
library(leaflet)
library(ggspatial)


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

path5 <- "/Users/christiangallagher/Documents/county_pop2.csv"
county_pop <- read_csv(path5)%>%
  rename(name = CTYNAME)

path6 <- "/Users/christiangallagher/Documents/SUB-IP-EST2019-ANNRES-13.csv"
city_pop <- read_csv(path6) 

city_pop2019 <- city_pop %>%
  select("name", "pop2019")


county_pop <- county_pop %>%
  select("name", "pop2021")


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

df <- merge(df, city_pop2019, by.x = "city", by.y = "name")

ggplot() +
  geom_sf(data = ga) +
  geom_sf(data = df, color = "cyan",
          aes(size = (raw_visit_counts/pop2019)*100)) +
  annotation_scale(location = "tr", width_hint = 0.25) +
  annotation_north_arrow(location = "tr", which_north = "true", 
                         pad_x = unit(0.75, "cm"), pad_y = unit(0.75, "cm"),
                         style = north_arrow_fancy_orienteering) +
  labs(size = "Proportional Visit Count") +
  theme_bw() 
  
#########  

#ga3 <- merge(df, county_pop , by.x = "city", by.y = "name")

#ga3 <- ga3 %>%
 # group_by(city)

testing_coord <- testing %>%
  st_as_sf(coords = c("X", "Y"), crs = 4326) %>%
  group_by(municipality)%>%
  summarize(n = n())

ga2 <- ga %>%
  st_join(testing_coord) %>%
  replace_na(list(n = 0))

####
ggplot() +
  geom_sf(data = ga) +
  geom_sf(data = ga3, color = "green", aes(size = raw_visit_counts/pop2021)) +
  #geom_sf(data = ga, aes(fill = n)) +
  annotation_scale(location = "tr", width_hint = 0.25) +
  annotation_north_arrow(location = "tr", which_north = "true", 
                         pad_x = unit(0.75, "cm"), pad_y = unit(0.75, "cm"),
                         style = north_arrow_fancy_orienteering) +
  labs(size = "Raw Visit Count") +
  theme_bw() 



ggplot() +
  geom_sf(data = ga) +
  geom_sf(data = df, aes(color = date_range_start)) +
  geom_sf(data = ga, aes(fill = n)) +
  annotation_scale(location = "tr", width_hint = 0.25) +
  annotation_north_arrow(location = "tr", which_north = "true", 
                         pad_x = unit(0.75, "cm"), pad_y = unit(0.75, "cm"),
                         style = north_arrow_fancy_orienteering) +
  theme_bw() 

table(df$date_range_start)

df2 <- data %>%
  pull(popularity_by_day) %>%
  group_by(popularity_by_day)



##### class work
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


##########
cal <- USAboundaries::us_counties(states = "California") %>%
  select(countyfp, countyns, name, aland, awater, state_abbr, geometry)
cal

ggplot() +
  geom_sf(data = cal) +
  geom_sf(data = filter(df, region == "CA"))

ggplot() +
  geom_sf(data = cal, aes(fill = awater)) +
  geom_sf_text(data = cal, aes(label = name), color = "grey")

cal %>%
  select(-9) %>%
  mutate(
    sf_area = st_area(geometry), 
    sf_middle = st_centroid(geometry))

chipotle_in_county <- st_join(df, cal, join = st_within)

chipotle_in_county %>%
  as_tibble() %>%
  count(geoid, name)

cal %>%
  mutate(
    states_area = aland + awater,
    sf_area = st_area(geometry)) %>%
  select(name, states_area, aland, sf_area, awater) %>%
  filter(name == "Santa Barbara")

ksu <- tibble(lat = 34.037876, long = -84.59102) %>%
  st_as_sf(coords = c("long", "lat"), crs = 3310)

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

ggplot(data = calw) +
  geom_sf(aes(fill = sf_intersects)) + 
  geom_sf(aes(geometry = sf_buffer), fill = "white") +
  geom_sf(aes(geometry = sf_center), color = "darkgrey") +
  geom_sf_text(aes(label = name), color = "lightgrey") +
  geom_sf(data = filter(df, region == "CA"), color = "black") + # our chipotle locations
  theme_bw() 

store_in_county <- st_join(df, cal, join = st_within) %>%
  select(placekey, city, region, geometry, countyfp, name)

store_in_county_count <- store_in_county %>%
  as_tibble() %>% 
  count(countyfp, name) %>%
  filter(!is.na(countyfp)) # drop the NA counts.

calw <- calw %>%
  left_join(store_in_county_count, fill = 0) %>%
  replace_na(list(n = 0)) 

calw %>%
  ggplot() +
  geom_sf(aes(fill = n)) + 
  scale_fill_continuous(trans = "sqrt") +
  geom_sf(data = filter(df, region == "CA"), color = "white", shape = "x") +
  theme_bw() +
  theme(legend.position = "bottom") +
  labs(fill = "Number of Chipotle\nstores")

##### more complicated join
dat_wc <- st_join(df, cal, join = st_within)

days_week_long <- dat_wc %>%
  filter(region == "CA") %>%
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

calw <- calw %>%
  left_join(visits_day_join %>% select(-name_county)) %>%
  replace_na(list(Monday = 0, Tuesday = 0, Wednesday = 0,
                  Thursday = 0, Friday = 0, Saturday = 0, Sunday = 0)) 

calw %>%
  ggplot() +
  geom_sf(aes(fill = Saturday)) + 
  geom_sf(data = filter(df, region == "CA"), color = "white", shape = "x") +
  theme_bw() +
  theme(legend.position = "bottom") +
  labs(fill = "Average store traffic", 
       title = "Saturday traffic for Chipotle")



