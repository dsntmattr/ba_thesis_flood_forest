# Aggregate the P1M reference data (MODIS NBAR and MODIS LAI) to P13Y (one picture for each month over the whole reference period).

# Packages. ---------------------------------------------------------------
# Spatial data
library(gdalcubes)   # raster cubes

# MODIS NBAR --------------------------------------------------------------

# Get the paths.
paths_05 <- list.files(path = "data/work/reference/P1M", pattern = "-05-", full.names = TRUE)
paths_06 <- list.files(path = "data/work/reference/P1M", pattern = "-06-", full.names = TRUE)
paths_07 <- list.files(path = "data/work/reference/P1M", pattern = "-07-", full.names = TRUE)
paths_08 <- list.files(path = "data/work/reference/P1M", pattern = "-08-", full.names = TRUE)
paths_09 <- list.files(path = "data/work/reference/P1M", pattern = "-09-", full.names = TRUE)

# Stack the cubes, one cubes for each month over the whole reference period.
cube_05 <- stack_cube(paths_05, datetime_values = c("2000-05", "2001-05", "2002-05", "2003-05", "2004-05", "2005-05", "2006-05", "2007-05", "2008-05", "2009-05","2010-05", "2011-05", "2012-05"))
cube_06 <- stack_cube(paths_06, datetime_values = c("2000-06", "2001-06", "2002-06", "2003-06", "2004-06", "2005-06", "2006-06", "2007-06", "2008-06", "2009-06","2010-06", "2011-06", "2012-06"))
cube_07 <- stack_cube(paths_07, datetime_values = c("2000-07", "2001-07", "2002-07", "2003-07", "2004-07", "2005-07", "2006-07", "2007-07", "2008-07", "2009-07","2010-07", "2011-07", "2012-07"))
cube_08 <- stack_cube(paths_08, datetime_values = c("2000-08", "2001-08", "2002-08", "2003-08", "2004-08", "2005-08", "2006-08", "2007-08", "2008-08", "2009-08","2010-08", "2011-08", "2012-08"))
cube_09 <- stack_cube(paths_09, datetime_values = c("2000-09", "2001-09", "2002-09", "2003-09", "2004-09", "2005-09", "2006-09", "2007-09", "2008-09", "2009-09","2010-09", "2011-09", "2012-09"))

# Reduce the time.
cube_05_P13Y <- reduce_time(cube_05, "mean(x1)", "mean(x2)", "mean(x3)")
cube_06_P13Y <- reduce_time(cube_06, "mean(x1)", "mean(x2)", "mean(x3)")
cube_07_P13Y <- reduce_time(cube_07, "mean(x1)", "mean(x2)", "mean(x3)")
cube_08_P13Y <- reduce_time(cube_08, "mean(x1)", "mean(x2)", "mean(x3)")
cube_09_P13Y <- reduce_time(cube_09, "mean(x1)", "mean(x2)", "mean(x3)")

# Save the pictures.
prefix <-  "MODIS_"
dir <- "data/work/reference/P13Y/"

write_tif(cube_05_P13Y, dir = dir, prefix = prefix)
write_tif(cube_06_P13Y, dir = dir, prefix = prefix)
write_tif(cube_07_P13Y, dir = dir, prefix = prefix)
write_tif(cube_08_P13Y, dir = dir, prefix = prefix)
write_tif(cube_09_P13Y, dir = dir, prefix = prefix)

# MODIS LAI ---------------------------------------------------------------

# Get the paths.
path = "data/work/reference/lai/no_qa/p1m"

paths_05 <- list.files(path = path, pattern = "-05-", full.names = TRUE)
paths_06 <- list.files(path = path, pattern = "-06-", full.names = TRUE)
paths_07 <- list.files(path = path, pattern = "-07-", full.names = TRUE)
paths_08 <- list.files(path = path, pattern = "-08-", full.names = TRUE)
paths_09 <- list.files(path = path, pattern = "-09-", full.names = TRUE)

years <- 2003:2012

# Stack the cubes, one cubes for each month over the whole reference period.
cube_05 <- stack_cube(paths_05, datetime_values = paste0(years, "-05"))
cube_06 <- stack_cube(paths_06, datetime_values = paste0(years, "-06"))
cube_07 <- stack_cube(paths_07, datetime_values = paste0(years, "-07"))
cube_08 <- stack_cube(paths_08, datetime_values = paste0(years, "-08"))
cube_09 <- stack_cube(paths_09, datetime_values = paste0(years, "-09"))

# Reduce the time.
cube_05_P13Y <- reduce_time(cube_05, "mean(x1)")
cube_06_P13Y <- reduce_time(cube_06, "mean(x1)")
cube_07_P13Y <- reduce_time(cube_07, "mean(x1)")
cube_08_P13Y <- reduce_time(cube_08, "mean(x1)")
cube_09_P13Y <- reduce_time(cube_09, "mean(x1)")

# Save the pictures.
prefix <-  "LAI_"
dir <- "data/work/reference/lai/no_qa/p13y/"

write_tif(cube_05_P13Y, dir = dir, prefix = prefix)
write_tif(cube_06_P13Y, dir = dir, prefix = prefix)
write_tif(cube_07_P13Y, dir = dir, prefix = prefix)
write_tif(cube_08_P13Y, dir = dir, prefix = prefix)
write_tif(cube_09_P13Y, dir = dir, prefix = prefix)
