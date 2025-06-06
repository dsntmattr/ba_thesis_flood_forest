# Function to load data from catalog and aggregate it over a selected timespane.

# Needed variables:

# aoi (bounding box of area of interest as vector)
# toi (time of interest e.g "2000-05-01/2000-09-30")
# col (collection e.g "modis-43A4-061")
# bds (bands to extract as vector e.g c("Nadir_Reflectance_Band1"))
# dt (timespane for pictures in cubeview e.g P1D)
# out (output path)
# pre (prefix for the output file names)

get_data = function(aoi, toi, coll, bds, dt, out, pre) {
  
  # link to collection
  s.obj <- stac("https://planetarycomputer.microsoft.com/api/stac/v1")
  
  #filter collection to find the elements we want containing the coordinates of interest
  it.obj <- s.obj %>%
    stac_search(collections = coll,
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
  collection  <- stac_image_collection(it.obj$features, asset_names = bds)
  
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
                    dt = dt,
                    aggregation = "mean",
                    resampling = "bilinear")
  
  cube = raster_cube(collection, v)
  
  # Saving
  write_tif((cube),
            dir = out,
            prefix = pre)
}


