-- Problem 2(a) – Schema with primary and foreign keys (PostgreSQL)
-- This file combines the base tables from p2/flights.sql with
-- explicit FOREIGN KEY constraints answering part (a).

DROP TABLE IF EXISTS Booking CASCADE;
DROP TABLE IF EXISTS Passenger CASCADE;
DROP TABLE IF EXISTS Flight CASCADE;
DROP TABLE IF EXISTS FlightService CASCADE;
DROP TABLE IF EXISTS Aircraft CASCADE;
DROP TABLE IF EXISTS Airport CASCADE;

CREATE TABLE Airport (
    airport_code VARCHAR(3) PRIMARY KEY,
    name         VARCHAR(100) NOT NULL,
    city         VARCHAR(50)  NOT NULL,
    country      VARCHAR(50)  NOT NULL
);

CREATE TABLE Aircraft (
    plane_type VARCHAR(30) PRIMARY KEY,
    capacity   INT NOT NULL
);

CREATE TABLE FlightService (
    flight_number VARCHAR(10) PRIMARY KEY,
    airline_name  VARCHAR(50) NOT NULL,
    origin_code   VARCHAR(3)  NOT NULL,
    dest_code     VARCHAR(3)  NOT NULL,
    departure_time TIME       NOT NULL,
    duration       INTERVAL   NOT NULL,
    CONSTRAINT flightservice_origin_fk
        FOREIGN KEY (origin_code)
        REFERENCES Airport(airport_code),
    CONSTRAINT flightservice_dest_fk
        FOREIGN KEY (dest_code)
        REFERENCES Airport(airport_code)
);

CREATE TABLE Flight (
    flight_number  VARCHAR(10) NOT NULL,
    departure_date DATE        NOT NULL,
    plane_type     VARCHAR(30) NOT NULL,
    PRIMARY KEY (flight_number, departure_date),
    CONSTRAINT flight_service_fk
        FOREIGN KEY (flight_number)
        REFERENCES FlightService(flight_number),
    CONSTRAINT flight_aircraft_fk
        FOREIGN KEY (plane_type)
        REFERENCES Aircraft(plane_type)
);

CREATE TABLE Passenger (
    pid            INT PRIMARY KEY,
    passenger_name VARCHAR(100) NOT NULL
);

CREATE TABLE Booking (
    pid            INT         NOT NULL,
    flight_number  VARCHAR(10) NOT NULL,
    departure_date DATE        NOT NULL,
    seat_number    INT         NOT NULL,
    PRIMARY KEY (pid, flight_number, departure_date),
    CONSTRAINT booking_passenger_fk
        FOREIGN KEY (pid)
        REFERENCES Passenger(pid),
    CONSTRAINT booking_flight_fk
        FOREIGN KEY (flight_number, departure_date)
        REFERENCES Flight(flight_number, departure_date)
);

