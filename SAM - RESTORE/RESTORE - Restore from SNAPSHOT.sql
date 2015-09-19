-- =============================================
-- Create Database Snapshot Template
-- =============================================
USE master
GO

-- Drop database snapshot if it already exists
IF  EXISTS (
	SELECT name 
		FROM sys.databases 
		WHERE name = N'dbDealing_snapshot'
)
DROP DATABASE dbDealing_snapshot
GO

-- Create the database snapshot
CREATE DATABASE dbDealing_snapshot ON
( NAME = dbDealing, FILENAME = 
'D:\MSSQLData2008R2\dbDealing_snapshot.ss' )
AS SNAPSHOT OF dbDealing;
GO

--Restore from snaphsot
USE master;
RESTORE DATABASE dbDealing FROM DATABASE_SNAPSHOT = 'dbDealing_snapshot';
GO

