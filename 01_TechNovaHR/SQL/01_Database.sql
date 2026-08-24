-- ==============================================================================
-- DATABASE CREATION & SETUP
-- ==============================================================================

-- Create the company HR database
CREATE DATABASE TechNovaHR;
GO

-- Switch execution context to TechNovaHR
USE TechNovaHR;
GO

-- Verify the current active database context
SELECT DB_NAME() AS currentdatabase;


-- ==============================================================================
-- SCHEMA DEFINITION (TABLES & CONSTRAINTS)
-- ==============================================================================

-- 1. Departments Table (Parent entity for departmental structure)
CREATE TABLE Departments (
    DepartmentID INT PRIMARY KEY IDENTITY(1,1),
    DepartmentName VARCHAR(50) NOT NULL UNIQUE,
    Location VARCHAR(50) NOT NULL
);

-- Conceptual Notes:
-- 1. Why does DepartmentID belong in Employees, rather than EmployeeID belonging in Departments?
--    One department can have many employees, but each employee belongs to one department.
--    In a one-to-many relationship, the foreign key is normally stored on the "many" side.
-- 2. What should happen if we try to insert an employee with DepartmentID = 99, when department 99 doesn't exist?
--    INSERT fails with a foreign key constraint violation.

-- 2. Employees Table (Child of Departments, Parent to EmployeeProjects)
CREATE TABLE Employees (
    EmpID INT PRIMARY KEY IDENTITY(1,1),
    EmpName VARCHAR(50) NOT NULL,
    Gender CHAR(1) NOT NULL CHECK (Gender IN ('M','F')),
    MobNo VARCHAR(15) NOT NULL UNIQUE,
    Email VARCHAR(100) NOT NULL UNIQUE,
    Location VARCHAR(50) NOT NULL,
    DepartmentID INT NOT NULL,

    -- Enforce referential integrity with Departments
    CONSTRAINT fk_Employees_Department FOREIGN KEY (DepartmentID) 
        REFERENCES Departments(DepartmentID)
);

-- 3. Projects Table (Independent entity for projects)
CREATE TABLE Projects (
    ProjectID INT PRIMARY KEY IDENTITY(1,1),
    ProjectName VARCHAR(50) NOT NULL UNIQUE,
    Location VARCHAR(50) NOT NULL
);

-- 4. EmployeeProjects Table (Junction/Bridge table establishing a Many-to-Many relationship)
CREATE TABLE EmployeeProjects (
    EmployeeID INT NOT NULL,
    ProjectID INT NOT NULL,
    -- Composite Primary Key to prevent duplicate project assignments
    CONSTRAINT pk_EmployeeProjects PRIMARY KEY (EmployeeID, ProjectID),
    CONSTRAINT fk_EmployeeProjects_Employees FOREIGN KEY (EmployeeID) 
        REFERENCES Employees(EmpID),
    CONSTRAINT fk_EmployeeProjects_Projects FOREIGN KEY (ProjectID) 
        REFERENCES Projects(ProjectID)
);


-- ==============================================================================
-- DATA INSERTION (SEED DATA)
-- ==============================================================================

-- Insert sample records into Departments
INSERT INTO Departments (DepartmentName, Location)
VALUES
('Engineering', 'Noida'),
('Human Resources', 'Gurgaon'),
('Finance', 'Delhi'),
('Marketing', 'Noida'),
('IT Support', 'Bangalore');

