select scheduler_id, cpu_id, status, is_online 
from sys.dm_os_schedulers 
where status = 'VISIBLE ONLINE'
