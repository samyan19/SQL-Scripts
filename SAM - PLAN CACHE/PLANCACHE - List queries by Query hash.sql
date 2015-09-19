SELECT [qs2].[query_hash] AS [Query Hash]
	, SUM ([qs2].[total_worker_time])
		AS [Total CPU Time - Cumulative Effect]
	, COUNT (DISTINCT [qs2].[query_plan_hash])
		AS [Number of plans] 
	, SUM ([qs2].[execution_count]) AS [Number of executions] 
	, MIN ([qs2].[statement_text]) AS [Example Statement Text]
 FROM (SELECT [qs].*,  
        [statement_text] = SUBSTRING ([st].[text], 
			([qs].[statement_start_offset] / 2) + 1
	    	, ((CASE [statement_end_offset] 
				WHEN - 1 THEN DATALENGTH ([st].[text]) 
				ELSE [qs].[statement_end_offset] 
				END 
		        - [qs].[statement_start_offset]) / 2) + 1) 
		FROM [sys].[dm_exec_query_stats] AS [qs] 
			CROSS APPLY [sys].[dm_exec_sql_text]
				 ([qs].[sql_handle]) AS [st]) AS [qs2]
GROUP BY [qs2].[query_hash] 
ORDER BY [Total CPU Time - Cumulative Effect] DESC;
GO