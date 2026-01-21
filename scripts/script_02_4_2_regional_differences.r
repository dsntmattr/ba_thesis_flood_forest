# ==============================================================================
# SCRIPT: Calculate Mean Differences - Regional Level Analysis
# PURPOSE: Create dataframes with time series values comparing study period
#          to reference period at regional level using forest type masks
# AUTHOR: Matthias Lerch
# DATE: [Current Date]
# ==============================================================================

# 00 LOAD REQUIRED PACKAGES -----------------------------------------------

# Spatial data processing
library(terra)       # Spatial raster data analysis

# Data manipulation and output
library(gdata)       # Additional data manipulation tools
library(tidyverse)   # Data manipulation & plotting
library(writexl)     # Write Excel files

# ==============================================================================
# PART 01: REFERENCE PERIOD DATA PROCESSING
# ==============================================================================

# 01 LOAD REFERENCE PERIOD DATA -------------------------------------------

# Load reference period vegetation indices (long-term averages)
ndvi <- rast(list.files(path = "data/work/reference/indices/", pattern = "NDVI", full.names = TRUE))
evi <- rast(list.files(path = "data/work/reference/indices/", pattern = "EVI", full.names = TRUE))
nirv <- rast(list.files(path = "data/work/reference/indices/", pattern = "NIRv", full.names = TRUE))

# Load reference period LAI data (long-term averages)
lai <- rast(list.files(path = "data/work/reference/lai/p13y/", pattern = "LAI", full.names = TRUE))

# Load forest type mask with 66% coverage threshold
mask <- rast("data/work/mask/mask_66p.tif")

# 02 DEFINE HELPER FUNCTION -----------------------------------------------

# Function to apply mask and calculate mean values for each forest type
# Parameters:
#   raster: Input raster layer to process
#   mask: Mask layer containing forest type classifications
# Returns: Dataframe with global mean values for each mask layer
mask_mean = function(raster, mask) {
  x <- raster %>%
    mask(mask) %>%                                          # Apply forest type mask
    global(fun = mean, na.rm = TRUE)                        # Calculate global mean (ignore NA values)
}

# 03 DEFINE COLUMN AND ROW NAMES ------------------------------------------

# Define descriptive column names for output dataframes
new_col_names <- c("NDVI_Broad", "NDVI_Conifer",            # NDVI for broadleaf and coniferous
                   "EVI_Broad" , "EVI_Conifer",             # EVI for broadleaf and coniferous
                   "NIRv_Broad", "NIRv_Conifer",            # NIRv for broadleaf and coniferous
                   "LAI_Broad" , "LAI_Conifer")             # LAI for broadleaf and coniferous

# Define month names for row labels
new_row_names <- c("May", "June", "July", "August", "September")

# 04 CALCULATE REFERENCE PERIOD MEANS -------------------------------------

# Calculate mean NDVI values for each forest type using mask layers
ndvi_bro_mean <- mask_mean(ndvi, mask[[1]])                 # Broadleaf NDVI means
ndvi_con_mean <- mask_mean(ndvi, mask[[2]])                 # Coniferous NDVI means

# Calculate mean EVI values for each forest type
evi_bro_mean <- mask_mean(evi, mask[[1]])                   # Broadleaf EVI means
evi_con_mean <- mask_mean(evi, mask[[2]])                   # Coniferous EVI means

# Calculate mean NIRv values for each forest type
nirv_bro_mean <- mask_mean(nirv, mask[[1]])                 # Broadleaf NIRv means
nirv_con_mean <- mask_mean(nirv, mask[[2]])                 # Coniferous NIRv means

# Calculate mean LAI values for each forest type
lai_bro_mean <- mask_mean(lai, mask[[1]])                   # Broadleaf LAI means
lai_con_mean <- mask_mean(lai, mask[[2]])                   # Coniferous LAI means

# 05 CREATE REFERENCE PERIOD DATAFRAME -----------------------------------

