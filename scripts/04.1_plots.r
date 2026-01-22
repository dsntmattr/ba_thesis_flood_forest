# ==============================================================================
# SCRIPT: Create Time Series Visualization Plots (A5 landscape PDF export)
# AUTHOR: Matthias Lerch
# ==============================================================================

# 00 LOAD REQUIRED PACKAGES -----------------------------------------------
library(tidyverse)

# 01 SET GLOBAL PLOT PARAMETERS -------------------------------------------
theme_set(theme_linedraw())

# 02 LOAD TIME SERIES DATA ------------------------------------------------
load("data/work/dataframes/df_dif_relative_local_long.RData")
load("data/work/dataframes/df_dif_relative_regional_long.RData")

# ==============================================================================
# PART 01: DEFINE VISUALIZATION PARAMETERS
# ==============================================================================

# 03 DEFINE VISUAL ELEMENTS -----------------------------------------------
graph_colors <- c("#0072B2", "#CC79A7", "#009E73", "#F0E442")
sep_lines_pos <- c(5.5, 10.5, 15.5, 20.5)

# --- A5 LANDSCAPE OUTPUT SETTINGS ----------------------------------------
a5_w <- 21
a5_h <- 14.8
a5_u <- "cm"

# Helper: always save as A5 landscape PDF with embedded fonts
save_a5_pdf <- function(plot, filename, dir_plots = "output/plots/") {
  dir.create(dir_plots, recursive = TRUE, showWarnings = FALSE)
  ggsave(
    filename = file.path(dir_plots, paste0(filename, ".pdf")),
    plot = plot,
    device = cairo_pdf,
    width = a5_w,
    height = a5_h,
    units = a5_u,
    bg = "white"
  )
}

# 04 DEFINE PLOT LABELS ----------------------------------------------------
labs_default <- list(
  x = "Monat",
  y = "Abweichung (%) vom Referenzwert",
  color = "Index:",
  linetype = "Waldtyp:"
)

# 05 DEFINE PLOT THEME (OPTIMISED FOR A5) ----------------------------------
plot_theme <- theme_minimal(base_size = 12) +
  theme(
    axis.title.x = element_text(size = 12),
    axis.title.y = element_text(size = 12),
    axis.text.x  = element_text(angle = 90, vjust = 0.5, size = 9),
    axis.text.y  = element_text(size = 10),
    
    panel.grid.minor = element_blank(),
    
    legend.position = "bottom",
    legend.box = "horizontal",
    legend.title = element_text(size = 11),
    legend.text  = element_text(size = 11),
    
    plot.margin = margin(t = 6, r = 6, b = 4, l = 6, unit = "mm")
  )

# 06 DEFINE LEGEND GUIDES --------------------------------------------------
plot_guides <- guides(
  color    = guide_legend(override.aes = list(linewidth = 0.9)),
  linetype = guide_legend(override.aes = list(linewidth = 0.9))
)

# ==============================================================================
# PART 02: DEFINE PLOTTING FUNCTIONS
# ==============================================================================

base_plot <- function(data, aes_args) {
  ggplot(data, aes_args) +
    geom_line(linewidth = 0.7) +                            # <- DRUCKTAUGLICH
    geom_hline(yintercept = 0, linetype = "dashed",
               color = "black", linewidth = 0.5) +
    coord_cartesian(ylim = c(-35, 30)) +
    scale_y_continuous(breaks = seq(-35, 30, by = 5)) +
    scale_color_manual(values = graph_colors)
}

add_sep_lines <- function(plot, sep_lines_pos, ylim) {
  for (x in sep_lines_pos) {
    plot <- plot +
      annotate(
        "segment",
        x = x, xend = x,
        y = ylim[1], yend = ylim[2],
        color = "black",
        linewidth = 0.5
      )
  }
  plot
}

# ==============================================================================
# PART 03: DATA PREPARATION
# ==============================================================================

df_local <- df_dif_rel_loc_long %>%
  mutate(
    year = as.numeric(format(time, "%Y")),
    MonthYear = format(time, "%Y-%m")
  )
df_local$MonthYear <- factor(df_local$MonthYear, levels = sort(unique(df_local$MonthYear)))

df_regional <- df_dif_rel_reg_long %>%
  mutate(
    year = as.numeric(format(date, "%Y")),
    MonthYear = format(date, "%Y-%m")
  )
df_regional$MonthYear <- factor(df_regional$MonthYear, levels = sort(unique(df_regional$MonthYear)))

# ==============================================================================
# PART 04: CREATE AND SAVE VISUALIZATION PLOTS (A5 landscape PDFs)
# ==============================================================================

# 11 LOCAL TIME SERIES PLOT ------------------------------------------------
p_local <- base_plot(
  df_local,
  aes(x = MonthYear, y = value, color = index, group = interaction(index, year))
) +
  do.call(labs, labs_default) +
  plot_theme +
  plot_guides

p_local <- add_sep_lines(p_local, sep_lines_pos, c(-35, 30))
save_a5_pdf(p_local, "plot_local_all")

# 12 REGIONAL OVERVIEW PLOT ------------------------------------------------
p_regional <- base_plot(
  df_regional,
  aes(x = MonthYear, y = value, color = Index, linetype = Vegetation,
      group = interaction(Index, Vegetation, year))
) +
  do.call(labs, labs_default) +
  plot_theme +
  plot_guides

p_regional <- add_sep_lines(p_regional, sep_lines_pos, c(-35, 30))
save_a5_pdf(p_regional, "plot_regional_all")

# 13 INDEX-SPECIFIC PLOTS --------------------------------------------------
indices_to_plot <- c("NDVI", "EVI", "NIRv", "LAI")

plots_list <- lapply(indices_to_plot, function(index_name) {
  df_filtered <- filter(df_regional, Index == index_name)
  
  p <- ggplot(
    df_filtered,
    aes(x = MonthYear, y = value, linetype = Vegetation,
        group = interaction(Vegetation, year))
  ) +
    geom_line(linewidth = 0.7) +
    geom_hline(yintercept = 0, linetype = "dashed",
               color = "black", linewidth = 0.5) +
    coord_cartesian(ylim = c(-35, 30)) +
    scale_y_continuous(breaks = seq(-35, 30, by = 5)) +
    do.call(labs, labs_default) +
    plot_theme +
    plot_guides
  
  add_sep_lines(p, sep_lines_pos, c(-35, 30))
})

names(plots_list) <- indices_to_plot

save_a5_pdf(plots_list[["NDVI"]], "plot_regional_ndvi")
save_a5_pdf(plots_list[["EVI"]],  "plot_regional_evi")
save_a5_pdf(plots_list[["LAI"]],  "plot_regional_lai")
save_a5_pdf(plots_list[["NIRv"]], "plot_regional_nirv")

# 15 FOREST TYPE-SPECIFIC PLOTS -------------------------------------------
plots_by_vegetation <- df_regional %>%
  group_split(Vegetation) %>%
  lapply(function(df) {
    p <- base_plot(
      df,
      aes(x = MonthYear, y = value, color = Index,
          group = interaction(Index, year))
    ) +
      do.call(labs, labs_default) +
      plot_theme +
      plot_guides
    
    add_sep_lines(p, sep_lines_pos, c(-35, 30))
  })

save_a5_pdf(plots_by_vegetation[[1]], "plot_regional_broad")
save_a5_pdf(plots_by_vegetation[[2]], "plot_regional_conifer")
