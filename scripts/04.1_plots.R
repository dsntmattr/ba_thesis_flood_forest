# Script to plot the timeseries results.
# Packages. ---------------------------------------------------------------
library(ggplot2)
library(lubridate)
library(dplyr)
theme_set(theme_linedraw())

# Load dataframes. --------------------------------------------------------
load("data/work/dataframes/df_dif_relative_local_long.RData")
load("data/work/dataframes/df_dif_relative_regional_long.RData")

# Define plot properties. -----------------------------------------
size <- 0.5   # Line size.
ylim <- c(-35, 30) # Dimension of y axis.
width <- 20
height  <- 12
base_font_size <- 24


# Local.  --------------------------------------------------------------
df <- df_dif_rel_loc_long

df_grouped <- df %>%
  mutate(
    year = as.numeric(format(time, "%Y"))
  )

df_grouped$MonthYear <- format(df_grouped$time, "%Y-%m")

plot <- ggplot(df_grouped, aes(
  x = MonthYear,
  y = value,
  color = index,
  #linetype = index,
  group = interaction(index, year)
)) +
  geom_line(size = size) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "black") +
  coord_cartesian(ylim = ylim) + 
  scale_y_continuous(breaks = seq(-35, 30, by = 5)) +
  labs(
    title = "Zeitverlauf Indizes Lokal (Vogelsang)",
    subtitle = "Mai–September 2013–2017,
    Referenzperiode Vegetationsindizes: 2000 - 2012
    Referenzperiode Blattflächenindex: 2003 - 2012",
    x = "Monat",
    y = "Abweichung in %",
    color = "Index",
    #linetype = "Index",
    caption = "Quelle: MODIS NBAR Daily"
  ) +
  theme_minimal(base_size = base_font_size) +
  theme(
    axis.text.x = element_text(angle = 90, vjust = 0.5, size = 7),
    panel.grid.minor = element_blank()
  )

plot

ggsave("data/final/plots/local.png", plot = plot, bg = "white", width = width, height   = height )

# Regional. -------------------------------------------------------
# Compare indices for each forest type ------------------------------------
df <- df_dif_rel_reg_long

# Group df
df_grouped <- df %>%
  mutate(
    year = as.numeric(format(date, "%Y"))
  )

df_grouped$MonthYear <- format(df_grouped$date, "%Y-%m")

# Specify the plot

df_grouped %>%
  group_by(Vegetation) %>%
  do(
    p = ggplot(data = ., aes(
      x = MonthYear,
      y = value,
      color = Index,
      #linetype = Index,
      group = interaction(Index, year)
    )) +
      geom_line(size = size) +
      geom_hline(yintercept = 0, linetype = "dashed", color = "black") +
       coord_cartesian(ylim = ylim)+ 
      scale_y_continuous(breaks = seq(-35, 30, by = 5)) +
      labs(
        title = paste("Vergleich der Indizes für Waldtyp:", unique(.$Vegetation)),
        subtitle = "Mai–September 2013–2017,
    Referenzperiode Vegetationsindizes: 2000 - 2012
    Referenzperiode Blattflächenindex: 2003 - 2012",
        x = "Monat",
        y = "Abweichung in %",
        color = "Index",
        #linetype = "Index",
        caption = "Quelle: MODIS NBAR Daily"
      ) +
      theme_minimal(base_size = base_font_size) +
      theme(
        axis.text.x = element_text(angle = 90, vjust = 0.5, size = 7),
        panel.grid.minor = element_blank()
      )
  ) -> plots_by_vegetation

# plots_by_vegetation$p enthält dann eine Liste mit Plots, z.B.:
plots_by_vegetation$p[[1]]  # erster Waldtyp
plots_by_vegetation$p[[2]]  # zweiter Waldtyp


ggsave("data/final/plots/regional_broad.png",   plot = plots_by_vegetation$p[[1]], bg = "white", width = width, height = height)
ggsave("data/final/plots/regional_conifer.png", plot = plots_by_vegetation$p[[2]], bg = "white", width = width, height = height)

# Compare one index for all forest type -----------------------------------
indices_to_plot <- c("NDVI", "EVI", "NIRv", "LAI")

plots_list <- lapply(indices_to_plot, function(index_to_plot) {
  df_filtered <- df_grouped %>%
    filter(Index == index_to_plot)
  
  ggplot(df_filtered, aes(
    x = MonthYear,
    y = value,
    color = Vegetation,
    group = interaction(Vegetation, year)
  )) +
    geom_line(size = size) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "black") +
     coord_cartesian(ylim = ylim)+ 
    scale_y_continuous(breaks = seq(-35, 30, by = 5)) +
    labs(
      title = paste("Vergleich von", index_to_plot, "bei allen Waldtypen"),
      subtitle = "Mai–September 2013–2017,\nReferenzperiode Vegetationsindizes: 2000–2012\nReferenzperiode Blattflächenindex: 2003–2012",
      x = "Monat",
      y = "Abweichung in %",
      color = "Waldtyp",
      caption = "Quelle: MODIS NBAR Daily"
    ) +
    theme_minimal(base_size = base_font_size) +
    theme(
      axis.text.x = element_text(angle = 90, vjust = 0.5, size = 7),
      panel.grid.minor = element_blank()
    )
})

# Optional: Namen für Liste vergeben
names(plots_list) <- indices_to_plot

# Zugriff z.B. auf NIRv-Plot:
plots_list[["NDVI"]]
plots_list[["EVI"]]
plots_list[["LAI"]]
plots_list[["NIRv"]]

ggsave("data/final/plots/regional_ndvi.png", plot = plots_list[["NDVI"]], bg = "white", width = width, height  = height )
ggsave("data/final/plots/regional_evi.png", plot = plots_list[["EVI"]], bg = "white", width = width, height  = height )
ggsave("data/final/plots/regional_lai.png", plot = plots_list[["LAI"]], bg = "white", width = width, height  = height )
ggsave("data/final/plots/regional_nirv.png", plot = plots_list[["NIRv"]], bg = "white", width = width, height  = height )

# Plot all indices and all forest types in one plot  -----------------------------------
df_grouped <- df_dif_rel_reg_long %>%
  mutate(
    year = as.numeric(format(date, "%Y")),
    MonthYear = format(date, "%Y-%m")
  )

# Plot
p <- ggplot(df_grouped, aes(
  x = MonthYear,
  y = value,
  color = Index,
  linetype = Vegetation,
  group = interaction(Index, Vegetation, year)
)) +
  geom_line(size = size) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "black") +
  coord_cartesian(ylim = ylim)+ 
  scale_y_continuous(breaks = seq(-35, 30, by = 5)) +
  labs(
    title = "Vergleich der Indizes für verschiedene Waldtypen",
    subtitle = "Mai–September 2013–2017\nReferenzperiode Vegetationsindizes: 2000–2012\nReferenzperiode Blattflächenindex: 2003–2012",
    x = "Monat",
    y = "Abweichung in % von Referenzwert",
    color = "Index",
    linetype = "Waldtyp",
    caption = "Quelle: MODIS NBAR Daily"
  ) +
  theme_minimal(base_size = base_font_size) +
  theme(
    axis.text.x = element_text(angle = 90, vjust = 0.5, size = 7),
    panel.grid.minor = element_blank()
  )

ggsave("data/final/plots/regional.png", plot = p, bg = "white", width = width, height  = height )
