USE zzPerfMon
GO

SELECT 
		 cdt.countername,
		MIN(CounterValue) AS MinValue,
        MAX(CounterValue) AS MaxValue,
        AVG(CounterValue) AS AvgValue
FROM    dbo.CounterDetails cdt
        INNER JOIN dbo.CounterData cd ON cdt.CounterID = cd.CounterID
        INNER JOIN dbo.DisplayToID d ON d.GUID = cd.GUID
WHERE  
        --ObjectName in ('LogicalDisk','Processor','SQLServer:SQL Statistics')
        /*AND*/ cdt.CounterName IN( 'Disk Writes/sec','Disk Reads/sec','% Processor Time','Batch Requests/sec')
        AND (cdt.InstanceName IS NULL OR cdt.InstanceName ='_Total')
GROUP BY CounterName