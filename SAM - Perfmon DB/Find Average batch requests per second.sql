DECLARE @UpTime DECIMAL(25,0)
,@StartDate DATETIME

SELECT @StartDate = create_date FROM master.sys.databases WHERE database_id = 2;
SELECT @UpTime = DATEDIFF(ss,@StartDate,CURRENT_TIMESTAMP);

SELECT
     RTRIM(object_name)
    ,RTRIM(counter_name)
    ,RTRIM(instance_name)
    ,'Avg since SQL startup'
    ,CONVERT(DECIMAL(25,2),(cntr_value/@UpTime))
    ,'See description'
    ,'Number of batch requests per second.  Good indicator of the activity level of the server.  Should be cross-checked with other counters such as CPU utilization.'
FROM sys.dm_os_performance_counters
WHERE /*object_name = @SQLServerName+':SQL Statistics'
AND*/ counter_name = 'Batch Requests/sec';
