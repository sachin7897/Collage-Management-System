-- =====================================================================
-- COMPLETE SQL DATA ANALYSIS - College Management System (PostgreSQL)
-- 229 queries | Run college_management.sql FIRST.
-- pgAdmin: ek query highlight karo aur F5 dabao.
-- Sections:
--   1. Basics (Q1-Q55)            4. Window functions, CTE (Q111-Q165)
--   2. Joins, Group, Subquery     5. DDL, DML, Functions, Triggers,
--      (Q56-Q110)                    Admin, JSON, Data quality (Q166-Q229)
-- Jo queries data badalti hain wo BEGIN ... ROLLBACK ke andar hain,
-- isliye BEGIN se ROLLBACK tak poora block highlight karke run karo.
-- =====================================================================
SET search_path TO college;

-- =====================================================================
-- SECTION 1: BASICS (Q1 - Q55)
-- =====================================================================

-- Q1. All students
SELECT * FROM student;
-- Q2. Selected columns
SELECT first_name, last_name, email FROM student;
-- Q3. Alias and concatenation
SELECT student_id, first_name || ' ' || last_name AS full_name FROM student;
-- Q4. Students of department 1
SELECT * FROM student WHERE dept_id = 1;
-- Q5. Female students
SELECT * FROM student WHERE gender = 'F';
-- Q6. AND condition
SELECT * FROM student WHERE dept_id = 1 AND gender = 'M';
-- Q7. OR condition
SELECT * FROM student WHERE dept_id = 2 OR dept_id = 3;
-- Q8. NOT condition
SELECT * FROM student WHERE NOT dept_id = 1;
-- Q9. IN list
SELECT * FROM student WHERE dept_id IN (1, 3);
-- Q10. NOT IN list
SELECT * FROM student WHERE dept_id NOT IN (1, 3);
-- Q11. BETWEEN (date of birth range)
SELECT * FROM student WHERE dob BETWEEN '2005-01-01' AND '2005-12-31';
-- Q12. LIKE - name starts with A
SELECT * FROM student WHERE first_name LIKE 'A%';
-- Q13. ILIKE - case-insensitive contains
SELECT * FROM student WHERE first_name ILIKE '%an%';
-- Q14. LIKE with underscore (second letter 'a')
SELECT * FROM student WHERE first_name LIKE '_a%';
-- Q15. IS NULL
SELECT * FROM student WHERE phone IS NULL;
-- Q16. IS NOT NULL
SELECT * FROM student WHERE phone IS NOT NULL;
-- Q17. ORDER BY ascending
SELECT * FROM student ORDER BY first_name ASC;
-- Q18. ORDER BY descending
SELECT * FROM student ORDER BY dob DESC;
-- Q19. Multi-column ORDER BY
SELECT * FROM student ORDER BY dept_id ASC, first_name DESC;
-- Q20. LIMIT
SELECT * FROM student ORDER BY student_id LIMIT 3;
-- Q21. LIMIT with OFFSET (pagination)
SELECT * FROM student ORDER BY student_id LIMIT 2 OFFSET 2;
-- Q22. DISTINCT
SELECT DISTINCT admission_year FROM student;
-- Q23. DISTINCT ON (oldest student per department)
SELECT DISTINCT ON (dept_id) dept_id, first_name, dob FROM student ORDER BY dept_id, dob;
-- Q24. COUNT all rows
SELECT COUNT(*) AS total_students FROM student;
-- Q25. COUNT DISTINCT
SELECT COUNT(DISTINCT dept_id) AS departments_with_students FROM student;
-- Q26. SUM
SELECT SUM(salary) AS total_salary FROM faculty;
-- Q27. AVG
SELECT ROUND(AVG(salary), 2) AS avg_salary FROM faculty;
-- Q28. MIN and MAX
SELECT MIN(salary) AS min_salary, MAX(salary) AS max_salary FROM faculty;
-- Q29. UPPER
SELECT UPPER(first_name) AS name_upper FROM student;
-- Q30. LOWER
SELECT LOWER(email) AS email_lower FROM student;
-- Q31. LENGTH
SELECT first_name, LENGTH(first_name) AS name_length FROM student;
-- Q32. SUBSTRING
SELECT email, SUBSTRING(email FROM 1 FOR 5) AS first_five FROM student;
-- Q33. SPLIT_PART (email domain)
SELECT email, SPLIT_PART(email, '@', 2) AS domain FROM student;
-- Q34. REPLACE
SELECT email, REPLACE(email, 'college.edu', 'univ.edu') AS new_email FROM student;
-- Q35. CONCAT_WS
SELECT CONCAT_WS(' | ', first_name, last_name, email) AS info FROM student;
-- Q36. LEFT and RIGHT
SELECT first_name, LEFT(first_name, 2) AS first2, RIGHT(first_name, 2) AS last2 FROM student;
-- Q37. INITCAP
SELECT INITCAP('database management system') AS title_case;
-- Q38. LPAD
SELECT course_id, LPAD(course_id::text, 4, '0') AS padded_id FROM course;
-- Q39. AGE
SELECT first_name, dob, AGE(dob) AS age_full, DATE_PART('year', AGE(dob)) AS age_years FROM student;
-- Q40. EXTRACT year
SELECT first_name, EXTRACT(YEAR FROM dob) AS birth_year FROM student;
-- Q41. DATE_PART month
SELECT first_name, DATE_PART('month', dob) AS birth_month FROM student;
-- Q42. TO_CHAR date formatting
SELECT first_name, TO_CHAR(dob, 'DD Mon YYYY') AS formatted_dob FROM student;
-- Q43. Date arithmetic with INTERVAL
SELECT first_name, dob + INTERVAL '18 years' AS turns_18_on FROM student;
-- Q44. DATE_TRUNC
SELECT DATE_TRUNC('week', class_date)::date AS week_start, COUNT(*) AS records
FROM attendance GROUP BY 1 ORDER BY 1;
-- Q45. CASE (gender label)
SELECT first_name,
       CASE gender WHEN 'M' THEN 'Male' WHEN 'F' THEN 'Female' ELSE 'Other' END AS gender_label
FROM student;
-- Q46. CASE (salary band)
SELECT first_name, salary,
       CASE WHEN salary >= 85000 THEN 'High'
            WHEN salary >= 70000 THEN 'Medium'
            ELSE 'Low' END AS salary_band
