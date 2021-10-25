pacman::p_load(tidyverse, sf, USAboundaries, leaflet, cowplot, stringdist, ggspatial)
#install.packages("USAboundariesData", repos = "http://packages.ropensci.org", type = "source") #nolint

httpgd::hgd()
httpgd::hgd_browse()

july <- read_csv("Data folder/core_poi-patterns_07_2021.csv")
aug <- read_csv("Data folder/core_poi-patterns_08_2021.csv")
sep <- read_csv("Data folder/core_poi-patterns_09_2021.csv")

covid_sites2 <- read_csv("Data folder/Covid_Testing_Sites.csv") %>%
    filter(X > -85.5, Y > 29)

covid_sites2 <- covid_sites2 %>% st_as_sf(coords = c("X", "Y"), crs = 4326)

dat <- rbind(july, aug, sep)

dat <- dat %>% filter(region == "GA")

dat <- dat %>%
  #slice(1:25) %>% # for the example
  mutate(
    open_hours = map(open_hours, ~json_to_tibble(.x)),
    visits_by_day = map(visits_by_day, ~json_to_tibble(.x)),
    visitor_home_cbgs = map(visitor_home_cbgs, ~json_to_tibble(.x)),
    visitor_country_of_origin = map(visitor_country_of_origin, ~json_to_tibble(.x)), #nolint 
    bucketed_dwell_times = map(bucketed_dwell_times, ~json_to_tibble(.x)),
    related_same_day_brand = map(related_same_day_brand, ~json_to_tibble(.x)),
    related_same_month_brand = map(related_same_month_brand, ~json_to_tibble(.x)), #nolint
    popularity_by_hour = map(popularity_by_hour, ~json_to_tibble(.x)),
    popularity_by_day = map(popularity_by_day, ~json_to_tibble(.x)),
    device_type = map(device_type, ~json_to_tibble(.x)),
    visitor_home_aggregation = map(visitor_home_aggregation, ~json_to_tibble(.x)), #nolint
    visitor_daytime_cbgs = map(visitor_daytime_cbgs, ~json_to_tibble(.x)),
  )

ga <- USAboundaries::us_counties(states = "Georgia")

ggplot() +
    geom_sf(data = ga) +
    geom_sf(data = covid_sites2) +
    theme_bw()

dat_july <- july %>% st_as_sf(coords = c("longitude", "latitude"), crs = 4326)
dat_aug <- aug %>% st_as_sf(coords = c("longitude", "latitude"), crs = 4326)
dat_sep <- sep %>% st_as_sf(coords = c("longitude", "latitude"), crs = 4326)

ga %>%
    mutate(
        states_area = aland + awater,
        sf_area = st_area(geometry)) %>%
    select(name, states_area, aland, sf_area, awater)

ksu <- tibble(latitude = 34.037876, longitude = -84.58102) %>%
    st_as_sf(coords = c("longitude", "latitude"), crs = 4326)

gaw <- ga %>%
    st_transform(4326) %>%
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

# ggplot(data = gaw) +
#     geom_sf(aes(geometry = sf_buffer), fill = "white") +
#     geom_sf(aes(geometry = sf_center), color = "darkgrey") +
#     geom_sf_text(aes(label = name), color = "lightgrey") +
#     geom_sf(data = filter(dat_july, region == "GA"), color = "black") +
#     theme_bw()

# ggplot(data = gaw) +
#     geom_sf(aes(geometry = sf_buffer), fill = NA) +
#     geom_sf(aes(geometry = sf_center), color = "darkgrey") +
#     geom_sf_text(aes(label = name), color = "lightgrey") +
#     geom_sf(data = filter(dat_july, region == "GA"), color = "black") +
#     theme_bw()

covid_cases <- st_join(dat_july, ga, join = st_within) %>%
    select(placekey, visits_by_day, city, region, geometry, raw_visitor_counts, location_name, countyfp) # nolint

covid_cases_count <- covid_cases %>%
    as_tibble() %>%
    count(countyfp, location_name) %>%
    filter(!is.na(countyfp)) # drop the NA counts.

gaw <- gaw %>%
    left_join(covid_cases_count, fill = 0)

