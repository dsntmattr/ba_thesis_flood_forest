# Packages ----------------------------------------------------------------
# Spatial data
library(gdalcubes) # raster cubes
library(sf)        # vector
library(terra)     # raster
# Data manipulation and more.
library(magrittr)

# Reference period.  ----------------------------------------------------------------
paths <- list.files(path = "data/work/reference/P13Y", pattern = "MODIS", full.names = TRUE)

cube <- stack_cube(paths, datetime_values = c("2000-05", "2000-06", "2000-07", "2000-08", "2000-09"))

ndvi <- apply_pixel(cube, "(x2 - x1) / (x2 + x1)", "NDVI")
evi  <- apply_pixel(cube, "(2.5 * (x2 - x1) / (x2 + 6 * x1 - 7.5 * x3 + 1))", "EVI")
nirv <- apply_pixel(cube, "((x2 - x1) / (x2 + x1)) * x2", "NIRv")

out <- "data/work/reference/indices/"

write_tif((ndvi), dir = out, prefix = 'NDVI_')
write_tif((evi), dir = out, prefix = 'EVI_')
write_tif((nirv), dir = out, prefix = 'NIRv_')

# Study period.  ----------------------------------------------------------------

paths <- list.files(path = "data/work/study/P1M", pattern = "MODIS", full.names = TRUE)
cube  <- stack_cube(paths, datetime_values = c("2013-05", "2013-06", "2013-07", "2013-08", "2013-09",
                                               "2014-05", "2014-06", "2014-07", "2014-08", "2014-09",
                                               "2015-05", "2015-06", "2015-07", "2015-08", "2015-09",
                                               "2016-05", "2016-06", "2016-07", "2016-08", "2016-09",
                                               "2017-05", "2017-06", "2017-07", "2017-08", "2017-09"))

ndvi <- apply_pixel(cube, "(x2 - x1) / (x2 + x1)", "NDVI")
evi  <- apply_pixel(cube, "(2.5 * (x2 - x1) / (x2 + 6 * x1 - 7.5 * x3 + 1))", "EVI")
nirv <- apply_pixel(cube, "((x2 - x1) / (x2 + x1)) * x2", "NIRv")

out <- "data/work/study/indices/"

write_tif((ndvi), dir = out, prefix = 'NDVI_')
write_tif((evi),  dir = out, prefix = 'EVI_')
write_tif((nirv), dir = out, prefix = 'NIRv_')
