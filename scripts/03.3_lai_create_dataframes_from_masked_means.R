# Packages ----------------------------------------------------------------
library(magrittr)
library(terra)
library(dplyr)

# Getting ready -----------------------------------------------------------

mask_mean = function(raster, mask) {
  x <- raster %>%
    mask(mask) %>%
    global (fun = mean, na.rm = TRUE)
}

# Setting the new names for columns and rows of the resluting dataframe
new_col_names <- c("LAI_Broad","LAI_Conifer", "LAI_Mixed")
new_row_names <- c("May", "June", "July", "August", "September")

# Reference

# Loading the LAI -----------------------------------------------------
lai <- rast(list.files(path = "data/work/reference/lai/qa1/p13y/", pattern = "LAI", full.names = TRUE))

# 30 percent coverage masking -----------------------------------------------------
# Loading the mask
mask <- rast("data/work/mask/mask_30p.tif")

# Mask and Mean
lai_bro_mean <- mask_mean(lai, mask[[1]])
lai_con_mean <- mask_mean(lai, mask[[2]])
lai_mix_mean <- mask_mean(lai, mask[[3]])

# Create the dataframe
df_ref <- data.frame(lai_bro_mean, lai_con_mean, lai_mix_mean)
colnames(df_ref)  <- new_col_names
row.names(df_ref) <- new_row_names

## Save the dataframe
df_ref_30p <- df_ref

# 50 percent coverage masking -----------------------------------------------------
# Loading the mask
mask <- rast("data/work/mask/mask_50p.tif")

# Mask and Mean
lai_bro_mean <- mask_mean(lai, mask[[1]])
lai_con_mean <- mask_mean(lai, mask[[2]])
lai_mix_mean <- mask_mean(lai, mask[[3]])

# Create the dataframe
df_ref <- data.frame(lai_bro_mean, lai_con_mean, lai_mix_mean)
colnames(df_ref)  <- new_col_names
row.names(df_ref) <- new_row_names

## Save the dataframe
df_ref_50p <- df_ref

# 66 percent coverage masking -----------------------------------------------------
# Loading the mask
mask <- rast("data/work/mask/mask_66p.tif")

# Mask and Mean
lai_bro_mean <- mask_mean(lai, mask[[1]])
lai_con_mean <- mask_mean(lai, mask[[2]])
lai_mix_mean <- mask_mean(lai, mask[[3]])

# Create the dataframe
df_ref <- data.frame(lai_bro_mean, lai_con_mean, lai_mix_mean)
colnames(df_ref)  <- new_col_names
row.names(df_ref) <- new_row_names

## Save the dataframe
df_ref_66p <- df_ref

# 70 percent coverage masking -----------------------------------------------------
# Loading the mask
mask <- rast("data/work/mask/mask_70p.tif")

# Mask and Mean
lai_bro_mean <- mask_mean(lai, mask[[1]])
lai_con_mean <- mask_mean(lai, mask[[2]])
lai_mix_mean <- mask_mean(lai, mask[[3]])

# Create the dataframe
df_ref <- data.frame(lai_bro_mean, lai_con_mean, lai_mix_mean)
colnames(df_ref)  <- new_col_names
row.names(df_ref) <- new_row_names

## Save the dataframe
df_ref_70p <- df_ref

# 90 percent coverage masking -----------------------------------------------------
# Loading the mask
mask <- rast("data/work/mask/mask_90p.tif")

# Mask and Mean
lai_bro_mean <- mask_mean(lai, mask[[1]])
lai_con_mean <- mask_mean(lai, mask[[2]])
lai_mix_mean <- mask_mean(lai, mask[[3]])

# Create the dataframe
df_ref <- data.frame(lai_bro_mean, lai_con_mean, lai_mix_mean)
colnames(df_ref)  <- new_col_names
row.names(df_ref) <- new_row_names

## Save the dataframe
df_ref_90p <- df_ref

# 99 percent coverage masking -----------------------------------------------------
# Loading the mask
mask <- rast("data/work/mask/mask_99p.tif")

# Mask and Mean
lai_bro_mean <- mask_mean(lai, mask[[1]])
lai_con_mean <- mask_mean(lai, mask[[2]])
lai_mix_mean <- mask_mean(lai, mask[[3]])

# Create the dataframe
df_ref <- data.frame(lai_bro_mean, lai_con_mean, lai_mix_mean)
colnames(df_ref)  <- new_col_names
row.names(df_ref) <- new_row_names

