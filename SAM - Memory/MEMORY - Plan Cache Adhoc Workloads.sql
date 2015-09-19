--Find the number of single plans

SELECT objtype AS [CacheType],cacheobjtype
        , count_big(*) AS [Total Plans]
        , sum(cast(size_in_bytes as decimal(18,2)))/1024/1024 AS [Total MBs]
        , avg(usecounts) AS [Avg Use Count]
        , sum(cast((CASE WHEN usecounts = 1 THEN size_in_bytes ELSE 0 END) as decimal(18,2)))/1024/1024 AS [Total MBs - USE Count 1]
        , sum(CASE WHEN usecounts = 1 THEN 1 ELSE 0 END) AS [Total Plans - USE Count 1]
FROM sys.dm_exec_cached_plans
GROUP BY objtype,cacheobjtype
ORDER BY [Total MBs - USE Count 1] DESC
go


-- Find the ad-hoc queries that are bloating the plan cache

SELECT TOP(1000) [text], size_in_bytes
FROM sys.dm_Exec_cached_plans
CROSS APPLY sys.dm_exec_sql_text(plan_handle)
WHERE cacheobjtype = 'Compiled Plan'
AND objtype = 'Adhoc' AND usecounts = 1
ORDER BY size_in_bytes DESC


--size of plan cache


SELECT count(*) as 'number of plans',
sum(cast(size_in_bytes as bigint))/1024/1024 as 'Plan Cache Size (MB)'
from sys.dm_exec_cached_plans



--Count of plans in cache by type and usecount with size
SELECT 
	objtype,
	usecounts,
	COUNT(*) as no_of_plans,
	SUM(size_in_bytes/1024./1024.) as size_in_MB
from sys.dm_exec_cached_plans as cp
cross APPLY sys.dm_exec_sql_text(cp.plan_handle) as St
--where cp.cacheobjtype ='Compiled Plan'
GROUP by cp.objtype,
		cp.usecounts
order by cp.objtype,
cp.usecounts;
	


