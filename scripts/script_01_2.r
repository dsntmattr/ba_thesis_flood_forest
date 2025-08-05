# ==============================================================================
# SCRIPT: Calculate Remaining Area Percentages and Pixel Counts
# PURPOSE: Analyze the remaining forest area and pixel counts after applying
#          different coverage threshold masks
# AUTHOR: [Your Name]
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

# 01 LOAD INPUT DATA -------------------------------------------------------

# Load coverage layers (forest type coverage percentages)
coverage <- rast("data/work/mask/coverage.tif")

# Load all mask layers with different thresholds
paths <- list.files(path = "data/work/mask", pattern = "mask", full.names = TRUE)
masks <- lapply(paths, rast)

# 02 APPLY MASKS TO COVERAGE LAYERS ---------------------------------------
# Apply each threshold mask to coverage layers to calculate remaining areas

# Apply masks to broadleaf forest coverage (layer 1)
cov_bro_30p <- mask(coverage[[1]], masks[[1]][[1]])         # 30% threshold
cov_bro_50p <- mask(coverage[[1]], masks[[2]][[1]])         # 50% threshold
cov_bro_66p <- mask(coverage[[1]], masks[[3]][[1]])         # 66% threshold
cov_bro_70p <- mask(coverage[[1]], masks[[4]][[1]])         # 70% threshold
cov_bro_90p <- mask(coverage[[1]], masks[[5]][[1]])         # 90% threshold
cov_bro_99p <- mask(coverage[[1]], masks[[6]][[1]])         # 99% threshold

# Apply masks to coniferous forest coverage (layer 2)
cov_con_30p <- mask(coverage[[2]], masks[[1]][[2]])         # 30% threshold
cov_con_50p <- mask(coverage[[2]], masks[[2]][[2]])         # 50% threshold
cov_con_66p <- mask(coverage[[2]], masks[[3]][[2]])         # 66% threshold
cov_con_70p <- mask(coverage[[2]], masks[[4]][[2]])         # 70% threshold
cov_con_90p <- mask(coverage[[2]], masks[[5]][[2]])         # 90% threshold
cov_con_99p <- mask(coverage[[2]], masks[[6]][[2]])         # 99% threshold

# Apply masks to mixed forest coverage (layer 3)
cov_mix_30p <- mask(coverage[[3]], masks[[1]][[3]])         # 30% threshold
cov_mix_50p <- mask(coverage[[3]], masks[[2]][[3]])         # 50% threshold
cov_mix_66p <- mask(coverage[[3]], masks[[3]][[3]])         # 66% threshold
cov_mix_70p <- mask(coverage[[3]], masks[[4]][[3]])         # 70% threshold
cov_mix_90p <- mask(coverage[[3]], masks[[5]][[3]])         # 90% threshold
cov_mix_99p <- mask(coverage[[3]], masks[[6]][[3]])         # 99% threshold

# 03 CALCULATE FOREST AREAS -----------------------------------------------
# Calculate total forest area for each forest type and threshold

# Calculate total coverage values (sum of all coverage percentages)
cov_bro_sum     <- global(coverage[[1]], "sum", na.rm = TRUE)      # Total broadleaf
cov_bro_30p_sum <- global(cov_bro_30p, "sum", na.rm = TRUE)        # Broadleaf at 30%
cov_bro_50p_sum <- global(cov_bro_50p, "sum", na.rm = TRUE)        # Broadleaf at 50%
cov_bro_66p_sum <- global(cov_bro_66p, "sum", na.rm = TRUE)        # Broadleaf at 66%
cov_bro_70p_sum <- global(cov_bro_70p, "sum", na.rm = TRUE)        # Broadleaf at 70%
cov_bro_90p_sum <- global(cov_bro_90p, "sum", na.rm = TRUE)        # Broadleaf at 90%
cov_bro_99p_sum <- global(cov_bro_99p, "sum", na.rm = TRUE)        # Broadleaf at 99%

cov_con_sum     <- global(coverage[[2]], "sum", na.rm = TRUE)      # Total coniferous
cov_con_30p_sum <- global(cov_con_30p, "sum", na.rm = TRUE)        # Coniferous at 30%
cov_con_50p_sum <- global(cov_con_50p, "sum", na.rm = TRUE)        # Coniferous at 50%
cov_con_66p_sum <- global(cov_con_66p, "sum", na.rm = TRUE)        # Coniferous at 66%
cov_con_70p_sum <- global(cov_con_70p, "sum", na.rm = TRUE)        # Coniferous at 70%
cov_con_90p_sum <- global(cov_con_90p, "sum", na.rm = TRUE)        # Coniferous at 90%
cov_con_99p_sum <- global(cov_con_99p, "sum", na.rm = TRUE)        # Coniferous at 99%

