/*======================================

SYMPTON:
Plan cache could be wasted by Single use plans.
Can result in high recompilations, slower queries
and poor query plan reuse.

RECCOMMENDATION:
If size of Ad-hoc queries is > 25% of total size of cache
switch on Optimise for Ad-hoc Workloads

========================================*/


/* Total Size of Plan Cache */
SELECT SUM(cast(size_in_bytes AS BIGINT))/1024/1024 AS 'Total Size (MB)'
FROM sys.dm_exec_cached_plans;
 

/* Plan cache breakdown by price */
SELECT objtype AS 'Type',
COUNT(*) AS '# Plans',
SUM(CAST(size_in_bytes AS BIGINT))/1024/1024 AS 'Size (MB)',
AVG(usecounts) AS 'Avg uses'
FROM sys.dm_exec_cached_plans
GROUP BY objtype
order by [# Plans] desc;

/* Number of Single use Cache Plans */
SELECT count(*) as '# Plans Single Use'
FROM sys.dm_exec_cached_plans
WHERE objtype = 'Adhoc' AND usecounts = 1;
 
/* Size of single use counts */
SELECT SUM(cast(size_in_bytes AS BIGINT))/1024/1024 AS 'Size (MB) Single Use'
FROM sys.dm_exec_cached_plans
WHERE objtype = 'Adhoc' AND usecounts = 1;
