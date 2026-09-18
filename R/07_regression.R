# Baseline regression analysis
library(fixest)
library(DBI)
library(duckdb)
library(dplyr)
library(here)

here::i_am("R/07_regression.R")

# Load analytical panel
con <- dbConnect(
  duckdb(),
  dbdir = here("data", "processed", "energy_project.duckdb")
)

panel <- dbGetQuery(
  con,
  "SELECT * FROM analysis_panel;"
)

dbDisconnect(con)

# Crisis indicator
panel <- panel %>%
  mutate(
    crisis = if_else(
      semester >= "2021-S1" & semester <= "2023-S2",
      1,
      0
    )
  )

# Model 1: gas price only
m1 <- lm(
  electricity_price ~ gas_price,
  data = panel
)

# Model 2: gas price + gas generation share
m2 <- lm(
  electricity_price ~ gas_price + gas_share,
  data = panel
)

# Model 3: interaction
m3 <- lm(
  electricity_price ~ gas_price * gas_share,
  data = panel
)

print(summary(m1))
print(summary(m2))
print(summary(m3))

m4 <- lm(
  electricity_price ~ gas_price * gas_share + crisis,
  data = panel
)

print(summary(m4))


# Country fixed effects
m5 <- feols(
  electricity_price ~ gas_price * gas_share | country_code,
  data = panel,
  cluster = ~country_code
)

# Country + semester fixed effects
m6 <- feols(
  electricity_price ~ gas_price * gas_share |
    country_code + semester,
  data = panel,
  cluster = ~country_code
)

print(summary(m5))
print(summary(m6))

m7 <- feols(
  electricity_price ~
    gas_price * gas_share +
    gas_price:crisis +
    gas_price:gas_share:crisis |
    country_code + semester,
  data = panel,
  cluster = ~country_code
)

print(summary(m7))

library(ggplot2)

# Representative gas-share values
gas_share_grid <- c(0.1, 0.3, 0.5)

effects <- expand.grid(
  gas_share = gas_share_grid,
  crisis = c(0, 1)
)

b <- coef(m7)

effects$gas_price_slope <-
  b["gas_price"] +
  b["gas_price:gas_share"] * effects$gas_share +
  b["gas_price:crisis"] * effects$crisis +
  b["gas_price:gas_share:crisis"] *
    effects$gas_share * effects$crisis

effects$period <- ifelse(
  effects$crisis == 1,
  "Energy crisis (2021–2023)",
  "Other periods"
)

print(effects)

effects <- effects %>%
  mutate(
    effect_per_1cent = gas_price_slope * 0.01
  )

print(effects)

p_effects <- ggplot(
  effects,
  aes(
    x = gas_share,
    y = effect_per_1cent,
    linetype = period,
    shape = period
  )
) +
  geom_line() +
  geom_point(size = 3) +
  labs(
    title = "Estimated Gas-Price Association by Gas Dependence",
    subtitle = "Based on country and semester fixed-effects model",
    x = "Gas-fired share of electricity generation",
    y = "Change in electricity price for a €0.01/kWh increase in gas price",
    linetype = NULL,
    shape = NULL
  ) +
  theme_minimal()

print(p_effects)



#tables
library(fixest)

# Pooled OLS, but using feols
m1_fe <- feols(
  electricity_price ~ gas_price,
  data = panel,
  cluster = ~country_code
)

m3_fe <- feols(
  electricity_price ~ gas_price * gas_share,
  data = panel,
  cluster = ~country_code
)

# Existing fixed-effects models
m6 <- feols(
  electricity_price ~ gas_price * gas_share |
    country_code + semester,
  data = panel,
  cluster = ~country_code
)

m7 <- feols(
  electricity_price ~
    gas_price * gas_share +
    gas_price:crisis +
    gas_price:gas_share:crisis |
    country_code + semester,
  data = panel,
  cluster = ~country_code
)

etable(
  m1_fe,
  m3_fe,
  m6,
  m7,
  headers = c(
    "Pooled OLS",
    "Pooled interaction",
    "Two-way FE",
    "Crisis interaction"
  ),
  digits = 3,
  file = here("output", "tables", "regression_results.html")
)

balanced_countries <- panel %>%
  group_by(country_code) %>%
  summarise(
    n_periods = n_distinct(semester),
    .groups = "drop"
  ) %>%
  filter(n_periods == 18)

print(balanced_countries)

panel_balanced <- panel %>%
  filter(country_code %in% balanced_countries$country_code)

print(
  panel_balanced %>%
    summarise(
      n_countries = n_distinct(country_code),
      n_obs = n()
    )
)

m6_bal <- feols(
  electricity_price ~ gas_price * gas_share |
    country_code + semester,
  data = panel_balanced,
  cluster = ~country_code
)

m7_bal <- feols(
  electricity_price ~
    gas_price * gas_share +
    gas_price:crisis +
    gas_price:gas_share:crisis |
    country_code + semester,
  data = panel_balanced,
  cluster = ~country_code
)

print(summary(m6_bal))
print(summary(m7_bal))