-- Insert sample records into Employees
INSERT INTO Employees (EmpName, Gender, MobNo, Email, Location, DepartmentID)
VALUES
('Amit Sharma', 'M', '9876543210', 'amit@technova.com', 'Noida', 1),
('Priya Singh', 'F', '9876543211', 'priya@technova.com', 'Delhi', 1),
('Rahul Verma', 'M', '9876543212', 'rahul@technova.com', 'Noida', 1),
('Neha Gupta', 'F', '9876543213', 'neha@technova.com', 'Gurgaon', 2),
('Rohit Kumar', 'M', '9876543214', 'rohit@technova.com', 'Delhi', 3),
('Sneha Roy', 'F', '9876543215', 'sneha@technova.com', 'Noida', 4),
('Karan Mehta', 'M', '9876543216', 'karan@technova.com', 'Bangalore', 5),
('Anjali Das', 'F', '9876543217', 'anjali@technova.com', 'Gurgaon', 2),
('Vikas Jain', 'M', '9876543218', 'vikas@technova.com', 'Noida', 4),
('Pooja Nair', 'F', '9876543219', 'pooja@technova.com', 'Bangalore', 5);

-- Insert sample records into Projects
INSERT INTO Projects (ProjectName, Location)
VALUES
('E-Commerce Platform', 'Noida'),
('Employee Portal', 'Gurgaon'),
('Financial Reporting System', 'Delhi'),
('Marketing Automation', 'Noida'),
('IT Helpdesk Upgrade', 'Bangalore');

-- Insert project allocation records (Many-to-Many mappings)
INSERT INTO EmployeeProjects (EmployeeID, ProjectID)
VALUES
(1, 1),
(1, 2),
(2, 1),
(2, 3),
(3, 1),
(3, 5),
(4, 2),
(5, 3),
(6, 4),
(7, 5),
(8, 2),
(9, 4);


-- ==============================================================================
-- BASIC VERIFICATION & JOIN QUERIES
-- ==============================================================================

-- Select all records to verify data loading across tables
SELECT * FROM Departments;
SELECT * FROM Employees;
SELECT * FROM Projects;
SELECT * FROM EmployeeProjects;

-- Basic INNER JOIN to combine Employee and Department details
SELECT * 
FROM Employees e 
INNER JOIN Departments d ON e.DepartmentID = d.DepartmentID;

-- Selective projection using INNER JOIN
SELECT 
    e.EmpID, 
    e.EmpName, 
    d.DepartmentID, 
    d.DepartmentName, 
    d.Location 
FROM Employees e 
INNER JOIN Departments d ON e.DepartmentID = d.DepartmentID;


-- ==============================================================================
-- PRACTICE QUERIES (1 - 14)
-- ==============================================================================

-- Query 1: Show all employees.
SELECT * FROM Employees;

-- Query 2: Show employee name and location only.
SELECT EmpName, Location FROM Employees;

-- Query 3: Find all employees whose location is Noida.
SELECT * FROM Employees WHERE Location = 'Noida';

-- Query 4: Find all female employees.
SELECT * FROM Employees WHERE Gender = 'F';

-- Query 5: Show all employees ordered by name from A to Z.
SELECT * FROM Employees ORDER BY EmpName ASC;

-- Query 6: Find employees whose name starts with A.
SELECT * FROM Employees WHERE EmpName LIKE 'A%';

-- Query 7: Show the different locations where employees are based, without duplicates.
SELECT DISTINCT Location FROM Employees;

-- Query 8: How many employees are there in the company?
SELECT COUNT(*) AS TotalCompanyEmployees FROM Employees;

-- Query 9: How many employees does each department have?
SELECT d.DepartmentName, COUNT(*) AS TotalEmployees 
FROM Employees e 
JOIN Departments d ON e.DepartmentID = d.DepartmentID
GROUP BY d.DepartmentName;

-- Query 10: How many employees are there in each location?
SELECT Location, COUNT(*) AS EmployeeCount 
FROM Employees 
GROUP BY Location;

-- Query 11: Which departments have more than 1 employee?
SELECT d.DepartmentName 
FROM Employees e 
JOIN Departments d ON e.DepartmentID = d.DepartmentID
GROUP BY e.DepartmentID, d.DepartmentName 
HAVING COUNT(*) > 1;

