# Harmonising the differences of each index.

# Packages ----------------------------------------------------------------
library(terra)     # raster
library(dplyr)
library(tidyr)


# Loading data. -----------------------------------------------------------
# Loading the differences.
load("data/work/dataframes/df_differences.RData")


# Loading the indices.
ndvi <- rast(list.files(path = "data/work/reference/indices", pattern = "NDVI", full.names = TRUE)) 
evi <- rast(list.files(path = "data/work/reference/indices", pattern = "EVI", full.names = TRUE))
nirv <- rast(list.files(path = "data/work/reference/indices", pattern = "NIRv", full.names = TRUE))

# Create function to get ranges  -----------------------------------------------------------

ranger = function(x) {
  range <- global(x, "max", na.rm = TRUE) - global(x, "min", na.rm = TRUE)
}

# 30p ---------------------------------------------
mask <- rast("data/work/mask/mask_30p.tif")

ndvi_bro <- mask(ndvi, mask[[1]])
ndvi_con <- mask(ndvi, mask[[2]])
ndvi_mix <- mask(ndvi, mask[[3]])

evi_bro <- mask(evi, mask[[1]])
evi_con <- mask(evi, mask[[2]])
evi_mix <- mask(evi, mask[[3]])

nirv_bro <- mask(nirv, mask[[1]])
nirv_con <- mask(nirv, mask[[2]])
nirv_mix <- mask(nirv, mask[[3]])

# Get ranges.

range_ndvi_bro <- ranger(ndvi_bro)
range_ndvi_con <- ranger(ndvi_con)
range_ndvi_mix <- ranger(ndvi_mix)

range_evi_bro <- ranger(evi_bro)
range_evi_con <- ranger(evi_con)
range_evi_mix <- ranger(evi_mix)

range_nirv_bro <- ranger(nirv_bro)
range_nirv_con <- ranger(nirv_con)
range_nirv_mix <- ranger(nirv_mix)

ranges <- data.frame(range_ndvi_bro, range_ndvi_con, range_ndvi_mix,
                     range_evi_bro, range_evi_con, range_evi_mix,
                     range_nirv_bro, range_nirv_con, range_nirv_mix)

ranges_30p <- ranges

# 50p  ---------------------------------------------
mask <- rast("data/work/mask/mask_50p.tif")

ndvi_bro <- mask(ndvi, mask[[1]])
ndvi_con <- mask(ndvi, mask[[2]])
ndvi_mix <- mask(ndvi, mask[[3]])

evi_bro <- mask(evi, mask[[1]])
evi_con <- mask(evi, mask[[2]])
evi_mix <- mask(evi, mask[[3]])

nirv_bro <- mask(nirv, mask[[1]])
nirv_con <- mask(nirv, mask[[2]])
nirv_mix <- mask(nirv, mask[[3]])

# Get ranges.

range_ndvi_bro <- ranger(ndvi_bro)
range_ndvi_con <- ranger(ndvi_con)
range_ndvi_mix <- ranger(ndvi_mix)

range_evi_bro <- ranger(evi_bro)
range_evi_con <- ranger(evi_con)
range_evi_mix <- ranger(evi_mix)

range_nirv_bro <- ranger(nirv_bro)
range_nirv_con <- ranger(nirv_con)
range_nirv_mix <- ranger(nirv_mix)

ranges <- data.frame(range_ndvi_bro, range_ndvi_con, range_ndvi_mix,
                     range_evi_bro, range_evi_con, range_evi_mix,
                     range_nirv_bro, range_nirv_con, range_nirv_mix)

ranges_50p <- ranges

# 66p  ---------------------------------------------
mask <- rast("data/work/mask/mask_66p.tif")

ndvi_bro <- mask(ndvi, mask[[1]])
ndvi_con <- mask(ndvi, mask[[2]])
ndvi_mix <- mask(ndvi, mask[[3]])

evi_bro <- mask(evi, mask[[1]])
evi_con <- mask(evi, mask[[2]])
evi_mix <- mask(evi, mask[[3]])

nirv_bro <- mask(nirv, mask[[1]])
nirv_con <- mask(nirv, mask[[2]])
nirv_mix <- mask(nirv, mask[[3]])

# Get ranges.

range_ndvi_bro <- ranger(ndvi_bro)
range_ndvi_con <- ranger(ndvi_con)
range_ndvi_mix <- ranger(ndvi_mix)

range_evi_bro <- ranger(evi_bro)
range_evi_con <- ranger(evi_con)
range_evi_mix <- ranger(evi_mix)

