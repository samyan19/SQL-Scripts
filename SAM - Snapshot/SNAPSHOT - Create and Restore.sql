
-- Create the database snapshot
CREATE DATABASE dbDealing_snapshot ON
( NAME = dbDealing_data, FILENAME = 
'D:\MSSQLData2008R2\dbDealing_snapshot.ss' )
AS SNAPSHOT OF dbDealing;
GO

--Restore from snaphsot
USE master;
RESTORE DATABASE dbDealing FROM DATABASE_SNAPSHOT = 'dbDealing_snapshot';
GO
