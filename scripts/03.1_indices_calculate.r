# ==============================================================================
# SCRIPT: Calculate Vegetation Indices
# PURPOSE: Calculate NDVI, EVI, and NIRv from MODIS reflectance data
#          for both reference and study periods
# AUTHOR: Matthias Lerch
# DATE: [25.01.2026]
# ==============================================================================

# 00 LOAD REQUIRED PACKAGES -----------------------------------------------

# Spatial data processing
library(gdalcubes)   # Processing raster data cubes
library(sf)          # Simple features for vector data
library(terra)       # Spatial raster data analysis

# Data manipulation
library(magrittr)    # Pipe operators for data processing

# ==============================================================================
# PART 01: REFERENCE PERIOD VEGETATION INDICES
# ==============================================================================

# 01 LOAD REFERENCE PERIOD REFLECTANCE DATA -------------------------------

# Get paths to reference period MODIS reflectance data (p13y = 13-year averages)
paths <- list.files(path = "data/work/reference/nbar/p13y/", pattern = "NBAR", full.names = TRUE)

# Define months for growing season analysis
months <- 5:9                                               # May through September

# Create data cube from reference period files
cube <- stack_cube(paths, datetime_values = paste0("2000-0", months))

# 02 CALCULATE VEGETATION INDICES FOR REFERENCE PERIOD --------------------

# Calculate NDVI (Normalized Difference Vegetation Index)
# Formula: (NIR - Red) / (NIR + Red)
# x1 = Red band, x2 = NIR band
ndvi <- apply_pixel(cube, "(x2 - x1) / (x2 + x1)", "NDVI")

# Calculate EVI (Enhanced Vegetation Index)
# Formula: 2.5 * (NIR - Red) / (NIR + 6*Red - 7.5*Blue + 1)
# x1 = Red band, x2 = NIR band, x3 = Blue band
evi <- apply_pixel(cube, "(2.5 * (x2 - x1) / (x2 + 6 * x1 - 7.5 * x3 + 1))", "EVI")

# Calculate NIRv (Near-Infrared Reflectance of Vegetation)
# Formula: NDVI * NIR
# Combined: ((NIR - Red) / (NIR + Red)) * NIR
nirv <- apply_pixel(cube, "((x2 - x1) / (x2 + x1)) * x2", "NIRv")

# 03 SAVE REFERENCE PERIOD INDICES ----------------------------------------

# Define output directory
out <- "data/work/reference/indices/"

# Save vegetation indices as GeoTIFF files
write_tif(ndvi, dir = out, prefix = 'NDVI_')                # NDVI reference
write_tif(evi,  dir = out, prefix = 'EVI_')                 # EVI reference
write_tif(nirv, dir = out, prefix = 'NIRv_')                # NIRv reference

# ==============================================================================
# PART 02: STUDY PERIOD VEGETATION INDICES
# ==============================================================================

# 04 LOAD STUDY PERIOD REFLECTANCE DATA -----------------------------------

# Get paths to study period MODIS reflectance data
paths <- list.files(path = "data/work/study/nbar/", pattern = "NBAR", full.names = TRUE)

# Define temporal parameters for study period
months <- 5:9                                               # May through September
years <- 2013:2017                                          # Study period years

# Create datetime values for all months in study period
# Format: YYYY-MM-DD for each month-year combination
datetime_values <- as.vector(sapply(years, function(y) sprintf("%d-%02d-01", y, months)))

# Create data cube from study period files
cube <- stack_cube(paths, datetime_values = datetime_values)

# 05 CALCULATE VEGETATION INDICES FOR STUDY PERIOD -----------------------

# Calculate same vegetation indices as reference period
# NDVI: Normalized Difference Vegetation Index
ndvi <- apply_pixel(cube, "(x2 - x1) / (x2 + x1)", "NDVI")

# EVI: Enhanced Vegetation Index  
evi <- apply_pixel(cube, "(2.5 * (x2 - x1) / (x2 + 6 * x1 - 7.5 * x3 + 1))", "EVI")

# NIRv: Near-Infrared Reflectance of Vegetation
nirv <- apply_pixel(cube, "((x2 - x1) / (x2 + x1)) * x2", "NIRv")

# 06 SAVE STUDY PERIOD INDICES --------------------------------------------

# Define output directory for study period indices
out <- "data/work/study/indices/"

# Save vegetation indices as GeoTIFF files
write_tif(ndvi, dir = out, prefix = 'NDVI_')                # NDVI study period
write_tif(evi,  dir = out, prefix = 'EVI_')                 # EVI study period
write_tif(nirv, dir = out, prefix = 'NIRv_')                # NIRv study period