range_nirv_bro <- ranger(nirv_bro)
range_nirv_con <- ranger(nirv_con)
range_nirv_mix <- ranger(nirv_mix)

ranges <- data.frame(range_ndvi_bro, range_ndvi_con, range_ndvi_mix,
                     range_evi_bro, range_evi_con, range_evi_mix,
                     range_nirv_bro, range_nirv_con, range_nirv_mix)

ranges_66p <- ranges

# 70p  ---------------------------------------------
mask <- rast("data/work/mask/mask_70p.tif")

ndvi_bro <- mask(ndvi, mask[[1]])
ndvi_con <- mask(ndvi, mask[[2]])
ndvi_mix <- mask(ndvi, mask[[3]])

evi_bro <- mask(evi, mask[[1]])
evi_con <- mask(evi, mask[[2]])
evi_mix <- mask(evi, mask[[3]])

nirv_bro <- mask(nirv, mask[[1]])
nirv_con <- mask(nirv, mask[[2]])
nirv_mix <- mask(nirv, mask[[3]])

# Get ranges.

range_ndvi_bro <- ranger(ndvi_bro)
range_ndvi_con <- ranger(ndvi_con)
range_ndvi_mix <- ranger(ndvi_mix)

range_evi_bro <- ranger(evi_bro)
range_evi_con <- ranger(evi_con)
range_evi_mix <- ranger(evi_mix)

range_nirv_bro <- ranger(nirv_bro)
range_nirv_con <- ranger(nirv_con)
range_nirv_mix <- ranger(nirv_mix)

ranges <- data.frame(range_ndvi_bro, range_ndvi_con, range_ndvi_mix,
                     range_evi_bro, range_evi_con, range_evi_mix,
                     range_nirv_bro, range_nirv_con, range_nirv_mix)

ranges_70p <- ranges

# 90p  ---------------------------------------------
mask <- rast("data/work/mask/mask_90p.tif")

ndvi_bro <- mask(ndvi, mask[[1]])
ndvi_con <- mask(ndvi, mask[[2]])
ndvi_mix <- mask(ndvi, mask[[3]])

evi_bro <- mask(evi, mask[[1]])
evi_con <- mask(evi, mask[[2]])
evi_mix <- mask(evi, mask[[3]])

nirv_bro <- mask(nirv, mask[[1]])
nirv_con <- mask(nirv, mask[[2]])
nirv_mix <- mask(nirv, mask[[3]])

# Get ranges.

range_ndvi_bro <- ranger(ndvi_bro)
range_ndvi_con <- ranger(ndvi_con)
range_ndvi_mix <- ranger(ndvi_mix)

range_evi_bro <- ranger(evi_bro)
range_evi_con <- ranger(evi_con)
range_evi_mix <- ranger(evi_mix)

range_nirv_bro <- ranger(nirv_bro)
range_nirv_con <- ranger(nirv_con)
range_nirv_mix <- ranger(nirv_mix)

ranges <- data.frame(range_ndvi_bro, range_ndvi_con, range_ndvi_mix,
                     range_evi_bro, range_evi_con, range_evi_mix,
                     range_nirv_bro, range_nirv_con, range_nirv_mix)

ranges_90p <- ranges

# 99p  ---------------------------------------------
mask <- rast("data/work/mask/mask_99p.tif")

ndvi_bro <- mask(ndvi, mask[[1]])
ndvi_con <- mask(ndvi, mask[[2]])
ndvi_mix <- mask(ndvi, mask[[3]])

evi_bro <- mask(evi, mask[[1]])
evi_con <- mask(evi, mask[[2]])
evi_mix <- mask(evi, mask[[3]])

nirv_bro <- mask(nirv, mask[[1]])
nirv_con <- mask(nirv, mask[[2]])
nirv_mix <- mask(nirv, mask[[3]])

# Get ranges.

range_ndvi_bro <- ranger(ndvi_bro)
range_ndvi_con <- ranger(ndvi_con)
range_ndvi_mix <- ranger(ndvi_mix)

range_evi_bro <- ranger(evi_bro)
range_evi_con <- ranger(evi_con)
range_evi_mix <- ranger(evi_mix)

range_nirv_bro <- ranger(nirv_bro)
range_nirv_con <- ranger(nirv_con)
range_nirv_mix <- ranger(nirv_mix)

ranges <- data.frame(range_ndvi_bro, range_ndvi_con, range_ndvi_mix,
                     range_evi_bro, range_evi_con, range_evi_mix,
                     range_nirv_bro, range_nirv_con, range_nirv_mix)

