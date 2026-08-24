/*
    Project: TechNova HR & Employee Analytics
    File: 04_Analysis_Queries.sql

    Purpose:
    Contains the complete set of analytical SQL queries developed
    during the project.

    Queries are organized in the same progression used while
    building the project, from basic SQL to advanced analytical
    queries.

    Concepts demonstrated:
    - SELECT
    - WHERE
    - ORDER BY
    - DISTINCT
    - LIKE
    - INNER JOIN
    - LEFT JOIN
    - SELF JOIN
    - GROUP BY
    - HAVING
    - COUNT, SUM, AVG, MIN, MAX
    - CASE expressions
    - COALESCE
    - Scalar subqueries
    - Correlated subqueries
    - IN
    - EXISTS
    - NOT EXISTS
    - Common Table Expressions (CTEs)
    - RANK
    - ROW_NUMBER
    - DENSE_RANK
    - Window functions
    - Date functions
    - NULL handling
    - Composite primary keys
    - Many-to-many relationship analysis
*/


/* ============================================================
   SECTION 1 - Basic Queries
   Queries 1-8
   ============================================================ */


/* ------------------------------------------------------------
   Query 1 - Display all employees
   ------------------------------------------------------------ */

SELECT *
FROM Employees;


/* ------------------------------------------------------------
   Query 2 - Display employee names and locations
   ------------------------------------------------------------ */

SELECT
    EmpName,
    Location
FROM Employees;


/* ------------------------------------------------------------
   Query 3 - Find employees from Noida
   ------------------------------------------------------------ */

SELECT *
FROM Employees
WHERE Location = 'Noida';


/* ------------------------------------------------------------
   Query 4 - Find female employees
   ------------------------------------------------------------ */

SELECT *
FROM Employees
WHERE Gender = 'F';


/* ------------------------------------------------------------
   Query 5 - Display employees alphabetically
   ------------------------------------------------------------ */

SELECT *
FROM Employees
ORDER BY EmpName ASC;


/* ------------------------------------------------------------
   Query 6 - Find employees whose names start with A
   ------------------------------------------------------------ */

SELECT *
FROM Employees
WHERE EmpName LIKE 'A%';


/* ------------------------------------------------------------
   Query 7 - Display unique employee locations
   ------------------------------------------------------------ */

SELECT DISTINCT
    Location
FROM Employees;


/* ------------------------------------------------------------
   Query 8 - Count total employees
   ------------------------------------------------------------ */

SELECT
    COUNT(*) AS EmployeeCount
FROM Employees;


/* ============================================================
   SECTION 2 - GROUP BY and Aggregation
   Queries 9-14
   ============================================================ */


/* ------------------------------------------------------------
   Query 9 - Number of employees in each department
   ------------------------------------------------------------ */

SELECT
    d.DepartmentID,
    d.DepartmentName,
    COUNT(*) AS TotalEmployees
FROM Employees e
INNER JOIN Departments d
    ON e.DepartmentID = d.DepartmentID
GROUP BY
    d.DepartmentID,
    d.DepartmentName;


/* ------------------------------------------------------------
   Query 10 - Number of employees in each location
   ------------------------------------------------------------ */

SELECT
    Location,
    COUNT(*) AS EmployeeCount
FROM Employees
GROUP BY Location;


/* ------------------------------------------------------------
   Query 11 - Departments with more than one employee
   ------------------------------------------------------------ */

SELECT
    d.DepartmentID,
    d.DepartmentName,
    COUNT(*) AS EmployeeCount
FROM Employees e
INNER JOIN Departments d
    ON e.DepartmentID = d.DepartmentID
GROUP BY
    d.DepartmentID,
    d.DepartmentName
HAVING COUNT(*) > 1;


/* ------------------------------------------------------------
   Query 12 - Number of male and female employees
   ------------------------------------------------------------ */

SELECT
    Gender,
    COUNT(*) AS EmployeeCount
FROM Employees
GROUP BY Gender;


