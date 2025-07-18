# Packages ----------------------------------------------------------------
# Spatial data
library(gdalcubes) # raster cubes
library(sf)        # vector
library(terra)     # raster
# Data manipulation and more.
library(magrittr)

# Reference period.  ----------------------------------------------------------------
paths <- list.files(path = "data/work/reference/modis/P13Y", pattern = "MODIS", full.names = TRUE)

months <- 5:9
cube <- stack_cube(paths, datetime_values = paste0("2000-0", months))

ndvi <- apply_pixel(cube, "(x2 - x1) / (x2 + x1)", "NDVI")
evi  <- apply_pixel(cube, "(2.5 * (x2 - x1) / (x2 + 6 * x1 - 7.5 * x3 + 1))", "EVI")
nirv <- apply_pixel(cube, "((x2 - x1) / (x2 + x1)) * x2", "NIRv")

out <- "data/work/reference/indices/"

write_tif((ndvi), dir = out, prefix = 'NDVI_')
write_tif((evi), dir = out, prefix = 'EVI_')
write_tif((nirv), dir = out, prefix = 'NIRv_')

# Study period.  ----------------------------------------------------------------

paths <- list.files(path = "data/work/study/P1M", pattern = "MODIS", full.names = TRUE)

months <- 5:9
years <- 2013:2017

datetime_values <- as.vector(sapply(years, function(y) sprintf("%d-%02d-01", y, months)))

cube  <- stack_cube(paths, datetime_values = datetime_values)

ndvi <- apply_pixel(cube, "(x2 - x1) / (x2 + x1)", "NDVI")
evi  <- apply_pixel(cube, "(2.5 * (x2 - x1) / (x2 + 6 * x1 - 7.5 * x3 + 1))", "EVI")
nirv <- apply_pixel(cube, "((x2 - x1) / (x2 + x1)) * x2", "NIRv")

out <- "data/work/study/indices/"

write_tif((ndvi), dir = out, prefix = 'NDVI_')
write_tif((evi),  dir = out, prefix = 'EVI_')
write_tif((nirv), dir = out, prefix = 'NIRv_')