FROM faculty;
-- Q47. COALESCE
SELECT first_name, COALESCE(phone, 'Not Available') AS phone FROM student;
-- Q48. NULLIF
SELECT first_name, NULLIF(gender, 'O') AS gender_or_null FROM student;
-- Q49. CAST
SELECT salary::int AS salary_int, CAST(salary AS TEXT) AS salary_text FROM faculty;
-- Q50. ROUND, CEIL, FLOOR
SELECT salary, ROUND(salary / 12, 2) AS monthly, CEIL(salary / 12) AS monthly_ceil, FLOOR(salary / 12) AS monthly_floor
FROM faculty;
-- Q51. ABS, MOD, POWER
SELECT ABS(-15) AS abs_val, MOD(17, 5) AS mod_val, POWER(2, 10) AS power_val;
-- Q52. Arithmetic: 10% hike preview
SELECT first_name, salary, salary * 1.10 AS salary_after_hike FROM faculty;
-- Q53. GREATEST and LEAST
SELECT first_name, salary, GREATEST(salary, 70000) AS at_least_70k, LEAST(salary, 80000) AS capped_80k FROM faculty;
-- Q54. generate_series
SELECT generate_series(1, 10) AS n;
-- Q55. VALUES list as a table
SELECT * FROM (VALUES (1, 'Mon'), (2, 'Tue'), (3, 'Wed')) AS t(day_no, day_name);

-- =====================================================================
-- SECTION 2: JOINS, GROUP BY, SUBQUERIES, SET OPERATIONS (Q56 - Q110)
-- =====================================================================

-- ---------- JOINS ----------
-- Q56. INNER JOIN student + department
SELECT s.first_name, d.dept_name FROM student s JOIN department d ON d.dept_id = s.dept_id;
-- Q57. 3-table join: student, enrollment, course
SELECT s.first_name, c.course_name
FROM student s
JOIN enrollment e ON e.student_id = s.student_id
JOIN course c ON c.course_id = e.course_id;
-- Q58. 4-table join with faculty
SELECT s.first_name AS student, c.course_name, f.first_name AS faculty
FROM student s
JOIN enrollment e ON e.student_id = s.student_id
JOIN course c ON c.course_id = e.course_id
JOIN faculty f ON f.faculty_id = c.faculty_id;
-- Q59. LEFT JOIN: enrollments count per student
SELECT s.first_name, COUNT(e.enrollment_id) AS courses
FROM student s LEFT JOIN enrollment e ON e.student_id = s.student_id
GROUP BY s.student_id, s.first_name;
-- Q60. LEFT JOIN anti-join: students without enrollment
SELECT s.* FROM student s LEFT JOIN enrollment e ON e.student_id = s.student_id
WHERE e.enrollment_id IS NULL;
-- Q61. RIGHT JOIN: all courses with faculty
SELECT f.first_name AS faculty, c.course_name
FROM faculty f RIGHT JOIN course c ON c.faculty_id = f.faculty_id;
-- Q62. FULL OUTER JOIN faculty and course
SELECT f.first_name AS faculty, c.course_name
FROM faculty f FULL OUTER JOIN course c ON c.faculty_id = f.faculty_id;
-- Q63. CROSS JOIN: all student-course combinations
SELECT s.first_name, c.course_code FROM student s CROSS JOIN course c ORDER BY 1, 2;
-- Q64. SELF JOIN: classmates in same department
SELECT a.first_name AS student1, b.first_name AS student2, a.dept_id
FROM student a JOIN student b ON a.dept_id = b.dept_id AND a.student_id < b.student_id;
-- Q65. SELF JOIN: faculty colleagues with salary difference
SELECT a.first_name AS faculty1, b.first_name AS faculty2, ABS(a.salary - b.salary) AS salary_gap
FROM faculty a JOIN faculty b ON a.dept_id = b.dept_id AND a.faculty_id < b.faculty_id;
-- Q66. NATURAL JOIN
SELECT first_name, dept_name FROM student NATURAL JOIN department;
-- Q67. JOIN ... USING
SELECT first_name, dept_name FROM student JOIN department USING (dept_id);
-- Q68. JOIN with extra ON condition
SELECT s.first_name, d.dept_name
FROM student s JOIN department d ON d.dept_id = s.dept_id AND d.dept_name LIKE 'C%';
-- Q69. Exam with course details
SELECT x.exam_id, c.course_name, x.exam_type, x.exam_date, x.max_marks
FROM exam x JOIN course c ON c.course_id = x.course_id;
-- Q70. Result sheet with student, course, exam
SELECT s.first_name, c.course_name, x.exam_type, r.marks, r.grade
FROM result r
JOIN student s ON s.student_id = r.student_id
JOIN exam x ON x.exam_id = r.exam_id
JOIN course c ON c.course_id = x.course_id
ORDER BY s.first_name;

-- ---------- GROUP BY / HAVING ----------
-- Q71. Students per department
SELECT d.dept_name, COUNT(*) AS students
FROM student s JOIN department d ON d.dept_id = s.dept_id GROUP BY d.dept_name;
-- Q72. Students per gender
SELECT gender, COUNT(*) FROM student GROUP BY gender;
-- Q73. Average salary per department
SELECT d.dept_name, ROUND(AVG(f.salary), 2) AS avg_salary
FROM faculty f JOIN department d ON d.dept_id = f.dept_id GROUP BY d.dept_name;
-- Q74. HAVING: departments with more than 1 student
SELECT dept_id, COUNT(*) AS students FROM student GROUP BY dept_id HAVING COUNT(*) > 1;
-- Q75. HAVING: departments with avg salary above 70000
SELECT dept_id, ROUND(AVG(salary), 2) AS avg_salary FROM faculty GROUP BY dept_id HAVING AVG(salary) > 70000;
-- Q76. GROUP BY multiple columns
SELECT dept_id, gender, COUNT(*) AS total FROM student GROUP BY dept_id, gender ORDER BY dept_id;
-- Q77. ROLLUP (subtotals and grand total)
SELECT d.dept_name, s.gender, COUNT(*) AS total
FROM student s JOIN department d USING (dept_id)
GROUP BY ROLLUP (d.dept_name, s.gender);
-- Q78. CUBE (all combinations)
SELECT d.dept_name, s.gender, COUNT(*) AS total
FROM student s JOIN department d USING (dept_id)
GROUP BY CUBE (d.dept_name, s.gender);
-- Q79. GROUPING SETS
SELECT dept_id, gender, COUNT(*) AS total
FROM student GROUP BY GROUPING SETS ((dept_id), (gender), ());
-- Q80. STRING_AGG: students per department as list
SELECT d.dept_name, STRING_AGG(s.first_name, ', ' ORDER BY s.first_name) AS students
FROM department d JOIN student s ON s.dept_id = d.dept_id GROUP BY d.dept_name;
-- Q81. ARRAY_AGG
SELECT dept_id, ARRAY_AGG(first_name ORDER BY first_name) AS student_array FROM student GROUP BY dept_id;
-- Q82. COUNT with FILTER
SELECT COUNT(*) AS total,
       COUNT(*) FILTER (WHERE gender = 'M') AS male,
       COUNT(*) FILTER (WHERE gender = 'F') AS female