-- Query 12: How many male and female employees are there?
SELECT Gender, COUNT(*) AS EmployeeCount 
FROM Employees 
GROUP BY Gender;

-- Query 13: How many projects are there?
SELECT COUNT(*) AS TotalProjects FROM Projects;

-- Query 14: How many employees are assigned to each project?
-- LEFT JOIN ensures projects with 0 assigned employees are still included in the result
SELECT p.ProjectName, COUNT(ep.EmployeeID) AS TotalEmployees
FROM Projects p 
LEFT JOIN EmployeeProjects ep ON p.ProjectID = ep.ProjectID
GROUP BY p.ProjectName;


CREATE TABLE Salaries
(
    SalaryID INT IDENTITY(1,1) PRIMARY KEY,
    EmpID INT NOT NULL,
    Salary DECIMAL(10,2) NOT NULL,
    EffectiveDate DATE NOT NULL,
   constraint fk_Salaries_Employees foreign key(EmpID) references Employees(EmpID)
);

INSERT INTO Salaries
    (EmpID, Salary, EffectiveDate)
VALUES
(1, 75000, '2026-01-01'),
(2, 82000, '2026-01-01'),
(3, 68000, '2026-01-01'),
(4, 55000, '2026-01-01'),
(5, 95000, '2026-01-01'),
(6, 62000, '2026-01-01'),
(7, 70000, '2026-01-01'),
(8, 58000, '2026-01-01'),
(9, 72000, '2026-01-01'),
(10, 65000, '2026-01-01');

select * from salaries;

--Query 15: Show each employee's name and salary.
select e.empname,s.Salary from employees e join salaries s on s.empid=e.empid;

--Query 16: What is the average salary of all employees?
select avg(salary) from salaries;

--Query 17: What is the highest salary?
select max(salary) from salaries;

--Query 18: What is the lowest salary?
select min(salary) from salaries;

--Query 19: What is the total salary expenditure of the company?
select sum(salary) from salaries;

--Query 20: What is the average salary for each department?
select avg(s.salary),d.DepartmentName from 
employees e join departments d on e.departmentid = d.departmentid 
join salaries s on e.empid=s.empid
group by e.DepartmentID,d.DepartmentName;

--Query 21: What is each department's total salary expenditure?
select sum(s.salary), d.departmentname from 
employees e join departments d on e.departmentid=d.departmentid
join salaries s on e.empid=s.empid
group by d.departmentname;

--Query 22: Which department has the highest average salary?
select top 1 with ties
avg(s.salary) as avgsalary,d.DepartmentName from 
employees e join departments d on e.departmentid = d.departmentid
join salaries s on e.empid=s.empid
group by d.DepartmentID,d.DepartmentName
order by avgsalary desc;


--Query 23: Show all employees and their project names, including employees who have no project.
select e.empname,p.ProjectName from employees e left join employeeprojects ep on  e.empid = ep.employeeid
left join projects p on p.ProjectID=ep.ProjectID;

--Query 24: Find employees who are not assigned to any project.
--select e.empname,p.projectname from employees e left join EmployeeProjects ep on e.EmpID = ep.EmployeeID
--left join projects p on p.ProjectID=ep.ProjectID
--where p.ProjectName is null;

SELECT e.EmpName
FROM Employees e
LEFT JOIN EmployeeProjects ep
    ON e.EmpID = ep.EmployeeID
WHERE ep.EmployeeID IS NULL;

--Query 25: Show every project and the number of employees assigned to it, including projects with zero employees.
--select p.projectname,count(*) from projects p left join EmployeeProjects ep on ep.ProjectID=p.ProjectID
--left join employees e on e.EmpID=ep.EmployeeID
--group by p.projectname

--INSERT INTO Projects (ProjectName, Location)
--VALUES ('AI Research Project', 'Noida');

--COUNT(*)       - counts the left-side row
--COUNT(column)  - counts non-NULL values of that column
SELECT
    p.ProjectName,
    COUNT(e.EmpID) AS EmployeeCount