/* ------------------------------------------------------------
   Query 13 - Total number of projects
   ------------------------------------------------------------ */

SELECT
    COUNT(*) AS ProjectCount
FROM Projects;


/* ------------------------------------------------------------
   Query 14 - Number of employees assigned to each project
   ------------------------------------------------------------ */

SELECT
    p.ProjectID,
    p.ProjectName,
    COUNT(*) AS EmployeeCount
FROM EmployeeProjects ep
INNER JOIN Projects p
    ON ep.ProjectID = p.ProjectID
GROUP BY
    p.ProjectID,
    p.ProjectName;


/* ============================================================
   SECTION 3 - Salary Analysis
   Queries 15-22
   ============================================================ */


/* ------------------------------------------------------------
   Query 15 - Display each employee's name and salary
   ------------------------------------------------------------ */

SELECT
    e.EmpName,
    s.Salary
FROM Employees e
INNER JOIN Salaries s
    ON e.EmpID = s.EmpID;


/* ------------------------------------------------------------
   Query 16 - Average company salary
   ------------------------------------------------------------ */

SELECT
    AVG(Salary) AS AverageSalary
FROM Salaries;


/* ------------------------------------------------------------
   Query 17 - Highest salary
   ------------------------------------------------------------ */

SELECT
    MAX(Salary) AS HighestSalary
FROM Salaries;


/* ------------------------------------------------------------
   Query 18 - Lowest salary
   ------------------------------------------------------------ */

SELECT
    MIN(Salary) AS LowestSalary
FROM Salaries;


/* ------------------------------------------------------------
   Query 19 - Total company salary expenditure
   ------------------------------------------------------------ */

SELECT
    SUM(Salary) AS TotalSalaryExpenditure
FROM Salaries;


/* ------------------------------------------------------------
   Query 20 - Average salary for each department
   ------------------------------------------------------------ */

SELECT
    d.DepartmentID,
    d.DepartmentName,
    AVG(s.Salary) AS AverageSalary
FROM Employees e
INNER JOIN Departments d
    ON e.DepartmentID = d.DepartmentID
INNER JOIN Salaries s
    ON e.EmpID = s.EmpID
GROUP BY
    d.DepartmentID,
    d.DepartmentName;


/* ------------------------------------------------------------
   Query 21 - Total salary expenditure for each department
   ------------------------------------------------------------ */

SELECT
    d.DepartmentID,
    d.DepartmentName,
    SUM(s.Salary) AS TotalSalaryExpenditure
FROM Employees e
INNER JOIN Departments d
    ON e.DepartmentID = d.DepartmentID
INNER JOIN Salaries s
    ON e.EmpID = s.EmpID
GROUP BY
    d.DepartmentID,
    d.DepartmentName;


/* ------------------------------------------------------------
   Query 22 - Department with the highest average salary
   ------------------------------------------------------------ */

SELECT TOP 1
    d.DepartmentName,
    AVG(s.Salary) AS AverageSalary
FROM Employees e
INNER JOIN Departments d
    ON e.DepartmentID = d.DepartmentID
INNER JOIN Salaries s
    ON e.EmpID = s.EmpID
GROUP BY
    d.DepartmentID,
    d.DepartmentName
ORDER BY AverageSalary DESC;


/* ============================================================
   SECTION 4 - JOINs and LEFT JOINs
   Queries 23-26
   ============================================================ */


/* ------------------------------------------------------------
   Query 23 - Employees and their project names

   Includes employees who are not assigned to any project.
   ------------------------------------------------------------ */

SELECT
    e.EmpID,
    e.EmpName,
    p.ProjectName
FROM Employees e
LEFT JOIN EmployeeProjects ep
    ON e.EmpID = ep.EmployeeID
LEFT JOIN Projects p
    ON ep.ProjectID = p.ProjectID;


/* ------------------------------------------------------------
   Query 24 - Employees without any project assignment
   ------------------------------------------------------------ */