FROM student;
-- Q83. Total credits per department
SELECT d.dept_name, SUM(c.credits) AS total_credits
FROM course c JOIN department d ON d.dept_id = c.dept_id GROUP BY d.dept_name;
-- Q84. Highest marks per exam
SELECT exam_id, MAX(marks) AS highest FROM result GROUP BY exam_id ORDER BY exam_id;
-- Q85. Average marks by exam type
SELECT x.exam_type, ROUND(AVG(r.marks), 2) AS avg_marks
FROM result r JOIN exam x ON x.exam_id = r.exam_id GROUP BY x.exam_type;
-- Q86. Enrollments per course
SELECT c.course_name, COUNT(e.enrollment_id) AS enrolled
FROM course c LEFT JOIN enrollment e ON e.course_id = c.course_id
GROUP BY c.course_id, c.course_name ORDER BY enrolled DESC;
-- Q87. Attendance by status
SELECT status, COUNT(*) AS total FROM attendance GROUP BY status;
-- Q88. Attendance per date
SELECT class_date, COUNT(*) AS records FROM attendance GROUP BY class_date ORDER BY class_date;
-- Q89. Students per birth year
SELECT EXTRACT(YEAR FROM dob) AS birth_year, COUNT(*) FROM student GROUP BY 1 ORDER BY 1;
-- Q90. HAVING with join: courses with 2 or more students
SELECT c.course_name, COUNT(*) AS students
FROM enrollment e JOIN course c ON c.course_id = e.course_id
GROUP BY c.course_name HAVING COUNT(*) >= 2;

-- ---------- SUBQUERIES ----------
-- Q91. Scalar subquery: salary above average
SELECT first_name, salary FROM faculty WHERE salary > (SELECT AVG(salary) FROM faculty);
-- Q92. IN subquery: students enrolled in any course
SELECT * FROM student WHERE student_id IN (SELECT student_id FROM enrollment);
-- Q93. NOT IN subquery: students with no result
SELECT * FROM student WHERE student_id NOT IN (SELECT student_id FROM result);
-- Q94. EXISTS
SELECT * FROM student s WHERE EXISTS (SELECT 1 FROM enrollment e WHERE e.student_id = s.student_id);
-- Q95. NOT EXISTS: courses with no exam
SELECT * FROM course c WHERE NOT EXISTS (SELECT 1 FROM exam x WHERE x.course_id = c.course_id);
-- Q96. Correlated subquery: highest paid faculty per department
SELECT * FROM faculty f
WHERE salary = (SELECT MAX(f2.salary) FROM faculty f2 WHERE f2.dept_id = f.dept_id);
-- Q97. ANY
SELECT first_name, salary FROM faculty
WHERE salary > ANY (SELECT salary FROM faculty WHERE dept_id = 2);
-- Q98. ALL (highest salary)
SELECT first_name, salary FROM faculty WHERE salary >= ALL (SELECT salary FROM faculty);
-- Q99. Subquery in FROM
SELECT dept_id, avg_sal FROM (SELECT dept_id, AVG(salary) AS avg_sal FROM faculty GROUP BY dept_id) t WHERE avg_sal > 70000;
-- Q100. Subquery in SELECT
SELECT d.dept_name, (SELECT COUNT(*) FROM student s WHERE s.dept_id = d.dept_id) AS students FROM department d;
-- Q101. Nested subquery: students of the department having most faculty
SELECT * FROM student WHERE dept_id = (
  SELECT dept_id FROM faculty GROUP BY dept_id ORDER BY COUNT(*) DESC LIMIT 1);
-- Q102. Students who scored the maximum marks
SELECT s.first_name, r.marks FROM result r JOIN student s ON s.student_id = r.student_id
WHERE r.marks = (SELECT MAX(marks) FROM result);
-- Q103. Second highest salary
SELECT MAX(salary) AS second_highest FROM faculty WHERE salary < (SELECT MAX(salary) FROM faculty);
-- Q104. Nth highest salary using OFFSET (here 2nd)
SELECT DISTINCT salary FROM faculty ORDER BY salary DESC OFFSET 1 LIMIT 1;

-- ---------- SET OPERATIONS ----------
-- Q105. UNION (unique)
SELECT dept_id FROM student UNION SELECT dept_id FROM faculty;
-- Q106. UNION ALL (with duplicates)
SELECT dept_id FROM student UNION ALL SELECT dept_id FROM faculty;
-- Q107. INTERSECT: departments having both students and faculty
SELECT dept_id FROM student INTERSECT SELECT dept_id FROM faculty;
-- Q108. EXCEPT: departments with students but no courses
SELECT dept_id FROM student EXCEPT SELECT dept_id FROM course;
-- Q109. Combined people directory
SELECT first_name, last_name, email, 'Student' AS role FROM student
UNION ALL
SELECT first_name, last_name, email, 'Faculty' FROM faculty ORDER BY role, first_name;
-- Q110. INTERSECT: students enrolled in both CS101 and CS102
SELECT e.student_id FROM enrollment e JOIN course c USING (course_id) WHERE c.course_code = 'CS101'
INTERSECT
SELECT e.student_id FROM enrollment e JOIN course c USING (course_id) WHERE c.course_code = 'CS102';

-- =====================================================================
-- SECTION 3: WINDOW FUNCTIONS, CTE, ADVANCED ANALYSIS (Q111 - Q165)
-- =====================================================================

-- ---------- WINDOW FUNCTIONS ----------
-- Q111. ROW_NUMBER
SELECT first_name, salary, ROW_NUMBER() OVER (ORDER BY salary DESC) AS rn FROM faculty;
-- Q112. RANK
SELECT first_name, salary, RANK() OVER (ORDER BY salary DESC) AS rnk FROM faculty;
-- Q113. DENSE_RANK
SELECT first_name, salary, DENSE_RANK() OVER (ORDER BY salary DESC) AS drnk FROM faculty;
-- Q114. NTILE (quartiles of marks)
SELECT student_id, marks, NTILE(4) OVER (ORDER BY marks DESC) AS quartile FROM result;
-- Q115. LAG: previous marks of the same student
SELECT r.student_id, x.exam_date, r.marks,
       LAG(r.marks) OVER (PARTITION BY r.student_id ORDER BY x.exam_date) AS prev_marks
