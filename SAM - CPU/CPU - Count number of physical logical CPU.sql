DECLARE @xp_msver TABLE (
    [idx] [int] NULL
    ,[c_name] [varchar](100) NULL
    ,[int_val] [float] NULL
    ,[c_val] [varchar](128) NULL
    )
 
INSERT INTO @xp_msver
EXEC ('[master]..[xp_msver]');;
 
WITH [ProcessorInfo]
AS (
    SELECT ([cpu_count] / [hyperthread_ratio]) AS [number_of_physical_cpus]
        ,CASE
            WHEN hyperthread_ratio = cpu_count
                THEN cpu_count
            ELSE (([cpu_count] - [hyperthread_ratio]) / ([cpu_count] / [hyperthread_ratio]))
            END AS [number_of_cores_per_cpu]
        ,CASE
            WHEN hyperthread_ratio = cpu_count
                THEN cpu_count
            ELSE ([cpu_count] / [hyperthread_ratio]) * (([cpu_count] - [hyperthread_ratio]) / ([cpu_count] / [hyperthread_ratio]))
            END AS [total_number_of_cores]
        ,[cpu_count] AS [number_of_virtual_cpus]
        ,(
            SELECT [c_val]
            FROM @xp_msver
            WHERE [c_name] = 'Platform'
            ) AS [cpu_category]
    FROM [sys].[dm_os_sys_info]
    )
SELECT [number_of_physical_cpus]
    ,[number_of_cores_per_cpu]
    ,[total_number_of_cores]
    ,[number_of_virtual_cpus]
    ,LTRIM(RIGHT([cpu_category], CHARINDEX('x', [cpu_category]) - 1)) AS [cpu_category]
FROM [ProcessorInfo]
