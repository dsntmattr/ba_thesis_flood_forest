# 00 Packages ---------------------------------------------------------
library(sf) # for vector data
library(tidyverse) # for tables and other stuff
library(terra) # for raster data
library(magrittr) # for %>%

# Load data. --------------------------------------------------------------
#  coverage layers.
coverage <- rast("data/work/coverage.tif")

# Load mask layer.
paths <- list.files(path = "data/work", pattern = "mask" , full.names = TRUE)
masks <- lapply(paths, rast)

# Mask coverage by masks  ---------------------------------------------------------
cov_bro_30p <- mask(coverage[[1]], masks[[1]][[1]])
cov_bro_50p <- mask(coverage[[1]], masks[[2]][[1]])
cov_bro_66p <- mask(coverage[[1]], masks[[3]][[1]])
cov_bro_70p <- mask(coverage[[1]], masks[[4]][[1]])
cov_bro_90p <- mask(coverage[[1]], masks[[5]][[1]])
cov_bro_99p <- mask(coverage[[1]], masks[[6]][[1]])

cov_con_30p <- mask(coverage[[2]], masks[[1]][[2]])
cov_con_50p <- mask(coverage[[2]], masks[[2]][[2]])
cov_con_66p <- mask(coverage[[2]], masks[[3]][[2]])
cov_con_70p <- mask(coverage[[2]], masks[[4]][[2]])
cov_con_90p <- mask(coverage[[2]], masks[[5]][[2]])
cov_con_99p <- mask(coverage[[2]], masks[[6]][[2]])

cov_mix_30p <- mask(coverage[[3]], masks[[1]][[3]])
cov_mix_50p <- mask(coverage[[3]], masks[[2]][[3]])
cov_mix_66p <- mask(coverage[[3]], masks[[3]][[3]])
cov_mix_70p <- mask(coverage[[3]], masks[[4]][[3]])
cov_mix_90p <- mask(coverage[[3]], masks[[5]][[3]])
cov_mix_99p <- mask(coverage[[3]], masks[[6]][[3]])

# Summarise values. -------------------------------------------------------
cov_bro_sum     <- global(coverage[[1]], "sum", na.rm=TRUE)
cov_bro_30p_sum <- global(cov_bro_30p, "sum", na.rm=TRUE)
cov_bro_50p_sum <- global(cov_bro_50p, "sum", na.rm=TRUE)
cov_bro_66p_sum <- global(cov_bro_66p, "sum", na.rm=TRUE)
cov_bro_70p_sum <- global(cov_bro_70p, "sum", na.rm=TRUE)
cov_bro_90p_sum <- global(cov_bro_90p, "sum", na.rm=TRUE)
cov_bro_99p_sum <- global(cov_bro_99p, "sum", na.rm=TRUE)

cov_con_sum     <- global(coverage[[2]], "sum", na.rm=TRUE)
cov_con_30p_sum <- global(cov_con_30p, "sum", na.rm=TRUE)
cov_con_50p_sum <- global(cov_con_50p, "sum", na.rm=TRUE)
cov_con_66p_sum <- global(cov_con_66p, "sum", na.rm=TRUE)
cov_con_70p_sum <- global(cov_con_70p, "sum", na.rm=TRUE)
cov_con_90p_sum <- global(cov_con_90p, "sum", na.rm=TRUE)
cov_con_99p_sum <- global(cov_con_99p, "sum", na.rm=TRUE)

cov_mix_sum     <- global(coverage[[3]], "sum", na.rm=TRUE)
cov_mix_30p_sum <- global(cov_mix_30p, "sum", na.rm=TRUE)
cov_mix_50p_sum <- global(cov_mix_50p, "sum", na.rm=TRUE)
cov_mix_66p_sum <- global(cov_mix_66p, "sum", na.rm=TRUE)
cov_mix_70p_sum <- global(cov_mix_70p, "sum", na.rm=TRUE)
cov_mix_90p_sum <- global(cov_mix_90p, "sum", na.rm=TRUE)
cov_mix_99p_sum <- global(cov_mix_99p, "sum", na.rm=TRUE)

# Areas in Hectares.   ---------------------------------------------------------
df_bro <- bind_rows(cov_bro_sum, cov_bro_30p_sum, cov_bro_50p_sum, cov_bro_66p_sum, cov_bro_70p_sum, cov_bro_90p_sum, cov_bro_99p_sum)
df_con <- bind_rows(cov_con_sum, cov_con_30p_sum, cov_con_50p_sum, cov_con_66p_sum, cov_con_70p_sum, cov_con_90p_sum, cov_con_99p_sum)
df_mix <- bind_rows(cov_mix_sum, cov_mix_30p_sum, cov_mix_50p_sum, cov_mix_66p_sum, cov_mix_70p_sum, cov_mix_90p_sum, cov_mix_99p_sum)

