new_library_path <- "G:/CASA/ejen/CustomR"
.libPaths(c(new_library_path, .libPaths()))

#Install and load packages
install.packages("exactextractr")
install.packages("raster")
install.packages("sf")
install.packages("sp")
install.packages("dplyr")
install.packages("tidyverse")
install.packages("terra")
install.packages("labeling")
install.packages("farver")

library(exactextractr)  
library(raster)        
library(sf)            
library(sp)                  
library(dplyr)
library(tidyverse)
library(terra)
library(ggplot2)
library(labeling)
library(farver)

#Projections
proj <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"

#Load GHS UCDB city boundaries and GHSPOP population rasters
ghsucdb2015 <- st_read("GHS_STAT_UCDB2015MT_GLOBE_R2019A_V1_2.gpkg")
ghsucdb2015 <- st_transform(ghsucdb2015, proj)
ghspop2025 <- raster("GHS_POP_E2025_GLOBE_R2023A_4326_3ss_V1_0.tif")
ghspop2020 <- raster("GHS_POP_E2020_GLOBE_R2023A_4326_3ss_V1_0.tif")
ghspop2015 <- raster("GHS_POP_E2015_GLOBE_R2023A_4326_3ss_V1_0.tif")

#Keep relevant variables
keep <- c("ID_HDC_G0","UC_NM_LST", "UC_NM_MN", "GDP15_SM", "CTR_MN_NM", "EL_AV_ALS", "E_KG_NM_LST")
cities_dataset <- ghsucdb2015[, keep]

#GHS POP 2025
cities_dataset$P25 <- exact_extract(ghspop2025, ghsucdb2015, 'sum')

#GHS POP 2020
cities_dataset$P20 <- exact_extract(ghspop2020, ghsucdb2015, 'sum')

#GHS POP 2015
cities_dataset$P15 <- exact_extract(ghspop2015, ghsucdb2015, 'sum')

#GDP per capita
cities_dataset <- cities_dataset %>%
  mutate(GDP15_PER = (GDP15 / P15)) #create variable for GDP per capita

#Generate variable for small and medium sized cities
cities_dataset <- cities_dataset %>%
  mutate(P25_SMMED = ifelse(P25 < 300000, 1, 0))
    
#Generate annual rate of population change 2020-2025
cities_dataset <- cities_dataset %>%
  mutate(P20_25 = ((P25 / P20)^(1/5) - 1) * 100)

#Generate variable for fast annual rate of population growth >= 4%
cities_dataset <- cities_dataset %>%
  mutate(P20_25_BIN = ifelse(P20_25 >= 4, 1, 0))

