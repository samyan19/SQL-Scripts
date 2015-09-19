/* List machines */
SELECT DISTINCT
        [MachineName]
FROM    dbo.CounterDetails   

/* List data collection */
SELECT  [DisplayString] ,
        [LogStartTime] ,
        [LogStopTime]
FROM    dbo.DisplayToID 


/* List counters */
select distinct objectname,CounterName,InstanceName
from CounterDetails


/* Check values for a specific counter */
 SELECT  MachineName ,
        CounterName ,
        InstanceName ,
        CounterValue ,
        CounterDateTime ,
        DisplayString
FROM    dbo.CounterDetails cdt
        INNER JOIN dbo.CounterData cd ON cdt.CounterID = cd.CounterID
        INNER JOIN DisplayToID d ON d.GUID = cd.GUID
WHERE   MachineName = '\\ALF'
        AND ObjectName = 'Processor'
        AND cdt.CounterName = '% Processor Time'
        AND cdt.InstanceName = '_Total'
ORDER BY CounterDateTime



/* Check values for a specific counter aggregated */
SELECT  MachineName ,
        CounterName ,
        InstanceName ,
        MIN(CounterValue) AS minValue ,
        MAX(CounterValue) AS maxValue ,
        AVG(CounterValue) AS avgValue ,
        DisplayString
FROM    dbo.CounterDetails cdt
        INNER JOIN dbo.CounterData cd ON cdt.CounterID = cd.CounterID
        INNER JOIN dbo.DisplayToID d ON d.GUID = cd.GUID
WHERE   MachineName = '\\ALF'
        AND ObjectName = 'Processor'
        AND cdt.CounterName = '% Processor Time'
        AND cdt.InstanceName = '_Total'
GROUP BY MachineName ,
        CounterName ,
        InstanceName ,
        DisplayString 