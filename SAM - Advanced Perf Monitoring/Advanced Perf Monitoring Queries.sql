/*
file io activity
*/
use tempdb
GO
SELECT file_name(file_id) as filename,num_of_reads,num_of_bytes_read,num_of_writes,num_of_bytes_written
from sys.dm_io_virtual_file_stats(db_id('tempdb'),NULL)/*fileid*/


/*
status and waittype for given session
*/
select status,wait_type
from sys.dm_exec_requests
where session_id=72


/*
memory grants for running query
*/
select granted_memory_kb,used_memory_kb,max_used_memory_kb
from sys.dm_exec_query_memory_grants
where session_id=74


/*
os tasks contained for this particular session. parent task is 0 (co-ordinator mostly suspended, waiting for child to complete)
*/
SELECT task_state, exec_context_id, parent_task_address, task_address
from sys.dm_os_tasks
where session_id=74


/*
To see if the session is waiting for anything
*/
select wait_type,exec_context_id,blocking_exec_context_id,waiting_task_address,blocking_task_address
from sys.dm_os_waiting_tasks
where session_id=74


/*
to reset wait stats
*/
dbcc sqlperf('sys.dm_os_wait_stats',clear)


/*
check what is waiting on a particular wait_type
*/
SELECT * FROM sys.dm_os_wait_stats where wait_type='cxpacket'



