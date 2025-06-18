# Aggregate the P1M reference pictures to P13Y (one picute for each month over the whole reference period).

# Spatial data
library(gdalcubes)   # raster cubes

# Get the paths.
paths_05 <- list.files(path = "data/work/reference/lai/P1M", pattern = "-05-", full.names = TRUE)
paths_06 <- list.files(path = "data/work/reference/lai/P1M", pattern = "-06-", full.names = TRUE)
paths_07 <- list.files(path = "data/work/reference/lai/P1M", pattern = "-07-", full.names = TRUE)
paths_08 <- list.files(path = "data/work/reference/lai/P1M", pattern = "-08-", full.names = TRUE)
paths_09 <- list.files(path = "data/work/reference/lai/P1M", pattern = "-09-", full.names = TRUE)


years <- 2003:2012
test <- 

# Stack the cubes, one cubes for each month over the whole reference period.
cube_05 <- stack_cube(paths_05, datetime_values = paste0(years, "-05"))
cube_06 <- stack_cube(paths_06, datetime_values = paste0(years, "-06"))
cube_07 <- stack_cube(paths_07, datetime_values = paste0(years, "-07"))
cube_08 <- stack_cube(paths_08, datetime_values = paste0(years, "-08"))
cube_09 <- stack_cube(paths_09, datetime_values = paste0(years, "-09"))

# Reduce the time.
cube_05_P13Y <- reduce_time(cube_05, "mean(x1)", "mean(x2)", "mean(x3)")
cube_06_P13Y <- reduce_time(cube_06, "mean(x1)", "mean(x2)", "mean(x3)")
cube_07_P13Y <- reduce_time(cube_07, "mean(x1)", "mean(x2)", "mean(x3)")
cube_08_P13Y <- reduce_time(cube_08, "mean(x1)", "mean(x2)", "mean(x3)")
cube_09_P13Y <- reduce_time(cube_09, "mean(x1)", "mean(x2)", "mean(x3)")

# Save the pictures.
prefix <-  "LAI_"
dir <- "data/work/reference/lai/P13Y/"

write_tif(cube_05_P13Y, dir = dir, prefix = prefix)
write_tif(cube_06_P13Y, dir = dir, prefix = prefix)
write_tif(cube_07_P13Y, dir = dir, prefix = prefix)
write_tif(cube_08_P13Y, dir = dir, prefix = prefix)
write_tif(cube_09_P13Y, dir = dir, prefix = prefix)
