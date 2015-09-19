use msdb
GO
--stop job
exec sp_stop_job @jobname

--start job
exec sp_start_job @jobname


