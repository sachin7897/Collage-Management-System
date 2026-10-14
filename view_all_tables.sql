-- =====================================================
-- View all table data one by one (College Management System)
-- pgAdmin tip: sirf ek query select (highlight) karo aur F5 dabao,
-- kyunki pgAdmin multiple SELECT chalane par sirf last ka result dikhata hai.
-- =====================================================

SET search_path TO college;

-- 1. Department
SELECT * FROM department ORDER BY dept_id;

-- 2. Student
SELECT * FROM student ORDER BY student_id;

-- 3. Faculty
SELECT * FROM faculty ORDER BY faculty_id;

-- 4. Course
SELECT * FROM course ORDER BY course_id;

-- 5. Enrollment
SELECT * FROM enrollment ORDER BY enrollment_id;

-- 6. Attendance
SELECT * FROM attendance ORDER BY attendance_id;

-- 7. Exam
SELECT * FROM exam ORDER BY exam_id;

-- 8. Result
SELECT * FROM result ORDER BY result_id;

-- 9. View: Student Report
SELECT * FROM v_student_report;

-- 10. View: Attendance Percentage
SELECT * FROM v_attendance_pct;

-- =====================================================
-- Bonus: Row count of every table in one result
-- =====================================================
SELECT 'department' AS table_name, COUNT(*) AS total_rows FROM department
UNION ALL SELECT 'student',    COUNT(*) FROM student
UNION ALL SELECT 'faculty',    COUNT(*) FROM faculty
UNION ALL SELECT 'course',     COUNT(*) FROM course
UNION ALL SELECT 'enrollment', COUNT(*) FROM enrollment
UNION ALL SELECT 'attendance', COUNT(*) FROM attendance
UNION ALL SELECT 'exam',       COUNT(*) FROM exam
UNION ALL SELECT 'result',     COUNT(*) FROM result;
