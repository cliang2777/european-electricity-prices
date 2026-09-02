
library(DBI)
library(duckdb)
library(here)

here::i_am("R/04_setup_database.R")

db_path <- here(
  "data",
  "processed",
  "energy_project.duckdb"
)

electricity_path <- here(
  "data",
  "raw",
  "nrg_pc_205_electricity_prices.csv"
)

gas_path <- here(
  "data",
  "raw",
  "nrg_pc_203_gas_prices.csv"
)

generation_path <- here(
  "data",
  "raw",
  "nrg_cb_pem_generation.csv"
)

print(file.exists(electricity_path))
print(file.exists(gas_path))
print(file.exists(generation_path))

drv <- duckdb(
    dbdir = db_path
)

con <- dbConnect(drv)

print(dbIsValid(con))

print(
    dbGetQuery(
        con,
        "SELECT 1 AS connection_test;"
    )
)


dbExecute(
    con,
    sprintf(
        "
        CREATE OR REPLACE TABLE electricity_raw AS
        SELECT *
        FROM read_csv_auto('%s');
        ",
        electricity_path
    )
)

print(
    dbGetQuery(
        con,
        "SELECT COUNT(*) AS n_rows FROM electricity_raw;"
    )
)


dbExecute(
    con,
    sprintf(
        "
        CREATE OR REPLACE TABLE gas_raw AS
        SELECT *
        FROM read_csv_auto('%s');
        ",
        gas_path
    )
)

print(
    dbGetQuery(
        con,
        "SELECT COUNT(*) AS n_rows FROM gas_raw;"
    )
)


dbExecute(
    con,
    sprintf(
        "
        CREATE OR REPLACE TABLE generation_raw AS
        SELECT *
        FROM read_csv_auto('%s');
        ",
        generation_path
    )
)

print(
    dbGetQuery(
        con,
        "SELECT COUNT(*) AS n_rows FROM generation_raw;"
    )
)



dbDisconnect(con)