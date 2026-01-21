# ==============================================================================
# SCRIPT: Create Area of Interest (AOI), Coverage Layers and Forest Masks
# PURPOSE: Intersect floodplains with forest areas and create coverage masks
#          with different thresholds for remote sensing analysis
# AUTHOR: Matthias Lerch
# DATE: [Current Date]
# ==============================================================================

# 00 LOAD REQUIRED PACKAGES -----------------------------------------------

# Spatial data processing
library(gdalcubes)   # Processing raster data cubes
library(sf)          # Simple features for vector data
library(terra)       # Spatial raster data analysis

# Data access
library(rstac)       # Access to STAC (SpatioTemporal Asset Catalog) endpoints

# Data manipulation
library(tidyverse)   # Collection of data science packages

# ==============================================================================
# SETUP: Create required directories
# ==============================================================================

required_dirs <- c(
  "data/work/aoi/",
  "data/work/crs/",
  "data/work/mask/"
)

# Create all directories
for (dir in required_dirs) {
  dir.create(dir, recursive = TRUE, showWarnings = FALSE)
}

# 01 CREATE FLOODED FOREST INTERSECTION -----------------------------------
# Intersect floodplains and forest areas to define study area

# Load and process floodplains data
floodplains <- st_read("data/raw/floodplains/FLUT_LK.shp")  # Read floodplains shapefile
floodplains <- st_transform(floodplains, crs = 25832)       # Transform to EPSG:25832 (ETRS89:UTM32N)
floodplains <- st_union(floodplains)                        # Dissolve internal boundaries (output: sfc-object)
floodplains <- st_sf(floodplains)                           # Convert back to sf-object

# Load and process forest data
forest <- st_read("data/raw/dlm_st_veg02_f/veg02_f.shp")    # Read forest vegetation shapefile
forest <- forest %>%
  group_by(VEG) %>%                                         # Group by vegetation type values in "VEG" column
  summarise(geometry = st_union(geometry))                  # Union geometries for each vegetation type

# Create intersection of floodplains and forest areas
flood_forest <- st_intersection(floodplains, forest)        # Calculate spatial intersection

# Save the flooded forest intersection
if (!dir.exists("data/work/aoi/")) {
  dir.create("data/work/aoi/", recursive = TRUE)
}
st_write(flood_forest, "data/work/aoi/flood_forest.shp")        # Export as shapefile

# 02 CREATE BASE GRID FOR ANALYSIS ----------------------------------------
# Generate a base grid covering the entire study area as template for masks

# Clear environment variables
rm(list=ls())

# Connect to STAC catalog
s.obj <- stac("https://planetarycomputer.microsoft.com/api/stac/v1")

# Load AOI and get bounding box
sf <- st_read("data/work/aoi/flood_forest.shp")                 # Read flooded forest data
sf <- st_transform(sf, crs = 4326)                          # Transform to WGS84 (EPSG:4326)
bbox <- st_bbox(sf)                                         # Extract bounding box
bbox.vector <- as.vector(bbox)                              # Convert to numeric vector
save(bbox.vector, file = "data/work/aoi/bbox.vector.RData")     # Save bounding box for later use

# Download MODIS scenes for base grid creation
toi <- "2013-05-01/2013-05-02"                              # Set time period of interest (2 days)
aoi <- bbox.vector                                          # Set area of interest

# Search STAC catalog for MODIS NBAR data
it.obj <- s.obj %>%
  stac_search(collections = "modis-43A4-061",               # MODIS NBAR Daily collection
              datetime = toi,
              bbox = aoi) %>%
  get_request() %>%
  items_sign(sign_fn = sign_planetary_computer())           # Sign request for Planetary Computer

# Display search results
it.obj

# Extract coordinate reference system from MODIS data
wkt2 <- it.obj$features[[1]]$properties$`proj:wkt2`
# Save crs as character vector
save(wkt2, file = "data/work/crs/wkt2.RData")

# Define bands to extract for base grid
assets <- c("Nadir_Reflectance_Band1")                      # Red band for base grid creation
collection <- stac_image_collection(it.obj$features, asset_names = assets)

# Define study area extent for data cube
xmin <- aoi[1]
ymin <- aoi[2]
xmax <- aoi[3]
ymax <- aoi[4]

# Create bounding box object
aoi.extent <- st_bbox(c(xmin = xmin,
                       xmax = xmax,
                       ymin = ymin,
                       ymax = ymax),
                     crs = 4326)

aoi.extent <- aoi.extent %>% st_as_sfc() %>% st_as_sf()

# Project AOI to satellite image projection (Sinusoidal)
aoi.extent <- st_bbox(st_transform(st_as_sfc(aoi.extent), wkt2))

