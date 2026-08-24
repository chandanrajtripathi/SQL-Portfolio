/*
    Project: TechNova HR & Employee Analytics
    File: 03_Insert_Data.sql

    Purpose:
    Inserts the sample data required to demonstrate the database
    design and analytical SQL queries.

    Data is inserted in dependency order so that all foreign key
    relationships remain valid.
*/


/* ============================================================
   1. Department Data
   ============================================================

   Creates five departments with different locations.

   The dataset intentionally contains multiple departments and
   multiple employees per department so that GROUP BY, JOIN,
   aggregation and ranking queries can be demonstrated.
   ============================================================ */

INSERT INTO Departments
    (DepartmentName, Location)
VALUES
    ('Engineering', 'Noida'),
    ('Human Resources', 'Gurgaon'),
    ('Finance', 'Delhi'),
    ('Marketing', 'Noida'),
    ('IT Support', 'Bangalore');


/* ============================================================
   2. Employee Data
   ============================================================

   Inserts ten employees.

   The dataset intentionally includes:
   - Multiple employees in the same department.
   - Employees working from different locations.
   - Employees with different joining dates.
   - One employee who initially has no project assignment.

   EmpID is generated automatically by IDENTITY.
   ============================================================ */

INSERT INTO Employees
    (EmpName, Gender, MobNo, Email, Location, DepartmentID, HireDate)
VALUES
    ('Amit Sharma', 'M', '9876543210', 'amit@technova.com', 'Noida', 1, '2022-03-15'),
    ('Priya Singh', 'F', '9876543211', 'priya@technova.com', 'Delhi', 1, '2023-07-10'),
    ('Rahul Verma', 'M', '9876543212', 'rahul@technova.com', 'Noida', 1, '2021-11-01'),
    ('Neha Gupta', 'F', '9876543213', 'neha@technova.com', 'Gurgaon', 2, '2024-01-20'),
    ('Rohit Kumar', 'M', '9876543214', 'rohit@technova.com', 'Delhi', 3, '2020-06-05'),
    ('Sneha Roy', 'F', '9876543215', 'sneha@technova.com', 'Noida', 4, '2023-02-14'),
    ('Karan Mehta', 'M', '9876543216', 'karan@technova.com', 'Bangalore', 5, '2022-09-18'),
    ('Anjali Das', 'F', '9876543217', 'anjali@technova.com', 'Gurgaon', 2, '2025-01-06'),
    ('Vikas Jain', 'M', '9876543218', 'vikas@technova.com', 'Noida', 4, '2021-05-25'),
    ('Pooja Nair', 'F', '9876543219', 'pooja@technova.com', 'Bangalore', 5, '2025-08-12');


/* ============================================================
   3. Project Data
   ============================================================

   Creates five projects.

   ProjectID is generated automatically by IDENTITY.
   ============================================================ */

INSERT INTO Projects
    (ProjectName, Location)
VALUES
    ('E-Commerce Platform', 'Noida'),
    ('Employee Portal', 'Gurgaon'),
    ('Financial Reporting System', 'Delhi'),
    ('Marketing Automation', 'Noida'),
    ('IT Helpdesk Upgrade', 'Bangalore');


/* ============================================================
   4. Salary Data
   ============================================================

   Inserts one salary record for each employee.

   Salary values are deliberately varied so that salary analysis,
   ranking, aggregation and comparison queries produce meaningful
   results.

   EffectiveDate represents the date from which the salary is
   applicable.
   ============================================================ */

INSERT INTO Salaries
    (EmpID, Salary, EffectiveDate)
VALUES
    (1, 75000, '2026-01-01'),
    (2, 82000, '2026-01-01'),
    (3, 75000, '2026-01-01'),
    (4, 55000, '2026-01-01'),
    (5, 95000, '2026-01-01'),
    (6, 62000, '2026-01-01'),
    (7, 70000, '2026-01-01'),
    (8, 58000, '2026-01-01'),
    (9, 72000, '2026-01-01'),
    (10, 65000, '2026-01-01');


/* ============================================================
   5. Employee-Project Assignments
   ============================================================

   Creates the many-to-many relationship between employees
   and projects.

   The assignments intentionally demonstrate:
   - Employees working on multiple projects.
   - Projects having multiple employees.
   - At least one employee with no project assignment.

   Employee 10 (Pooja Nair) is intentionally left without a
   project so that LEFT JOIN and NOT EXISTS scenarios can be
   demonstrated.
   ============================================================ */

INSERT INTO EmployeeProjects
    (EmployeeID, ProjectID)
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


/* ============================================================
   6. Employee Manager Assignments
   ============================================================

   Creates the self-referencing employee hierarchy.

   ManagerID references another employee's EmpID.

   Employee 1 (Amit Sharma) is treated as a top-level employee
   and therefore has no manager.
   ============================================================ */

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