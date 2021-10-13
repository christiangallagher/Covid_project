#Test Project Stuff
#Cartograms

dat1 <-  read.csv("Data folder/core_poi-patterns_07_2021.csv")

dat2 <- read.csv("Data folder/core_poi-patterns_08_2021.csv")

dat3 <- read.csv("Data folder/core_poi-patterns_09_2021.csv")

dat <- merge(dat1, dat2, dat3)

glimpse(dat)

glimpse(dat2)

glimpse(dat3)