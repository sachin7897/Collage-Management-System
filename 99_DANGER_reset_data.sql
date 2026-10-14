-- =====================================================================
-- 99_DANGER_reset_data.sql
-- DELETES ALL ROWS FROM ALL 8 TABLES. The tables themselves stay.
-- Use ONLY when a CSV import went wrong and you want to start the
-- import again from Step 1 (department). Do not run it otherwise.
-- =====================================================================
SET search_path TO college;
TRUNCATE attendance, enrollment, result, exam, course, faculty, student, department
RESTART IDENTITY;