FROM Projects p
LEFT JOIN EmployeeProjects ep
    ON ep.ProjectID = p.ProjectID
LEFT JOIN Employees e
    ON e.EmpID = ep.EmployeeID
GROUP BY p.ProjectName;

--Query 26: Show each employee's name, department, and salary.
select e.empname, d.departmentname, s.Salary from employees e join departments d on e.DepartmentID = d.DepartmentID
join salaries s on e.EmpID=s.EmpID

--Query 27: Write a query to display each employee's name, salary, and salary band,
--where Salary < 60000 = Low, Salary between 60000 and 75000 = Medium, and Salary > 75000 = High.
select e.empname,s.Salary,
case
when s.salary>75000 then 'High'
when s.salary>=60000 and s.salary<=75000 then 'Medium'
else
'Low'
end 'Salary Band'
from employees e join salaries s on e.empid = s.empid
order by s.Salary

--Query 28: Write a query to display the number of employees in each salary band: Low, Medium, and High.
--select
--case
--when s.salary>75000 Then 'High'
--when s.salary between 60000 and 75000 then 'medium'
--else 'Low'
--end as 'salaryband',
--count(*) as totalemployee
--from salaries s 
--group by case
--when s.salary>75000 Then 'High'
--when s.salary between 60000 and 75000 then 'medium'
--else 'Low'
--end

--using subquery, dont have to repeat the case
select salaryband, count(*) totalemployees from
(select case
when salary>75000 Then 'High'
when salary between 60000 and 75000 then 'medium'
else 'Low'
end as salaryband
from salaries) as salarybands
group by salaryband

--Query 29: Write a query to display each employee's name, salary, and employee type,
--labeling employees earning more than 75,000 as High Earner and everyone else as Regular.
select e.empname,s.salary,
case
when s.salary>75000 then 'High Earner'
else 'Regular'
end as Employee_Type
from employees e join salaries s on e.empid=s.empid

--query 30: Find all employees whose salary is greater than the company's average salary.
select e.empname,s.salary from employees e join salaries s on e.empid=s.empid
where s.salary>(select avg(salary) from salaries);

--query 31: Find employees whose salary is greater than the average salary of their own department.
select e.empid,e.empname,e.DepartmentID, s.Salary,avgs.deptavg from
(select  e.DepartmentID, avg(s.salary) as deptavg from salaries s join employees e on e.empid = s.empid
group by e.DepartmentID) as avgs join employees e on avgs.DepartmentID=e.DepartmentID join salaries s on s.empid=e.empid
where s.Salary>avgs.deptavg;


--Use EXISTS, NOT EXISTS to solve 32,33
--Query 32: Find employees who are assigned to at least one project.
select * from employees e
where exists(select 1 from EmployeeProjects ep where ep.EmployeeID = e.empid)

--Query 33: Find employees who are not assigned to any project.
select * from employees e where not exists(select 1 from EmployeeProjects ep where ep.EmployeeID=e.EmpID)

--Query 34: Employees assigned to at least one project using IN.
select * from employees where empid in(select EmployeeID from employeeprojects)

--Query 35: Employees assigned to at least one project using JOIN.
--3 approaches
--join + group by
select ep.employeeid from
employees e join EmployeeProjects ep on e.empid = ep.employeeid
group by ep.EmployeeID
--join + distinct
select distinct e.empid,e.empname from employees e join EmployeeProjects ep on e.empid = ep.employeeid
--exists
select * from employees e
where exists(select 1 from EmployeeProjects ep where ep.EmployeeID = e.empid)

