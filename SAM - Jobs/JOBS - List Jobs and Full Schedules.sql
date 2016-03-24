/*
http://www.sqlprofessionals.com/blog/sql-scripts/2014/10/06/insight-into-sql-agent-job-schedules/

*/

SELECT	 [JobName] = [jobs].[name]
		,[Category] = [categories].[name]
		,[Owner] = SUSER_SNAME([jobs].[owner_sid])
		,[Enabled] = CASE [jobs].[enabled] WHEN 1 THEN 'Yes' ELSE 'No' END
		,[Scheduled] = CASE [schedule].[enabled] WHEN 1 THEN 'Yes' ELSE 'No' END
		,[Description] = [jobs].[description]
		,[Occurs] = 
				CASE [schedule].[freq_type]
					WHEN   1 THEN 'Once'
					WHEN   4 THEN 'Daily'
					WHEN   8 THEN 'Weekly'
					WHEN  16 THEN 'Monthly'
					WHEN  32 THEN 'Monthly relative'
					WHEN  64 THEN 'When SQL Server Agent starts'
					WHEN 128 THEN 'Start whenever the CPU(s) become idle' 
					ELSE ''
				END
		,[Occurs_detail] = 
				CASE [schedule].[freq_type]
					WHEN   1 THEN 'O'
					WHEN   4 THEN 'Every ' + CONVERT(VARCHAR, [schedule].[freq_interval]) + ' day(s)'
					WHEN   8 THEN 'Every ' + CONVERT(VARCHAR, [schedule].[freq_recurrence_factor]) + ' weeks(s) on ' + 
						LEFT(
							CASE WHEN [schedule].[freq_interval] &  1 =  1 THEN 'Sunday, '    ELSE '' END + 
							CASE WHEN [schedule].[freq_interval] &  2 =  2 THEN 'Monday, '    ELSE '' END + 
							CASE WHEN [schedule].[freq_interval] &  4 =  4 THEN 'Tuesday, '   ELSE '' END + 
							CASE WHEN [schedule].[freq_interval] &  8 =  8 THEN 'Wednesday, ' ELSE '' END + 
							CASE WHEN [schedule].[freq_interval] & 16 = 16 THEN 'Thursday, '  ELSE '' END + 
							CASE WHEN [schedule].[freq_interval] & 32 = 32 THEN 'Friday, '    ELSE '' END + 
							CASE WHEN [schedule].[freq_interval] & 64 = 64 THEN 'Saturday, '  ELSE '' END , 
							LEN(
								CASE WHEN [schedule].[freq_interval] &  1 =  1 THEN 'Sunday, '    ELSE '' END + 
								CASE WHEN [schedule].[freq_interval] &  2 =  2 THEN 'Monday, '    ELSE '' END + 
								CASE WHEN [schedule].[freq_interval] &  4 =  4 THEN 'Tuesday, '   ELSE '' END + 
								CASE WHEN [schedule].[freq_interval] &  8 =  8 THEN 'Wednesday, ' ELSE '' END + 
								CASE WHEN [schedule].[freq_interval] & 16 = 16 THEN 'Thursday, '  ELSE '' END + 
								CASE WHEN [schedule].[freq_interval] & 32 = 32 THEN 'Friday, '    ELSE '' END + 
								CASE WHEN [schedule].[freq_interval] & 64 = 64 THEN 'Saturday, '  ELSE '' END 
							) - 1
						)
					WHEN  16 THEN 'Day ' + CONVERT(VARCHAR, [schedule].[freq_interval]) + ' of every ' + CONVERT(VARCHAR, [schedule].[freq_recurrence_factor]) + ' month(s)'
					WHEN  32 THEN 'The ' + 
							CASE [schedule].[freq_relative_interval]
								WHEN  1 THEN 'First'
								WHEN  2 THEN 'Second'
								WHEN  4 THEN 'Third'
								WHEN  8 THEN 'Fourth'
								WHEN 16 THEN 'Last' 
							END +
							CASE [schedule].[freq_interval]
								WHEN  1 THEN ' Sunday'
								WHEN  2 THEN ' Monday'
								WHEN  3 THEN ' Tuesday'
								WHEN  4 THEN ' Wednesday'
								WHEN  5 THEN ' Thursday'
								WHEN  6 THEN ' Friday'
								WHEN  7 THEN ' Saturday'
								WHEN  8 THEN ' Day'
								WHEN  9 THEN ' Weekday'
								WHEN 10 THEN ' Weekend Day' 
							END + ' of every ' + CONVERT(VARCHAR, [schedule].[freq_recurrence_factor]) + ' month(s)' 
					ELSE ''
				END
		,[Frequency] = 
				CASE [schedule].[freq_subday_type]
					WHEN 1 THEN 'Occurs once at ' + 
								STUFF(STUFF(RIGHT('000000' + CONVERT(VARCHAR(8), [schedule].[active_start_time]), 6), 5, 0, ':'), 3, 0, ':')
					WHEN 2 THEN 'Occurs every ' + 
								CONVERT(VARCHAR, [schedule].[freq_subday_interval]) + ' Seconds(s) between ' + 
								STUFF(STUFF(RIGHT('000000' + CONVERT(VARCHAR(8), [schedule].[active_start_time]), 6), 5, 0, ':'), 3, 0, ':') + ' and ' + 
								STUFF(STUFF(RIGHT('000000' + CONVERT(VARCHAR(8), [schedule].[active_end_time]), 6), 5, 0, ':'), 3, 0, ':')
					WHEN 4 THEN 'Occurs every ' + 
								CONVERT(VARCHAR, [schedule].[freq_subday_interval]) + ' Minute(s) between ' + 
								STUFF(STUFF(RIGHT('000000' + CONVERT(VARCHAR(8), [schedule].[active_start_time]), 6), 5, 0, ':'), 3, 0, ':') + ' and ' + 
								STUFF(STUFF(RIGHT('000000' + CONVERT(VARCHAR(8), [schedule].[active_end_time]), 6), 5, 0, ':'), 3, 0, ':')
					WHEN 8 THEN 'Occurs every ' + 
								CONVERT(VARCHAR, [schedule].[freq_subday_interval]) + ' Hour(s) between ' + 
								STUFF(STUFF(RIGHT('000000' + CONVERT(VARCHAR(8), [schedule].[active_start_time]), 6), 5, 0, ':'), 3, 0, ':') + ' and ' + 
								STUFF(STUFF(RIGHT('000000' + CONVERT(VARCHAR(8), [schedule].[active_end_time]), 6), 5, 0, ':'), 3, 0, ':')
					ELSE ''
				END
		,[AvgDurationInSec] = CONVERT(DECIMAL(10, 2), [jobhistory].[AvgDuration])
		,[Next_Run_Date] = 
				CASE [jobschedule].[next_run_date]
					WHEN 0 THEN CONVERT(DATETIME, '1900/1/1')
					ELSE CONVERT(DATETIME, CONVERT(CHAR(8), [jobschedule].[next_run_date], 112) + ' ' + 
						 STUFF(STUFF(RIGHT('000000' + CONVERT(VARCHAR(8), [jobschedule].[next_run_time]), 6), 5, 0, ':'), 3, 0, ':'))
				END