FROM result r JOIN exam x ON x.exam_id = r.exam_id;
-- Q116. LEAD: next marks of the same student
SELECT r.student_id, x.exam_date, r.marks,
       LEAD(r.marks) OVER (PARTITION BY r.student_id ORDER BY x.exam_date) AS next_marks
FROM result r JOIN exam x ON x.exam_id = r.exam_id;
-- Q117. FIRST_VALUE: highest salary in own department
SELECT first_name, dept_id, salary,
       FIRST_VALUE(salary) OVER (PARTITION BY dept_id ORDER BY salary DESC) AS dept_max
FROM faculty;
-- Q118. LAST_VALUE with full frame
SELECT first_name, dept_id, salary,
       LAST_VALUE(salary) OVER (PARTITION BY dept_id ORDER BY salary DESC
         ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS dept_min
FROM faculty;
-- Q119. NTH_VALUE
SELECT first_name, salary,
       NTH_VALUE(salary, 2) OVER (ORDER BY salary DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS second_highest
FROM faculty;
-- Q120. Running total of salary
SELECT first_name, salary, SUM(salary) OVER (ORDER BY faculty_id) AS running_total FROM faculty;
-- Q121. Running count of classes per date
SELECT class_date, COUNT(*) AS daily,
       SUM(COUNT(*)) OVER (ORDER BY class_date) AS cumulative
FROM attendance GROUP BY class_date ORDER BY class_date;
-- Q122. PERCENT_RANK
SELECT first_name, salary, ROUND(PERCENT_RANK() OVER (ORDER BY salary)::numeric, 2) AS pct_rank FROM faculty;
-- Q123. CUME_DIST
SELECT student_id, marks, ROUND(CUME_DIST() OVER (ORDER BY marks)::numeric, 2) AS cume FROM result;
-- Q124. Salary share of total
SELECT first_name, salary, ROUND(100.0 * salary / SUM(salary) OVER (), 2) AS pct_of_total FROM faculty;
-- Q125. Individual vs department average
SELECT first_name, dept_id, salary,
       ROUND(AVG(salary) OVER (PARTITION BY dept_id), 2) AS dept_avg
FROM faculty;
-- Q126. Salary rank within department
SELECT first_name, dept_id, salary,
       RANK() OVER (PARTITION BY dept_id ORDER BY salary DESC) AS dept_rank
FROM faculty;
-- Q127. Top 1 per department (ROW_NUMBER)
SELECT * FROM (
  SELECT f.*, ROW_NUMBER() OVER (PARTITION BY dept_id ORDER BY salary DESC) AS rn FROM faculty f
) t WHERE rn = 1;
-- Q128. Top 2 marks per course
SELECT * FROM (
  SELECT c.course_name, s.first_name, r.marks,
         ROW_NUMBER() OVER (PARTITION BY c.course_id ORDER BY r.marks DESC) AS rn
  FROM result r
  JOIN exam x ON x.exam_id = r.exam_id
  JOIN course c ON c.course_id = x.course_id
  JOIN student s ON s.student_id = r.student_id
) t WHERE rn <= 2;
-- Q129. Difference from department average salary
SELECT first_name, salary,
       ROUND(salary - AVG(salary) OVER (PARTITION BY dept_id), 2) AS diff_from_avg
FROM faculty;
-- Q130. Running present count per enrollment
SELECT enrollment_id, class_date, status,
       COUNT(*) FILTER (WHERE status = 'Present')
         OVER (PARTITION BY enrollment_id ORDER BY class_date) AS present_so_far
FROM attendance ORDER BY enrollment_id, class_date;
-- Q131. Named WINDOW clause
SELECT first_name, dept_id, salary,
       RANK() OVER w AS rnk, SUM(salary) OVER w AS running_sum
FROM faculty
WINDOW w AS (PARTITION BY dept_id ORDER BY salary DESC);
-- Q132. Moving average over 3 rows
SELECT class_date, COUNT(*) AS daily,
       ROUND(AVG(COUNT(*)) OVER (ORDER BY class_date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS moving_avg_3
FROM attendance GROUP BY class_date ORDER BY class_date;
-- Q133. COUNT as window function
SELECT first_name, dept_id, COUNT(*) OVER (PARTITION BY dept_id) AS dept_size FROM student;
-- Q134. Marks vs exam average
SELECT r.student_id, r.exam_id, r.marks,
       ROUND(AVG(r.marks) OVER (PARTITION BY r.exam_id), 2) AS exam_avg,
       ROUND(r.marks - AVG(r.marks) OVER (PARTITION BY r.exam_id), 2) AS diff
FROM result r;

-- ---------- STATISTICS ----------
-- Q135. Median marks
SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY marks) AS median_marks FROM result;
-- Q136. PERCENTILE_DISC (75th percentile)
SELECT PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY marks) AS p75 FROM result;
-- Q137. MODE (most common grade)
SELECT MODE() WITHIN GROUP (ORDER BY grade) AS most_common_grade FROM result;
-- Q138. Standard deviation
SELECT ROUND(STDDEV(marks), 2) AS std_dev FROM result;
-- Q139. Variance
SELECT ROUND(VARIANCE(marks), 2) AS variance FROM result;
-- Q140. Correlation: attendance % vs average marks
WITH att AS (
  SELECT e.student_id, 100.0 * COUNT(*) FILTER (WHERE a.status = 'Present') / COUNT(*) AS att_pct
  FROM attendance a JOIN enrollment e ON e.enrollment_id = a.enrollment_id GROUP BY e.student_id),
mk AS (SELECT student_id, AVG(marks) AS avg_marks FROM result GROUP BY student_id)
SELECT ROUND(CORR(att.att_pct, mk.avg_marks)::numeric, 3) AS correlation
FROM att JOIN mk USING (student_id);
-- Q141. Regression slope: marks change per 1% attendance
WITH att AS (
  SELECT e.student_id, 100.0 * COUNT(*) FILTER (WHERE a.status = 'Present') / COUNT(*) AS att_pct
  FROM attendance a JOIN enrollment e ON e.enrollment_id = a.enrollment_id GROUP BY e.student_id),
mk AS (SELECT student_id, AVG(marks) AS avg_marks FROM result GROUP BY student_id)
SELECT ROUND(REGR_SLOPE(mk.avg_marks, att.att_pct)::numeric, 3) AS slope
FROM att JOIN mk USING (student_id);
-- Q142. Median marks per course
SELECT c.course_name, PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY r.marks) AS median_marks
FROM result r JOIN exam x ON x.exam_id = r.exam_id JOIN course c ON c.course_id = x.course_id
GROUP BY c.course_name;

-- ---------- CTE ----------
-- Q143. Simple CTE
WITH dept_avg AS (SELECT dept_id, AVG(salary) AS avg_sal FROM faculty GROUP BY dept_id)
SELECT d.dept_name, ROUND(a.avg_sal, 2) AS avg_salary
FROM dept_avg a JOIN department d USING (dept_id);
-- Q144. Multiple CTEs
WITH s_cnt AS (SELECT dept_id, COUNT(*) AS students FROM student GROUP BY dept_id),
     f_cnt AS (SELECT dept_id, COUNT(*) AS faculty FROM faculty GROUP BY dept_id)
SELECT d.dept_name, COALESCE(s.students, 0) AS students, COALESCE(f.faculty, 0) AS faculty,
       ROUND(COALESCE(s.students, 0)::numeric / NULLIF(f.faculty, 0), 2) AS student_faculty_ratio
FROM department d LEFT JOIN s_cnt s USING (dept_id) LEFT JOIN f_cnt f USING (dept_id);
-- Q145. Chained CTEs: students above overall average
WITH avg_marks AS (SELECT student_id, AVG(marks) AS am FROM result GROUP BY student_id),
     overall AS (SELECT AVG(am) AS oa FROM avg_marks)
SELECT s.first_name, ROUND(a.am, 2) AS avg_marks
FROM avg_marks a JOIN student s USING (student_id), overall o
WHERE a.am > o.oa;
-- Q146. CTE used with window function
WITH ranked AS (
  SELECT s.first_name, d.dept_name, AVG(r.marks) AS avg_marks,
         RANK() OVER (PARTITION BY d.dept_name ORDER BY AVG(r.marks) DESC) AS rnk
  FROM result r JOIN student s ON s.student_id = r.student_id JOIN department d ON d.dept_id = s.dept_id
  GROUP BY s.first_name, d.dept_name)
SELECT * FROM ranked WHERE rnk = 1;
-- Q147. Recursive CTE: numbers and squares
WITH RECURSIVE t(n) AS (SELECT 1 UNION ALL SELECT n + 1 FROM t WHERE n < 10)
SELECT n, n * n AS square FROM t;
-- Q148. Recursive CTE: date series
WITH RECURSIVE d(day) AS (
  SELECT DATE '2026-08-01' UNION ALL SELECT day + 1 FROM d WHERE day < DATE '2026-08-10')
SELECT day, TO_CHAR(day, 'Dy') AS weekday FROM d;
-- Q149. Recursive CTE: factorial
WITH RECURSIVE f(n, fact) AS (
  SELECT 1, 1::numeric UNION ALL SELECT n + 1, fact * (n + 1) FROM f WHERE n < 10)
SELECT * FROM f;

-- ---------- LATERAL, PIVOT, ADVANCED ----------
-- Q150. LATERAL: top 2 results per student
SELECT s.first_name, t.marks, t.grade
FROM student s
CROSS JOIN LATERAL (SELECT r.marks, r.grade FROM result r WHERE r.student_id = s.student_id
                    ORDER BY r.marks DESC LIMIT 2) t;
-- Q151. LATERAL: latest attendance record per enrollment
SELECT e.enrollment_id, a.class_date, a.status
FROM enrollment e
LEFT JOIN LATERAL (SELECT class_date, status FROM attendance a2 WHERE a2.enrollment_id = e.enrollment_id
                   ORDER BY class_date DESC LIMIT 1) a ON TRUE;
-- Q152. Pivot with FILTER: grade counts per department
SELECT d.dept_name,
       COUNT(*) FILTER (WHERE r.grade IN ('A+', 'A')) AS excellent,
       COUNT(*) FILTER (WHERE r.grade IN ('B', 'C')) AS good,
       COUNT(*) FILTER (WHERE r.grade IN ('D', 'F')) AS weak
FROM result r JOIN student s ON s.student_id = r.student_id JOIN department d ON d.dept_id = s.dept_id
GROUP BY d.dept_name;
-- Q153. Pivot with CASE: marks per exam type per student
SELECT s.first_name,
       MAX(CASE WHEN x.exam_type = 'Midterm' THEN r.marks END) AS midterm,
       MAX(CASE WHEN x.exam_type = 'Final' THEN r.marks END) AS final
FROM result r JOIN exam x ON x.exam_id = r.exam_id JOIN student s ON s.student_id = r.student_id
GROUP BY s.first_name;
-- Q154. Attendance % per student per month
SELECT s.first_name, TO_CHAR(a.class_date, 'YYYY-MM') AS month,
       ROUND(100.0 * COUNT(*) FILTER (WHERE a.status = 'Present') / COUNT(*), 2) AS pct
FROM attendance a
JOIN enrollment e ON e.enrollment_id = a.enrollment_id
JOIN student s ON s.student_id = e.student_id
GROUP BY s.first_name, month ORDER BY 1, 2;
-- Q155. At-risk: attendance below 75% or any F grade
SELECT s.student_id, s.first_name FROM student s
WHERE s.student_id IN (SELECT student_id FROM result WHERE grade = 'F')
   OR s.student_id IN (SELECT e.student_id FROM attendance a JOIN enrollment e USING (enrollment_id)
                       GROUP BY e.student_id
                       HAVING 100.0 * COUNT(*) FILTER (WHERE a.status = 'Present') / COUNT(*) < 75);
-- Q156. Cohort: admission year vs department
SELECT admission_year, d.dept_name, COUNT(*) AS students
FROM student s JOIN department d USING (dept_id)
GROUP BY admission_year, d.dept_name ORDER BY admission_year, d.dept_name;
-- Q157. Calendar days with no class records
SELECT g::date AS no_class_date
FROM generate_series('2026-08-01'::date, '2026-08-31'::date, '1 day') g
WHERE g::date NOT IN (SELECT DISTINCT class_date FROM attendance);
-- Q158. Longest absent streaks (gaps and islands)
WITH x AS (
  SELECT enrollment_id, class_date, status,
         ROW_NUMBER() OVER (PARTITION BY enrollment_id ORDER BY class_date)
       - ROW_NUMBER() OVER (PARTITION BY enrollment_id, status ORDER BY class_date) AS grp
  FROM attendance)
SELECT enrollment_id, MIN(class_date) AS streak_start, MAX(class_date) AS streak_end, COUNT(*) AS days
FROM x WHERE status = 'Absent' GROUP BY enrollment_id, grp ORDER BY days DESC;
-- Q159. Department share of total students
SELECT d.dept_name, COUNT(*) AS students,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct
FROM student s JOIN department d USING (dept_id) GROUP BY d.dept_name;
-- Q160. Faculty salary percentile bands
SELECT first_name, salary, NTILE(3) OVER (ORDER BY salary) AS salary_tier FROM faculty;
-- Q161. Marks histogram (buckets of 20)
SELECT WIDTH_BUCKET(marks, 0, 100, 5) AS bucket, COUNT(*) AS students
FROM result GROUP BY bucket ORDER BY bucket;
-- Q162. Grade points per result
SELECT s.first_name, c.course_name, r.grade,
       CASE r.grade WHEN 'A+' THEN 10 WHEN 'A' THEN 9 WHEN 'B' THEN 8
                    WHEN 'C' THEN 7 WHEN 'D' THEN 6 ELSE 0 END AS grade_point
FROM result r JOIN exam x ON x.exam_id = r.exam_id JOIN course c ON c.course_id = x.course_id
JOIN student s ON s.student_id = r.student_id;
-- Q163. Credit-weighted GPA per student
SELECT s.first_name,
       ROUND(SUM(c.credits * CASE r.grade WHEN 'A+' THEN 10 WHEN 'A' THEN 9 WHEN 'B' THEN 8
                    WHEN 'C' THEN 7 WHEN 'D' THEN 6 ELSE 0 END)::numeric / SUM(c.credits), 2) AS gpa
FROM result r JOIN exam x ON x.exam_id = r.exam_id JOIN course c ON c.course_id = x.course_id
JOIN student s ON s.student_id = r.student_id
GROUP BY s.student_id, s.first_name ORDER BY gpa DESC;
-- Q164. Student rank across the whole college by average marks
SELECT s.first_name, ROUND(AVG(r.marks), 2) AS avg_marks,
       DENSE_RANK() OVER (ORDER BY AVG(r.marks) DESC) AS college_rank
FROM result r JOIN student s ON s.student_id = r.student_id GROUP BY s.student_id, s.first_name;
-- Q165. Top 3 students overall
SELECT s.first_name, ROUND(AVG(r.marks), 2) AS avg_marks
FROM result r JOIN student s ON s.student_id = r.student_id
GROUP BY s.student_id, s.first_name ORDER BY avg_marks DESC LIMIT 3;

-- =====================================================================
-- SECTION 4: VIEWS, INDEXES, DDL, DML, FUNCTIONS, TRIGGERS, ADMIN,
--            JSON, DATA QUALITY (Q166 - Q229)
-- =====================================================================

-- ---------- VIEWS ----------
-- Q166. Create a department summary view
CREATE OR REPLACE VIEW v_dept_summary AS
SELECT d.dept_id, d.dept_name,
       (SELECT COUNT(*) FROM student s WHERE s.dept_id = d.dept_id) AS students,
       (SELECT COUNT(*) FROM faculty f WHERE f.dept_id = d.dept_id) AS faculty,
       (SELECT COUNT(*) FROM course c WHERE c.dept_id = d.dept_id) AS courses
FROM department d;
-- Q167. Query the view
SELECT * FROM v_dept_summary ORDER BY students DESC;
-- Q168. Replace the view (add HOD column)
CREATE OR REPLACE VIEW v_dept_summary AS
SELECT d.dept_id, d.dept_name,
       (SELECT COUNT(*) FROM student s WHERE s.dept_id = d.dept_id) AS students,
       (SELECT COUNT(*) FROM faculty f WHERE f.dept_id = d.dept_id) AS faculty,
       (SELECT COUNT(*) FROM course c WHERE c.dept_id = d.dept_id) AS courses,
       d.hod_name
FROM department d;
-- Q169. Materialized view
DROP MATERIALIZED VIEW IF EXISTS mv_course_stats;
CREATE MATERIALIZED VIEW mv_course_stats AS
SELECT c.course_id, c.course_name,
       (SELECT COUNT(*) FROM enrollment e WHERE e.course_id = c.course_id) AS enrolled,
       (SELECT ROUND(AVG(r.marks), 2) FROM result r JOIN exam x ON x.exam_id = r.exam_id
        WHERE x.course_id = c.course_id) AS avg_marks
FROM course c;
-- Q170. Query and refresh the materialized view
SELECT * FROM mv_course_stats;
REFRESH MATERIALIZED VIEW mv_course_stats;
-- Q171. Drop a view (cleanup)
DROP VIEW IF EXISTS v_dept_summary;

-- ---------- INDEXES & PERFORMANCE ----------
-- Q172. Composite index
CREATE INDEX IF NOT EXISTS idx_result_exam_student ON result(exam_id, student_id);
-- Q173. Partial index (only absent records)
CREATE INDEX IF NOT EXISTS idx_attendance_absent ON attendance(enrollment_id) WHERE status = 'Absent';
-- Q174. Expression index on lower(email)
CREATE INDEX IF NOT EXISTS idx_student_email_lower ON student(LOWER(email));
-- Q175. EXPLAIN
EXPLAIN SELECT * FROM student WHERE LOWER(email) = 'aarav@college.edu';
-- Q176. EXPLAIN ANALYZE
EXPLAIN ANALYZE SELECT * FROM enrollment WHERE student_id = 1;
-- Q177. List all indexes
SELECT tablename, indexname, indexdef FROM pg_indexes WHERE schemaname = 'college' ORDER BY tablename;
-- Q178. Drop an index (cleanup)
DROP INDEX IF EXISTS idx_student_email_lower;

-- ---------- SYSTEM CATALOG / METADATA ----------
-- Q179. Table sizes
SELECT relname AS table_name, pg_size_pretty(pg_total_relation_size(relid)) AS total_size
FROM pg_stat_user_tables WHERE schemaname = 'college' ORDER BY pg_total_relation_size(relid) DESC;
-- Q180. List all tables
SELECT table_name FROM information_schema.tables WHERE table_schema = 'college' AND table_type = 'BASE TABLE' ORDER BY 1;
-- Q181. List all columns with data types
SELECT table_name, column_name, data_type, is_nullable, column_default
FROM information_schema.columns WHERE table_schema = 'college' ORDER BY table_name, ordinal_position;
-- Q182. List all constraints (p=PK, f=FK, u=UNIQUE, c=CHECK)
SELECT conrelid::regclass AS table_name, conname, contype
FROM pg_constraint WHERE connamespace = 'college'::regnamespace ORDER BY 1, 3;
-- Q183. List foreign key relationships
SELECT tc.table_name, kcu.column_name, ccu.table_name AS references_table, ccu.column_name AS references_column
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
  ON tc.constraint_name = kcu.constraint_name AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage ccu
  ON ccu.constraint_name = tc.constraint_name AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY' AND tc.table_schema = 'college';
-- Q184. Approx row counts from statistics
SELECT relname, n_live_tup FROM pg_stat_user_tables WHERE schemaname = 'college' ORDER BY n_live_tup DESC;
-- Q185. Exact row count of every table
SELECT 'department' AS tbl, COUNT(*) FROM department
UNION ALL SELECT 'student', COUNT(*) FROM student
UNION ALL SELECT 'faculty', COUNT(*) FROM faculty
UNION ALL SELECT 'course', COUNT(*) FROM course
UNION ALL SELECT 'enrollment', COUNT(*) FROM enrollment
UNION ALL SELECT 'attendance', COUNT(*) FROM attendance
UNION ALL SELECT 'exam', COUNT(*) FROM exam
UNION ALL SELECT 'result', COUNT(*) FROM result;
-- Q186. Environment info
SELECT current_database() AS db, current_schema() AS schema, current_user AS usr, version();

-- ---------- DDL (safe, rolled back) ----------
-- Q187. CREATE TABLE AS (temp table)
BEGIN;
CREATE TEMP TABLE top_students AS
SELECT s.student_id, s.first_name, ROUND(AVG(r.marks), 2) AS avg_marks
FROM student s JOIN result r USING (student_id) GROUP BY s.student_id, s.first_name;
SELECT * FROM top_students ORDER BY avg_marks DESC;
ROLLBACK;
-- Q188. ALTER TABLE ADD COLUMN
BEGIN;
ALTER TABLE student ADD COLUMN city VARCHAR(50) DEFAULT 'Delhi';
SELECT first_name, city FROM student;
ROLLBACK;
-- Q189. ALTER TABLE RENAME COLUMN
BEGIN;
ALTER TABLE student RENAME COLUMN phone TO mobile;
SELECT first_name, mobile FROM student;
ROLLBACK;
-- Q190. ALTER TABLE ADD CONSTRAINT
BEGIN;
ALTER TABLE faculty ADD CONSTRAINT chk_designation
  CHECK (designation IN ('Professor', 'Associate Professor', 'Assistant Professor'));
SELECT conname FROM pg_constraint WHERE conrelid = 'faculty'::regclass;
ROLLBACK;
-- Q191. ALTER TABLE DROP COLUMN
BEGIN;
ALTER TABLE student DROP COLUMN phone;
SELECT * FROM student LIMIT 2;
ROLLBACK;

-- ---------- DML (safe, rolled back) ----------
-- Q192. INSERT
BEGIN;
INSERT INTO student (first_name, last_name, email, phone, dob, gender, admission_year, dept_id)
VALUES ('Test', 'User', 'test.user@college.edu', '9999999999', '2005-05-05', 'M', 2026, 1);
SELECT * FROM student ORDER BY student_id DESC LIMIT 1;
ROLLBACK;
-- Q193. UPDATE
BEGIN;
UPDATE faculty SET salary = salary * 1.10 WHERE dept_id = 1;
SELECT first_name, salary FROM faculty WHERE dept_id = 1;
ROLLBACK;
-- Q194. DELETE
BEGIN;
DELETE FROM attendance WHERE status = 'Absent';
SELECT COUNT(*) AS remaining_records FROM attendance;
ROLLBACK;
-- Q195. UPSERT (INSERT ... ON CONFLICT)
BEGIN;
INSERT INTO department (dept_name, hod_name) VALUES ('Computer Science', 'Dr. New HOD')
ON CONFLICT (dept_name) DO UPDATE SET hod_name = EXCLUDED.hod_name;
SELECT * FROM department ORDER BY dept_id;
ROLLBACK;
-- Q196. INSERT ... SELECT
BEGIN;
CREATE TEMP TABLE cs_students AS SELECT * FROM student WHERE FALSE;
INSERT INTO cs_students SELECT * FROM student WHERE dept_id = 1;
SELECT * FROM cs_students;
ROLLBACK;
-- Q197. UPDATE ... FROM (add 5 grace marks in course 1)
BEGIN;
UPDATE result r SET marks = r.marks + 5
FROM exam x WHERE x.exam_id = r.exam_id AND x.course_id = 1;
SELECT student_id, exam_id, marks, grade FROM result WHERE exam_id = 1;
ROLLBACK;
-- Q198. DELETE ... USING
BEGIN;
DELETE FROM enrollment e USING course c
WHERE c.course_id = e.course_id AND c.course_code = 'ME201';
SELECT COUNT(*) AS remaining_enrollments FROM enrollment;
ROLLBACK;
-- Q199. RETURNING clause
BEGIN;
UPDATE faculty SET salary = salary + 1000 WHERE faculty_id = 1 RETURNING faculty_id, first_name, salary;
ROLLBACK;
-- Q200. SAVEPOINT
BEGIN;
UPDATE faculty SET salary = salary + 1000 WHERE faculty_id = 1;
SAVEPOINT sp1;
DELETE FROM attendance;
ROLLBACK TO SAVEPOINT sp1;
SELECT (SELECT COUNT(*) FROM attendance) AS attendance_rows, (SELECT salary FROM faculty WHERE faculty_id = 1) AS salary;
ROLLBACK;
-- Q201. TRUNCATE (transactional in PostgreSQL)
BEGIN;
TRUNCATE attendance;
SELECT COUNT(*) AS rows_after_truncate FROM attendance;
ROLLBACK;

-- ---------- FUNCTIONS, PROCEDURES, DO BLOCKS ----------
-- Q202. SQL function: GPA of a student
CREATE OR REPLACE FUNCTION fn_student_gpa(p_student INT) RETURNS NUMERIC AS $$
  SELECT ROUND(SUM(c.credits * CASE r.grade WHEN 'A+' THEN 10 WHEN 'A' THEN 9 WHEN 'B' THEN 8
                   WHEN 'C' THEN 7 WHEN 'D' THEN 6 ELSE 0 END)::numeric / NULLIF(SUM(c.credits), 0), 2)
  FROM result r
  JOIN exam x ON x.exam_id = r.exam_id
  JOIN course c ON c.course_id = x.course_id
  WHERE r.student_id = p_student;
$$ LANGUAGE sql;
-- Q203. Use the function
SELECT student_id, first_name, fn_student_gpa(student_id) AS gpa FROM student ORDER BY gpa DESC NULLS LAST;
-- Q204. Function returning a table
CREATE OR REPLACE FUNCTION fn_dept_students(p_dept INT)
RETURNS TABLE (student_id INT, full_name TEXT, email VARCHAR) AS $$
  SELECT s.student_id, (s.first_name || ' ' || s.last_name)::text, s.email
  FROM student s WHERE s.dept_id = p_dept;
$$ LANGUAGE sql;
-- Q205. Use the table function
SELECT * FROM fn_dept_students(1);
-- Q206. Stored procedure: raise salary for a department
CREATE OR REPLACE PROCEDURE sp_raise_salary(p_dept INT, p_pct NUMERIC)
LANGUAGE plpgsql AS $$
BEGIN
  UPDATE faculty SET salary = ROUND(salary * (1 + p_pct / 100), 2) WHERE dept_id = p_dept;
END; $$;
-- Q207. Test the procedure (rolled back)
BEGIN;
CALL sp_raise_salary(1, 10);
SELECT first_name, salary FROM faculty WHERE dept_id = 1;
ROLLBACK;
-- Q208. Anonymous DO block with loop (see Messages tab in pgAdmin)
DO $$
DECLARE r RECORD;
BEGIN
  FOR r IN SELECT d.dept_name, COUNT(*) AS n FROM department d JOIN student s USING (dept_id) GROUP BY d.dept_name LOOP
    RAISE NOTICE '% -> % students', r.dept_name, r.n;
  END LOOP;
END $$;
-- Q209. DO block with IF logic
DO $$
DECLARE total INT;
BEGIN
  SELECT COUNT(*) INTO total FROM student;
  IF total > 3 THEN RAISE NOTICE 'Large batch: % students', total;
  ELSE RAISE NOTICE 'Small batch: % students', total;
  END IF;
END $$;

-- ---------- TRIGGERS ----------
-- Q210. Audit table for salary changes
CREATE TABLE IF NOT EXISTS salary_audit (
  audit_id SERIAL PRIMARY KEY, faculty_id INT, old_salary NUMERIC(10,2),
  new_salary NUMERIC(10,2), changed_at TIMESTAMP DEFAULT NOW());
-- Q211. Audit trigger function + trigger
CREATE OR REPLACE FUNCTION fn_audit_salary() RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO salary_audit (faculty_id, old_salary, new_salary) VALUES (OLD.faculty_id, OLD.salary, NEW.salary);
  RETURN NEW;
END; $$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS trg_audit_salary ON faculty;
CREATE TRIGGER trg_audit_salary AFTER UPDATE OF salary ON faculty
FOR EACH ROW WHEN (OLD.salary IS DISTINCT FROM NEW.salary) EXECUTE FUNCTION fn_audit_salary();
-- Q212. Test the audit trigger (rolled back)
BEGIN;
UPDATE faculty SET salary = salary + 500 WHERE faculty_id = 1;
SELECT * FROM salary_audit;
ROLLBACK;
-- Q213. Trigger: block attendance for future dates
CREATE OR REPLACE FUNCTION fn_block_future_attendance() RETURNS TRIGGER AS $$
BEGIN
  IF NEW.class_date > CURRENT_DATE THEN RAISE EXCEPTION 'Attendance date cannot be in the future'; END IF;
  RETURN NEW;
END; $$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS trg_block_future_attendance ON attendance;
CREATE TRIGGER trg_block_future_attendance BEFORE INSERT ON attendance
FOR EACH ROW EXECUTE FUNCTION fn_block_future_attendance();
-- Q214. Test (this should give an ERROR - that is the proof it works)
-- INSERT INTO attendance (enrollment_id, class_date, status) VALUES (1, CURRENT_DATE + 5, 'Present');
-- Q215. List all triggers
SELECT event_object_table AS table_name, trigger_name, event_manipulation, action_timing
FROM information_schema.triggers WHERE trigger_schema = 'college' ORDER BY 1;
-- Q216. List all functions and procedures
SELECT proname AS name, prokind AS kind FROM pg_proc WHERE pronamespace = 'college'::regnamespace ORDER BY 1;

-- ---------- ROLES & PERMISSIONS ----------
-- Q217. Create a read-only analyst role
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'analyst_role') THEN CREATE ROLE analyst_role NOLOGIN; END IF;
END $$;
-- Q218. GRANT read access
GRANT USAGE ON SCHEMA college TO analyst_role;
GRANT SELECT ON ALL TABLES IN SCHEMA college TO analyst_role;
-- Q219. REVOKE access on a sensitive table
REVOKE SELECT ON faculty FROM analyst_role;
-- Q220. COMMENT on table (documentation)
COMMENT ON TABLE student IS 'Stores student personal and admission details';

