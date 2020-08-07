SET NOCOUNT ON;

-- first get the path to the error log directory
DECLARE @errorLogPath as NVARCHAR(4000);
SELECT @errorLogPath = cast(SERVERPROPERTY('ErrorLogFileName') AS NVARCHAR(4000));

SET @errorLogPath = REPLACE(@errorLogPath, '\ERRORLOG', '');


-- now get a list of files -- this may take a while
CREATE TABLE #DirectoryTree (
      subdirectory nvarchar(512),
      depth int,
      isfile bit);

INSERT INTO #DirectoryTree (subdirectory,depth,isfile)
EXEC master.sys.xp_dirtree @errorLogPath,1,1;


-- get a count of files in the error log directory
DECLARE @fileCount AS INTEGER = 0;
SELECT @fileCount = COUNT(*) FROM #DirectoryTree
WHERE isfile = 1;


PRINT 'Error log directory ' + @errorLogPath + ' contains ' + cast(@fileCount as varchar(100)) + ' files.';

DROP TABLE #DirectoryTree;