ranges_99p <- ranges


df_ranges <- bind_cols(ranges_30p, ranges_50p, ranges_66p, ranges_70p, ranges_90p, ranges_99p)

rownames(df_ranges) <- c("05", "06", "07", "08", "09")
colnames(df_ranges) <- c("NDVI_Broad_30p","NDVI_Conifer_30p", "NDVI_Mixed_30p", "EVI_Broad_30p","EVI_Conifer_30p", "EVI_Mixed_30p", "NIRv_Broad_30p", "NIRv_Conifer_30p", "NIRv_Mixed_30p",
                                  "NDVI_Broad_50p","NDVI_Conifer_50p", "NDVI_Mixed_50p", "EVI_Broad_50p","EVI_Conifer_50p", "EVI_Mixed_50p", "NIRv_Broad_50p", "NIRv_Conifer_50p", "NIRv_Mixed_50p",
                                  "NDVI_Broad_66p","NDVI_Conifer_66p", "NDVI_Mixed_66p", "EVI_Broad_66p","EVI_Conifer_66p", "EVI_Mixed_66p", "NIRv_Broad_66p", "NIRv_Conifer_66p", "NIRv_Mixed_66p",
                                  "NDVI_Broad_70p","NDVI_Conifer_70p", "NDVI_Mixed_70p", "EVI_Broad_70p","EVI_Conifer_70p", "EVI_Mixed_70p", "NIRv_Broad_70p", "NIRv_Conifer_70p", "NIRv_Mixed_70p",
                                  "NDVI_Broad_90p","NDVI_Conifer_90p", "NDVI_Mixed_90p", "EVI_Broad_90p","EVI_Conifer_90p", "EVI_Mixed_90p", "NIRv_Broad_90p", "NIRv_Conifer_90p", "NIRv_Mixed_90p",
                                  "NDVI_Broad_99p","NDVI_Conifer_99p", "NDVI_Mixed_99p", "EVI_Broad_99p","EVI_Conifer_99p", "EVI_Mixed_99p", "NIRv_Broad_99p", "NIRv_Conifer_99p", "NIRv_Mixed_99p")


# Harmonising -------------------------------------------------------------

# Slice for each years.
df_dif_2013 <- slice(df_differences, 1:5)
df_dif_2014 <- slice(df_differences, 6:10)
df_dif_2015 <- slice(df_differences, 11:15)
df_dif_2016 <- slice(df_differences, 16:20)
df_dif_2017 <- slice(df_differences, 21:25)

df_dif_2013_harmonised <- (df_dif_2013/df_ranges)*100
df_dif_2014_harmonised <- (df_dif_2014/df_ranges)*100
df_dif_2015_harmonised <- (df_dif_2015/df_ranges)*100
df_dif_2016_harmonised <- (df_dif_2016/df_ranges)*100
df_dif_2017_harmonised <- (df_dif_2017/df_ranges)*100

df_differences_harmonised <- bind_rows(df_dif_2013_harmonised, df_dif_2014_harmonised, df_dif_2015_harmonised, df_dif_2016_harmonised, df_dif_2017_harmonised)

save(df_ranges, file ="data/work/dataframes/df_ranges.RData")
save(df_differences_harmonised, file = "data/work/dataframes/df_differences_harmonised.RData")

##################################################################################################
##################################################################################################
# test for pivot_longer

load("data/work/dataframes/df_differences_harmonised.RData")

# Stack the cubes, one cubes for each month over the whole reference period.
datetime_values = c("2013-05-01", "2013-06-01", "2013-07-01", "2013-08-01", "2013-09-01",
                    "2014-05-01", "2014-06-01", "2014-07-01", "2014-08-01", "2014-09-01",
                    "2015-05-01", "2015-06-01", "2015-07-01", "2015-08-01", "2015-09-01",
                    "2016-05-01", "2016-06-01", "2016-07-01", "2016-08-01", "2016-09-01",
                    "2017-05-01", "2017-06-01", "2017-07-01", "2017-08-01", "2017-09-01")

df_differences_harmonised$date <- as.Date(paste0(datetime_values))

df_dif_har_66p <- df_differences_harmonised %>% 
  select(date, contains("66"))
  
  
df_dif_har_66p_long <- df_dif_har_66p %>%
  pivot_longer(
    cols = -date,
    names_to = c("Index", "Vegetation", "Percentile"),
    names_sep = "_",
    values_to = "value"
  )

save(df_dif_har_66p_long, file = "data/work/dataframes/df_dif_har_66p_long.RData")


