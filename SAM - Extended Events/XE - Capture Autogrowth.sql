/* https://sqlzealots.com/2015/04/01/auto-file-growth-track-the-growth-events-using-extended-events-in-sql-server/ */

-- Create event
CREATE EVENT SESSION [DB_file_size_changed] ON SERVER 
ADD EVENT sqlserver.database_file_size_change(SET collect_database_name=(1)
    ACTION
   (sqlserver.client_app_name,sqlserver.client_hostname, sqlserver.database_id,sqlserver.session_id,
   sqlserver.session_nt_username,sqlserver.username) 
   /* You can filter the database that needs to be monitored for the auto growth, for which you need to pass the database id for the filter*/
   --WHERE ([database_id]=()) 
   ) 
ADD TARGET package0.event_file
(SET filename=N'D:\DBA\DB_file_size_changed.xel')
WITH (MAX_DISPATCH_LATENCY=1 SECONDS)

--Start Session
ALTER EVENT SESSION DB_File_size_Changed 
ON SERVER STATE = START -- START/STOP to start and stop the event session

--QUery session
USE [master];
GO
SELECT
        Case when file_type = 'Data file' Then 'Data File Grow' Else File_Type End AS [Event Name]
	   , database_name AS DatabaseName
	   , file_names
	   , size_change_kb
	   , duration
       , client_app_name AS Client_Application
	   , client_hostname
       , session_id AS SessionID
	   , Is_Automatic 
       
FROM (
       SELECT
           n.value ('(data[@name="size_change_kb"]/value)[1]', 'int') AS size_change_kb
           , n.value ('(data[@name="database_name"]/value)[1]', 'nvarchar(50)') AS database_name
           , n.value ('(data[@name="duration"]/value)[1]', 'int') AS duration
           , n.value ('(data[@name="file_type"]/text)[1]','nvarchar(50)') AS file_type
           , n.value ('(action[@name="client_app_name"]/value)[1]','nvarchar(50)') AS client_app_name
           , n.value ('(action[@name="session_id"]/value)[1]','nvarchar(50)') AS session_id
		   , n.value ('(action[@name="client_hostname"]/value)[1]','nvarchar(50)') AS Client_HostName
		   , n.value ('(data[@name="file_name"]/value)[1]','nvarchar(50)') AS file_names
		   , n.value ('(data[@name="is_automatic"]/value)[1]','nvarchar(50)') AS Is_Automatic
           
       FROM 
           (   SELECT CAST(event_data AS XML) AS event_data
               FROM sys.fn_xe_file_target_read_file(
                   N'C:\temp\DB_file_size_changed*.xel',
                   NULL,
                   NULL,
                   NULL)
           ) AS Event_Data_Table
CROSS APPLY event_data.nodes('event') AS q(n)) xyz
ORDER BY database_name
