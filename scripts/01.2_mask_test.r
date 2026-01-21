# ==============================================================================
# SCRIPT: Calculate Remaining Area Percentages and Pixel Counts
# PURPOSE: Analyze the remaining forest area and pixel counts after applying
#          different coverage threshold masks
# AUTHOR: Matthias Lerch
# DATE: [Current Date]
# ==============================================================================

# 00 LOAD REQUIRED PACKAGES -----------------------------------------------

# Spatial data processing
library(sf)          # Simple features for vector data
library(terra)       # Spatial raster data analysis

# Data manipulation and output
library(tidyverse)   # Collection of data science packages
library(gdata)       # Additional data manipulation tools
library(writexl)     # Write Excel files

# ==============================================================================
# SETUP: Create required directories
# ==============================================================================

required_dirs <- c(
  "output"
)

# Create all directories
for (dir in required_dirs) {
  dir.create(dir, recursive = TRUE, showWarnings = FALSE)
}


# Set row names and column names for output tables ------------------------

# Add descriptive row and column names
new_rownames <- c("No mask", "66%")
new_colnames <- c("Broad (ha)", "Conifer (ha)", "Mixed (ha)")

# 01 LOAD INPUT DATA -------------------------------------------------------

# Load coverage layers (forest type coverage percentages)
coverage <- rast("data/work/mask/coverage.tif")

# Load all mask layers with different thresholds
path <- list.files(path = "data/work/mask", pattern = "mask", full.names = TRUE)
mask <- rast(path)

# 02 APPLY MASKS TO COVERAGE LAYERS ---------------------------------------
# Apply each threshold mask to coverage layers to calculate remaining areas

# Apply masks to broadleaf forest coverage (layer 1)
cov_bro_66p <- mask(coverage[[1]], mask[[1]])         # 66% threshold

# Apply masks to coniferous forest coverage (layer 2)
cov_con_66p <- mask(coverage[[2]], mask[[2]])         # 66% threshold

# Apply masks to mixed forest coverage (layer 3)
cov_mix_66p <- mask(coverage[[3]], mask[[3]])         # 66% threshold

# 03 CALCULATE FOREST AREAS -----------------------------------------------
# Calculate total forest area for each forest type and threshold

# Calculate total coverage values (sum of all coverage percentages)
cov_bro_sum     <- global(coverage[[1]], "sum", na.rm = TRUE)      # Total broadleaf
cov_bro_66p_sum <- global(cov_bro_66p, "sum", na.rm = TRUE)        # Broadleaf at 66%

cov_con_sum     <- global(coverage[[2]], "sum", na.rm = TRUE)      # Total coniferous
cov_con_66p_sum <- global(cov_con_66p, "sum", na.rm = TRUE)        # Coniferous at 66%

cov_mix_sum     <- global(coverage[[3]], "sum", na.rm = TRUE)      # Total mixed
cov_mix_66p_sum <- global(cov_mix_66p, "sum", na.rm = TRUE)        # Mixed at 66%

# 04 CONVERT TO HECTARES ---------------------------------------------------

# Combine coverage sums into dataframes by forest type
df_bro <- bind_rows(cov_bro_sum, cov_bro_66p_sum)
df_con <- bind_rows(cov_con_sum, cov_con_66p_sum)
df_mix <- bind_rows(cov_mix_sum, cov_mix_66p_sum)

# Combine all forest types
df <- bind_cols(df_bro, df_con, df_mix)

# Convert coverage values to hectares
# Coverage layer values represent percentage coverage per cell
# Each cell = 500 × 500 meters = 25 hectares
# Example: cell with 50% forest coverage = 0.5 × 25 = 12.5 ha
df <- df * 25

# Round values to whole hectares
#df <- round(df, digits = 2)

# Add descriptive names
colnames(df) <- new_colnames
df$Mask      <- new_rownames


df_area_absolute <- df

# 05 CALCULATE RELATIVE AREAS ----------------------------------------------
# Calculate percentage of remaining area compared to total area

# Calculate percentage of total area for each forest type
df_bro_perc <- data.frame(df$Broad  / df$Broad  [[1]] * 100)      # Broadleaf percentages
df_con_perc <- data.frame(df$Conifer/ df$Conifer[[1]] * 100)      # Coniferous percentages
df_mix_perc <- data.frame(df$Mixed  / df$Mixed  [[1]] * 100)      # Mixed percentages

