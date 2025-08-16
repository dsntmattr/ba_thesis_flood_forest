# Load packages -----------------------------------------------------------
if (!require("terra", quietly = TRUE)) install.packages("terra")
if (!require("rstac", quietly = TRUE)) install.packages("rstac")
if (!require("sf", quietly = TRUE)) install.packages("sf")
library(terra)
library(rstac)
library(sf)

# Clean Environment and Set Working Directory -----------------------------
rm(list=ls())
graphics.off()
sf <- st_read("data/raw/forest_loss/forest_loss.shp")
# STAC Configuration ------------------------------------------------------
stac_url <- "https://planetarycomputer.microsoft.com/api/stac/v1/"

aoi      <- c(-122.5,46.,-121.9, 46.5)
coi      <- "3dep-seamless"

# Query STAC Items --------------------------------------------------------
stac_items <- stac(stac_url) %>%
  stac_search(collections = coi,bbox = aoi) %>%
  get_request() %>%
  items_sign(sign_fn = sign_planetary_computer())

# Get unique acquisition dates
image_dates <- unique(sapply(stac_items$features, function(x) substr(x$properties$datetime, 1, 10)))
image_dates <- rev(image_dates)
print('Found images for:')
print(image_dates)
selected_date <- image_dates[2] 

# Download and merge DEM tiles --------------------------------------------
dem_list <- list()
for (i in seq_along(stac_items$features)) {
  item_date <- substr(stac_items$features[[i]]$properties$datetime, 1, 10)
  if (item_date == selected_date && stac_items$features[[i]]$properties$gsd == 10) {
    dem_url <- stac_items$features[[i]]$assets$data$href
    dem_tile <- rast(dem_url)
    # Crop to AOI (optional)
    aoi_sf <- st_as_sfc(st_bbox(c(xmin = aoi[1], xmax = aoi[3],
                                  ymin = aoi[2], ymax = aoi[4]),
                                crs = 4326))
    aoi_transformed <- st_transform(aoi_sf, crs(dem_tile))
    dem_list <- append(dem_list, list(dem_tile))
  }
}

# plot(dem_list[[1]])

# Merge tiles if multiple were found
if (length(dem_list) > 1) {
  dem <- do.call(merge, dem_list)
} else {
  dem <- dem_list[[1]]
}

dem <- crop(dem,ext(aoi[1], aoi[3], aoi[2], aoi[4]))

# Plot and save ----------------------------------------------------------
col <- terrain.colors(100)
plot(dem, col = col, main = "Elevation (m)")
# 
# # Save as GeoTIFF
# writeRaster(dem, "data/MtStHelens_postE_DEM.tif", overwrite = TRUE)
