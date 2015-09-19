-- Query 2 - Memory Clerk Usage *******************************************************

-- Memory Clerk Usage for instance
-- Look for high value for CACHESTORE_SQLCP (Ad-hoc query plans)
SELECT TOP(10) [type] AS [Memory Clerk Type], SUM(single_pages_kb) AS [SPA Mem, Kb] 
FROM sys.dm_os_memory_clerks 
GROUP BY [type]  
ORDER BY SUM(single_pages_kb) DESC OPTION (RECOMPILE);

-- CACHESTORE_SQLCP  SQL Plans         These are cached SQL statements or batches that aren't in 
--                                     stored procedures, functions and triggers
-- CACHESTORE_OBJCP  Object Plans      These are compiled plans for stored procedures, 
--                                     functions and triggers
-- CACHESTORE_PHDR   Algebrizer Trees  An algebrizer tree is the parsed SQL text that 
--                                     resolves the table and column names