# Combine all reference means into single dataframe
df_ref <- data.frame(ndvi_bro_mean, ndvi_con_mean,
                     evi_bro_mean, evi_con_mean,
                     nirv_bro_mean, nirv_con_mean,
                     lai_bro_mean, lai_con_mean)

# Apply descriptive names
row.names(df_ref) <- new_row_names                          # Month names as row labels
colnames(df_ref) <- new_col_names                           # Index-forest type combinations as columns

# ==============================================================================
# PART 02: STUDY PERIOD DATA PROCESSING
# ==============================================================================

# 06 LOAD STUDY PERIOD VEGETATION INDICES --------------------------------

# Set path to study period indices
path <- "data/work/study/indices/"

# Load NDVI data for each year (2013-2017)
ndvi_2013 <- rast(list.files(path = path, pattern = "NDVI_2013", full.names = TRUE))
ndvi_2014 <- rast(list.files(path = path, pattern = "NDVI_2014", full.names = TRUE))
ndvi_2015 <- rast(list.files(path = path, pattern = "NDVI_2015", full.names = TRUE))
ndvi_2016 <- rast(list.files(path = path, pattern = "NDVI_2016", full.names = TRUE))
ndvi_2017 <- rast(list.files(path = path, pattern = "NDVI_2017", full.names = TRUE))

# Load EVI data for each year (2013-2017)
evi_2013 <- rast(list.files(path = path, pattern = "EVI_2013", full.names = TRUE))
evi_2014 <- rast(list.files(path = path, pattern = "EVI_2014", full.names = TRUE))
evi_2015 <- rast(list.files(path = path, pattern = "EVI_2015", full.names = TRUE))
evi_2016 <- rast(list.files(path = path, pattern = "EVI_2016", full.names = TRUE))
evi_2017 <- rast(list.files(path = path, pattern = "EVI_2017", full.names = TRUE))

# Load NIRv data for each year (2013-2017)
nirv_2013 <- rast(list.files(path = path, pattern = "NIRv_2013", full.names = TRUE))
nirv_2014 <- rast(list.files(path = path, pattern = "NIRv_2014", full.names = TRUE))
nirv_2015 <- rast(list.files(path = path, pattern = "NIRv_2015", full.names = TRUE))
nirv_2016 <- rast(list.files(path = path, pattern = "NIRv_2016", full.names = TRUE))
nirv_2017 <- rast(list.files(path = path, pattern = "NIRv_2017", full.names = TRUE))

# 07 LOAD STUDY PERIOD LAI DATA -------------------------------------------

# Set path to study period LAI data
path <- "data/work/study/lai/"

# Load LAI data for each year (2013-2017)
lai_2013 <- rast(list.files(path = path, pattern = "LAI_2013", full.names = TRUE))
lai_2014 <- rast(list.files(path = path, pattern = "LAI_2014", full.names = TRUE))
lai_2015 <- rast(list.files(path = path, pattern = "LAI_2015", full.names = TRUE))
lai_2016 <- rast(list.files(path = path, pattern = "LAI_2016", full.names = TRUE))
lai_2017 <- rast(list.files(path = path, pattern = "LAI_2017", full.names = TRUE))

# 08 CALCULATE STUDY PERIOD MEANS -----------------------------------------

# Calculate NDVI means for broadleaf forests across all years
ndvi_2013_bro_mean <- mask_mean(ndvi_2013, mask[[1]])       # 2013 broadleaf NDVI
ndvi_2014_bro_mean <- mask_mean(ndvi_2014, mask[[1]])       # 2014 broadleaf NDVI
ndvi_2015_bro_mean <- mask_mean(ndvi_2015, mask[[1]])       # 2015 broadleaf NDVI
ndvi_2016_bro_mean <- mask_mean(ndvi_2016, mask[[1]])       # 2016 broadleaf NDVI
ndvi_2017_bro_mean <- mask_mean(ndvi_2017, mask[[1]])       # 2017 broadleaf NDVI

