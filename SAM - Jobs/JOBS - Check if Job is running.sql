DECLARE @running int=0;
DECLARE @jobname nvarchar(100)='test'
declare @runningjobs table (Job_ID UNIQUEIDENTIFIER,   
							Last_Run_Date INT,   
							Last_Run_Time INT,   
							Next_Run_Date INT,   
							Next_Run_Time INT,   
							Next_Run_Schedule_ID INT,   
							Requested_To_Run INT,   
							Request_Source INT,   
							Request_Source_ID VARCHAR(100),   
							Running INT,   
							Current_Step INT,   
							Current_Retry_Attempt INT,   
							State INT)
      
INSERT INTO @RunningJobs EXEC master.dbo.xp_sqlagent_enum_jobs 1,''   
  
SELECT   @running = COUNT(1)
FROM     @RunningJobs JSR  
JOIN     msdb.dbo.sysjobs  
ON       JSR.Job_ID=sysjobs.job_id  
WHERE    Running=1 and name =@jobname -- i.e. still running  

if @running>0
	exec sp_stop_job @jobname
else 
	print 'job not running'