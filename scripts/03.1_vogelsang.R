# Test the differences analysis for the forest loss area near vogelsang magdeburg

# Tables
library(dplyr)
library(tidyr)
library(gdata)

# Spatial data
library(sf)
library(terra)
library(gdalcubes)

sf <- st_read("data/raw/forest_loss/forest_loss.shp")
sf <- st_transform(sf, "+proj=sinu +lon_0=0 +x_0=0 +y_0=0 +R=6371007.181 +units=m +no_defs")

# Reference
# Get the paths

path = "data/work/reference/indices/"

paths_ndvi <- list.files(path = path, pattern = "NDVI_", full.names = TRUE)
paths_evi <- list.files(path = path, pattern = "EVI_", full.names = TRUE)
paths_nirv <- list.files(path = path, pattern = "NIRv_", full.names = TRUE)

# Stack the cubes, one cubes for each month over the whole reference period.
cube_ndvi <- stack_cube(paths_ndvi, datetime_values = c("2000-05-01", "2000-06-01", "2000-07-01", "2000-08-01", "2000-09-01"))
cube_evi <- stack_cube(paths_evi, datetime_values = c("2000-05-01", "2000-06-01", "2000-07-01", "2000-08-01", "2000-09-01"))
cube_nirv <- stack_cube(paths_nirv, datetime_values = c("2000-05-01", "2000-06-01", "2000-07-01", "2000-08-01", "2000-09-01"))

# Getting the ranges of each index per month

ranger = function(cube, sf) {
  vals <- extract_geom(cube, sf)%>%
    arrange(time)
  
  vals_05 <- vals %>% 
    filter(time == "2000-05-01")
  
  vals_06 <- vals %>% 
    filter(time == "2000-06-01")
  
  vals_07 <- vals %>% 
    filter(time == "2000-07-01")
  
  vals_08 <- vals %>% 
    filter(time == "2000-08-01")
  
  vals_09 <- vals %>% 
    filter(time == "2000-09-01")
  
  range_05 <- max(vals_05$x1) - min(vals_05$x1)
  range_06 <- max(vals_06$x1) - min(vals_06$x1)
  range_07 <- max(vals_07$x1) - min(vals_07$x1)
  range_08 <- max(vals_08$x1) - min(vals_08$x1)
  range_09 <- max(vals_09$x1) - min(vals_09$x1)
  
  return(c(range_05, range_06, range_07, range_08, range_09))
  
}

ndvi_ranges <- ranger(cube_ndvi, sf)
evi_ranges <- ranger(cube_evi, sf)
nirv_ranges <- ranger(cube_nirv, sf)

# Combine the ranges
df_ranges <- data.frame(ndvi = ndvi_ranges, evi = evi_ranges, irv = nirv_ranges)
                        
# extracing cubes values by polygon
ref_ndvi_means <- extract_geom(cube_ndvi, sf, FUN = mean)
ref_evi_means <- extract_geom(cube_evi, sf, FUN = mean)
ref_nirv_means <- extract_geom(cube_nirv, sf, FUN = mean)

# Study

# Get the paths

path = "data/work/study/indices/"

paths_ndvi <- list.files(path = path, pattern = "NDVI_", full.names = TRUE)
paths_evi <- list.files(path = path, pattern = "EVI_", full.names = TRUE)
paths_nirv <- list.files(path = path, pattern = "NIRv_", full.names = TRUE)

# Stack the cubes, one cubes for each month over the whole reference period.
datetime_values = c("2013-05-01", "2013-06-01", "2013-07-01", "2013-08-01", "2013-09-01",
                    "2014-05-01", "2014-06-01", "2014-07-01", "2014-08-01", "2014-09-01",
                    "2015-05-01", "2015-06-01", "2015-07-01", "2015-08-01", "2015-09-01",
                    "2016-05-01", "2016-06-01", "2016-07-01", "2016-08-01", "2016-09-01",
                    "2017-05-01", "2017-06-01", "2017-07-01", "2017-08-01", "2017-09-01")


cube_ndvi <- stack_cube(paths_ndvi, datetime_values = datetime_values)
cube_evi <- stack_cube(paths_evi, datetime_values = datetime_values)
cube_nirv <- stack_cube(paths_nirv, datetime_values = datetime_values)

ndvi_means <- extract_geom(cube_ndvi, sf, FUN = mean)
evi_means <- extract_geom(cube_evi, sf, FUN = mean)
nirv_means <- extract_geom(cube_nirv, sf, FUN = mean)

df_differences <- data.frame(ndvi = c(ndvi_means$x1 - ref_ndvi_means$x1),
                          evi = c(evi_means$x1 - ref_evi_means$x1),
                          nirv = c(nirv_means$x1 - ref_nirv_means$x1))


# Differences raw.
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

df_differences_harmonised$date <- as.Date(paste0(datetime_values))

df_differences_harmonised_long <- df_differences_harmonised %>%
  pivot_longer(
    cols = c(ndvi, evi, nirv),
    names_to = "index",
    values_to = "difference"
  )

save(df_differences_harmonised_long, file = "data/work/dataframes/df_diff_harm_long_vogelsang.RData")

