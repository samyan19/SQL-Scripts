/**
There are two dynamic management views (DMVs) for monitoring seeding: sys.dm_hadr_automatic_seeding and sys.dm_hadr_physical_seeding_stats.

sys.dm_hadr_automatic_seeding contains the general status of automatic seeding, and retains the history for each time it is executed (whether successful or not). 
The column current_state has either a value of COMPLETED or FAILED. If the value is FAILED, use the value in failure_state_desc to help in diagnosing the problem. 
You may need to combine that with what it in the SQL Server Log to see what went wrong. This DMV is populated on the primary replica and all secondary replicas.

sys.dm_hadr_physical_seeding_stats shows the status of the automatic seeding operation as it is executing. 
As with sys.dm_hadr_automatic_seeding, this returns values for both the primary and secondary replicas, but this history is not stored. 
#The values are for the current execution only, and is not retained. 
Columns of interest include start_time_utc, end_time_utc, estimate_time_complete_utc, total_disk_io_wait_time_ms, total_network_wait_time_ms, and if the seeding operation fails, failure_message.
**/
