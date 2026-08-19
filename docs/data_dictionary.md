# Data Dictionary

This document records the main data sources and variables.

## Data Sources

### 1. Electricity Prices

**Eurostat dataset:** `nrg_pc_205`  
**Description:** Electricity prices for industrial consumers  
**Frequency:** Bi-annual  
**Coverage:** 2007-S1 to 2025-S2  

**Variables to extract:**
- `geo`: country
- `TIME_PERIOD`: semester
- `OBS_VALUE`: electricity price
- `OBS_FLAG`: observation status

**Planned filters:**
- `nrg_cons = MWH500-1999`
- `tax = X_TAX`
- `currency = EUR`
- `unit = KWH`

---

### 2. Natural Gas Prices

**Eurostat dataset:** `nrg_pc_203`  
**Description:** Natural gas prices for industrial consumers  
**Frequency:** Bi-annual  
**Coverage:** 2007-S1 to 2025-S2  

**Variables to extract:**
TBD


---

### 3. Electricity Generation by Fuel

**Eurostat dataset:** `nrg_cb_pem`  
**Description:** Net electricity generation by type of fuel  
**Frequency:** Monthly  
**Coverage:** 2008-01 to 2026-06  

**Main fuel categories:**
- Total generation
- Natural gas
- Coal and manufactured gases
- Renewables and biofuels
- Hydro
- Wind
- Solar
- Nuclear
- Fossil energy

**Planned derived variables:**
- Gas generation share
- Renewable generation share
- Nuclear generation share
- Coal / fossil generation share

Monthly data will be aggregated into semesters:

- January–June → S1
- July–December → S2

---

## Planned Analytical Unit

The final analytical dataset is expected to contain one observation for each:

`country × semester`

The planned common period is:

`2008-S1 – 2025-S2`
