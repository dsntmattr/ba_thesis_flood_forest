# ==============================================================================
# SCRIPT: Download, Aggregate and Rescale MODIS Data
# PURPOSE: Download MODIS NBAR and LAI data, aggregate to monthly composites,
#          and rescale values for analysis
# AUTHOR: [Your Name]
# DATE: [Current Date]
# ==============================================================================

# PART 01: MODIS Nadir BRDF-Adjusted Reflectance (NBAR) Daily
#   - Aggregate to one image per month using mean values for each cell
#   - Rescale cell values to 0-1 range by dividing by 10000

# PART 02: MODIS Leaf Area Index/FPAR 8-Day
#   - Create cubes with one image per 8-day period
#   - Apply quality masking using quality bands
#   - Rescale cell values by multiplying with factor 0.1
#   - Aggregate to one image per month using mean values

# 00 LOAD REQUIRED PACKAGES -----------------------------------------------

# Spatial data processing
library(gdalcubes)   # Processing raster data cubes
library(sf)          # Simple features for vector data

# Data access
library(rstac)       # Access to STAC catalogs

# Data manipulation
library(magrittr)    # Pipe operators for data processing

# ==============================================================================
# PART 01: MODIS NBAR DAILY DATA PROCESSING
# ==============================================================================

# 01 DEFINE DATA DOWNLOAD FUNCTION ----------------------------------------

# Function to download and process MODIS NBAR data
# Parameters:
#   aoi: Area of interest as bounding box vector
#   toi: Time of interest as date range string (e.g., "2000-05-01/2000-09-30")
#   out: Output directory path
#   pre: Prefix for output file names

