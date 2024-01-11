-- -----------------------------------------
-- Demonstrating before_project_update trigger and the use of WHERE...LIKE

UPDATE project
SET deadline = '2023-12-24'
WHERE projectName LIKE 'Polymorph%';

SELECT 
	projectName AS 'Project', 
    screenType AS 'Screen Type', 
    deadline AS 'Deadline', 
    overseer AS 'Overseer ID', 
    action AS 'Action Performed', 
    dateOfChange AS 'Time Change was Implemented'
    FROM project_history;

-- -----------------------------------------
-- Query to find instruments that are overdue maintenance, demonstrating date functions

SELECT instrumentName AS 'Instrument', manufacturer AS 'Manufacturer', location AS 'Location', DATEDIFF(CURDATE(), maintenanceDate)
AS "Days Maintenance Overdue"
FROM Instrument
WHERE maintenanceDate < NOW();

-- -----------------------------------------
-- Query to find analysts who are currently underutilised, i.e. working on less than 2 experiments.
-- Demonstrates GROUP BY, GROUP BY...HAVING and aggregate function COUNT

SELECT CONCAT(fName, ' ', lName) AS "Name", COUNT(analyst) AS 'Assigned Experiments'
	FROM Staff JOIN carriesOut
    ON carriesOut.employeeId = Staff.employeeId
    GROUP BY analyst, name
    HAVING COUNT(analyst) < 2
	ORDER BY analyst, name;

-- -----------------------------------------
-- Query to find the names of managers currently working on projects, demonstrating a subquery and WHERE...IN

SELECT CONCAT(fName, ' ', lName) AS "Staff Currently Overseeing a Project:" 
FROM Staff
WHERE employeeId IN 
(SELECT overseer
FROM Project);

-- -----------------------------------------
-- Query to find all projects - including projects that do not have an overseer assigned, if one was forgotten.
-- Demonstrates a right outer join.

SELECT projectName AS 'Project', customerName AS 'Client', deadline AS 'Deadline', CONCAT(fName, ' ', lName) AS "Overseer Assigned"
FROM Staff 
RIGHT JOIN Project 
ON Staff.employeeId = Project.overseer
ORDER BY CONCAT(fName, ' ', lName);

-- -----------------------------------------
-- Query to find all projects who have deadlines in December, demonstrating WHERE...BETWEEN

SELECT projectName AS 'Project', customerName AS 'Client', deadline AS 'Deadline'
FROM Project
WHERE deadline BETWEEN '2023-12-01' AND '2023-12-31'
ORDER BY deadline;