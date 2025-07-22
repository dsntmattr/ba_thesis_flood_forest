# Trying a new approach for 02.4.2, 
# a shorter/more efficient version.

# Packages. ---------------------------------------------------------------
# Spatial data.
library(terra)       # raster

# Tabular data.
library(dplyr)       # manipulation
library(gdata)       # manipulation
library(tibble)      
library(tidyr)       # tidying
library(stringr)

# Define helper function. ----------------------------------
mask_mean = function(raster, mask) {
  x <- raster %>%
    mask(mask) %>%
    global (fun = mean, na.rm = TRUE)
}

# Load mask.
mask <- rast("data/work/mask/mask_66p.tif")

# REFERENCE ---------------------------------------------------------------
# Load data. --------------------------------------------------------------
ndvi <- rast(list.files(path = "data/work/reference/indices", pattern = "NDVI", full.names = TRUE)) 
evi <- rast(list.files(path = "data/work/reference/indices", pattern = "EVI", full.names = TRUE))
nirv <- rast(list.files(path = "data/work/reference/indices", pattern = "NIRv", full.names = TRUE))

lai <- rast(list.files(path = "data/work/reference/lai/qa1/p13y/", pattern = "LAI", full.names = TRUE))

# Define new names for columns and rows.
new_col_names <- c("EVI_Broad" , "EVI_Conifer",
                   "LAI_Broad" , "LAI_Conifer",
                   "NDVI_Broad", "NDVI_Conifer",
                   "NIRv_Broad", "NIRv_Conifer" 
                   )

new_row_names <- c("May", "June", "July", "August", "September")

# Mask and Mean.  -----------------------------------------------------
evi_bro_mean <- mask_mean(evi, mask[[1]])
evi_con_mean <- mask_mean(evi, mask[[2]])

lai_bro_mean <- mask_mean(lai, mask[[1]])
lai_con_mean <- mask_mean(lai, mask[[2]])

ndvi_bro_mean <- mask_mean(ndvi, mask[[1]])
ndvi_con_mean <- mask_mean(ndvi, mask[[2]])

nirv_bro_mean <- mask_mean(nirv, mask[[1]])
nirv_con_mean <- mask_mean(nirv, mask[[2]])

# Create the dataframe
df_ref <- data.frame(evi_bro_mean,
                     lai_bro_mean,
                     ndvi_bro_mean,
                     nirv_bro_mean,
                     evi_con_mean,
                     lai_con_mean, 
                     ndvi_con_mean,
                     nirv_con_mean)

row.names(df_ref) <- new_row_names
colnames(df_ref) <- new_col_names


# # STUDY. ----------------------------------------------------------------
# Loading the indices pictures per year and index-----------------------------------------------------
path <- "data/work/study/indices/"

df_per_forest_type = function (path, pattern, maskband, names){
  files <- c(rast(list.files(path = path, pattern = pattern, full.names = TRUE)))
  files_masked_means <- mask_mean(files, mask[[maskband]])
  
  files_masked_means$name <- names
  
  files_masked_means <- files_masked_means %>% 
    separate(name, into = c("Index", "Monat"), sep = "_") %>%
    pivot_wider(names_from = Index, values_from = mean) %>% 
    column_to_rownames(var = "Monat")
  return(files_masked_means)
}

# Broad

names <- c("EVI.Broad_05", "EVI.Broad_06", "EVI.Broad_07", "EVI.Broad_08", "EVI.Broad_09",
           "LAI.Broad_05", "LAI.Broad_06", "LAI.Broad_07", "LAI.Broad_08", "LAI.Broad_09",
           "NDVI.Broad_05", "NDVI.Broad_06", "NDVI.Broad_07", "NDVI.Broad_08", "NDVI.Broad_09",
           "NIRv.Broad_05", "NIRv.Broad_06", "NIRv.Broad_07", "NIRv.Broad_08", "NIRv.Broad_09")

df_2013_broad <- df_per_forest_type(path, "2013", 1, names)
df_2014_broad <- df_per_forest_type(path, "2014", 1, names)
df_2015_broad <- df_per_forest_type(path, "2015", 1, names)
df_2016_broad <- df_per_forest_type(path, "2016", 1, names)
df_2017_broad <- df_per_forest_type(path, "2017", 1, names)

# Conifer

