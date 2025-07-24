# Script to test the influence of LAI QA1 and QA2 bands on
# 1. number of remaining pixels
# 2. result in plot

# Packages
library(terra)
library(dplyr)

# Load coverage raster and mask raster.
cov <- rast("data/work/mask/coverage.tif")
mask <- rast("data/work/mask/mask_66p.tif")

# Define new names for dataframe rows and columns.
new_rownames <- c("May", "June", "July", "August", "September")
new_colnames <- c("Broad", "Conifer")

# Test 01 - QA1
# Number of remaining pixels. 
# Reference ---------------------------------------------------------------

# Load LAI rasters.
r_list <- rast(list.files(path = "data/work/reference/lai/qa1/p13y", full.names = TRUE))

# Create helper function
count_cells <- function(r_list, overlay, rownames, colnames) {
  
  # Check for not NA cells in LAI raster and overlay rasters
  valid_mask_bro <- !is.na(r_list) & !is.na(overlay[[1]])
  valid_mask_con <- !is.na(r_list) & !is.na(overlay[[2]])
  
  # Count TRUE values (= not NA values in both rasters)
  n_valid_cells_bro <- global(valid_mask_bro, fun = "sum", na.rm = TRUE)
  n_valid_cells_con <- global(valid_mask_con, fun = "sum", na.rm = TRUE)
  
  # Combine the dataframes
  n_valid_cells <- bind_cols(n_valid_cells_bro, n_valid_cells_con)
  
  # Renaming rows and columns of the combined dataframe.
  row.names(n_valid_cells) <- rownames
  colnames(n_valid_cells) <- colnames
  
  return(n_valid_cells)
}

# Number of cells based on coverage layer.
qa1_ref_valid_cells_cov <- count_cells(r_list, cov, new_rownames, new_colnames)

# Number of cells based on mask layer.
qa1_ref_valid_cells_mask <- count_cells(r_list, mask, new_rownames, new_colnames)

# Study -------------------------------------------------------------------

r_list <- rast(list.files(path = "data/work/study/lai/qa1/p1m", full.names = TRUE))

qa1_2013_valid_cells_cov  <- count_cells(r_list[[1:5]], cov, new_rownames, new_colnames)
qa1_2013_valid_cells_mask <- count_cells(r_list[[1:5]], mask, new_rownames, new_colnames)

qa1_2014_valid_cells_cov  <- count_cells(r_list[[6:10]], cov, new_rownames, new_colnames)
qa1_2014_valid_cells_mask <- count_cells(r_list[[6:10]], mask, new_rownames, new_colnames)

qa1_2015_valid_cells_cov  <- count_cells(r_list[[11:15]], cov, new_rownames, new_colnames)
qa1_2015_valid_cells_mask <- count_cells(r_list[[11:15]], mask, new_rownames, new_colnames)

qa1_2016_valid_cells_cov  <- count_cells(r_list[[16:20]], cov, new_rownames, new_colnames)
qa1_2016_valid_cells_mask <- count_cells(r_list[[16:20]], mask, new_rownames, new_colnames)

qa1_2017_valid_cells_cov  <- count_cells(r_list[[21:25]], cov, new_rownames, new_colnames)
qa1_2017_valid_cells_mask <- count_cells(r_list[[21:25]], mask, new_rownames, new_colnames)


































# Test 02 - QA1+QA2
# Number of remaining pixels. 
# Reference ---------------------------------------------------------------

# Load LAI rasters.
r_list <- rast(list.files(path = "data/work/reference/lai/qc1-0_qc2-0/p13y", full.names = TRUE))

# Create helper function
count_cells <- function(r_list, overlay, rownames, colnames) {
  
  # Check for not NA cells in LAI raster and overlay rasters
  valid_mask_bro <- !is.na(r_list) & !is.na(overlay[[1]])
  valid_mask_con <- !is.na(r_list) & !is.na(overlay[[2]])
  
  # Count TRUE values (= not NA values in both rasters)
  n_valid_cells_bro <- global(valid_mask_bro, fun = "sum", na.rm = TRUE)
  n_valid_cells_con <- global(valid_mask_con, fun = "sum", na.rm = TRUE)
  
  # Combine the dataframes
  n_valid_cells <- bind_cols(n_valid_cells_bro, n_valid_cells_con)
  
  # Renaming rows and columns of the combined dataframe.
  row.names(n_valid_cells) <- rownames
  colnames(n_valid_cells) <- colnames
  
  return(n_valid_cells)
}

# Number of cells based on coverage layer.
qa1.qa2_ref_valid_cells_cov <- count_cells(r_list, cov, new_rownames, new_colnames)

# Number of cells based on mask layer.
qa1.qa2_ref_valid_cells_mask <- count_cells(r_list, mask, new_rownames, new_colnames)

# Study -------------------------------------------------------------------

r_list <- rast(list.files(path = "data/work/study/lai/qc1-0_qc2-0/p1m", full.names = TRUE))

qa1.qa2_2013_valid_cells_cov  <- count_cells(r_list[[1:5]], cov,  new_rownames, new_colnames)
qa1.qa2_2013_valid_cells_mask <- count_cells(r_list[[1:5]], mask, new_rownames, new_colnames)

qa1.qa2_2014_valid_cells_cov  <- count_cells(r_list[[6:10]], cov, new_rownames, new_colnames)
qa1.qa2_2014_valid_cells_mask <- count_cells(r_list[[6:10]], mask, new_rownames, new_colnames)

qa1.qa2_2015_valid_cells_cov  <- count_cells(r_list[[11:15]], cov,  new_rownames, new_colnames)
qa1.qa2_2015_valid_cells_mask <- count_cells(r_list[[11:15]], mask, new_rownames, new_colnames)

qa1.qa2_2016_valid_cells_cov  <- count_cells(r_list[[16:20]], cov,  new_rownames, new_colnames)
qa1.qa2_2016_valid_cells_mask <- count_cells(r_list[[16:20]], mask, new_rownames, new_colnames)

qa1.qa2_2017_valid_cells_cov  <- count_cells(r_list[[21:25]], cov,  new_rownames, new_colnames)
qa1.qa2_2017_valid_cells_mask <- count_cells(r_list[[21:25]], mask, new_rownames, new_colnames)
















































#######################################################################################
test <- rast("data/work/reference/lai/qa1/p13y/LAI_2003-08-01.tif")
test_mask_bro <- mask(test, mask[[2]])
test.cells <- global(test_mask_bro, fun = "notNA", na.rm = FALSE)
