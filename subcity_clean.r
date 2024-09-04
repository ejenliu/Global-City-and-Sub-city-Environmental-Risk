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

#fix cyclone, river, wsdi

cities_dataset <- st_read ("cities_dataset_final.shp")
airpollu5 <- st_read("subcity_airpollu_5.shp")
airpollu10 <- st_read("subcity_airpollu_10.shp")
airpollu15 <- st_read("subcity_airpollu_15_1.shp")
airpollu25 <- st_read("subcity_airpollu_25.shp")
airpollu35 <- st_read("subcity_airpollu_35.shp")
surge <- st_read("surge.shp")
waterscar <- st_read("waterscar.shp")
tmax <- st_read("tmax.shp")
wbgt <- st_read("wbgt.shp")
cyclone <- st_read("Cities_IBTrACS_Y1990p_64Kt_rMSWBuff_Merg_Binary_USA.shp")
wsdi <- st_read("wsdi_intersect.shp")
rivflooding <- st_read("rivflooding.shp")
keep <- c("ID_HDC_G0", "UC_NM_MN", "UC_NM_LST", "CTR_MN_NM", "REG_GHSL", "REG_USAID", "IN_USAID")
cities_dataset <- cities_dataset[, keep]

cities_dataset <- st_make_valid(cities_dataset)

#Join city characterstics to subcity binary polygons
airpollu5 <- airpollu5 %>%
  select(ID_HDC_G0, UC_NM_MN, UC_NM_LST, CTR_MN_NM, REG_GHSL, REG_USAID, IN_USAID, gridcode) %>%
  rename(SUB_AIR = gridcode)
st_write(airpollu5, "subcity_airpollu_5.shp")

airpollu10 <- airpollu10 %>%
  select(ID_HDC_G0, UC_NM_MN, UC_NM_LST, CTR_MN_NM, REG_GHSL, REG_USAID, IN_USAID, gridcode) %>%
  rename(SUB_AIR = gridcode)
st_write(airpollu10, "subcity_airpollu_10.shp")

airpollu15 <- airpollu15 %>%
  select(ID_HDC_G0, UC_NM_MN, UC_NM_LST, CTR_MN_NM, REG_GHSL, REG_USAID, IN_USAID, gridcode) %>%
  rename(SUB_AIR = gridcode)
st_write(airpollu15, "subcity_airpollu_15.shp")

airpollu25 <- airpollu25 %>%
  select(ID_HDC_G0, UC_NM_MN, UC_NM_LST, CTR_MN_NM, REG_GHSL, REG_USAID, IN_USAID, gridcode) %>%
  rename(SUB_AIR = gridcode)
st_write(airpollu25, "subcity_airpollu_25.shp")

airpollu35 <- airpollu35 %>%
  select(ID_HDC_G0, UC_NM_MN, UC_NM_LST, CTR_MN_NM, REG_GHSL, REG_USAID, IN_USAID, gridcode) %>%
  rename(SUB_AIR = gridcode)
st_write(airpollu35, "subcity_airpollu_35.shp")

surge <- surge %>%
  select(ID_HDC_G0, UC_NM_MN, UC_NM_LST, CTR_MN_NM, REG_GHSL, REG_USAID, IN_USAID, gridcode) %>%
  rename(SUB_SURG = gridcode)
st_write(surge, "subcity_surge.shp")

tmax <- tmax %>%
  select(ID_HDC_G0, binary) %>%
  rename(SUB_TEMP = binary)
tmax <- st_drop_geometry(tmax)
tmax <- merge(cities_dataset, tmax, by = c("ID_HDC_G0"), all.x = TRUE)
st_write(tmax, "subcity_heat_tmax.shp")

wbgt <- wbgt %>%
  select(ID_HDC_G0, binary) %>%
  rename(SUB_WBGT = binary)
wbgt <- st_drop_geometry(wbgt)
wbgt <- merge(cities_dataset, wbgt, by = c("ID_HDC_G0"), all.x = TRUE)
st_write(wbgt, "subcity_heat_wbgt.shp")

waterscar <- waterscar %>%
  select("ID_HDC_G0", "WSL_baseli")
waterscar <- merge(cities_dataset, waterscar, by = c("ID_HDC_G0"), all.x = TRUE)
waterscar <- waterscar %>%
  rename(SUB_SCAR = WSL_baseli)
st_write(waterscar, "subcity_waterscar.shp")

cyclone <- st_make_valid(cyclone)
cyclone <- st_join(cyclone, cities_dataset, join = st_intersects)
cyclone <- cyclone %>%
  select(ID_HDC_G0, UC_NM_MN, UC_NM_LST, CTR_MN_NM, REG_GHSL, REG_USAID, IN_USAID, binary) %>%
  rename(SUB_CYC = binary)
st_write(cyclone, "subcity_cyclone.shp")

wsdi <- wsdi %>%
  select(ID_HDC_G0, UC_NM_MN, UC_NM_LST, CTR_MN_NM, REG_GHSL, REG_USAID, IN_USAID, gridcode) %>%
  rename(SUB_WSDI = gridcode)
st_write(wsdi, "subcity_heat_wsdi.shp")

rivflooding <- rivflooding %>%
  select(ID_HDC_G0, UC_NM_MN, UC_NM_LST, CTR_MN_NM, REG_GHSL, REG_USAID, IN_USAID, gridcode) %>%
  rename(SUB_RIV = gridcode)
st_write(rivflooding, "subcity_rivflooding.shp")

