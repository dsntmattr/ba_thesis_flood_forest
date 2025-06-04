# 00 Packages ---------------------------------------------------------
library(sf) # for vector data
library(tidyverse) # for tables and other stuff
library(magrittr) # for %>%
library(terra) # for raster data
library(rstac) # for data access
library(magrittr) # for %>%
library(gdalcubes) # for raster cubes

# 01 Flooded forests ---------------------------------------------------------
# Intersect floodplains and forest areas

floodplains <- st_read("data/raw/floodplains/FLUT_LK.shp")  # read
floodplains <- st_transform(floodplains, crs = 25832)       # transform to EPSG:25832 (ETRS89:UTM32N)
floodplains <- st_union(floodplains)                        # dissolve internal boundaries (output: sfc-object)
floodplains <- st_sf(floodplains)                           # make floodplains a sf-object again

forest <- st_read("data/raw/dlm_st_veg02_f/veg02_f.shp")        # read
forest <- forest %>%
  group_by(VEG) %>%                                             # group by values in column "VEG"
  summarise(geometry = st_union(geometry))                      # create a new column "geometry" to union

flood_forest <- st_intersection(floodplains, forest)            # intersect

st_write(flood_forest, "data/work/flood_forest.shp")            # save

# 02 Base grid ---------------------------------------------------------
# Create a base grid which covers the whole study area as "template" for the masks.

# Removing all variables from the current environment.
rm(list=ls())

# Link to collection
s.obj <- stac("https://planetarycomputer.microsoft.com/api/stac/v1")

# Get bounding box of AOI
sf <-st_read ("data/work/flood_forest.shp")               # read
sf <- st_transform(sf, crs = 4326)                        # transform to EPSG:4326
bbox <- st_bbox(sf)                                       # get bounding box
bbox.vector <- as.vector(bbox)                            # get bounding box in numeric vector
save(bbox.vector, file = "data/work/bbox.vector.RData")   # save bounding box vector as .RData

# Download the MODIS scenes:

toi   <- "2013-05-01/2013-05-02" # set time period of interest
aoi   <- bbox.vector             # set area of interest

# Filter collection to find the elements we want containing the coordinates of interest.
it.obj <- s.obj %>%
  stac_search(collections = "modis-43A4-061",
              datetime=toi,
              bbox = aoi) %>%
  get_request() %>%
  items_sign(sign_fn = sign_planetary_computer())
it.obj

# Get the coordinate system.
wkt2 <- it.obj$features[[1]]$properties$`proj:wkt2`

# Define the bands to extract:
assets      <- c("Nadir_Reflectance_Band1")                                 
collection  <- stac_image_collection(it.obj$features, asset_names = assets)

# Define the study area for the cut.
xmin        <- aoi[1]
ymin        <- aoi[2]
xmax        <- aoi[3]
ymax        <- aoi[4]

aoi.extent  <- st_bbox(c(xmin = xmin,
                         xmax = xmax,
                         ymin = ymin,
                         ymax = ymax),
                       crs = 4326)

aoi.extent  <- aoi.extent %>% st_as_sfc() %>% st_as_sf()

# Project AOI to satellite image projection
aoi.extent  <- st_bbox(st_transform(st_as_sfc(aoi.extent), wkt2))

# Datacube for images at acquisition time  
v = cube_view(srs = wkt2,                              # CRS
              extent = list(t0 = substr(toi, 1, 10),   # start of datetimes
                            t1 = substr(toi, 12, 22),  # end of datetimes
                            left = aoi.extent$xmin,    # xmin-value of bounding box
                            right = aoi.extent$xmax,   # xmax-value of bounding box
                            top = aoi.extent$ymax,     # ymax-value of bounding box
                            bottom = aoi.extent$ymin), # ymax-value of bounding box
              dx = 500, # pixel size in x direction
              dy = 500, # pixel size in y direction
              dt="P1D") # timespane to aggregate to one picture

cube = raster_cube(collection, v)

# Get the acquisition date
img.dates <- NULL

for (i in 1:length(it.obj$features)) {
  img.dates <- c(img.dates,substr(it.obj$features[[i]]$properties$datetime, 1, 10))
}

img.dates <- rev(unique(img.dates))

# Saving
write_tif(select_time(raster_cube(collection, v),img.dates),
          dir="data/work",
          prefix='MODIS_BASEGRID_')