SELECT
    e.EmpID,
    e.EmpName
FROM Employees e
LEFT JOIN EmployeeProjects ep
    ON e.EmpID = ep.EmployeeID
WHERE ep.EmployeeID IS NULL;


/* ------------------------------------------------------------
   Query 25 - Every project and its employee count

   Includes projects with zero employees.

   COUNT(e.EmpID) is used instead of COUNT(*) because a LEFT JOIN
   still produces a row for a project with no matching employee.
   ------------------------------------------------------------ */

SELECT
    p.ProjectID,
    p.ProjectName,
    COUNT(e.EmpID) AS EmployeeCount
FROM Projects p
LEFT JOIN EmployeeProjects ep
    ON ep.ProjectID = p.ProjectID
LEFT JOIN Employees e
    ON e.EmpID = ep.EmployeeID
GROUP BY
    p.ProjectID,
    p.ProjectName;


/* ------------------------------------------------------------
   Query 26 - Employee name, department and salary
   ------------------------------------------------------------ */

SELECT
    e.EmpName,
    d.DepartmentName,
    s.Salary
FROM Employees e
INNER JOIN Departments d
    ON e.DepartmentID = d.DepartmentID
INNER JOIN Salaries s
    ON e.EmpID = s.EmpID;


/* ============================================================
   SECTION 5 - CASE Expressions
   Queries 27-29
   ============================================================ */


/* ------------------------------------------------------------
   Query 27 - Categorize employees into salary bands

   Salary < 60000       -> Low
   Salary 60000-75000   -> Medium
   Salary > 75000       -> High
   ------------------------------------------------------------ */

SELECT
    e.EmpName,
    s.Salary,
    CASE
        WHEN s.Salary > 75000 THEN 'High'
        WHEN s.Salary BETWEEN 60000 AND 75000 THEN 'Medium'
        ELSE 'Low'
    END AS SalaryBand
FROM Employees e
INNER JOIN Salaries s
    ON e.EmpID = s.EmpID
ORDER BY s.Salary;


/* ------------------------------------------------------------
   Query 28 - Number of employees in each salary band

   A derived table is used so that the salary band is calculated
   once and then grouped in the outer query.
   ------------------------------------------------------------ */

SELECT
    SalaryBand,
    COUNT(*) AS TotalEmployees
FROM
(
    SELECT
        CASE
            WHEN Salary > 75000 THEN 'High'
            WHEN Salary BETWEEN 60000 AND 75000 THEN 'Medium'
            ELSE 'Low'
        END AS SalaryBand
    FROM Salaries
) AS SalaryBands
GROUP BY SalaryBand;


/* ------------------------------------------------------------
   Query 29 - Classify employees as High Earner or Regular
   ------------------------------------------------------------ */

SELECT
    e.EmpName,
    s.Salary,
    CASE
        WHEN s.Salary > 75000 THEN 'High Earner'
        ELSE 'Regular'
    END AS EmployeeType
FROM Employees e
INNER JOIN Salaries s
    ON e.EmpID = s.EmpID;


/* ============================================================
   SECTION 6 - Subqueries
   Queries 30-31
   ============================================================ */


/* ------------------------------------------------------------
   Query 30 - Employees earning above the company average
   ------------------------------------------------------------ */

SELECT
    e.EmpID,
    e.EmpName,
    s.Salary
FROM Employees e
INNER JOIN Salaries s
    ON e.EmpID = s.EmpID
WHERE s.Salary >
(
    SELECT AVG(Salary)
    FROM Salaries
);


/* ------------------------------------------------------------
   Query 31 - Employees earning above their department average

   The inner query calculates the average salary of each department.
   The outer query compares each employee against their department's
   corresponding average.
   ------------------------------------------------------------ */

SELECT
    e.EmpID,
    e.EmpName,
    d.DepartmentName,
    s.Salary,
    avgs.DeptAvg
