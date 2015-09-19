

/*********************************
Let's build a list of waits we can safely ignore.
*********************************/
IF OBJECT_ID('tempdb..#ignorable_waits') IS NOT NULL
    DROP TABLE #ignorable_waits;
GO

create table #ignorable_waits (wait_type nvarchar(256) PRIMARY KEY);
GO

/* We aren't using row constructors to be SQL 2005 compatible */
set nocount on;
insert #ignorable_waits (wait_type) VALUES ('REQUEST_FOR_DEADLOCK_SEARCH');
insert #ignorable_waits (wait_type) VALUES ('SQLTRACE_INCREMENTAL_FLUSH_SLEEP');
insert #ignorable_waits (wait_type) VALUES ('SQLTRACE_BUFFER_FLUSH');
insert #ignorable_waits (wait_type) VALUES ('LAZYWRITER_SLEEP');
insert #ignorable_waits (wait_type) VALUES ('XE_TIMER_EVENT');
insert #ignorable_waits (wait_type) VALUES ('XE_DISPATCHER_WAIT');
insert #ignorable_waits (wait_type) VALUES ('FT_IFTS_SCHEDULER_IDLE_WAIT');
insert #ignorable_waits (wait_type) VALUES ('LOGMGR_QUEUE');
insert #ignorable_waits (wait_type) VALUES ('CHECKPOINT_QUEUE');
insert #ignorable_waits (wait_type) VALUES ('BROKER_TO_FLUSH');
insert #ignorable_waits (wait_type) VALUES ('BROKER_TASK_STOP');
insert #ignorable_waits (wait_type) VALUES ('BROKER_EVENTHANDLER');
insert #ignorable_waits (wait_type) VALUES ('SLEEP_TASK');
insert #ignorable_waits (wait_type) VALUES ('WAITFOR');
insert #ignorable_waits (wait_type) VALUES ('DBMIRROR_DBM_MUTEX')
insert #ignorable_waits (wait_type) VALUES ('DBMIRROR_EVENTS_QUEUE')
insert #ignorable_waits (wait_type) VALUES ('DBMIRRORING_CMD');
insert #ignorable_waits (wait_type) VALUES ('DISPATCHER_QUEUE_SEMAPHORE');
insert #ignorable_waits (wait_type) VALUES ('BROKER_RECEIVE_WAITFOR');
insert #ignorable_waits (wait_type) VALUES ('CLR_AUTO_EVENT');
insert #ignorable_waits (wait_type) VALUES ('DIRTY_PAGE_POLL');
insert #ignorable_waits (wait_type) VALUES ('HADR_FILESTREAM_IOMGR_IOCOMPLETION');
insert #ignorable_waits (wait_type) VALUES ('ONDEMAND_TASK_QUEUE');
insert #ignorable_waits (wait_type) VALUES ('FT_IFTSHC_MUTEX');
insert #ignorable_waits (wait_type) VALUES ('CLR_MANUAL_EVENT');
insert #ignorable_waits (wait_type) VALUES ('SP_SERVER_DIAGNOSTICS_SLEEP');
GO





/* Want to manually exclude an event and recalculate?*/
/* insert #ignorable_waits (wait_type) VALUES (''); */

/*********************************
What are the highest overall waits since startup?
*********************************/
SELECT TOP 25
	os.wait_type,
	SUM(os.wait_time_ms) OVER (PARTITION BY os.wait_type) as sum_wait_time_ms,
	CAST(
		100.* SUM(os.wait_time_ms) OVER (PARTITION BY os.wait_type)
		/ (1. * SUM(os.wait_time_ms) OVER () )
		AS NUMERIC(10,1)) as pct_wait_time,
	SUM(os.waiting_tasks_count) OVER (PARTITION BY os.wait_type) AS sum_waiting_tasks,
	CASE WHEN  SUM(os.waiting_tasks_count) OVER (PARTITION BY os.wait_type) > 0
	THEN
		CAST(
			SUM(os.wait_time_ms) OVER (PARTITION BY os.wait_type)
				/ (1. * SUM(os.waiting_tasks_count) OVER (PARTITION BY os.wait_type))
			AS NUMERIC(10,1))
	ELSE 0 END AS avg_wait_time_ms,
	CURRENT_TIMESTAMP as sample_time
FROM sys.dm_os_wait_stats os
LEFT JOIN #ignorable_waits iw on
	os.wait_type=iw.wait_type
WHERE
	iw.wait_type is null
ORDER BY sum_wait_time_ms DESC;
GO