#Assign regions
region_map <- c(
  "Angola" = "AFRICA", "Benin" = "AFRICA", "Botswana" = "AFRICA", "Burkina Faso" = "AFRICA",
  "Burundi" = "AFRICA", "Cameroon" = "AFRICA", "CAR" = "AFRICA", "Chad" = "AFRICA",
  "Code d'Ivoire" = "AFRICA", "Djibouti" = "AFRICA", "DR Congo" = "AFRICA",
  "Eswantini" = "AFRICA", "Ethiopia" = "AFRICA", "Gambia" = "AFRICA", "Ghana" = "AFRICA",
  "Guinea" = "AFRICA", "Kenya" = "AFRICA", "Lesotho" = "AFRICA", "Liberia" = "AFRICA",
  "Madagascar" = "AFRICA", "Malawi" = "AFRICA", "Mali" = "AFRICA", "Mauritania" = "AFRICA",
  "Mozambique" = "AFRICA", "Namibia" = "AFRICA", "Niger" = "AFRICA", "Nigeria" = "AFRICA",
  "Rwanda" = "AFRICA", "Senegal" = "AFRICA", "Sierra Leone" = "AFRICA", "Somalia" = "AFRICA",
  "South Africa" = "AFRICA", "South Sudan" = "AFRICA", "Sudan" = "AFRICA", "Tanzania" = "AFRICA",
  "Uganda" = "AFRICA", "Zambia" = "AFRICA", "Zimbabwe" = "AFRICA",
  
  "Afghanistan" = "ASIA", "Bangladesh" = "ASIA", "Burma (Myanmar)" = "ASIA",
  "Cambodia" = "ASIA", "China" = "ASIA", "India" = "ASIA", "Indonesia" = "ASIA",
  "Kazakhstan" = "ASIA", "Kyrgyz Republic" = "ASIA", "Laos" = "ASIA", "Maldives" = "ASIA",
  "Mongolia" = "ASIA", "Nepal" = "ASIA", "Pakistan" = "ASIA", "Philippines" = "ASIA",
  "Sri Lanka" = "ASIA", "Tajikistan" = "ASIA", "Thailand" = "ASIA", "Timor-Leste" = "ASIA",
  "Turkmenistan" = "ASIA", "Uzbekistan" = "ASIA", "Vietnam" = "ASIA",
  
  "Bolivia" = "LATIN AMERICA & CARIBBEAN", "Brazil" = "LATIN AMERICA & CARIBBEAN",
  "Colombia" = "LATIN AMERICA & CARIBBEAN", "Cuba" = "LATIN AMERICA & CARIBBEAN",
  "Dominican Republic" = "LATIN AMERICA & CARIBBEAN", "El Salvador" = "LATIN AMERICA & CARIBBEAN",
  "Guatemala" = "LATIN AMERICA & CARIBBEAN", "Haiti" = "LATIN AMERICA & CARIBBEAN",
  "Honduras" = "LATIN AMERICA & CARIBBEAN", "Jamaica" = "LATIN AMERICA & CARIBBEAN",
  "Mexico" = "LATIN AMERICA & CARIBBEAN", "Nicaragua" = "LATIN AMERICA & CARIBBEAN",
  "Panama" = "LATIN AMERICA & CARIBBEAN", "Paraguay" = "LATIN AMERICA & CARIBBEAN",
  "Peru" = "LATIN AMERICA & CARIBBEAN", "Venezuela" = "LATIN AMERICA & CARIBBEAN",
  
  "Albania" = "EUROPE & EURASIA", "Armenia" = "EUROPE & EURASIA", "Azerbaijan" = "EUROPE & EURASIA",
  "Belarus" = "EUROPE & EURASIA", "Bosnia and Herzegovina" = "EUROPE & EURASIA",
  "Georgia" = "EUROPE & EURASIA", "Greenland" = "EUROPE & EURASIA", "Kosovo" = "EUROPE & EURASIA",
  "Moldova" = "EUROPE & EURASIA", "North Macedonia" = "EUROPE & EURASIA",
  "Russia" = "EUROPE & EURASIA", "Serbia" = "EUROPE & EURASIA", "Ukraine" = "EUROPE & EURASIA",
  
  "Egypt" = "MIDDLE EAST", "Iraq" = "MIDDLE EAST", "Jordan" = "MIDDLE EAST", "Lebanon" = "MIDDLE EAST",
  "Libya" = "MIDDLE EAST", "Morocco" = "MIDDLE EAST", "Syria" = "MIDDLE EAST", "Tunisia" = "MIDDLE EAST",
  "West Bank" = "MIDDLE EAST", "Yemen" = "MIDDLE EAST"
)

cities_dataset <- cities_dataset  %>%
  mutate(REGION = region_map[CTR_MN_NM])

#City size P25_CAT
cutoffs_P25_CAT <- c(50000, 100000, 300000, 500000, 1000000, 5000000, 10000000, Inf)
labels_P25_CAT <- c("50k-100k", "100k-300k", "300k-500k", "500k-1M", "1M-5M", "5M-10M", "10M+")
cities_dataset$P25_CAT <- cut(cities_dataset$P25, breaks = cutoffs_P25_CAT, labels = labels_P25_CAT, right = FALSE)

#P_20_25_CAT
cutoffs_P_20_25_CAT <- c(-Inf, -2, 0, 2, 4, 6, Inf)
labels_P_20_25_CAT <- c("<-2%", "-2%-0%", "0%-2%", "2%-4%", "4%-6%", ">6%")  # Adjusted labels
cities_dataset$P_20_25_CAT <- cut(cities_dataset$P2025_CHNG, breaks = cutoffs_P_20_25_CAT, labels = labels_P_20_25_CAT, right = FALSE)

