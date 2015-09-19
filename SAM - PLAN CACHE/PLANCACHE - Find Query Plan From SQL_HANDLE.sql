--Get query plan handle
select qs. sql_handle, qs.plan_handle
from sys.dm_exec_query_stats qs 
where qs.sql_handle=0x030005003feeec64be95140184a300000100000000000000

--Get query plan
select * from sys.dm_exec_query_plan(0x050005003FEEEC644021A71B060000000000000000000000)