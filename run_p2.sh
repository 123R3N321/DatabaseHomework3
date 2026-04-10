#!/usr/bin/env bash

# Simple end-to-end runner for Problem 2 (Airline Flights & Booking).
# Usage (from project root):  bash run_p2.sh

set -e

DB_NAME="flights_db"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Dropping and recreating database: ${DB_NAME}"
psql -d postgres -v ON_ERROR_STOP=1 <<SQL
DROP DATABASE IF EXISTS ${DB_NAME};
CREATE DATABASE ${DB_NAME};
SQL

echo "Loading flights schema and data..."
psql -d "${DB_NAME}" -v ON_ERROR_STOP=1 <<SQL
\i '${ROOT_DIR}/p2/flights.sql'
SQL

echo "Adding foreign keys..."
psql -d "${DB_NAME}" -v ON_ERROR_STOP=1 <<SQL
\i '${ROOT_DIR}/p2_alter_fks.sql'
SQL

echo "Creating views and running Problem 2 queries..."
psql -d "${DB_NAME}" -v ON_ERROR_STOP=1 <<SQL
\i '${ROOT_DIR}/p2_views.sql'
SQL

echo "All done. You can now inspect results in ${DB_NAME}."

