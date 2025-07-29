# Script to test the influence of LAI QA1 and QA2 bands on
# number of remaining pixels.

# Packages
library(terra)
library(dplyr)
library(gdata)
library(tidyr)
library(ggplot2)

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

# Alle Ergebnisse in eine Liste packen
df_list <- list(
  "Ref"  = qa1_ref_valid_cells_cov,
  "2013" = qa1_2013_valid_cells_cov,
  "2014" = qa1_2014_valid_cells_cov,
  "2015" = qa1_2015_valid_cells_cov,
  "2016" = qa1_2016_valid_cells_cov,
  "2017" = qa1_2017_valid_cells_cov
)

# Liste in einen einzigen Dataframe umwandeln
qa1_cov_all <- bind_rows(df_list, .id = "Year")

df_list_mask <- list(
  "Ref"  = qa1_ref_valid_cells_mask,
  "2013" = qa1_2013_valid_cells_mask,
  "2014" = qa1_2014_valid_cells_mask,
  "2015" = qa1_2015_valid_cells_mask,
  "2016" = qa1_2016_valid_cells_mask,
  "2017" = qa1_2017_valid_cells_mask
)

qa1_mask_all <- bind_rows(df_list_mask, .id = "Year")



# # Test 02 - QA1+QA2 -----------------------------------------------------
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

# Alle Ergebnisse in eine Liste packen
df_list <- list(
  "Ref"  = qa1.qa2_ref_valid_cells_cov,
  "2013" = qa1.qa2_2013_valid_cells_cov,
  "2014" = qa1.qa2_2014_valid_cells_cov,
  "2015" = qa1.qa2_2015_valid_cells_cov,
  "2016" = qa1.qa2_2016_valid_cells_cov,
  "2017" = qa1.qa2_2017_valid_cells_cov
)

# Liste in einen einzigen Dataframe umwandeln
qa1.qa2_cov_all <- bind_rows(df_list, .id = "Year")

df_list_mask <- list(
  "Ref"  = qa1.qa2_ref_valid_cells_mask,
  "2013" = qa1.qa2_2013_valid_cells_mask,
  "2014" = qa1.qa2_2014_valid_cells_mask,
  "2015" = qa1.qa2_2015_valid_cells_mask,
  "2016" = qa1.qa2_2016_valid_cells_mask,
  "2017" = qa1.qa2_2017_valid_cells_mask
)

qa1.qa2_mask_all <- bind_rows(df_list_mask, .id = "Year")

# # Test 03 - no QA -----------------------------------------------------
# Number of remaining pixels. 
# Reference ---------------------------------------------------------------

# Load LAI rasters.
r_list <- rast(list.files(path = "data/work/reference/lai/no_qa/p13y", full.names = TRUE))

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
no.qa_ref_valid_cells_cov <- count_cells(r_list, cov, new_rownames, new_colnames)

# Number of cells based on mask layer.
no.qa_ref_valid_cells_mask <- count_cells(r_list, mask, new_rownames, new_colnames)

# Study -------------------------------------------------------------------

r_list <- rast(list.files(path = "data/work/study/lai/no_qa/p1m", full.names = TRUE))

no.qa_2013_valid_cells_cov  <- count_cells(r_list[[1:5]], cov,  new_rownames, new_colnames)
no.qa_2013_valid_cells_mask <- count_cells(r_list[[1:5]], mask, new_rownames, new_colnames)

no.qa_2014_valid_cells_cov  <- count_cells(r_list[[6:10]], cov, new_rownames, new_colnames)
no.qa_2014_valid_cells_mask <- count_cells(r_list[[6:10]], mask, new_rownames, new_colnames)

no.qa_2015_valid_cells_cov  <- count_cells(r_list[[11:15]], cov,  new_rownames, new_colnames)
no.qa_2015_valid_cells_mask <- count_cells(r_list[[11:15]], mask, new_rownames, new_colnames)

no.qa_2016_valid_cells_cov  <- count_cells(r_list[[16:20]], cov,  new_rownames, new_colnames)
no.qa_2016_valid_cells_mask <- count_cells(r_list[[16:20]], mask, new_rownames, new_colnames)

