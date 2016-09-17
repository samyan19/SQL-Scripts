/*
http://www.patrickkeisler.com/2013/12/collecting-historical-io-file-statistics.html

1. Collect data for all databases.

EXEC dbo.sp_CollectIoVirtualFileStats
 @Database = '*';
GO

2. Collect data for all databases except for AdventureWorks, and output all debug commands.

EXEC dbo.sp_CollectIoVirtualFileStats
  @Database = '*'
 ,@ExcludedDBs = 'AdventureWorks'
 ,@Debug = 1;
GO

3. Output an aggregated report of data collected so far for tempdb.

EXEC dbo.sp_CollectIoVirtualFileStats
  @Database = 'tempdb'
 ,@GenerateReport = 1;
GO
*/

USE dba_admin;
GO

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'dbo.sp_CollectIoVirtualFileStats') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
	DROP PROCEDURE dbo.sp_CollectIoVirtualFileStats;
GO

/********************************************************************

  File Name:    sp_CollectIoVirtualFileStats.sql

  Applies to:   SQL Server 2005
				SQL Server 2008
				SQL Server 2008 R2
				SQL Server 2012

  Purpose:      To collect and store data from sys.dm_io_virtual_file_stats.

  Parameters:   5 total.
		
				@Database	
					'*' Default is to process ALL databases.
					'MyDatabase1' Use to process only a single database.
					'MyDatabase1,MyDatabase2,MyDatabase3' Comma delimited list of databases.
					'SYSTEM_DATABASES' Use to process only the system databases.
					'USER_DATABASES' Use to process only user databases.

				@GenerateReport
					Default value is 0.
					A value of 0 will collect the raw data.
					A value of 1 will generate an aggregated report of the historical data, but will not collect any addtional data.

				@HistoryRentention
					Default value is 365 days.
					A value of 0 will keep all historical data.
					The number of days of history to keep in dba_admin.dbo.IoVirtualFileStatsHistory.

				@ExcludedDBs
					Defalut value is 'Northwind,pubs,AdventureWorks,AdventureWorks2008,AdventureWorks2008R2,AdventureWorks2012'.
					Use this to specifly a comma delimited list of databases to be excluded from processing.

				@Debug
					Default is 0.
					A value of 1 will output debug messages during processing.

  Author:       Patrick Keisler

  Version:      1.0.0

  Date:         12/16/2013

  Help:         http://www.patrickkeisler.com/

  License:      (C) 2013 Patrick Keisler
                sp_CollectIoVirtualFileStats is free to download and use for 
                personal, educational, and internal corporate purposes, 
                provided that this header is preserved. Redistribution 
                or sale sp_CollectIoVirtualFileStats in whole or in part, 
                is prohibited without the author's express written consent.

********************************************************************/

CREATE PROCEDURE dbo.sp_CollectIoVirtualFileStats(
	 @Database NVARCHAR(MAX) = '*'
		-- '*' Default for ALL databases
		-- 'MyDatabase1,MyDatabase2,MyDatabase3' for comma delimited database list
		-- 'SYSTEM_DATABASES' for system databases only
		-- 'USER_DATABASES' for user databases only
	,@GenerateReport BIT = 0
		-- Default value is 0 which will collect the data
	,@HistoryRentention INT = 365
		-- Default value is 365 days
		-- Number of days of history to keep in dba_admin.dbo.IoVirtualFileStatsHistory
	,@ExcludedDBs NVARCHAR(MAX) = 'Northwind,pubs,AdventureWorks'
		-- Use this to specifly a comma delimited list of databases to be excluded from processing
	,@Debug BIT = 0
		-- Default is 0
		-- A value of 1 will display debug messages during processing
)
AS
SET NOCOUNT ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
SET ARITHABORT ON;
SET LOCK_TIMEOUT 3600000;

DECLARE 
	 @DatabaseId INT
	,@DatabaseName SYSNAME
	,@DBMode VARCHAR(50)
	,@DBRole TINYINT
	,@Position INT
	,@Cmd NVARCHAR(2000)
	,@TempDatabaseId INT
	,@Counter INT
	,@Output INT
	,@ServerVersion INT
	,@StatusMsg VARCHAR(2000)
	,@ErrorMessage NVARCHAR(4000)
	,@ErrorSeverity INT
	,@CurrentSqlServerStartTime DATETIME
    ,@PreviousSqlServerStartTime DATETIME
    ,@PreviousCollectionTime DATETIME;