# Calculate NDVI means for coniferous forests across all years
ndvi_2013_con_mean <- mask_mean(ndvi_2013, mask[[2]])       # 2013 coniferous NDVI
ndvi_2014_con_mean <- mask_mean(ndvi_2014, mask[[2]])       # 2014 coniferous NDVI
ndvi_2015_con_mean <- mask_mean(ndvi_2015, mask[[2]])       # 2015 coniferous NDVI
ndvi_2016_con_mean <- mask_mean(ndvi_2016, mask[[2]])       # 2016 coniferous NDVI
ndvi_2017_con_mean <- mask_mean(ndvi_2017, mask[[2]])       # 2017 coniferous NDVI

# Calculate EVI means for broadleaf forests across all years
evi_2013_bro_mean <- mask_mean(evi_2013, mask[[1]])         # 2013 broadleaf EVI
evi_2014_bro_mean <- mask_mean(evi_2014, mask[[1]])         # 2014 broadleaf EVI
evi_2015_bro_mean <- mask_mean(evi_2015, mask[[1]])         # 2015 broadleaf EVI
evi_2016_bro_mean <- mask_mean(evi_2016, mask[[1]])         # 2016 broadleaf EVI
evi_2017_bro_mean <- mask_mean(evi_2017, mask[[1]])         # 2017 broadleaf EVI

# Calculate EVI means for coniferous forests across all years
evi_2013_con_mean <- mask_mean(evi_2013, mask[[2]])         # 2013 coniferous EVI
evi_2014_con_mean <- mask_mean(evi_2014, mask[[2]])         # 2014 coniferous EVI
evi_2015_con_mean <- mask_mean(evi_2015, mask[[2]])         # 2015 coniferous EVI
evi_2016_con_mean <- mask_mean(evi_2016, mask[[2]])         # 2016 coniferous EVI
evi_2017_con_mean <- mask_mean(evi_2017, mask[[2]])         # 2017 coniferous EVI

# Calculate NIRv means for broadleaf forests across all years
nirv_2013_bro_mean <- mask_mean(nirv_2013, mask[[1]])       # 2013 broadleaf NIRv
nirv_2014_bro_mean <- mask_mean(nirv_2014, mask[[1]])       # 2014 broadleaf NIRv
nirv_2015_bro_mean <- mask_mean(nirv_2015, mask[[1]])       # 2015 broadleaf NIRv
nirv_2016_bro_mean <- mask_mean(nirv_2016, mask[[1]])       # 2016 broadleaf NIRv
nirv_2017_bro_mean <- mask_mean(nirv_2017, mask[[1]])       # 2017 broadleaf NIRv

# Calculate NIRv means for coniferous forests across all years
nirv_2013_con_mean <- mask_mean(nirv_2013, mask[[2]])       # 2013 coniferous NIRv
nirv_2014_con_mean <- mask_mean(nirv_2014, mask[[2]])       # 2014 coniferous NIRv
nirv_2015_con_mean <- mask_mean(nirv_2015, mask[[2]])       # 2015 coniferous NIRv
nirv_2016_con_mean <- mask_mean(nirv_2016, mask[[2]])       # 2016 coniferous NIRv
nirv_2017_con_mean <- mask_mean(nirv_2017, mask[[2]])       # 2017 coniferous NIRv

# Calculate LAI means for broadleaf forests across all years
lai_2013_bro_mean <- mask_mean(lai_2013, mask[[1]])         # 2013 broadleaf LAI
lai_2014_bro_mean <- mask_mean(lai_2014, mask[[1]])         # 2014 broadleaf LAI
lai_2015_bro_mean <- mask_mean(lai_2015, mask[[1]])         # 2015 broadleaf LAI
lai_2016_bro_mean <- mask_mean(lai_2016, mask[[1]])         # 2016 broadleaf LAI
lai_2017_bro_mean <- mask_mean(lai_2017, mask[[1]])         # 2017 broadleaf LAI

