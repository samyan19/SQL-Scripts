SELECT ST.text AS "Query Text", QS.query_hash AS "Query Hash", 
    QS.query_plan_hash AS "Query Plan Hash"
FROM sys.dm_exec_query_stats QS
    CROSS APPLY sys.dm_exec_sql_text (QS.sql_handle) ST
WHERE ST.text like '%Change date: 2015/02/23%'