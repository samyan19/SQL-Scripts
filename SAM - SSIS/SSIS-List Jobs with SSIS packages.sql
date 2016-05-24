/*
https://www.experts-exchange.com/questions/27773643/SQl-how-to-get-a-list-of-jobs-that-run-SSIS-packages.html
*/

USE [msdb]
GO
SELECT j.job_id,
       s.srvname,
       j.name,
       js.subsystem,
       js.step_id,
       js.command,
       j.enabled,
       js.output_file_name,
       js.last_run_outcome,
       js.last_run_duration,
       js.last_run_retries,
       js.last_run_date,
       js.last_run_time,
        js.proxy_id 
FROM   dbo.sysjobs j
JOIN   dbo.sysjobsteps js
   ON  js.job_id = j.job_id 
JOIN   MASTER.dbo.sysservers s
   ON  s.srvid = j.originating_server_id
--filter only the job steps which are executing SSIS packages 
WHERE  subsystem = 'SSIS'
--use the line below to enter some search criteria
--AND js.command LIKE N'%ENTER_SEARCH%'
GO 
