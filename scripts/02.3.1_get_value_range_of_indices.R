# Get MINMAX values to harmonising values.

library(terra)     # raster

# Loading the indices.
ndvi <- rast(list.files(path = "data/work/reference/indices", pattern = "NDVI", full.names = TRUE)) 
evi <- rast(list.files(path = "data/work/reference/indices", pattern = "EVI", full.names = TRUE))
nirv <- rast(list.files(path = "data/work/reference/indices", pattern = "NIRv", full.names = TRUE))

mask <- rast("data/work/mask_30p.tif")

ndvi_bro_30p <- mask(ndvi, mask[[1]])
ndvi_con_30p <- mask(ndvi, mask[[2]])
ndvi_mix_30p <- mask(ndvi, mask[[3]])


ranger = function(x) {
  range <- global(x, "max", na.rm = TRUE) - global(x, "min", na.rm = TRUE)
}



ndvi_bro_30p_range_test <- ranger(ndvi_bro_30p)                                      
