SELECT qt.[text] AS [SP Name], qs.last_execution_time, qs.execution_count AS [Execution Count] 
	FROM sys.dm_exec_query_stats AS qs
	CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS qt
	WHERE /*qt.dbid = db_id() -- Filter by current database
	AND*/ qt.text LIKE '%DDMandateFileProcessed%'