-- ---------- DATA QUALITY ----------
-- Q221. Duplicate emails across students and faculty
SELECT email, COUNT(*) FROM (SELECT email FROM student UNION ALL SELECT email FROM faculty) t
GROUP BY email HAVING COUNT(*) > 1;
-- Q222. Marks greater than exam maximum
SELECT r.* FROM result r JOIN exam x USING (exam_id) WHERE r.marks > x.max_marks;
-- Q223. Students enrolled in a course of another department
SELECT s.first_name, c.course_name
FROM enrollment e JOIN student s ON s.student_id = e.student_id JOIN course c ON c.course_id = e.course_id
WHERE s.dept_id <> c.dept_id;
-- Q224. Students younger than 17 at admission
SELECT first_name, dob, admission_year FROM student
WHERE DATE_PART('year', AGE(MAKE_DATE(admission_year, 7, 1), dob)) < 17;

-- ---------- JSON & FINAL REPORT ----------
-- Q225. Department report as JSON
SELECT jsonb_pretty(jsonb_build_object(
  'dept', d.dept_name,
  'students', (SELECT COUNT(*) FROM student s WHERE s.dept_id = d.dept_id),
  'faculty', (SELECT COUNT(*) FROM faculty f WHERE f.dept_id = d.dept_id))) AS report