# Calculate LAI means for coniferous forests across all years
lai_2013_con_mean <- mask_mean(lai_2013, mask[[2]])         # 2013 coniferous LAI
lai_2014_con_mean <- mask_mean(lai_2014, mask[[2]])         # 2014 coniferous LAI
lai_2015_con_mean <- mask_mean(lai_2015, mask[[2]])         # 2015 coniferous LAI
lai_2016_con_mean <- mask_mean(lai_2016, mask[[2]])         # 2016 coniferous LAI
lai_2017_con_mean <- mask_mean(lai_2017, mask[[2]])         # 2017 coniferous LAI

# 09 CREATE STUDY PERIOD DATAFRAMES ---------------------------------------

# Create dataframes for each year containing all indices and forest types
df_2013 <- data.frame(ndvi_2013_bro_mean, ndvi_2013_con_mean, evi_2013_bro_mean, evi_2013_con_mean, 
                      nirv_2013_bro_mean, nirv_2013_con_mean, lai_2013_bro_mean, lai_2013_con_mean)
df_2014 <- data.frame(ndvi_2014_bro_mean, ndvi_2014_con_mean, evi_2014_bro_mean, evi_2014_con_mean, 
                      nirv_2014_bro_mean, nirv_2014_con_mean, lai_2014_bro_mean, lai_2014_con_mean)
df_2015 <- data.frame(ndvi_2015_bro_mean, ndvi_2015_con_mean, evi_2015_bro_mean, evi_2015_con_mean, 
                      nirv_2015_bro_mean, nirv_2015_con_mean, lai_2015_bro_mean, lai_2015_con_mean)
df_2016 <- data.frame(ndvi_2016_bro_mean, ndvi_2016_con_mean, evi_2016_bro_mean, evi_2016_con_mean, 
                      nirv_2016_bro_mean, nirv_2016_con_mean, lai_2016_bro_mean, lai_2016_con_mean)
df_2017 <- data.frame(ndvi_2017_bro_mean, ndvi_2017_con_mean, evi_2017_bro_mean, evi_2017_con_mean, 
                      nirv_2017_bro_mean, nirv_2017_con_mean, lai_2017_bro_mean, lai_2017_con_mean)

# Apply consistent column names to all yearly dataframes
colnames(df_2013) <- new_col_names
colnames(df_2014) <- new_col_names
colnames(df_2015) <- new_col_names
colnames(df_2016) <- new_col_names
colnames(df_2017) <- new_col_names

# Apply consistent row names (months) to all yearly dataframes
row.names(df_2013) <- new_row_names
row.names(df_2014) <- new_row_names
row.names(df_2015) <- new_row_names
row.names(df_2016) <- new_row_names
row.names(df_2017) <- new_row_names

# ==============================================================================
# PART 03: CALCULATE DIFFERENCES AND CREATE FINAL DATAFRAMES
# ==============================================================================

# 10 CALCULATE ABSOLUTE DIFFERENCES ---------------------------------------

# Calculate absolute differences between study years and reference period
df_2013_dif_abs <- df_2013 - df_ref                         # 2013 minus reference
df_2014_dif_abs <- df_2014 - df_ref                         # 2014 minus reference
df_2015_dif_abs <- df_2015 - df_ref                         # 2015 minus reference
df_2016_dif_abs <- df_2016 - df_ref                         # 2016 minus reference
df_2017_dif_abs <- df_2017 - df_ref                         # 2017 minus reference

# Combine all absolute differences into single dataframe
df_dif_abs_reg <- bind_rows(df_2013_dif_abs,
                            df_2014_dif_abs,
                            df_2015_dif_abs,
                            df_2016_dif_abs,
                            df_2017_dif_abs)

