install.packages("sf")
install.packages("raster")
install.packages("dplyr")

library(sf)
library(raster)
library(dplyr)

cities_dataset <- st_read("cities_dataset_progress_7_18.gpkg")
cities_dataset_old <- st_read("cities_dataset_progress_7_15.gpkg")

cities_dataset <- st_drop_geometry(cities_dataset)
cities_dataset_old <- merge(cities_dataset_old, cities_dataset, by = c("ID_HDC_G0"), all.x = TRUE)

#Compare RP100 and RP200 for future cyclone risk
#Boxplots of distribution for RP100 versus RP200
boxplot(RISK_CYCLONE_RP100 ~ REG_GHSL, data = cities_dataset_old,
        main = "Boxplot of Cyclone RP100 by Region",
        xlab = "Region",
        ylab = "Cyclone RP 100",
        col = "darkgray",  # Color of the boxes
        border = "darkblue"  # Color of the box borders
)

boxplot(RISK_CYCLONE_RP200 ~ REG_GHSL, data = cities_dataset_old,
        main = "Boxplot of Cyclone RP200 by Region",
        xlab = "Region",
        ylab = "Cyclone RP 200",
        col = "darkgray",  # Color of the boxes
        border = "darkblue"  # Color of the box borders
)
