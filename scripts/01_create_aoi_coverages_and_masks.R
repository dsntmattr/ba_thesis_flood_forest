# 0.0 Packages ####
library(sf) # for vector data
library(tidyverse) # for tables and other stuff
library(magrittr) # for %>%
library(terra) # for raster data
library(rstac) # for data access
library(magrittr) # for %>%
library(gdalcubes) # for raster cubes

# 1.0 Flooded forests ####
# Intersection the raw datasets floodplains ("FLUT_LK.shp) and forest area types (DLM veg02_f.shp; VEG == 1100, 1200, 1300)

# Read the floodplains
# Transform its CRS to EPSG:25832 (ETRS89:UTM32N)
# Dissolve internal borders between the polygon (the raw data is devides by provinces(Landkreise))
floodplains <- st_read("data/raw/floodplains/FLUT_LK.shp")
floodplains <- st_transform(floodplains, crs = 25832)
floodplains <-st_union(floodplains)
floodplains <-st_sf(floodplains) # ???

## Read the forest areas
forest <- st_read("data/raw/clc12_5ha_st_forest_types/clc12_forest_types_st.shp")
forest <- st_transform(forest, crs = 25832)
## Dissolving forest dataset to each Code_12 class.
forest <- forest %>%
  group_by(Code_12) %>%
  summarise(geometry = st_union(geometry)) ## Creates a new column "geometry" where all former geometries are unionized.

## Intersect floodplains and forest
flood_forest <- st_intersection(floodplains, forest)

st_write(flood_forest, "data/work/clc12_5ha/flood_forest.shp")

# 2.0 Base grid ####
# Get a base grid which covers the whole study area, to use it later as template for the masks
## removing all variables from the current environment.
rm(list=ls())

#link to collection
s.obj <- stac("https://planetarycomputer.microsoft.com/api/stac/v1")

#load aoi shapefile to get bounding box
sf <-st_read ("data/work/clc12_5ha/flood_forest.shp")
sf <- st_transform(sf, crs =4326)
bbox <- st_bbox(sf)
bbox.vector <- as.vector(bbox)
save(bbox.vector, file = "data/work/bbox.vector.RData")

#set time period of interest
toi   <- "2013-05-01/2013-05-02"

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

#define the Bands you want to extract
assets      <- c("Nadir_Reflectance_Band1")
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
aoi.extent  <- st_bbox(st_transform(st_as_sfc(aoi.extent), wkt2))

#datacube for images at acquisition time  
v     = cube_view(srs = wkt2,  extent = list(t0 = substr(toi, 1, 10), t1 = substr(toi, 12, 22),
                                             left = aoi.extent$xmin, right = aoi.extent$xmax,  top = aoi.extent$ymax, bottom = aoi.extent$ymin),
                  dx = 500, dy = 500, dt="P1D")


cube = raster_cube(collection, v)

#get the acquisition date
img.dates <- NULL
for (i in 1:length(it.obj$features)) {
  img.dates <- c(img.dates,substr(it.obj$features[[i]]$properties$datetime, 1, 10))
}
img.dates <- rev(unique(img.dates))

write_tif(select_time(raster_cube(collection, v),img.dates),
          dir="data/work/clc12_5ha",
          prefix='MODIS_')


# 3.0 Coverage layers ####
# Get 3 raster layers whose cell values represent the cellsm covergages by the different forest typen as a value betwenn 0 and 1.

## removing all variables from the current environment.
rm(list=ls())

## Reading the MODIS scene
r <- rast("data/work/clc12_5ha/MODIS_2013-05-01.tif")

## Set the CRS of the MODIS scene. Watch out, we don't project or transform the CRS.
## We just tell the data, which CRS it has.
crs(r) <- ("PROJCS[\"unnamed\",GEOGCS[\"Unknown datum based upon the custom spheroid\",DATUM[\"Not specified (based on custom spheroid)\",SPHEROID[\"Custom spheroid\",6371007.181,0]],PRIMEM[\"Greenwich\",0],UNIT[\"degree\",0.0174532925199433,AUTHORITY[\"EPSG\",\"9122\"]]],PROJECTION[\"Sinusoidal\"],PARAMETER[\"longitude_of_center\",0],PARAMETER[\"false_easting\",0],PARAMETER[\"false_northing\",0],UNIT[\"Meter\",1],AXIS[\"Easting\",EAST],AXIS[\"Northing\",NORTH]]")

## Changing the cell values from the orignal values (reflectances) to integer numbers, 
## so each cell gets one particular integer value (like an unique ID)
## This step is important at this point, because the origial reflectance values of neighbouring cells could be too close to each other,
## which could lead to mistakes in the polygonizing process.
r <- setValues(r, 1:(ncell(r)))

## Convert the MODIS raster to a polygon dataset. Each raster cell becomes a polygon.
r.sf <- as.polygons(r)

## Convert the polygon with the class "spatVector" (terra package) to a sf-object (sf package)
r.sf <- st_as_sf(r.sf)

## Rename the column "Nadir_Reflectance_Band1" to "id_mask"
r.sf <- rename(r.sf, id_mask = Nadir_Reflectance_Band1)