## Save the dataframe
df_ref_99p <- df_ref

# Combine the reference dataframes.  -----------------------------------------------------

new_col_names_30p <- c("LAI_Broad_30p","LAI_Conifer_30p", "LAI_Mixed_30p")
new_col_names_50p <- c("LAI_Broad_50p","LAI_Conifer_50p", "LAI_Mixed_50p")
new_col_names_66p <- c("LAI_Broad_66p","LAI_Conifer_66p", "LAI_Mixed_66p")
new_col_names_70p <- c("LAI_Broad_70p","LAI_Conifer_70p", "LAI_Mixed_70p")
new_col_names_90p <- c("LAI_Broad_90p","LAI_Conifer_90p", "LAI_Mixed_90p")
new_col_names_99p <- c("LAI_Broad_99p","LAI_Conifer_99p", "LAI_Mixed_99p")

colnames(df_ref_30p) <- new_col_names_30p
colnames(df_ref_50p) <- new_col_names_50p
colnames(df_ref_66p) <- new_col_names_66p
colnames(df_ref_70p) <- new_col_names_70p
colnames(df_ref_90p) <- new_col_names_90p
colnames(df_ref_99p) <- new_col_names_99p

df_ref_combined <- cbind(df_ref_30p, df_ref_50p, df_ref_66p, df_ref_70p, df_ref_90p, df_ref_99p)


# Study period. -----------------------------------------------------------

# Loading the lai pictures per year and index-----------------------------------------------------
path <- "data/work/study/lai/qa1/p1m/"

lai_2013 <- rast(list.files(path = path, pattern = "LAI_2013", full.names = TRUE))
lai_2014 <- rast(list.files(path = path, pattern = "LAI_2014", full.names = TRUE))
lai_2015 <- rast(list.files(path = path, pattern = "LAI_2015", full.names = TRUE))
lai_2016 <- rast(list.files(path = path, pattern = "LAI_2016", full.names = TRUE))
lai_2017 <- rast(list.files(path = path, pattern = "LAI_2017", full.names = TRUE))

# 30 percent coverage masking -----------------------------------------------------
# Loading the mask
mask <- rast("data/work/mask/mask_30p.tif")

# Mask and Mean
# NDVI
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

lai_2013_mix_mean <- mask_mean(lai_2013, mask[[3]])
lai_2014_mix_mean <- mask_mean(lai_2014, mask[[3]])
lai_2015_mix_mean <- mask_mean(lai_2015, mask[[3]])
lai_2016_mix_mean <- mask_mean(lai_2016, mask[[3]])
lai_2017_mix_mean <- mask_mean(lai_2017, mask[[3]])

# Create the dataframes 
df_2013 <- data.frame(lai_2013_bro_mean, lai_2013_con_mean, lai_2013_mix_mean)
df_2014 <- data.frame(lai_2014_bro_mean, lai_2014_con_mean, lai_2014_mix_mean)
df_2015 <- data.frame(lai_2015_bro_mean, lai_2015_con_mean, lai_2015_mix_mean)
df_2016 <- data.frame(lai_2016_bro_mean, lai_2016_con_mean, lai_2016_mix_mean)
df_2017 <- data.frame(lai_2017_bro_mean, lai_2017_con_mean, lai_2017_mix_mean)

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

df_2013_30p <- df_2013
df_2014_30p <- df_2014
df_2015_30p <- df_2015
df_2016_30p <- df_2016
df_2017_30p <- df_2017
# 50 percent coverage masking -----------------------------------------------------
# Loading the mask
mask <- rast("data/work/mask/mask_50p.tif")

# Mask and Mean
# NDVI
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

lai_2013_mix_mean <- mask_mean(lai_2013, mask[[3]])
lai_2014_mix_mean <- mask_mean(lai_2014, mask[[3]])
lai_2015_mix_mean <- mask_mean(lai_2015, mask[[3]])
lai_2016_mix_mean <- mask_mean(lai_2016, mask[[3]])
lai_2017_mix_mean <- mask_mean(lai_2017, mask[[3]])

# Create the dataframes 
df_2013 <- data.frame(lai_2013_bro_mean, lai_2013_con_mean, lai_2013_mix_mean)
df_2014 <- data.frame(lai_2014_bro_mean, lai_2014_con_mean, lai_2014_mix_mean)
df_2015 <- data.frame(lai_2015_bro_mean, lai_2015_con_mean, lai_2015_mix_mean)
df_2016 <- data.frame(lai_2016_bro_mean, lai_2016_con_mean, lai_2016_mix_mean)
df_2017 <- data.frame(lai_2017_bro_mean, lai_2017_con_mean, lai_2017_mix_mean)

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

