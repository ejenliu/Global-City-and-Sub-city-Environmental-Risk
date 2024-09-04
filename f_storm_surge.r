#Install and load packages
install.packages("raster")
install.packages("sf")
install.packages(exactextractr)

library(raster)
library(sf)
library(exactextractr)

#Load data
pop_2025 <- raster("GHS_POP_E2025_GLOBE_R2023A_4326_3ss_V1_0-003.tif")
cities_dataset <- st_read("cities_dataset_progress_7_15.gpkg")

#Pull in rasters generated using arcpy: population masked by flooded affected areas and total population in LECZs
masked_population <- raster("future_surge_masked_population.tif")
lecz_population <- raster("D:/JFM_tests/CASA/GHSPop_2025_maskedCitiesLECZ.tif")

#Find affected population per city using zonal statistics
affected_population_city <- exact_extract(masked_population, cities_dataset, 'sum')
summary(affected_population_city)
cities_dataset$affected_population_city <- affected_population_city

#Find total population in LECZs
lecz_city_population <- exact_extract(lecz_population, cities_dataset, 'sum')
summary(lecz_city_population)
cities_dataset$lecz_city_population <- lecz_city_population

#Find percentage of population affected in each city in LECZs
percent_affected_population <- ifelse(lecz_city_population != 0, (affected_population_city / lecz_city_population) * 100, 0)
summary(percent_affected_population)
cities_dataset$RISK_SURG_ <- percent_affected_population

#Round breaks and classify surge values on scale between 0-5
breaks <- c(-Inf,0, 1, 2, 3, 6, Inf)
labels <- c("0", "1", "2", "3", "4", "5")
cities_dataset$RISK_SURG <- cut(cities_dataset$RISK_SURG_, breaks = breaks, labels = labels, include.lowest = TRUE)
cities_dataset$RISK_SURG[cities_dataset$RISK_SURG_ == 0] <- 0
cities_dataset$RISK_SURG <- as.numeric(as.character(cities_dataset$RISK_SURG))
summary(cities_dataset$RISK_SURG)

st_write(cities_dataset, "cities_dataset_progress_7_16.gpkg", driver = "GPKG", append=FALSE)
cities_dataset <- st_read("cities_dataset_progress_7_16.gpkg")