--Query 36 : Find employees whose salary is greater than the average salary of their own department.
--select e.empid,e.empname,e.DepartmentID, s.Salary,avgs.deptavg from
--(select  e.DepartmentID, avg(s.salary) as deptavg from salaries s join employees e on e.empid = s.empid
--group by e.DepartmentID) as avgs join employees e on avgs.DepartmentID=e.DepartmentID join salaries s on s.empid=e.empid
--where s.Salary>avgs.deptavg;
--Rewrite your Query 31 using a CTE.
with avgsalary as(
select e.departmentid, avg(s.salary) as avgOfDept from employees e join salaries s on e.empid = s.empid
group by e.DepartmentID
)
select e.empid,e.empname,e.DepartmentID,s.Salary,a.avgOfDept from employees e join avgsalary a on a.DepartmentID=e.DepartmentID join salaries s on s.empid=e.empid
where s.Salary>a.avgOfDept;

--Query 37 : Find the highest-paid employee in every department.
with maxsalary as(
select e.DepartmentID,d.DepartmentName, max(salary) maxofdept from employees e join salaries s on e.empid = s.empid join departments d on d.DepartmentID=e.DepartmentID
group by e.DepartmentID, d.DepartmentName
)
select e.empid,e.empname,s.Salary,m.DepartmentName,m.maxofdept from employees e join salaries s on e.empid=s.empid join maxsalary m on m.DepartmentID=e.DepartmentID
where s.Salary=m.maxofdept;

--Query 38 : Rank employees by salary within each department.
select e.EmpID,e.EmpName,d.DepartmentName,s.salary,
rank() over(partition by e.departmentid order by s.salary desc) as empRank
from employees e join salaries s on e.empid=s.EmpID join Departments d on d.DepartmentID=e.DepartmentID;

--Query 39:Find the top 2 highest-paid employees in every department.
with RankedData as(
select e.EmpID,e.EmpName,d.DepartmentName,s.salary,
rank() over(partition by e.departmentid order by s.salary desc) as empRank
from employees e join salaries s on e.empid=s.EmpID join Departments d on d.DepartmentID=e.DepartmentID
)
select empid, empname, departmentname, salary,emprank from rankeddata where emprank<=2

--Query 40 : Find exactly the top 2 highest-paid employees in every department using ROW_NUMBER().
with emprank as(
select e.EmpID,e.EmpName,d.DepartmentName,s.salary,
row_number() over(partition by e.departmentid order by s.salary desc) as emprankno
from employees e join salaries s on e.empid=s.EmpID join Departments d on d.DepartmentID=e.DepartmentID
)
select empid, empname, departmentname, salary,emprankno from emprank where emprankno<=2

--Query 41 : Show EmpName, Salary, ROW_NUMBER(), RANK(), and DENSE_RANK() 
--for every employee, with rankings calculated separately within each department.
select e.EmpID,e.EmpName,s.salary,
ROW_NUMBER() over(partition by e.departmentid order by s.salary desc) as rowno,
rank() over(partition by e.departmentid order by s.salary desc) as rankno,
DENSE_RANK() over(partition by e.departmentid order by s.salary desc) as denserankno
from employees e join salaries s on e.empid=s.EmpID

UPDATE Salaries
SET Salary = 75000
WHERE EmpID = 3;

--ROW_NUMBER() -> 1, 2, 3, 4
--RANK()       -> 1, 2, 2, 4
--DENSE_RANK() -> 1, 2, 2, 3

--ROW_NUMBER : Give everyone a unique position.
--RANK : Tied people share the rank, and the next rank is skipped.
--DENSE_RANK : Tied people share the rank, but no rank is skipped.

--alter table employees add HireDate date not null;
alter table employees add HireDate date not null
constraint DF_Employees_HireDate
Default Cast(getDate() as Date);

select * from employees;

UPDATE Employees
SET HireDate =
    CASE EmpID
        WHEN 1 THEN '2022-03-15'
        WHEN 2 THEN '2023-07-10'
        WHEN 3 THEN '2021-11-01'
        WHEN 4 THEN '2024-01-20'
        WHEN 5 THEN '2020-06-05'
        WHEN 6 THEN '2023-02-14'
        WHEN 7 THEN '2022-09-18'
        WHEN 8 THEN '2025-01-06'
        WHEN 9 THEN '2021-05-25'
        WHEN 10 THEN '2025-08-12'
    END;

