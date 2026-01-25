# ==============================================================================
# SCRIPT: Aggregate Reference Period Data
# PURPOSE: Aggregate monthly MODIS NBAR and LAI data from reference period
#          to create long-term monthly averages (P13Y = 13-year period)
# AUTHOR: Matthias Lerch
# DATE: [25.01.2026]
# ==============================================================================

# 00 LOAD REQUIRED PACKAGES -----------------------------------------------

# Spatial data processing
library(gdalcubes)   # Processing raster data cubes

# ==============================================================================
# PART 01: MODIS NBAR REFERENCE AGGREGATION
# ==============================================================================

# 01 LOAD AND ORGANIZE MONTHLY DATA ---------------------------------------
# Set path to NBAR data
path = "data/work/reference/nbar/p1m/"

# Get file paths for each month across all reference years
paths_05 <- list.files(path = path, pattern = "-05-", full.names = TRUE)
paths_06 <- list.files(path = path, pattern = "-06-", full.names = TRUE)
paths_07 <- list.files(path = path, pattern = "-07-", full.names = TRUE)
paths_08 <- list.files(path = path, pattern = "-08-", full.names = TRUE)
paths_09 <- list.files(path = path, pattern = "-09-", full.names = TRUE)

# 02 CREATE MONTHLY STACKS ------------------------------------------------
# Stack rasters from same month across all years (2000-2012)

# Create datetime labels for each year in reference period
years <- 2000:2012

# Stack cubes by month (one cube per month containing all years)
cube_05 <- stack_cube(paths_05, datetime_values = paste0(years, "-05"))
cube_06 <- stack_cube(paths_06, datetime_values = paste0(years, "-06"))
cube_07 <- stack_cube(paths_07, datetime_values = paste0(years, "-07"))
cube_08 <- stack_cube(paths_08, datetime_values = paste0(years, "-08"))
cube_09 <- stack_cube(paths_09, datetime_values = paste0(years, "-09"))

# 03 CALCULATE LONG-TERM MONTHLY AVERAGES ---------------------------------
# Reduce temporal dimension by calculating mean across all years

# Calculate mean values for each band across all years
cube_05_P13Y <- reduce_time(cube_05, "mean(x1)", "mean(x2)", "mean(x3)")  # May average
cube_06_P13Y <- reduce_time(cube_06, "mean(x1)", "mean(x2)", "mean(x3)")  # June average
cube_07_P13Y <- reduce_time(cube_07, "mean(x1)", "mean(x2)", "mean(x3)")  # July average
cube_08_P13Y <- reduce_time(cube_08, "mean(x1)", "mean(x2)", "mean(x3)")  # August average
cube_09_P13Y <- reduce_time(cube_09, "mean(x1)", "mean(x2)", "mean(x3)")  # September average

# 04 SAVE REFERENCE PERIOD AVERAGES ---------------------------------------

# Define output parameters
prefix <- "NBAR_"                                          # File prefix
dir <- "data/work/reference/nbar/p13y/test/"               # Output directory

# Save long-term monthly averages
write_tif(cube_05_P13Y, dir = dir, prefix = prefix)        # May reference
write_tif(cube_06_P13Y, dir = dir, prefix = prefix)        # June reference
write_tif(cube_07_P13Y, dir = dir, prefix = prefix)        # July reference
write_tif(cube_08_P13Y, dir = dir, prefix = prefix)        # August reference
write_tif(cube_09_P13Y, dir = dir, prefix = prefix)        # September reference

# ==============================================================================
# PART 02: MODIS LAI REFERENCE AGGREGATION
# ==============================================================================

# 05 LOAD AND ORGANIZE LAI MONTHLY DATA ----------------------------------

# Set path to LAI data
path = "data/work/reference/lai/p1m/"

# Get file paths for each month across all LAI reference years
paths_05 <- list.files(path = path, pattern = "-05-", full.names = TRUE)
paths_06 <- list.files(path = path, pattern = "-06-", full.names = TRUE)
paths_07 <- list.files(path = path, pattern = "-07-", full.names = TRUE)
paths_08 <- list.files(path = path, pattern = "-08-", full.names = TRUE)
paths_09 <- list.files(path = path, pattern = "-09-", full.names = TRUE)

# Define LAI reference period (2003-2012, 10 years)
years <- 2000:2012

# 06 CREATE LAI MONTHLY STACKS --------------------------------------------

# Stack LAI cubes by month (one cube per month containing all years)
cube_05 <- stack_cube(paths_05, datetime_values = paste0(years, "-05"))
cube_06 <- stack_cube(paths_06, datetime_values = paste0(years, "-06"))
cube_07 <- stack_cube(paths_07, datetime_values = paste0(years, "-07"))
cube_08 <- stack_cube(paths_08, datetime_values = paste0(years, "-08"))
cube_09 <- stack_cube(paths_09, datetime_values = paste0(years, "-09"))

# 07 CALCULATE LAI LONG-TERM MONTHLY AVERAGES -----------------------------

# Reduce temporal dimension by calculating mean LAI across all years
cube_05_P13Y <- reduce_time(cube_05, "mean(x1)")           # May LAI average
cube_06_P13Y <- reduce_time(cube_06, "mean(x1)")           # June LAI average
cube_07_P13Y <- reduce_time(cube_07, "mean(x1)")           # July LAI average
cube_08_P13Y <- reduce_time(cube_08, "mean(x1)")           # August LAI average
cube_09_P13Y <- reduce_time(cube_09, "mean(x1)")           # September LAI average

# 08 SAVE LAI REFERENCE PERIOD AVERAGES -----------------------------------

# Define output parameters for LAI
prefix <- "LAI_"                                            # File prefix
dir <- "data/work/reference/lai/p13y/"                      # Output directory

# Save LAI long-term monthly averages
write_tif(cube_05_P13Y, dir = dir, prefix = prefix)        # May LAI reference
write_tif(cube_06_P13Y, dir = dir, prefix = prefix)        # June LAI reference
write_tif(cube_07_P13Y, dir = dir, prefix = prefix)        # July LAI reference
write_tif(cube_08_P13Y, dir = dir, prefix = prefix)        # August LAI reference
write_tif(cube_09_P13Y, dir = dir, prefix = prefix)        # September LAI reference