SET @Position = 0;
SET @Counter = 0;

SET @ServerVersion = CONVERT(INT,SUBSTRING(CONVERT(VARCHAR,SERVERPROPERTY('ProductVersion')),1,(CHARINDEX('.',(CONVERT(VARCHAR,SERVERPROPERTY('ProductVersion'))))-1)));

/*******************************/
/*   VALIDATE ALL PARAMETERS   */
/*******************************/

-- Check Access Level
IF IS_SRVROLEMEMBER ('sysadmin') = 0
BEGIN
	SELECT @StatusMsg = 'Insufficient system access for ' + SUSER_SNAME() + ' to collect IO stats.' + CHAR(10) + 'User needs SysAdmin permission to run dbo.sp_CollectIoVirtualFileStats.';
	RAISERROR(@StatusMsg,16,1);
	RETURN 1;
END

-- Validate @Database
IF @Database IS NULL OR @Database = ''
BEGIN
	SELECT @StatusMsg = 'Invalid value for @Database parameter.' + CHAR(10) + 'Valid options are:' + CHAR(10)
		+ CHAR(39) + '*' + CHAR(39) + ' Default is to process ALL databases.' + CHAR(10)
		+ CHAR(39) + 'MyDatabase1' + CHAR(39) + ' Use to process only a sinlge database.' + CHAR(10)
		+ CHAR(39) + 'MyDatabase1,MyDatabase2,MyDatabase3' + CHAR(39) + ' Comma delimited list of databases.' + CHAR(10)
		+ CHAR(39) + 'SYSTEM_DATABASES'+ CHAR(39) + ' Use to process only the system databases.' + CHAR(10)
		+ CHAR(39) + 'USER_DATABASES'+ CHAR(39) + ' Use to process only user databases.';
	RAISERROR(@StatusMsg,16,1);
	RETURN 1;
END

-- Validate @@GenerateReport
IF @GenerateReport IS NULL
BEGIN
	SELECT @StatusMsg = 'Invalid value for @GenerateReport parameter.' + CHAR(10) + 'Valid options are: 0 or 1.';
	RAISERROR(@StatusMsg,16,1);
	RETURN 1;
END

-- Validate @HistoryRentention
IF @HistoryRentention IS NULL
BEGIN
	SELECT @StatusMsg = 'Invalid value for @HistoryRentention parameter.' + CHAR(10) + 'The value must be an integer >= 0.';
	RAISERROR(@StatusMsg,16,1);
	RETURN 1;
END
ELSE IF @HistoryRentention < 0
BEGIN
	SELECT @StatusMsg = 'Invalid value for @HistoryRentention parameter = ' + CONVERT(VARCHAR,@HistoryRentention)+ CHAR(10) + 'The value must be an integer >= 0.';
	RAISERROR(@StatusMsg,16,1);
	RETURN 1;
END

-- Validate @Debug
IF @Debug IS NULL
BEGIN
	SELECT @StatusMsg = 'Invalid value for @Debug parameter.' + CHAR(10) + 'Valid options are: 0 or 1.';
	RAISERROR(@StatusMsg,16,1);
	RETURN 1;
END

-- Validate @ExcludedDBs
IF @ExcludedDBs IS NULL
BEGIN
	SELECT @StatusMsg = 'Invalid value for @ExcludedDBs parameter.' + CHAR(10) + 'Valid options are:' + CHAR(10)
		+ CHAR(39) + CHAR(39) + ' (blank) Use to not exclude any databases.' + CHAR(10)
		+ CHAR(39) + 'MyDatabase1' + CHAR(39) + ' Use to exclude only a sinlge database.' + CHAR(10)
		+ CHAR(39) + 'MyDatabase1,MyDatabase2,MyDatabase3' + CHAR(39) + ' Comma delimited list of excluded databases.' + CHAR(10)
	RAISERROR(@StatusMsg,16,1);
	RETURN 1;
