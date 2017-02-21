/*
https://simondrichards.wordpress.com/2012/11/29/scripting-log-re-sizing/
*/

USE master
GO

--our variables
DECLARE @maxsize_MB	INT;
DECLARE @currentsize_MB	INT;
DECLARE @growth_size	INT;
DECLARE @first_growth	INT;
DECLARE @log_name	VARCHAR(60);
DECLARE @command	VARCHAR(255);
DECLARE @db_name	VARCHAR(60);

--the database you are growing, max size of the log and the block size you want to grow it in
SET @db_name = 'AdventureWorks'
SET @maxsize_MB = 2048;
SET @growth_size = 512;

--get the details for our database
SELECT
@log_name = name,
@currentsize_MB = (size * 8) / 1024 -- size is recorded in # of 8KB pages
FROM
sys.master_files
WHERE
database_id = DB_ID(@db_name)
AND
type = 1 --log

--set the initial size up to our growth size
SET @first_growth = @growth_size - @currentsize_MB

--grow the log file until it is at a size we like
WHILE @currentsize_MB < @maxsize_MB
BEGIN

SET @currentsize_MB = CASE
WHEN @first_growth = 0 THEN @currentsize_MB + @growth_size
ELSE @currentsize_MB + @first_growth
END
SET @command = 'ALTER DATABASE [' + @db_name + '] MODIFY FILE ( NAME = N''' + @log_name + ''', SIZE = ' + CAST(@currentsize_MB AS VARCHAR(25)) + ' MB )';
PRINT @currentsize_MB
PRINT @command
EXECUTE(@command)

--ignore this after first growth
SET @first_growth = 0

END
