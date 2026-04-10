#!/usr/bin/env bash

# End-to-end runner for Problem 3 (Warehouse Inventory & Membership).
# Usage (from project root):  bash run_p3.sh

set -e

DB_NAME="warehouse_db"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Dropping and recreating database: ${DB_NAME}"
psql -d postgres -v ON_ERROR_STOP=1 <<SQL
DROP DATABASE IF EXISTS ${DB_NAME};
CREATE DATABASE ${DB_NAME};
SQL

echo "Loading Problem 3 schema and sample data..."
psql -d "${DB_NAME}" -v ON_ERROR_STOP=1 <<SQL
\i '${ROOT_DIR}/p3_schema_and_data.sql'
SQL

echo "Running Problem 3 queries..."
psql -d "${DB_NAME}" -v ON_ERROR_STOP=1 <<SQL
\i '${ROOT_DIR}/p3_queries.sql'
SQL

echo "All done. You can now inspect results in database ${DB_NAME}."