# Combine percentage dataframes
df_perc <- bind_cols(df_bro_perc, df_con_perc, df_mix_perc)

# Round to whole percentages
#df_perc <- round(df_perc)

# Add descriptive names
colnames(df_perc) <- new_colnames
df_perc$Mask      <- new_rownames

df_area_relative <- df_perc

# 06 COUNT PIXELS/CELLS ----------------------------------------------------
# Count number of valid (non-NA) cells for each mask and forest type

# Count cells in original coverage layers
cells_coverage_bro <- sum(!is.na(values(coverage[[1]])))    # Broadleaf cells
cells_coverage_con <- sum(!is.na(values(coverage[[2]])))    # Coniferous cells
cells_coverage_mix <- sum(!is.na(values(coverage[[3]])))    # Mixed cells

# Count cells in broadleaf mask
cells_mask_bro_66p <- sum(!is.na(values(mask[[1]])))  # 66% threshold

# Count cells in coniferous mask
cells_mask_con_66p <- sum(!is.na(values(mask[[2]])))  # 66% threshold

# Count cells in mixed mask
cells_mask_mix_66p <- sum(!is.na(values(mask[[3]])))  # 66% threshold

# Create vectors with cell counts for each forest type
vec_bro_cells <- c(cells_coverage_bro, cells_mask_bro_66p)
vec_con_cells <- c(cells_coverage_con, cells_mask_con_66p)
vec_mix_cells <- c(cells_coverage_mix, cells_mask_mix_66p)

# Create dataframe with absolute cell counts
df <- data.frame(vec_bro_cells, vec_con_cells, vec_mix_cells)

# Add descriptive names
colnames(df) <- new_colnames
df$Mask      <- new_rownames

df_pixels_absolute <- df

# 07 CALCULATE RELATIVE PIXEL COUNTS --------------------------------------
# Calculate percentage of remaining pixels compared to total pixels

# Calculate percentage of total pixels for each forest type
df_bro_ncells_perc <- data.frame(df[1]/df[[1]][1] * 100)    # Broadleaf pixel percentages
df_con_ncells_perc <- data.frame(df[2]/df[[2]][1] * 100)    # Coniferous pixel percentages
df_mix_ncells_perc <- data.frame(df[3]/df[[3]][1] * 100)    # Mixed pixel percentages

# Combine percentage dataframes
df_perc <- bind_cols(df_bro_ncells_perc, df_con_ncells_perc, df_mix_ncells_perc)

# Round to one decimal place
#df_perc <- round(df_perc, digits = 2)

# Add descriptive names
colnames(df_perc) <- new_colnames
df_perc$Mask      <- new_rownames


df_pixels_relative <- df_perc

# 08 CLEAN ENVIRONMENT AND SAVE RESULTS -----------------------------------

# Keep only final result dataframes
keep(df_area_absolute,
     df_area_relative,
     df_pixels_absolute,
     df_pixels_relative,
     sure = TRUE)

# Create list of all result dataframes for Excel export
result_list <- list(
  "Area Absolute"   = df_area_absolute,
  "Area Relative"   = df_area_relative,
  "Pixels Absolute" = df_pixels_absolute,
  "Pixels Relative" = df_pixels_relative
)

all_col_names <- c(
  "Broad area ha", "Conifer area ha", "Mixed area ha",
  "Broad area %",  "Conifer area %",  "Mixed area %",
  "Broad pixel num", "Conifer pixel num", "Mixed pixel num",
  "Broad pixel %",   "Conifer pixel %",   "Mixed pixel %",
  "Mask"
)

mask_result <- bind_cols(
  df_area_absolute,
  df_area_relative,
  df_pixels_absolute,
  df_pixels_relative
) %>%
  # falls wirklich jede Quelle 4 Spalten hat und du nur die 1–3 pro Block willst:
  select(
    1:3, 5:7, 9:11, 13:15, 16
  ) %>%
  setNames(all_col_names) %>%
  select(
    Mask,
    starts_with("Broad"),
    starts_with("Conifer"),
    starts_with("Mixed")
  )


write_xlsx(mask_result, path = "output/mask_result.xlsx")
