library(ggplot2)


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