select * from employees order by HireDate;

--Query 42 : Show employees who joined on or after January 1, 2024.
select * from employees where hiredate>='2024-01-01'

--Query 43 : Show how many employees joined in each year.
select year(HireDate) year, count(*) from employees group by year(HireDate)

--Query 44 : Show employees ordered from longest tenure to shortest tenure.
select *,DATEDIFF(DAY, HireDate, GETDATE()) AS DaysWorked from employees order by DaysWorked desc
select *,DATEDIFF(week, HireDate, GETDATE()) AS weeksWorked from employees order by weeksWorked desc
select *,DATEDIFF(month, HireDate, GETDATE()) AS monthsWorked from employees order by monthsWorked desc
select *,DATEDIFF(year, HireDate, GETDATE()) AS YearsWorked from employees order by YearsWorked desc

--Query 45 : Show each employee's name, hire date, and years worked.
select empname,HireDate,DATEDIFF(year, HireDate, GETDATE())
- case when dateadd(year, datediff(year,hiredate,getdate()),hiredate) >= GETDATE() then 1
else 0 
end as yearWorked
from employees 


--Query 46 : Show the average employee tenure for each department and identify which departments have the longest average tenure.
select departmentid, avg(datediff(day,hiredate,getdate())) as deptavg  from employees group by departmentid order by deptavg desc


alter table employees add ManagerID int null;

--self referencing foreign keys
ALTER TABLE Employees
ADD CONSTRAINT FK_Employees_Manager
    FOREIGN KEY (ManagerID)
    REFERENCES Employees(EmpID);

UPDATE Employees
SET ManagerID =
    CASE EmpID
        WHEN 1 THEN NULL
        WHEN 2 THEN 1
        WHEN 3 THEN 1
        WHEN 4 THEN 2
        WHEN 5 THEN 1
        WHEN 6 THEN 2
        WHEN 7 THEN 1
        WHEN 8 THEN 4
        WHEN 9 THEN 6
        WHEN 10 THEN 7
    END;

select * from employees;
select empid,empname,managerid from employees;


--Query 47 : Find employees who do not have a manager.
--select e.empid,e.empname,e.ManagerID from employees e left join employees m on e.ManagerID=m.empid;
select empid,empname,ManagerID from employees where ManagerID is null

--Query 48 : Find employees who have a manager.
select empid,empname,ManagerID from employees where ManagerID is not null

--Query 49 : Show each employee along with their manager's name using a self join.
select e.empid,e.empname,e.ManagerID,m.empname
from employees e join employees m on e.ManagerID=m.EmpID

--Query 50 : Show each employee along with their manager's name, displaying "Top Level" when the employee has no manager.
select e.empid,e.empname,e.ManagerID,
coalesce(m.empname,'Top Level')
from employees e left join employees m on e.ManagerID=m.EmpID;

--Query 51 : Find the top 3 highest-paid employees in the company, including ties.
with rankeddata as(
select e.empid,e.empname,s.salary,
Rank() over(order by s.salary desc) as rankemp
from employees e join salaries s on e.empid=s.empid
)
select * from rankeddata where rankemp<=3

--Query 52 : Find the department with the highest total salary expenditure.
--this is simpler query
select top 1 d.DepartmentID,d.DepartmentName, sum(s.salary) as exp
from employees e join salaries s on e.empid=s.EmpID join Departments d on d.DepartmentID=e.DepartmentID
group by d.DepartmentID,d.DepartmentName
order by exp desc;
--or
with totalexpenditures as(
select d.DepartmentID,d.DepartmentName, sum(s.salary) as exp
from employees e join salaries s on e.empid=s.EmpID join Departments d on d.DepartmentID=e.DepartmentID
group by d.DepartmentID,d.DepartmentName
)
select top 1 DepartmentID, DepartmentName,exp from totalexpenditures
order by exp desc;

