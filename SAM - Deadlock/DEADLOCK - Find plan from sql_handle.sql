/* 
https://blogs.msdn.microsoft.com/sqlprogrammability/2007/01/09/2-0-sql_handle-and-plan_handle-explained/
*/

select * from sys.dm_exec_query_stats
where sql_handle=0x02000000f9ee08346130583940b38bf98af1832d300c0aaa0000000000000000000000000000000000000000


select st.text, qs. sql_handle, qs.plan_handle
from sys.dm_exec_query_stats qs cross apply sys.dm_exec_sql_text(sql_handle) st
go
