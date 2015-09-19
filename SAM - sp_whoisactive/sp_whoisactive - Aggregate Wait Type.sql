/****** Script for SelectTopNRows command from SSMS  ******/

--sp_AskBrent @seconds =0, @ExpertMode =1 

;with CTE as (
SELECT TOP 3000 
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
  FROM [zzSQLServerAdmin].[dbo].[WhoIsActive]
  where collection_time < '2015-06-11 12:20:00'
  and collection_time > '2015-06-11 11:50:00'
 -- and wait_info like '%HADR_SYNC_COMMIT%'
  --order by collection_time desc
  )
  select wait_type,count(1) as count
  from CTE
  where wait_type is not NULL
  group by wait_type
  order by count desc
