SELECT Convert(varchar(20),SERVERPROPERTY('ServerName')) AS ServerName,
j.name AS job_name,
CASE j.enabled WHEN 1 THEN 'Enabled' Else 'Disabled' END AS job_status,
CASE jh.run_status WHEN 0 THEN 'Error Failed'
				WHEN 1 THEN 'Succeeded'
				WHEN 2 THEN 'Retry'
				WHEN 3 THEN 'Cancelled'
				WHEN 4 THEN 'In Progress' ELSE
				'Status Unknown' END AS 'last_run_status',
ja.run_requested_date as last_run_date,
CONVERT(VARCHAR(10),CONVERT(DATETIME,RTRIM(19000101))+(jh.run_duration * 9 + jh.run_duration % 10000 * 6 + jh.run_duration % 100 * 10) / 216e4,108) AS run_duration,
ja.next_scheduled_run_date,
CONVERT(VARCHAR(500),jh.message) AS step_description
FROM
(msdb.dbo.sysjobactivity ja LEFT JOIN msdb.dbo.sysjobhistory jh ON ja.job_history_id = jh.instance_id)
join msdb.dbo.sysjobs_view j on ja.job_id = j.job_id
WHERE ja.session_id=(SELECT MAX(session_id)  from msdb.dbo.sysjobactivity) ORDER BY job_name,job_status