cov_mix_sum     <- global(coverage[[3]], "sum", na.rm = TRUE)      # Total mixed
cov_mix_30p_sum <- global(cov_mix_30p, "sum", na.rm = TRUE)        # Mixed at 30%
cov_mix_50p_sum <- global(cov_mix_50p, "sum", na.rm = TRUE)        # Mixed at 50%
cov_mix_66p_sum <- global(cov_mix_66p, "sum", na.rm = TRUE)        # Mixed at 66%
cov_mix_70p_sum <- global(cov_mix_70p, "sum", na.rm = TRUE)        # Mixed at 70%
cov_mix_90p_sum <- global(cov_mix_90p, "sum", na.rm = TRUE)        # Mixed at 90%
cov_mix_99p_sum <- global(cov_mix_99p, "sum", na.rm = TRUE)        # Mixed at 99%

# 04 CONVERT TO HECTARES ---------------------------------------------------
# Convert coverage values to actual forest areas in hectares

# Combine coverage sums into dataframes by forest type
df_bro <- bind_rows(cov_bro_sum, cov_bro_30p_sum, cov_bro_50p_sum, 
                   cov_bro_66p_sum, cov_bro_70p_sum, cov_bro_90p_sum, cov_bro_99p_sum)
df_con <- bind_rows(cov_con_sum, cov_con_30p_sum, cov_con_50p_sum, 
                   cov_con_66p_sum, cov_con_70p_sum, cov_con_90p_sum, cov_con_99p_sum)
df_mix <- bind_rows(cov_mix_sum, cov_mix_30p_sum, cov_mix_50p_sum, 
                   cov_mix_66p_sum, cov_mix_70p_sum, cov_mix_90p_sum, cov_mix_99p_sum)

# Combine all forest types
df <- bind_cols(df_bro, df_con, df_mix)

# Convert coverage values to hectares
# Coverage layer values represent percentage coverage per cell
# Each cell = 500 × 500 meters = 25 hectares
# Example: cell with 50% forest coverage = 0.5 × 25 = 12.5 ha
df <- df * 25

# Add descriptive row and column names
row.names(df) <- c("Total", "30%", "50%", "66%", "70%", "90%", "99%")
colnames(df) <- c("Broad (ha)", "Conifer (ha)", "Mixed (ha)")

# Round values to whole hectares
df <- round(df)
df_area_absolute <- df

# 05 CALCULATE RELATIVE AREAS ----------------------------------------------
# Calculate percentage of remaining area compared to total area

# Calculate percentage of total area for each forest type
df_bro_perc <- data.frame(df$Broad/df$Broad[[1]] * 100)     # Broadleaf percentages
df_con_perc <- data.frame(df$Conifer/df$Conifer[[1]] * 100) # Coniferous percentages
df_mix_perc <- data.frame(df$Mixed/df$Mixed[[1]] * 100)     # Mixed percentages

# Combine percentage dataframes
df_perc <- bind_cols(df_bro_perc, df_con_perc, df_mix_perc)

# Add descriptive names
row.names(df_perc) <- c("Total", "30%", "50%", "66%", "70%", "90%", "99%")
colnames(df_perc) <- c("Broad (%)", "Conifer (%)", "Mixed (%)")

# Round to whole percentages
df_area_relative <- round(df_perc)

# 06 COUNT PIXELS/CELLS ----------------------------------------------------
# Count number of valid (non-NA) cells for each mask and forest type

# Count cells in original coverage layers
cells_coverage_bro <- sum(!is.na(values(coverage[[1]])))    # Broadleaf cells
cells_coverage_con <- sum(!is.na(values(coverage[[2]])))    # Coniferous cells
cells_coverage_mix <- sum(!is.na(values(coverage[[3]])))    # Mixed cells

# Count cells in broadleaf masks at different thresholds
cells_mask_bro_30p <- sum(!is.na(values(masks[[1]][[1]])))  # 30% threshold
cells_mask_bro_50p <- sum(!is.na(values(masks[[2]][[1]])))  # 50% threshold
cells_mask_bro_66p <- sum(!is.na(values(masks[[3]][[1]])))  # 66% threshold
cells_mask_bro_70p <- sum(!is.na(values(masks[[4]][[1]])))  # 70% threshold
cells_mask_bro_90p <- sum(!is.na(values(masks[[5]][[1]])))  # 90% threshold
cells_mask_bro_99p <- sum(!is.na(values(masks[[6]][[1]])))  # 99% threshold

