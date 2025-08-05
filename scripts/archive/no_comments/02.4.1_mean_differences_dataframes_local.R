# Script to create dataframes from timeseries values on local and regional level

# Packages. ---------------------------------------------------------------
# Spatial data.
library(gdalcubes)   # raster cubes
library(sf)          # vector
library(terra)       # raster

# Tabular data.
library(dplyr)       # manipulation
library(gdata)       # manipulation
library(tidyr)       # tidying

# Load and transform vector data.  ---------------------------------------------------------------
sf <- st_read("data/raw/forest_loss/forest_loss.shp")
sf <- st_transform(sf, "+proj=sinu +lon_0=0 +x_0=0 +y_0=0 +R=6371007.181 +units=m +no_defs")

# Reference  ---------------------------------------------------------------
# Get the paths of the indix rasters.
path = "data/work/reference/indices/"

paths_ndvi <- list.files(path = path, pattern = "NDVI_", full.names = TRUE)
paths_evi  <- list.files(path = path, pattern = "EVI_",  full.names = TRUE)
paths_nirv <- list.files(path = path, pattern = "NIRv_", full.names = TRUE)

paths_lai  <- list.files(path = "data/work/reference/lai/qa1/P13Y", pattern = "LAI", full.names = TRUE)

# Stack the the rasters into cubes, one cube for each index.
months <- 5:9 

cube_ndvi <- stack_cube(paths_ndvi, datetime_values = paste0("2000-0", months))
cube_evi  <- stack_cube(paths_evi,  datetime_values = paste0("2000-0", months))
cube_nirv <- stack_cube(paths_nirv, datetime_values = paste0("2000-0", months))

cube_lai  <- stack_cube(paths_lai, datetime_values = paste0("2003-0", months))

# Calculate mean value for each month over the whole reference period,
# only for cells, which center is overlapped by the forest loss polygone.

ref_ndvi_means <- extract_geom(cube_ndvi, sf, FUN = mean) %>% 
  rename(NDVI = x1) # Change column name from x1 to index.

ref_evi_means <- extract_geom(cube_evi, sf, FUN = mean) %>% 
  rename(EVI = x1)  # Change column name from x1 to index.

ref_nirv_means <- extract_geom(cube_nirv, sf, FUN = mean) %>% 
  rename(NIRv = x1) # Change column name from x1 to index.

ref_lai_means <- extract_geom(cube_lai, sf, FUN = mean) %>% 
  rename(LAI = x1)  # Change column name from x1 to index.

# Create new column, containing the month.
ref_ndvi_means$month <- format(as.Date(ref_ndvi_means$time), "%m")
ref_evi_means$month <- format(as.Date(ref_evi_means$time), "%m")
ref_nirv_means$month <- format(as.Date(ref_nirv_means$time), "%m")
ref_lai_means$month <- format(as.Date(ref_lai_means$time), "%m")

# Merge the dataframes, bind by same values in columns "FID" and "month".
df_ref <- ref_ndvi_means %>%
  left_join(ref_evi_means,  by = c("FID", "month")) %>%
  left_join(ref_nirv_means, by = c("FID", "month")) %>% 
  left_join(ref_lai_means,  by = c("FID", "month"))

# Set the rownames to month (MM).
rownames(df_ref) <- df_ref$month

# Create new data frame, containing only the indices values.
df_ref <- df_ref %>% 
  select(NDVI, EVI, NIRv, LAI)
  

# Study ------------------------------------------------------------------
# Get the paths.
path = "data/work/study/indices/"

paths_ndvi <- list.files(path = path, pattern = "NDVI_", full.names = TRUE)
paths_evi  <- list.files(path = path, pattern = "EVI_",  full.names = TRUE)
paths_nirv <- list.files(path = path, pattern = "NIRv_", full.names = TRUE)

paths_lai <- list.files(path = "data/work/study/lai/qa1/P1M", pattern = "LAI", full.names = TRUE)

# Create datetime values in format YYYY-MM
months <- 5:9
years <- 2013:2017
datetime_values <- as.vector(sapply(years, function(y) sprintf("%d-%02d", y, months)))

# Stack the the rasters into cubes, one cube for each index.
cube_ndvi <- stack_cube(paths_ndvi, datetime_values = datetime_values)
cube_evi  <- stack_cube(paths_evi,  datetime_values = datetime_values)
cube_nirv <- stack_cube(paths_nirv, datetime_values = datetime_values)

