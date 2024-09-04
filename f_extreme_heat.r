#Install and load packages
install.packages("dplyr")
install.packages("tidyverse")
install.packages("sf")
install.packages("terra")

library(dplyr)
library(tidyverse)
library(sf)
library(terra)

tmax_45 <- st_read("Tmax45_avg_counts_07-16.shp")
wbgtmax_30 <- st_read("wbgtmax30_avg_counts_07-16.shp")
cities_dataset <- st_read("cities_dataset_progress_7_15.gpkg")

cities_dataset <- cities_dataset %>%
  select(-obs.y)

#Add tmax45 days and wbgtmax_30 days to cities dataset
tmax_45 <- st_drop_geometry(tmax_45)
cities_dataset <- left_join(cities_dataset, tmax_45, by="ID_HDC_G0")
cities_dataset$RISK_TEMP_SSP2_unclassified <- cities_dataset$X2050SSP245
cities_dataset$RISK_TEMP_SSP5_unclassified <- cities_dataset$X2050SSP585

wbgtmax_30 <- st_drop_geometry(wbgtmax_30)
cities_dataset <- left_join(cities_dataset, wbgtmax_30, by="ID_HDC_G0")
cities_dataset$RISK_WBGT_SSP2_unclassified <- cities_dataset$X2050SSP245
cities_dataset$RISK_WBGT_SSP5_unclassified <- cities_dataset$X2050SSP585

#Classify days into categories
breaks <- c(-Inf, 0, 7, 30, 60, 90, Inf)
labels <- c("0", "1", "2", "3", "4", "5")
cities_dataset$RISK_TEMP <- cut(cities_dataset$RISK_TEMP_, breaks = breaks, labels = labels, right = FALSE)
cities_dataset$RISK_TEMP[cities_dataset$RISK_TEMP_ == 0] <- 0

cities_dataset$RISK_WBGT <- cut(cities_dataset$RISK_WBGT_, breaks = breaks, labels = labels, right = FALSE)
cities_dataset$RISK_WBGT[cities_dataset$RISK_WBGT_ == 0] <- 0

cities_dataset$RISK_WBGT <- as.numeric(as.character(cities_dataset$RISK_WBGT))
cities_dataset$RISK_TEMP <- as.numeric(as.character(cities_dataset$RISK_TEMP))

st_write(cities_dataset, "cities_dataset_progress_7_15.gpkg", driver = "GPKG", append=FALSE)