FROM
(
    SELECT
        e.DepartmentID,
        AVG(s.Salary) AS DeptAvg
    FROM Employees e
    INNER JOIN Salaries s
        ON e.EmpID = s.EmpID
    GROUP BY e.DepartmentID
) AS avgs
INNER JOIN Employees e
    ON avgs.DepartmentID = e.DepartmentID
INNER JOIN Departments d
    ON e.DepartmentID = d.DepartmentID
INNER JOIN Salaries s
    ON s.EmpID = e.EmpID
WHERE s.Salary > avgs.DeptAvg;


/* ============================================================
   SECTION 7 - EXISTS, NOT EXISTS and IN
   Queries 32-35
   ============================================================ */


/* ------------------------------------------------------------
   Query 32 - Employees assigned to at least one project

   EXISTS checks whether at least one matching project assignment
   exists for the current employee.
   ------------------------------------------------------------ */

SELECT
    e.EmpID,
    e.EmpName
FROM Employees e
WHERE EXISTS
(
    SELECT 1
    FROM EmployeeProjects ep
    WHERE ep.EmployeeID = e.EmpID
);


/* ------------------------------------------------------------
   Query 33 - Employees not assigned to any project

   NOT EXISTS checks that no matching project assignment exists.
   ------------------------------------------------------------ */

SELECT
    e.EmpID,
    e.EmpName
FROM Employees e
WHERE NOT EXISTS
(
    SELECT 1
    FROM EmployeeProjects ep
    WHERE ep.EmployeeID = e.EmpID
);


/* ------------------------------------------------------------
   Query 34 - Employees assigned to at least one project using IN
   ------------------------------------------------------------ */

SELECT
    *
FROM Employees
WHERE EmpID IN
(
    SELECT EmployeeID
    FROM EmployeeProjects
);


/* ------------------------------------------------------------
   Query 35 - Employees assigned to at least one project using JOIN

   DISTINCT is required because an employee can be assigned to
   multiple projects and therefore appear multiple times after
   the JOIN.
   ------------------------------------------------------------ */

SELECT DISTINCT
    e.EmpID,
    e.EmpName
FROM Employees e
INNER JOIN EmployeeProjects ep
    ON e.EmpID = ep.EmployeeID;


/* ============================================================
   SECTION 8 - Common Table Expressions
   Queries 36-37
   ============================================================ */


/* ------------------------------------------------------------
   Query 36 - Employees earning above their department average

   This is the CTE version of Query 31.
   ------------------------------------------------------------ */

WITH AvgSalary AS
(
    SELECT
        e.DepartmentID,
        AVG(s.Salary) AS AvgOfDept
    FROM Employees e
    INNER JOIN Salaries s
        ON e.EmpID = s.EmpID
    GROUP BY e.DepartmentID
)
SELECT
    e.EmpID,
    e.EmpName,
    e.DepartmentID,
    s.Salary,
    a.AvgOfDept
FROM Employees e
INNER JOIN AvgSalary a
    ON a.DepartmentID = e.DepartmentID
INNER JOIN Salaries s
    ON s.EmpID = e.EmpID
WHERE s.Salary > a.AvgOfDept;


/* ------------------------------------------------------------
   Query 37 - Highest-paid employee in every department

   All employees tied at the highest salary are returned.
   ------------------------------------------------------------ */

WITH MaxSalary AS
(
    SELECT
        e.DepartmentID,
        d.DepartmentName,
        MAX(s.Salary) AS MaxOfDept
    FROM Employees e
    INNER JOIN Salaries s
        ON e.EmpID = s.EmpID
    INNER JOIN Departments d
        ON d.DepartmentID = e.DepartmentID
    GROUP BY
        e.DepartmentID,
        d.DepartmentName
)
SELECT
    e.EmpID,
    e.EmpName,
    s.Salary,
    m.DepartmentName,
    m.MaxOfDept
FROM Employees e
INNER JOIN Salaries s
    ON s.EmpID = e.EmpID
