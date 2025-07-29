# Script to plot the timeseries results with vertical year-separating lines.
# Packages. ---------------------------------------------------------------
library(ggplot2)
library(lubridate)
library(dplyr)
theme_set(theme_linedraw())

# Load dataframes. --------------------------------------------------------
load("data/work/dataframes/df_dif_relative_local_long.RData")
load("data/work/dataframes/df_dif_relative_regional_long.RData")

# Define base plot function. ----------------------------------------------

base_plot <- function(data, aes_args) {
  ggplot(data, aes_args) +
    geom_line(size = 1.5) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "black") +
    coord_cartesian(ylim = c(-35, 30)) +
    scale_y_continuous(breaks = seq(ylim[1], ylim[2], by = 5)) +
    scale_color_manual(values = graph_colors)
}
# Define seperation lines.  ---------------------------------------------

sep_lines_pos <- c(5.5, 10.5, 15.5, 20.5)

add_sep_lines <- function(plot, sep_lines_pos, ylim) {
  for (x in sep_lines_pos) {
    plot <- plot + annotate("segment", x = x, xend = x,
                            y = ylim[1], yend = ylim[2],
                            color = "black", linetype = "solid")
  }
  return(plot)
}

# Define default lab elements ---------------------------------------------

labs_default <- list(
  subtitle = "Mai–September 2013–2017,\nReferenzperiode EVI, NDVI, NIRv: 2000 - 2012\nReferenzperiode LAI: 2003 - 2012",
  x = "Monat",
  y = "Abweichung in % von Referenzwert",
  color = "Index:",
  linetype = "Waldtyp:",
  caption = "Quelle:\nEVI, NDVI, NIRv: MODIS NBAR Daily\nLAI: MODIS Leaf Area Index/FPAR 8-Day"
)

# Define graph colors. ----------------------------------------------------

graph_colors <- c(
  "#0072B2", "#CC79A7", "#009E73", "#F0E442"
)

# Define plot theme.  ---------------------------------------------

plot_theme <- theme_minimal(base_size = 20) +
  theme(
    axis.text.x = element_text(angle = 90, vjust = 0.5, size = 16),
    panel.grid.minor = element_blank(),
    plot.caption = element_text(hjust = 0),
    legend.position = "bottom",
    legend.box = "horizontal",
    legend.title = element_text(size = 20),
    legend.text = element_text(size = 18)
  )

plot_guides <- guides(
  color = guide_legend(override.aes = list(size = 18)),
  linetype = guide_legend(override.aes = list(size = 18))
)

# Define plot size. -------------------------------------------------------

width <- 20
height <- 12

# Local. ------------------------------------------------------------------

df_local <- df_dif_rel_loc_long %>%
  mutate(
    year = as.numeric(format(time, "%Y")),
    MonthYear = format(time, "%Y-%m")
  )
df_local$MonthYear <- factor(df_local$MonthYear, levels = sort(unique(df_local$MonthYear)))

p_local <- base_plot(
  df_local,
  aes(x = MonthYear, y = value, color = index, group = interaction(index, year))
) +
  labs(title = "Zeitverlauf Indizes Lokal (Vogelsang)") +
  do.call(labs, labs_default) +
  plot_theme +
  plot_guides

p_local <- add_sep_lines(p_local, sep_lines_pos, ylim)
ggsave("output/local.png", plot = p_local, bg = "white", width = width, height = height)

# Regional - Gesamt. ------------------------------------------------------
df_regional <- df_dif_rel_reg_long %>%
  mutate(
    year = as.numeric(format(date, "%Y")),
    MonthYear = format(date, "%Y-%m")
  )
df_regional$MonthYear <- factor(df_regional$MonthYear, levels = sort(unique(df_regional$MonthYear)))

p_regional <- base_plot(
  df_regional,
  aes(x = MonthYear, y = value, color = Index, linetype = Vegetation, group = interaction(Index, Vegetation, year))
) +
  labs(title = "Vergleich der Indizes für verschiedene Waldtypen") +
  do.call(labs, labs_default) +
  plot_theme +
  plot_guides

p_regional <- add_sep_lines(p_regional, sep_lines_pos, ylim)
ggsave("output/regional.png", plot = p_regional, bg = "white", width = width, height = height)

# Index-spezifische Plots -------------------------------------------------
indices_to_plot <- c("NDVI", "EVI", "NIRv", "LAI")

plots_list <- lapply(indices_to_plot, function(index_name) {
  df_filtered <- filter(df_regional, Index == index_name)
  
  p <- base_plot(
    df_filtered,
    aes(x = MonthYear, y = value, color = Vegetation, group = interaction(Vegetation, year))
  ) +
    labs(title = paste("Vergleich von", index_name, "bei allen Waldtypen")) +
    do.call(labs, labs_default) +
    plot_theme +
    plot_guides
  add_sep_lines(p, sep_lines_pos, ylim)
})

names(plots_list) <- indices_to_plot

# Speichern
ggsave("output/regional_ndvi.png", plot = plots_list[["NDVI"]], bg = "white", width = width, height = height)
ggsave("output/regional_evi.png",  plot = plots_list[["EVI"]],  bg = "white", width = width, height = height)
ggsave("output/regional_lai.png",  plot = plots_list[["LAI"]],  bg = "white", width = width, height = height)
ggsave("output/regional_nirv.png", plot = plots_list[["NIRv"]], bg = "white", width = width, height = height)

# Waldtyp-Plots -----------------------------------------------------------
plots_by_vegetation <- df_regional %>%
  group_split(Vegetation) %>%
  lapply(function(df) {
    
    p <- base_plot(
      df,
      aes(x = MonthYear, y = value, color = Index, group = interaction(Index, year))
    ) +
      labs(title = paste("Vergleich der Indizes für Waldtyp:", unique(df$Vegetation))) +
      do.call(labs, labs_default) +
      plot_theme +
      plot_guides
    add_sep_lines(p, sep_lines_pos, ylim)
  })

# Speichern
ggsave("output/regional_broad.png",   plot = plots_by_vegetation[[1]], bg = "white", width = width, height = height)
ggsave("output/regional_conifer.png", plot = plots_by_vegetation[[2]], bg = "white", width = width, height = height)
