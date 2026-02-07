# dbt-analytics

Medallion pipeline on **GCP / BigQuery** using dbt.

| Layer | dbt path | Schema | Materialization | Tag |
|-------|----------|--------|-----------------|-----|
| **Source** | `models/sources/` | — | — | `sources` |
| **Silver** | `models/staging/` | `staging` | view | `silver` |
| **Gold** | `models/analytics/` | `analytics` | table | `gold` |

---

## Project Structure

```
models/
  sources/raw_ingestion/          # source definitions (_src YAML)
  staging/                        # SILVER — clean + standardized views
    customers/
    transactions/
  analytics/                      # GOLD — business-ready tables
    transactions/

macros/
  standard_fields/                # std_string, std_int, std_numeric, std_bool, std_date, std_timestamp
  keys/                           # generate_surrogate_key, natural_key_as_string

profiles/                         # profiles.yml (env-var based, no secrets)
```

---

## Naming Conventions

| Object | Pattern | Example |
|--------|---------|---------|
| Source YAML | `_src_<system>.yml` | `raw_ingestion__tables.yml` |
| Staging model | `stg_<system>__<entity>.sql` | `stg_ingestion__customers.sql` |
| Dimension | `dim_<entity>.sql` | `dim_customers.sql` |
| Fact | `fct_<process>.sql` | `fct_transactions.sql` |

---

## Macros

**Standard fields** — enforce consistent casting, trimming, and null handling across all staging models:

- `std_string(expr)` — trim + cast + optional upper/lower + empty→null
- `std_int(expr)` — `safe_cast` to `int64`
- `std_numeric(expr)` — `safe_cast` to `numeric`
- `std_bool(expr)` — multilingual boolean parser
- `std_date(expr)` / `std_timestamp(expr)` — safe casts

**Keys:**

- `generate_surrogate_key(['col_a', 'col_b'])` — MD5 hash of concatenated columns
- `natural_key_as_string(expr)` — trim + cast + nullif for source natural keys

---

## Local Setup

**Requirements:** Python 3.11+, pyenv (optional)

```bash
# Automated setup (pyenv + virtualenv + deps + dbt deps)
make local-setup

# Or manually
pip install -r requirements.txt
dbt deps
```

Copy and configure your profile:

```bash
cp profiles.yml.example profiles/profiles.yml
```

**Required env vars:**

| Variable | Description | Default |
|----------|-------------|---------|
| `DBT_BQ_PROJECT` | GCP project ID | — |
| `DBT_BQ_DATASET` | Base dataset | `silver_prod` |
| `DBT_BQ_LOCATION` | BigQuery location | `US` |
| `DBT_BQ_METHOD` | Auth method (`oauth` or `service-account`) | `oauth` |
| `DBT_TARGET` | Target environment | `prod` |

---

## Orchestration (Airflow Contract)

Airflow uses **dbt tags** via selectors to run layers in order:

```bash
# Step 1 — Silver
dbt build --selector silver

# Step 2 — Gold
dbt build --selector gold
```

Selectors are defined in `selectors.yml`. Tags are enforced in `dbt_project.yml`.

---

## Docker

```bash
# Build
docker build -t dbt-medallion:latest .

# Run (example: silver layer)
docker run --rm \
  -e DBT_BQ_PROJECT=my-project \
  -e DBT_BQ_DATASET=silver_prod \
  dbt-medallion:latest build --selector silver
```

The image uses **Python 3.11-slim** with dbt-core + dbt-bigquery **1.9.2**. Credentials are expected via **ADC / Workload Identity** — no JSON keys baked in.

---

## Adding a New Source System

1. Create `models/sources/<system>/_src_<system>.yml`
2. Create `models/staging/<system>/stg_<system>__<entity>.sql` using standard macros
3. (Optional) Create gold models in `models/analytics/<domain>/`

That's it — tags and materialization are inherited from `dbt_project.yml`.