FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    DBT_PROFILES_DIR=/app/profiles \
    DBT_PROJECT_DIR=/app/dbt

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    git ca-certificates \
  && rm -rf /var/lib/apt/lists/*

ARG DBT_VERSION=1.9.2
RUN pip install --no-cache-dir \
    "dbt-core==${DBT_VERSION}" \
    "dbt-bigquery==${DBT_VERSION}"

COPY dbt_project.yml packages.yml package-lock.yml selectors.yml /app/dbt/
COPY models/       /app/dbt/models/
COPY macros/       /app/dbt/macros/
COPY tests/        /app/dbt/tests/
COPY seeds/        /app/dbt/seeds/
COPY snapshots/    /app/dbt/snapshots/

COPY profiles/ /app/profiles/

COPY entrypoint.sh /app/entrypoint.sh

RUN chmod +x /app/entrypoint.sh \
  && dbt --version \
  && cd /app/dbt && dbt deps

ENTRYPOINT ["/app/entrypoint.sh"]
