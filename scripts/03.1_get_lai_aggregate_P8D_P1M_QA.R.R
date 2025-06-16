# load LAI 500m 8-day product data from catalog,
# get cubes with one picture for 8 days,
# mask the scenes using the quality bands,
# rescaling the cell values by multiply factor 0.1
# and get cubes with 1 picture for 1 month.
# Packages ---------------------------------------------------------
# Spatial data
library(gdalcubes)   # raster cubes
library(sf)          # vector
# Access to STAC-catalouges
library(rstac)       
# Data manipulation and more.
library(magrittr)