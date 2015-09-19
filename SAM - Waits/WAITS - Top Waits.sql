select wait_type,
	waiting_tasks_count,
	wait_time_ms,
	max_wait_time_ms,
	signal_wait_time_ms
from sys.dm_os_wait_stats
order by wait_time_ms desc
GO