
USE student_analytics;

-- 1. Overall student performance with rankings
SELECT
    student_id,
    name,
    department,
    attendance,
    avg_marks,
    CASE
        WHEN avg_marks >= 90 THEN 'A+'
        WHEN avg_marks >= 80 THEN 'A'
        WHEN avg_marks >= 70 THEN 'B'
        WHEN avg_marks >= 60 THEN 'C'
        ELSE 'F'
    END AS grade,
    DENSE_RANK() OVER (ORDER BY avg_marks DESC) AS student_rank
FROM student_report
ORDER BY student_rank;

-- 2. Students at academic risk
SELECT *
FROM student_report
WHERE attendance < 75 OR avg_marks < 70;

-- 3. Department-wise performance
SELECT
    department,
    COUNT(*) AS total_students,
    ROUND(AVG(avg_marks), 2) AS average_marks,
    ROUND(AVG(attendance), 2) AS average_attendance
FROM student_report
GROUP BY department;

-- 4. Subject-wise statistics
SELECT
    subject,
    ROUND(AVG(score), 2) AS average_score,
    MAX(score) AS highest_score,
    MIN(score) AS lowest_score
FROM marks
GROUP BY subject;

-- 5. Performance category distribution
SELECT
    CASE
        WHEN avg_marks >= 90 THEN 'Excellent'
        WHEN avg_marks >= 75 THEN 'Good'
        WHEN avg_marks >= 60 THEN 'Average'
        ELSE 'Needs Improvement'
    END AS performance_category,
    COUNT(*) AS student_count
FROM student_report
GROUP BY performance_category;

-- 6. Stored procedure demonstration
CALL GetDepartmentReport('CSE');
