## Project Structure Overview

This project contains all files needed to solve CS 6083 Spring 2026 Problem Set 2 (Problems 1–3) using PostgreSQL.

### Top-level files

- `instruction.pdf` / `instruction.md`  
  Assignment handout describing Problems 1–3 and all subparts.

- `p1_schema.sql`  
  DDL for Problem 1 (Machine Learning Hackathon) schema: participants, teams, challenges, rounds, submissions, judges, evaluates, leaderboard, and `EliteParticipant`.

- `p1_load.sql`  
  Uses `\copy` to bulk-load CSV data from `p1/*.csv` into the Problem 1 tables.

- `p1_queries.sql`  
  SQL solutions for Problem 1(b), queries (i)–(vii).

- `p1_relational_algebra.md`  
  Relational algebra expressions for Problem 1(c), queries (iii)–(vi).

- `p1_updates.sql`  
  Implements Problem 1(d): loads `_upd` CSV files, recomputes `Leaderboard`, and populates `EliteParticipant`.

- `p1_triggers.sql`  
  Functions and triggers for Problem 1(e): automatic leaderboard refresh and elite-participant maintenance on inserts/updates.

- `p1_README.md`  
  How to create the ML Hackathon database, load data, run queries, apply updates, and use triggers.

- `p2_alter_fks.sql`  
  Adds foreign-key constraints to the flights schema defined in `p2/flights.sql` (Problem 2(a)).

- `p2_er_model.md`  
  Textual ER explanation for the Airline Flights & Booking database: entities, relationships, cardinalities, participation.

- `p2_er_diagram.md`  
  Mermaid ER diagram for Problem 2(b).

- `p2_views.sql`  
  Defines the `FlightOccupancy` view and implements Problem 2(c) queries, plus the `AirportBasic` view and discussion/queries for Problem 2(d).

- `p2_README.md`  
  Instructions for creating the flights database, loading `p2/flights.sql`, applying foreign keys, and running the Problem 2 views/queries.

- `p3_er_and_schema.md`  
  ER model and relational schema design for the Costco-style warehouse inventory and membership system (Problem 3(a),(b)).

- `p3_er_diagram.md`  
  Mermaid ER diagram corresponding to `p3_er_and_schema.md`.

- `p3_schema_and_data.sql`  
  Full DDL and sample data for Problem 3 tables: warehouses, products, inventory batches, membership plans, members, memberships, transactions, and transaction items.

- `p3_queries.sql`  
  SQL solutions for Problem 3(c): Executive vs Basic savings, out-of-stock `Kirkland Paper Towels`, sold-out grocery items, and high-spend multi-warehouse members.

- `p3_README.md`  
  Instructions for creating a `warehouse_db`, loading `p3_schema_and_data.sql`, and running `p3_queries.sql`, with key modeling assumptions.

- `p3_log.txt`  
  Example log file capturing the output of Problem 3 queries (as required by the assignment).

- `run_p1_end_to_end.sh`  
  Bash script to drop/recreate the ML Hackathon database, load schema/data, run queries, create triggers, apply updates, and print final `Leaderboard` and `EliteParticipant`.

- `run_p2.sh`  
  Bash script to drop/recreate the flights database, load `p2/flights.sql`, apply foreign keys, and run the Problem 2 views/queries.

- `run_p3.sh`  
  Bash script to drop/recreate the warehouse database, load Problem 3 schema/data, and run all Problem 3 queries.

### Subdirectories

- `p1/` – Machine Learning Hackathon CSV data  
  - `participants.csv`, `participant_upd.csv`  
  - `team.csv`, `team_upd.csv`  
  - `team_member.csv`, `team_member_upd.csv`  
  - `challenge.csv`, `round.csv`, `submission.csv`, `submission_upd.csv`  
  - `judge.csv`, `evaluates.csv`, `evaluates_upd.csv`  
  - `leaderboard.csv`  
  These files back the Problem 1 schema and updates.

- `p2/` – Flights schema and data  
  - `flights.sql`  
    Contains the base Postgres DDL and inserts for `Airport`, `Aircraft`, `FlightService`, `Flight`, `Passenger`, and `Booking` used in Problem 2.

- `flights_app/` – Problem Set #3 Rails UI (see course handout `instruction2.md`)  
  - Rails 8 app: search flights by route and date range, list results, show capacity and available seats.  
  - Uses PostgreSQL database `flights_db` (load `p2/flights.sql` first). See [flights_app/README.md](flights_app/README.md).

### How the pieces fit together

- **Problem 1** (Hackathon DB): `p1/*.csv` → `p1_schema.sql` + `p1_load.sql` → `p1_queries.sql` + `p1_relational_algebra.md` → updates/triggers via `p1_updates.sql` and `p1_triggers.sql` → orchestrated by `run_p1_end_to_end.sh` and documented in `p1_README.md`.

- **Problem 2** (Flights & Booking): `p2/flights.sql` → `p2_alter_fks.sql` (FKs) → `p2_views.sql` (views and queries) → optional script `run_p2.sh` → described in `p2_er_model.md`, `p2_er_diagram.md`, and `p2_README.md`. **Problem Set #3** adds the browser UI in `flights_app/` on the same schema/data.

- **Problem 3** (Warehouse & Membership): design in `p3_er_and_schema.md` + `p3_er_diagram.md` → implementation/data in `p3_schema_and_data.sql` → analytical queries in `p3_queries.sql` → run instructions in `p3_README.md` and helper script `run_p3.sh`, with resulting output captured in `p3_log.txt`.

