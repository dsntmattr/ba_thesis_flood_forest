# ==============================================================================
# SCRIPT: Create Time Series Visualization Plots
# PURPOSE: Generate standardized time series plots comparing vegetation indices
#          between study period and reference period for local and regional analysis
# AUTHOR: Matthias Lerch
# DATE: [Current Date]
# ==============================================================================

# 00 LOAD REQUIRED PACKAGES -----------------------------------------------
library(tidyverse)   # Data manipulation & plotting

# 01 SET GLOBAL PLOT PARAMETERS -------------------------------------------

# Set default theme for all ggplot2 visualizations
theme_set(theme_linedraw())

# 02 LOAD TIME SERIES DATA ------------------------------------------------

# Load local analysis results (forest loss site level)
load("data/work/dataframes/df_dif_relative_local_long.RData")

# Load regional analysis results (forest type mask level)
load("data/work/dataframes/df_dif_relative_regional_long.RData")

# ==============================================================================
# PART 01: DEFINE VISUALIZATION PARAMETERS
# ==============================================================================

# 03 DEFINE VISUAL ELEMENTS -----------------------------------------------

# Color palette for different vegetation indices (colorblind-friendly)
graph_colors <- c("#0072B2", "#CC79A7", "#009E73", "#F0E442")

# Positions for vertical separation lines between years
sep_lines_pos <- c(5.5, 10.5, 15.5, 20.5)                  # After months 5, 10, 15, 20

# Plot dimensions in centimeters for consistent output
width <- 20                                                 # Plot width in cm
height <- 12                                                # Plot height in cm

# 04 DEFINE PLOT LABELS ----------------------------------------------------

# Standard German labels used across all plots
labs_default <- list(
  subtitle = "Mai – September 2013 – 2017,\nReferenzperiode: 2000 – 2012",
  x = "Monat",                                              # Month
  y = "Abweichung (%) vom Referenzwert",                    # Deviation (%) from reference value
  color = "Index:",                                         # Index legend label
  linetype = "Waldbewuchsart:",                             # Forest type legend label
  caption = "Quelle:\nEVI, NDVI, NIRv: MODIS NBAR Daily\nLAI: MODIS Leaf Area Index/FPAR 8-Day"
)

# 05 DEFINE PLOT THEME -----------------------------------------------------

# Custom theme for consistent plot appearance
plot_theme <- theme_minimal(base_size = 20) +
  theme(
    axis.text.x = element_text(angle = 90, vjust = 0.5, size = 16),  # Rotate x-axis labels
    panel.grid.minor = element_blank(),                     # Remove minor grid lines
    plot.caption = element_text(hjust = 0),                 # Left-align caption
    legend.position = "bottom",                             # Place legend at bottom
    legend.box = "horizontal",                              # Arrange legend items horizontally
    legend.title = element_text(size = 20),                 # Legend title size
    legend.text = element_text(size = 18)                   # Legend text size
  )

# 06 DEFINE LEGEND GUIDES --------------------------------------------------

# Legend appearance settings for better visibility
plot_guides <- guides(
  color = guide_legend(override.aes = list(size = 18)),     # Larger legend points/lines
  linetype = guide_legend(override.aes = list(size = 18))   # Larger legend lines
)

# ==============================================================================
# PART 02: DEFINE PLOTTING FUNCTIONS
# ==============================================================================

# 07 DEFINE BASE PLOT FUNCTION --------------------------------------------

# Base plot function that encapsulates common plot elements
# Parameters:
#   data: Input dataframe for plotting
#   aes_args: Aesthetic mappings for ggplot
# Returns: ggplot object with base layers
base_plot <- function(data, aes_args) {
  ggplot(data, aes_args) +
    geom_line(size = 1.5) +                                 # Main data lines
    geom_hline(yintercept = 0, linetype = "dashed", color = "black") +  # Reference line at zero
    coord_cartesian(ylim = c(-35, 30)) +                    # Set y-axis limits
    scale_y_continuous(breaks = seq(-35, 30, by = 5)) +     # Y-axis tick marks every 5%
    scale_color_manual(values = graph_colors)               # Apply custom color palette
}

# 08 DEFINE SEPARATION LINES FUNCTION -------------------------------------

# Function to add vertical lines marking year boundaries
# Parameters:
#   plot: ggplot object to modify
#   sep_lines_pos: Vector of x-positions for vertical lines
#   ylim: Y-axis limits as vector c(min, max)
# Returns: Modified ggplot object with vertical lines
add_sep_lines <- function(plot, sep_lines_pos, ylim) {
  for (x in sep_lines_pos) {
    plot <- plot + annotate("segment", x = x, xend = x,
                            y = ylim[1], yend = ylim[2],
                            color = "black", linetype = "solid")
  }
  return(plot)
}

# ==============================================================================
# PART 03: DATA PREPARATION
# ==============================================================================

# 09 PREPARE LOCAL DATA FOR PLOTTING --------------------------------------

# Add temporal variables to local analysis dataframe
df_local <- df_dif_rel_loc_long %>%
  mutate(
    year = as.numeric(format(time, "%Y")),                  # Extract year from date
    MonthYear = format(time, "%Y-%m")                       # Create year-month string
  )

# Convert MonthYear to ordered factor for proper chronological plotting
df_local$MonthYear <- factor(df_local$MonthYear, levels = sort(unique(df_local$MonthYear)))

# 10 PREPARE REGIONAL DATA FOR PLOTTING -----------------------------------

# Add temporal variables to regional analysis dataframe
df_regional <- df_dif_rel_reg_long %>%
  mutate(
    year = as.numeric(format(date, "%Y")),                  # Extract year from date
    MonthYear = format(date, "%Y-%m")                       # Create year-month string
  )

