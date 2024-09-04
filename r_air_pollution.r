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

library(dplyr)
library(sf)
library(ncdf4)
library(purrr)
library(raster)
library(rasterVis)
library(lattice)

#Open netcdf files and transform into rasters
#2012
pollution_2012 = ncdf4::nc_open("V5GL04.HybridPM25.Global.201201-201212.nc")
names(pollution_2012$var)
input_nc = "G:/CASA/data/ACAG GWRPM25/V5GL04.HybridPM25.Global.201201-201212.nc"
varname = 'GWRPM25'
raster_2012 = raster(input_nc,varname = varname,band = 1)
output = "G:/CASA/output_rasters/pm2.5_rasters_annual/2012.tif"
writeRaster(raster_2012,output,format = 'GTiff',overwrite = TRUE)
nc_close(pollution_2012)

#2013
pollution_2013 = ncdf4::nc_open("V5GL04.HybridPM25.Global.201301-201312.nc")
input_nc = "G:/CASA/data/ACAG GWRPM25/V5GL04.HybridPM25.Global.201301-201312.nc"
varname = 'GWRPM25'
raster_2013 = raster(input_nc,varname = varname,band = 1)
output = "G:/CASA/output_rasters/pm2.5_rasters_annual/2013.tif"
writeRaster(raster_2013,output,format = 'GTiff',overwrite = TRUE)
nc_close(pollution_2013)

#2014
pollution_2014 = ncdf4::nc_open("V5GL04.HybridPM25.Global.201401-201412.nc")
input_nc = "G:/CASA/data/ACAG GWRPM25/V5GL04.HybridPM25.Global.201401-201412.nc"
varname = 'GWRPM25'
raster_2014 = raster(input_nc,varname = varname,band = 1)
output = "G:/CASA/output_rasters/pm2.5_rasters_annual/2014.tif"
writeRaster(raster_2014,output,format = 'GTiff',overwrite = TRUE)
nc_close(pollution_2014)

#2015
pollution_2015 = ncdf4::nc_open("V5GL04.HybridPM25.Global.201501-201512.nc")
input_nc = "G:/CASA/data/ACAG GWRPM25/V5GL04.HybridPM25.Global.201501-201512.nc"
varname = 'GWRPM25'
raster_2015 = raster(input_nc,varname = varname,band = 1)
output = "G:/CASA/output_rasters/pm2.5_rasters_annual/2015.tif"
writeRaster(raster_2015,output,format = 'GTiff',overwrite = TRUE)
nc_close(pollution_2015)

#2016
pollution_2016 = ncdf4::nc_open("V5GL04.HybridPM25.Global.201601-201612.nc")
input_nc = "G:/CASA/data/ACAG GWRPM25/V5GL04.HybridPM25.Global.201601-201612.nc"
varname = 'GWRPM25'
raster_2016 = raster(input_nc,varname = varname,band = 1)
output = "G:/CASA/output_rasters/pm2.5_rasters_annual/2016.tif"
writeRaster(raster_2016,output,format = 'GTiff',overwrite = TRUE)
nc_close(pollution_2016)

#2017
pollution_2017 = ncdf4::nc_open("V5GL04.HybridPM25.Global.201701-201712.nc")
input_nc = "G:/CASA/data/ACAG GWRPM25/V5GL04.HybridPM25.Global.201701-201712.nc"
varname = 'GWRPM25'
raster_2017 = raster(input_nc,varname = varname,band = 1)
output = "G:/CASA/output_rasters/pm2.5_rasters_annual/2017.tif"
writeRaster(raster_2017,output,format = 'GTiff',overwrite = TRUE)
nc_close(pollution_2017)

#2018
pollution_2018 = ncdf4::nc_open("V5GL04.HybridPM25.Global.201801-201812.nc")
input_nc = "G:/CASA/data/ACAG GWRPM25/V5GL04.HybridPM25.Global.201801-201812.nc"
varname = 'GWRPM25'
raster_2018 = raster(input_nc,varname = varname,band = 1)
output = "G:/CASA/output_rasters/pm2.5_rasters_annual/2018.tif"
writeRaster(raster_2018,output,format = 'GTiff',overwrite = TRUE)
nc_close(pollution_2018)

#2019
pollution_2019 = ncdf4::nc_open("V5GL04.HybridPM25.Global.201901-201912.nc")
input_nc = "G:/CASA/data/ACAG GWRPM25/V5GL04.HybridPM25.Global.201901-201912.nc"
varname = 'GWRPM25'
raster_2019 = raster(input_nc,varname = varname,band = 1)
output = "G:/CASA/output_rasters/pm2.5_rasters_annual/2019.tif"
writeRaster(raster_2019,output,format = 'GTiff',overwrite = TRUE)
nc_close(pollution_2019)

#2020
pollution_2020 = ncdf4::nc_open("V5GL04.HybridPM25.Global.202001-202012.nc")
input_nc = "G:/CASA/data/ACAG GWRPM25/V5GL04.HybridPM25.Global.202001-202012.nc"
varname = 'GWRPM25'
raster_2020 = raster(input_nc,varname = varname,band = 1)
output = "G:/CASA/output_rasters/pm2.5_rasters_annual/2020.tif"
writeRaster(raster_2020,output,format = 'GTiff',overwrite = TRUE)
nc_close(pollution_2020)

#2021
pollution_2021 = ncdf4::nc_open("V5GL04.HybridPM25.Global.202101-202112.nc")
input_nc = "G:/CASA/data/ACAG GWRPM25/V5GL04.HybridPM25.Global.202101-202112.nc"
varname = 'GWRPM25'
raster_2021 = raster(input_nc,varname = varname,band = 1)
output = "G:/CASA/output_rasters/pm2.5_rasters_annual/2021.tif"
writeRaster(raster_2021,output,format = 'GTiff',overwrite = TRUE)
nc_close(pollution_2021)

#2022
pollution_2022 = ncdf4::nc_open("V5GL04.HybridPM25.Global.202201-202212.nc")
input_nc = "G:/CASA/data/ACAG GWRPM25/V5GL04.HybridPM25.Global.202201-202212.nc"
varname = 'GWRPM25'
raster_2022 = raster(input_nc,varname = varname,band = 1)
output = "G:/CASA/output_rasters/pm2.5_rasters_annual/2022.tif"
writeRaster(raster_2022,output,format = 'GTiff',overwrite = TRUE)
nc_close(pollution_2022)




