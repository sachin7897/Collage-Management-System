-- =====================================================================
-- 03_verify_import.sql
-- Run AFTER importing the CSV files and running 02_fix_sequences.sql.
-- Compare "total_rows" with the number of data rows in each CSV file
-- (rows in the CSV minus the 1 header line).
-- =====================================================================
SET search_path TO college;

-- Check 1: row count of every table
SELECT 'department' AS table_name, COUNT(*) AS total_rows FROM department
UNION ALL SELECT 'student',    COUNT(*) FROM student
UNION ALL SELECT 'faculty',    COUNT(*) FROM faculty
UNION ALL SELECT 'course',     COUNT(*) FROM course
UNION ALL SELECT 'exam',       COUNT(*) FROM exam
UNION ALL SELECT 'result',     COUNT(*) FROM result
UNION ALL SELECT 'enrollment', COUNT(*) FROM enrollment
UNION ALL SELECT 'attendance', COUNT(*) FROM attendance;

-- Check 2: broken relationships. Every row below must show 0.
SELECT 'students with missing department' AS check_name, COUNT(*) AS problems
FROM student s LEFT JOIN department d ON d.dept_id = s.dept_id WHERE d.dept_id IS NULL
UNION ALL
SELECT 'courses with missing department', COUNT(*)
FROM course c LEFT JOIN department d ON d.dept_id = c.dept_id WHERE d.dept_id IS NULL
UNION ALL
SELECT 'results with missing student', COUNT(*)
FROM result r LEFT JOIN student s ON s.student_id = r.student_id WHERE s.student_id IS NULL
UNION ALL
SELECT 'attendance with missing enrollment', COUNT(*)
FROM attendance a LEFT JOIN enrollment e ON e.enrollment_id = a.enrollment_id WHERE e.enrollment_id IS NULL
UNION ALL
SELECT 'results without a grade', COUNT(*) FROM result WHERE grade IS NULL;

-- Check 3: the sequences are ready (next ID must be higher than the biggest ID)
SELECT 'student next id' AS item, last_value + 1 AS next_value FROM student_student_id_seq;