END

/****************************************/
/*   BUILD HISTORICAL AND WORK TABLES   */
/****************************************/

-- Create the IoVirtualFileStats if it does not exists
IF OBJECT_ID('dba_admin.dbo.IoVirtualFileStatsHistory') IS NULL
BEGIN
	SET @Cmd = 'CREATE TABLE dbo.IoVirtualFileStatsHistory(
					 SqlServerStartTime DATETIME NOT NULL
					,CollectionTime DATETIME NOT NULL
					,TimeDiff_ms BIGINT NOT NULL
					,DatabaseName NVARCHAR(128) NOT NULL
					,DatabaseId SMALLINT NOT NULL
					,FileId SMALLINT NOT NULL
					,SampleMs INT NOT NULL
					,SampleMsDiff INT NOT NULL
					,NumOfReads BIGINT NOT NULL
					,NumOfReadsDiff BIGINT NOT NULL
					,NumOfBytesRead BIGINT NOT NULL
					,NumOfBytesReadDiff BIGINT NOT NULL
					,IoStallReadMs BIGINT NOT NULL
					,IoStallReadMsDiff BIGINT NOT NULL
					,NumOfWrites BIGINT NOT NULL
					,NumOfWritesDiff BIGINT NOT NULL
					,NumOfBytesWritten BIGINT NOT NULL
					,NumOfBytesWrittenDiff BIGINT NOT NULL
					,IoStallWriteMs BIGINT NOT NULL
					,IoStallWriteMsDiff BIGINT NOT NULL
					,IoStall BIGINT NOT NULL
					,IoStallDiff BIGINT NOT NULL
					,SizeOnDiskBytes BIGINT NOT NULL
					,SizeOnDiskBytesDiff BIGINT NOT NULL
					,FileHandle VARBINARY(8) NOT NULL
					,CONSTRAINT PK_IoVirtualFileStatsHistory PRIMARY KEY CLUSTERED (CollectionTime,DatabaseName,DatabaseId,FileId)
				)';

	-- If possible, add data compression
	IF (@ServerVersion > 9 AND SUBSTRING(CONVERT(NVARCHAR,SERVERPROPERTY('Edition')),1,10) = 'Enterprise')
		SET @Cmd = @Cmd + 'WITH (DATA_COMPRESSION = PAGE);';
	ELSE
		SET @Cmd = @Cmd + ';';

	BEGIN TRY
		IF @Debug = 1
			PRINT 'DEBUG: ' + @Cmd;
		EXEC (@Cmd);
	END TRY
	BEGIN CATCH
		SELECT @StatusMsg = 'CREATE TABLE dba_admin.dbo.IoVirtualFileStatsHistory failed.';
		RAISERROR(@StatusMsg,16,1);
		SELECT @ErrorMessage = ERROR_MESSAGE(),@ErrorSeverity = ERROR_SEVERITY();
		RAISERROR(@ErrorMessage,@ErrorSeverity,1);
		RETURN 1;
	END CATCH

	SET @Cmd = 'CREATE NONCLUSTERED INDEX IX_IoVirtualFileStatsHistory_1 ON dba_admin.dbo.IoVirtualFileStatsHistory(SqlServerStartTime)';

	-- If possible, add data compression
	IF (@ServerVersion > 9 AND SUBSTRING(CONVERT(NVARCHAR,SERVERPROPERTY('Edition')),1,10) = 'Enterprise')
		SET @Cmd = @Cmd + 'WITH (DATA_COMPRESSION = PAGE);';
	ELSE
		SET @Cmd = @Cmd + ';';

	BEGIN TRY
		IF @Debug = 1
			PRINT 'DEBUG: ' + @Cmd;
		EXEC (@Cmd);
	END TRY
	BEGIN CATCH
		SELECT @StatusMsg = 'CREATE INDEX IX_IoVirtualFileStatsHistory_1 failed.';
		RAISERROR(@StatusMsg,16,1);
		SELECT @ErrorMessage = ERROR_MESSAGE(),@ErrorSeverity = ERROR_SEVERITY();
		RAISERROR(@ErrorMessage,@ErrorSeverity,1);
		RETURN 1;
	END CATCH
