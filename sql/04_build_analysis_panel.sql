CREATE OR REPLACE TABLE analysis_panel AS

SELECT
    e.country_code,
    e.country,
    e.semester,
    e.electricity_price,
    g.gas_price,
    m.gas_share,
    m.coal_share,
    m.renewable_share,
    m.nuclear_other_share,
    m.oil_share

FROM electricity_prices e

INNER JOIN gas_prices g
    ON e.country_code = g.country_code
    AND e.semester = g.semester

INNER JOIN generation_mix m
    ON e.country_code = m.country_code
    AND e.semester = m.semester

WHERE
    e.semester >= '2017-S1'
    AND e.semester <= '2025-S2';