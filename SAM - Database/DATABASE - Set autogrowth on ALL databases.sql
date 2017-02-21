--Set autogrowth for all databases


SELECT 'ALTER DATABASE ' + QUOTENAME(DB_NAME(database_id)) + ' MODIFY FILE (NAME=' + QUOTENAME(name) + ', FILEGROWTH=1GB);'
FROM sys.master_files
	WHERE database_id > 4 AND
	state_desc = N'ONLINE' AND
	type = 1;
