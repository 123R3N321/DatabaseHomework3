## Problem 2(b) – ER Diagram (Airline Flights and Booking)

This ER-style diagram matches the narrative in `p2_er_model.md` and the schema in `p2/flights.sql` plus `p2_alter_fks.sql`.

```mermaid
erDiagram
    Airport ||--o{ FlightService : has_origin
    Airport ||--o{ FlightService : has_destination

    Aircraft ||--o{ Flight : operates_as_type

    FlightService ||--o{ Flight : schedules_instances

    Passenger ||--o{ Booking : makes
    Flight    ||--o{ Booking : is_booked_on

    Airport {
        VARCHAR(3) airport_code PK
        VARCHAR name
        VARCHAR city
        VARCHAR country
    }

    Aircraft {
        VARCHAR plane_type PK
        INT capacity
    }

    FlightService {
        VARCHAR flight_number PK
        VARCHAR airline_name
        VARCHAR origin_code FK
        VARCHAR dest_code FK
        TIME departure_time
        INTERVAL duration
    }

    Flight {
        VARCHAR flight_number FK
        DATE departure_date
        VARCHAR plane_type FK
    }

    Passenger {
        INT pid PK
        VARCHAR passenger_name
    }

    Booking {
        INT pid FK
        VARCHAR flight_number FK
        DATE departure_date FK
        INT seat_number
    }
```

Use this as the ER “drawing” for Problem 2(b); it reflects the entities, primary keys, and relationships described in the assignment and implemented in the SQL files.

