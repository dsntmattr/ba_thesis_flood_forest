# Packages. ---------------------------------------------------------------
library(ggplot2)
library(lubridate)
library(dplyr)
theme_set(theme_linedraw())

# Each plot in new window.  ----------------------------------------
#dev.off()

# Vogelsang. --------------------------------------------------------------
load("data/work/dataframes/df_diff_harm_long_vogelsang.RData")
df <- df_differences_harmonised_long

# One plot per graph, on one page. ----------------------------------------
ggplot(df, aes(x = date, y = difference)) +
  geom_line(color = "#2C3E50") +
  facet_wrap(~index, ncol = 1, scales = "free_y") +  # je ein Panel pro Variable
  labs(
    title = "Zeitverlauf Vegetationsindizes",
    subtitle = "Mai–September 2013–2017",
    x = "Datum",
    y = "Indexwert",
    caption = "Quelle: Satellitendaten"
  ) +
  scale_x_date(
    breaks = unique(df$date),
    labels = brks <- unique(df$date)  # Definiere brks vor der Verwendung

  ) +
  theme(
    axis.text.x = element_text(angle = 90, vjust = 0.5, size = 7),
    panel.grid.minor = element_blank()
  )

# All graphs in one plot. -------------------------------------------------
df_grouped <- df %>%
  mutate(
    year = as.numeric(format(date, "%Y"))
  )

df_grouped$MonthYear <- format(df_grouped$date, "%Y-%m")

ggplot(df_grouped, aes(
  x = MonthYear,
  y = difference,
  color = index,
  linetype = index,
  group = interaction(index, year)
)) +
  geom_line(size = 1) +
  labs(
    title = "Zeitverlauf Vegetationsindizes Vogelsang",
    subtitle = "Mai–September 2013–2017",
    x = "Monat",
    y = "Abweichung in % von Wertespanne der Referenzperiode",
    color = "Index",
    linetype = "Index",
    caption = "Quelle: Satellitendaten"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 90, vjust = 0.5, size = 7),
    panel.grid.minor = element_blank()
  )

# Compare indices for each forest type ------------------------------------------------------------------
load("data/work/dataframes/df_dif_har_66p_long.RData")
df <- df_dif_har_66p_long

df_grouped <- df %>%
  mutate(
    year = as.numeric(format(date, "%Y"))
  )

df_grouped$MonthYear <- format(df_grouped$date, "%Y-%m")

df_grouped %>%
  group_by(Vegetation) %>%
  do(
    p = ggplot(data = ., aes(
      x = MonthYear,
      y = value,
      color = Index,
      linetype = Index,
      group = interaction(Index, year)
    )) +
      geom_line(size = 1) +
      geom_hline(yintercept = 0, linetype = "dashed", color = "black") +
      labs(
        title = paste("Vergleich der Indices für Waldtyp:", unique(.$Vegetation)),
        x = "Monat",
        y = "Abweichung in %",
        color = "Index",
        linetype = "Index"
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
plots_by_vegetation$p[[3]]  # zweiter Waldtyp
# etc.

# Compare one index for all forest types
index_to_plot <- "NIRv"  # Beispiel: IndexType, den du anschauen willst

df_filtered <- df_grouped %>%
  filter(Index == index_to_plot)

ggplot(df_filtered, aes(
  x = MonthYear,
  y = value,
  color = Vegetation,
  group = interaction(Vegetation, year)
)) +
  geom_line(size = 1) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "black") +
  labs(
    title = paste("Vergleich von", index_to_plot, "bei allen Waldtypen"),
    x = "Monat",
    y = "Abweichung in %",
    color = "Waldtyp"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 90, vjust = 0.5, size = 7),
    panel.grid.minor = element_blank()
  )













# One plot per index. -----------------------------------------------------
df_ndvi_harm <- data.frame(dif = c(df_differences_harmonised$ndvi))
df_evi_harm <- data.frame(dif = c(df_differences_harmonised$evi))
df_nirv_harm <- data.frame(dif = c(df_differences_harmonised$nirv))

row.names(df_ndvi_harm) <- new_rows
row.names(df_evi_harm) <- new_rows
row.names(df_nirv_harm) <- new_rows

plot_ndvi <- ggplot(df, aes(x = rownames(df))) +
  geom_point(aes(y = dif, colour = "dif")) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "black") +
  labs(title = "NDVI", x = "Datetimes YY/MM", y = "Differences", color = "Coverage") +
  ylim(-260, 10)
plot_ndvi

plot_evi <- ggplot(df, aes(x = rownames(df))) +
  geom_point(aes(y = dif, colour = "dif")) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "black") +
  labs(title = "EVI", x = "Datetimes YY/MM", y = "Differences", color = "Coverage") +
  ylim(-260, 10)
plot_evi

plot_nirv <- ggplot(df, aes(x = rownames(df))) +
  geom_point(aes(y = dif, colour = "dif")) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "black") +
  labs(title = "nirv", x = "Datetimes YY/MM", y = "Differences", color = "Coverage") +
  ylim(-260, 10)
plot_nirv

plot_ndvi / plot_evi / plot_nirv  # untereinander
# oder plot_ndvi + plot_evi + plot_nirv  # nebeneinander

# LAI ---------------------------------------------------------------------
# Vergleich der Plots zwischen LAI Q1Q2 und LAi Q1
# QA1QA2

df <- df_lai_differences

