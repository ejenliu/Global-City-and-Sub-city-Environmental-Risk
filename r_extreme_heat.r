new_library_path <- "G:/CASA/ejen/CustomR"
.libPaths(c(new_library_path, .libPaths()))

#Install and load packages
install.packages("dplyr")
install.packages("sf")
install.packages("ncdf4")
install.packages("purrr")
install.packages("raster")
install.packages("rasterVis")
install.packages("lattice")
install.packages("raster")
install.packages("ggplot2")

library(dplyr)
library(sf)
library(ncdf4)
library(purrr)
library(raster)
library(rasterVis)
library(lattice)
library(raster)
library(ggplot2)

cities_dataset <- st_read("cities_dataset_progress_7_18.gpkg")

#WSDI from BEST dataset
#Open netcdf file and transform into raster
wsdi = ncdf4::nc_open("BEST (Berkeley Earth Surface Temperature) 1880-2021_WSDI_ANN_AverageMap_2010-2021_-84to84_-180to180.nc")
names(wsdi$var)
input_nc = "G:/CASA/data/BEST (Berkeley Earth Surface Temperature) 1880-2021_WSDI_ANN_AverageMap_2010-2021_-84to84_-180to180.nc"
varname = 'index_avg'
raster_wsdi = raster(input_nc,varname = varname,band = 1)
output = "G:/CASA/output_rasters/wsdi_unprocessed.tif"
writeRaster(raster_wsdi,output,format = 'GTiff',overwrite = TRUE)

#Explore data and raster distribution
values <- getValues(raster_wsdi)
hist(values, breaks = "Sturges", main = "Histogram of Raster Values", xlab = "Pixel Values")

#Create binary map

#1 month threshold (30 days)
rcl_matrix <- matrix(c(-Inf, 30, 0, 30, Inf, 1), ncol=3, byrow=TRUE)
binary_map_30 <- reclassify(raster_wsdi, rcl = rcl_matrix)
output = "G:/CASA/ejen/Recent Extreme Heat/subcity_wsdi_binary.tif"
writeRaster(binary_map_30,output,format = 'GTiff',overwrite = TRUE)

#WBGT and Max Air Temp from CHC-CMIP6
tmax_45 <- st_read("Tmax45_avg_counts_07-16.shp")
wbgtmax_30 <- st_read("wbgtmax30_avg_counts_07-16.shp")

#Check distribution
obs_values <- tmax_45$obs
obs_values_tmax <- tmax_45$obs[tmax_45$obs != 0]
data <- data.frame(obs = obs_values)
ggplot(data, aes(x = obs)) +
  geom_histogram(binwidth = 1, fill = "skyblue", color = "black") +
  labs(title = "Histogram of Variable 'obs' in tmax_45",
       x = "Value of 'obs'",
       y = "Frequency") +
  theme_minimal()

obs_values <- wbgtmax_30$obs
obs_values_wbgt <- wbgtmax_30$obs[wbgtmax_30$obs != 0]
data <- data.frame(obs = obs_values)
ggplot(data, aes(x = obs)) +
  geom_histogram(binwidth = 1, fill = "skyblue", color = "black") +
  labs(title = "Histogram of Variable 'obs' in wbgtmax_30",
       x = "Value of 'obs'",
       y = "Frequency") +
  theme_minimal()

#Boxplot to compare distributions
tmax_45$source <- "tmax_45"
wbgtmax_30$source <- "wbgtmax_30"

# Combine the data frames
combined_data <- rbind(tmax_45, wbgtmax_30)

ggplot(combined_data, aes(x = source, y = obs, fill = source)) +
  geom_boxplot() +
  labs(x = "Source", y = "obs Distribution",
       title = "Boxplot of obs Distribution by Source")


obs_quantiles <- quantile(tmax_45$obs_values_tmax, probs = 0.90, na.rm=TRUE)
cat("90th percentile value for 'obs':", obs_quantiles, "\n")

obs_quantiles <- quantile(wbgtmax_30$obs_values_wbgt, probs = 0.90, na.rm=TRUE)
cat("90th percentile value for 'obs':", obs_quantiles, "\n")

Q1 <- quantile(obs_values_tmax, 0.25, na.rm = TRUE)
Q3 <- quantile(obs_values_tmax, 0.75, na.rm = TRUE)
IQR <- Q3 - Q1
upper_bound <- Q3 + 1.5 * IQR
cat("IQR:", IQR, "\n")
cat("Upper Bound:", upper_bound, "\n")
cat("Q1:", Q1, "\n")
cat("Q3:", Q3, "\n")


Q1 <- quantile(obs_values_wbgt, 0.25, na.rm = TRUE)
Q3 <- quantile(obs_values_wbgt, 0.75, na.rm = TRUE)
IQR <- Q3 - Q1
upper_bound <- Q3 + 1.5 * IQR
cat("IQR:", IQR, "\n")
cat("Upper Bound:", upper_bound, "\n")
cat("Q1:", Q1, "\n")
cat("Q3:", Q3, "\n")


#Create binary files
#Threshold = 30 days
tmax_45$binary <- ifelse(tmax_45$obs > 30, 1, 0)
tmax_45 <- tmax_45 %>%
  select(ID_HDC_G0, obs, binary)

wbgtmax_30$binary <- ifelse(wbgtmax_30$obs > 30, 1, 0)
wbgtmax_30 <- wbgtmax_30 %>%
  select(ID_HDC_G0, obs, binary)

st_write(tmax_45, "recent_tmax_45_final.gpkg", driver = "GPKG", append=FALSE)
st_write(wbgtmax_30, "recent_wbgtmax_30_final.gpkg", driver = "GPKG", append=FALSE)
