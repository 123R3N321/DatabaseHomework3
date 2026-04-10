# Flights frontend (Qn 1 of PS3, grad db class)
Data from prev homework (`../p2/flights.sql`).
Made with ruby on rails.

## Requirements

- Ruby 3.x and Rails 8.x (see `Gemfile` / `.ruby-version`)
- PostgreSQL
- Bundler (`gem install bundler`)

## db setup / update

0. If you do not have any config problem, simply:
```bash
chmod +x reload
bash reload.sh
```
Otherwise, manually do everything:
1. Create a PostgreSQL database and load the course data (from the parent `databaseStuff` directory):

   ```bash
   psql -d postgres -c "DROP DATABASE IF EXISTS flights_db;"
   psql -d postgres -c "CREATE DATABASE flights_db;"
   psql -d flights_db -f ../p2/flights.sql
   ```

   Optional foreign keys (not required for the UI):

   ```bash
   psql -d flights_db -f ../p2_alter_fks.sql
   ```

2. By default this app uses the **`flights_db`** database in development (see `config/database.yml`). Override with:

   ```bash
   export FLIGHTS_DATABASE_NAME=my_other_db
   ```

## Install and run

From this directory (`flights_app/`):

```bash
bundle config set path 'vendor/bundle'   # optional: local gem path
bundle install
bin/rails server
```

Open [http://localhost:3000](http://localhost:3000).

## HTTP routes

Routes are declared in [`config/routes.rb`](config/routes.rb). The app is **server-rendered HTML** (ERB views), not a JSON API; all successful responses use `text/html` unless you add JSON formats yourself.

| Method | Path | Controller | Purpose |
|--------|------|------------|---------|
| `GET` | `/` | `FlightsController#index` | Search form (root) |
| `POST` | `/flights/search` | `FlightsController#search` | Submit search; re-renders index with results or validation errors |
| `GET` | `/flights/:flight_number/:departure_date` | `FlightsController#show` | Flight detail (`departure_date` must match `YYYY-MM-DD`) |
| `GET` | `/up` | `Rails::HealthController#show` | Load-balancer / health check |

**Named route helpers** (e.g. in views or `bin/rails routes`): `root_path`, `search_flights_path`, `flight_path(flight_number, departure_date)` (e.g. `flight_path("AA101", "2025-12-29")`).

**Search (`POST /flights/search`)** form / body parameters (see [`app/views/flights/index.html.erb`](app/views/flights/index.html.erb)):

| Parameter | Required | Notes |
|-----------|----------|--------|
| `origin` | yes | 3-letter source airport code |
| `destination` | yes | 3-letter destination airport code |
| `start_date` | yes | ISO date (`YYYY-MM-DD`) |
| `end_date` | yes | ISO date (`YYYY-MM-DD`) |

Invalid search input returns **422** with the index template and flash messages. A **422** on an otherwise valid search often means **CSRF / session** (e.g. production over HTTP without `FLIGHTS_HTTP_MODE`); missing or invalid flight on show redirects to `/` with an alert.

## Docker Compose

PostgreSQL and the app run together; the database volume is initialized from `../p2/flights.sql` on **first** start only (empty volume).

From `flights_app/`:

```bash
docker compose up --build
```

Compose loads a local **`.env`** (gitignored) with `RAILS_MASTER_KEY` so you do not need to export anything. On a fresh clone, copy `compose.env.example` to `.env` and paste the value from `config/master.key`.

Open [http://localhost:3000](http://localhost:3000) (or `http://127.0.0.1:3000`). Prefer that over `http://0.0.0.0:3000` in the browser; `0.0.0.0` is only the bind address for the server.

The Compose stack sets **`FLIGHTS_HTTP_MODE=1`**, which turns off `force_ssl` / `assume_ssl` in production. Without that, plain HTTP would use **secure session cookies** that the browser never sends, so **CSRF checks fail** and `POST /flights/search` returns **422** even with a valid form.

When finished:

- **Stop and remove containers + network:** `docker compose down`
- **Also delete Postgres data** (full reset; next `up` reloads `flights.sql`): `docker compose down -v`

If `bundle install` fails writing to `~/.bundle`, use a local bundle home:

```bash
BUNDLE_USER_HOME="$(pwd)/.bundle" bundle install --path vendor/bundle
```

## Features (instruction2.md, PS3 Qn1 features)

- **(a)** Home page: source airport, destination airport, date range, submit.
- **(b)** Lists all matching flights (including full ones): flight number, date, origin, destination, departure time (**GMT time**).
- **(c)** Can Click a flight to see **capacity**, **booked** seat count, and **available** seats.

## Test example

- Origin **JFK**, destination **LAX**, dates including **2025-12-29** through today. (see first two entries in ``FlightService`` table : `AA101`, `AA205` in `flights.sql`).

## File Hierarchy

- `app/models/` – `Flight`, `FlightService`, `Aircraft`, `Booking`, `Passenger`, `Airport`
- `app/controllers/flights_controller.rb` – search and show
- `app/views/flights/` – form, results table, detail page
