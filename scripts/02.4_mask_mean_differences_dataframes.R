# Mask the calculated indices and the LAI product with the selfmade forest type covergae masks,
# calculate mean values,
# calculate differences between reference period and study period
# and create dataframes.

# Packages ---------------------------------------------------------
# Spatial data
library(terra) # raster
# Data manipulation and more.
library(magrittr) # pipe operator %>%
library(dplyr)

# Reference -------------------------------------------------------------

# Loading the indices.
ndvi <- rast(list.files(path = "data/work/reference/indices", pattern = "NDVI", full.names = TRUE)) 
evi <- rast(list.files(path = "data/work/reference/indices", pattern = "EVI", full.names = TRUE))
nirv <- rast(list.files(path = "data/work/reference/indices", pattern = "NIRv", full.names = TRUE))

lai <- rast(list.files(path = "data/work/reference/lai/qa1/p13y/", pattern = "LAI", full.names = TRUE))

# Loading the mask
mask <- rast("data/work/mask/mask_66p.tif")

# Define the function for mask and mean. ----------------------------------
mask_mean = function(raster, mask) {
  x <- raster %>%
    mask(mask) %>%
    global (fun = mean, na.rm = TRUE)
}

# Setting the new names for columns and rows of the resluting dataframe
new_col_names <- c("NDVI_Broad","NDVI_Conifer", 
                   "EVI_Broad","EVI_Conifer", 
                   "NIRv_Broad", "NIRv_Conifer", 
                   "LAI_Broad","LAI_Conifer")

new_row_names <- c("May", "June", "July", "August", "September")

# Mask and Mean.  -----------------------------------------------------
ndvi_bro_mean <- mask_mean(ndvi, mask[[1]])
ndvi_con_mean <- mask_mean(ndvi, mask[[2]])

evi_bro_mean <- mask_mean(evi, mask[[1]])
evi_con_mean <- mask_mean(evi, mask[[2]])

nirv_bro_mean <- mask_mean(nirv, mask[[1]])
nirv_con_mean <- mask_mean(nirv, mask[[2]])

lai_bro_mean <- mask_mean(lai, mask[[1]])
lai_con_mean <- mask_mean(lai, mask[[2]])

# Create the dataframe
df_ref <- data.frame(ndvi_bro_mean, ndvi_con_mean,
                     evi_bro_mean, evi_con_mean,
                     nirv_bro_mean, nirv_con_mean,
                     lai_bro_mean, lai_con_mean)

row.names(df_ref) <- new_row_names
colnames(df_ref) <- new_col_names

# Study period. ---------------------------------------------------------
# Loading the indices pictures per year and index-----------------------------------------------------
path <- "data/work/study/indices/"

ndvi_2013 <- rast(list.files(path = path, pattern = "NDVI_2013", full.names = TRUE))
ndvi_2014 <- rast(list.files(path = path, pattern = "NDVI_2014", full.names = TRUE))
ndvi_2015 <- rast(list.files(path = path, pattern = "NDVI_2015", full.names = TRUE))
ndvi_2016 <- rast(list.files(path = path, pattern = "NDVI_2016", full.names = TRUE))
ndvi_2017 <- rast(list.files(path = path, pattern = "NDVI_2017", full.names = TRUE))

evi_2013 <- rast(list.files(path = path, pattern = "EVI_2013", full.names = TRUE))
evi_2014 <- rast(list.files(path = path, pattern = "EVI_2014", full.names = TRUE))
evi_2015 <- rast(list.files(path = path, pattern = "EVI_2015", full.names = TRUE))
evi_2016 <- rast(list.files(path = path, pattern = "EVI_2016", full.names = TRUE))
evi_2017 <- rast(list.files(path = path, pattern = "EVI_2017", full.names = TRUE))

nirv_2013 <- rast(list.files(path = path, pattern = "NIRv_2013", full.names = TRUE))
nirv_2014 <- rast(list.files(path = path, pattern = "NIRv_2014", full.names = TRUE))
nirv_2015 <- rast(list.files(path = path, pattern = "NIRv_2015", full.names = TRUE))
nirv_2016 <- rast(list.files(path = path, pattern = "NIRv_2016", full.names = TRUE))
nirv_2017 <- rast(list.files(path = path, pattern = "NIRv_2017", full.names = TRUE))

# Loading the lai pictures per year and index-----------------------------------------------------
path <- "data/work/study/lai/qa1/p1m/"

lai_2013 <- rast(list.files(path = path, pattern = "LAI_2013", full.names = TRUE))
lai_2014 <- rast(list.files(path = path, pattern = "LAI_2014", full.names = TRUE))
lai_2015 <- rast(list.files(path = path, pattern = "LAI_2015", full.names = TRUE))
lai_2016 <- rast(list.files(path = path, pattern = "LAI_2016", full.names = TRUE))
lai_2017 <- rast(list.files(path = path, pattern = "LAI_2017", full.names = TRUE))

# Mask and Mean. ----------------------------------------------------------
# NDVI
ndvi_2013_bro_mean <- mask_mean(ndvi_2013, mask[[1]])
ndvi_2014_bro_mean <- mask_mean(ndvi_2014, mask[[1]])
ndvi_2015_bro_mean <- mask_mean(ndvi_2015, mask[[1]])
ndvi_2016_bro_mean <- mask_mean(ndvi_2016, mask[[1]])
ndvi_2017_bro_mean <- mask_mean(ndvi_2017, mask[[1]])

