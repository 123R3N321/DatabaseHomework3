-- Problem 2(a): Add foreign keys to flights schema
-- Assumes base tables are created and populated by p2/flights.sql.

ALTER TABLE FlightService
    ADD CONSTRAINT flightservice_origin_fk
        FOREIGN KEY (origin_code)
        REFERENCES Airport(airport_code),
    ADD CONSTRAINT flightservice_dest_fk
        FOREIGN KEY (dest_code)
        REFERENCES Airport(airport_code);

ALTER TABLE Flight
    ADD CONSTRAINT flight_service_fk
        FOREIGN KEY (flight_number)
        REFERENCES FlightService(flight_number),
    ADD CONSTRAINT flight_aircraft_fk
        FOREIGN KEY (plane_type)
        REFERENCES Aircraft(plane_type);

ALTER TABLE Booking
    ADD CONSTRAINT booking_passenger_fk
        FOREIGN KEY (pid)
        REFERENCES Passenger(pid),
    ADD CONSTRAINT booking_flight_fk
        FOREIGN KEY (flight_number, departure_date)
        REFERENCES Flight(flight_number, departure_date);

