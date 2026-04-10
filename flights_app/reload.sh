   psql -d postgres -c "DROP DATABASE IF EXISTS flights_db;"
   psql -d postgres -c "CREATE DATABASE flights_db;"
   psql -d flights_db -f ../p2/flights.sql
   bin/rails server

