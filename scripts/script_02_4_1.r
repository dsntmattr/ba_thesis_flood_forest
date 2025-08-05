# ==============================================================================
# SCRIPT: Calculate Mean Differences - Local Level Analysis
# PURPOSE: Create dataframes with time series values comparing study period
#          to reference period at local forest loss sites
# AUTHOR: [Your Name]
# DATE: [Current Date]
# ==============================================================================

# 00 LOAD REQUIRED PACKAGES -----------------------------------------------

# Spatial data processing
library(gdalcubes)   # Processing raster data cubes
library(sf)          # Simple features for vector data
library(terra)       # Spatial raster data analysis

# Data manipulation
library(dplyr)       # Data manipulation and transformation
library(gdata)       # Additional data manipulation tools
library(tidyr)       # Data tidying and reshaping

# 01 LOAD AND PREPARE VECTOR DATA -----------------------------------------

# Load forest loss polygon data for local analysis
sf <- st_read("data/raw/forest_loss/forest_loss.shp")

# Transform to Sinusoidal projection (MODIS native projection)
sf <- st_transform(sf, "+proj=sinu +lon_0=0 +x_0=0 +y_0=0 +R=6371007.181 +units=m +no_defs")

# ==============================================================================
# PART 01: REFERENCE PERIOD DATA PROCESSING
# ==============================================================================

# 02 LOAD REFERENCE PERIOD INDEX DATA -------------------------------------

# Define path to reference period vegetation indices
path = "data/work/reference/indices/"

# Get file paths for each vegetation index
paths_ndvi <- list.files(path = path, pattern = "NDVI_", full.names = TRUE)
paths_evi  <- list.files(path = path, pattern = "EVI_",  full.names = TRUE)
paths_nirv <- list.files(path = path, pattern = "NIRv_", full.names = TRUE)

# Get LAI reference data path
paths_lai <- list.files(path = "data/work/reference/lai/qa1/P13Y", pattern = "LAI", full.names = TRUE)

# 03 CREATE REFERENCE PERIOD DATA CUBES -----------------------------------

# Define months for growing season
months <- 5:9                                               # May through September

# Stack reference period rasters into cubes (one cube per index)
cube_ndvi <- stack_cube(paths_ndvi, datetime_values = paste0("2000-0", months))
cube_evi  <- stack_cube(paths_evi,  datetime_values = paste0("2000-0", months))
cube_nirv <- stack_cube(paths_nirv, datetime_values = paste0("2000-0", months))
cube_lai  <- stack_cube(paths_lai,  datetime_values = paste0("2003-0", months))

# 04 EXTRACT REFERENCE VALUES AT FOREST LOSS SITES -----------------------

# Extract mean values for each month over reference period
# Only for cells whose centers overlap with forest loss polygons

ref_ndvi_means <- extract_geom(cube_ndvi, sf, FUN = mean) %>% 
  rename(NDVI = x1)                                         # Rename column for clarity

ref_evi_means <- extract_geom(cube_evi, sf, FUN = mean) %>% 
  rename(EVI = x1)                                          # Rename column for clarity

ref_nirv_means <- extract_geom(cube_nirv, sf, FUN = mean) %>% 
  rename(NIRv = x1)                                         # Rename column for clarity

ref_lai_means <- extract_geom(cube_lai, sf, FUN = mean) %>% 
  rename(LAI = x1)                                          # Rename column for clarity

# 05 PROCESS REFERENCE PERIOD DATA ----------------------------------------

# Add month column to each dataframe
ref_ndvi_means$month <- format(as.Date(ref_ndvi_means$time), "%m")
ref_evi_means$month  <- format(as.Date(ref_evi_means$time),  "%m")
ref_nirv_means$month <- format(as.Date(ref_nirv_means$time), "%m")
ref_lai_means$month  <- format(as.Date(ref_lai_means$time),  "%m")

# Merge all reference dataframes by FID and month
df_ref <- ref_ndvi_means %>%
  left_join(ref_evi_means,  by = c("FID", "month")) %>%
  left_join(ref_nirv_means, by = c("FID", "month")) %>% 
  left_join(ref_lai_means,  by = c("FID", "month"))