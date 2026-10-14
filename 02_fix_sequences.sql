-- =====================================================================
-- 02_fix_sequences.sql
-- RUN THIS AFTER ALL 8 CSV FILES ARE IMPORTED.
--
-- Why: the CSV files already contain the ID values (1, 2, 3 ...).
-- Importing them does NOT move the auto-number counters (sequences).
-- Without this script, the next normal INSERT would try to use ID 1
-- again and fail with "duplicate key value violates unique constraint".
-- This script moves every counter to the highest existing ID.
-- Safe to run more than once.
-- =====================================================================
SET search_path TO college;

SELECT setval(pg_get_serial_sequence('college.department', 'dept_id'),       (SELECT COALESCE(MAX(dept_id), 1)       FROM department));
SELECT setval(pg_get_serial_sequence('college.student',    'student_id'),    (SELECT COALESCE(MAX(student_id), 1)    FROM student));
SELECT setval(pg_get_serial_sequence('college.faculty',    'faculty_id'),    (SELECT COALESCE(MAX(faculty_id), 1)    FROM faculty));
SELECT setval(pg_get_serial_sequence('college.course',     'course_id'),     (SELECT COALESCE(MAX(course_id), 1)     FROM course));
SELECT setval(pg_get_serial_sequence('college.exam',       'exam_id'),       (SELECT COALESCE(MAX(exam_id), 1)       FROM exam));
SELECT setval(pg_get_serial_sequence('college.result',     'result_id'),     (SELECT COALESCE(MAX(result_id), 1)     FROM result));
SELECT setval(pg_get_serial_sequence('college.enrollment', 'enrollment_id'), (SELECT COALESCE(MAX(enrollment_id), 1) FROM enrollment));
SELECT setval(pg_get_serial_sequence('college.attendance', 'attendance_id'), (SELECT COALESCE(MAX(attendance_id), 1) FROM attendance));