#Join worldpop demographics dataset to cities_dataset
#Match the zone
worldpop_demographics <- read.csv("worldpop_agesex_urban_demographic.csv")
worldpop_2020 <- subset(worldpop_demographics, year == 2020)
keep3 <- c("zone", "young_sum", "working_sum", "old_sum", "total_pop", "dependency_ratio","city_name", "country_name")
worldpop_2020 <- worldpop_2020[, keep3]
worldpop_2020$ID_HDC_G0 <- worldpop_2020$zone
cities_dataset <- merge(cities_dataset, worldpop_2020, by = c("ID_HDC_G0"), all.x = TRUE)

#Generate age variables
cities_dataset$P_AGE_UND15 <- (cities_dataset$young_sum/cities_dataset$total_pop)*100
cities_dataset$P_AGE_15_64 <- (cities_dataset$working_sum/cities_dataset$total_pop)*100
cities_dataset$P_AGE_65UP <- (cities_dataset$old_sum/cities_dataset$total_pop)*100
cities_dataset$P_DEP_RATIO <- cities_dataset$dependency_ratio

#Generate migration/pop change variables
worldpop_migration <- read.csv("worldpop_agesex_change_migration.csv")
keep4 <- c("zone", "total_pop_perc","migration_perc","city_name", "country_name")
worldpop_migration <- worldpop_migration[, keep4]
worldpop_migration$ID_HDC_G0 <- worldpop_migration$zone
cities_dataset <- merge(cities_dataset, worldpop_migration, by = c("ID_HDC_G0"), all.x = TRUE)
cities_dataset$P00_20_CHNG <- cities_dataset$total_pop_perc
cities_dataset$P00_20_MIG_CHNG <- cities_dataset$migration_perc

#Dry/Wet Climate Variable
dry_climate <- c("arid", "tundra", "desert")
pattern <- paste(dry_climate, collapse = "|")
matches <- grepl(pattern, ghs_ucdb$E_KG_NM_LST, ignore.case = TRUE)
matched_data <- ghs_ucdb[matches, ]
ghs_ucdb$LOC_DRY <- ifelse(matches, 1, 0)

#DIST_1M_CITY
cities_1M <- cities_dataset[cities_dataset$P25 > 1000000, ]
nearest_major_city_indices <- st_nearest_feature(cities_dataset, cities_1M)
nearest_major_city_distance <- st_distance(cities_dataset, cities_1M[nearest_major_city_indices,], by_element=TRUE)
cities_1Mt <- cities_1M[,"UC_NM_MN"]
cities_dataset = cbind(cities_dataset, st_drop_geometry(cities_1Mt)[nearest_major_city_indices,])
cities_dataset$DIST_1M_CITY <- nearest_major_city_distance
names(cities_dataset)[names(cities_dataset)== "st_drop_geometry.cities_1Mt..nearest_major_city_indices..."] <- "1M_CITY"
cities_dataset$D_1M <- (cities_dataset$D_1M)/1000

#DIST_500k_CITY
cities_500k <- cities_dataset[cities_dataset$P25 > 500000, ]
nearest_major_city_indices <- st_nearest_feature(cities_dataset, cities_500k)
nearest_major_city_distance <- st_distance(cities_dataset, cities_500k[nearest_major_city_indices,], by_element=TRUE)
cities_500kt <- cities_500k[,"UC_NM_MN"]
cities_dataset = cbind(cities_dataset, st_drop_geometry(cities_500kt)[nearest_major_city_indices,])
cities_dataset$DIST_500k_CITY <- nearest_major_city_distance
names(cities_dataset)[names(cities_dataset)== "st_drop_geometry.cities_500kt..nearest_major_city_indices..."] <- "500k_CITY"
cities_dataset$D_500K <- (cities_dataset$D_500K)/1000

#Elevation
cities_dataset <- cities_dataset %>%
  mutate(LOC_HIGH_LOW = case_when(
    EL_AV_ALS > 1500 ~ "high elevation",
    EL_AV_ALS <= 1500 ~ "low elevation"
  ))

#Define coastal cities
#Use city polygons to do zonal statistics of lecz, no statistics for a city means that there are no lecz pixels in the city
lecz_boundary <- raster("merit_leczs_lt10.tif")
coastal_cities <- exact_extract(lecz_boundary, cities_dataset, 'sum')
cities_dataset$LOC_HIGH_LOW[coastal_cities > 0] <- "coastal"

#Generate LOC_COAST, binary variable for whether a city is coastal or not
cities_dataset_6_28$LOC_COAST <- ifelse(coastal_cities > 0, 1, 0)

