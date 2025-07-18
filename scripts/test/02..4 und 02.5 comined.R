# Script to mask, calc the means and harmonise them in one script

# Packages ---------------------------------------------------------
# Spatial data
library(terra) # raster
library(gdalcubes)
# Data manipulation and more.
library(magrittr) # pipe operator %>%
library(dplyr)

#  Masking ----------------------------------------------------------------

# Load the masks

path <- list.files("data/work/mask/", pattern = "p.tif", full.names = TRUE)

list_mask <- lapply(path, rast)

# mask_list = list of masks
# each mask = 3 layers (broad, conifer, mixed)

# Reference  ----------------------------------------------------------------

# Loading the indices.
ndvi <- rast(list.files(path = "data/work/reference/indices", pattern = "NDVI", full.names = TRUE)) 
evi <- rast(list.files(path = "data/work/reference/indices", pattern = "EVI", full.names = TRUE))
nirv <- rast(list.files(path = "data/work/reference/indices", pattern = "NIRv", full.names = TRUE))

masker <- function (r, m) {
  x <- r * m[[1]]
  y <- r * m[[2]]
  z <- r * m[[3]]
  all <- c(x, y, z)
  return(all)
}

index <- ndvi

ndvi_30p <- masker(index, list_mask[[1]])
ndvi_50p <- masker(index, list_mask[[2]])
ndvi_66p <- masker(index, list_mask[[3]])
ndvi_70p <- masker(index, list_mask[[4]])
ndvi_90p <- masker(index, list_mask[[5]])
ndvi_99p <- masker(index, list_mask[[6]])

index = evi

evi_30p <- masker(index, list_mask[[1]])
evi_50p <- masker(index, list_mask[[2]])
evi_66p <- masker(index, list_mask[[3]])
evi_70p <- masker(index, list_mask[[4]])
evi_90p <- masker(index, list_mask[[5]])
evi_99p <- masker(index, list_mask[[6]])

index = nirv

nirv_30p <- masker(index, list_mask[[1]])
nirv_50p <- masker(index, list_mask[[2]])
nirv_66p <- masker(index, list_mask[[3]])
nirv_70p <- masker(index, list_mask[[4]])
nirv_90p <- masker(index, list_mask[[5]])
nirv_99p <- masker(index, list_mask[[6]])










