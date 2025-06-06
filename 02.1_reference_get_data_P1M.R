# Getting the raw MODIS scenes for our study area, aggregated to one picture for each month.
# Packages ----
# Load packages 
library(rstac)
library(magrittr)
library(terra)
library(sf)
library(gdalcubes)

# Gettin ready ----
# removing all variables from the current environment.
rm(list=ls())
# setting margins for plot window.
par(mar = c(2,2,1,1))
# link to collection
s.obj <- stac("https://planetarycomputer.microsoft.com/api/stac/v1")

# Load boundig box vector
load("raw/bbox.vector.RData")

# 2000 ----
#set time period of interest
toi   <- c("2000-05-01/2000-09-30")
#set area of interest
aoi   <- bbox.vector
#filter collection to find the elements we want containing the coordinates of interest
it.obj <- s.obj %>%
  stac_search(collections = "modis-43A4-061",
              datetime=toi,
              bbox = aoi) %>%
  get_request() %>%
  items_sign(sign_fn = sign_planetary_computer())
it.obj
#get the coordinate system
wkt2 <- it.obj$features[[1]]$properties$`proj:wkt2`
#get the acquisition date
img.dates <- NULL
for (i in 1:length(it.obj$features)) {
  img.dates <- c(img.dates,substr(it.obj$features[[i]]$properties$datetime, 1, 10))
}
img.dates <- rev(unique(img.dates))
#define the Bands you want to extract
assets      <- c("Nadir_Reflectance_Band1","Nadir_Reflectance_Band2", "Nadir_Reflectance_Band3")
collection  <- stac_image_collection(it.obj$features, asset_names = assets)
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

#datacube for images at acquisition time  
v     = cube_view(srs = wkt2,  extent = list(t0 = substr(toi, 1, 10), t1 = substr(toi, 12, 22),
                                             left = aoi.extent$xmin, right = aoi.extent$xmax,  top = aoi.extent$ymax, bottom = aoi.extent$ymin),
                  dx = 500, dy = 500, dt="P1M", aggregation = "mean", resampling = "bilinear")
cube = raster_cube(collection, v)

# Saving
write_tif((cube),
          dir="work/P1M",
          prefix='MODIS_')

# 2001 ----

#set time period of interest
toi   <- c("2001-05-01/2001-09-30")

#set area of interest
aoi   <- bbox.vector

#filter collection to find the elements we want containing the coordinates of interest
it.obj <- s.obj %>%
  stac_search(collections = "modis-43A4-061",
              datetime=toi,
              bbox = aoi) %>%
  get_request() %>%
  items_sign(sign_fn = sign_planetary_computer())
it.obj

#get the coordinate system
wkt2 <- it.obj$features[[1]]$properties$`proj:wkt2`

#get the acquisition date
img.dates <- NULL
for (i in 1:length(it.obj$features)) {
  img.dates <- c(img.dates,substr(it.obj$features[[i]]$properties$datetime, 1, 10))
}
img.dates <- rev(unique(img.dates))

#define the Bands you want to extract
assets      <- c("Nadir_Reflectance_Band1","Nadir_Reflectance_Band2", "Nadir_Reflectance_Band3")
collection  <- stac_image_collection(it.obj$features, asset_names = assets)

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

#datacube for images at acquisition time  
v     = cube_view(srs = wkt2,  extent = list(t0 = substr(toi, 1, 10), t1 = substr(toi, 12, 22),
                                             left = aoi.extent$xmin, right = aoi.extent$xmax,  top = aoi.extent$ymax, bottom = aoi.extent$ymin),
                  dx = 500, dy = 500, dt="P1M", aggregation = "mean", resampling = "bilinear")

cube = raster_cube(collection, v)

## Save all images from the cube to drive
write_tif((cube),
          dir="work/P1M",
          prefix='MODIS_')

# 2002 ----

#set time period of interest
toi   <- c("2002-05-01/2002-09-30")

#set area of interest
aoi   <- bbox.vector

#filter collection to find the elements we want containing the coordinates of interest
it.obj <- s.obj %>%
  stac_search(collections = "modis-43A4-061",
              datetime=toi,
              bbox = aoi) %>%
  get_request() %>%
  items_sign(sign_fn = sign_planetary_computer())
it.obj

