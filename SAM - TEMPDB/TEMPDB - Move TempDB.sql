/*
NOTE: Can only move to a drive which is in view of SQL
*/


USE master;
GO
ALTER DATABASE tempdb 
MODIFY FILE (NAME = tempdev, FILENAME = 'E:\SQLData\tempdb.mdf');
GO
ALTER DATABASE tempdb 
MODIFY FILE (NAME = templog, FILENAME = 'F:\SQLLog\templog.ldf');
GO
