
/*
   When was the last time DBCC finished successfully?
   DBCC CHECKDB checks databases for corruption.  You won't know 
   Script is from http://sqlserverpedia.com/wiki/Last_clean_DBCC_CHECKDB_date
   To get sample corrupt databases - http://sqlskills.com/pastConferences.asp
    
*/

CREATE TABLE #temp (          
       ParentObject     VARCHAR(255)
       , [Object]       VARCHAR(255)
       , Field          VARCHAR(255)
       , [Value]        VARCHAR(255)   
   )   
   
CREATE TABLE #DBCCResults (
        ServerName           VARCHAR(255)
        , DBName             VARCHAR(255)
        , LastCleanDBCCDate  DATETIME   
    )   
    
EXEC master.dbo.sp_MSforeachdb       
           @command1 = 'USE [?] INSERT INTO #temp EXECUTE (''DBCC DBINFO WITH TABLERESULTS'')'
           , @command2 = 'INSERT INTO #DBCCResults SELECT @@SERVERNAME, ''?'', Value FROM #temp WHERE Field = ''dbi_dbccLastKnownGood'''
           , @command3 = 'TRUNCATE TABLE #temp'   
   
   --Delete duplicates due to a bug in SQL Server 2008
   
  &nbsp;;WITH DBCC_CTE AS
   (
       SELECT ROW_NUMBER() OVER (PARTITION BY ServerName, DBName, LastCleanDBCCDate ORDER BY LastCleanDBCCDate) RowID
       FROM #DBCCResults
   )
   DELETE FROM DBCC_CTE WHERE RowID > 1;
   
    SELECT        
           ServerName       
           , DBName       
           , CASE LastCleanDBCCDate 
                   WHEN '1900-01-01 00:00:00.000' THEN 'Never ran DBCC CHECKDB' 
                   ELSE CAST(LastCleanDBCCDate AS VARCHAR) END AS LastCleanDBCCDate    
   FROM #DBCCResults   
   ORDER BY 3
   
   DROP TABLE #temp, #DBCCResults;






/*
	If any databases have never experienced the magic of DBCC, consider doing that
	as soon as practical.  DBCC CHECKDB is a CPU & IO intensive operation, so
	consider doing it after business hours.  For more information:
	http://www.sqlskills.com/blogs/paul/post/CHECKDB-From-Every-Angle-Consistency-Checking-Options-for-a-VLDB.aspx
	For the demo, we'll run it on a small database right away.  This won't work on
	your machine unless you have a database named TimeTracking.
*/