# Count cells in coniferous masks at different thresholds
cells_mask_con_30p <- sum(!is.na(values(masks[[1]][[2]])))  # 30% threshold
cells_mask_con_50p <- sum(!is.na(values(masks[[2]][[2]])))  # 50% threshold
cells_mask_con_66p <- sum(!is.na(values(masks[[3]][[2]])))  # 66% threshold
cells_mask_con_70p <- sum(!is.na(values(masks[[4]][[2]])))  # 70% threshold
cells_mask_con_90p <- sum(!is.na(values(masks[[5]][[2]])))  # 90% threshold
cells_mask_con_99p <- sum(!is.na(values(masks[[6]][[2]])))  # 99% threshold

# Count cells in mixed masks at different thresholds
cells_mask_mix_30p <- sum(!is.na(values(masks[[1]][[3]])))  # 30% threshold
cells_mask_mix_50p <- sum(!is.na(values(masks[[2]][[3]])))  # 50% threshold
cells_mask_mix_66p <- sum(!is.na(values(masks[[3]][[3]])))  # 66% threshold
cells_mask_mix_70p <- sum(!is.na(values(masks[[4]][[3]])))  # 70% threshold
cells_mask_mix_90p <- sum(!is.na(values(masks[[5]][[3]])))  # 90% threshold
cells_mask_mix_99p <- sum(!is.na(values(masks[[6]][[3]])))  # 99% threshold

# Create vectors with cell counts for each forest type
vec_bro_cells <- c(cells_coverage_bro, cells_mask_bro_30p, cells_mask_bro_50p, 
                   cells_mask_bro_66p, cells_mask_bro_70p, cells_mask_bro_90p, cells_mask_bro_99p)
vec_con_cells <- c(cells_coverage_con, cells_mask_con_30p, cells_mask_con_50p, 
                   cells_mask_con_66p, cells_mask_con_70p, cells_mask_con_90p, cells_mask_con_99p)
vec_mix_cells <- c(cells_coverage_mix, cells_mask_mix_30p, cells_mask_mix_50p, 
                   cells_mask_mix_66p, cells_mask_mix_70p, cells_mask_mix_90p, cells_mask_mix_99p)

# Create dataframe with absolute cell counts
df <- data.frame(vec_bro_cells, vec_con_cells, vec_mix_cells)

# Add descriptive names
row.names(df) <- c("Total", "30%", "50%", "66%", "70%", "90%", "99%")
colnames(df) <- c("Broad (ncells)", "Conifer (ncells)", "Mixed (ncells)")

df_pixels_absolute <- df

# 07 CALCULATE RELATIVE PIXEL COUNTS --------------------------------------
# Calculate percentage of remaining pixels compared to total pixels

# Calculate percentage of total pixels for each forest type
df_bro_ncells_perc <- data.frame(df[1]/df[[1]][1] * 100)    # Broadleaf pixel percentages
df_con_ncells_perc <- data.frame(df[2]/df[[2]][1] * 100)    # Coniferous pixel percentages
df_mix_ncells_perc <- data.frame(df[3]/df[[3]][1] * 100)    # Mixed pixel percentages

# Combine percentage dataframes
df_perc <- bind_cols(df_bro_ncells_perc, df_con_ncells_perc, df_mix_ncells_perc)

# Add descriptive names
row.names(df_perc) <- c("Total", "30%", "50%", "66%", "70%", "90%", "99%")
colnames(df_perc) <- c("Broad (ncells%)", "Conifer (ncells%)", "Mixed (ncells%)")

# Round to one decimal place
df_perc <- round(df_perc, digits = 1)
df_pixels_relative <- df_perc

# 08 CLEAN ENVIRONMENT AND SAVE RESULTS -----------------------------------

# Keep only final result dataframes
keep(df_area_absolute,
     df_area_relative,
     df_pixels_absolute,
     df_pixels_relative,
     sure = TRUE)

# Create list of all result dataframes for Excel export
result_list <- list(df_area_absolute, df_area_relative, df_pixels_absolute, df_pixels_relative)

# Export all results to Excel file with multiple sheets
write_xlsx(result_list, path = "output/remaining_area_and_pixels.xlsx")