# Convert MonthYear to ordered factor for proper chronological plotting
df_regional$MonthYear <- factor(df_regional$MonthYear, levels = sort(unique(df_regional$MonthYear)))

# ==============================================================================
# PART 04: CREATE AND SAVE VISUALIZATION PLOTS
# ==============================================================================

# 11 CREATE LOCAL TIME SERIES PLOT ----------------------------------------

# Generate local analysis plot (forest loss sites)
p_local <- base_plot(
  df_local,
  aes(x = MonthYear, y = value, color = index, group = interaction(index, year))
) +
  labs(title = "Zeitreihe der Indizes am lokalen Standort (Vogelsang)") +  # Local site time series
  do.call(labs, labs_default) +                             # Apply default labels
  plot_theme +                                              # Apply custom theme
  plot_guides                                               # Apply legend guides

# Add year separation lines and save local plot
p_local <- add_sep_lines(p_local, sep_lines_pos, c(-35, 30))

dir_plots <- "output/plots/"
dir.create(dir_plots, recursive = TRUE, showWarnings = FALSE)

ggsave(filename = file.path(dir_plots, "local.png"), plot = p_local, bg = "white", width = width, height = height)

# 12 CREATE REGIONAL OVERVIEW PLOT ----------------------------------------

# Generate regional analysis plot (all forest types and indices)
p_regional <- base_plot(
  df_regional,
  aes(x = MonthYear, y = value, color = Index, linetype = Vegetation, group = interaction(Index, Vegetation, year))
) +
  labs(title = "Vergleich der Indizes für verschiedene Waldbewuchsarten") +  # Comparison of indices for different forest types
  do.call(labs, labs_default) +                             # Apply default labels
  plot_theme +                                              # Apply custom theme
  plot_guides                                               # Apply legend guides

# Add year separation lines and save regional overview plot
p_regional <- add_sep_lines(p_regional, sep_lines_pos, c(-35, 30))

dir_plots <- "output/plots/"
dir.create(dir_plots, recursive = TRUE, showWarnings = FALSE)

ggsave(filename = file.path(dir_plots, "regional.png"), plot = p_regional, bg = "white", width = width, height = height)

# 13 CREATE INDEX-SPECIFIC PLOTS ------------------------------------------

# Define vegetation indices to create individual plots for
indices_to_plot <- c("NDVI", "EVI", "NIRv", "LAI")

# Create separate plot for each vegetation index
plots_list <- lapply(indices_to_plot, function(index_name) {
  # Filter data for current index only
  df_filtered <- filter(df_regional, Index == index_name)
  
  # Create plot for specific index comparing forest types
  p <- base_plot(
    df_filtered,
    aes(x = MonthYear, y = value, linetype = Vegetation, group = interaction(Vegetation, year))
  ) +
    labs(title = paste("Vergleich des Index", index_name, "für Waldbewuchsarten")) +  # Index comparison for forest types
    do.call(labs, labs_default) +                           # Apply default labels
    plot_theme +                                            # Apply custom theme
    plot_guides                                             # Apply legend guides
  
  # Add year separation lines
  add_sep_lines(p, sep_lines_pos, c(-35, 30))
})

# Assign names to plots list for easier access
names(plots_list) <- indices_to_plot

# 14 SAVE INDEX-SPECIFIC PLOTS --------------------------------------------

# Save individual plots for each vegetation index

dir_plots <- "output/plots/"
dir.create(dir_plots, recursive = TRUE, showWarnings = FALSE)

ggsave(filename = file.path(dir_plots, "regional_ndvi.png"), plot = plots_list[["NDVI"]], bg = "white", width = width, height = height)
ggsave(filename = file.path(dir_plots, "regional_evi.png"),  plot = plots_list[["EVI"]],  bg = "white", width = width, height = height)
ggsave(filename = file.path(dir_plots, "regional_lai.png"),  plot = plots_list[["LAI"]],  bg = "white", width = width, height = height)
ggsave(filename = file.path(dir_plots, "regional_nirv.png"), plot = plots_list[["NIRv"]], bg = "white", width = width, height = height)

# 15 CREATE FOREST TYPE-SPECIFIC PLOTS ------------------------------------

# Create plots grouped by forest vegetation type (broadleaf vs coniferous)
plots_by_vegetation <- df_regional %>%
  group_split(Vegetation) %>%                               # Split data by vegetation type
  lapply(function(df) {
    # Create plot for specific forest type comparing all indices
    p <- base_plot(
      df,
      aes(x = MonthYear, y = value, color = Index, group = interaction(Index, year))
    ) +
      labs(title = paste("Vergleich der Indizes für Waldbewuchsart:", unique(df$Vegetation))) +  # Index comparison for forest type
      do.call(labs, labs_default) +                         # Apply default labels
      plot_theme +                                          # Apply custom theme
      plot_guides                                           # Apply legend guides
    
    # Add year separation lines
    add_sep_lines(p, sep_lines_pos, c(-35, 30))
  })

# 16 SAVE FOREST TYPE-SPECIFIC PLOTS --------------------------------------

# Save plots for each forest vegetation type

dir_plots <- "output/plots/"
dir.create(dir_plots, recursive = TRUE, showWarnings = FALSE)

ggsave(filename = file.path(dir_plots, "regional_broad.png"),   plot = plots_by_vegetation[[1]], bg = "white", width = width, height = height)  # Broadleaf forests
ggsave(filename = file.path(dir_plots, "regional_conifer.png"), plot = plots_by_vegetation[[2]], bg = "white", width = width, height = height)  # Coniferous forests