INNER JOIN MaxSalary m
    ON m.DepartmentID = e.DepartmentID
WHERE s.Salary = m.MaxOfDept;


/* ============================================================
   SECTION 9 - Window Functions
   Queries 38-41
   ============================================================ */


/* ------------------------------------------------------------
   Query 38 - Rank employees by salary within each department
   ------------------------------------------------------------ */

SELECT
    e.EmpID,
    e.EmpName,
    d.DepartmentName,
    s.Salary,
    RANK() OVER
    (
        PARTITION BY e.DepartmentID
        ORDER BY s.Salary DESC
    ) AS EmpRank
FROM Employees e
INNER JOIN Salaries s
    ON e.EmpID = s.EmpID
INNER JOIN Departments d
    ON d.DepartmentID = e.DepartmentID;


/* ------------------------------------------------------------
   Query 39 - Top 2 salary ranks in every department

   RANK is used, so employees tied at rank 2 are all returned.
   Therefore more than two employees can be returned for a department.
   ------------------------------------------------------------ */

WITH RankedData AS
(
    SELECT
        e.EmpID,
        e.EmpName,
        d.DepartmentName,
        s.Salary,
        RANK() OVER
        (
            PARTITION BY e.DepartmentID
            ORDER BY s.Salary DESC
        ) AS EmpRank
    FROM Employees e
    INNER JOIN Salaries s
        ON e.EmpID = s.EmpID
    INNER JOIN Departments d
        ON d.DepartmentID = e.DepartmentID
)
SELECT
    EmpID,
    EmpName,
    DepartmentName,
    Salary,
    EmpRank
FROM RankedData
WHERE EmpRank <= 2;


/* ------------------------------------------------------------
   Query 40 - Exactly two highest-paid employees per department

   ROW_NUMBER gives each employee a unique position within the
   department.

   EmpID is used as a secondary sort key so that ties in salary
   produce a deterministic result.
   ------------------------------------------------------------ */

WITH EmployeeRank AS
(
    SELECT
        e.EmpID,
        e.EmpName,
        d.DepartmentName,
        s.Salary,
        ROW_NUMBER() OVER
        (
            PARTITION BY e.DepartmentID
            ORDER BY s.Salary DESC, e.EmpID
        ) AS EmpRankNo
    FROM Employees e
    INNER JOIN Salaries s
        ON e.EmpID = s.EmpID
    INNER JOIN Departments d
        ON d.DepartmentID = e.DepartmentID
)
SELECT
    EmpID,
    EmpName,
    DepartmentName,
    Salary,
    EmpRankNo
FROM EmployeeRank
WHERE EmpRankNo <= 2;


/* ------------------------------------------------------------
   Query 41 - Compare ROW_NUMBER, RANK and DENSE_RANK

   The three ranking functions are calculated separately within
   each department so that the behavior of ties can be compared.
   ------------------------------------------------------------ */

SELECT
    e.EmpID,
    e.EmpName,
    d.DepartmentName,
    s.Salary,
    ROW_NUMBER() OVER
    (
        PARTITION BY e.DepartmentID
        ORDER BY s.Salary DESC
    ) AS RowNo,
    RANK() OVER
    (
        PARTITION BY e.DepartmentID
        ORDER BY s.Salary DESC
    ) AS RankNo,
    DENSE_RANK() OVER
    (
        PARTITION BY e.DepartmentID
        ORDER BY s.Salary DESC
    ) AS DenseRankNo
FROM Employees e
INNER JOIN Salaries s
    ON e.EmpID = s.EmpID
INNER JOIN Departments d
    ON d.DepartmentID = e.DepartmentID;


/* ============================================================
   SECTION 10 - Date Analysis
   Queries 42-46
   ============================================================ */


/* ------------------------------------------------------------
   Query 42 - Employees who joined on or after January 1, 2024
   ------------------------------------------------------------ */

SELECT
    *
FROM Employees
WHERE HireDate >= '2024-01-01';


