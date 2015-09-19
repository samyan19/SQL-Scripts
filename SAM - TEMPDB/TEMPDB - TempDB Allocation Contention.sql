SELECT session_id, wait_duration_ms, resource_description
from sys.dm_os_waiting_tasks 
where wait_type LIKE 'PAGELATCH_%' and resource_description LIKE '2.%'