library(DBI)
library(duckdb)
library(here)

here::i_am("R/05_run_sql_preprocessing.R")

con <- dbConnect(
  duckdb(),
  dbdir = here("data", "processed", "energy_project.duckdb")
)

# Electricity prices
sql_electricity <- paste(
  readLines(
    here("sql", "01_prepare_electricity_prices.sql")
  ),
  collapse = "\n"
)

dbExecute(con, sql_electricity)

print(
  dbGetQuery(
    con,
    "SELECT COUNT(*) AS n_rows FROM electricity_prices;"
  )
)

print(
  dbGetQuery(
    con,
    "
    SELECT *
    FROM electricity_prices
    ORDER BY country_code, semester
    LIMIT 10;
    "
  )
)

# Gas prices
sql_gas <- paste(
    readLines(
        here("sql", "02_prepare_gas_prices.sql")
    ),
    collapse = "\n"
)

dbExecute(con, sql_gas)

print(
    dbGetQuery(
        con,
        "SELECT COUNT(*) AS n_rows FROM gas_prices;"
    )
)

print(
    dbGetQuery(
        con,
        "
        SELECT *
        FROM gas_prices
        ORDER BY country_code, semester
        LIMIT 10;
        "
    )
)

# Generation mix
sql_generation <- paste(
    readLines(
        here("sql", "03_prepare_generation.sql")
    ),
    collapse = "\n"
)

dbExecute(con, sql_generation)

print(
    dbGetQuery(
        con,
        "SELECT COUNT(*) AS n_rows FROM generation_semester;"
    )
)

print(
    dbGetQuery(
        con,
        "
        SELECT *
        FROM generation_semester
        WHERE country_code = 'NL'
        ORDER BY semester
        LIMIT 10;
        "
    )
)

print(
    dbGetQuery(
        con,
        "
        SELECT
            country_code,
            semester,
            gas_share,
            coal_share,
            renewable_share,
            nuclear_other_share,
            oil_share
        FROM generation_mix
        WHERE country_code = 'NL'
        ORDER BY semester
        LIMIT 10;
        "
    )
)

print(
    dbGetQuery(
        con,
        "
        SELECT
            MIN(gas_share) AS min_gas,
            MAX(gas_share) AS max_gas,
            MIN(coal_share) AS min_coal,
            MAX(coal_share) AS max_coal,
            MIN(renewable_share) AS min_renewable,
            MAX(renewable_share) AS max_renewable,
            MIN(nuclear_other_share) AS min_nuclear_other,
            MAX(nuclear_other_share) AS max_nuclear_other,
            MIN(oil_share) AS min_oil,
            MAX(oil_share) AS max_oil
        FROM generation_mix;
        "
    )
)

print(
    dbGetQuery(
        con,
        "
        SELECT *
        FROM generation_mix
        WHERE gas_share > 1
           OR coal_share > 1
           OR renewable_share > 1
           OR nuclear_other_share > 1
           OR oil_share > 1;
        "
    )
)

# Panel
sql_panel <- paste(
    readLines(
        here("sql", "04_build_analysis_panel.sql")
    ),
    collapse = "\n"
)

dbExecute(con, sql_panel)

print(
    dbGetQuery(
        con,
        "SELECT COUNT(*) AS n_rows FROM analysis_panel;"
    )
)

print(
    dbGetQuery(
        con,
        "
        SELECT *
        FROM analysis_panel
        ORDER BY country_code, semester
        LIMIT 20;
        "
    )
)

# Number of countries
print(
    dbGetQuery(
        con,
        "
        SELECT COUNT(DISTINCT country_code) AS n_countries
        FROM analysis_panel;
        "
    )
)

# Time coverage
print(
    dbGetQuery(
        con,
        "
        SELECT
            MIN(semester) AS first_period,
            MAX(semester) AS last_period
        FROM analysis_panel;
        "
    )
)

# Missing values
print(
    dbGetQuery(
        con,
        "
        SELECT
            SUM(electricity_price IS NULL) AS missing_electricity,
            SUM(gas_price IS NULL) AS missing_gas,
            SUM(gas_share IS NULL) AS missing_gas_share,
            SUM(coal_share IS NULL) AS missing_coal_share,
            SUM(renewable_share IS NULL) AS missing_renewable_share,
            SUM(nuclear_other_share IS NULL) AS missing_nuclear_other_share,
            SUM(oil_share IS NULL) AS missing_oil_share
        FROM analysis_panel;
        "
    )
)
dbDisconnect(con)