-- Resource Usage  
select r.ring_buffer_address,  
r.ring_buffer_type,  
dateadd(hour,-1,dateadd (ms, r.[timestamp] - sys.ms_ticks, getdate())) as record_time,  
cast(r.record as xml) record  
from sys.dm_os_ring_buffers r  
cross join sys.dm_os_sys_info sys  
where   
ring_buffer_type='RING_BUFFER_CONNECTIVITY' 
order by 3 desc 




-- Exceptions  
select r.ring_buffer_address,  
r.ring_buffer_type,  
dateadd(hour,-1,dateadd (ms, r.[timestamp] - sys.ms_ticks, getdate())) as record_time,  
cast(r.record as xml) record  
from sys.dm_os_ring_buffers r  
cross join sys.dm_os_sys_info sys  
where   
ring_buffer_type='RING_BUFFER_EXCEPTION' 
order by 3 desc 