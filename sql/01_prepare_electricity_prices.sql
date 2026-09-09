CREATE OR REPLACE TABLE electricity_prices AS

SELECT
    geo AS country_code,
    "Geopolitical entity (reporting)" AS country,
    TIME_PERIOD AS semester,
    OBS_VALUE AS electricity_price,
    OBS_FLAG AS observation_flag
FROM electricity_raw
WHERE
    nrg_cons = 'MWH500-1999'
    AND tax = 'X_TAX'
    AND currency = 'EUR'
    AND unit = 'KWH'
    AND TIME_PERIOD >= '2008-S1'
    AND TIME_PERIOD <= '2025-S2';
    