df_2013_50p <- df_2013
df_2014_50p <- df_2014
df_2015_50p <- df_2015
df_2016_50p <- df_2016
df_2017_50p <- df_2017
# 66 percent coverage masking -----------------------------------------------------
# Loading the mask
mask <- rast("data/work/mask/mask_66p.tif")

# Mask and Mean
# NDVI
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

lai_2013_mix_mean <- mask_mean(lai_2013, mask[[3]])
lai_2014_mix_mean <- mask_mean(lai_2014, mask[[3]])
lai_2015_mix_mean <- mask_mean(lai_2015, mask[[3]])
lai_2016_mix_mean <- mask_mean(lai_2016, mask[[3]])
lai_2017_mix_mean <- mask_mean(lai_2017, mask[[3]])

# Create the dataframes 
df_2013 <- data.frame(lai_2013_bro_mean, lai_2013_con_mean, lai_2013_mix_mean)
df_2014 <- data.frame(lai_2014_bro_mean, lai_2014_con_mean, lai_2014_mix_mean)
df_2015 <- data.frame(lai_2015_bro_mean, lai_2015_con_mean, lai_2015_mix_mean)
df_2016 <- data.frame(lai_2016_bro_mean, lai_2016_con_mean, lai_2016_mix_mean)
df_2017 <- data.frame(lai_2017_bro_mean, lai_2017_con_mean, lai_2017_mix_mean)

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

df_2013_66p <- df_2013
df_2014_66p <- df_2014
df_2015_66p <- df_2015
df_2016_66p <- df_2016
df_2017_66p <- df_2017
# 70 percent coverage masking -----------------------------------------------------
# Loading the mask
mask <- rast("data/work/mask/mask_70p.tif")

# Mask and Mean
# NDVI
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

lai_2013_mix_mean <- mask_mean(lai_2013, mask[[3]])
lai_2014_mix_mean <- mask_mean(lai_2014, mask[[3]])
lai_2015_mix_mean <- mask_mean(lai_2015, mask[[3]])
lai_2016_mix_mean <- mask_mean(lai_2016, mask[[3]])
lai_2017_mix_mean <- mask_mean(lai_2017, mask[[3]])

# Create the dataframes 
df_2013 <- data.frame(lai_2013_bro_mean, lai_2013_con_mean, lai_2013_mix_mean)
df_2014 <- data.frame(lai_2014_bro_mean, lai_2014_con_mean, lai_2014_mix_mean)
df_2015 <- data.frame(lai_2015_bro_mean, lai_2015_con_mean, lai_2015_mix_mean)
df_2016 <- data.frame(lai_2016_bro_mean, lai_2016_con_mean, lai_2016_mix_mean)
df_2017 <- data.frame(lai_2017_bro_mean, lai_2017_con_mean, lai_2017_mix_mean)

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

df_2013_70p <- df_2013
df_2014_70p <- df_2014
df_2015_70p <- df_2015
df_2016_70p <- df_2016
df_2017_70p <- df_2017
# 90 percent coverage masking -----------------------------------------------------
# Loading the mask
mask <- rast("data/work/mask/mask_90p.tif")

# Mask and Mean
# NDVI
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

lai_2013_mix_mean <- mask_mean(lai_2013, mask[[3]])
lai_2014_mix_mean <- mask_mean(lai_2014, mask[[3]])
lai_2015_mix_mean <- mask_mean(lai_2015, mask[[3]])
lai_2016_mix_mean <- mask_mean(lai_2016, mask[[3]])
lai_2017_mix_mean <- mask_mean(lai_2017, mask[[3]])

# Create the dataframes 
df_2013 <- data.frame(lai_2013_bro_mean, lai_2013_con_mean, lai_2013_mix_mean)
df_2014 <- data.frame(lai_2014_bro_mean, lai_2014_con_mean, lai_2014_mix_mean)
df_2015 <- data.frame(lai_2015_bro_mean, lai_2015_con_mean, lai_2015_mix_mean)
df_2016 <- data.frame(lai_2016_bro_mean, lai_2016_con_mean, lai_2016_mix_mean)
df_2017 <- data.frame(lai_2017_bro_mean, lai_2017_con_mean, lai_2017_mix_mean)

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