ndvi_2013_con_mean <- mask_mean(ndvi_2013, mask[[2]])
ndvi_2014_con_mean <- mask_mean(ndvi_2014, mask[[2]])
ndvi_2015_con_mean <- mask_mean(ndvi_2015, mask[[2]])
ndvi_2016_con_mean <- mask_mean(ndvi_2016, mask[[2]])
ndvi_2017_con_mean <- mask_mean(ndvi_2017, mask[[2]])

# EVI
evi_2013_bro_mean <- mask_mean(evi_2013, mask[[1]])
evi_2014_bro_mean <- mask_mean(evi_2014, mask[[1]])
evi_2015_bro_mean <- mask_mean(evi_2015, mask[[1]])
evi_2016_bro_mean <- mask_mean(evi_2016, mask[[1]])
evi_2017_bro_mean <- mask_mean(evi_2017, mask[[1]])

evi_2013_con_mean <- mask_mean(evi_2013, mask[[2]])
evi_2014_con_mean <- mask_mean(evi_2014, mask[[2]])
evi_2015_con_mean <- mask_mean(evi_2015, mask[[2]])
evi_2016_con_mean <- mask_mean(evi_2016, mask[[2]])
evi_2017_con_mean <- mask_mean(evi_2017, mask[[2]])

# NIRv
nirv_2013_bro_mean <- mask_mean(nirv_2013, mask[[1]])
nirv_2014_bro_mean <- mask_mean(nirv_2014, mask[[1]])
nirv_2015_bro_mean <- mask_mean(nirv_2015, mask[[1]])
nirv_2016_bro_mean <- mask_mean(nirv_2016, mask[[1]])
nirv_2017_bro_mean <- mask_mean(nirv_2017, mask[[1]])

nirv_2013_con_mean <- mask_mean(nirv_2013, mask[[2]])
nirv_2014_con_mean <- mask_mean(nirv_2014, mask[[2]])
nirv_2015_con_mean <- mask_mean(nirv_2015, mask[[2]])
nirv_2016_con_mean <- mask_mean(nirv_2016, mask[[2]])
nirv_2017_con_mean <- mask_mean(nirv_2017, mask[[2]])

# LAI
lai_2013_bro_mean <- mask_mean(lai_2013, mask[[1]])
lai_2014_bro_mean <- mask_mean(lai_2014, mask[[1]])
lai_2015_bro_mean <- mask_mean(lai_2015, mask[[1]])
lai_2016_bro_mean <- mask_mean(lai_2016, mask[[1]])
lai_2017_bro_mean <- mask_mean(lai_2017, mask[[1]])

lai_2013_con_mean <- mask_mean(lai_2013, mask[[2]])
lai_2014_con_mean <- mask_mean(lai_2014, mask[[2]])
lai_2015_con_mean <- mask_mean(lai_2015, mask[[2]])
lai_2016_con_mean <- mask_mean(lai_2016, mask[[2]])
lai_2017_con_mean <- mask_mean(lai_2017, mask[[2]])

# Create the dataframes 
df_2013 <- data.frame(ndvi_2013_bro_mean, ndvi_2013_con_mean, evi_2013_bro_mean, evi_2013_con_mean, nirv_2013_bro_mean, nirv_2013_con_mean, lai_2013_bro_mean, lai_2013_con_mean)
df_2014 <- data.frame(ndvi_2014_bro_mean, ndvi_2014_con_mean, evi_2014_bro_mean, evi_2014_con_mean, nirv_2014_bro_mean, nirv_2014_con_mean, lai_2014_bro_mean, lai_2014_con_mean)
df_2015 <- data.frame(ndvi_2015_bro_mean, ndvi_2015_con_mean, evi_2015_bro_mean, evi_2015_con_mean, nirv_2015_bro_mean, nirv_2015_con_mean, lai_2015_bro_mean, lai_2015_con_mean)
df_2016 <- data.frame(ndvi_2016_bro_mean, ndvi_2016_con_mean, evi_2016_bro_mean, evi_2016_con_mean, nirv_2016_bro_mean, nirv_2016_con_mean, lai_2016_bro_mean, lai_2016_con_mean)
df_2017 <- data.frame(ndvi_2017_bro_mean, ndvi_2017_con_mean, evi_2017_bro_mean, evi_2017_con_mean, nirv_2017_bro_mean, nirv_2017_con_mean, lai_2017_bro_mean, lai_2017_con_mean)

colnames(df_2013) <- new_col_names
colnames(df_2014) <- new_col_names
colnames(df_2015) <- new_col_names
colnames(df_2016) <- new_col_names
colnames(df_2017) <- new_col_names

row.names(df_2013) <- new_row_names
row.names(df_2014) <- new_row_names
row.names(df_2015) <- new_row_names
row.names(df_2016) <- new_row_names
row.names(df_2017) <- new_row_names

# Differences -------------------------------------------------------------
df_2013_differences <- df_2013 - df_ref
df_2014_differences <- df_2014 - df_ref
df_2015_differences <- df_2015 - df_ref
df_2016_differences <- df_2016 - df_ref
df_2017_differences <- df_2017 - df_ref

df_differences <- bind_rows(df_2013_differences,
                            df_2014_differences,
                            df_2015_differences,
                            df_2016_differences,
                            df_2017_differences)

row.names(df_differences) <- c("13/05", "13/06", "13/07", "13/08", "13/09",
                               "14/05", "14/06", "14/07", "14/08", "14/09",
                               "15/05", "15/06", "15/07", "15/08", "15/09",
                               "16/05", "16/06", "16/07", "16/08", "16/09",
                               "17/05", "17/06", "17/07", "17/08", "17/09")

#df_differences$datetimes <- row.names(df_differences)

save(df_differences, file = "data/work/dataframes/df_differences.RData")