/* ------------------------------------------------------------
   Query 43 - Number of employees hired in each year
   ------------------------------------------------------------ */

SELECT
    YEAR(HireDate) AS HireYear,
    COUNT(*) AS EmployeeCount
FROM Employees
GROUP BY YEAR(HireDate)
ORDER BY HireYear;


/* ------------------------------------------------------------
   Query 44 - Employees ordered by longest tenure

   Days worked is used because it gives a direct elapsed-day
   measurement without the year-boundary issue associated with
   DATEDIFF(YEAR, ...).
   ------------------------------------------------------------ */

SELECT
    *,
    DATEDIFF(DAY, HireDate, GETDATE()) AS DaysWorked
FROM Employees
ORDER BY DaysWorked DESC;


/* ------------------------------------------------------------
   Query 45 - Employee tenure in completed years

   DATEDIFF(YEAR, ...) counts year boundaries rather than completed
   anniversary years. The calculation below adjusts the result when
   the employee has not yet reached their anniversary date.
   ------------------------------------------------------------ */

SELECT
    EmpName,
    HireDate,
    DATEDIFF(YEAR, HireDate, GETDATE())
    -
    CASE
        WHEN DATEADD
        (
            YEAR,
            DATEDIFF(YEAR, HireDate, GETDATE()),
            HireDate
        ) > GETDATE()
        THEN 1
        ELSE 0
    END AS YearsWorked
FROM Employees;


/* ------------------------------------------------------------
   Query 46 - Average employee tenure by department
   ------------------------------------------------------------ */

SELECT
    d.DepartmentID,
    d.DepartmentName,
    AVG
    (
        DATEDIFF(DAY, e.HireDate, GETDATE())
    ) AS AverageTenureDays
FROM Employees e
INNER JOIN Departments d
    ON e.DepartmentID = d.DepartmentID
GROUP BY
    d.DepartmentID,
    d.DepartmentName
ORDER BY AverageTenureDays DESC;


/* ============================================================
   SECTION 11 - NULL Handling and Self Joins
   Queries 47-50
   ============================================================ */


/* ------------------------------------------------------------
   Query 47 - Employees without a manager
   ------------------------------------------------------------ */

SELECT
    EmpID,
    EmpName,
    ManagerID
FROM Employees
WHERE ManagerID IS NULL;


/* ------------------------------------------------------------
   Query 48 - Employees who have a manager
   ------------------------------------------------------------ */

SELECT
    EmpID,
    EmpName,
    ManagerID
FROM Employees
WHERE ManagerID IS NOT NULL;


/* ------------------------------------------------------------
   Query 49 - Employee and manager name

   Employees who have no manager are excluded because an INNER JOIN
   is used.
   ------------------------------------------------------------ */

SELECT
    e.EmpID,
    e.EmpName,
    e.ManagerID,
    m.EmpName AS ManagerName
FROM Employees e
INNER JOIN Employees m
    ON e.ManagerID = m.EmpID;


/* ------------------------------------------------------------
   Query 50 - Employee and manager name with Top Level label

   LEFT JOIN keeps top-level employees in the result.
   COALESCE replaces NULL manager names with 'Top Level'.
   ------------------------------------------------------------ */

SELECT
    e.EmpID,
    e.EmpName,
    e.ManagerID,
    COALESCE(m.EmpName, 'Top Level') AS ManagerName
FROM Employees e
LEFT JOIN Employees m
    ON e.ManagerID = m.EmpID;


/* ============================================================
   SECTION 12 - Advanced Business Questions
   Queries 51-56
   ============================================================ */


/* ------------------------------------------------------------
   Query 51 - Top 3 highest-paid employees in the company,
   including ties

   RANK is used so employees with the same salary receive the
   same rank and all employees within the top three ranks are
   returned.
   ------------------------------------------------------------ */

