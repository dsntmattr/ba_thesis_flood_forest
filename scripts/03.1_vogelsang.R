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
months <- 5:9

cube_ndvi <- stack_cube(paths_ndvi, datetime_values = paste0("2000-0", months))
cube_evi <- stack_cube(paths_evi, datetime_values = paste0("2000-0", months))
cube_nirv <- stack_cube(paths_nirv, datetime_values = paste0("2000-0", months))

# extracing cubes values by polygon
ref_ndvi_means <- extract_geom(cube_ndvi, sf, FUN = mean)
ref_ndvi_means$index <- "ndvi"

ref_evi_means <- extract_geom(cube_evi, sf, FUN = mean)
ref_evi_means$index <- "evi"

ref_nirv_means <- extract_geom(cube_nirv, sf, FUN = mean)
ref_nirv_means$index <- "nirv"

df_ref <- bind_rows(ref_ndvi_means, ref_evi_means, ref_nirv_means)

df_ref$FID <- NULL

# Study

# Get the path
path = "data/work/study/indices/"

paths_ndvi <- list.files(path = path, pattern = "NDVI_", full.names = TRUE)
paths_evi <- list.files(path = path, pattern = "EVI_", full.names = TRUE)
paths_nirv <- list.files(path = path, pattern = "NIRv_", full.names = TRUE)

# Stack the cubes, one cubes for each month over the whole reference period.
months <- 5:9
years <- 2013:2017

datetime_values <- as.vector(sapply(years, function(y) sprintf("%d-%02d-01", y, months)))

cube_ndvi <- stack_cube(paths_ndvi, datetime_values = datetime_values)
cube_evi <- stack_cube(paths_evi, datetime_values = datetime_values)
cube_nirv <- stack_cube(paths_nirv, datetime_values = datetime_values)

ndvi_means <- extract_geom(cube_ndvi, sf, FUN = mean)
ndvi_means$index <- "ndvi"

evi_means <- extract_geom(cube_evi, sf, FUN = mean)
evi_means$index <- "evi"

nirv_means <- extract_geom(cube_nirv, sf, FUN = mean)
nirv_means$index <- "nirv"

df_stu <- bind_rows(ndvi_means, evi_means, nirv_means)

df_stu$FID <- NULL

df_2013 <- df_stu %>% 
  filter(grepl("2013", time))

df_2014 <- df_stu %>% 
  filter(grepl("2014", time))

df_2015 <- df_stu %>% 
  filter(grepl("2015", time))

df_2016 <- df_stu %>% 
  filter(grepl("2016", time))

df_2017 <- df_stu %>% 
  filter(grepl("2017", time))


# Differences raw.
df_dif_2013_test <- df_2013$x1 - df_ref$x1
df_dif_2014_test <- df_2014$x1 - df_ref$x1
df_dif_2015_test <- df_2015$x1 - df_ref$x1
df_dif_2016_test <- df_2016$x1 - df_ref$x1
df_dif_2017_test <- df_2017$x1 - df_ref$x1

df_dif_2013_harmonised <- (df_dif_2013_test - df_ref$x1)*100
df_dif_2014_harmonised <- (df_dif_2014_test - df_ref$x1)*100
df_dif_2015_harmonised <- (df_dif_2015_test - df_ref$x1)*100
df_dif_2016_harmonised <- (df_dif_2016_test - df_ref$x1)*100
df_dif_2017_harmonised <- (df_dif_2017_test - df_ref$x1)*100

df_test <- data.frame("2013" = df_dif_2013_harmonised,
                      "2014" = df_dif_2014_harmonised,
                      "2015" = df_dif_2015_harmonised,
                      "2016" = df_dif_2016_harmonised,
                      "2017" = df_dif_2017_harmonised)














df_test$date <- as.Date(paste0(datetime_values))

df_differences_harmonised_long <- df_differences_harmonised %>%
  pivot_longer(
    cols = c(ndvi, evi, nirv),
    names_to = "index",
    values_to = "difference"
  )

save(df_differences_harmonised_long, file = "data/work/dataframes/df_diff_harm_long_vogelsang.RData")