names <- c("EVI.Conifer_05", "EVI.Conifer_06", "EVI.Conifer_07", "EVI.Conifer_08", "EVI.Conifer_09",
           "LAI.Conifer_05", "LAI.Conifer_06", "LAI.Conifer_07", "LAI.Conifer_08", "LAI.Conifer_09",
           "NDVI.Conifer_05", "NDVI.Conifer_06", "NDVI.Conifer_07", "NDVI.Conifer_08", "NDVI.Conifer_09",
           "NIRv.Conifer_05", "NIRv.Conifer_06", "NIRv.Conifer_07", "NIRv.Conifer_08", "NIRv.Conifer_09")

df_2013_conifer <- df_per_forest_type(path, "2013", 2, names)
df_2014_conifer <- df_per_forest_type(path, "2014", 2, names)
df_2015_conifer <- df_per_forest_type(path, "2015", 2, names)
df_2016_conifer <- df_per_forest_type(path, "2016", 2, names)
df_2017_conifer <- df_per_forest_type(path, "2017", 2, names)

df_2013 <- bind_cols(df_2013_broad, df_2013_conifer)
df_2014 <- bind_cols(df_2014_broad, df_2014_conifer)
df_2015 <- bind_cols(df_2015_broad, df_2015_conifer)
df_2016 <- bind_cols(df_2016_broad, df_2016_conifer)
df_2017 <- bind_cols(df_2017_broad, df_2017_conifer)

df_2013_dif_abs <- df_2013 - df_ref
df_2014_dif_abs <- df_2014 - df_ref
df_2015_dif_abs <- df_2015 - df_ref
df_2016_dif_abs <- df_2016 - df_ref
df_2017_dif_abs <- df_2017 - df_ref

df_dif_abs_reg <- bind_rows(df_2013_dif_abs,
                            df_2014_dif_abs,
                            df_2015_dif_abs,
                            df_2016_dif_abs,
                            df_2017_dif_abs)
months <- 5:9
years <- 2013:2017

row.names(df_dif_abs_reg) <- as.vector(sapply(years, function(y) sprintf("%d-%02d-01", y, months)))

# Harmosing ---------------------------------------------------------------s 
df_2013_dif_rel <- (df_2013_dif_abs / df_ref) * 100
df_2014_dif_rel <- (df_2014_dif_abs / df_ref) * 100
df_2015_dif_rel <- (df_2015_dif_abs / df_ref) * 100
df_2016_dif_rel <- (df_2016_dif_abs / df_ref) * 100
df_2017_dif_rel <- (df_2017_dif_abs / df_ref) * 100

df_dif_rel_reg <- bind_rows(df_2013_dif_rel,
                            df_2014_dif_rel,
                            df_2015_dif_rel,
                            df_2016_dif_rel,
                            df_2017_dif_rel)

# Pivoting to longer (for better use in ggplot2).
months <- 5:9
years <- 2013:2017

df_dif_abs_reg$date <- as.Date(sapply(years, function(y) sprintf("%d-%02d-01", y, months)))
df_dif_rel_reg$date <- as.Date(sapply(years, function(y) sprintf("%d-%02d-01", y, months)))

df_dif_abs_reg_long <- df_dif_abs_reg %>%
  pivot_longer(
    cols = -date,
    names_to = c("Index", "Vegetation"),
    names_sep = "\\.",
    values_to = "value"
  )

df_dif_rel_reg_long <- df_dif_rel_reg %>%
  pivot_longer(
    cols = -date,
    names_to = c("Index", "Vegetation"),
    names_sep = "\\.",
    values_to = "value"
  )

keep(df_dif_abs_reg,
     df_dif_rel_reg,
     df_dif_abs_reg_long, 
     df_dif_rel_reg_long, 
     sure = TRUE)

test1 <- df_dif_abs_reg
test2 <- df_dif_rel_reg
test3 <- df_dif_abs_reg_long 
test4 <- df_dif_rel_reg_long

save(df_dif_abs_reg,      file = "data/work/dataframes/TEST_df_dif_absolute_regional.RData")
save(df_dif_rel_reg,      file = "data/work/dataframes/TEST_df_dif_relative_regional.RData")

save(df_dif_abs_reg_long, file = "data/work/dataframes/TEST_df_dif_absolute_regional_long.RData")
save(df_dif_rel_reg_long, file = "data/work/dataframes/TEST_df_dif_relative_regional_long.RData")
