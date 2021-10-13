pacman::p_load(tidyverse, sf, USAboundaries, leaflet, jcolors)

httpgd::hgd()
httpgd::hgd_browse()

dat <- read_rds("chipotle_nested.rds") %>%
    st_as_sf(coords = c("longitude", "latitude"), crs = 4326)

cal <- us_counties(states = "California") %>%
    select(countyfp, countyns, name, aland, awater, state_abbr, geometry)

cal %>%
    mutate(
        states_area = aland + awater,
        sf_area = st_area(geometry)) %>%
    select(name, states_area, aland, sf_area, awater) %>%
    filter(name == "Santa Barbara")

ksu <- tibble(latitude = 34.037876, longitude = -84.58102) %>%
    st_as_sf(coords = c("longitude", "latitude"), crs = 3310)

    # https://epsg.io/4326 units are degrees
calw <- cal %>%
    st_transform(3310) %>% # search https://spatialreference.org/ref/?search=california&srtext=Search. Units are in meters for buffer. # nolint
    #transforming bc long & lat are in degrees but we need to change to meters
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
        sf_intersects = st_intersects(., filter(., name == "Los Angeles"), sparse = FALSE) #making the counties that are touching LA count as LA # nolint
        )

ggplot(data = calw) +
    geom_sf(aes(fill = sf_intersects)) +
    geom_sf(aes(geometry = sf_buffer), fill = "white") +
    geom_sf(aes(geometry = sf_center), color = "darkgrey") +
    geom_sf_text(aes(label = name), color = "lightgrey") +
    geom_sf(data = filter(dat, region == "CA"), color = "black") + # our chipotle locations # nolint
    theme_bw()

ggplot(data = calw) +
    geom_sf(aes(fill = sf_intersects)) +
    geom_sf(aes(geometry = sf_buffer), fill = NA) +
    geom_sf(aes(geometry = sf_center), color = "darkgrey") +
    geom_sf_text(aes(label = name), color = "lightgrey") +
    geom_sf(data = filter(dat, region == "CA"), color = "black") + # our chipotle locations # nolint
    theme_bw()

# the join chart build process

store_in_county <- st_join(dat, cal, join = st_within) %>%
    select(placekey, city, region, geometry, countyfp, name)

store_in_county_count <- store_in_county %>%
    as_tibble() %>%
    count(countyfp, name) %>%
    filter(!is.na(countyfp)) # drop the NA counts.

calw <- calw %>%
    left_join(store_in_county_count, fill = 0)

calw %>%
ggplot() +
    geom_sf(aes(fill = n)) +
    scale_fill_continuous(trans = "sqrt") +
    geom_sf(data = filter(dat, region == "CA"), color = "white", shape = "x") +
    theme_bw() +
    theme(legend.position = "bottom") +
    labs(fill = "Number of Chipotle\nstores") +
    scale_fill_gradient(low = "orange", high = "red", na.value = NA) # changing color # nolint

# more complicated join
dat_wc <- st_join(dat, cal, join = st_within)

days_week_long <- dat_wc %>%
    filter(region == "CA") %>%
    as_tibble() %>% # notice this line to break the sf object rules.
    rename(name_county = name) %>%
    unnest(popularity_by_day) %>%
    select(placekey, city, region, contains("raw"),
        name, value, geometry, countyfp, name_county)

days_week <-  days_week_long %>%
    pivot_wider(names_from = name, values_from = value)

 # average visits per day over the n stores by county.
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
    left_join(visits_day_join %>% select(-name_county)) %>%  # nolint
    replace_na(list(Monday = 0, Tuesday = 0, Wednesday = 0,
      Thursday = 0, Friday = 0, Saturday = 0, Sunday = 0))

calw %>%
ggplot() +
    geom_sf(aes(fill = Saturday)) +
    geom_sf(data = filter(dat, region == "CA"), color = "white", shape = "x") +
    theme_bw() +
    theme(legend.position = "bottom") +
    labs(fill = "Average store traffic",
      title = "Saturday traffic for Chipotle")
      
calw %>%
ggplot() +
    geom_sf(aes(fill = Saturday)) +
    geom_sf(aes(geometry = sf_center, size = count), color = "grey") +
    theme_bw() +
    scale_size_continuous(breaks = c(1, 5, 10, 25, 50, 75),
      trans = "sqrt", range = c(2, 15)) +
    labs(
        fill = "Average store traffic",
        size = "Number of stores",
        title = "Saturday traffic for Chipotle")
        calw_4326 <- st_transform(calw, 4326) # will need in 4326 for leaflet

bins <- c(0, 10, 20, 30, 50, 70, 90, 110)
pal <- colorBin("YlOrRd", domain = calw_4326$n)

m <- leaflet(calw_4326) %>%
    addPolygons(
        data = calw_4326,
        fillColor = ~pal(n),
        fillOpacity = .5,
        color = "darkgrey",
        weight = 2) %>%
    addCircleMarkers(
        data = filter(dat, region == "CA"),
        radius = 3,
        color = "grey") %>%
    addProviderTiles(providers$CartoDB.Positron)
