# Test the differences analysis for the forest loss area near vogelsang magdeburg

library(sf)
library(terra)
library(ggplot2)
library(dplyr)
# Spatial data
library(gdalcubes)   # raster cubes

sf <- st_read("data/raw/forest_loss/forest_loss.shp")
sf <- st_transform(sf, "+proj=sinu +lon_0=0 +x_0=0 +y_0=0 +R=6371007.181 +units=m +no_defs")

# reference
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
datetime_values = c("2013-05", "2013-06", "2013-07", "2013-08", "2013-09",
                    "2014-05", "2014-06", "2014-07", "2014-08", "2014-09",
                    "2015-05", "2015-06", "2015-07", "2015-08", "2015-09",
                    "2016-05", "2016-06", "2016-07", "2016-08", "2016-09",
                    "2017-05", "2017-06", "2017-07", "2017-08", "2017-09")


cube_ndvi <- stack_cube(paths_ndvi, datetime_values = datetime_values)
cube_evi <- stack_cube(paths_evi, datetime_values = datetime_values)
cube_nirv <- stack_cube(paths_nirv, datetime_values = datetime_values)

ndvi_means <- extract_geom(cube_ndvi, sf, FUN = mean)
evi_means <- extract_geom(cube_evi, sf, FUN = mean)
nirv_means <- extract_geom(cube_nirv, sf, FUN = mean)

df_differences <- data.frame(ndvi = c(ndvi_means$x1 - ref_ndvi_means$x1),
                          evi = c(evi_means$x1 - ref_evi_means$x1),
                          nirv = c(nirv_means$x1 - ref_nirv_means$x1))

new_rows <- c("13/05", "13/06", "13/07", "13/08", "13/09",
              "14/05", "14/06", "14/07", "14/08", "14/09",
              "15/05", "15/06", "15/07", "15/08", "15/09",
              "16/05", "16/06", "16/07", "16/08", "16/09",
              "17/05", "17/06", "17/07", "17/08", "17/09")


row.names(df_differences) <- new_rows

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

df_ndvi_harm <- data.frame(dif = c(df_differences_harmonised$ndvi))
df_evi_harm <- data.frame(dif = c(df_differences_harmonised$evi))
df_nirv_harm <- data.frame(dif = c(df_differences_harmonised$nirv))

row.names(df_ndvi_harm) <- new_rows
row.names(df_evi_harm) <- new_rows
row.names(df_nirv_harm) <- new_rows

# plotting
# Idee: bei dem kleinen Gebiet nicht auf Waldtypen eingehen da so kleine Gebiete, beim großen dann aber?


df <- df_ndvi_harm

plot_ndvi <- ggplot(df, aes(x = rownames(df))) +
  geom_point(aes(y = dif, colour = "dif")) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "black") +
  labs(title = "NDVI", x = "Datetimes YY/MM", y = "Differences", color = "Coverage")
plot_ndvi

df <- df_evi_harm
plot_evi <- ggplot(df, aes(x = rownames(df))) +
  geom_point(aes(y = dif, colour = "dif")) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "black") +
  labs(title = "EVI", x = "Datetimes YY/MM", y = "Differences", color = "Coverage")
plot_evi

df <- df_nirv_harm
plot_nirv <- ggplot(df, aes(x = rownames(df))) +
  geom_point(aes(y = dif, colour = "dif")) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "black") +
  labs(title = "nirv", x = "Datetimes YY/MM", y = "Differences", color = "Coverage")
plot_nirv




library(patchwork)
plot_ndvi / plot_evi / plot_nirv  # untereinander
# oder plot_ndvi + plot_evi + plot_nirv  # nebeneinander


