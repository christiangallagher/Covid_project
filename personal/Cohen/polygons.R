pacman::p_load(tidyverse, sf, USAboundaries, leaflet)
install.packages("USAboundariesData", repos = "http://packages.ropensci.org", type = "source")

httpgd::hgd()
httpgd::hgd_browse()

dat <- read_rds("chipotle_nested.rds")

dat <- dat %>% st_as_sf(coords = c("longitude", "latitude"), crs = 4326)

select(dat, street_address, region, geometry)

cal <- USAboundaries::us_counties(states = "California")

ggplot() +
    geom_sf(data = cal) +
    geom_sf(data = filter(dat, region == "CA"))

ggplot() +
    geom_sf(data = cal, aes(fill = awater)) + #awater- area of water in region
    geom_sf_text(data = cal, aes(label = name), color = "grey")

cal %>%
    select(-9) %>%
    mutate(
        sf_area = st_area(geometry), # the awater variable is in m^2
        sf_middle = st_centroid(geometry)
    )

chipotle_in_county <- st_join(dat, cal, join = st_within)

chipotle_in_county %>%
    as_tibble() %>%
    count(geoid, name)