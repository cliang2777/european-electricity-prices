CREATE OR REPLACE TABLE gas_prices AS

SELECT
    geo AS country_code,
    "Geopolitical entity (reporting)" AS country,
    TIME_PERIOD AS semester,
    OBS_VALUE AS gas_price,
    OBS_FLAG AS observation_flag
FROM gas_raw
WHERE
    nrg_cons = 'GJ10000-99999'
    AND tax = 'X_TAX'
    AND currency = 'EUR'
    AND unit = 'KWH'
    AND TIME_PERIOD >= '2008-S1'
    AND TIME_PERIOD <= '2025-S2';
    