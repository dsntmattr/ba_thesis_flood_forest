# Packages ----------------------------------------------------------------
library(magrittr)
library(terra)
library(sf)
library(gdalcubes)

# Creating datetimes ------------------------------------------------------

# Create a sequence over the reference period years
years <- 2000:2012
# Create the months
months <- c("05", "06", "07", "08", "09")
# Combine years and monthts
date_strings <- expand.grid(year = years, month = months)
# Transform to a datetime format and add "-01" to the name (the datetime needs to be in format "YYYY-MM-DD")
dates <- as.Date(paste0(date_strings$year, "-", date_strings$month, "-01"))
# Sort the dates to bring them in the same order like the saved raster files.
dates <- sort(dates)

# Paths -------------------------------------------------------------------

## Pointer to images path
## The goal is to create one image collection for each month. 
## Therefore, we need one path pointer for each month.

input <- "data/work/reference/P1M"

path_05 <- list.files(path = input, pattern = "-05-", full.names = TRUE)
path_06 <- list.files(path = input, pattern = "-06-", full.names = TRUE)
path_07 <- list.files(path = input, pattern = "-07-", full.names = TRUE)
path_08 <- list.files(path = input, pattern = "-08-", full.names = TRUE)
path_09 <- list.files(path = input, pattern = "-09-", full.names = TRUE)

# Format datetimes --------------------------------------------------------

## To create an image collection, we need to specify the datetimes of the images.
## Because we want to create on image collection per month, we need the datetimes for each month
dates_05 <- dates[format(dates, "%m") == "05"]
dates_06 <- dates[format(dates, "%m") == "06"]
dates_07 <- dates[format(dates, "%m") == "07"]
dates_08 <- dates[format(dates, "%m") == "08"]
dates_09 <- dates[format(dates, "%m") == "09"]

# Create image collections ------------------------------------------------

names <- c("x1", "x2", "x3")

col_05 <- create_image_collection(path_05, date_time = dates_05, band_names = names)
col_06 <- create_image_collection(path_06, date_time = dates_06, band_names = names)
col_07 <- create_image_collection(path_07, date_time = dates_07, band_names = names)
col_08 <- create_image_collection(path_08, date_time = dates_08, band_names = names)
col_09 <- create_image_collection(path_09, date_time = dates_09, band_names = names)

# Preparing cube views ----------------------------------------------------

#set the coordinate system
wkt2 <- "PROJCS[\"unnamed\",GEOGCS[\"Unknown datum based upon the custom spheroid\",DATUM[\"Not specified (based on custom spheroid)\",SPHEROID[\"Custom spheroid\",6371007.181,0]],PRIMEM[\"Greenwich\",0],UNIT[\"degree\",0.0174532925199433,AUTHORITY[\"EPSG\",\"9122\"]]],PROJECTION[\"Sinusoidal\"],PARAMETER[\"longitude_of_center\",0],PARAMETER[\"false_easting\",0],PARAMETER[\"false_northing\",0],UNIT[\"Meter\",1],AXIS[\"Easting\",EAST],AXIS[\"Northing\",NORTH]]"

# Load boundig box vector
load("data/work/bbox.vector.RData")

#set area of interest
aoi   <- bbox.vector
#define the study area for the cut
xmin        <- aoi[1]
ymin        <- aoi[2]
xmax        <- aoi[3]
ymax        <- aoi[4]
aoi.extent  <- st_bbox(c(xmin = xmin, xmax = xmax,
                         ymin = ymin, ymax = ymax),
                       crs = 4326)
aoi.extent  <- aoi.extent %>% st_as_sfc() %>% st_as_sf()

#project aoi to satellite image projection
aoi.extent  <- st_bbox(st_transform(st_as_sfc(aoi.extent),wkt2))

#set time period of interest
toi_05  <- c("2000-05-01/2012-05-31")
toi_06  <- c("2000-06-01/2012-06-31")
toi_07  <- c("2000-07-01/2012-07-31")
toi_08  <- c("2000-08-01/2012-08-31")
toi_09  <- c("2000-09-01/2012-09-31")