FROM	 [msdb].[dbo].[sysjobs] AS [jobs] WITh(NOLOCK) 
		 LEFT OUTER JOIN [msdb].[dbo].[sysjobschedules] AS [jobschedule] WITh(NOLOCK) 
				 ON [jobs].[job_id] = [jobschedule].[job_id] 
		 LEFT OUTER JOIN [msdb].[dbo].[sysschedules] AS [schedule] WITh(NOLOCK) 
				 ON [jobschedule].[schedule_id] = [schedule].[schedule_id] 
		 INNER JOIN [msdb].[dbo].[syscategories] [categories] WITh(NOLOCK) 
				 ON [jobs].[category_id] = [categories].[category_id] 
		 LEFT OUTER JOIN 
					(	SELECT	 [job_id], [AvgDuration] = (SUM((([run_duration] / 10000 * 3600) + 
																(([run_duration] % 10000) / 100 * 60) + 
																 ([run_duration] % 10000) % 100)) * 1.0) / COUNT([job_id])
						FROM	 [msdb].[dbo].[sysjobhistory] WITh(NOLOCK)
						WHERE	 [step_id] = 0 
						GROUP BY [job_id]
					 ) AS [jobhistory] 
				 ON [jobhistory].[job_id] = [jobs].[job_id];
GO
