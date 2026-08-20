# Initial inspection of 'nrg_pc_203'

library(readr)
library(dplyr)
library(here)

gas_raw <- read_csv(
  here("data", "raw", "nrg_pc_203_gas_prices.csv"),
  show_col_types = FALSE
)

glimpse(gas_raw)

names(gas_raw)

dim(gas_raw)

# Key dimensions
gas_raw %>%
  distinct(nrg_cons) %>%
  arrange(nrg_cons)

gas_raw %>%
  distinct(tax)

gas_raw %>%
  distinct(unit)

gas_raw %>%
  distinct(currency)

# Labels for key categories
gas_raw %>%
  distinct(nrg_cons, `Energy consumption`)

gas_raw %>%
  distinct(tax, Taxes)

gas_raw %>%
  distinct(currency, Currency)

# Country coverage
gas_raw %>%
  summarise(
    n_countries = n_distinct(geo)
  )

# Time coverage
gas_raw %>%
  summarise(
    first_period = min(TIME_PERIOD, na.rm = TRUE),
    last_period = max(TIME_PERIOD, na.rm = TRUE)
  )

# Missing gas prices
gas_raw %>%
  summarise(
    n_observations = n(),
    missing_prices = sum(is.na(OBS_VALUE))
  )

# Candidate main natural gas price measure
gas_candidate <- gas_raw %>%
  filter(
    nrg_cons == "GJ10000-99999",
    tax == "X_TAX",
    currency == "EUR",
    unit == "KWH"
  )

# Basic coverage
gas_candidate %>%
  summarise(
    n_countries = n_distinct(geo),
    first_period = min(TIME_PERIOD, na.rm = TRUE),
    last_period = max(TIME_PERIOD, na.rm = TRUE),
    n_observations = n(),
    missing_prices = sum(is.na(OBS_VALUE))
  )

gas_candidate_2008 <- gas_candidate %>%
  filter(
    TIME_PERIOD >= "2008-S1",
    TIME_PERIOD <= "2025-S2"
  )

gas_candidate_2008 %>%
  group_by(geo, `Geopolitical entity (reporting)`) %>%
  summarise(
    first_period = min(TIME_PERIOD),
    last_period = max(TIME_PERIOD),
    n_periods = n_distinct(TIME_PERIOD),
    missing_prices = sum(is.na(OBS_VALUE)),
    .groups = "drop"
  ) %>%
  arrange(n_periods) %>%
  print(n = Inf)

gas_candidate_2008 %>%
  count(geo, TIME_PERIOD) %>%
  filter(n > 1)

# Check zero gas prices
gas_candidate_2008 %>%
  filter(OBS_VALUE == 0) %>%
  select(
    geo,
    `Geopolitical entity (reporting)`,
    TIME_PERIOD,
    OBS_VALUE,
    OBS_FLAG,
    `Observation status (Flag) V2 structure`
  )
