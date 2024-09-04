#Install and load packages
install.packages("exactextractr")
install.packages("raster")
install.packages("sf")
install.packages("sp")
install.packages("dplyr")
install.packages("tidyverse")
install.packages("terra")
install.packages("classInt")

library(exactextractr)  
library(raster)        
library(sf)            
library(sp)                  
library(dplyr)
library(tidyverse)
library(terra)
library(classInt)

#Projections
proj <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"

#Import ghsucdb city boundaries
cities_dataset <- st_read("cities_dataset.gpkg")

#Read global landslide data
global_landslide <- raster("global-landslide-susceptibility-map-2-27-23.tif")

#Zonal statistics to find average susceptibility for each city
print(crs(global_landslide)) #global_landslide is in WGS84, no need for re-projection
cities_dataset$future_landslide_unclassified <- exact_extract(global_landslide, cities_dataset, 'mean')

#Classify into scale between 0 = no risk and 5 = very high by rounding
cities_dataset$future_landslide_classified <- round(cities_dataset$future_landslide_unclassified, digits=0)

#Export as geopackage
st_write(cities_dataset, "future_landslide.gpkg", driver = "GPKG", append=FALSE)
