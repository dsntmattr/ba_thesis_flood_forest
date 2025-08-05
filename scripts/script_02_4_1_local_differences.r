# ==============================================================================
# SCRIPT: Calculate Mean Differences - Local Level Analysis
# PURPOSE: Create dataframes with time series values comparing study period
#          to reference period at local forest loss sites
# AUTHOR: Matthias Lerch
# DATE: [Current Date]
# ==============================================================================

# 00 LOAD REQUIRED PACKAGES -----------------------------------------------

# Spatial data processing
library(gdalcubes)   # Processing raster data cubes
library(sf)          # Simple features for vector data
library(terra)       # Spatial raster data analysis

# Data manipulation and output
library(dplyr)       # Data manipulation and transformation
library(gdata)       # Additional data manipulation tools
library(tidyr)       # Data tidying and reshaping
library(writexl)     # Write Excel files

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

# Get LAI reference data path (Note: using P13Y from original script)
paths_lai <- list.files(path = "data/work/reference/lai/qa1/P10Y", pattern = "LAI", full.names = TRUE)

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

# Set row names to month and select only index columns
rownames(df_ref) <- df_ref$month
df_ref <- df_ref %>% 
  select(NDVI, EVI, NIRv, LAI)

# ==============================================================================
# PART 02: STUDY PERIOD DATA PROCESSING
# ==============================================================================

# 06 LOAD STUDY PERIOD INDEX DATA -----------------------------------------

# Define path to study period vegetation indices
path = "data/work/study/indices/"

# Get file paths for each vegetation index
paths_ndvi <- list.files(path = path, pattern = "NDVI_", full.names = TRUE)
paths_evi  <- list.files(path = path, pattern = "EVI_",  full.names = TRUE)
paths_nirv <- list.files(path = path, pattern = "NIRv_", full.names = TRUE)

# Get LAI study data path
paths_lai <- list.files(path = "data/work/study/lai/qa1/P1M", pattern = "LAI", full.names = TRUE)

# 07 CREATE STUDY PERIOD DATA CUBES ---------------------------------------

# Create datetime values for study period (2013-2017, growing season months)
months <- 5:9                                               # May through September
years <- 2013:2017                                          # Study period years
datetime_values <- as.vector(sapply(years, function(y) sprintf("%d-%02d", y, months)))

# Stack study period rasters into cubes (one cube per index)
cube_ndvi <- stack_cube(paths_ndvi, datetime_values = datetime_values)
cube_evi  <- stack_cube(paths_evi,  datetime_values = datetime_values)
cube_nirv <- stack_cube(paths_nirv, datetime_values = datetime_values)
cube_lai  <- stack_cube(paths_lai,  datetime_values = datetime_values)

# 08 EXTRACT STUDY VALUES AT FOREST LOSS SITES ---------------------------

# Extract mean values for each month/year combination over study period
# Only for cells whose centers overlap with forest loss polygons

ndvi_means <- extract_geom(cube_ndvi, sf, FUN = mean) %>% 
  rename(NDVI = x1)                                         # Rename column for clarity

evi_means <- extract_geom(cube_evi, sf, FUN = mean) %>% 
  rename(EVI = x1)                                          # Rename column for clarity

nirv_means <- extract_geom(cube_nirv, sf, FUN = mean) %>% 
  rename(NIRv = x1)                                         # Rename column for clarity

lai_means <- extract_geom(cube_lai, sf, FUN = mean) %>% 
  rename(LAI = x1)                                          # Rename column for clarity

# 09 PROCESS STUDY PERIOD DATA --------------------------------------------

# Merge all study dataframes by FID and time
df_stu <- ndvi_means %>%
  left_join(evi_means,  by = c("FID", "time")) %>%
  left_join(nirv_means, by = c("FID", "time")) %>% 
  left_join(lai_means,  by = c("FID", "time"))

# Set row names to datetime and select only index columns
rownames(df_stu) <- df_stu$time
df_stu <- df_stu %>% 
  select(NDVI, EVI, NIRv, LAI)

# ==============================================================================
# PART 03: ANNUAL DATA SEPARATION AND DIFFERENCE CALCULATIONS
# ==============================================================================

# 10 SEPARATE STUDY DATA BY YEAR ------------------------------------------

