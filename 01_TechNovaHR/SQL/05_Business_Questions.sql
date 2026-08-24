/*
    Project: TechNova HR & Employee Analytics
    File: 05_Business_Questions.sql

    Purpose:
    Contains advanced, business-oriented SQL questions that combine
    multiple SQL concepts learned throughout the project.

    These queries are designed to demonstrate the ability to
    translate business requirements into practical SQL solutions.

    Concepts demonstrated:
    - JOINs
    - LEFT JOIN
    - GROUP BY
    - Aggregate functions
    - CTEs
    - Scalar and correlated subqueries
    - EXISTS
    - NOT EXISTS
    - DISTINCT
    - Date calculations
    - Window functions
    - RANK
*/


/* ============================================================
   Query 57 - Top 3 departments by total salary expenditure
   ============================================================

   Business question:

   Find the top 3 departments based on total salary expenditure.

   Approach:
   - Join employees with salaries and departments.
   - Calculate total salary per department.
   - Sort departments by total salary in descending order.
   - Return the top 3 departments.
   ============================================================ */

SELECT TOP 3
    d.DepartmentID,
    d.DepartmentName,
    SUM(s.Salary) AS TotalSalaryExpenditure
FROM Departments d
INNER JOIN Employees e
    ON d.DepartmentID = e.DepartmentID
INNER JOIN Salaries s
    ON e.EmpID = s.EmpID
GROUP BY
    d.DepartmentID,
    d.DepartmentName
ORDER BY TotalSalaryExpenditure DESC;


/* ============================================================
   Query 58 - Highest-paid employee in each department
   ============================================================

   Business question:

   Find the highest-paid employee in every department,
   including employees tied at the highest salary.

   Approach:
   - Calculate the maximum salary for each department.
   - Match employees against that maximum salary.
   - Since equality is used against the maximum, all employees
     tied at the highest salary are returned.
   ============================================================ */

WITH DepartmentMaximum AS
(
    SELECT
        DepartmentID,
        MAX(Salary) AS MaximumSalary
    FROM Employees e
    INNER JOIN Salaries s
        ON e.EmpID = s.EmpID
    GROUP BY DepartmentID
)
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
INNER JOIN DepartmentMaximum dm
    ON e.DepartmentID = dm.DepartmentID
WHERE s.Salary = dm.MaximumSalary;


/* ============================================================
   Query 59 - Above company average but below department maximum
   ============================================================

   Business question:

   Find employees whose salary is:
   1. Greater than the company-wide average salary.
   2. Less than the maximum salary in their own department.

   This identifies employees who are relatively high earners
   company-wide but are not the highest-paid employees in their
   own department.
   ============================================================ */

WITH DepartmentMaximum AS
(
    SELECT
        e.DepartmentID,
        MAX(s.Salary) AS MaximumDepartmentSalary
    FROM Employees e
    INNER JOIN Salaries s
        ON e.EmpID = s.EmpID
    GROUP BY e.DepartmentID
)
SELECT
    e.EmpID,
    e.EmpName,
    d.DepartmentName,
    s.Salary,
    dm.MaximumDepartmentSalary,
    CompanyAverage.AverageCompanySalary
FROM Employees e
INNER JOIN Departments d
    ON e.DepartmentID = d.DepartmentID
INNER JOIN Salaries s
    ON e.EmpID = s.EmpID
INNER JOIN DepartmentMaximum dm
    ON e.DepartmentID = dm.DepartmentID
CROSS JOIN
(
    SELECT
        AVG(Salary) AS AverageCompanySalary
    FROM Salaries
) AS CompanyAverage
WHERE s.Salary > CompanyAverage.AverageCompanySalary
  AND s.Salary < dm.MaximumDepartmentSalary;


/* ============================================================
   Query 60 - Employees never assigned to a project
   ============================================================

   Business question:

   Find employees who have never been assigned to any project.

   NOT EXISTS is appropriate because we only need to determine
   whether at least one project assignment exists for an employee.
   No project information is required in the final result.
   ============================================================ */

SELECT
    e.EmpID,
    e.EmpName,
    d.DepartmentName
FROM Employees e
INNER JOIN Departments d
    ON e.DepartmentID = d.DepartmentID
WHERE NOT EXISTS
(
    SELECT 1
    FROM EmployeeProjects ep
    WHERE ep.EmployeeID = e.EmpID
);


/* ============================================================
   Query 61 - Department with the highest average employee tenure
   ============================================================

   Business question:

   Find the department with the highest average employee tenure.

   Tenure is calculated in days from HireDate until the current date.

   The department with the largest average tenure is returned.
   ============================================================ */