df <- bind_cols(df_bro, df_con, df_mix)

# Convert the values to hectar.
# The cell values of the coverage layer indicates the coverage of each cell by forest
# One cell = 500 * 500 meter = 25 Hectar
# So e.g. one cell covered by 50 percent forest has 12.5 ha forest, cell value would be 0.5; 25 * 0,5 = 12.5
df <- df * 25

row.names(df) <- c("Total", "30%", "50%", "66%", "70%", "90%", "99%")
colnames(df) <- c("Broad (ha)", "Conifer (ha)", "Mixed (ha)")

df <- round(df)


# Areas in percent. -------------------------------------------------------
df_bro_perc <- data.frame(df$Broad/df$Broad[[1]]*100)
df_con_perc <- data.frame(df$Conifer/df$Conifer[[1]]*100)
df_mix_perc <- data.frame(df$Mixed/df$Mixed[[1]]*100)

df_perc <- bind_cols(df_bro_perc, df_con_perc, df_mix_perc)

row.names(df_perc) <- c("Total", "30%", "50%", "66%", "70%", "90%", "99%")
colnames(df_perc) <- c("Broad (%)", "Conifer (%)", "Mixed (%)")

df_perc <- round(df_perc)

# Number of cells. --------------------------------------------------------
cells_coverage_bro <- sum(!is.na(values(coverage[[1]])))
cells_coverage_con <- sum(!is.na(values(coverage[[2]])))
cells_coverage_mix <- sum(!is.na(values(coverage[[3]])))

cells_mask_bro_30p <- sum(!is.na(values(masks[[1]][[1]])))
cells_mask_bro_50p <- sum(!is.na(values(masks[[2]][[1]])))
cells_mask_bro_66p <- sum(!is.na(values(masks[[3]][[1]])))
cells_mask_bro_70p <- sum(!is.na(values(masks[[4]][[1]])))
cells_mask_bro_90p <- sum(!is.na(values(masks[[5]][[1]])))
cells_mask_bro_99p <- sum(!is.na(values(masks[[6]][[1]])))

cells_mask_con_30p <- sum(!is.na(values(masks[[1]][[2]])))
cells_mask_con_50p <- sum(!is.na(values(masks[[2]][[2]])))
cells_mask_con_66p <- sum(!is.na(values(masks[[3]][[2]])))
cells_mask_con_70p <- sum(!is.na(values(masks[[4]][[2]])))
cells_mask_con_90p <- sum(!is.na(values(masks[[5]][[2]])))
cells_mask_con_99p <- sum(!is.na(values(masks[[6]][[2]])))

cells_mask_mix_30p <- sum(!is.na(values(masks[[1]][[3]])))
cells_mask_mix_50p <- sum(!is.na(values(masks[[2]][[3]])))
cells_mask_mix_66p <- sum(!is.na(values(masks[[3]][[3]])))
cells_mask_mix_70p <- sum(!is.na(values(masks[[4]][[3]])))
cells_mask_mix_90p <- sum(!is.na(values(masks[[5]][[3]])))
cells_mask_mix_99p <- sum(!is.na(values(masks[[6]][[3]])))

vec_bro_cells <- c(cells_coverage_bro, cells_mask_bro_30p, cells_mask_bro_50p, cells_mask_bro_66p, cells_mask_bro_70p, cells_mask_bro_90p, cells_mask_bro_99p)
vec_con_cells <- c(cells_coverage_con, cells_mask_con_30p, cells_mask_con_50p, cells_mask_con_66p, cells_mask_con_70p, cells_mask_con_90p, cells_mask_con_99p)
vec_mix_cells <- c(cells_coverage_mix, cells_mask_mix_30p, cells_mask_mix_50p, cells_mask_mix_66p, cells_mask_mix_70p, cells_mask_mix_90p, cells_mask_mix_99p)

df <- data.frame(vec_bro_cells, vec_con_cells, vec_mix_cells)

row.names(df) <- c("Total", "30%", "50%", "66%", "70%", "90%", "99%")
colnames(df) <- c("Broad (ncells)", "Conifer (ncells)", "Mixed (ncells)")

# Percentage of cells.  --------------------------------------------------------
df_bro_ncells_perc <- data.frame(df[1]/df[[1]][1]*100)
df_con_ncells_perc <- data.frame(df[2]/df[[2]][1]*100)
df_mix_ncells_perc <- data.frame(df[3]/df[[3]][1]*100)

df_perc <- bind_cols(df_bro_ncells_perc, df_con_ncells_perc, df_mix_ncells_perc)

row.names(df_perc) <- c("Total", "30%", "50%", "66%", "70%", "90%", "99%")
colnames(df_perc) <- c("Broad (ncells%)", "Conifer (ncells%)", "Mixed (ncells%)")

df_perc <- round(df_perc, digits = 1)