## Now we need the flooded forests to overlap them with our vectorized raster layer.
sf <- st_read("data/work/clc12_5ha/flood_forest.shp")

## Transform the CRS of the forest layer to the CRS of our MODIS scene.
sf <- st_transform(sf, crs(r))

## Get the first column of forest dataset (VEG = code which represents the different forest types)
#sf1 <- sf[1]

# Add a ID column to the forest dataset.
#sf$ID_sf <- 1:nrow(sf)

## Now we want to clip the forest dataset to the size of the modis scene.
## Get the MODIS scene extent.
crop.box <- ext(r)

## Make a SpatVector from the extent.
crop.box <- as.polygons(crop.box, crs=crs(r))

## Crop the flooded forest data to the MODIS scene extent.
sf <- st_crop(sf,crop.box)

## Get one polygon for each forest type with unionized features.
# 311 - Broad
# 312 - Conifer
# 313 - Mixed
for_bro <- sf %>% filter(Code_12 == "311")
for_con <- sf %>% filter(Code_12 == "312")
for_mix <- sf %>% filter(Code_12 == "313")

## Intersect the forest types and the vectorized raster layer.
for_bro_int <- st_intersection(for_bro, r.sf)
for_con_int <- st_intersection(for_con, r.sf)
for_mix_int <- st_intersection(for_mix, r.sf)

## Get a raster with all cell from modis which are coverd by forest type 
## and where the cell value = coverage of the cell by forest in percentage (0-1).
cov_bro <- rasterize(for_bro_int, r, cover=TRUE)
cov_con <- rasterize(for_con_int, r, cover=TRUE)
cov_mix <- rasterize(for_mix_int, r, cover=TRUE)

writeRaster(cov_bro, "data/work/clc12_5ha/cov_bro.tif")
writeRaster(cov_con, "data/work/clc12_5ha/cov_con.tif")
writeRaster(cov_mix, "data/work/clc12_5ha/cov_mix.tif")

# 4.0 Mask layers ####
# Making the final mask layers based on different tresholds.

## removing all variables from the current environment.
rm(list=ls())

cov_bro <- rast("data/work/clc12_5ha/cov_bro.tif")
cov_con <- rast("data/work/clc12_5ha/cov_con.tif")
cov_mix <- rast("data/work/clc12_5ha/cov_mix.tif")

cov_all <- c(cov_bro, cov_con, cov_mix)

## Create a multiple reclass matrices to reclassify the raster files.
## We set different tresholds to get different mask layers to compare the results of the later calculated indice values,
## based on different forest coverages.
## All cells with a forest type coverage under the treshold get the value NA, all cells with a forest type coverage above the treshold get the value 1.

# create the function

testdata <- c(cov_bro, cov_con, cov_mix)

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




## Mask 1: treshold = 0.3 (30%)
writeRaster(mask_30p, "data/work/clc12_5ha/mask_30p.tif")

## Mask 2: treshold = 0.5 (50%)
m <- c(0, 0.5, NA,
       0.5, 1, 1)
rclmat_50 <- matrix(m, ncol=3, byrow=TRUE)

mask_bro_50 <- classify(cov_bro, rclmat_50)
mask_con_50 <- classify(cov_con, rclmat_50)
mask_mix_50 <- classify(cov_mix, rclmat_50)

mask_50p <- c(mask_bro_50, mask_con_50, mask_mix_50)
writeRaster(mask_50p, "data/work/clc12_5ha/mask_50p.tif")

## Mask 3: treshold = 0.7 (70%)
m <- c(0, 0.7, NA,
       0.7, 1, 1)
rclmat_70 <- matrix(m, ncol=3, byrow=TRUE)

mask_bro_70 <- classify(cov_bro, rclmat_70)
mask_con_70 <- classify(cov_con, rclmat_70)
mask_mix_70 <- classify(cov_mix, rclmat_70)

mask_70p <- c(mask_bro_70, mask_con_70, mask_mix_70)
writeRaster(mask_70p, "data/work/clc12_5ha/mask_70p.tif")

## Mask 4: treshold = 0.9 (90%)
m <- c(0, 0.9, NA,
       0.9, 1, 1)
rclmat_90 <- matrix(m, ncol=3, byrow=TRUE)

mask_bro_90 <- classify(cov_bro, rclmat_90)
mask_con_90 <- classify(cov_con, rclmat_90)
mask_mix_90 <- classify(cov_mix, rclmat_90)

mask_90p <- c(mask_bro_90, mask_con_90, mask_mix_90)
writeRaster(mask_90p, "data/work/clc12_5ha/mask_90p.tif")

## Mask 5: treshold = 0.99 (99%)
m <- c(0, 0.99, NA,
       0.99, 1, 1)
rclmat_99 <- matrix(m, ncol=3, byrow=TRUE)

mask_bro_99 <- classify(cov_bro, rclmat_99)
mask_con_99 <- classify(cov_con, rclmat_99)
mask_mix_99 <- classify(cov_mix, rclmat_99)

mask_99p <- c(mask_bro_99, mask_con_99, mask_mix_99)
writeRaster(mask_99p, "data/work/clc12_5ha/mask_99p.tif")