SELECT TOP 1
    d.DepartmentID,
    d.DepartmentName,
    AVG(DATEDIFF(DAY, e.HireDate, GETDATE())) AS AverageTenureDays
FROM Departments d
INNER JOIN Employees e
    ON d.DepartmentID = e.DepartmentID
GROUP BY
    d.DepartmentID,
    d.DepartmentName
ORDER BY AverageTenureDays DESC;


/* ============================================================
   Query 62 - Department-level employee, project and salary summary
   ============================================================

   Business question:

   For every department, show:
   - DepartmentName
   - EmployeeCount
   - ProjectCount
   - AverageSalary

   Important consideration:

   Employees can participate in multiple projects.

   Joining all three entities directly can multiply employee rows,
   which can incorrectly affect employee counts and salary
   calculations.

   Separate CTEs are therefore used to calculate employee/project
   information independently before combining the results.
   ============================================================ */

WITH EmployeeSummary AS
(
    SELECT
        e.DepartmentID,
        COUNT(*) AS EmployeeCount,
        AVG(s.Salary) AS AverageSalary
    FROM Employees e
    INNER JOIN Salaries s
        ON e.EmpID = s.EmpID
    GROUP BY e.DepartmentID
),
ProjectSummary AS
(
    SELECT
        e.DepartmentID,
        COUNT(DISTINCT ep.ProjectID) AS ProjectCount
    FROM Employees e
    INNER JOIN EmployeeProjects ep
        ON e.EmpID = ep.EmployeeID
    GROUP BY e.DepartmentID
)
SELECT
    d.DepartmentID,
    d.DepartmentName,
    COALESCE(es.EmployeeCount, 0) AS EmployeeCount,
    COALESCE(ps.ProjectCount, 0) AS ProjectCount,
    es.AverageSalary
FROM Departments d
LEFT JOIN EmployeeSummary es
    ON d.DepartmentID = es.DepartmentID
LEFT JOIN ProjectSummary ps
    ON d.DepartmentID = ps.DepartmentID
ORDER BY d.DepartmentID;


/* ============================================================
   Query 63 - Employees with more projects than the average
   ============================================================

   Business question:

   Find employees who are assigned to more projects than the
   average number of projects assigned per employee.

   The calculation is performed in three logical steps:

   1. Count projects for every employee.
   2. Calculate the average of those project counts.
   3. Return employees whose count is above that average.

   Employees with no projects are included with a project count
   of zero.
   ============================================================ */

WITH EmployeeProjectCount AS
(
    SELECT
        e.EmpID,
        e.EmpName,
        COUNT(ep.ProjectID) AS ProjectCount
    FROM Employees e
    LEFT JOIN EmployeeProjects ep
        ON e.EmpID = ep.EmployeeID
    GROUP BY
        e.EmpID,
        e.EmpName
),
AverageProjectCount AS
(
    SELECT
        AVG(CAST(ProjectCount AS DECIMAL(10,2))) AS AverageProjects
    FROM EmployeeProjectCount
)
SELECT
    epc.EmpID,
    epc.EmpName,
    epc.ProjectCount,
    apc.AverageProjects
FROM EmployeeProjectCount epc
CROSS JOIN AverageProjectCount apc
WHERE epc.ProjectCount > apc.AverageProjects
ORDER BY epc.ProjectCount DESC;


/* ============================================================
   Query 64 - Employee salary analysis
   ============================================================

   Business question:

   For every employee, show:
   - EmpName
   - DepartmentName
   - Salary
   - DepartmentAverageSalary
   - SalaryDifference
   - SalaryRankWithinDepartment

   SalaryDifference is calculated as:

       Employee Salary - Department Average Salary

   RANK is used so employees with the same salary receive the
   same rank within their department.
   ============================================================ */

WITH DepartmentAverage AS
(
    SELECT
        e.DepartmentID,
        AVG(s.Salary) AS DepartmentAverageSalary
    FROM Employees e
    INNER JOIN Salaries s
        ON e.EmpID = s.EmpID
    GROUP BY e.DepartmentID
)
SELECT
    e.EmpName,
    d.DepartmentName,
    s.Salary,
    da.DepartmentAverageSalary,
    s.Salary - da.DepartmentAverageSalary AS SalaryDifference,
    RANK() OVER
    (
        PARTITION BY e.DepartmentID
        ORDER BY s.Salary DESC
    ) AS SalaryRankWithinDepartment
FROM Employees e
INNER JOIN Departments d
    ON e.DepartmentID = d.DepartmentID
INNER JOIN Salaries s
    ON e.EmpID = s.EmpID
INNER JOIN DepartmentAverage da
    ON e.DepartmentID = da.DepartmentID
ORDER BY
    d.DepartmentName,
    SalaryRankWithinDepartment;