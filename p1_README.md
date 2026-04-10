## CS 6083 – Problem Set 2, Problem 1

Machine Learning Hackathon database implemented in PostgreSQL.

### Files
- `p1_schema.sql`: creates all tables (`Participant`, `Team`, `TeamMember`, `Challenge`, `Round`, `Submission`, `Judge`, `Evaluates`, `Leaderboard`, `EliteParticipant`) with keys and constraints.
- `p1_load.sql`: bulk-loads initial CSV data from `p1/*.csv` into the schema using `COPY`.
- `p1_queries.sql`: answers Problem 1(b), queries (i)–(vii).
- `p1_relational_algebra.md`: relational algebra expressions for queries (iii)–(vi).
- `p1_updates.sql`: processes `*_upd.csv`, refreshes `Leaderboard`, and populates `EliteParticipant` as in Problem 1(d).
- `p1_triggers.sql`: defines helper functions and triggers to automatically maintain `Leaderboard` and `EliteParticipant` as in Problem 1(e).

### Prerequisites
- PostgreSQL installed and accessible via `psql`.
- The working directory `/home/ren/projects/databaseStuff` (or adjust paths in the `COPY` commands if different).

### Setup and Data Load
In `psql`, run:

```sql
CREATE DATABASE ml_hackathon;
\c ml_hackathon

\i p1_schema.sql;
\i p1_load.sql;
```

### Queries (Part b)
To run and inspect all queries (i)–(vii):

```sql
\i p1_queries.sql;
```

Each query is separated by comments indicating which sub-question it answers.

### Relational Algebra (Part c)
Open `p1_relational_algebra.md` to see the relational algebra formulations corresponding to queries (iii)–(vi).

### Updates (Part d)
To insert the `*_upd.csv` data, recompute the leaderboard, and populate `EliteParticipant`:

```sql
\i p1_updates.sql;
```

You can then check:

```sql
SELECT * FROM Leaderboard ORDER BY challenge_id, rank;
SELECT * FROM EliteParticipant ORDER BY pid;
```

### Triggers (Part e)
To create the helper functions and triggers:

```sql
\i p1_triggers.sql;
```

After this:
- Any `INSERT` into `Evaluates` will automatically recompute the corresponding challenge’s leaderboard.
- Any `INSERT` or `UPDATE` on `Leaderboard` will automatically recompute `EliteParticipant`.

Suggested demo sequence:

```sql
-- After initial load:
\i p1_triggers.sql;
\i p1_updates.sql;

SELECT * FROM Leaderboard ORDER BY challenge_id, rank;
SELECT * FROM EliteParticipant ORDER BY pid;
```