END

-- Create temp tables for processing
IF OBJECT_ID('tempdb..#SelectedDatabases') IS NOT NULL
	DROP TABLE #SelectedDatabases;

CREATE TABLE #SelectedDatabases(
	 ID INT IDENTITY(1,1)
	,DatabaseId INT
	,DatabaseName SYSNAME
	,PRIMARY KEY(ID));

IF OBJECT_ID('tempdb..#ExcludedDatabases') IS NOT NULL
	DROP TABLE #ExcludedDatabases;

CREATE TABLE #ExcludedDatabases(
	 ID INT IDENTITY(1,1)
	,DatabaseName SYSNAME
	,PRIMARY KEY(ID));

/****************************************/
/*   PARSE @Database AND @ExcludedDBs   */
/****************************************/

-- Attempt to remove spaces if they exist
SET @Database = REPLACE(LTRIM(RTRIM(@Database)), ', ', ',');
SET @Database = REPLACE(@Database, ' ,', ',');
SET @ExcludedDBs = REPLACE(LTRIM(RTRIM(@ExcludedDBs)), ', ', ',');
SET @ExcludedDBs = REPLACE(@ExcludedDBs, ' ,', ',');

WHILE CHARINDEX(',', @ExcludedDBs) > 0
BEGIN
	SELECT @Position = CHARINDEX(',', @ExcludedDBs);
	SELECT @DatabaseName = SUBSTRING(@ExcludedDBs, 1, @Position-1);

	INSERT INTO #ExcludedDatabases 
	SELECT @DatabaseName;

	SELECT @ExcludedDBs = SUBSTRING(@ExcludedDBs, @Position+1, LEN(@ExcludedDBs)-@Position);
END
INSERT INTO #ExcludedDatabases
SELECT @ExcludedDBs;

-- Validate @Database
IF @Database IS NULL
BEGIN
	SELECT @StatusMsg = 'Invalid value for @Database parameter.' + CHAR(10) 
		+ CHAR(39) + '*' + CHAR(39) + 'Default is to process ALL databases.'
		+ CHAR(39) + 'MyDatabase1' + CHAR(39) + 'Use to process only a sinlge database.'
		+ CHAR(39) + 'MyDatabase1,MyDatabase2,MyDatabase3' + CHAR(39) + 'Comma delimited list of databases.'
		+ CHAR(39) + 'SYSTEM_DATABASES'+ CHAR(39) + 'Use to process only the system databases.'
		+ CHAR(39) + 'USER_DATABASES'+ CHAR(39) + 'Use to process only user databases.';
	RAISERROR(@StatusMsg,16,1);
	RETURN 1;
END

