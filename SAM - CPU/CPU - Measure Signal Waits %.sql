/*
In conclusion, if Signal Waits are a significant percentage of total waits, 
you have CPU pressure which may be alleviated by faster or more CPUs.  
Alternately, CPU pressure can be reduced by eliminating unnecessary sorts 
(indexes can avoid sorts in order & group by’s) and joins, and compilations (and re-compilations).  
If Signal Waits are not significant, a faster CPU will not appreciably improve performance.
*/


dbcc sqlperf ([sys.dm_os_wait_stats],clear) with no_infomsgs

---- Total waits are wait_time_ms
Select signal_wait_time_ms=sum(signal_wait_time_ms)
          ,'%signal (cpu) waits' = cast(100.0 * sum(signal_wait_time_ms) / sum (wait_time_ms) as numeric(20,2))
          ,resource_wait_time_ms=sum(wait_time_ms - signal_wait_time_ms)
          ,'%resource waits'= cast(100.0 * sum(wait_time_ms - signal_wait_time_ms) / sum (wait_time_ms) as numeric(20,2))
From sys.dm_os_wait_stats