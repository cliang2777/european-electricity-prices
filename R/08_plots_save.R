library(here)

here::i_am("R/08_plots_save.R")

source(here("R", "06_eda.R"))
source(here("R", "07_regression.R"))

ggplot2::ggsave(
  here("output", "figures", "electricity_price_trend.png"),
  plot = p1,
  width = 9,
  height = 6,
  dpi = 300
)

ggplot2::ggsave(
  here("output", "figures", "gas_price_trend.png"),
  plot = p2,
  width = 9,
  height = 6,
  dpi = 300
)

ggplot2::ggsave(
  here("output", "figures", "gas_electricity_relationship.png"),
  plot = p3,
  width = 9,
  height = 6,
  dpi = 300
)

ggplot2::ggsave(
  here("output", "figures", "gas_exposure_relationship.png"),
  plot = p5,
  width = 9,
  height = 6,
  dpi = 300
)

ggplot2::ggsave(
  here("output", "figures", "marginal_effects_gas_dependence.png"),
  plot = p_effects,
  width = 9,
  height = 6,
  dpi = 300
)