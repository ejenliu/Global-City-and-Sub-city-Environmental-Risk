new_library_path <- "G:/CASA/ejen/CustomR"
.libPaths(c(new_library_path, .libPaths()))

#Install and load packages
install.packages("exactextractr")
install.packages("raster")
install.packages("sf")
install.packages("tidyverse")

library(exactextractr)  
library(raster)        
library(sf)  
library(tidyverse)

cities_dataset <- st_read("cities_dataset_progress_check.gpkg")

#Read in rasters processed in arcpy: # Convert from m/s to km/h
CRH_RP100 <- raster("2050_ssp245_CRH_RP100_kmh.tif")
CRH_RP200 <- raster("2050_ssp245_CRH_RP200_kmh.tif")
SD_RP100 <- raster("2050_ssp245_SD_RP100_kmh.tif")
SD_RP200 <- raster("2050_ssp245_SD_RP200_kmh.tif")

#Find max value within each city boundary
cities_dataset$CRH_RP100 <- exact_extract(CRH_RP100, cities_dataset, 'max')
cities_dataset$CRH_RP200 <- exact_extract(CRH_RP200, cities_dataset, 'max')
cities_dataset$SD_RP100 <- exact_extract(SD_RP100, cities_dataset, 'max')
cities_dataset$SD_RP200 <- exact_extract(SD_RP200, cities_dataset, 'max')

#Average CRH and SD scores
cities_dataset$average_RP100 <- (cities_dataset$CRH_RP100 + cities_dataset$SD_RP100) / 2
cities_dataset$average_RP200 <- (cities_dataset$CRH_RP200 + cities_dataset$SD_RP200) / 2

#Classify
breaks <- c(-Inf, 119, 153, 177, 208, 251, Inf)
labels <- c(0, 1, 2, 3, 4, 5)
cities_dataset$RISK_CYCLONE_RP100 <- cut(cities_dataset$average_RP100, breaks = breaks, labels = labels, right = FALSE)
cities_dataset$RISK_CYCLONE_RP200 <- cut(cities_dataset$average_RP200, breaks = breaks, labels = labels, right = FALSE)

cities_dataset$RISK_CYCLONE_RP100 <- as.numeric(as.character(cities_dataset$RISK_CYCLONE_RP100))
cities_dataset$RISK_CYCLONE_RP200 <- as.numeric(as.character(cities_dataset$RISK_CYCLONE_RP200))

summary(cities_dataset$RISK_CYCLONE_RP200)

st_write(cities_dataset, "future_cyclone.gpkg", driver = "GPKG", append=FALSE)
st_write(cities_dataset, "cities_dataset_progress_7_11.gpkg", driver = "GPKG", append=FALSE)

cities_dataset <- st_read("cities_dataset_progress_7_11.gpkg")