#get the coordinate system
wkt2 <- it.obj$features[[1]]$properties$`proj:wkt2`

#get the acquisition date
img.dates <- NULL
for (i in 1:length(it.obj$features)) {
  img.dates <- c(img.dates,substr(it.obj$features[[i]]$properties$datetime, 1, 10))
}
img.dates <- rev(unique(img.dates))

#define the Bands you want to extract
assets      <- c("Nadir_Reflectance_Band1","Nadir_Reflectance_Band2", "Nadir_Reflectance_Band3")
collection  <- stac_image_collection(it.obj$features, asset_names = assets)

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

#datacube for images at acquisition time  
v     = cube_view(srs = wkt2,  extent = list(t0 = substr(toi, 1, 10), t1 = substr(toi, 12, 22),
                                             left = aoi.extent$xmin, right = aoi.extent$xmax,  top = aoi.extent$ymax, bottom = aoi.extent$ymin),
                  dx = 500, dy = 500, dt="P1M", aggregation = "mean", resampling = "bilinear")

cube = raster_cube(collection, v)

write_tif((cube),
          dir="work/P1M",
          prefix='MODIS_')

# 2003 ----

#set time period of interest
toi   <- c("2003-05-01/2003-09-30")

#set area of interest
aoi   <- bbox.vector

#filter collection to find the elements we want containing the coordinates of interest
it.obj <- s.obj %>%
  stac_search(collections = "modis-43A4-061",
              datetime=toi,
              bbox = aoi) %>%
  get_request() %>%
  items_sign(sign_fn = sign_planetary_computer())
it.obj

#get the coordinate system
wkt2 <- it.obj$features[[1]]$properties$`proj:wkt2`

#get the acquisition date
img.dates <- NULL
for (i in 1:length(it.obj$features)) {
  img.dates <- c(img.dates,substr(it.obj$features[[i]]$properties$datetime, 1, 10))
}
img.dates <- rev(unique(img.dates))

#define the Bands you want to extract
assets      <- c("Nadir_Reflectance_Band1","Nadir_Reflectance_Band2", "Nadir_Reflectance_Band3")
collection  <- stac_image_collection(it.obj$features, asset_names = assets)

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

#datacube for images at acquisition time  
v     = cube_view(srs = wkt2,  extent = list(t0 = substr(toi, 1, 10), t1 = substr(toi, 12, 22),
                                             left = aoi.extent$xmin, right = aoi.extent$xmax,  top = aoi.extent$ymax, bottom = aoi.extent$ymin),
                  dx = 500, dy = 500, dt="P1M", aggregation = "mean", resampling = "bilinear")

cube = raster_cube(collection, v)

write_tif((cube),
          dir="work/P1M",
          prefix='MODIS_')

# 2004 ----

#set time period of interest
toi   <- c("2004-05-01/2004-09-30")

#set area of interest
aoi   <- bbox.vector

#filter collection to find the elements we want containing the coordinates of interest
it.obj <- s.obj %>%
  stac_search(collections = "modis-43A4-061",
              datetime=toi,
              bbox = aoi) %>%
  get_request() %>%
  items_sign(sign_fn = sign_planetary_computer())
it.obj

#get the coordinate system
wkt2 <- it.obj$features[[1]]$properties$`proj:wkt2`

#get the acquisition date
img.dates <- NULL
for (i in 1:length(it.obj$features)) {
  img.dates <- c(img.dates,substr(it.obj$features[[i]]$properties$datetime, 1, 10))
}
img.dates <- rev(unique(img.dates))

#define the Bands you want to extract
assets      <- c("Nadir_Reflectance_Band1","Nadir_Reflectance_Band2", "Nadir_Reflectance_Band3")
collection  <- stac_image_collection(it.obj$features, asset_names = assets)

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

#datacube for images at acquisition time  
v     = cube_view(srs = wkt2,  extent = list(t0 = substr(toi, 1, 10), t1 = substr(toi, 12, 22),
                                             left = aoi.extent$xmin, right = aoi.extent$xmax,  top = aoi.extent$ymax, bottom = aoi.extent$ymin),
                  dx = 500, dy = 500, dt="P1M", aggregation = "mean", resampling = "bilinear")

cube = raster_cube(collection, v)

