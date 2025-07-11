# Load data from catalog. -----------------------------------------------

# Part 01: MODIS Nadir BRDF-Adjusted Reflectance (NBAR) Daily
  # aggregate to one picture per month with mean values for each cell, 
  # and rescaling the cell values to values between 0 and 1 (by division though 10000)

# Part 02: MODIS Leaf Area Index/FPAR 8-Day
  # get cubes with one picture for 8 days,
  # mask the scenes using quality bands,
  # rescaling the cell values by multiplying with factor 0.1
  # and aggregate to one picture per month with mean values for each cell.

# Packages ---------------------------------------------------------
# Spatial data
library(gdalcubes)   # raster cubes
library(sf)          # vector
# Access to STAC-catalouges
library(rstac)       
# Data manipulation and more.
library(magrittr)

# Part 01 -----------------------------------------------------------------

# Create function. --------------------------------------------------------

# Needed variables:
# aoi (bounding box of area of interest as vector)
# toi (time of interest e.g "2000-05-01/2000-09-30")
# out (output path)
# pre (prefix for the output file names)

get_data = function(aoi, toi, out, pre) {
  
  # link to collection
  s.obj <- stac("https://planetarycomputer.microsoft.com/api/stac/v1")
  
  #filter collection to find the elements we want containing the coordinates of interest
  it.obj <- s.obj %>%
    stac_search(collections = "modis-43A4-061",
                datetime = toi,
                bbox = aoi) %>%
    get_request() %>%
    items_sign(sign_fn = sign_planetary_computer())
  
  #get the coordinate system
  wkt2 <- it.obj$features[[1]]$properties$`proj:wkt2`
  
  #get the acquisition date
  img.dates <- NULL
  for (i in 1:length(it.obj$features)) {
    img.dates <- c(img.dates,substr(it.obj$features[[i]]$properties$datetime, 1, 10))
  }
  img.dates <- rev(unique(img.dates))
  
  #define the Bands you want to extract
  assets <- c("Nadir_Reflectance_Band1","Nadir_Reflectance_Band2", "Nadir_Reflectance_Band3")
  collection  <- stac_image_collection(it.obj$features, asset_names = assets)
  
  #define the study area for the cut
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
  
  #project aoi to satellite image projection
  aoi.extent  <- st_bbox(st_transform(st_as_sfc(aoi.extent),wkt2))
  
  #datacube for images at acquisition time  
  v     = cube_view(srs = wkt2,  
                    extent = list(t0      = substr(toi, 1, 10),
                                  t1      = substr(toi, 12, 22),
                                  left    = aoi.extent$xmin,
                                  right   = aoi.extent$xmax,
                                  top     = aoi.extent$ymax,
                                  bottom  = aoi.extent$ymin),
                    dx = 500,
                    dy = 500,
                    dt = "P1M",
                    aggregation = "mean",
                    resampling = "bilinear")
  
  cube = raster_cube(collection, v) %>%
    apply_pixel( c("Nadir_Reflectance_Band1 / 10000", "Nadir_Reflectance_Band2 / 10000", "Nadir_Reflectance_Band3 / 10000"), c("x1", "x2", "x3")
    )
  
  # Saving
  write_tif((cube),
            dir = out,
            prefix = pre)
}

# Variables.
load("data/work/bbox.vector.RData")    
aoi  <- bbox.vector               
pre  <- 'MODIS_'

# Reference period. -------------------------------------------------------

out  <- "data/work/reference/P1M/"

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

# Study period. -----------------------------------------------------------

out  <- "data/work/study/P1M/"

get_data(aoi, toi = "2013-05-01/2013-09-30", out, pre)
get_data(aoi, toi = "2014-05-01/2014-09-30", out, pre)
get_data(aoi, toi = "2015-05-01/2015-09-30", out, pre)
get_data(aoi, toi = "2016-05-01/2016-09-30", out, pre)
get_data(aoi, toi = "2017-05-01/2017-09-30", out, pre)



# Part 02 -----------------------------------------------------------------


# Create the function. ----------------------------------------------------
get_data = function(aoi, toi, out, pre) {
  
  #link to collection
  s.obj <- stac("https://planetarycomputer.microsoft.com/api/stac/v1")
  
  #filter collection to find the elements we want containing the coordinates of interest
  it.obj <- s.obj %>% 
    stac_search(collections = "modis-15A2H-061",
                datetime = toi,
                bbox = aoi) %>%
    get_request() %>%
    items_sign(sign_fn = sign_planetary_computer())
  
  #get the coordinate system
  wkt2 <- it.obj$features[[1]]$properties$`proj:wkt2`
  
  #get the acquisition date
  img.dates <- NULL
  for (i in 1:length(it.obj$features)) {
    img.dates <- c(img.dates,substr(it.obj$features[[i]]$properties$datetime, 1, 10))
  }
  img.dates <- rev(unique(img.dates))
  
  #define the Bands you want to extract
  assets      <- c("Lai_500m", "FparLai_QC", "FparExtra_QC")
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
  ## make a view to show each image without any aggregation or sth
  v     = cube_view(srs = wkt2,  extent = list(t0 = substr(toi, 1, 10), t1 = substr(toi, 12, 22),
                                               left = aoi.extent$xmin, right = aoi.extent$xmax,
                                               top = aoi.extent$ymax, bottom = aoi.extent$ymin),
                    dx = 500, dy = 500, dt="P8D")
  
  ## make a cube a mask bad pixels with the two quality bands
  cube = raster_cube(collection, v, mask = image_mask("FparLai_QC", values = 0, invert = TRUE)) |>
    # filter_pixel("FparExtra_QC == 0") |>
    apply_pixel(c("Lai_500m * 0.1"), c("x1"))
  
  cube_monthly = aggregate_time(cube, dt = "P1M", method = "mean")
  
  write_tif((cube_monthly),
            dir = out,
            prefix = pre)
}

# Variables. ----------------------------------------------------
load("data/work/aoi/bbox.vector.RData")
aoi   <- bbox.vector
pre <- "LAI_"

# Reference. ----------------------------------------------------

# Create vector with all TOIs of the reference period.
years <- 2003:2012
toi_vec <- paste0(years, "-05-01/", years, "-09-30")

out <- "data/work/reference/lai/no_qa/p1m"

for (toi in toi_vec) {
  get_data(aoi, toi = toi, out, pre)
}

# Remove trash.
trash <- list.files(out, pattern = "10-01", full.names = TRUE)
file.remove(trash)

# Study period. ----------------------------------------------------
out <- "data/work/study/lai/no_qa/p1m"

# Create vector with all TOIs of the study period.
years <- 2013:2017
toi_vec <- paste0(years, "-05-01/", years, "-09-30")

for (toi in toi_vec) {
  get_data(aoi, toi = toi, out, pre)
}

# Remove trash.
trash <- list.files(out, pattern = "10-01", full.names = TRUE)
file.remove(trash)

# more trash --------------------------------------------
#trash <- list.files("data/work/reference/lai/P1M", pattern = ".aux", full.names = TRUE)
#file.remove(trash)
#trash <- list.files("data/work/study/lai/P1M", pattern = ".aux", full.names = TRUE)
#file.remove(trash)