WITH RankedData AS
(
    SELECT
        e.EmpID,
        e.EmpName,
        s.Salary,
        RANK() OVER
        (
            ORDER BY s.Salary DESC
        ) AS RankEmp
    FROM Employees e
    INNER JOIN Salaries s
        ON e.EmpID = s.EmpID
)
SELECT
    EmpID,
    EmpName,
    Salary,
    RankEmp
FROM RankedData
WHERE RankEmp <= 3;


/* ------------------------------------------------------------
   Query 52 - Department with the highest total salary expenditure
   ------------------------------------------------------------ */

SELECT TOP 1
    d.DepartmentID,
    d.DepartmentName,
    SUM(s.Salary) AS TotalSalaryExpenditure
FROM Employees e
INNER JOIN Salaries s
    ON e.EmpID = s.EmpID
INNER JOIN Departments d
    ON d.DepartmentID = e.DepartmentID
GROUP BY
    d.DepartmentID,
    d.DepartmentName
ORDER BY TotalSalaryExpenditure DESC;


/* ------------------------------------------------------------
   Query 53 - Employees earning above their department average
   and assigned to at least one project

   EXISTS is used because the requirement is only to verify that
   at least one project assignment exists. Project details are not
   required in the final result.

   This avoids duplicate employee rows when an employee has
   multiple project assignments.
   ------------------------------------------------------------ */

WITH DeptAvg AS
(
    SELECT
        e.DepartmentID,
        AVG(s.Salary) AS AvgSalary
    FROM Employees e
    INNER JOIN Salaries s
        ON s.EmpID = e.EmpID
    GROUP BY e.DepartmentID
)
SELECT
    e.EmpID,
    e.EmpName,
    s.Salary,
    d.AvgSalary
FROM Employees e
INNER JOIN DeptAvg d
    ON e.DepartmentID = d.DepartmentID
INNER JOIN Salaries s
    ON s.EmpID = e.EmpID
WHERE s.Salary > d.AvgSalary
  AND EXISTS
  (
      SELECT 1
      FROM EmployeeProjects ep
      WHERE ep.EmployeeID = e.EmpID
  );


/* ------------------------------------------------------------
   Query 54 - Departments that have no employees assigned to
   any project

   NOT EXISTS is used to ensure that there is no employee within
   the department who has a project assignment.
   ------------------------------------------------------------ */

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


/* ------------------------------------------------------------
   Query 55 - Second-highest salary in each department

   RANK is used so employees tied at the second-highest salary
   are all returned.
   ------------------------------------------------------------ */

SELECT
    DepartmentID,
    DepartmentName,
    Salary
FROM
(
    SELECT
        d.DepartmentID,
        d.DepartmentName,
        s.Salary,
        RANK() OVER
        (
            PARTITION BY d.DepartmentID
            ORDER BY s.Salary DESC
        ) AS SalaryRank
    FROM Employees e
    INNER JOIN Departments d
        ON e.DepartmentID = d.DepartmentID
    INNER JOIN Salaries s
        ON s.EmpID = e.EmpID
) AS SalaryData
WHERE SalaryRank = 2;


/* ------------------------------------------------------------
   Query 56 - Department salary summary

   Shows:
   - Department name
   - Employee count
   - Average salary
   - Highest salary
   - Lowest salary
   - Total salary

   The query uses LEFT JOIN so departments with no employees
   can still appear in the result.
   ------------------------------------------------------------ */

SELECT
    d.DepartmentName,
    COUNT(DISTINCT e.EmpID) AS EmployeeCount,
    AVG(s.Salary) AS AverageSalary,
    MAX(s.Salary) AS HighestSalary,
    MIN(s.Salary) AS LowestSalary,
    SUM(s.Salary) AS TotalSalary
FROM Departments d
LEFT JOIN Employees e
    ON e.DepartmentID = d.DepartmentID
LEFT JOIN Salaries s
    ON s.EmpID = e.EmpID
GROUP BY
    d.DepartmentID,
    d.DepartmentName
ORDER BY TotalSalary DESC;