--Query 53 : Find employees who earn more than their department average and are assigned to at least one project.
with DeptAvg as(
select e.DepartmentID,avg(salary) avgsalary
from employees e join salaries s on s.EmpID=e.EmpID
group by e.DepartmentID
)
select distinct e.empid,e.empname, s.Salary,d.avgsalary
from employees e join DeptAvg d on e.DepartmentID=d.DepartmentID
join Salaries s on s.EmpID=e.EmpID
join EmployeeProjects ep on ep.EmployeeID = e.EmpID
where s.salary>d.avgsalary;

--better version
WITH DeptAvg AS
(
SELECT e.DepartmentID,AVG(s.Salary) AS AvgSalary
FROM Employees e JOIN Salaries s ON s.EmpID = e.EmpID 
GROUP BY e.DepartmentID
)
SELECT e.EmpID,e.EmpName,s.Salary,d.AvgSalary
FROM Employees e JOIN DeptAvg d ON e.DepartmentID = d.DepartmentID JOIN Salaries s ON s.EmpID = e.EmpID
WHERE s.Salary > d.AvgSalary
AND EXISTS
(
SELECT 1FROM EmployeeProjects ep WHERE ep.EmployeeID = e.EmpID
);

--Query 54 : Find departments that have no employees assigned to any project.
SELECT d.DepartmentID, d.DepartmentName
FROM Departments d
WHERE NOT EXISTS
(
    SELECT 1
    FROM Employees e
    JOIN EmployeeProjects ep
        ON ep.EmployeeID = e.EmpID
    WHERE e.DepartmentID = d.DepartmentID
);

--Query 55 : Find the second-highest salary in each department.
--If the requirement were "the second employee after sorting," we'd use ROW_NUMBER() instead.
select * from ( 
select d.DepartmentID,d.DepartmentName,s.salary,
rank() over(partition by d.departmentid order by s.salary desc) as salaryrank
from employees e join Departments d on e.DepartmentID=d.DepartmentID join Salaries s on s.EmpID=e.EmpID
) as Sal where salaryrank=2

--Query 56 : For every department, show the department name, employee count, 
--average salary, highest salary, lowest salary, and total salary. Sort by total salary in descending order.
select d.DepartmentName,count(distinct e.EmpID) EmployeeCount, 
avg(s.salary) AvgSalary, max(s.salary) HighestSalary, min(s.salary) LowestSalary, sum(s.salary) TotalSalary
from employees e join Departments d on e.DepartmentID=d.DepartmentID join Salaries s on s.EmpID=e.EmpID
group by d.DepartmentName
order by TotalSalary desc


--Business Analysis Questions - best interview worthy questions
Query 57 : Find the top 3 departments by total salary expenditure.

--Query 58 : Find the highest-paid employee in each department, including ties.

--Query 59 : Find employees whose salary is above the company average but below their department's maximum salary.

--Query 60 : Find employees who have never been assigned to a project.

--Query 61 : Find the department with the highest average employee tenure.

--Query 62 : For each department, show the DepartmentName, EmployeeCount, ProjectCount, and AverageSalary. Be careful not to overcount projects because employees can have multiple project assignments.

--Query 63 : Find employees who are assigned to more projects than the average number of projects per employee.

--Query 64 : For each employee, show their EmpName, DepartmentName, Salary, DepartmentAverageSalary, SalaryDifference, and SalaryRankWithinDepartment. Combine JOIN, CTE, AVG, a window function, and a calculated column.

SELECT
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME IN
(
    'Departments',
    'Employees',
    'Salaries',
    'Projects',
    'EmployeeProjects'
)
ORDER BY TABLE_NAME, ORDINAL_POSITION;