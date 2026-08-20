# Initial inspection of 'nrg_cb_pem'

library(readr)
library(dplyr)
library(here)

generation_raw <- read_csv(
  here("data", "raw", "nrg_cb_pem_generation.csv"),
  show_col_types = FALSE
)

glimpse(generation_raw)

names(generation_raw)

dim(generation_raw)

# Fuel categories
generation_raw %>%
  distinct(
    siec,
    `Standard international energy product classification (SIEC)`
  ) %>%
  arrange(siec) %>%
  print(n = Inf)

# Units
generation_raw %>%
  distinct(unit, `Unit of measure`)

# Country coverage
generation_raw %>%
  summarise(
    n_countries = n_distinct(geo)
  )

# Time coverage
generation_raw %>%
  summarise(
    first_period = min(TIME_PERIOD, na.rm = TRUE),
    last_period = max(TIME_PERIOD, na.rm = TRUE)
  )

# Missing generation values
generation_raw %>%
  summarise(
    n_observations = n(),
    missing_generation = sum(is.na(OBS_VALUE))
  )


generation_raw %>%
  filter(
    unit == "GWH",
    TIME_PERIOD >= "2008-01",
    TIME_PERIOD <= "2025-12"
  ) %>%
  count(geo, TIME_PERIOD, siec) %>%
  filter(n > 1)

generation_raw %>%
  filter(
    unit == "GWH",
    siec %in% c(
      "TOTAL",
      "G3000",
      "C0000",
      "O4000XBIO",
      "RA000",
      "N9000"
    ),
    TIME_PERIOD >= "2008-01",
    TIME_PERIOD <= "2025-12"
  ) %>%
  group_by(siec) %>%
  summarise(
    n_observations = n(),
    missing_values = sum(is.na(OBS_VALUE)),
    .groups = "drop"
  )

generation_raw %>%
  filter(
    unit == "GWH",
    siec %in% c(
      "TOTAL",
      "G3000",
      "C0000",
      "O4000XBIO",
      "RA000",
      "N9000"
    ),
    TIME_PERIOD >= "2008-01",
    TIME_PERIOD <= "2025-12"
  ) %>%
  group_by(siec) %>%
  summarise(
    n_countries = n_distinct(geo),
    first_period = min(TIME_PERIOD),
    last_period = max(TIME_PERIOD),
    n_observations = n(),
    .groups = "drop"
  )

generation_raw %>%
  filter(
    geo == "NL",
    unit == "GWH",
    siec %in% c("TOTAL", "G3000", "C0000", "RA000", "N9000"),
    TIME_PERIOD >= "2020-01",
    TIME_PERIOD <= "2020-12"
  ) %>%
  select(geo, TIME_PERIOD, siec, OBS_VALUE) %>%
  arrange(TIME_PERIOD, siec)
