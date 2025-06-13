# Harmonising the differences of each index.

# Packages ----------------------------------------------------------------
library(terra)     # raster
library(dplyr)


# Loading data. -----------------------------------------------------------
# Loading the differences.
load("data/work/df_differences.RData")

# Loading the indices.
ndvi <- rast(list.files(path = "data/work/reference/indices", pattern = "NDVI", full.names = TRUE)) 
evi <- rast(list.files(path = "data/work/reference/indices", pattern = "EVI", full.names = TRUE))
nirv <- rast(list.files(path = "data/work/reference/indices", pattern = "NIRv", full.names = TRUE))

# 30 percent pixel coverage ---------------------------------------------
mask <- rast("data/work/mask_30p.tif")

ndvi_bro <- mask(ndvi, mask[[1]])
ndvi_con <- mask(ndvi, mask[[2]])
ndvi_mix <- mask(ndvi, mask[[3]])

evi_bro <- mask(evi, mask[[1]])
evi_con <- mask(evi, mask[[2]])
evi_mix <- mask(evi, mask[[3]])

nirv_bro <- mask(nirv, mask[[1]])
nirv_con <- mask(nirv, mask[[2]])
nirv_mix <- mask(nirv, mask[[3]])


# Ranger. -----------------------------------------------------------------

ranger = function(x) {
  range <- global(x, "max", na.rm = TRUE) - global(x, "min", na.rm = TRUE)
}

range_ndvi_bro <- ranger(ndvi_bro)
range_ndvi_con <- ranger(ndvi_con)
range_ndvi_mix <- ranger(ndvi_mix)

range_evi_bro <- ranger(evi_bro)
range_evi_con <- ranger(evi_con)
range_evi_mix <- ranger(evi_mix)

range_nirv_bro <- ranger(nirv_bro)
range_nirv_con <- ranger(nirv_con)
range_nirv_mix <- ranger(nirv_mix)

ranges_combined <- data.frame(range_evi_bro, range_evi_con, range_evi_mix,
                              ramge_ndvi_bro, range_ndvi_con)

df_dif_2013 <- slice(df_differences, 1:5)
df_dif_2014 <- slice(df_differences, 6:10)
df_dif_2015 <- slice(df_differences, 11:15)
df_dif_2016 <- slice(df_differences, 16:20)
df_dif_2017 <- slice(df_differemce, 20:25)

df_dif_2013_percent <- (dif_)

dif_ndvi_bro_30p_2013_harmonised <- (dif_ndvi_bro_30p_2013/range_bro)*100

### df_differences aufteilen nach Jahren, ranges kombinieren sodass
# Format mit df_differences_YYYY übereinstimmt, dann verrechnen