# Create row names with year-month format for time series
months <- 5:9                                               # Growing season months (May-September)
years <- 2013:2017                                          # Study period years
row.names(df_dif_abs_reg) <- as.vector(sapply(years, function(y) sprintf("%d-%02d-01", y, months)))

# 11 CALCULATE RELATIVE DIFFERENCES ---------------------------------------

# Calculate relative differences as percentages of reference values
df_2013_dif_rel <- (df_2013_dif_abs / df_ref) * 100        # 2013 relative differences (%)
df_2014_dif_rel <- (df_2014_dif_abs / df_ref) * 100        # 2014 relative differences (%)
df_2015_dif_rel <- (df_2015_dif_abs / df_ref) * 100        # 2015 relative differences (%)
df_2016_dif_rel <- (df_2016_dif_abs / df_ref) * 100        # 2016 relative differences (%)
df_2017_dif_rel <- (df_2017_dif_abs / df_ref) * 100        # 2017 relative differences (%)

# Combine all relative differences into single dataframe
df_dif_rel_reg <- bind_rows(df_2013_dif_rel,
                            df_2014_dif_rel,
                            df_2015_dif_rel,
                            df_2016_dif_rel,
                            df_2017_dif_rel)

# 12 PIVOT DATA FOR VISUALIZATION -----------------------------------------

# Define temporal parameters for long format conversion
months <- 5:9                                               # Growing season months
years <- 2013:2017                                          # Study period years

# Add date columns to dataframes for pivoting
df_dif_abs_reg$date <- as.Date(sapply(years, function(y) sprintf("%d-%02d-01", y, months)))
df_dif_rel_reg$date <- as.Date(sapply(years, function(y) sprintf("%d-%02d-01", y, months)))

# Convert absolute differences to long format for ggplot2
df_dif_abs_reg_long <- df_dif_abs_reg %>%
  pivot_longer(
    cols = -date,                                           # Keep date column, pivot all others
    names_to = c("Index", "Vegetation"),                    # Split column names into Index and Vegetation
    names_sep = "_",                                        # Separator between Index and Vegetation
    values_to = "value"                                     # Value column name
  )

# Convert relative differences to long format for ggplot2
df_dif_rel_reg_long <- df_dif_rel_reg %>%
   pivot_longer(
     cols = -date,                                          # Keep date column, pivot all others
     names_to = c("Index", "Vegetation"),                   # Split column names into Index and Vegetation
     names_sep = "_",                                       # Separator between Index and Vegetation
     values_to = "value"                                    # Value column name
   )

# 13 CLEAN ENVIRONMENT AND SAVE RESULTS -----------------------------------

# Keep only final result dataframes in environment
gdata::keep(df_dif_abs_reg,
            df_dif_rel_reg,
            df_dif_abs_reg_long, 
            df_dif_rel_reg_long, 
            sure = TRUE)

# Save regional difference dataframes in wide format
dir_df <- "data/work/dataframes/"
dir_xlsx <- "output/"

dir.create("data/work/dataframes/", recursive = TRUE, showWarnings = FALSE)
dir.create("output/",               recursive = TRUE, showWarnings = FALSE)

save(df_dif_abs_reg, file = file.path(dir_df, "df_dif_absolute_regional.RData"))
save(df_dif_rel_reg, file = file.path (dir_df, "df_dif_relative_regional.RData"))

write_xlsx(df_dif_abs_reg, path = file.path(dir_xlsx, "differences_absolute_regional.xlsx"))
write_xlsx(df_dif_rel_reg, path = file.path(dir_xlsx, "differences_relative_regional.xlsx"))
 
# Save regional difference dataframes in long format (for visualization)
save(df_dif_abs_reg_long, file = file.path(dir_df, "df_dif_absolute_regional_long.RData"))
save(df_dif_rel_reg_long, file = file.path(dir_df, "df_dif_relative_regional_long.RData"))