# 03 Coverage ---------------------------------------------------------
# Get coverage layers (cell values = coverage by forest type in percent)

# Removing all variables from the current environment.
rm(list=ls())

r <- rast("data/work/MODIS_BASEGRID_2013-05-01.tif") # read base grid

# Set the CRS of the base grid (no project/transform, only "tell" the CRS)
crs(r) <- ("PROJCS[\"unnamed\",GEOGCS[\"Unknown datum based upon the custom spheroid\",DATUM[\"Not specified (based on custom spheroid)\",SPHEROID[\"Custom spheroid\",6371007.181,0]],PRIMEM[\"Greenwich\",0],UNIT[\"degree\",0.0174532925199433,AUTHORITY[\"EPSG\",\"9122\"]]],PROJECTION[\"Sinusoidal\"],PARAMETER[\"longitude_of_center\",0],PARAMETER[\"false_easting\",0],PARAMETER[\"false_northing\",0],UNIT[\"Meter\",1],AXIS[\"Easting\",EAST],AXIS[\"Northing\",NORTH]]")

# Vectorize the base grid.
r <- setValues(r, 1:(ncell(r)))                         # set cell values to integer numbers (prevent merging cells if reflectance values are to close)
r.sf <- as.polygons(r)                                  # make base grid to a polygon (each cell becomes a polygon)
r.sf <- st_as_sf(r.sf)                                  # convert "spatVector"-object (terra) to a sf-object (sf)
r.sf <- rename(r.sf, id_mask = Nadir_Reflectance_Band1) # rename column

# Get flooded forest.
sf <- st_read("data/work/flood_forest.shp")             # load flooded forest
sf <- st_transform(sf, crs(r))                          # Transform flooded forest CRS to base grid crs

# Clip flooded forest to size of base grid.
crop.box <- ext(r)                            # Get base grid extent.
crop.box <- as.polygons(crop.box, crs=crs(r)) # Make a spatVector from the extent.
sf <- st_crop(sf,crop.box)                    # Crop the flooded forest to base grid extent.

## Get one polygon for each forest type with unionized features.
for_bro <- sf %>% filter(VEG == "1100")
for_con <- sf %>% filter(VEG == "1200")
for_mix <- sf %>% filter(VEG == "1300")

# Intersect the forest types and the vectorized raster layer.
for_bro_int <- st_intersection(for_bro, r.sf)
for_con_int <- st_intersection(for_con, r.sf)
for_mix_int <- st_intersection(for_mix, r.sf)

# Make the coverage layers
cov_bro <- rasterize(for_bro_int, r, cover=TRUE)
cov_con <- rasterize(for_con_int, r, cover=TRUE)
cov_mix <- rasterize(for_mix_int, r, cover=TRUE)

cov_all <- c(cov_bro, cov_con, cov_mix)

writeRaster(cov_all, "data/work/coverage.tif")

# 04 Mask layers ---------------------------------------------------------
# Making the final mask layers based on different tresholds.

## removing all variables from the current environment.
#rm(list=ls())

cov_all <- rast("data/work/coverage.tif")

# Reclassifying the coverage layers by different tresholds.
# Values < treshold = NA
# Values > treshold = 1

# Create the function
create_mask = function(data, treshold) {
  m <- c(0, treshold, NA,
         treshold, 1, 1)
  rclmat <- matrix(m, ncol=3, byrow=TRUE)
  mask_01 <- classify(data[[01]], rclmat)
  mask_02 <- classify(data[[02]], rclmat)
  mask_03 <- classify(data[[03]], rclmat)
  all_masks <- c(mask_01, mask_02, mask_03)
  return(all_masks)
}

mask_30p <- create_mask(cov_all, 0.3)
mask_50p <- create_mask(cov_all, 0.5)
mask_66p <- create_mask(cov_all, 0.66)
mask_70p <- create_mask(cov_all, 0.7)
mask_90p <- create_mask(cov_all, 0.9)
mask_99p <- create_mask(cov_all, 0.99)

writeRaster(mask_30p, "data/work/mask_30p.tif")
writeRaster(mask_50p, "data/work/mask_50p.tif")
writeRaster(mask_70p, "data/work/mask_70p.tif")
writeRaster(mask_66p, "data/work/mask_66p.tif")
writeRaster(mask_90p, "data/work/mask_90p.tif")
writeRaster(mask_99p, "data/work/mask_99p.tif")