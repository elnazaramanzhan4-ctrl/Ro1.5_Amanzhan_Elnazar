-- 1. Среда выполнения
CREATE SCHEMA IF NOT EXISTS airline_schema;
SET search_path TO airline_schema, public;

-- 2. География
CREATE TABLE IF NOT EXISTS countries (
    id SERIAL PRIMARY KEY,
    name VARCHAR(60) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS cities (
    id SERIAL PRIMARY KEY,
    name VARCHAR(60) NOT NULL
);

CREATE TABLE IF NOT EXISTS airport_list (
    id SERIAL PRIMARY KEY,
    code CHAR(3) UNIQUE NOT NULL,
    name VARCHAR(120) NOT NULL,
    city_id INT NOT NULL REFERENCES cities(id),
    country_id INT NOT NULL REFERENCES countries(id)
);

-- 3. Авиапарк и Маршруты
CREATE TABLE IF NOT EXISTS flight_routes (
    id SERIAL PRIMARY KEY,
    flight_code VARCHAR(25) UNIQUE NOT NULL,
    departure_airport INT NOT NULL REFERENCES airport_list(id),
    arrival_airport INT NOT NULL REFERENCES airport_list(id)
);

CREATE TABLE IF NOT EXISTS plane_models (
    id SERIAL PRIMARY KEY,
    brand VARCHAR(60) NOT NULL,
    model VARCHAR(60) NOT NULL,
    seats_count INT CHECK (seats_count > 0)
);

CREATE TABLE IF NOT EXISTS planes (
    id SERIAL PRIMARY KEY,
    model_id INT NOT NULL REFERENCES plane_models(id),
    reg_number VARCHAR(20) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS seat_map (
    id SERIAL PRIMARY KEY,
    plane_id INT NOT NULL REFERENCES planes(id),
    seat_no VARCHAR(10) NOT NULL,
    class_type VARCHAR(20) CHECK (class_type IN ('Economy','Business')),
    UNIQUE(plane_id, seat_no)
);

-- 4. Расписание и Персонал
CREATE TABLE IF NOT EXISTS flight_schedule (
    id SERIAL PRIMARY KEY,
    route_id INT NOT NULL REFERENCES flight_routes(id),
    plane_id INT NOT NULL REFERENCES planes(id),
    dep_time TIMESTAMP NOT NULL,
    arr_time TIMESTAMP NOT NULL,
    status VARCHAR(20) DEFAULT 'Scheduled'
        CHECK (status IN ('Scheduled','Departed','Arrived','Cancelled','Delayed')),
    CHECK (arr_time > dep_time)
);

CREATE TABLE IF NOT EXISTS job_roles (
    id SERIAL PRIMARY KEY,
    role_name VARCHAR(40) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS staff (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    role_id INT NOT NULL REFERENCES job_roles(id),
    phone_number VARCHAR(20),
    email VARCHAR(100),
    iin BIGINT UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS crew_assignments (
    flight_id INT REFERENCES flight_schedule(id),
    staff_id INT REFERENCES staff(id),
    duty VARCHAR(40),
    PRIMARY KEY (flight_id, staff_id)
);

-- 5. Клиенты, Билеты и Посадка
CREATE TABLE IF NOT EXISTS clients (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    passport VARCHAR(25) UNIQUE NOT NULL,
    email VARCHAR(60) UNIQUE
);

CREATE TABLE IF NOT EXISTS reservations (
    id SERIAL PRIMARY KEY,
    client_id INT NOT NULL REFERENCES clients(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_price NUMERIC(10,2) DEFAULT 0 CHECK (total_price >= 0)
);

CREATE TABLE IF NOT EXISTS tickets (
    id SERIAL PRIMARY KEY,
    reservation_id INT NOT NULL REFERENCES reservations(id),
    flight_id INT NOT NULL REFERENCES flight_schedule(id),
    price NUMERIC(10,2) CHECK (price >= 0)
);

CREATE TABLE IF NOT EXISTS boarding_cards (
    id SERIAL PRIMARY KEY,
    ticket_id INT UNIQUE NOT NULL REFERENCES tickets(id),
    seat_id INT NOT NULL REFERENCES seat_map(id)
);

---------------------------------------------------------
-- ЗАПОЛНЕНИЕ ДАННЫМИ (с защитой от дублей)
---------------------------------------------------------

INSERT INTO countries (name) VALUES ('USA') ON CONFLICT DO NOTHING;
INSERT INTO cities (name) VALUES ('New York'), ('Los Angeles') ON CONFLICT DO NOTHING;

INSERT INTO airport_list (code, name, city_id, country_id) 
VALUES ('JFK', 'John F Kennedy Airport', 1, 1),
       ('LAX', 'Los Angeles International', 2, 1)
ON CONFLICT DO NOTHING;

INSERT INTO flight_routes (flight_code, departure_airport, arrival_airport) 
VALUES ('AA101', 1, 2)
ON CONFLICT DO NOTHING;

INSERT INTO plane_models (brand, model, seats_count) 
VALUES ('Boeing', '737', 180)
ON CONFLICT DO NOTHING;

INSERT INTO planes (model_id, reg_number) 
VALUES (1, 'N12345')
ON CONFLICT DO NOTHING;

INSERT INTO seat_map (plane_id, seat_no, class_type) 
VALUES (1, '1A', 'Business'), (1, '10B', 'Economy')
ON CONFLICT (plane_id, seat_no) DO NOTHING;

INSERT INTO flight_schedule (route_id, plane_id, dep_time, arr_time) 
VALUES (1, 1, '2026-05-01 10:00:00', '2026-05-01 14:00:00')
ON CONFLICT DO NOTHING;

INSERT INTO job_roles (role_name) VALUES ('Pilot') ON CONFLICT DO NOTHING;

INSERT INTO staff (first_name, last_name, role_id, iin) 
VALUES ('John', 'Doe', 1, 900101123456)
ON CONFLICT DO NOTHING;

INSERT INTO crew_assignments (flight_id, staff_id, duty) 
VALUES (1, 1, 'Captain')
ON CONFLICT DO NOTHING;

INSERT INTO clients (first_name, last_name, passport, email) 
VALUES ('Alice', 'Smith', 'AB123456', 'alice@mail.com')
ON CONFLICT DO NOTHING;

INSERT INTO reservations (client_id, total_price) 
VALUES (1, 500.00)
ON CONFLICT DO NOTHING;

INSERT INTO tickets (reservation_id, flight_id, price) 
VALUES (1, 1, 500.00)
ON CONFLICT DO NOTHING;

INSERT INTO boarding_cards (ticket_id, seat_id) 
VALUES (1, 1)
ON CONFLICT DO NOTHING;