get_data = function(aoi, toi, out, pre) {
  
  # Connect to STAC catalog
  s.obj <- stac("https://planetarycomputer.microsoft.com/api/stac/v1")
  
  # Search for MODIS NBAR data within specified time and area
  it.obj <- s.obj %>%
    stac_search(collections = "modis-43A4-061",             # MODIS NBAR Daily collection
                datetime = toi,
                bbox = aoi) %>%
    get_request() %>%
    items_sign(sign_fn = sign_planetary_computer())
  
  # Extract coordinate reference system from first item
  wkt2 <- it.obj$features[[1]]$properties# ==============================================================================
# SCRIPT: Download, Aggregate and Rescale MODIS Data
# PURPOSE: Download MODIS NBAR and LAI data, aggregate to monthly composites,
#          and rescale values for analysis
# AUTHOR: [Your Name]
# DATE: [Current Date]
# ==============================================================================

# PART 01: MODIS Nadir BRDF-Adjusted Reflectance (NBAR) Daily
#   - Aggregate to one image per month using mean values for each cell
#   - Rescale cell values to 0-1 range by dividing by 10000

# PART 02: MODIS Leaf Area Index/FPAR 8-Day
#   - Create cubes with one image per 8-day period
#   - Apply quality masking using quality bands
#   - Rescale cell values by multiplying with factor 0.1
#   - Aggregate to one image per month using mean values

# 00 LOAD REQUIRED PACKAGES -----------------------------------------------

# Spatial data processing
library(gdalcubes)   # Processing raster data cubes
library(sf)          # Simple features for vector data

# Data access
library(rstac)       # Access to STAC catalogs

# Data manipulation
library(magrittr)    # Pipe operators for data processing

# ==============================================================================
# PART 01: MODIS NBAR DAILY DATA PROCESSING
# ==============================================================================

# 01 DEFINE DATA DOWNLOAD FUNCTION ----------------------------------------

# Function to download and process MODIS NBAR data
# Parameters:
#   aoi: Area of interest as bounding box vector
#   toi: Time of interest as date range string (e.g., "2000-05-01/2000-09-30")
#   out: Output directory path
#   pre: Prefix for output file names

get_data = function(aoi, toi, out, pre) {
  
proj:wkt2`
  
  # Extract acquisition dates from all items
  img.dates <- NULL
  for (i in 1:length(it.obj$features)) {
    img.dates <- c(img.dates, substr(it.obj$features[[i]]$properties$datetime, 1, 10))
  }
  img.dates <- rev(unique(img.dates))
  
  # Define bands to extract (Red, NIR, Blue for vegetation indices)
  assets <- c("Nadir_Reflectance_Band1",                    # Red band
              "Nadir_Reflectance_Band2",                    # NIR band  
              "Nadir_Reflectance_Band3")                    # Blue band
  collection <- stac_image_collection(it.obj$features, asset_names = assets)
  
  # Define spatial extent for data cube
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
  
  # Project AOI to satellite image projection
  aoi.extent <- st_bbox(st_transform(st_as_sfc(aoi.extent), wkt2))
  
  # Create data cube view for monthly aggregation
  v = cube_view(srs = wkt2,                                 # Coordinate reference system
                extent = list(t0 = substr(toi, 1, 10),     # Start date
                              t1 = substr(toi, 12, 22),    # End date
                              left = aoi.extent$xmin,      # Western boundary
                              right = aoi.extent$xmax,     # Eastern boundary
                              top = aoi.extent$ymax,       # Northern boundary
                              bottom = aoi.extent$ymin),   # Southern boundary
                dx = 500,                                   # Pixel size in x direction (meters)
                dy = 500,                                   # Pixel size in y direction (meters)
                dt = "P1M",                                 # Temporal aggregation: monthly
                aggregation = "mean",                       # Aggregation method: mean
                resampling = "bilinear")                    # Resampling method
  
  # Create raster cube and rescale reflectance values
  # MODIS reflectance values are scaled by 10000, divide to get 0-1 range
  cube = raster_cube(collection, v) %>%
    apply_pixel(c("Nadir_Reflectance_Band1 / 10000",       # Rescale red band
                  "Nadir_Reflectance_Band2 / 10000",       # Rescale NIR band
                  "Nadir_Reflectance_Band3 / 10000"),      # Rescale blue band
                c("x1", "x2", "x3"))                       # Output band names
  
  # Save processed data as GeoTIFF files
  write_tif(cube,
            dir = out,
            prefix = pre)
}

# 02 SET PROCESSING PARAMETERS ---------------------------------------------

# Load bounding box from previous processing step
load("data/work/bbox.vector.RData")    
aoi <- bbox.vector                                          # Area of interest
pre <- 'MODIS_'                                            # File prefix

# 03 PROCESS REFERENCE PERIOD DATA ----------------------------------------
# Download and process MODIS NBAR data for reference period (2000-2012)

out <- "data/work/reference/P1M/"                          # Output directory

# Process each year of reference period (May-September growing season)
get_data(aoi, toi = "2000-05-01/2000-09-30", out, pre)
get_data(aoi, toi = "2001-05-01/2001-09-30", out, pre)
get_data(aoi, toi = "2002-05-01/2002-09-30", out, pre)
get_data(aoi, toi = "2003-05-01/2003-09-30", out, pre)
get_data(aoi, toi = "2004-05-01/2004-09-30", out, pre)
get_data(aoi, toi = "2005-05-01/2005-09-30", out, pre)
get_data(aoi, toi = "2006-05-01/2006-09-30", out, pre)
get_data(aoi, toi = "2007-05-01/2007-09-30", out, pre)
get_data(aoi, toi = "2008-05-01/2008-09-30", out, pre)
get_data(aoi, toi = "2009-05-01/2009-09-30", out, pre)
get_data(aoi, toi = "2010-05-01/2010-09-30", out, pre)
get_data(aoi, toi = "2011-05-01/2011-09-30", out, pre)
get_data(aoi, toi = "2012-05-01/2012-09-30", out, pre)

# 04 PROCESS STUDY PERIOD DATA --------------------------------------------
# Download and process MODIS NBAR data for study period (2013-2017)

out <- "data/work/study/P1M/"                              # Output directory

# Process each year of study period (May-September growing season)
get_data(aoi, toi = "2013-05-01/2013-09-30", out, pre)
get_data(aoi, toi = "2014-05-01/2014-09-30", out, pre)
get_data(aoi, toi = "2015-05-01/2015-09-30", out, pre)
get_data(aoi, toi = "2016-05-01/2016-09-30", out, pre)
get_data(aoi, toi = "2017-05-01/2017-09-30", out, pre)

# ==============================================================================
# PART 02: MODIS LEAF AREA INDEX/FPAR 8-DAY DATA PROCESSING
# ==============================================================================

# 05 DEFINE LAI DATA DOWNLOAD FUNCTION ------------------------------------

# Function to download and process MODIS LAI data
# Parameters same as get_data function above
get_data = function(aoi, toi, out, pre) {
  
  # Connect to STAC catalog
  s.obj <- stac("https://planetarycomputer.microsoft.com/api/stac/v1")
  
  # Search for MODIS LAI data within specified time and area
  it.obj <- s.obj %>% 
    stac_search(collections = "modis-15A2H-061",            # MODIS LAI/FPAR 8-Day collection
                datetime = toi,
                bbox = aoi) %>%
    get_request() %>%
    items_sign(sign_fn = sign_planetary_computer())
  
  # Extract coordinate reference system from first item
  wkt2 <- it.obj$features[[1]]$properties# ==============================================================================
# SCRIPT: Download, Aggregate and Rescale MODIS Data
# PURPOSE: Download MODIS NBAR and LAI data, aggregate to monthly composites,
#          and rescale values for analysis
# AUTHOR: [Your Name]
# DATE: [Current Date]
# ==============================================================================

# PART 01: MODIS Nadir BRDF-Adjusted Reflectance (NBAR) Daily
#   - Aggregate to one image per month using mean values for each cell
#   - Rescale cell values to 0-1 range by dividing by 10000

# PART 02: MODIS Leaf Area Index/FPAR 8-Day
#   - Create cubes with one image per 8-day period
#   - Apply quality masking using quality bands
#   - Rescale cell values by multiplying with factor 0.1
#   - Aggregate to one image per month using mean values

# 00 LOAD REQUIRED PACKAGES -----------------------------------------------

# Spatial data processing
library(gdalcubes)   # Processing raster data cubes
library(sf)          # Simple features for vector data

# Data access
library(rstac)       # Access to STAC catalogs

# Data manipulation
library(magrittr)    # Pipe operators for data processing

# ==============================================================================
# PART 01: MODIS NBAR DAILY DATA PROCESSING
# ==============================================================================

# 01 DEFINE DATA DOWNLOAD FUNCTION ----------------------------------------

# Function to download and process MODIS NBAR data
# Parameters:
#   aoi: Area of interest as bounding box vector
#   toi: Time of interest as date range string (e.g., "2000-05-01/2000-09-30")
#   out: Output directory path
#   pre: Prefix for output file names

get_data = function(aoi, toi, out, pre) {
  
proj:wkt2`
  
  # Extract acquisition dates from all items
  img.dates <- NULL
  for (i in 1:length(it.obj$features)) {
    img.dates <- c(img.dates, substr(it.obj$features[[i]]$properties$datetime, 1, 10))
  }
  img.dates <- rev(unique(img.dates))
  
  # Define LAI band to extract
  assets <- c("Lai_500m")                                   # LAI at 500m resolution
  # Note: Quality bands "FparLai_QC", "FparExtra_QC" available but not used here
  collection <- stac_image_collection(it.obj$features, asset_names = assets)
  
  # Define spatial extent for data cube
  xmin <- aoi[1]
  ymin <- aoi[2]
  xmax <- aoi[3]
  ymax <- aoi[4]
  aoi.extent <- st_bbox(c(xmin = xmin, xmax = xmax,
                         ymin = ymin, ymax = ymax),
                       crs = 4326)
  aoi.extent <- aoi.extent %>% st_as_sfc() %>% st_as_sf()
  
  # Project AOI to satellite image projection
  aoi.extent <- st_bbox(st_transform(st_as_sfc(aoi.extent), wkt2))
  
  # Create data cube view for 8-day periods
  v = cube_view(srs = wkt2,                                 # Coordinate reference system
                extent = list(t0 = substr(toi, 1, 10),     # Start date
                              t1 = substr(toi, 12, 22),    # End date
                              left = aoi.extent$xmin,      # Western boundary
                              right = aoi.extent$xmax,     # Eastern boundary
                              top = aoi.extent$ymax,       # Northern boundary
                              bottom = aoi.extent$ymin),   # Southern boundary
                dx = 500,                                   # Pixel size in x direction (meters)
                dy = 500,                                   # Pixel size in y direction (meters)
                dt = "P8D")                                 # Temporal resolution: 8 days
  
  # Create raster cube with optional quality masking and rescaling
  cube = raster_cube(collection, v) |>
    # Optional quality masking (commented out):
    # mask = image_mask("FparLai_QC", values = 0, invert = TRUE)
    # filter_pixel("FparExtra_QC == 0") |>
    apply_pixel(c("Lai_500m * 0.1"), c("x1"))              # Rescale LAI values by factor 0.1
  
  # Aggregate 8-day data to monthly means
  cube_monthly = aggregate_time(cube, dt = "P1M", method = "mean")
  
  # Save processed LAI data
  write_tif(cube_monthly,
            dir = out,
            prefix = pre)
}

# 06 SET LAI PROCESSING PARAMETERS ----------------------------------------

# Load bounding box from previous processing step
load("data/work/aoi/bbox.vector.RData")
aoi <- bbox.vector                                          # Area of interest
pre <- "LAI_"                                              # File prefix

# 07 PROCESS REFERENCE PERIOD LAI DATA -----------------------------------

# Create vector with time periods for reference period
years <- 2003:2012                                          # LAI reference period (10 years)
toi_vec <- paste0(years, "-05-01/", years, "-09-30")       # May-September for each year

out <- "data/work/reference/lai/no_qa/p1m"                 # Output directory

# Process each year of reference period
for (toi in toi_vec) {
  get_data(aoi, toi = toi, out, pre)
}

# Remove unwanted October files (artifacts from processing)
trash <- list.files(out, pattern = "10-01", full.names = TRUE)
file.remove(trash)

# 08 PROCESS STUDY PERIOD LAI DATA ----------------------------------------

out <- "data/work/study/lai/no_qa/p1m"                     # Output directory

# Create vector with time periods for study period
years <- 2013:2017                                          # Study period (5 years)
toi_vec <- paste0(years, "-05-01/", years, "-09-30")       # May-September for each year

# Process each year of study period
for (toi in toi_vec) {
  get_data(aoi, toi = toi, out, pre)
}

# 09 CLEAN UP TEMPORARY FILES ---------------------------------------------

# Remove unwanted October files (artifacts from processing)
trash <- list.files(out, pattern = "10-01", full.names = TRUE)
file.remove(trash)

# Optional: Remove auxiliary files if present
# trash <- list.files("data/work/reference/lai/P1M", pattern = ".aux", full.names = TRUE)
# file.remove(trash)
# trash <- list.files("data/work/study/lai/P1M", pattern = ".aux", full.names = TRUE)
# file.remove(trash)