# Create data cube view for base grid
v = cube_view(srs = wkt2,                                   # Coordinate reference system
              extent = list(t0 = substr(toi, 1, 10),       # Start date
                            t1 = substr(toi, 12, 22),      # End date
                            left = aoi.extent$xmin,        # Western boundary
                            right = aoi.extent$xmax,       # Eastern boundary
                            top = aoi.extent$ymax,         # Northern boundary
                            bottom = aoi.extent$ymin),     # Southern boundary
              dx = 500,                                     # Pixel size in x direction (meters)
              dy = 500,                                     # Pixel size in y direction (meters)
              dt = "P1D")                                   # Temporal resolution (1 day)

# Create raster cube from collection
cube = raster_cube(collection, v)

# Extract acquisition dates from STAC items
img.dates <- NULL
for (i in 1:length(it.obj$features)) {
  img.dates <- c(img.dates, substr(it.obj$features[[i]]$properties$datetime, 1, 10))
}
img.dates <- rev(unique(img.dates))

# Save base grid as GeoTIFF
write_tif(select_time(raster_cube(collection, v), img.dates),
          dir = "data/work",
          prefix = 'MODIS_BASEGRID_')

# 03 CALCULATE FOREST TYPE COVERAGE ---------------------------------------
# Calculate coverage layers (cell values = percentage coverage by forest type)

# Clear environment variables
rm(list=ls())

# Load base grid raster
r <- rast("data/work/MODIS_BASEGRID_2013-05-01.tif")        # Read base grid

# Set coordinate reference system (assignment only, no transformation)
load("data/work/crs/wkt2.RData")
crs(r) <- wkt2

# Vectorize the base grid
r <- setValues(r, 1:(ncell(r)))                             # Assign unique cell IDs to prevent merging
r.sf <- as.polygons(r)                                      # Convert raster to polygons
r.sf <- st_as_sf(r.sf)                                      # Convert to sf object
r.sf <- rename(r.sf, id_mask = Nadir_Reflectance_Band1)     # Rename ID column

# Load and process flooded forest data
sf <- st_read("data/work/aoi/flood_forest.shp")                 # Load flooded forest intersection
sf <- st_transform(sf, crs(r))                              # Transform to base grid CRS

# Clip flooded forest to base grid extent
crop.box <- ext(r)                                          # Get base grid extent
crop.box <- as.polygons(crop.box, crs = crs(r))            # Convert extent to polygon
sf <- st_crop(sf, crop.box)                                 # Crop flooded forest to grid extent

# Separate forest types based on vegetation codes
# VEG codes: 1100 = Broadleaf, 1200 = Coniferous, 1300 = Mixed
for_bro <- sf %>% filter(VEG == "1100")                     # Broadleaf forests
for_con <- sf %>% filter(VEG == "1200")                     # Coniferous forests  
for_mix <- sf %>% filter(VEG == "1300")                     # Mixed forests

# Calculate intersections between forest types and grid cells
for_bro_int <- st_intersection(for_bro, r.sf)               # Broadleaf-grid intersection
for_con_int <- st_intersection(for_con, r.sf)               # Coniferous-grid intersection
for_mix_int <- st_intersection(for_mix, r.sf)               # Mixed-grid intersection

# Create coverage rasters (percentage coverage per cell)
cov_bro <- rasterize(for_bro_int, r, cover = TRUE)          # Broadleaf coverage
cov_con <- rasterize(for_con_int, r, cover = TRUE)          # Coniferous coverage
cov_mix <- rasterize(for_mix_int, r, cover = TRUE)          # Mixed coverage

# Combine all coverage layers into single raster stack
cov_all <- c(cov_bro, cov_con, cov_mix)

# Save coverage layers
writeRaster(cov_all, "data/work/mask/coverage.tif")

# clean up temporary files (base grid) 

trash <- list.files("data/work/", pattern = "BASEGRID", full.names = TRUE)
file.remove(trash)

# 04 CREATE FOREST MASKS WITH DIFFERENT THRESHOLDS -----------------------
# Generate binary masks based on different coverage thresholds

# Load coverage layers (optional: clear environment first)
# rm(list=ls())
cov_all <- rast("data/work/mask/coverage.tif")

# Define function to create binary masks based on coverage thresholds
# Values below threshold = NA (masked out)
# Values above threshold = 1 (included)
create_mask = function(data, threshold) {
  # Define reclassification matrix
  m <- c(0, threshold, NA,                                  # 0 to threshold -> NA
         threshold, 1, 1)                                   # threshold to 1 -> 1
  rclmat <- matrix(m, ncol = 3, byrow = TRUE)
  
  # Apply reclassification to each forest type layer
  mask_01 <- classify(data[[01]], rclmat)                   # Broadleaf mask
  mask_02 <- classify(data[[02]], rclmat)                   # Coniferous mask
  mask_03 <- classify(data[[03]], rclmat)                   # Mixed mask
  
  # Combine masks into single raster stack
  all_masks <- c(mask_01, mask_02, mask_03)
  return(all_masks)
}

# Create masks with different coverage thresholds
mask_66p <- create_mask(cov_all, 0.66)                      # 66% coverage threshold

# Save all mask layers as GeoTIFF files
writeRaster(mask_66p, "data/work/mask/mask_66p.tif")