# Cube views and cubes --------------------------------------------------------------

# Specify the cube views
v_05   = cube_view(extent= list(t0 = substr(toi_05, 1, 10), t1 = substr(toi_05, 12, 22),
                                left = aoi.extent$xmin, right = aoi.extent$xmax,  top = aoi.extent$ymax, bottom = aoi.extent$ymin), srs = wkt2,
                   dx = 500, dy = 500, dt="P13Y", aggregation = "mean", resampling = "bilinear")

v_06   = cube_view(extent= list(t0 = substr(toi_06, 1, 10), t1 = substr(toi_06, 12, 22),
                                left = aoi.extent$xmin, right = aoi.extent$xmax,  top = aoi.extent$ymax, bottom = aoi.extent$ymin), srs = wkt2,
                   dx = 500, dy = 500, dt="P13Y", aggregation = "mean", resampling = "bilinear")

v_07  = cube_view(extent= list(t0 = substr(toi_07, 1, 10), t1 = substr(toi_07, 12, 22),
                               left = aoi.extent$xmin, right = aoi.extent$xmax,  top = aoi.extent$ymax, bottom = aoi.extent$ymin), srs = wkt2,
                  dx = 500, dy = 500, dt="P13Y", aggregation = "mean", resampling = "bilinear")

v_08   = cube_view(extent= list(t0 = substr(toi_08, 1, 10), t1 = substr(toi_08, 12, 22),
                                left = aoi.extent$xmin, right = aoi.extent$xmax,  top = aoi.extent$ymax, bottom = aoi.extent$ymin), srs = wkt2,
                   dx = 500, dy = 500, dt="P13Y", aggregation = "mean", resampling = "bilinear")

v_09   = cube_view(extent= list(t0 = substr(toi_09, 1, 10), t1 = substr(toi_09, 12, 22),
                                left = aoi.extent$xmin, right = aoi.extent$xmax,  top = aoi.extent$ymax, bottom = aoi.extent$ymin), srs = wkt2,
                   dx = 500, dy = 500, dt="P13Y", aggregation = "mean", resampling = "bilinear")

## Create the cubes
cube_05 = raster_cube(col_05, v_05)
cube_06 = raster_cube(col_06, v_06)
cube_07 = raster_cube(col_07, v_07)
cube_08 = raster_cube(col_08, v_08)
cube_09 = raster_cube(col_09, v_09)

# Rescaling ---------------------------------------------------------------

## Rescale the cell values to range 0-1
## Reason: the EVI formula needs cell values between 0-1, otherwise the results will be nonsense

cube_05_scaled_0_1 <- apply_pixel(
  cube_05,
  c("x1 / 10000", "x2 / 10000", "x3 / 10000"),
  c("x1", "x2", "x3")
)

cube_06_scaled_0_1 <- apply_pixel(
  cube_06,
  c("x1 / 10000", "x2 / 10000", "x3 / 10000"),
  c("x1", "x2", "x3")
)

cube_07_scaled_0_1 <- apply_pixel(
  cube_07,
  c("x1 / 10000", "x2 / 10000", "x3 / 10000"),
  c("x1", "x2", "x3")
)

cube_08_scaled_0_1 <- apply_pixel(
  cube_08,
  c("x1 / 10000", "x2 / 10000", "x3 / 10000"),
  c("x1", "x2", "x3")
)

cube_09_scaled_0_1 <- apply_pixel(
  cube_09,
  c("x1 / 10000", "x2 / 10000", "x3 / 10000"),
  c("x1", "x2", "x3")
)

# NDVI --------------------------------------------------------------------

## Calculate NDVI
ndvi_05 <- apply_pixel (cube_05_scaled_0_1, "(x2 - x1) / (x2 + x1)", "NDVI")
ndvi_06 <- apply_pixel (cube_06_scaled_0_1, "(x2 - x1) / (x2 + x1)", "NDVI")
ndvi_07 <- apply_pixel (cube_07_scaled_0_1, "(x2 - x1) / (x2 + x1)", "NDVI")
ndvi_08 <- apply_pixel (cube_08_scaled_0_1, "(x2 - x1) / (x2 + x1)", "NDVI")
ndvi_09 <- apply_pixel (cube_09_scaled_0_1, "(x2 - x1) / (x2 + x1)", "NDVI")

