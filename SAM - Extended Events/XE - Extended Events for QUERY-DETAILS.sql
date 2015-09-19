CREATE EVENT SESSION [query hash] ON SERVER
ADD EVENT sqlserver.sp_statement_completed (
    ACTION(package0.collect_system_time,
           sqlserver.client_app_name,
           sqlserver.client_hostname,
           sqlserver.database_name)
    WHERE ([sqlserver].[session_id]=59))
ADD TARGET package0.asynchronous_file_target
(SET filename = 'C:\temp\XEventSessions\query_hash.xel',
     metadatafile = 'C:\temp\XEventSessions\query_hash.xem',
     max_file_size=5,
     max_rollover_files=5)
WITH (MAX_DISPATCH_LATENCY = 5SECONDS);
GO

/*
Once you have that up and running, you should be able to start the session, if it isn’t already started, by running:
*/

ALTER EVENT SESSION [query hash] ON SERVER
STATE = START ;

/*
Just like that, you’ll be capturing your terrible queries to disk where you can mine the extended events files for gold and glory at your own convenience. If you want to query it, it’d look something like this:
*/

WITH events_cte AS (
    SELECT
        DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), CURRENT_TIMESTAMP),
            xevents.event_data.value('(event/@timestamp)[1]',
            'datetime2')) AS [event time] ,
        xevents.event_data.value('(event/action[@name="client_app_name"]/value)[1]', 'nvarchar(128)')
          AS [client app name],
        xevents.event_data.value('(event/action[@name="client_hostname"]/value)[1]', 'nvarchar(max)')
          AS [client host name],
        xevents.event_data.value('(event/action[@name="database_name"]/value)[1]', 'nvarchar(max)')
          AS [database name],
        xevents.event_data.value('(event/data[@name="duration"]/value)[1]', 'bigint')
          AS [duration (ms)],
        xevents.event_data.value('(event/data[@name="cpu_time"]/value)[1]', 'bigint')
          AS [cpu time (ms)],
        xevents.event_data.value('(event/data[@name="logical_reads"]/value)[1]', 'bigint') AS [logical reads],
        xevents.event_data.value('(event/data[@name="row_count"]/value)[1]', 'bigint')  AS [row count]
    FROM sys.fn_xe_file_target_read_file
         ('C:\temp\XEventSessions\query_hash*.xel',
          'C:\temp\XEventSessions\query_hash*.xem',
          null, null)
    CROSS APPLY (select CAST(event_data as XML) as event_data) as xevents
)
SELECT *
FROM events_cte
ORDER BY [event time] DESC;

/*
CLEANING UP AFTER YOURSELF

Once you’re done watching a specific query or queries, make sure you clean up after yourself. There’s no reason to add extra load to SQL Server when you aren’t watching. Make sure to stop and remove your Extended Events session:
*/

/* Stop the Extended Events session */
ALTER EVENT SESSION [query hash] ON SERVER
STATE = STOP;
/* Remove the session from the server.
   This step is optional - I clear them out on my dev SQL Server
   because I'm constantly doing stupid things to my dev SQL Server. */
DROP EVENT SESSION [query hash] ON SERVER;
