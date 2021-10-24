pacman::p_load(tidyverse, sf, USAboundaries, leaflet, cowplot)
#install.packages("USAboundariesData", repos = "http://packages.ropensci.org", type = "source") #nolint

httpgd::hgd()
httpgd::hgd_browse()

july <- read_csv("Data folder/core_poi-patterns_07_2021.csv")
aug <- read_csv("Data folder/core_poi-patterns_08_2021.csv")
sep <- read_csv("Data folder/core_poi-patterns_09_2021.csv")

covid_sites2 <- read_csv("Data folder/Covid_Testing_Sites.csv") %>%
    filter(X > -85.5, Y > 29)

covid_sites2 <- covid_sites2 %>% st_as_sf(coords = c("X", "Y"), crs = 4326)

ggplot() +
    geom_sf(data = ga) +
    geom_sf(data = covid_sites2) +
    theme_bw()

dat <- rbind(july, aug, sep)

dat <- dat %>% filter(region == "GA")

ga <- us_counties(states = "Georgia") %>%
    select(countyfp, countyns, name, aland, awater, state_abbr, geometry)

dat_july <- july %>% st_as_sf(coords = c("longitude", "latitude"), crs = 4326)

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

ggplot(data = gaw) +
    geom_sf(aes(geometry = sf_buffer), fill = "white") +
    geom_sf(aes(geometry = sf_center), color = "darkgrey") +
    geom_sf_text(aes(label = name), color = "lightgrey") +
    geom_sf(data = filter(dat_july, region == "GA"), color = "black") +
    theme_bw()

ggplot(data = gaw) +
    geom_sf(aes(geometry = sf_buffer), fill = NA) +
    geom_sf(aes(geometry = sf_center), color = "darkgrey") +
    geom_sf_text(aes(label = name), color = "lightgrey") +
    geom_sf(data = filter(dat_july, region == "GA"), color = "black") +
    theme_bw()

covid_cases <- st_join(dat_july, ga, join = st_within) %>%
    select(placekey, visits_by_day, city, region, geometry, raw_visitor_counts, location_name, countyfp) # nolint

covid_cases_count <- covid_cases %>%
    as_tibble() %>%
    count(countyfp, location_name) %>%
    filter(!is.na(countyfp)) # drop the NA counts.

gaw <- gaw %>%
    left_join(covid_cases_count, fill = 0)

A <- gaw %>%
ggplot() +
    geom_sf(aes(fill = n)) +
    scale_fill_continuous(trans = "sqrt") +
    geom_sf(data = filter(dat_aug, region == "GA"), color = "white", shape = "x") + # nolint
    theme_bw() +
    theme(legend.position = "bottom") +
    labs(fill = "Number of Hospitals")

dat_aug <- aug %>% st_as_sf(coords = c("longitude", "latitude"), crs = 4326)

B <- gaw %>%
ggplot() +
    geom_sf(aes(fill = n)) +
    scale_fill_continuous(trans = "sqrt") +
    geom_sf(data = filter(dat_aug, region == "GA"), color = "white", shape = "x") + # nolint
    theme_bw() +
    theme(legend.position = "bottom") +
    labs(fill = "Number of Hospitals")

ggdraw() +
  draw_plot(A, x = 0, y = .5, width = .5, height = .5) +
  draw_plot(B, x = .5, y = .5, width = .5, height = .5)

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