# aug_plot <- gaw %>%
# ggplot() +
#     geom_sf(aes(fill = n)) +
#     scale_fill_continuous(trans = "sqrt") +
#     geom_sf(data = filter(dat_aug, region == "GA"), color = "white", shape = "x") + # nolint
#     theme_bw() +
#     theme(legend.position = "bottom") +
#     labs(fill = "Number of Hospitals")

# july_plot <- gaw %>%
# ggplot() +
#     geom_sf(aes(fill = n)) +
#     scale_fill_continuous(trans = "sqrt") +
#     geom_sf(data = filter(dat_july, region == "GA"), color = "white", shape = "x") + # nolint
#     theme_bw() +
#     theme(legend.position = "bottom") +
#     labs(fill = "Number of Hospitals")

# sep_plot <- gaw %>%
# ggplot() +
#     geom_sf(aes(fill = n)) +
#     scale_fill_continuous(trans = "sqrt") +
#     geom_sf(data = filter(dat_sep, region == "GA"), color = "white", shape = "x") + # nolint
#     theme_bw() +
#     theme(legend.position = "bottom") +
#     labs(fill = "Number of Hospitals")

# ggdraw() +
#   draw_plot(july_plot, x = 0, y = .5, width = .5, height = .5) +
#   draw_plot(sep_plot, x = .5, y = .5, width = .5, height = .5) +
#   draw_plot(aug_plot, x = .5, y = .5, width = .5, height = .5)

# all the months on the plot

dat_sf <- dat %>% st_as_sf(coords = c("longitude", "latitude"), crs = 4326)

ggplot() +
    geom_sf(data = ga) +
    geom_sf(data = dat_sf) +
    theme_bw()

gaw %>%
ggplot() +
    geom_sf(aes(fill = n)) +
    scale_fill_continuous(trans = "sqrt") +
    geom_sf(data = filter(dat_sf, region == "GA"), color = "white", shape = "x") + # nolint
    theme_bw() +
    theme(legend.position = "bottom") +
    labs(fill = "Number of Hospitals")


sites <- read.csv("Data folder/WalgreensSites.csv")

glimpse(sites)
cases <- read.csv("https://raw.githubusercontent.com/nytimes/covid-19-data/master/rolling-averages/us-counties-2021.csv") # nolint

cases <- cases %>% filter(state == "Georgia", date >= as.Date("2021-07-01"), date <= as.Date("2021-09-30")) # nolint

cases %>%
ggplot() +
    geom_sf(data = ga) +
    theme_bw()

ga <- ga[, !duplicated(colnames(ga))]

colnames(ga)[6] <- "county"

casga <- merge(cases, ga, by = "county")

test1 <- casga  %>%
group_by(county) %>%
summarise(pcc = sum(cases_avg_per_100k))

countycases <- merge(ga, test1, by = "county")

city_pop <- read_csv("Data folder/City_pop.csv")

city_pop2019 <- city_pop %>%
  select("name", "pop2019")

df <- merge(dat_sf, city_pop2019, by.x = "city", by.y = "name")

tab2 <- df %>%
  group_by(city)

tab2 <- tab2 %>%
  summarize(n = sum(raw_visit_counts, na.rm = TRUE))

tab3 <- merge(tab2, city_pop2019, by.x = "city", by.y = "name")

ggplot() +
    geom_sf(data = countycases, aes(fill = pcc)) +
    scale_fill_viridis_c(trans = "sqrt", alpha = .4) +
    geom_sf(data = dat_sf) +
    geom_sf(data = tab3, color = "black",
          aes(size = (n / pop2019) * 100), alpha = 0.5) +
  annotation_scale(location = "tr", width_hint = 0.25) +
  annotation_north_arrow(location = "tr", which_north = "true",
                         pad_x = unit(0.75, "cm"), pad_y = unit(0.75, "cm"),
                         style = north_arrow_fancy_orienteering) +
  labs(size = "Proportional Visit Count")

#Do cases correlate with number of testing sites in the county?
#Do cases correlate with number of hospital visits?
#How do we even begin plotting by date?
# I guess we don't really do sf, but more just temporal plots
#So many lingering questions

allsites <- read_csv("Data folder/Covid_Testing_Sites.csv")