-- Process @Database parameter
IF @Database = '*'
BEGIN
	INSERT #SelectedDatabases
	SELECT database_id, name FROM master.sys.databases
	WHERE name NOT IN (SELECT DatabaseName from #ExcludedDatabases)
	AND source_database_id IS NULL -- Exclude snapshots
	AND state_desc = 'ONLINE' -- Exclude databases that are not online
	AND is_read_only = 0 -- Exclude databases that are read-only
	ORDER BY name;
END
ELSE IF @Database = 'SYSTEM_DATABASES'
BEGIN
	INSERT #SelectedDatabases
	SELECT database_id, name FROM master.sys.databases WHERE name IN ('master','model','msdb')
	AND name NOT IN (SELECT DatabaseName from #ExcludedDatabases)
	ORDER BY name;
END
ELSE IF @Database = 'USER_DATABASES'
BEGIN
	INSERT #SelectedDatabases
	SELECT database_id, name FROM master.sys.databases 
	WHERE database_id > 4
	AND name NOT IN (SELECT DatabaseName from #ExcludedDatabases)
	AND source_database_id IS NULL -- Exclude snapshots
	AND state_desc = 'ONLINE' -- Exclude databases that are not online
	AND is_read_only = 0 -- Exclude databases that are read-only
	ORDER BY name;
END
ELSE
BEGIN
	WHILE CHARINDEX(',', @Database) > 0
	BEGIN
		SELECT @Position = CHARINDEX(',', @Database);
		SELECT @DatabaseName = SUBSTRING(@Database, 1, @Position-1);
		IF NOT EXISTS (SELECT name FROM master.sys.databases WHERE name = @DatabaseName)
		BEGIN
			SET @StatusMsg = 'Invalid database selected for @DatabaseName parameter = ' + QUOTENAME(@DatabaseName);
			RAISERROR(@StatusMsg,16,1);
			RETURN 1;
		END
		ELSE IF @DatabaseName = 'tempdb'
		BEGIN
			SELECT @StatusMsg = 'Can not run index maintenance on tempdb';
			RAISERROR(@StatusMsg,16,1);
			RETURN 1;
		END
		ELSE
		BEGIN
			INSERT INTO #SelectedDatabases 
			SELECT database_id, name FROM master.sys.databases WHERE name = @DatabaseName;
		END
		SELECT @Database = SUBSTRING(@Database, @Position+1, LEN(@Database) - @Position);
	END
	INSERT INTO #SelectedDatabases
	SELECT database_id, name FROM master.sys.databases WHERE name = @Database;

	IF (SELECT COUNT(*) FROM #SelectedDatabases) = 0
	BEGIN
		SELECT @StatusMsg = 'Invalid value for @Database parameter = ' + CHAR(39) + @Database + CHAR(39) + CHAR(10) + 'The database specified does not exist.';
		RAISERROR(@StatusMsg,16,1);
		RETURN 1;
	END
END

IF @Debug = 1
	SELECT * FROM #SelectedDatabases;

IF @GenerateReport = 1
	GOTO GenerateReport

-- Get SQL Server start time
IF @ServerVersion = 9
BEGIN
	-- This section is for SQL Server 2005
	-- Must convert to smalldatetime, because SQL could return different milliseond values
	SET @Cmd = 'SELECT @StartUp = CONVERT(SMALLDATETIME,(DATEADD(MS,-ms_ticks,CURRENT_TIMESTAMP))) FROM sys.dm_os_sys_info;';
	EXEC sp_executesql @Cmd, N'@StartUp SMALLDATETIME OUTPUT', @CurrentSqlServerStartTime OUTPUT;
END
ELSE
BEGIN
	-- This section is for SQL Server 2008+
	SET @Cmd = 'SELECT @StartUp = sqlserver_start_time FROM master.sys.dm_os_sys_info;';
	EXEC sp_executesql @Cmd, N'@StartUp DATETIME OUTPUT', @CurrentSqlServerStartTime OUTPUT;
END


/************************************/
/*   BEGIN LOOP FOR EACH DATABASE   */
/************************************/

WHILE EXISTS (SELECT * FROM #SelectedDatabases)
BEGIN
	-- Clear @Cmd variable
	SET @Cmd = '';

	-- Select the next database from #SelectedDatabases
	SELECT TOP 1
		 @TempDatabaseId = ID
		,@DatabaseId = DatabaseId
		,@DatabaseName = DatabaseName 
	FROM #SelectedDatabases;

	PRINT 'Begin processing: ' + QUOTENAME(@DatabaseName) + ' - ' + CONVERT(VARCHAR,CURRENT_TIMESTAMP,109);

	-- Get the last collection time
	SELECT 
		 @PreviousSqlServerStartTime = MAX(SqlServerStartTime)
		,@PreviousCollectionTime = MAX(CollectionTime) 
	FROM dba_admin.dbo.IoVirtualFileStatsHistory
	WHERE DatabaseName = @DatabaseName;

-- Collect IO virtual stats from sys.dm_io_virtual_stats
IF @CurrentSqlServerStartTime <> ISNULL(@PreviousSqlServerStartTime,0)
BEGIN
	-- If SQL started since the last collection, then insert starter values
	-- Must do DATEDIFF using seconds instead of milliseconds to avoid arithmetic overflow.
	SET @Cmd = 'INSERT INTO dbo.IoVirtualFileStatsHistory
				SELECT
					''' + CONVERT(VARCHAR,@CurrentSqlServerStartTime,121) + '''
					,CURRENT_TIMESTAMP
					,CONVERT(BIGINT,DATEDIFF(SS,''' + CONVERT(VARCHAR,@CurrentSqlServerStartTime,121) + ''',CURRENT_TIMESTAMP))*1000
					,' + QUOTENAME(@DatabaseName,'''') + '
					,' + CONVERT(VARCHAR,@DatabaseId) + '
					,file_id
					,sample_ms
					,sample_ms
					,num_of_reads
					,num_of_reads
					,num_of_bytes_read
					,num_of_bytes_read
					,io_stall_read_ms
					,io_stall_read_ms
					,num_of_writes
					,num_of_writes
					,num_of_bytes_written
					,num_of_bytes_written
					,io_stall_write_ms
					,io_stall_write_ms
					,io_stall
					,io_stall
					,size_on_disk_bytes
					,size_on_disk_bytes
					,file_handle
				FROM sys.dm_io_virtual_file_stats(' + CONVERT(VARCHAR,@DatabaseId) + ',NULL);';
	BEGIN TRY
		-- Insert the current IO stat counters
		IF @Debug = 1
			PRINT 'DEBUG: ' + @Cmd;
		EXEC (@Cmd);
	END TRY
	BEGIN CATCH
		SELECT @StatusMsg = 'INSERT dbo.IoVirtualFileStatsHistory failed for ' + QUOTENAME(@DatabaseName);
		RAISERROR(@StatusMsg,16,1);
		SELECT @ErrorMessage = ERROR_MESSAGE(),@ErrorSeverity = ERROR_SEVERITY();
		RAISERROR(@ErrorMessage,@ErrorSeverity,1);
	END CATCH
END
ELSE
BEGIN
	-- Calculate the diff values and insert into the history table
	SET @Cmd = 'WITH CurrentIoVirtualFileStats AS
				(
					SELECT 
						CURRENT_TIMESTAMP AS ''CollectionTime''
						,' + QUOTENAME(@DatabaseName,'''') + ' AS ''DatabaseName''
						,* 
					FROM sys.dm_io_virtual_file_stats(' + CONVERT(VARCHAR,@DatabaseId) + ',NULL)
				)
				INSERT INTO dbo.IoVirtualFileStatsHistory
				SELECT
					''' + CONVERT(VARCHAR,@CurrentSqlServerStartTime,121) + '''
					,CURRENT_TIMESTAMP
					,CONVERT(BIGINT,DATEDIFF(MS,''' + CONVERT(VARCHAR,@PreviousCollectionTime,121) + ''',curr.CollectionTime))
					,' + QUOTENAME(@DatabaseName,'''') + '
					,' + CONVERT(VARCHAR,@DatabaseId) + '
					,file_id
					,sample_ms
					,curr.sample_ms - hist.SampleMs
					,num_of_reads
					,curr.num_of_reads - hist.NumOfReads
					,num_of_bytes_read
					,curr.num_of_bytes_read - hist.NumOfBytesRead
					,io_stall_read_ms
					,curr.io_stall_read_ms - hist.IoStallReadMs
					,num_of_writes
					,curr.num_of_writes - hist.NumOfWrites
					,num_of_bytes_written
					,curr.num_of_bytes_written - hist.NumOfBytesWritten
					,io_stall_write_ms
					,curr.io_stall_write_ms - hist.IoStallWriteMs
					,io_stall
					,curr.io_stall - hist.IoStall
					,size_on_disk_bytes
					,curr.size_on_disk_bytes - hist.SizeOnDiskBytes
					,file_handle
				FROM CurrentIoVirtualFileStats curr INNER JOIN dbo.IoVirtualFileStatsHistory hist
					ON (curr.DatabaseName = hist.DatabaseName
						AND curr.database_id = hist.DatabaseId
						AND curr.file_id = hist.FileId)
					AND hist.CollectionTime = ''' + CONVERT(VARCHAR,@PreviousCollectionTime,121) + ''';';
	BEGIN TRY
		-- Insert the current IO stat counters
		IF @Debug = 1
			PRINT 'DEBUG: ' + @Cmd;
		EXEC (@Cmd);
	END TRY
	BEGIN CATCH
		SELECT @StatusMsg = 'INSERT dbo.IoVirtualFileStatsHistory failed for ' + QUOTENAME(@DatabaseName);
		RAISERROR(@StatusMsg,16,1);
		SELECT @ErrorMessage = ERROR_MESSAGE(),@ErrorSeverity = ERROR_SEVERITY();
		RAISERROR(@ErrorMessage,@ErrorSeverity,1);
	END CATCH
END
	-- Go get the next database on the list
	NextDB:;
	PRINT 'Finished processing: ' + QUOTENAME(@DatabaseName) + ' - ' + CONVERT(VARCHAR,CURRENT_TIMESTAMP,109);

	-- Delete the database from #SelectedDatabases once it has been processed
	DELETE #SelectedDatabases WHERE ID = @TempDatabaseId;
END
/**********************************/
/*   END LOOP FOR EACH DATABASE   */
/**********************************/

-- Purge historical data from dba_admin.dbo.IoVirtualFileStatsHistory
IF @HistoryRentention > 0
BEGIN
	SET @Cmd = 'DELETE FROM dba_admin.dbo.IoVirtualFileStatsHistory WHERE CollectionTime < DATEADD(DAY,-' + CONVERT(VARCHAR,@HistoryRentention) + ',CURRENT_TIMESTAMP)';
	BEGIN TRY
		IF @Debug = 1
			PRINT 'DEBUG: ' + @Cmd;
		EXEC (@Cmd);
	END TRY
	BEGIN CATCH
		SELECT @StatusMsg = 'DELETE FROM dba_admin.dbo.IoVirtualFileStatsHistory failed' + CHAR(10) + @Cmd;
		RAISERROR(@StatusMsg,16,1);
		SELECT @ErrorMessage = ERROR_MESSAGE(),@ErrorSeverity = ERROR_SEVERITY();
		RAISERROR(@ErrorMessage,@ErrorSeverity,1);
		RETURN 1;
	END CATCH
END

GOTO EXITPROC;

-- Generate a report from the historical data
GenerateReport:
SET @Cmd = 'WITH IoVirtualFileStatsHistoryReport
AS
(
	SELECT 
			DATEADD(ms,-timediff_ms,CollectionTime) AS ''PreviousCollectionTime''
		,CollectionTime
		,DatabaseName
		,FileType = 
			CASE FileId
			WHEN 2 THEN ''Log''
			ELSE ''Data''
			END
		,NumOfReadsDiff
		,IoStallReadMsDiff
		,NumOfWritesDiff
		,IoStallWriteMsDiff
		,IoStallDiff
	FROM dbo.IoVirtualFileStatsHistory
	WHERE DatabaseName IN (SELECT DatabaseName FROM #SelectedDatabases)
)
SELECT
		PreviousCollectionTime
	,CollectionTime
	,DatabaseName
	,FileType
	,SUM(IoStallReadMsDiff/(NumOfReadsDiff+1)) AS ''ms/Read''
	,SUM(IoStallWriteMsDiff/(NumOfWritesDiff+1)) AS ''ms/Write''
	,SUM(IoStallDiff/(NumOfReadsDiff+NumOfWritesDiff+1)) AS ''ms/IO''
FROM IoVirtualFileStatsHistoryReport
GROUP BY PreviousCollectionTime,CollectionTime,DatabaseName,FileType;';
BEGIN TRY
	IF @Debug = 1
		PRINT 'DEBUG: ' + @Cmd;
	EXEC (@Cmd);
END TRY
BEGIN CATCH
	SELECT @StatusMsg = 'Generate report failed for dba_admin.dbo.IoVirtualFileStatsHistory failed' + CHAR(10) + @Cmd;
	RAISERROR(@StatusMsg,16,1);
	SELECT @ErrorMessage = ERROR_MESSAGE(),@ErrorSeverity = ERROR_SEVERITY();
	RAISERROR(@ErrorMessage,@ErrorSeverity,1);
	RETURN 1;
END CATCH

ExitProc:
-- Cleanup temporary objects
IF OBJECT_ID('tempdb..#SelectedDatabases') IS NOT NULL
	DROP TABLE #SelectedDatabases;
IF OBJECT_ID('tempdb..#ExcludedDatabases') IS NOT NULL
	DROP TABLE #ExcludedDatabases;
RETURN 0
GO
