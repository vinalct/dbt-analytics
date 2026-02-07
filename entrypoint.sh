#!/usr/bin/env bash
set -euo pipefail

cd "${DBT_PROJECT_DIR:-/app/dbt}"

echo "=== dbt version ==="
dbt --version

echo "=== dbt debug ==="
dbt debug

echo "=== running: dbt $* ==="
exec dbt "$@"