plot_lai_30p <- ggplot(df, aes(x = rownames(df))) +
  geom_point(aes(y = LAI_Broad_30p, colour = "B")) +
  geom_point(aes(y = LAI_Conifer_30p, colour = "C")) +
  geom_point(aes(y = LAI_Mixed_30p, colour = "M")) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "black") +
  labs(title = "LAI 30p", x = "Datetimes YY/MM", y = "Differences", color = "Coverage")

plot_lai_50p <- ggplot(df, aes(x = rownames(df))) +
  geom_point(aes(y = LAI_Broad_50p, colour = "B")) +
  geom_point(aes(y = LAI_Conifer_50p, colour = "C")) +
  geom_point(aes(y = LAI_Mixed_50p, colour = "M")) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "black") +
  labs(title = "LAI 50p", x = "Datetimes YY/MM", y = "Differences", color = "Coverage")

plot_lai_66p <- ggplot(df, aes(x = rownames(df))) +
  geom_point(aes(y = LAI_Broad_66p, colour = "B")) +
  geom_point(aes(y = LAI_Conifer_66p, colour = "C")) +
  geom_point(aes(y = LAI_Mixed_66p, colour = "M")) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "black") +
  labs(title = "LAI 66p", x = "Datetimes YY/MM", y = "Differences", color = "Coverage")

plot_lai_70p <- ggplot(df, aes(x = rownames(df))) +
  geom_point(aes(y = LAI_Broad_70p, colour = "B")) +
  geom_point(aes(y = LAI_Conifer_70p, colour = "C")) +
  geom_point(aes(y = LAI_Mixed_70p, colour = "M")) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "black") +
  labs(title = "LAI 70p", x = "Datetimes YY/MM", y = "Differences", color = "Coverage")

plot_lai_90p <- ggplot(df, aes(x = rownames(df))) +
  geom_point(aes(y = LAI_Broad_90p, colour = "B")) +
  geom_point(aes(y = LAI_Conifer_90p, colour = "C")) +
  geom_point(aes(y = LAI_Mixed_90p, colour = "M")) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "black") +
  labs(title = "LAI 90p", x = "Datetimes YY/MM", y = "Differences", color = "Coverage")

plot_lai_99p <- ggplot(df, aes(x = rownames(df))) +
  geom_point(aes(y = LAI_Broad_99p, colour = "B")) +
  geom_point(aes(y = LAI_Conifer_99p, colour = "C")) +
  geom_point(aes(y = LAI_Mixed_99p, colour = "M")) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "black") +
  labs(title = "LAI 99p", x = "Datetimes YY/MM", y = "Differences", color = "Coverage")


# QA1

df <- df_lai_differences_qa1

plot_lai_30p_qa1 <- ggplot(df, aes(x = rownames(df))) +
  geom_point(aes(y = LAI_Broad_30p, colour = "B")) +
  geom_point(aes(y = LAI_Conifer_30p, colour = "C")) +
  geom_point(aes(y = LAI_Mixed_30p, colour = "M")) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "black") +
  labs(title = "LAI 30p", x = "Datetimes YY/MM", y = "Differences", color = "Coverage")

plot_lai_50p_qa1 <- ggplot(df, aes(x = rownames(df))) +
  geom_point(aes(y = LAI_Broad_50p, colour = "B")) +
  geom_point(aes(y = LAI_Conifer_50p, colour = "C")) +
  geom_point(aes(y = LAI_Mixed_50p, colour = "M")) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "black") +
  labs(title = "LAI 50p", x = "Datetimes YY/MM", y = "Differences", color = "Coverage")

plot_lai_66p_qa1 <- ggplot(df, aes(x = rownames(df))) +
  geom_point(aes(y = LAI_Broad_66p, colour = "B")) +
  geom_point(aes(y = LAI_Conifer_66p, colour = "C")) +
  geom_point(aes(y = LAI_Mixed_66p, colour = "M")) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "black") +
  labs(title = "LAI 66p", x = "Datetimes YY/MM", y = "Differences", color = "Coverage")

plot_lai_70p_qa1 <- ggplot(df, aes(x = rownames(df))) +
  geom_point(aes(y = LAI_Broad_70p, colour = "B")) +
  geom_point(aes(y = LAI_Conifer_70p, colour = "C")) +
  geom_point(aes(y = LAI_Mixed_70p, colour = "M")) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "black") +
  labs(title = "LAI 70p", x = "Datetimes YY/MM", y = "Differences", color = "Coverage")

plot_lai_90p_qa1 <- ggplot(df, aes(x = rownames(df))) +
  geom_point(aes(y = LAI_Broad_90p, colour = "B")) +
  geom_point(aes(y = LAI_Conifer_90p, colour = "C")) +
  geom_point(aes(y = LAI_Mixed_90p, colour = "M")) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "black") +
  labs(title = "LAI 90p", x = "Datetimes YY/MM", y = "Differences", color = "Coverage")

plot_lai_99p_qa1 <- ggplot(df, aes(x = rownames(df))) +
  geom_point(aes(y = LAI_Broad_99p, colour = "B")) +
  geom_point(aes(y = LAI_Conifer_99p, colour = "C")) +
  geom_point(aes(y = LAI_Mixed_99p, colour = "M")) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "black") +
  labs(title = "LAI 99p", x = "Datetimes YY/MM", y = "Differences", color = "Coverage")

# Plots

plot_lai_30p
plot_lai_50p
plot_lai_66p
plot_lai_90p
plot_lai_99p

plot_lai_30p_qa1
plot_lai_50p_qa1
plot_lai_66p_qa1
plot_lai_90p_qa1
plot_lai_99p_qa1

