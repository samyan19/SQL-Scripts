/*
http://www.jasonstrate.com/2011/02/can-you-dig-it-find-estimated-cost/

*/

IF OBJECT_ID('tempdb..#StatementSubTreeCost') IS NOT NULL
DROP TABLE #StatementSubTreeCost ;

CREATE TABLE #StatementSubTreeCost
(
StatementSubTreeCost FLOAT
,StatementId INT
,UseCounts BIGINT
,plan_handle VARBINARY(64)
) ;

WITH XMLNAMESPACES
(DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan')
INSERT INTO #StatementSubTreeCost (StatementSubTreeCost, StatementId, UseCounts, plan_handle)
SELECT TOP 25
c.value('@StatementSubTreeCost', 'float') AS StatementSubTreeCost
,c.value('@StatementId', 'float') AS StatementId
,cp.UseCounts
,cp.plan_handle
FROM sys.dm_exec_cached_plans AS cp
CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle) AS qp
CROSS APPLY qp.query_plan.nodes('//StmtSimple') t(c)
WHERE cp.cacheobjtype = 'Compiled Plan'
AND qp.query_plan.exist('//StmtSimple') = 1
AND c.value('@StatementSubTreeCost', 'float') IS NOT NULL
ORDER BY c.value('@StatementSubTreeCost', 'float') DESC;

WITH XMLNAMESPACES
(DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan')
,cQueryStats
AS (
SELECT query_hash
,SUM(total_worker_time / NULLIF(qs.execution_count,0)) AS avg_worker_time
,SUM(total_logical_reads / NULLIF(qs.execution_count,0)) AS avg_logical_reads
,SUM(total_elapsed_time / NULLIF(qs.execution_count,0)) AS avg_elapsed_time
FROM sys.dm_exec_query_stats qs
GROUP BY query_hash
)
SELECT
s.StatementSubTreeCost
, s.usecounts
, CAST(c.value('@StatementEstRows', 'float') AS bigint) AS StatementEstRows
, qs.avg_worker_time
, qs.avg_logical_reads
, qs.avg_elapsed_time
,c.value('@StatementType', 'varchar(255)') AS StatementType
,c.value('@StatementText', 'varchar(max)') AS StatementText
,s.plan_handle
,qp.query_plan
FROM #StatementSubTreeCost s
CROSS APPLY sys.dm_exec_query_plan(s.plan_handle) AS qp
CROSS APPLY qp.query_plan.nodes('//StmtSimple') t(c)
LEFT OUTER JOIN cQueryStats qs ON c.value('xs:hexBinary(substring(@QueryHash,3))','binary(8)') = query_hash
WHERE c.value('@StatementId', 'float') = s.StatementId
ORDER BY c.value('@StatementSubTreeCost', 'float') DESC, s.StatementSubTreeCost DESC