write_tif((cube),
          dir="work/P1M",
          prefix='MODIS_')

# 2005 ----

#set time period of interest
toi   <- c("2005-05-01/2005-09-30")

#set area of interest
aoi   <- bbox.vector

#filter collection to find the elements we want containing the coordinates of interest
it.obj <- s.obj %>%
  stac_search(collections = "modis-43A4-061",
              datetime=toi,
              bbox = aoi) %>%
  get_request() %>%
  items_sign(sign_fn = sign_planetary_computer())
it.obj

#get the coordinate system
wkt2 <- it.obj$features[[1]]$properties$`proj:wkt2`

#get the acquisition date
img.dates <- NULL
for (i in 1:length(it.obj$features)) {
  img.dates <- c(img.dates,substr(it.obj$features[[i]]$properties$datetime, 1, 10))
}
img.dates <- rev(unique(img.dates))

#define the Bands you want to extract
assets      <- c("Nadir_Reflectance_Band1","Nadir_Reflectance_Band2", "Nadir_Reflectance_Band3")
collection  <- stac_image_collection(it.obj$features, asset_names = assets)

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

#datacube for images at acquisition time  
v     = cube_view(srs = wkt2,  extent = list(t0 = substr(toi, 1, 10), t1 = substr(toi, 12, 22),
                                             left = aoi.extent$xmin, right = aoi.extent$xmax,  top = aoi.extent$ymax, bottom = aoi.extent$ymin),
                  dx = 500, dy = 500, dt="P1M", aggregation = "mean", resampling = "bilinear")

cube = raster_cube(collection, v)

write_tif((cube),
          dir="work/P1M",
          prefix='MODIS_')

# 2006 ----

#set time period of interest
toi   <- c("2006-05-01/2006-09-30")

#set area of interest
aoi   <- bbox.vector

#filter collection to find the elements we want containing the coordinates of interest
it.obj <- s.obj %>%
  stac_search(collections = "modis-43A4-061",
              datetime=toi,
              bbox = aoi) %>%
  get_request() %>%
  items_sign(sign_fn = sign_planetary_computer())
it.obj

#get the coordinate system
wkt2 <- it.obj$features[[1]]$properties$`proj:wkt2`

#get the acquisition date
img.dates <- NULL
for (i in 1:length(it.obj$features)) {
  img.dates <- c(img.dates,substr(it.obj$features[[i]]$properties$datetime, 1, 10))
}
img.dates <- rev(unique(img.dates))

#define the Bands you want to extract
assets      <- c("Nadir_Reflectance_Band1","Nadir_Reflectance_Band2", "Nadir_Reflectance_Band3")
collection  <- stac_image_collection(it.obj$features, asset_names = assets)

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

#datacube for images at acquisition time  
v     = cube_view(srs = wkt2,  extent = list(t0 = substr(toi, 1, 10), t1 = substr(toi, 12, 22),
                                             left = aoi.extent$xmin, right = aoi.extent$xmax,  top = aoi.extent$ymax, bottom = aoi.extent$ymin),
                  dx = 500, dy = 500, dt="P1M", aggregation = "mean", resampling = "bilinear")

cube = raster_cube(collection, v)

write_tif((cube),
          dir="work/P1M",
          prefix='MODIS_')

# 2007 ----

#set time period of interest
toi   <- c("2007-05-01/2007-09-30")

#set area of interest
aoi   <- bbox.vector

#filter collection to find the elements we want containing the coordinates of interest
it.obj <- s.obj %>%
  stac_search(collections = "modis-43A4-061",
              datetime=toi,
              bbox = aoi) %>%
  get_request() %>%
  items_sign(sign_fn = sign_planetary_computer())
it.obj

#get the coordinate system
wkt2 <- it.obj$features[[1]]$properties$`proj:wkt2`

#get the acquisition date
img.dates <- NULL
for (i in 1:length(it.obj$features)) {
  img.dates <- c(img.dates,substr(it.obj$features[[i]]$properties$datetime, 1, 10))
}
img.dates <- rev(unique(img.dates))

#define the Bands you want to extract
assets      <- c("Nadir_Reflectance_Band1","Nadir_Reflectance_Band2", "Nadir_Reflectance_Band3")
collection  <- stac_image_collection(it.obj$features, asset_names = assets)

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

