#!/usr/bin/env bash

# Simple end-to-end runner for Problem 1 using default psql settings.
# Usage (from project root):  bash run_p1_end_to_end.sh

set -e

DB_NAME="ml_hackathon"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Dropping and recreating database: ${DB_NAME}"
psql -d postgres -v ON_ERROR_STOP=1 <<SQL
DROP DATABASE IF EXISTS ${DB_NAME};
CREATE DATABASE ${DB_NAME};
SQL

echo "Loading schema and base data..."
psql -d "${DB_NAME}" -v ON_ERROR_STOP=1 <<SQL
\i '${ROOT_DIR}/p1_schema.sql'
\i '${ROOT_DIR}/p1_load.sql'
SQL

echo "Running Problem 1(b) queries..."
psql -d "${DB_NAME}" -v ON_ERROR_STOP=1 <<SQL
\i '${ROOT_DIR}/p1_queries.sql'
SQL

echo "Creating triggers for leaderboard and elite maintenance..."
psql -d "${DB_NAME}" -v ON_ERROR_STOP=1 <<SQL
\i '${ROOT_DIR}/p1_triggers.sql'
SQL

echo "Applying *_upd.csv updates (Problem 1(d))..."
psql -d "${DB_NAME}" -v ON_ERROR_STOP=1 <<SQL
\i '${ROOT_DIR}/p1_updates.sql'
SQL

echo "Final Leaderboard:"
psql -d "${DB_NAME}" -v ON_ERROR_STOP=1 -c \
"SELECT * FROM Leaderboard ORDER BY challenge_id, rank;"

echo "Final EliteParticipant:"
psql -d "${DB_NAME}" -v ON_ERROR_STOP=1 -c \
"SELECT * FROM EliteParticipant ORDER BY pid;"

echo "All done."


