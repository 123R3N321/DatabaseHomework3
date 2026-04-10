## CS 6083 – Problem Set 2, Problem 2

Airline Flights & Booking database tasks implemented in PostgreSQL.

### Files
- `p2/flights.sql`: creates the base schema (`Airport`, `Aircraft`, `FlightService`, `Flight`, `Passenger`, `Booking`) and inserts sample data.
- `p2_alter_fks.sql`: adds foreign key constraints on top of the schema from `flights.sql`.
- `p2_er_model.md`: ER description, relationships, cardinalities, and participation details.
- `p2_views.sql`: defines:
  - `FlightOccupancy` view and the queries for part (c).
  - `AirportBasic` view and operations/justifications for part (d).

### Prerequisites
- PostgreSQL installed and accessible via `psql`.
- Run commands from the project root: `/home/ren/projects/databaseStuff`.

### Creating and loading the database

In `psql`, create a database (e.g., `flights_db`) and connect:

```sql
CREATE DATABASE flights_db;
\c flights_db
```

Load the base schema and data:

```sql
\i p2/flights.sql
```

Add foreign keys:

```sql
\i p2_alter_fks.sql
```

### Views and queries (parts c and d)

Create the views and run the queries:

```sql
\i p2_views.sql
```

This will:
- Create the `FlightOccupancy` view.
- Run:
  - (c.1) Query for the single most-booked flight.
  - (c.2) Query for total arriving passengers per airport on `2025-12-31`.
  - (c.3) Query listing flights that are more than 90% full.
- Create the `AirportBasic` view.
- Execute the delete in (d.2) and the aggregation in (d.4), while including comments and explanations for (d.1) and (d.3).

You can re-run `p2/flights.sql` in a fresh database if you want to restore the original `Airport` contents before running the `AirportBasic` examples.

