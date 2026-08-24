/*
    Project: TechNova HR & Employee Analytics
    File: 06_Verification_Queries.sql

    Purpose:
    Contains validation queries used to verify that the database
    was created correctly, the expected sample data was inserted,
    and the main relationships are working as intended.

    These queries are intended for development/testing purposes.
    They do not modify any data.
*/


/* ============================================================
   1. Verify Table Row Counts
   ============================================================

   Purpose:

   Confirms that the expected number of records were inserted
   into each table after running 02_Create_Tables.sql and
   03_Insert_Data.sql.

   Expected counts for the sample dataset:

   Departments       -> 5
   Employees         -> 10
   Projects          -> 5
   Salaries          -> 10
   EmployeeProjects  -> 12

   Why this matters:

   If the counts do not match, the seed data may not have been
   inserted completely or the script may have been executed in
   an incorrect state.
   ============================================================ */

SELECT
    COUNT(*) AS DepartmentCount
FROM Departments;

SELECT
    COUNT(*) AS EmployeeCount
FROM Employees;

SELECT
    COUNT(*) AS ProjectCount
FROM Projects;

SELECT
    COUNT(*) AS SalaryCount
FROM Salaries;

SELECT
    COUNT(*) AS AssignmentCount
FROM EmployeeProjects;


/* ============================================================
   2. Verify Employee, Department and Salary Relationship
   ============================================================

   Purpose:

   Confirms that every employee can be correctly linked to both
   an existing department and a salary record.

   Why this matters:

   This validates the foreign key relationships:

       Employees.DepartmentID -> Departments.DepartmentID
       Salaries.EmpID -> Employees.EmpID

   The result should contain 10 employees for the current
   sample dataset.
   ============================================================ */

SELECT
    e.EmpID,
    e.EmpName,
    d.DepartmentName,
    s.Salary
FROM Employees e
INNER JOIN Departments d
    ON e.DepartmentID = d.DepartmentID
INNER JOIN Salaries s
    ON e.EmpID = s.EmpID
ORDER BY e.EmpID;


/* ============================================================
   3. Verify Employee and Project Relationship
   ============================================================

   Purpose:

   Confirms that employee-project assignments are correctly
   connected through the EmployeeProjects bridge table.

   LEFT JOIN is intentionally used so that employees without
   a project assignment are also visible.

   In the sample dataset, Pooja Nair should appear with a NULL
   ProjectName.

   Why this matters:

   This validates the many-to-many relationship:

       Employees
           ->
       EmployeeProjects
           ->
       Projects
   ============================================================ */

SELECT
    e.EmpID,
    e.EmpName,
    p.ProjectName
FROM Employees e
LEFT JOIN EmployeeProjects ep
    ON e.EmpID = ep.EmployeeID
LEFT JOIN Projects p
    ON ep.ProjectID = p.ProjectID
ORDER BY e.EmpID;


/* ============================================================
   4. Verify Employee Manager Relationship
   ============================================================

   Purpose:

   Confirms that the self-referencing ManagerID relationship
   works correctly.

   The Employees table references itself:

       Employees.ManagerID -> Employees.EmpID

   LEFT JOIN is used so that top-level employees are also shown.

   In the sample dataset, Amit Sharma is the top-level employee
   and should therefore display "Top Level".
   ============================================================ */

SELECT
    e.EmpID,
    e.EmpName AS Employee,
    COALESCE(m.EmpName, 'Top Level') AS Manager
FROM Employees e
LEFT JOIN Employees m
    ON e.ManagerID = m.EmpID
ORDER BY e.EmpID;


/* ============================================================
   5. Verify Departments Without Project Assignments
   ============================================================

   Purpose:

   Identifies departments for which no employee currently has
   a project assignment.

   This acts as a higher-level validation of the relationship
   between Departments, Employees and EmployeeProjects.

   Why this matters:

   It confirms that the many-to-many project relationship can
   be queried correctly at the department level.
   ============================================================ */

SELECT
    d.DepartmentID,
    d.DepartmentName
FROM Departments d
WHERE NOT EXISTS
(
    SELECT 1
    FROM Employees e
    INNER JOIN EmployeeProjects ep
        ON ep.EmployeeID = e.EmpID
    WHERE e.DepartmentID = d.DepartmentID
);


/* ============================================================
   6. Verify Foreign Key Integrity through Orphan Checks
   ============================================================

   Purpose:

   Checks for records that have no valid parent record.

   In a correctly configured database, these queries should
   return zero rows.

   The checks validate:

       Employees -> Departments
       Salaries -> Employees
       EmployeeProjects -> Employees
       EmployeeProjects -> Projects
       Employees.ManagerID -> Employees
   ============================================================ */


/* Employees with an invalid DepartmentID */

SELECT
    e.EmpID,
    e.EmpName,
    e.DepartmentID
FROM Employees e
LEFT JOIN Departments d
    ON e.DepartmentID = d.DepartmentID
WHERE d.DepartmentID IS NULL;


/* Salaries with an invalid Employee ID */

SELECT
    s.SalaryID,
    s.EmpID
FROM Salaries s
LEFT JOIN Employees e
    ON s.EmpID = e.EmpID
WHERE e.EmpID IS NULL;


/* Employee-project assignments with an invalid Employee ID */

SELECT
    ep.EmployeeID,
    ep.ProjectID
FROM EmployeeProjects ep
LEFT JOIN Employees e
    ON ep.EmployeeID = e.EmpID
WHERE e.EmpID IS NULL;


/* Employee-project assignments with an invalid Project ID */

SELECT
    ep.EmployeeID,
    ep.ProjectID
FROM EmployeeProjects ep
LEFT JOIN Projects p
    ON ep.ProjectID = p.ProjectID
WHERE p.ProjectID IS NULL;


/* Employees with an invalid ManagerID */

SELECT
    e.EmpID,
    e.EmpName,
    e.ManagerID
FROM Employees e
LEFT JOIN Employees m
    ON e.ManagerID = m.EmpID
WHERE e.ManagerID IS NOT NULL
  AND m.EmpID IS NULL;


/* ============================================================
   7. Verify Duplicate Employee-Project Assignments
   ============================================================

   Purpose:

   Confirms that an employee has not been assigned to the same
   project more than once.

   The database's composite primary key:

       (EmployeeID, ProjectID)

   should already prevent duplicates.

   This query acts as an additional validation check.

   Expected result:
   Zero rows.
   ============================================================ */

SELECT
    EmployeeID,
    ProjectID,
    COUNT(*) AS AssignmentCount
FROM EmployeeProjects
GROUP BY
    EmployeeID,
    ProjectID
HAVING COUNT(*) > 1;


/* ============================================================
   8. Verify Salary Records per Employee
   ============================================================

   Purpose:

   Shows the number of salary records associated with each
   employee.

   This is useful because the Salaries table was designed to
   support salary history through EffectiveDate.

   The current sample dataset contains one salary record per
   employee.

   Multiple records for an employee would be valid in a future
   version of the project when salary revisions are introduced.
   ============================================================ */

SELECT
    e.EmpID,
    e.EmpName,
    COUNT(s.SalaryID) AS SalaryRecordCount
FROM Employees e
LEFT JOIN Salaries s
    ON e.EmpID = s.EmpID
GROUP BY
    e.EmpID,
    e.EmpName
ORDER BY e.EmpID;