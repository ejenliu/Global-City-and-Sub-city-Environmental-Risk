new_library_path <- "G:/CASA/ejen/CustomR"
.libPaths(c(new_library_path, .libPaths()))

#Install and load packages
install.packages("dplyr")
install.packages("tidyverse")
install.packages("sf")
install.packages("terra")
install.packages("raster")
install.packages("exactextractr")

library(dplyr)
library(tidyverse)
library(sf)
library(terra)
library(raster)
library(exactextractr)

#Load data
cities_dataset <- st_read("cities_dataset_progress_7_15.gpkg")

#Read in file that was processed in arcpy: #Masked population raster with population values only where flood data is present
population_masked <- raster("D:/JFM_tests/CASA/GHSPop_2025_maskedRiverine.tif")

#Zonal statistics to find number of people affected in each city
cities_dataset$affectedpop <- exact_extract(population_masked, cities_dataset, 'sum')

#Find percentage of population affected for each city
cities_dataset$future_flood_percent_pop <- (cities_dataset$affectedpop / cities_dataset$P25)*100
summary(cities_dataset$future_flood_percent_pop)

#Classify city population percentages to assess vulnerability
breaks <- c(-Inf, 0, 10, 20, 30, 40, Inf)
labels <- c(0, 1, 2, 3, 4, 5)
cities_dataset$RISK_RIVR <- cut(cities_dataset$RISK_RIVR_, breaks = breaks, labels = labels, include.lowest = TRUE)
cities_dataset$RISK_RIVR <- as.numeric(as.character(cities_dataset$RISK_RIVR))
summary(cities_dataset$RISK_RIVR)
keep <- c("ID_HDC_G0", "RISK_RIVER", "future_flood_percent_pop") #select relevant variables
cities_dataset <- cities_dataset[, keep]

st_write(cities_dataset, "cities_dataset_progress_7_15.gpkg", driver = "GPKG", append=FALSE)
