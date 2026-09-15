library(DBI)
library(duckdb)
library(dplyr)
library(ggplot2)
library(here)

here::i_am("R/06_eda.R")

con <- dbConnect(
    duckdb(),
    dbdir = here("data", "processed", "energy_project.duckdb")
)

panel <- dbGetQuery(
    con,
    "SELECT * FROM analysis_panel;"
)

dbDisconnect(con)


glimpse(panel)

print(dim(panel))
print(summary(panel))

print(
panel %>%
    summarise(
        n_countries = n_distinct(country_code),
        first_period = min(semester),
        last_period = max(semester)
    )
)

# electricity_trend
panel <- panel %>%
  mutate(
    semester = factor(
      semester,
      levels = sort(unique(semester))
    )
  )

electricity_trend <- panel %>%
  group_by(semester) %>%
  summarise(
    mean_electricity_price = mean(electricity_price, na.rm = TRUE),
    .groups = "drop"
  )

p1 <- ggplot(
  electricity_trend,
  aes(
    x = semester,
    y = mean_electricity_price,
    group = 1
  )
) +
  geom_line() +
  geom_point() +
  labs(
    title = "Average Non-Household Electricity Prices in Europe",
    subtitle = "2017-S1 to 2025-S2",
    x = NULL,
    y = "EUR per kWh"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(
      angle = 45,
      hjust = 1
    )
  )

print(p1)

# gas_trend
gas_trend <- panel %>%
  group_by(semester) %>%
  summarise(
    mean_gas_price = mean(gas_price, na.rm = TRUE),
    .groups = "drop"
  )

p2 <- ggplot(
  gas_trend,
  aes(
    x = semester,
    y = mean_gas_price,
    group = 1
  )
) +
  geom_line() +
  geom_point() +
  labs(
    title = "Average Non-Household Natural Gas Prices in Europe",
    subtitle = "2017-S1 to 2025-S2",
    x = NULL,
    y = "EUR per kWh"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(
      angle = 45,
      hjust = 1
    )
  )

print(p2)

# crisis indicator
panel <- panel %>%
  mutate(
    crisis_period = if_else(
      as.character(semester) >= "2021-S1" &
        as.character(semester) <= "2023-S2",
      "Energy crisis (2021–2023)",
      "Other periods"
    )
  )

print(
  panel %>%
    count(crisis_period)
)

# Panel
p3 <- ggplot(
  panel,
  aes(
    x = gas_price,
    y = electricity_price,
    shape = crisis_period
  )
) +
  geom_point(
    alpha = 0.6
  ) +
  geom_smooth(
    method = "lm",
    se = FALSE,
    aes(linetype = crisis_period)
  ) +
  labs(
    title = "Natural Gas and Electricity Prices in Europe",
    subtitle = "Country-semester observations, 2017–2025",
    x = "Natural gas price (EUR per kWh)",
    y = "Electricity price (EUR per kWh)",
    shape = NULL,
    linetype = NULL
  ) +
  theme_minimal()

print(p3)

print(
  panel %>%
    summarise(
      correlation = cor(
        gas_price,
        electricity_price,
        use = "complete.obs"
      )
    )
)

print(
  panel %>%
    group_by(crisis_period) %>%
    summarise(
      correlation = cor(
        gas_price,
        electricity_price,
        use = "complete.obs"
      ),
      .groups = "drop"
    )
)

p4 <- ggplot(
  panel,
  aes(
    x = gas_share,
    y = electricity_price,
    color = crisis_period
  )
) +
  geom_point(
    alpha = 0.55
  ) +
  geom_smooth(
    method = "lm",
    se = FALSE
  ) +
  labs(
    title = "Gas-Fired Generation and Electricity Prices",
    subtitle = "Country-semester observations, 2017–2025",
    x = "Natural gas share of electricity generation",
    y = "Electricity price (EUR per kWh)",
    color = NULL
  ) +
  theme_minimal()

print(p4)

print(
  panel %>%
    summarise(
      correlation = cor(
        gas_share,
        electricity_price,
        use = "complete.obs"
      )
    )
)

print(
  panel %>%
    group_by(crisis_period) %>%
    summarise(
      correlation = cor(
        gas_share,
        electricity_price,
        use = "complete.obs"
      ),
      .groups = "drop"
    )
)

panel <- panel %>%
  mutate(
    gas_exposure = gas_price * gas_share
  )

p5 <- ggplot(
  panel,
  aes(
    x = gas_exposure,
    y = electricity_price,
    color = crisis_period
  )
) +
  geom_point(alpha = 0.55) +
  geom_smooth(
    method = "lm",
    se = FALSE
  ) +
  labs(
    title = "Gas Price Exposure and Electricity Prices",
    subtitle = "Gas price × gas-fired generation share, 2017–2025",
    x = "Gas price × gas generation share",
    y = "Electricity price (EUR per kWh)",
    color = NULL
  ) +
  theme_minimal()

print(p5)

print(
  panel %>%
    summarise(
      correlation = cor(
        gas_exposure,
        electricity_price,
        use = "complete.obs"
      )
    )
)

print(
  panel %>%
    group_by(crisis_period) %>%
    summarise(
      correlation = cor(
        gas_exposure,
        electricity_price,
        use = "complete.obs"
      ),
      .groups = "drop"
    )
)
