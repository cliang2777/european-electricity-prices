CREATE OR REPLACE TABLE generation_semester AS

WITH monthly_generation AS (
    SELECT
        geo AS country_code,
        "Geopolitical entity (reporting)" AS country,
        TIME_PERIOD,
        CAST(SUBSTR(TIME_PERIOD, 1, 4) AS INTEGER) AS year,
        CAST(SUBSTR(TIME_PERIOD, 6, 2) AS INTEGER) AS month,
        siec,
        OBS_VALUE AS generation_gwh
    FROM generation_raw
    WHERE
        unit = 'GWH'
        AND TIME_PERIOD >= '2017-01'
        AND TIME_PERIOD <= '2025-12'
        AND siec IN (
            'TOTAL',
            'G3000',
            'C0000',
            'RA000',
            'N9000',
            'O4000XBIO'
        )
),

semester_generation AS (
    SELECT
        country_code,
        country,
        year,
        CASE
            WHEN month <= 6 THEN 'S1'
            ELSE 'S2'
        END AS semester_half,
        siec,
        SUM(generation_gwh) AS generation_gwh
    FROM monthly_generation
    GROUP BY
        country_code,
        country,
        year,
        semester_half,
        siec
)

SELECT
    country_code,
    country,
    CAST(year AS VARCHAR) || '-' || semester_half AS semester,

    MAX(CASE WHEN siec = 'TOTAL' THEN generation_gwh END) AS total_generation_gwh,
    MAX(CASE WHEN siec = 'G3000' THEN generation_gwh END) AS gas_generation_gwh,
    MAX(CASE WHEN siec = 'C0000' THEN generation_gwh END) AS coal_generation_gwh,
    MAX(CASE WHEN siec = 'RA000' THEN generation_gwh END) AS renewable_generation_gwh,
    MAX(CASE WHEN siec = 'N9000' THEN generation_gwh END) AS nuclear_other_generation_gwh,
    MAX(CASE WHEN siec = 'O4000XBIO' THEN generation_gwh END) AS oil_generation_gwh

FROM semester_generation

GROUP BY
    country_code,
    country,
    year,
    semester_half;

CREATE OR REPLACE TABLE generation_mix AS

SELECT
    *,
    gas_generation_gwh / NULLIF(total_generation_gwh, 0) AS gas_share,
    coal_generation_gwh / NULLIF(total_generation_gwh, 0) AS coal_share,
    renewable_generation_gwh / NULLIF(total_generation_gwh, 0) AS renewable_share,
    nuclear_other_generation_gwh / NULLIF(total_generation_gwh, 0) AS nuclear_other_share,
    oil_generation_gwh / NULLIF(total_generation_gwh, 0) AS oil_share

FROM generation_semester;