cube_lai  <- stack_cube(paths_lai, datetime_values = datetime_values)

# Calculate mean value for each month over the whole reference period,
# only for cells, which center is overlapped by the forest loss polygone.
ndvi_means <- extract_geom(cube_ndvi, sf, FUN = mean) %>% 
  rename(NDVI = x1) # Change column name from x1 to index.

evi_means <- extract_geom(cube_evi, sf, FUN = mean) %>% 
  rename(EVI = x1) # Change column name from x1 to index.

nirv_means <- extract_geom(cube_nirv, sf, FUN = mean) %>% 
  rename(NIRv = x1) # Change column name from x1 to index.

lai_means <- extract_geom(cube_lai, sf, FUN = mean) %>% 
  rename(LAI = x1) # Change column name from x1 to index.

# Merge the dataframes, bind by same values in columns "FID" and "month".
df_stu <- ndvi_means %>%
  left_join(evi_means, by = c("FID", "time")) %>%
  left_join(nirv_means, by = c("FID", "time")) %>% 
  left_join(lai_means, by = c("FID", "time"))

# Set the rownames to month date (YYYY-MM).
rownames(df_stu) <- df_stu$time

# Create new data frame, containing only the indices values.
df_stu <- df_stu %>% 
  select(NDVI, EVI, NIRv, LAI)

# Create new dataframes, each one contains only the mean index value for each year.
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

# Calculate the absolute differences by subtracting the reference period value from the study period value.
df_dif_2013_abs <- df_2013 - df_ref
df_dif_2014_abs <- df_2014 - df_ref
df_dif_2015_abs <- df_2015 - df_ref
df_dif_2016_abs <- df_2016 - df_ref
df_dif_2017_abs <- df_2017 - df_ref

# Harmonise the differences by calculating the relative difference (= percentage of reference period value).
df_dif_2013_rel <- (df_dif_2013_abs / df_ref)*100
df_dif_2014_rel <- (df_dif_2014_abs / df_ref)*100
df_dif_2015_rel <- (df_dif_2015_abs / df_ref)*100
df_dif_2016_rel <- (df_dif_2016_abs / df_ref)*100
df_dif_2017_rel <- (df_dif_2017_abs / df_ref)*100

# Combine the dataframes containing the absolute values.
df_dif_abs_loc <- bind_rows(df_dif_2013_abs, 
                            df_dif_2014_abs, 
                            df_dif_2015_abs, 
                            df_dif_2016_abs, 
                            df_dif_2017_abs)

# Combine the dataframes containing the relative values.
df_dif_rel_loc <- bind_rows(df_dif_2013_rel, 
                            df_dif_2014_rel, 
                            df_dif_2015_rel, 
                            df_dif_2016_rel, 
                            df_dif_2017_rel)

# Create a column containing the datetimes (from the rownames).
df_dif_abs_loc$time <- as.Date(rownames(df_dif_abs_loc))
df_dif_rel_loc$time <- as.Date(rownames(df_dif_rel_loc))

# Transform the dataframes to "long" format, means one row per value.
# Absolute values.
df_dif_abs_loc_long <- df_dif_abs_loc %>%
  pivot_longer(
    cols = c(NDVI, EVI, NIRv, LAI),
    names_to = "index",
    values_to = "value"
  )

# Relative values.
df_dif_rel_loc_long <- df_dif_rel_loc %>%
  pivot_longer(
    cols = c(NDVI, EVI, NIRv, LAI),
    names_to = "index",
    values_to = "value"
  )

# Tidy the environment, only keep the objects we want to save.
keep(df_dif_abs_loc,
     df_dif_rel_loc,
     df_dif_abs_loc_long, 
     df_dif_rel_loc_long, 
     sure = TRUE)

# Save the dataframes.
save(df_dif_abs_loc,      file = "data/work/dataframes/df_dif_absolute_local.RData")
save(df_dif_rel_loc,      file = "data/work/dataframes/df_dif_relative_local.RData")

save(df_dif_abs_loc_long, file = "data/work/dataframes/df_dif_absolute_local_long.RData")
save(df_dif_rel_loc_long, file = "data/work/dataframes/df_dif_relative_local_long.RData")
