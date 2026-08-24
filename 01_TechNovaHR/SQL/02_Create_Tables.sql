/*
    Project: TechNova HR & Employee Analytics
    File: 02_Create_Tables.sql

    Purpose:
    Creates all tables and relationships required for the project.

    Important:
    Tables are created in dependency order because foreign keys
    reference tables that must already exist.
*/


/* ============================================================
   1. Departments
   ============================================================

   Stores the departments available in the organization.

   DepartmentID:
   - Surrogate primary key.
   - IDENTITY automatically generates sequential IDs.

   DepartmentName:
   - UNIQUE prevents duplicate department names.

   Location:
   - Stores the department's office location.
   ============================================================ */

CREATE TABLE Departments
(
    DepartmentID INT IDENTITY(1,1) PRIMARY KEY,
    DepartmentName VARCHAR(50) NOT NULL UNIQUE,
    Location VARCHAR(50) NOT NULL
);


/* ============================================================
   2. Employees
   ============================================================

   Stores employee master information.

   EmpID:
   - Surrogate primary key.
   - IDENTITY automatically generates sequential employee IDs.

   Gender:
   - Restricted to the values used in this project through a
     CHECK constraint.

   MobNo:
   - Stored as VARCHAR because phone numbers are identifiers,
     not values used for mathematical calculations.
   - UNIQUE prevents duplicate phone numbers.

   Email:
   - UNIQUE ensures each employee has a unique email address.

   DepartmentID:
   - Foreign key creating a one-to-many relationship:
     Departments (1) -> Employees (Many).

   HireDate:
   - Stores the employee's joining date.
   - Used later for tenure and hiring analysis.

   ManagerID:
   - Added separately after table creation.
   - Creates a self-referencing relationship:
     Employees.ManagerID -> Employees.EmpID.
   ============================================================ */

CREATE TABLE Employees
(
    EmpID INT IDENTITY(1,1) PRIMARY KEY,
    EmpName VARCHAR(50) NOT NULL,
    Gender CHAR(1) NOT NULL
        CHECK (Gender IN ('M', 'F')),
    MobNo VARCHAR(15) NOT NULL UNIQUE,
    Email VARCHAR(100) NOT NULL UNIQUE,
    Location VARCHAR(50) NOT NULL,
    DepartmentID INT NOT NULL,
    HireDate DATE NOT NULL,

    CONSTRAINT FK_Employees_Departments
        FOREIGN KEY (DepartmentID)
        REFERENCES Departments(DepartmentID)
);


/* ============================================================
   3. Salaries
   ============================================================

   Stores salary information for employees.

   SalaryID:
   - Surrogate primary key.
   - IDENTITY automatically generates sequential IDs.

   EmpID:
   - Foreign key linking each salary record to an employee.

   Salary:
   - DECIMAL(10,2) is used for monetary values to maintain
     predictable decimal precision.

   EffectiveDate:
   - Stores the date from which the salary became effective.
   - Allows the table to support salary history when an employee
     receives salary revisions.
   ============================================================ */

CREATE TABLE Salaries
(
    SalaryID INT IDENTITY(1,1) PRIMARY KEY,
    EmpID INT NOT NULL,
    Salary DECIMAL(10,2) NOT NULL,
    EffectiveDate DATE NOT NULL,

    CONSTRAINT FK_Salaries_Employees
        FOREIGN KEY (EmpID)
        REFERENCES Employees(EmpID)
);


/* ============================================================
   4. Projects
   ============================================================

   Stores projects handled by the organization.

   ProjectID:
   - Surrogate primary key.
   - IDENTITY automatically generates sequential project IDs.

   ProjectName:
   - UNIQUE prevents duplicate project names.

   Location:
   - Stores the project location.

   Employees and Projects have a many-to-many relationship,
   which is implemented through the EmployeeProjects table.
   ============================================================ */

CREATE TABLE Projects
(
    ProjectID INT IDENTITY(1,1) PRIMARY KEY,
    ProjectName VARCHAR(50) NOT NULL UNIQUE,
    Location VARCHAR(50) NOT NULL
);


/* ============================================================
   5. EmployeeProjects
   ============================================================

   Bridge/junction table used to implement the many-to-many
   relationship between Employees and Projects.

   Relationship:

       Employees (1) ---- (Many) EmployeeProjects (Many) ---- (1) Projects

   EmployeeID:
   - Foreign key referencing Employees.

   ProjectID:
   - Foreign key referencing Projects.

   Composite Primary Key:
   - (EmployeeID, ProjectID)
   - Prevents the same employee from being assigned to the
     same project more than once.
   ============================================================ */

CREATE TABLE EmployeeProjects
(
    EmployeeID INT NOT NULL,
    ProjectID INT NOT NULL,

    CONSTRAINT PK_EmployeeProjects
        PRIMARY KEY (EmployeeID, ProjectID),

    CONSTRAINT FK_EmployeeProjects_Employees
        FOREIGN KEY (EmployeeID)
        REFERENCES Employees(EmpID),

    CONSTRAINT FK_EmployeeProjects_Projects
        FOREIGN KEY (ProjectID)
        REFERENCES Projects(ProjectID)
);


/* ============================================================
   6. Employee Manager Relationship
   ============================================================

   Adds the ManagerID column to Employees.

   ManagerID:
   - References Employees.EmpID.
   - Creates a self-referencing relationship.
   - NULL is allowed because a top-level employee may not have
     another employee as their manager.

   Relationship:

       Employees.ManagerID -> Employees.EmpID
   ============================================================ */

ALTER TABLE Employees
ADD ManagerID INT NULL;


ALTER TABLE Employees
ADD CONSTRAINT FK_Employees_Manager
    FOREIGN KEY (ManagerID)
    REFERENCES Employees(EmpID);