#datacube for images at acquisition time  
v     = cube_view(srs = wkt2,  extent = list(t0 = substr(toi, 1, 10), t1 = substr(toi, 12, 22),
                                             left = aoi.extent$xmin, right = aoi.extent$xmax,  top = aoi.extent$ymax, bottom = aoi.extent$ymin),
                  dx = 500, dy = 500, dt="P1M", aggregation = "mean", resampling = "bilinear")

cube = raster_cube(collection, v)

write_tif((cube),
          dir="work/P1M",
          prefix='MODIS_')

# 2008 ----

#set time period of interest
toi   <- c("2008-05-01/2008-09-30")

#set area of interest
aoi   <- bbox.vector

#filter collection to find the elements we want containing the coordinates of interest
it.obj <- s.obj %>%
  stac_search(collections = "modis-43A4-061",
              datetime=toi,
              bbox = aoi) %>%
  get_request() %>%
  items_sign(sign_fn = sign_planetary_computer())
it.obj

#get the coordinate system
wkt2 <- it.obj$features[[1]]$properties$`proj:wkt2`

#get the acquisition date
img.dates <- NULL
for (i in 1:length(it.obj$features)) {
  img.dates <- c(img.dates,substr(it.obj$features[[i]]$properties$datetime, 1, 10))
}
img.dates <- rev(unique(img.dates))

#define the Bands you want to extract
assets      <- c("Nadir_Reflectance_Band1","Nadir_Reflectance_Band2", "Nadir_Reflectance_Band3")
collection  <- stac_image_collection(it.obj$features, asset_names = assets)

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

#datacube for images at acquisition time  
v     = cube_view(srs = wkt2,  extent = list(t0 = substr(toi, 1, 10), t1 = substr(toi, 12, 22),
                                             left = aoi.extent$xmin, right = aoi.extent$xmax,  top = aoi.extent$ymax, bottom = aoi.extent$ymin),
                  dx = 500, dy = 500, dt="P1M", aggregation = "mean", resampling = "bilinear")

cube = raster_cube(collection, v)

write_tif((cube),
          dir="work/P1M",
          prefix='MODIS_')

# 2009 ----

#set time period of interest
toi   <- c("2009-05-01/2009-09-30")

#set area of interest
aoi   <- bbox.vector

#filter collection to find the elements we want containing the coordinates of interest
it.obj <- s.obj %>%
  stac_search(collections = "modis-43A4-061",
              datetime=toi,
              bbox = aoi) %>%
  get_request() %>%
  items_sign(sign_fn = sign_planetary_computer())
it.obj

#get the coordinate system
wkt2 <- it.obj$features[[1]]$properties$`proj:wkt2`

#get the acquisition date
img.dates <- NULL
for (i in 1:length(it.obj$features)) {
  img.dates <- c(img.dates,substr(it.obj$features[[i]]$properties$datetime, 1, 10))
}
img.dates <- rev(unique(img.dates))

#define the Bands you want to extract
assets      <- c("Nadir_Reflectance_Band1","Nadir_Reflectance_Band2", "Nadir_Reflectance_Band3")
collection  <- stac_image_collection(it.obj$features, asset_names = assets)

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

#datacube for images at acquisition time  
v     = cube_view(srs = wkt2,  extent = list(t0 = substr(toi, 1, 10), t1 = substr(toi, 12, 22),
                                             left = aoi.extent$xmin, right = aoi.extent$xmax,  top = aoi.extent$ymax, bottom = aoi.extent$ymin),
                  dx = 500, dy = 500, dt="P1M", aggregation = "mean", resampling = "bilinear")

cube = raster_cube(collection, v)

write_tif((cube),
          dir="work/P1M",
          prefix='MODIS_')

# 2010 ----

#set time period of interest
toi   <- c("2010-05-01/2010-09-30")

#set area of interest
aoi   <- bbox.vector

#filter collection to find the elements we want containing the coordinates of interest
it.obj <- s.obj %>%
  stac_search(collections = "modis-43A4-061",
              datetime=toi,
              bbox = aoi) %>%
  get_request() %>%
  items_sign(sign_fn = sign_planetary_computer())
it.obj

#get the coordinate system
wkt2 <- it.obj$features[[1]]$properties$`proj:wkt2`

