-- =====================================================================
-- 01_schema_only.sql
-- College Management System (PostgreSQL) - STRUCTURE ONLY, NO DATA
--
-- Creates: schema "college", 8 tables, indexes, grade trigger,
--          stored procedure, 2 views.
-- It does NOT insert any rows. Data comes from the CSV files (Step 5).
--
-- HOW TO RUN: open Query Tool on the empty database "college_db",
--             paste this whole file, press F5 (do not select any part).
-- RUN IT ONLY ONCE. If you need to start over, drop the schema first
-- (see README, Troubleshooting).
-- =====================================================================

CREATE SCHEMA college;
SET search_path TO college;

-- ---------- 1. TABLES ----------
CREATE TABLE department (
    dept_id     SERIAL PRIMARY KEY,
    dept_name   VARCHAR(80) NOT NULL UNIQUE,
    hod_name    VARCHAR(80)
);

CREATE TABLE student (
    student_id  SERIAL PRIMARY KEY,
    first_name  VARCHAR(50) NOT NULL,
    last_name   VARCHAR(50) NOT NULL,
    email       VARCHAR(100) NOT NULL UNIQUE,
    phone       VARCHAR(15),
    dob         DATE NOT NULL,
    gender      CHAR(1) CHECK (gender IN ('M','F','O')),
    admission_year INT NOT NULL CHECK (admission_year >= 2000),
    dept_id     INT NOT NULL REFERENCES department(dept_id)
                ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE faculty (
    faculty_id  SERIAL PRIMARY KEY,
    first_name  VARCHAR(50) NOT NULL,
    last_name   VARCHAR(50) NOT NULL,
    email       VARCHAR(100) NOT NULL UNIQUE,
    designation VARCHAR(50),
    salary      NUMERIC(10,2) CHECK (salary > 0),
    dept_id     INT NOT NULL REFERENCES department(dept_id)
                ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE course (
    course_id   SERIAL PRIMARY KEY,
    course_code VARCHAR(10) NOT NULL UNIQUE,
    course_name VARCHAR(100) NOT NULL,
    credits     INT NOT NULL CHECK (credits BETWEEN 1 AND 6),
    semester    INT NOT NULL CHECK (semester BETWEEN 1 AND 8),
    dept_id     INT NOT NULL REFERENCES department(dept_id),
    faculty_id  INT REFERENCES faculty(faculty_id) ON DELETE SET NULL
);

CREATE TABLE enrollment (
    enrollment_id SERIAL PRIMARY KEY,
    student_id  INT NOT NULL REFERENCES student(student_id) ON DELETE CASCADE,
    course_id   INT NOT NULL REFERENCES course(course_id) ON DELETE CASCADE,
    enroll_date DATE NOT NULL DEFAULT CURRENT_DATE,
    UNIQUE (student_id, course_id)
);

CREATE TABLE attendance (
    attendance_id SERIAL PRIMARY KEY,
    enrollment_id INT NOT NULL REFERENCES enrollment(enrollment_id) ON DELETE CASCADE,
    class_date  DATE NOT NULL,
    status      VARCHAR(7) NOT NULL CHECK (status IN ('Present','Absent')),
    UNIQUE (enrollment_id, class_date)
);

CREATE TABLE exam (
    exam_id     SERIAL PRIMARY KEY,
    course_id   INT NOT NULL REFERENCES course(course_id) ON DELETE CASCADE,
    exam_type   VARCHAR(20) NOT NULL CHECK (exam_type IN ('Midterm','Final','Internal')),
    exam_date   DATE NOT NULL,
    max_marks   INT NOT NULL DEFAULT 100 CHECK (max_marks > 0)
);

CREATE TABLE result (
    result_id   SERIAL PRIMARY KEY,
    exam_id     INT NOT NULL REFERENCES exam(exam_id) ON DELETE CASCADE,
    student_id  INT NOT NULL REFERENCES student(student_id) ON DELETE CASCADE,
    marks       NUMERIC(5,2) NOT NULL CHECK (marks >= 0),
    grade       CHAR(2),
    UNIQUE (exam_id, student_id)
);

-- ---------- 2. INDEXES ----------
CREATE INDEX idx_student_dept    ON student(dept_id);
CREATE INDEX idx_enroll_student  ON enrollment(student_id);
CREATE INDEX idx_enroll_course   ON enrollment(course_id);
CREATE INDEX idx_attendance_enr  ON attendance(enrollment_id);
CREATE INDEX idx_result_student  ON result(student_id);


-- ---------- 4. TRIGGER: auto grade ----------
CREATE OR REPLACE FUNCTION fn_assign_grade() RETURNS TRIGGER AS $$
DECLARE pct NUMERIC;
BEGIN
    SELECT (NEW.marks / max_marks) * 100 INTO pct FROM exam WHERE exam_id = NEW.exam_id;
    IF pct > 100 THEN RAISE EXCEPTION 'Marks exceed max marks'; END IF;
    NEW.grade := CASE
        WHEN pct >= 90 THEN 'A+' WHEN pct >= 80 THEN 'A'
        WHEN pct >= 70 THEN 'B'  WHEN pct >= 60 THEN 'C'
        WHEN pct >= 50 THEN 'D'  ELSE 'F' END;
    RETURN NEW;
END; $$ LANGUAGE plpgsql;

CREATE TRIGGER trg_assign_grade
BEFORE INSERT OR UPDATE ON result
FOR EACH ROW EXECUTE FUNCTION fn_assign_grade();


-- ---------- 5. STORED PROCEDURE ----------
CREATE OR REPLACE PROCEDURE enroll_student(p_student INT, p_course INT)
LANGUAGE plpgsql AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM enrollment WHERE student_id=p_student AND course_id=p_course) THEN
        RAISE EXCEPTION 'Student % already enrolled in course %', p_student, p_course;
    END IF;
    INSERT INTO enrollment (student_id, course_id) VALUES (p_student, p_course);
END; $$;
-- CALL enroll_student(3, 1);

-- ---------- 6. VIEWS ----------
CREATE VIEW v_attendance_pct AS
SELECT s.student_id, s.first_name || ' ' || s.last_name AS student,
       c.course_code,
       ROUND(100.0 * COUNT(*) FILTER (WHERE a.status='Present') / COUNT(*), 2) AS attendance_pct
FROM attendance a
JOIN enrollment e ON e.enrollment_id = a.enrollment_id
JOIN student s ON s.student_id = e.student_id
JOIN course c ON c.course_id = e.course_id
GROUP BY s.student_id, student, c.course_code;

CREATE VIEW v_student_report AS
SELECT s.student_id, s.first_name || ' ' || s.last_name AS student,
       d.dept_name, c.course_name, r.marks, r.grade
FROM result r
JOIN student s ON s.student_id = r.student_id
JOIN exam x ON x.exam_id = r.exam_id
JOIN course c ON c.course_id = x.course_id
JOIN department d ON d.dept_id = s.dept_id;