no.qa_2017_valid_cells_cov  <- count_cells(r_list[[21:25]], cov,  new_rownames, new_colnames)
no.qa_2017_valid_cells_mask <- count_cells(r_list[[21:25]], mask, new_rownames, new_colnames)

# Alle Ergebnisse in eine Liste packen
df_list <- list(
  "Ref"  = no.qa_ref_valid_cells_cov,
  "2013" = no.qa_2013_valid_cells_cov,
  "2014" = no.qa_2014_valid_cells_cov,
  "2015" = no.qa_2015_valid_cells_cov,
  "2016" = no.qa_2016_valid_cells_cov,
  "2017" = no.qa_2017_valid_cells_cov
)

# Liste in einen einzigen Dataframe umwandeln
no.qa_cov_all <- bind_rows(df_list, .id = "Year")

df_list_mask <- list(
  "Ref"  = no.qa_ref_valid_cells_mask,
  "2013" = no.qa_2013_valid_cells_mask,
  "2014" = no.qa_2014_valid_cells_mask,
  "2015" = no.qa_2015_valid_cells_mask,
  "2016" = no.qa_2016_valid_cells_mask,
  "2017" = no.qa_2017_valid_cells_mask
)

no.qa_mask_all <- bind_rows(df_list_mask, .id = "Year")



# Plots. ------------------------------------------------------------------

# Coverage
# Define month names
monate <- c("MAY", "JUN", "JUL", "AUG", "SEP")


qa1 <- qa1_cov_all
qa2 <- qa1.qa2_cov_all
qa3 <- no.qa_cov_all

# Add QA type columnn.
qa1$QA <- "QA1"
qa2$QA <- "QA1+QA2"
qa3$QA <- "no QA"

# Assign month column.
qa1$Monat <- rep(monate, times = 6) 
qa2$Monat <- rep(monate, times = 6)
qa3$Monat <- rep(monate, times = 6)

# Combine dataframes.
combined <- bind_rows(qa1, qa2, qa3)

# Sort month as factor.
combined$Monat <- factor(combined$Monat, levels = monate)

# Pivot from wide to long.
combined_long <- combined %>%
  pivot_longer(cols = c("Broad", "Conifer"), names_to = "Vegetation", values_to = "ValidPixels")

# Plotting.
p <- ggplot(combined_long, aes(x = Monat, y = ValidPixels, fill = QA)) +
  geom_bar(stat = "identity", position = "dodge") +
  facet_wrap(~ Year + Vegetation) +
  labs(x = "Monat", y = "Gültige Pixel",
       title = "Gültige Pixel pro Monat, QA-Filter & Vegetationstyp", 
       subtitle = "basierend auf gesamtem überfluteten Wald")

ggsave("output_test/lai_validcells_cov.jpg", plot = p, width = 10, height = 6, dpi = 300)


# Mask
# Define month names
qa1 <- qa1_mask_all
qa2 <- qa1.qa2_mask_all
qa3 <- no.qa_mask_all

monate <- c("MAY", "JUN", "JUL", "AUG", "SEP")

# Add QA type column
qa1$QA <- "QA1"
qa2$QA <- "QA1+QA2"
qa3$QA <- "no QA"

# Assign month column.
qa1$Monat <- rep(monate, times = 6) 
qa2$Monat <- rep(monate, times = 6)
qa3$Monat <- rep(monate, times = 6)

# Combine dataframes.
combined <- bind_rows(qa1, qa2, qa3)

# Sort month as factor.
combined$Monat <- factor(combined$Monat, levels = monate)

# Pivot from wide to long.
combined_long <- combined %>%
  pivot_longer(cols = c("Broad", "Conifer"), names_to = "Vegetation", values_to = "ValidPixels")

# Plotting.
p <- ggplot(combined_long, aes(x = Monat, y = ValidPixels, fill = QA)) +
  geom_bar(stat = "identity", position = "dodge") +
  facet_wrap(~ Year + Vegetation) +
  labs(x = "Monat", y = "Gültige Pixel",
       title = "Gültige Pixel pro Monat, QA-Filter & Vegetationstyp", 
       subtitle = "nach Anwendung 66%-Maske")

ggsave("output_test/lai_validcells_mask.jpg", plot = p, width = 10, height = 6, dpi = 300)

