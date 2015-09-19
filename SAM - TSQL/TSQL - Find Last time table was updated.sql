SELECT last_user_update
FROM sys.dm_db_index_usage_stats
WHERE object_id=object_id('BESTINVEST.WFProcessLog')