FROM department d;
-- Q226. Rows as JSON
SELECT row_to_json(d) FROM department d;
-- Q227. JSON array aggregation
SELECT json_agg(json_build_object('student', first_name, 'email', email)) AS students_json FROM student;
-- Q228. Department-wise student list as text
SELECT d.dept_name || ': ' || STRING_AGG(s.first_name, ', ' ORDER BY s.first_name) AS summary
FROM department d JOIN student s USING (dept_id) GROUP BY d.dept_name;
-- Q229. Final one-row college dashboard
WITH att AS (
  SELECT ROUND(100.0 * COUNT(*) FILTER (WHERE status = 'Present') / COUNT(*), 2) AS overall_att FROM attendance),
top1 AS (
  SELECT s.first_name || ' ' || s.last_name AS topper
  FROM result r JOIN student s USING (student_id) GROUP BY s.student_id, s.first_name, s.last_name
  ORDER BY AVG(r.marks) DESC LIMIT 1)
SELECT (SELECT COUNT(*) FROM student) AS students,
       (SELECT COUNT(*) FROM faculty) AS faculty,
       (SELECT COUNT(*) FROM course) AS courses,
       (SELECT ROUND(AVG(marks), 2) FROM result) AS avg_marks,
       att.overall_att AS attendance_pct,
       top1.topper
FROM att, top1;