# EVI ---------------------------------------------------------------------

## Calculate EVI
evi_05 <- apply_pixel (cube_05_scaled_0_1, "(2.5 * (x2 - x1) / (x2 + 6 * x1 - 7.5 * x3 + 1))", "EVI")
evi_06 <- apply_pixel (cube_06_scaled_0_1, "(2.5 * (x2 - x1) / (x2 + 6 * x1 - 7.5 * x3 + 1))", "EVI")
evi_07 <- apply_pixel (cube_07_scaled_0_1, "(2.5 * (x2 - x1) / (x2 + 6 * x1 - 7.5 * x3 + 1))", "EVI")
evi_08 <- apply_pixel (cube_08_scaled_0_1, "(2.5 * (x2 - x1) / (x2 + 6 * x1 - 7.5 * x3 + 1))", "EVI")
evi_09 <- apply_pixel (cube_09_scaled_0_1, "(2.5 * (x2 - x1) / (x2 + 6 * x1 - 7.5 * x3 + 1))", "EVI")

# NIRv --------------------------------------------------------------------

## Calculate NIRv
nirv_05 <- apply_pixel (cube_05_scaled_0_1, "((x2 - x1) / (x2 + x1)) * x2", "NIRv")
nirv_06 <- apply_pixel (cube_06_scaled_0_1, "((x2 - x1) / (x2 + x1)) * x2", "NIRv")
nirv_07 <- apply_pixel (cube_07_scaled_0_1, "((x2 - x1) / (x2 + x1)) * x2", "NIRv")
nirv_08 <- apply_pixel (cube_08_scaled_0_1, "((x2 - x1) / (x2 + x1)) * x2", "NIRv")
nirv_09 <- apply_pixel (cube_09_scaled_0_1, "((x2 - x1) / (x2 + x1)) * x2", "NIRv")

# SAVING ------------------------------------------------------------------

out <- "data/work/reference/P13Y"


# Saving the pictures. --------------------------------------------------
write_tif((cube_05),
          dir = out,
          prefix = 'MODIS_05_')

write_tif((cube_06),
          dir = out,
          prefix = 'MODIS_06_')

write_tif((cube_07),
          dir = out,
          prefix = 'MODIS_07_')

write_tif((cube_08),
          dir = out,
          prefix = 'MODIS_08_')

write_tif((cube_09),
          dir = out,
          prefix = 'MODIS_09_')


# Saving the NDVIs --------------------------------------------------------
write_tif((ndvi_05),
          dir = out,
          prefix = 'NDVI_05_')

write_tif((ndvi_06),
          dir = out,
          prefix = 'NDVI_06_')

write_tif((ndvi_07),
          dir = out,
          prefix = 'NDVI_07_')

write_tif((ndvi_08),
          dir = out,
          prefix = 'NDVI_08_')

write_tif((ndvi_09),
          dir = out,
          prefix = 'NDVI_09_')


# Saving the EVIs ---------------------------------------------------------
write_tif((evi_05),
          dir = out,
          prefix = 'EVI_05_')

write_tif((evi_06),
          dir = out,
          prefix = 'EVI_06_')

write_tif((evi_07),
          dir = out,
          prefix = 'EVI_07_')

write_tif((evi_08),
          dir = out,
          prefix = 'EVI_08_')

write_tif((evi_09),
          dir = out,
          prefix = 'EVI_09_')


# Saving the NIRv ---------------------------------------------------------
write_tif((nirv_05),
          dir = out,
          prefix = 'NIRv_05_')

write_tif((nirv_06),
          dir = out,
          prefix = 'NIRv_06_')

write_tif((nirv_07),
          dir = out,
          prefix = 'NIRv_07_')

write_tif((nirv_08),
          dir = out,
          prefix = 'NIRv_08_')

write_tif((nirv_09),
          dir = out,
          prefix = 'NIRv_09_')
