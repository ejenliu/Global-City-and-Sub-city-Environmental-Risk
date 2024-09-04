new_library_path <- "G:/CASA/ejen/CustomR"
.libPaths(c(new_library_path, .libPaths()))

#Install and load packages
install.packages("dplyr")
install.packages("tidyverse")
install.packages("sf")
install.packages("terra")

library(dplyr)
library(tidyverse)
library(sf)
library(terra)

#Perform spatial join between city and catchment polygons in arcpy to identify all catchments that intersect with each city polygon
cities_catchments_join <- st_read("G:/CASA/output_shapefiles/baseline_cities_catchments_join.shp")

#Create binary variable for non water scarcity versus some water scarcity
cities_catchments_join <- cities_catchments_join %>%
  mutate(WSL_baseline = case_when(
    `Water_scar` == "Seasonal water scarcity" ~ 1,
    `Water_scar` == "Perennial water scarcity" ~ 1,
    `Water_scar` == "Arid and low water use" ~ 1,
    `Water_scar` == "Non-water scarcity" ~ 0,
    TRUE ~ NA_real_ 
  ))


cities_catchments_join <- st_make_valid(cities_catchments_join)

keep <- c("ID_HDC_G0", "pfaf_id", "CTR_MN_NM", "UC_NM_MN", "UC_NM_LST", "WSL_baseline", "Water_scar")
recent_water_scarcity <- cities_catchments_join[, keep]

#Find max WSL score within each city
dichotomous_scores <- recent_water_scarcity %>%
  group_by(city_id = recent_water_scarcity$ID_HDC_G0) %>%  
  summarize(recent_water_scarcity = max(WSL_baseline, na.rm = TRUE))

st_write(dichotomous_scores, "r_water_scarcity_city", driver = "GPKG", append=FALSE)
st_write(recent_water_scarcity, "r_water_scarcity_catchment.gpkg", driver = "GPKG", append=FALSE)

