-- =========================
-- RESET
-- =========================

DROP SCHEMA IF EXISTS course_schema CASCADE;

CREATE SCHEMA course_schema;

SET search_path TO course_schema;

-- =========================
-- TABLES
-- =========================

CREATE TABLE students (
    student_id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE instructors (
    instructor_id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL
);

CREATE TABLE courses (
    course_id SERIAL PRIMARY KEY,
    title VARCHAR(100),
    instructor_id INT REFERENCES instructors(instructor_id)
);

CREATE TABLE enrollments (
    enrollment_id SERIAL PRIMARY KEY,
    student_id INT REFERENCES students(student_id) ON DELETE CASCADE,
    course_id INT REFERENCES courses(course_id) ON DELETE CASCADE
);

-- =========================
-- DATA
-- =========================

INSERT INTO students(full_name,email) VALUES
('John','john@mail.com'),
('Emma','emma@mail.com');

INSERT INTO instructors(full_name) VALUES
('Teacher A'),
('Teacher B');

INSERT INTO courses(title,instructor_id) VALUES
('Python',1),
('SQL',2);

INSERT INTO enrollments(student_id,course_id) VALUES
(1,1),
(2,2);

-- =========================
-- TEST
-- =========================

SELECT * FROM students;