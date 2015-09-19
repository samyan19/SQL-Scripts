/*
	Check for startup stored procedures.  These live in the master database, and
	they run automatically when SQL Server starts up.  They're sometimes left
	behind by ambitious auditors or evil employees.
	
	For more information about startup stored procs, read:
	http://www.mssqltips.com/tip.asp?tip=1574
*/
USE master
GO
SELECT *
FROM master.INFORMATION_SCHEMA.ROUTINES
WHERE OBJECTPROPERTY(OBJECT_ID(ROUTINE_NAME),'ExecIsStartup') = 1 