#get the acquisition date
img.dates <- NULL
for (i in 1:length(it.obj$features)) {
  img.dates <- c(img.dates,substr(it.obj$features[[i]]$properties$datetime, 1, 10))
}
img.dates <- rev(unique(img.dates))

#define the Bands you want to extract
assets      <- c("Nadir_Reflectance_Band1","Nadir_Reflectance_Band2", "Nadir_Reflectance_Band3")
collection  <- stac_image_collection(it.obj$features, asset_names = assets)

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

#datacube for images at acquisition time  
v     = cube_view(srs = wkt2,  extent = list(t0 = substr(toi, 1, 10), t1 = substr(toi, 12, 22),
                                             left = aoi.extent$xmin, right = aoi.extent$xmax,  top = aoi.extent$ymax, bottom = aoi.extent$ymin),
                  dx = 500, dy = 500, dt="P1M", aggregation = "mean", resampling = "bilinear")

cube = raster_cube(collection, v)

write_tif((cube),
          dir="work/P1M",
          prefix='MODIS_')

# 2011 ----

#set time period of interest
toi   <- c("2011-05-01/2011-09-30")

#set area of interest
aoi   <- bbox.vector

#filter collection to find the elements we want containing the coordinates of interest
it.obj <- s.obj %>%
  stac_search(collections = "modis-43A4-061",
              datetime=toi,
              bbox = aoi) %>%
  get_request() %>%
  items_sign(sign_fn = sign_planetary_computer())
it.obj

#get the coordinate system
wkt2 <- it.obj$features[[1]]$properties$`proj:wkt2`

#get the acquisition date
img.dates <- NULL
for (i in 1:length(it.obj$features)) {
  img.dates <- c(img.dates,substr(it.obj$features[[i]]$properties$datetime, 1, 10))
}
img.dates <- rev(unique(img.dates))

#define the Bands you want to extract
assets      <- c("Nadir_Reflectance_Band1","Nadir_Reflectance_Band2", "Nadir_Reflectance_Band3")
collection  <- stac_image_collection(it.obj$features, asset_names = assets)

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

#datacube for images at acquisition time  
v     = cube_view(srs = wkt2,  extent = list(t0 = substr(toi, 1, 10), t1 = substr(toi, 12, 22),
                                             left = aoi.extent$xmin, right = aoi.extent$xmax,  top = aoi.extent$ymax, bottom = aoi.extent$ymin),
                  dx = 500, dy = 500, dt="P1M", aggregation = "mean", resampling = "bilinear")

cube = raster_cube(collection, v)

write_tif((cube),
          dir="work/P1M",
          prefix='MODIS_')

# 2012 ----

#set time period of interest
toi   <- c("2012-05-01/2012-09-30")

#set area of interest
aoi   <- bbox.vector

#filter collection to find the elements we want containing the coordinates of interest
it.obj <- s.obj %>%
  stac_search(collections = "modis-43A4-061",
              datetime=toi,
              bbox = aoi) %>%
  get_request() %>%
  items_sign(sign_fn = sign_planetary_computer())
it.obj

#get the coordinate system
wkt2 <- it.obj$features[[1]]$properties$`proj:wkt2`

#get the acquisition date
img.dates <- NULL
for (i in 1:length(it.obj$features)) {
  img.dates <- c(img.dates,substr(it.obj$features[[i]]$properties$datetime, 1, 10))
}
img.dates <- rev(unique(img.dates))

#define the Bands you want to extract
assets      <- c("Nadir_Reflectance_Band1","Nadir_Reflectance_Band2", "Nadir_Reflectance_Band3")
collection  <- stac_image_collection(it.obj$features, asset_names = assets)

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

#datacube for images at acquisition time  
v     = cube_view(srs = wkt2,  extent = list(t0 = substr(toi, 1, 10), t1 = substr(toi, 12, 22),
                                             left = aoi.extent$xmin, right = aoi.extent$xmax,  top = aoi.extent$ymax, bottom = aoi.extent$ymin),
                  dx = 500, dy = 500, dt="P1M", aggregation = "mean", resampling = "bilinear")

cube = raster_cube(collection, v)

write_tif((cube),
          dir="work/P1M",
          prefix='MODIS_')