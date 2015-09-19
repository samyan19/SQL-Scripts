
/*
	We've hit the major pain points on reliability and security.  Now let's do a
	little poking around in performance.  Let's query the server's wait stats,
	which tell us what things the server has been waiting on since the last
	restart.  For more about wait stats, check out:
	http://sqlserverpedia.com/wiki/Wait_Types
*/
SELECT *, (wait_time_ms - signal_wait_time_ms) AS real_wait_time_ms 
FROM sys.dm_os_wait_stats 
ORDER BY (wait_time_ms - signal_wait_time_ms) DESC