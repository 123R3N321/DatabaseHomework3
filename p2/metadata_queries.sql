-- Metadata queries for the flights schema (PostgreSQL)
-- Run after loading p2/flights.sql (and optionally p2_alter_fks.sql) into the current database.
-- Adjust :schema if you use a schema other than public.

-- ---------------------------------------------------------------------------
-- (a) Tables that have at least two outgoing foreign keys referencing
--     distinct referenced tables.
-- ---------------------------------------------------------------------------

SELECT
    c.relname AS table_name,
    COUNT(DISTINCT conf.confrelid) AS distinct_referenced_tables,
    COUNT(*)                    AS foreign_key_constraints
FROM pg_constraint AS con
JOIN pg_class AS c
  ON c.oid = con.conrelid
JOIN pg_namespace AS n
  ON n.oid = c.relnamespace
JOIN pg_class AS conf
  ON conf.oid = con.confrelid
WHERE con.contype = 'f'
  AND n.nspname = current_schema()
GROUP BY c.relname
HAVING COUNT(DISTINCT conf.confrelid) >= 2
ORDER BY c.relname;

-- Note: With only p2/flights.sql (no FKs), this returns no rows.
-- After p2_alter_fks.sql, expect e.g. Flight (FlightService, Aircraft),
-- Booking (Passenger, Flight).


-- ---------------------------------------------------------------------------
-- (b) All columns configured as date / time / timestamp types.
-- ---------------------------------------------------------------------------

SELECT
    table_schema,
    table_name,
    column_name,
    data_type,
    udt_name
FROM information_schema.columns
WHERE table_schema = current_schema()
  AND data_type IN (
      'date',
      'timestamp without time zone',
      'timestamp with time zone',
      'time without time zone',
      'time with time zone'
  )
ORDER BY table_name, ordinal_position;

-- Optional: include INTERVAL if you treat it as temporal metadata:
-- AND data_type = 'interval'


-- ---------------------------------------------------------------------------
-- (c) For each attribute of Flight, count distinct values in the current DB.
-- ---------------------------------------------------------------------------

SELECT 'flight_number'  AS attribute, COUNT(DISTINCT flight_number)  AS distinct_values FROM Flight
UNION ALL
SELECT 'departure_date', COUNT(DISTINCT departure_date) FROM Flight
UNION ALL
SELECT 'plane_type',     COUNT(DISTINCT plane_type)     FROM Flight
ORDER BY attribute;


-- ---------------------------------------------------------------------------
-- (d) Tables whose primary key is composite (more than one column).
-- ---------------------------------------------------------------------------

SELECT
    n.nspname   AS table_schema,
    c.relname   AS table_name,
    con.conname AS constraint_name,
    array_length(con.conkey, 1) AS pk_column_count
FROM pg_constraint AS con
JOIN pg_class AS c
  ON c.oid = con.conrelid
JOIN pg_namespace AS n
  ON n.oid = c.relnamespace
WHERE con.contype = 'p'
  AND n.nspname = current_schema()
  AND array_length(con.conkey, 1) > 1
ORDER BY c.relname;

-- Expected on base flights.sql: Flight, Booking.


-- ---------------------------------------------------------------------------
-- (e) All attributes (columns) whose name contains the substring "name"
--     (case-insensitive).
-- ---------------------------------------------------------------------------

SELECT
    table_schema,
    table_name,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = current_schema()
  AND column_name ILIKE '%name%'
ORDER BY table_name, ordinal_position;

-- Expected: Airport.name, FlightService.airline_name, Passenger.passenger_name.