#Revise indicators and variable names
cities_dataset <- st_read("cities_dataset_progress_7_11.gpkg")
cities_dataset <- cities_dataset %>%
  select(-RISK)

cities_dataset <- cities_dataset %>%
  rename(P20_25_BIN = P2025_FAST,
         P_AGE_U15 = P_AGE_UND15,
         P_AGE_DEP = P_DEP_RATIO, 
         P00_20 = P00_20_CHNG,
         P00_20_MIG = P00_20_MIG_CHNG,
         D_1M = DIST_1M_CITY,
         D_1M_NM = X1M_CITY,
         D_500K = DIST_500k_CITY,
         D_500K_NM = X500k_CITY,
         L_DRY = LOC_DRY,
         L_COAST = LOC_COAST,
         L_ELEV = LOC_ELEVATION,
         RISK_TEMP_ = RISK_TEMP_SSP2_unclassified, 
         RISK_WBGT_ = RISK_WBGT_SSP2_unclassified, 
         RISK_TEMP = RISK_TEMP_SSP2_SCORE, 
         RISK_WBGT = RISK_WBGT_SSP2_SCORE, 
         RISK_SCAR = RISK_WATER_SSP245, 
         RISK_RIVR_ = future_flood_percent_pop,
         RISK_RIVR = RISK_RIVER, 
         RISK_SURG_ = RISK_SURGE_unclassified)

#Reorder variables
cities_dataset <- cities_dataset %>%
  rename(REG_GHSL = REG_GHSL1)
  select(ID_HDC_G0, UC_NM_MN, UC_NM_LST, CTR_MN_NM, REGION, P15, P20, P25, P20_25, P20_25_CAT, P20_25_BIN, P25_CAT, P25_SMMED, P_AGE_U15, P_AGE_65UP, P_AGE_DEP, GDP15, GDP15_PER, P00_20, P00_20_MIG, D_1M, D_1M_NM, D_500K, D_500K_NM, L_DRY, L_COAST, L_ELEV, RISK_TEMP_, RISK_WBGT_, RISK_TEMP, RISK_WBGT, RISK_SCAR, RISK_RIVR_, RISK_RIVR, RISK_SURG_, RISK_SURGE, RISK_CYCLONE_RP100, RISK_CYCLONE_RP200, RISK_LAND)

cities_dataset_old <- st_read("cities_dataset_progress_7_15.gpkg")
keep3 <- c("ID_HDC_G0", "RISK_CYCLONE_RP100", "RISK_CYCLONE_RP200")
cities_dataset_old <- cities_dataset_old[, keep3]
cities_dataset_old <- st_drop_geometry(cities_dataset_old)
cities_dataset <- merge(cities_dataset, cities_dataset_old, by = c("ID_HDC_G0"), all.x = TRUE)
cities_dataset <- cities_dataset %>%
  rename(RISK_CYC1 = RISK_CYCLONE_RP100, 
         RISK_CYC2 = RISK_CYCLONE_RP200)

#Add column for USAID cities versus not
cities_dataset <- cities_dataset %>% 
  mutate(IN_USAID = ifelse(is.na(REG_USAID), 0, 1))

cities_dataset <- cities_dataset %>%
  select(ID_HDC_G0, UC_NM_MN, UC_NM_LST, CTR_MN_NM, REG_GHSL, REG_USAID, IN_USAID, P15, P20, P25, P20_25, P20_25_CAT, P20_25_BIN, P25_CAT, P25_SMMED, P_AGE_U15, P_AGE_65UP, P_AGE_DEP, GDP15, GDP15_PER, P00_20, P00_20_MIG, D_1M, D_1M_NM, D_500K, D_500K_NM, L_DRY, L_COAST, L_ELEV, RISK_TEMP_, RISK_WBGT_, RISK_TEMP, RISK_WBGT, RISK_SCAR, RISK_RIVR_, RISK_RIVR, RISK_SURG_, RISK_SURG, RISK_CYC1, RISK_CYC2, RISK_LAND)

cities_dataset$GDP15 <- as.integer(cities_dataset$GDP15)

st_write(cities_dataset, "cities_dataset_progress_final.gpkg", driver = "GPKG", append=FALSE)
st_write(cities_dataset, "cities_dataset_final.shp")