df_2013_90p <- df_2013
df_2014_90p <- df_2014
df_2015_90p <- df_2015
df_2016_90p <- df_2016
df_2017_90p <- df_2017
# 99 percent coverage masking -----------------------------------------------------
# Loading the mask
mask <- rast("data/work/mask/mask_99p.tif")

# Mask and Mean
# NDVI
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

lai_2013_mix_mean <- mask_mean(lai_2013, mask[[3]])
lai_2014_mix_mean <- mask_mean(lai_2014, mask[[3]])
lai_2015_mix_mean <- mask_mean(lai_2015, mask[[3]])
lai_2016_mix_mean <- mask_mean(lai_2016, mask[[3]])
lai_2017_mix_mean <- mask_mean(lai_2017, mask[[3]])

# Create the dataframes 
df_2013 <- data.frame(lai_2013_bro_mean, lai_2013_con_mean, lai_2013_mix_mean)
df_2014 <- data.frame(lai_2014_bro_mean, lai_2014_con_mean, lai_2014_mix_mean)
df_2015 <- data.frame(lai_2015_bro_mean, lai_2015_con_mean, lai_2015_mix_mean)
df_2016 <- data.frame(lai_2016_bro_mean, lai_2016_con_mean, lai_2016_mix_mean)
df_2017 <- data.frame(lai_2017_bro_mean, lai_2017_con_mean, lai_2017_mix_mean)

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

df_2013_99p <- df_2013
df_2014_99p <- df_2014
df_2015_99p <- df_2015
df_2016_99p <- df_2016
df_2017_99p <- df_2017

# Combine study dataframes. -----------------------------------------------

df_2013_combined <- cbind(df_2013_30p, df_2013_50p, df_2013_66p, df_2013_70p, df_2013_90p, df_2013_99p)
df_2014_combined <- cbind(df_2014_30p, df_2014_50p, df_2014_66p, df_2014_70p, df_2014_90p, df_2014_99p)
df_2015_combined <- cbind(df_2015_30p, df_2015_50p, df_2015_66p, df_2015_70p, df_2015_90p, df_2015_99p)
df_2016_combined <- cbind(df_2016_30p, df_2016_50p, df_2016_66p, df_2016_70p, df_2016_90p, df_2016_99p)
df_2017_combined <- cbind(df_2017_30p, df_2017_50p, df_2017_66p, df_2017_70p, df_2017_90p, df_2017_99p)

newcolnames <- c("LAI_Broad_30p","LAI_Conifer_30p", "LAI_Mixed_30p",
                 "LAI_Broad_50p","LAI_Conifer_50p", "LAI_Mixed_50p",
                 "LAI_Broad_66p","LAI_Conifer_66p", "LAI_Mixed_66p",
                 "LAI_Broad_70p","LAI_Conifer_70p", "LAI_Mixed_70p",
                 "LAI_Broad_90p","LAI_Conifer_90p", "LAI_Mixed_90p",
                 "LAI_Broad_99p","LAI_Conifer_99p", "LAI_Mixed_99p")

colnames(df_2013_combined) <- newcolnames
colnames(df_2014_combined) <- newcolnames
colnames(df_2015_combined) <- newcolnames
colnames(df_2016_combined) <- newcolnames
colnames(df_2017_combined) <- newcolnames

# Differences -------------------------------------------------------------

df_2013_differences <- df_2013_combined - df_ref_combined
df_2014_differences <- df_2014_combined - df_ref_combined
df_2015_differences <- df_2015_combined - df_ref_combined
df_2016_differences <- df_2016_combined - df_ref_combined
df_2017_differences <- df_2017_combined - df_ref_combined

df_lai_differences_qa1 <- bind_rows(df_2013_differences,
                            df_2014_differences,
                            df_2015_differences,
                            df_2016_differences,
                            df_2017_differences)

row.names(df_lai_differences_qa1) <- c("13/05", "13/06", "13/07", "13/08", "13/09",
                               "14/05", "14/06", "14/07", "14/08", "14/09",
                               "15/05", "15/06", "15/07", "15/08", "15/09",
                               "16/05", "16/06", "16/07", "16/08", "16/09",
                               "17/05", "17/06", "17/07", "17/08", "17/09")

#df_differences$datetimes <- row.names(df_differences)

save(df_lai_differences_qa1, file = "data/work/dataframes/df_lai_differences_qa1.RData")