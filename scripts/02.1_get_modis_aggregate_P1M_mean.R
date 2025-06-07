# Getting the raw MODIS scenes for our study area, aggregated to one picture for each month.

# Packages ---------------------------------------------------------
# Spatial data
library(gdalcubes)   # raster cubes
library(sf)          # vector
# Access to STAC-catalouges
library(rstac)       
# Data manipulation and more.
library(magrittr)


# Load function and set variables. ----------------------------------------

source ("scripts/FUN_get_data.R")

# Variables.
load("data/work/bbox.vector.RData")    
aoi  <- bbox.vector               
coll <- "modis-43A4-061"
bds  <- c("Nadir_Reflectance_Band1","Nadir_Reflectance_Band2", "Nadir_Reflectance_Band3")
dt   <- "P1M"
pre  <- 'MODIS_'


# Get the data. -----------------------------------------------------------
# Load the data for each TOI,
# aggregate the scenes to one picture for each month
# and calculate the mean value.


# Reference period. -------------------------------------------------------

out  <- "data/work/reference/P1M/"

get_data(aoi, toi = "2000-05-01/2000-09-30", coll, bds, dt, out, pre)
get_data(aoi, toi = "2001-05-01/2001-09-30", coll, bds, dt, out, pre)
get_data(aoi, toi = "2002-05-01/2002-09-30", coll, bds, dt, out, pre)
get_data(aoi, toi = "2003-05-01/2003-09-30", coll, bds, dt, out, pre)
get_data(aoi, toi = "2004-05-01/2004-09-30", coll, bds, dt, out, pre)
get_data(aoi, toi = "2005-05-01/2005-09-30", coll, bds, dt, out, pre)
get_data(aoi, toi = "2006-05-01/2006-09-30", coll, bds, dt, out, pre)
get_data(aoi, toi = "2007-05-01/2007-09-30", coll, bds, dt, out, pre)
get_data(aoi, toi = "2008-05-01/2008-09-30", coll, bds, dt, out, pre)
get_data(aoi, toi = "2009-05-01/2009-09-30", coll, bds, dt, out, pre)
get_data(aoi, toi = "2010-05-01/2010-09-30", coll, bds, dt, out, pre)
get_data(aoi, toi = "2011-05-01/2011-09-30", coll, bds, dt, out, pre)
get_data(aoi, toi = "2012-05-01/2012-09-30", coll, bds, dt, out, pre)

# Study period. -----------------------------------------------------------

out  <- "data/work/study/P1M/"

get_data(aoi, toi = "2013-05-01/2013-09-30", coll, bds, dt, out, pre)
get_data(aoi, toi = "2014-05-01/2014-09-30", coll, bds, dt, out, pre)
get_data(aoi, toi = "2015-05-01/2015-09-30", coll, bds, dt, out, pre)
get_data(aoi, toi = "2016-05-01/2016-09-30", coll, bds, dt, out, pre)
get_data(aoi, toi = "2017-05-01/2017-09-30", coll, bds, dt, out, pre)

