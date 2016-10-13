DECLARE @targetTime datetime = '2014-05-04 06:04:49';
-- SET @targetTime = 'xxx' -- for SQL Server 2008 and less

-- convert to string, then int:
DECLARE @filter int = CAST(CONVERT(char(8), @targetTime, 112) AS int); 

WITH times AS (
SELECT 
job_id,
step_name,
LEFT(run_date, 4) + '-' + SUBSTRING(CAST(run_date AS char(8)),5,2) 
        + '-' + RIGHT(run_date,2) + ' ' + 
        LEFT(REPLICATE('0', 6 - LEN(run_time)) 
        + CAST(run_time AS varchar(6)), 2) + ':' + 
        SUBSTRING(REPLICATE('0', 6 - LEN(run_time)) 
        + CAST(run_time AS varchar(6)), 3, 2) + ':' 
        + RIGHT(REPLICATE('0', 6 - LEN(run_time)) 
        + CAST(run_time AS varchar(6)), 2) AS [start_time],
'2010-01-01 ' + LEFT(REPLICATE('0', 6 - LEN(run_duration)) 
        + CAST(run_duration AS varchar(6)), 2) + ':' + 
        SUBSTRING(REPLICATE('0', 6 - LEN(run_duration)) 
        + CAST(run_duration AS varchar(6)), 3, 2) + ':' + 
        RIGHT(REPLICATE('0', 6 - LEN(run_duration)) 
        + CAST(run_duration AS varchar(6)), 2) [duration]
FROM 
        msdb.dbo.sysjobhistory
WHERE
        run_date IN (@filter - 1, @filter, @filter + 1)
)

SELECT 
        j.name,
        t.step_name,
        t.start_time, 
        DATEADD(ss, DATEDIFF(ss, '2010-01-01 00:00:00', 
                duration), start_time) [end_time]
FROM 
        times t
        INNER JOIN msdb.dbo.sysjobs j ON j.job_id = t.job_id
WHERE
        @targetTime >= start_time
                AND @targetTime <= DATEADD(ss, DATEDIFF(ss, '2010-01-01 00:00:00', 
                        duration), start_time)
ORDER BY 
        start_time ASC;
