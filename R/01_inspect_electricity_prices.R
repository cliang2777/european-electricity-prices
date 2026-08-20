# Initial inspection of 'nrg_pc_205'

library(readr)
library(dplyr)
library(here)

electricity_raw <- read_csv(
  here("data", "raw", "nrg_pc_205_electricity_prices.csv"),
  show_col_types = FALSE
)


glimpse(electricity_raw)

names(electricity_raw)

dim(electricity_raw)

# Key dimensions
electricity_raw %>%
  distinct(nrg_cons) %>%
  arrange(nrg_cons)

electricity_raw %>%
  distinct(tax)

electricity_raw %>%
  distinct(unit)

electricity_raw %>%
  distinct(currency)

# Country coverage
electricity_raw %>%
  summarise(
    n_countries = n_distinct(geo)
  )

# Time coverage
electricity_raw %>%
  summarise(
    first_period = min(TIME_PERIOD, na.rm = TRUE),
    last_period = max(TIME_PERIOD, na.rm = TRUE)
  )

# Missing electricity prices
electricity_raw %>%
  summarise(
    n_observations = n(),
    missing_prices = sum(is.na(OBS_VALUE))
  )

# Candidate main electricity price measure
electricity_candidate <- electricity_raw %>%
  filter(
    nrg_cons == "MWH500-1999",
    tax == "X_TAX",
    currency == "EUR",
    unit == "KWH"
  )

# Basic size
dim(electricity_candidate)

# Country coverage
electricity_candidate %>%
  summarise(
    n_countries = n_distinct(geo),
    first_period = min(TIME_PERIOD, na.rm = TRUE),
    last_period = max(TIME_PERIOD, na.rm = TRUE),
    n_observations = n(),
    missing_prices = sum(is.na(OBS_VALUE))
  )

electricity_candidate %>%
  group_by(geo, `Geopolitical entity (reporting)`) %>%
  summarise(
    n_periods = n_distinct(TIME_PERIOD),
    missing_prices = sum(is.na(OBS_VALUE)),
    .groups = "drop"
  ) %>%
  arrange(n_periods)

# Restrict to planned project period
electricity_candidate_2008 <- electricity_candidate %>%
  filter(
    TIME_PERIOD >= "2008-S1",
    TIME_PERIOD <= "2025-S2"
  )

# Coverage by country
electricity_candidate_2008 %>%
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

electricity_candidate_2008 %>%
  count(geo, TIME_PERIOD) %>%
  filter(n > 1)
