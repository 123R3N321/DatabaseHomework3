-- Problem 2(c) and (d): Views and queries for Airline Flights & Booking
-- Assumes base tables are created and populated by p2/flights.sql
-- and foreign keys added by p2_alter_fks.sql.

------------------------------------------------------------
-- (c) FlightOccupancy view
------------------------------------------------------------

CREATE OR REPLACE VIEW FlightOccupancy AS
SELECT
    f.flight_number,
    f.departure_date,
    -- arrival_date: date of (departure_date + departure_time + duration)
    (f.departure_date
        + fs.departure_time
        + fs.duration)::date AS arrival_date,
    fs.origin_code,
    fs.dest_code,
    a.capacity,
    COALESCE(COUNT(b.pid), 0) AS total_passengers
FROM Flight AS f
JOIN FlightService AS fs
  ON fs.flight_number = f.flight_number
JOIN Aircraft AS a
  ON a.plane_type = f.plane_type
LEFT JOIN Booking AS b
  ON b.flight_number   = f.flight_number
 AND b.departure_date  = f.departure_date
GROUP BY
    f.flight_number,
    f.departure_date,
    fs.origin_code,
    fs.dest_code,
    fs.departure_time,
    fs.duration,
    a.capacity;


------------------------------------------------------------
-- (c.1) Using only FlightOccupancy:
-- Single flight with highest number of passenger bookings
------------------------------------------------------------

-- Returns exactly one row (ties broken arbitrarily by ORDER BY / LIMIT 1).
SELECT
    flight_number,
    departure_date,
    total_passengers
FROM FlightOccupancy
ORDER BY total_passengers DESC, flight_number, departure_date
LIMIT 1;


------------------------------------------------------------
-- (c.2) For each airport, total passengers scheduled to
--       arrive on '2025-12-31', using only FlightOccupancy
------------------------------------------------------------

SELECT
    dest_code AS airport_code,
    SUM(total_passengers) AS total_arriving_passengers
FROM FlightOccupancy
WHERE arrival_date = DATE '2025-12-31'
GROUP BY dest_code
ORDER BY dest_code;


------------------------------------------------------------
-- (c.3) All flights that are more than 90% full
------------------------------------------------------------

SELECT
    flight_number,
    departure_date,
    origin_code,
    dest_code,
    capacity,
    total_passengers,
    (total_passengers::decimal / capacity) AS load_factor
FROM FlightOccupancy
WHERE capacity > 0
  AND total_passengers > 0.9 * capacity
ORDER BY flight_number, departure_date;


------------------------------------------------------------
-- (d) AirportBasic view and operations
------------------------------------------------------------

CREATE OR REPLACE VIEW AirportBasic AS
SELECT
    airport_code,
    name,
    city
FROM Airport;


-- (d.1) Add DXB via AirportBasic: this will fail because
--       Airport.country is NOT NULL and not provided.
-- Example statement (likely to error in PostgreSQL):
--
-- INSERT INTO AirportBasic (airport_code, name, city)
-- VALUES ('DXB', 'Dubai International', 'Dubai');
--
-- Explanation:
-- - The underlying table Airport has a NOT NULL constraint on country.
-- - This view does not expose country and does not define a default.
-- - Therefore, the insert cannot be expressed correctly using only AirportBasic.


-- (d.2) Delete airports located in the city of 'Chicago' using only the view

DELETE FROM AirportBasic
WHERE city = 'Chicago';

-- Explanation:
-- - AirportBasic is a simple projection of Airport with no joins or computed columns.
-- - Deleting rows from AirportBasic is equivalent to deleting the corresponding rows
--   from Airport where city = 'Chicago', which is valid and view-updatable.


-- (d.3) Delete airports located in the country of 'France'
-- Using only AirportBasic, this cannot be done directly, because
-- the view does not expose the country attribute.
--
-- Explanation:
-- - We would need a predicate on Airport.country, which is not present
--   in AirportBasic.
-- - Any correct DELETE that targets airports in 'France' must reference
--   the base table (or a different view that includes country).


-- (d.4) For each city, list the number of distinct airports in that city

SELECT
    city,
    COUNT(DISTINCT airport_code) AS num_airports
FROM AirportBasic
GROUP BY city
ORDER BY city;

