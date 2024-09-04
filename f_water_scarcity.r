#Install and load packages
install.packages("dplyr")
install.packages("tidyverse")
install.packages("sf")
install.packages("terra")

library(dplyr)
library(tidyverse)
library(sf)
library(terra)

#Read cities dataset
cities_dataset <- st_read("cities_dataset_progress_7_15.gpkg")

#Read in file that was processed in arcpy: Perform spatial join between city and catchment polygons in arcpy to identify all catchments that intersect with each city polygon
cities_catchments_join <- st_read("cities_catchments_join.shp")

#Classify water scarcity scores on scale between 0 and 5
cities_catchments_join <- cities_catchments_join %>%
  mutate(WSL50_SSP2 = case_when(
    `WSL50_SSP2` == "Seasonal water scarcity" ~ 4,
    `WSL50_SSP2` == "Perennial water scarcity" ~ 5,
    `WSL50_SSP2` == "Arid and low water use" ~ 3,
    `WSL50_SSP2` == "Non-water scarcity" ~ 0,
    TRUE ~ NA_real_ 
  ))

cities_catchments_join <- st_make_valid(cities_catchments_join)

#Find max WSL score within each city
cities_with_scores_SSP2 <- cities_catchments_join %>%
  group_by(city_id = cities_catchments_join$ID_HDC_G0) %>%  
  summarize(RISK_SCAR = max(WSL50_SSP2, na.rm = TRUE))

#Join with cities dataset
cities_with_scores_SSP2 <- st_drop_geometry(cities_with_scores_SSP2)
cities_with_scores_SSP2$ID_HDC_G0 <- cities_with_scores_SSP2$city_id
cities_dataset <- left_join(cities_dataset, cities_with_scores_SSP2, by="ID_HDC_G0")

cities_dataset <- st_read("cities_dataset_progress_7_2.gpkg")
#Hard code for cities missing water scarcity values
# Define cities and their corresponding RISK_WATER values
cities_to_hardcode <- c(
  "João Teves" = 5,
  "Mindelo" = 5,
  "Le Port" = 3,
  "Le Tampon" = 3,
  "Saint-André" = 3,
  "Saint-Denis" = 3,
  "Papeete" = 3,
  "Malé" = 5,
  "Port Louis" = 5,
  "Honolulu" = 5
)

# Hard code RISK_WATER values without altering existing rows
cities_dataset$RISK_SCAR.y <- ifelse(cities_dataset$UC_NM_MN %in% names(cities_to_hardcode),
                                   cities_to_hardcode[cities_dataset$UC_NM_MN],
                                   cities_dataset$RISK_SCAR.y)

cities_dataset <- cities_dataset %>%
  rename (RISK_SCAR = RISK_SCAR.y)

st_write(cities_dataset, "cities_dataset_progress_7_15.gpkg", driver = "GPKG", append=FALSE)