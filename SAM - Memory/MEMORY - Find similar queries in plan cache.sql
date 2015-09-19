--Find count of similar queries in cache plan

SELECT COUNT(*) AS [Count], query_stats.query_hash
FROM 
    (SELECT QS.*, 
    SUBSTRING(ST.text, (QS.statement_start_offset/2) + 1,
    ((CASE statement_end_offset 
        WHEN -1 THEN DATALENGTH(ST.text)
        ELSE QS.statement_end_offset END 
            - QS.statement_start_offset)/2) + 1) AS statement_text
     FROM sys.dm_exec_query_stats AS QS
     CROSS APPLY sys.dm_exec_sql_text(QS.sql_handle) as ST) as query_stats
GROUP BY query_stats.query_hash
ORDER BY 1 DESC;


--find text of query
SELECT top 10 query_stats.query_hash, 
    query_stats.statement_text AS [Text],query_stats.plan_handle
FROM 
    (SELECT QS.*, 
    SUBSTRING(ST.text, (QS.statement_start_offset/2) + 1,
    ((CASE statement_end_offset 
        WHEN -1 THEN DATALENGTH(ST.text)
        ELSE QS.statement_end_offset END 
            - QS.statement_start_offset)/2) + 1) AS statement_text
     FROM sys.dm_exec_query_stats AS QS
     CROSS APPLY sys.dm_exec_sql_text(QS.sql_handle) as ST) as query_stats
GROUP BY query_stats.query_hash, query_stats.statement_text,query_stats.plan_handle
having query_stats.query_hash=0xCF3B638209CA460D
ORDER BY 1 DESC;


select * from sys.dm_exec_query_plan(0x06000A006AC17E1B20740982020000000000000000000000);






