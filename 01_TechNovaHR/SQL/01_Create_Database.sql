/*
    Project: TechNova HR & Employee Analytics
    File: 01_Create_Database.sql

    Purpose:
    Creates the SQL Server database used by the project.

    This script should be executed first, before creating the
    tables and inserting the project data.
*/


/* ============================================================
   Create Database
   ============================================================

   Creates the TechNovaHR database.

   The remaining project scripts should be executed against
   this database in the following order:

   1. 02_Create_Tables.sql
   2. 03_Insert_Data.sql
   3. 04_Analysis_Queries.sql
   4. 05_Business_Questions.sql
   ============================================================ */

CREATE DATABASE TechNovaHR;
GO


/* ============================================================
   Select Database
   ============================================================

   Sets TechNovaHR as the active database for subsequent SQL
   statements executed in the session.
   ============================================================ */

USE TechNovaHR;
GO
