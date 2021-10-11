pacman::p_load(tidyverse, sf, USAboundaries, leaflet)
install.packages("USAboundariesData", repos = "http://packages.ropensci.org", type = "source")

httpgd::hgd()
httpgd::hgd_browse()