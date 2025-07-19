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
paths_evi  <- list.files(path = path, pattern = "EVI_",  full.names = TRUE)
paths_nirv <- list.files(path = path, pattern = "NIRv_", full.names = TRUE)

# Stack the cubes, one cubes for each month over the whole reference period.
months <- 5:9

cube_ndvi <- stack_cube(paths_ndvi, datetime_values = paste0("2000-0", months))
cube_evi  <- stack_cube(paths_evi,  datetime_values = paste0("2000-0", months))
cube_nirv <- stack_cube(paths_nirv, datetime_values = paste0("2000-0", months))

# extracing cubes values by polygon
ref_ndvi_means <- extract_geom(cube_ndvi, sf, FUN = mean)
ref_ndvi_means <- ref_ndvi_means %>% rename(ndvi = x1)

ref_evi_means <- extract_geom(cube_evi, sf, FUN = mean)
ref_evi_means <- ref_evi_means %>% rename(evi = x1)

ref_nirv_means <- extract_geom(cube_nirv, sf, FUN = mean)
ref_nirv_means <- ref_nirv_means %>% rename(nirv = x1)

df_ref <- ref_ndvi_means %>%
  left_join(ref_evi_means, by = c("FID", "time")) %>%
  left_join(ref_nirv_means, by = c("FID", "time"))

rownames(df_ref) <- df_ref$time

df_ref <- df_ref %>% 
  select(ndvi, evi, nirv)
  
# Study
# Get the path
path = "data/work/study/indices/"

paths_ndvi <- list.files(path = path, pattern = "NDVI_", full.names = TRUE)
paths_evi  <- list.files(path = path, pattern = "EVI_",  full.names = TRUE)
paths_nirv <- list.files(path = path, pattern = "NIRv_", full.names = TRUE)

# Stack the cubes, one cubes for each month over the whole reference period.
months <- 5:9
years <- 2013:2017

datetime_values <- as.vector(sapply(years, function(y) sprintf("%d-%02d-01", y, months)))

cube_ndvi <- stack_cube(paths_ndvi, datetime_values = datetime_values)
cube_evi  <- stack_cube(paths_evi,  datetime_values = datetime_values)
cube_nirv <- stack_cube(paths_nirv, datetime_values = datetime_values)

ndvi_means <- extract_geom(cube_ndvi, sf, FUN = mean)
ndvi_means <- ndvi_means %>% rename(ndvi = x1)

evi_means <- extract_geom(cube_evi, sf, FUN = mean)
evi_means <- evi_means %>% rename(evi = x1)

nirv_means <- extract_geom(cube_nirv, sf, FUN = mean)
nirv_means <- nirv_means %>% rename(nirv = x1)

df_stu <- ndvi_means %>%
  left_join(evi_means, by = c("FID", "time")) %>%
  left_join(nirv_means, by = c("FID", "time"))

rownames(df_stu) <- df_stu$time
df_stu <- df_stu %>% 
  select(ndvi, evi, nirv)

df_2013 <- df_stu %>% 
  filter(grepl("2013", rownames(df_stu)))

df_2014 <- df_stu %>% 
  filter(grepl("2014", rownames(df_stu)))

df_2015 <- df_stu %>% 
  filter(grepl("2015", rownames(df_stu)))

df_2016 <- df_stu %>% 
  filter(grepl("2016", rownames(df_stu)))

df_2017 <- df_stu %>% 
  filter(grepl("2017", rownames(df_stu)))

# Differences raw.
df_dif_2013_abs <- df_2013 - df_ref
df_dif_2014_abs <- df_2014 - df_ref
df_dif_2015_abs <- df_2015 - df_ref
df_dif_2016_abs <- df_2016 - df_ref
df_dif_2017_abs <- df_2017 - df_ref

df_dif_2013_rel <- (df_dif_2013_abs / df_ref)*100
df_dif_2014_rel <- (df_dif_2014_abs / df_ref)*100
df_dif_2015_rel <- (df_dif_2015_abs / df_ref)*100
df_dif_2016_rel <- (df_dif_2016_abs / df_ref)*100
df_dif_2017_rel <- (df_dif_2017_abs / df_ref)*100

# Combine the dataframes

df_dif_abs_loc <- bind_rows(df_dif_2013_abs, 
                            df_dif_2014_abs, 
                            df_dif_2015_abs, 
                            df_dif_2016_abs, 
                            df_dif_2017_abs)

df_dif_rel_loc <- bind_rows(df_dif_2013_rel, 
                            df_dif_2014_rel, 
                            df_dif_2015_rel, 
                            df_dif_2016_rel, 
                            df_dif_2017_rel)

df_dif_abs_loc$time <- as.Date(rownames(df_dif_abs_loc))
df_dif_rel_loc$time <- as.Date(rownames(df_dif_rel_loc))

df_dif_abs_loc_long <- df_dif_abs_loc %>%
  pivot_longer(
    cols = c(ndvi, evi, nirv),
    names_to = "index",
    values_to = "value"
  )

df_dif_rel_loc_long <- df_dif_rel_loc %>%
  pivot_longer(
    cols = c(ndvi, evi, nirv),
    names_to = "index",
    values_to = "value"
  )

keep(df_dif_abs_loc,
     df_dif_rel_loc,
     df_dif_abs_loc_long, 
     df_dif_rel_loc_long, 
     sure = TRUE)

save(df_dif_abs_loc,      file = "data/work/dataframes/df_dif_absolute_local.RData")
save(df_dif_rel_loc,      file = "data/work/dataframes/df_dif_relative_local.RData")

save(df_dif_abs_loc_long, file = "data/work/dataframes/df_dif_absolute_local_long.RData")
save(df_dif_rel_loc_long, file = "data/work/dataframes/df_dif_relative_local_long.RData")
