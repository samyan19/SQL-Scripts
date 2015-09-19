DECLARE @databaseName SYSNAME
SET @databaseName = 'zzSQLServerAdmin'
CREATE TABLE #tmp_sp_help_jobstep
    (
      step_id INT NULL ,
      step_name NVARCHAR(128) NULL ,
      subsystem NVARCHAR(128) COLLATE Latin1_General_CI_AS
                              NULL ,
      command NVARCHAR(MAX) NULL ,
      flags INT NULL ,
      cmdexec_success_code INT NULL ,
      on_success_action TINYINT NULL ,
      on_success_step_id INT NULL ,
      on_fail_action TINYINT NULL ,
      on_fail_step_id INT NULL ,
      server NVARCHAR(128) NULL ,
      database_name SYSNAME NULL ,
      database_user_name SYSNAME NULL ,
      retry_attempts INT NULL ,
      retry_interval INT NULL ,
      os_run_priority INT NULL ,
      output_file_name NVARCHAR(300) NULL ,
      last_run_outcome INT NULL ,
      last_run_duration INT NULL ,
      last_run_retries INT NULL ,
      last_run_date INT NULL ,
      last_run_time INT NULL ,
      proxy_id INT NULL ,
      job_id UNIQUEIDENTIFIER NULL
    )
DECLARE @job_id UNIQUEIDENTIFIER
DECLARE crs CURSOR local fast_forward
FOR
    ( SELECT    sv.job_id AS [JobID]
      FROM      msdb.dbo.sysjobs_view AS sv
    )
OPEN crs
FETCH crs INTO @job_id
WHILE @@fetch_status >= 0 
    BEGIN
        INSERT  INTO #tmp_sp_help_jobstep
                ( step_id ,
                  step_name ,
                  subsystem ,
                  command ,
                  flags ,
                  cmdexec_success_code ,
                  on_success_action ,
                  on_success_step_id ,
                  on_fail_action ,
                  on_fail_step_id ,
                  server ,
                  database_name ,
                  database_user_name ,
                  retry_attempts ,
                  retry_interval ,
                  os_run_priority ,
                  output_file_name ,
                  last_run_outcome ,
                  last_run_duration ,
                  last_run_retries ,
                  last_run_date ,
                  last_run_time ,
                  proxy_id
                )
                EXEC msdb.dbo.sp_help_jobstep @job_id = @job_id
        UPDATE  #tmp_sp_help_jobstep
        SET     job_id = @job_id
        WHERE   job_id IS NULL
        FETCH crs INTO @job_id
    END
CLOSE crs
DEALLOCATE crs
CREATE TABLE #tmp_sp_help_proxy
    (
      proxy_id INT NULL ,
      name NVARCHAR(300) NULL ,
      credential_identity NVARCHAR(300) NULL ,
      enabled TINYINT NULL ,
      description NVARCHAR(MAX) NULL ,
      user_sid BINARY(200) NULL ,
      credential_id INT NULL ,
      credential_identity_exists INT NULL
    )
INSERT  INTO #tmp_sp_help_proxy
        ( proxy_id ,
          name ,
          credential_identity ,
          enabled ,
          description ,
          user_sid ,
          credential_id ,
          credential_identity_exists
        )
        EXEC msdb.dbo.sp_help_proxy
SELECT  tshj.step_id AS [ID] ,
        tshj.step_name AS [Name] ,
        ISNULL(tshj.command, N'') AS [Command] ,
        tshj.cmdexec_success_code AS [CommandExecutionSuccessCode] ,
        ISNULL(tshj.database_name, N'') AS [DatabaseName] ,
        ISNULL(tshj.database_user_name, N'') AS [DatabaseUserName] ,
        tshj.flags AS [JobStepFlags] ,
        NULL AS [LastRunDate] ,
        tshj.last_run_duration AS [LastRunDuration] ,
        tshj.last_run_outcome AS [LastRunOutcome] ,
        tshj.last_run_retries AS [LastRunRetries] ,
        tshj.on_fail_action AS [OnFailAction] ,
        tshj.on_fail_step_id AS [OnFailStep] ,
        tshj.on_success_action AS [OnSuccessAction] ,
        tshj.on_success_step_id AS [OnSuccessStep] ,
        tshj.os_run_priority AS [OSRunPriority] ,
        ISNULL(tshj.output_file_name, N'') AS [OutputFileName] ,
        tshj.retry_attempts AS [RetryAttempts] ,
        tshj.retry_interval AS [RetryInterval] ,
        ISNULL(tshj.server, N'') AS [Server] ,
        CASE LOWER(tshj.subsystem)
          WHEN 'tsql' THEN 1
          WHEN 'activescripting' THEN 2
          WHEN 'cmdexec' THEN 3
          WHEN 'snapshot' THEN 4
          WHEN 'logreader' THEN 5
          WHEN 'distribution' THEN 6
          WHEN 'merge' THEN 7
          WHEN 'queuereader' THEN 8
          WHEN 'analysisquery' THEN 9
          WHEN 'analysiscommand' THEN 10
          WHEN 'dts' THEN 11
          WHEN 'ssis' THEN 11
          WHEN 'powershell' THEN 12
          ELSE 0
        END AS [SubSystem] ,
        ISNULL(sp.name, N'') AS [ProxyName] ,
        tshj.last_run_date AS [LastRunDateInt] ,
        tshj.last_run_time AS [LastRunTimeInt]
FROM    msdb.dbo.sysjobs_view AS sv
        INNER JOIN #tmp_sp_help_jobstep AS tshj ON tshj.job_id = sv.job_id
        LEFT OUTER JOIN #tmp_sp_help_proxy AS sp ON sp.proxy_id = tshj.proxy_id
WHERE   tshj.database_name = @databaseName
        OR tshj.command LIKE '%' + @databaseName + '%'
ORDER BY [ID] ASC
DROP TABLE #tmp_sp_help_jobstep
DROP TABLE #tmp_sp_help_proxy