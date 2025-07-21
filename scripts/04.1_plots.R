# Packages. ---------------------------------------------------------------
library(ggplot2)
library(lubridate)
library(dplyr)
theme_set(theme_linedraw())

# Each plot in new window.  ----------------------------------------
#dev.off()

# Load dataframes. --------------------------------------------------------
load("data/work/dataframes/df_dif_relative_local_long.RData")
load("data/work/dataframes/df_dif_relative_regional_long.RData")


# Change properties of the plots. -----------------------------------------

size <- 0.5
ylim <- c(-40, 30)

# Local.  --------------------------------------------------------------

df <- df_dif_rel_loc_long

# All graphs in one plot.
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
  ylim(ylim) + 
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
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 90, vjust = 0.5, size = 7),
    panel.grid.minor = element_blank()
  )

plot

ggsave("data/final/plots/local.png", plot = plot, bg = "white")

# Regional. -------------------------------------------------------
# Compare indices for each forest type
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
      ylim(ylim) +
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
      theme_minimal() +
      theme(
        axis.text.x = element_text(angle = 90, vjust = 0.5, size = 7),
        panel.grid.minor = element_blank()
      )
  ) -> plots_by_vegetation

# plots_by_vegetation$p enthält dann eine Liste mit Plots, z.B.:
plots_by_vegetation$p[[1]]  # erster Waldtyp
plots_by_vegetation$p[[2]]  # zweiter Waldtyp


ggsave("data/final/plots/regional_broad.png",   plot = plots_by_vegetation$p[[1]], bg = "white")
ggsave("data/final/plots/regional_conifer.png", plot = plots_by_vegetation$p[[2]], bg = "white")

# Compare one index for all forest type

df_filtered <- df_grouped %>%
  filter(Index == "NDVI")

plot <- ggplot(df_filtered, aes(
  x = MonthYear,
  y = value,
  color = Vegetation,
  linetype = Vegetation,
  group = interaction(Vegetation, year)
)) +
  geom_line(size = size) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "black") +
  ylim(ylim) +
  labs(
    title = paste("Vergleich von", index_to_plot, "bei allen Waldtypen"),
    subtitle = "Mai–September 2013–2017,
    Referenzperiode Vegetationsindizes: 2000 - 2012
    Referenzperiode Blattflächenindex: 2003 - 2012",
    x = "Monat",
    y = "Abweichung in %",
    color = "Waldtyp",
    linetype = "Waldtyp",
    caption = "Quelle: MODIS NBAR Daily"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 90, vjust = 0.5, size = 7),
    panel.grid.minor = element_blank()
  )

plot

ggsave("data/final/plots/regional_ndvi.png", plot = plot, bg = "white")



