/*  https://dba.stackexchange.com/questions/241127/dbcc-freesystemcache-sql-plans-deletes-all-ad-hoc-and-prepared-plans-not-jus
*/

DECLARE @plan_handle varbinary(64)

DECLARE db_cursor CURSOR FOR 
SELECT plan_handle
FROM sys.dm_exec_cached_plans
WHERE objtype = 'Adhoc' 

OPEN db_cursor  
FETCH NEXT FROM db_cursor INTO @plan_handle  

WHILE @@FETCH_STATUS = 0  
BEGIN  
    DBCC FREEPROCCACHE (@plan_handle);  
    FETCH NEXT FROM db_cursor INTO @plan_handle 
END 

CLOSE db_cursor  
DEALLOCATE db_cursor



/* Erik Darling version */


ALTER PROCEDURE [dbo].[clear_single_plans]
AS
BEGIN
SET NOCOUNT, XACT_ABORT ON;

IF OBJECT_ID('tempdb..#plan_handles')
IS NOT NULL
BEGIN
    DROP TABLE #plan_handles
END

CREATE TABLE #plan_handles(plan_handle VARCHAR(1000));

DECLARE @plan_handle_command VARCHAR(1000) = '';

INSERT #plan_handles ( plan_handle )
SELECT DISTINCT 'DBCC FREEPROCCACHE (' 
                 + CONVERT(VARCHAR(128), decp.plan_handle, 1) 
                 + ');'
FROM sys.dm_exec_cached_plans AS decp
JOIN sys.dm_exec_query_stats AS deqs
    ON decp.plan_handle = deqs.plan_handle
WHERE decp.usecounts = 1
AND   decp.objtype = 'Adhoc'
AND   deqs.last_execution_time < DATEADD(HOUR, -1, GETDATE());

DECLARE plan_cursor CURSOR 
FORWARD_ONLY LOCAL  
FOR  
SELECT plan_handle 
FROM #plan_handles;  

OPEN plan_cursor;  
FETCH NEXT FROM plan_cursor 
    INTO @plan_handle_command
WHILE @@FETCH_STATUS = 0  
BEGIN   

 PRINT @plan_handle_command;  
 EXEC(@plan_handle_command);  

FETCH NEXT FROM plan_cursor 
    INTO @plan_handle_command;  
END;  

CLOSE plan_cursor;  
DEALLOCATE plan_cursor;  
END;