# Create separate dataframes for each study year
df_2013 <- df_stu %>% 
  filter(grepl("2013", rownames(df_stu)))

df_2014 <- df_stu %>% 
  filter(grepl("2014", rownames(df_stu)))

df_2015 <- df_stu %>% 
  filter(grepl("2015", rownames(df_stu)))

df_2016 <- df_stu %>% 
  filter(grepl("2016", rownames(df_stu)))

df_2017 <- df_stu %>% 
  filter(grepl("2017", rownames(df_stu)))

# 11 CALCULATE ABSOLUTE DIFFERENCES ---------------------------------------

# Calculate absolute differences by subtracting reference from study values
df_dif_2013_abs <- df_2013 - df_ref
df_dif_2014_abs <- df_2014 - df_ref
df_dif_2015_abs <- df_2015 - df_ref
df_dif_2016_abs <- df_2016 - df_ref
df_dif_2017_abs <- df_2017 - df_ref

# 12 CALCULATE RELATIVE DIFFERENCES ---------------------------------------

# Calculate relative differences as percentage of reference period values
df_dif_2013_rel <- (df_dif_2013_abs / df_ref) * 100
df_dif_2014_rel <- (df_dif_2014_abs / df_ref) * 100
df_dif_2015_rel <- (df_dif_2015_abs / df_ref) * 100
df_dif_2016_rel <- (df_dif_2016_abs / df_ref) * 100
df_dif_2017_rel <- (df_dif_2017_abs / df_ref) * 100

# ==============================================================================
# PART 04: COMBINE AND FORMAT OUTPUT DATA
# ==============================================================================

# 13 COMBINE ANNUAL DIFFERENCES -------------------------------------------

# Combine all absolute difference dataframes
df_dif_abs_loc <- bind_rows(df_dif_2013_abs, 
                            df_dif_2014_abs, 
                            df_dif_2015_abs, 
                            df_dif_2016_abs, 
                            df_dif_2017_abs)

# Combine all relative difference dataframes
df_dif_rel_loc <- bind_rows(df_dif_2013_rel, 
                            df_dif_2014_rel, 
                            df_dif_2015_rel, 
                            df_dif_2016_rel, 
                            df_dif_2017_rel)

# 14 ADD TIME INFORMATION -------------------------------------------------

# Create time column from row names
df_dif_abs_loc$time <- as.Date(rownames(df_dif_abs_loc))
df_dif_rel_loc$time <- as.Date(rownames(df_dif_rel_loc))

# 15 TRANSFORM TO LONG FORMAT ---------------------------------------------

# Transform absolute differences to long format (one row per value)
df_dif_abs_loc_long <- df_dif_abs_loc %>%
  pivot_longer(
    cols = c(NDVI, EVI, NIRv, LAI),
    names_to = "index",
    values_to = "value"
  )

# Transform relative differences to long format (one row per value)
df_dif_rel_loc_long <- df_dif_rel_loc %>%
  pivot_longer(
    cols = c(NDVI, EVI, NIRv, LAI),
    names_to = "index",
    values_to = "value"
  )

# ==============================================================================
# PART 05: CLEAN ENVIRONMENT AND SAVE OUTPUT
# ==============================================================================

# 16 CLEAN ENVIRONMENT ----------------------------------------------------

# Keep only the final output dataframes
keep(df_dif_abs_loc,
     df_dif_rel_loc,
     df_dif_abs_loc_long, 
     df_dif_rel_loc_long, 
     sure = TRUE)

# 17 SAVE OUTPUT DATAFRAMES -----------------------------------------------

# Save wide format dataframes
save(df_dif_abs_loc, file = "data/work/dataframes/df_dif_absolute_local.RData")
save(df_dif_rel_loc, file = "data/work/dataframes/df_dif_relative_local.RData")

write_xlsx(df_dif_abs_loc, path = "output/differences_absolute_local.xlsx")
write_xlsx(df_dif_rel_loc, path = "output/differences_relative_local.xlsx")

# Save long format dataframes
save(df_dif_abs_loc_long, file = "data/work/dataframes/df_dif_absolute_local_long.RData")
save(df_dif_rel_loc_long, file = "data/work/dataframes/df_dif_relative_local_long.RData")


