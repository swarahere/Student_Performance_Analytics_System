-- STUDENT PERFORMANCE ANALYTICS: V2 UPGRADE
-- Run AFTER the original student_performance.sql. Does not delete existing data.
USE student_analytics;

-- 1. Rankings and grade classification
CREATE OR REPLACE VIEW student_advanced_report AS
SELECT student_id, name, department, attendance, avg_marks,
       DENSE_RANK() OVER (ORDER BY avg_marks DESC) AS overall_rank,
       CASE WHEN avg_marks >= 90 THEN 'A+'
            WHEN avg_marks >= 80 THEN 'A'
            WHEN avg_marks >= 70 THEN 'B'
            WHEN avg_marks >= 60 THEN 'C'
            ELSE 'D' END AS grade,
       CASE WHEN attendance < 75 OR avg_marks < 70 THEN 'AT RISK'
            ELSE 'ON TRACK' END AS status
FROM student_report;

-- 2. Dedicated view for at-risk students
CREATE OR REPLACE VIEW at_risk_students AS
SELECT * FROM student_advanced_report WHERE status = 'AT RISK';

-- 3. Stored procedure: report for a given department
DROP PROCEDURE IF EXISTS GetDepartmentReport;
DELIMITER $$
CREATE PROCEDURE GetDepartmentReport(IN dept_name VARCHAR(30))
BEGIN
  SELECT * FROM student_advanced_report
  WHERE department = dept_name
  ORDER BY overall_rank;
END $$
DELIMITER ;

-- 4. Trigger: prevent marks outside 0-100
DROP TRIGGER IF EXISTS validate_marks_insert;
DELIMITER $$
CREATE TRIGGER validate_marks_insert
BEFORE INSERT ON marks
FOR EACH ROW
BEGIN
  IF NEW.score < 0 OR NEW.score > 100 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Marks must be between 0 and 100';
  END IF;
END $$
DELIMITER ;

DROP TRIGGER IF EXISTS validate_marks_update;
DELIMITER $$
CREATE TRIGGER validate_marks_update
BEFORE UPDATE ON marks
FOR EACH ROW
BEGIN
  IF NEW.score < 0 OR NEW.score > 100 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Marks must be between 0 and 100';
  END IF;
END $$
DELIMITER ;

-- 5. Index for subject searches
CREATE INDEX idx_marks_subject ON marks(subject);

-- 6. Analytics outputs: execute and capture screenshots
SELECT * FROM student_advanced_report ORDER BY overall_rank;
SELECT * FROM at_risk_students;
CALL GetDepartmentReport('AIML');
SELECT subject, ROUND(AVG(score),2) AS average_score,
       MAX(score) AS highest_score, MIN(score) AS lowest_score
FROM marks GROUP BY subject ORDER BY average_score DESC;

CALL GetDepartmentReport('CSE');

INSERT INTO marks(student_id, subject, score)
VALUES (1, 'DBMS', 100);