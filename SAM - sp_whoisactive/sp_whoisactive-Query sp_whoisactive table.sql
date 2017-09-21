declare @start_time datetime='2017-09-13 02:26:00', 
		@end_time datetime ='2017-09-13 02:26:00'


SELECT 
[collection_time]
,[dd hh:mm:ss.mss]
      ,[session_id]
      ,[sql_text]
      ,[login_name]
      ,[wait_info]
	  ,REPLACE(SUBSTRING([wait_info], CHARINDEX(')', [wait_info]), LEN([wait_info])), ')', '') as wait_type
      ,[tran_log_writes]
      ,[CPU]
      ,[tempdb_allocations]
      ,[tempdb_current]
      ,[blocking_session_id]
      ,[reads]
      ,[writes]
      ,[physical_reads]
      ,[query_plan]
      ,[used_memory]
      ,[status]
      ,[tran_start_time]
      ,[open_tran_count]
      ,[percent_complete]
      ,[host_name]
      ,[database_name]
      ,[program_name]
      ,[start_time]
      ,[login_time]
      ,[request_id]
  FROM DBA_Admin.[dbo].[WhoIsActive]
  where collection_time < @end_time
  and collection_time > @start_time
 -- and wait_info like '%HADR_SYNC_COMMIT%'
  order by collection_time desc
