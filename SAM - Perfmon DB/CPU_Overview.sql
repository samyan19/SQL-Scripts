/*
An overview of CPU Performance from the zzPermon data

OUTPUT
------
countername
MinValue
MaxValue
AvgValue
PercentageAboveThreshold (percentage of data above 75% CPU utilization. If >10% indicate the need for more CPU)
*/

USE zzPerfMon
GO
DECLARE @CountAboveThreshold INT
DECLARE	@TotalCount INT

SET @CountAboveThreshold=(SELECT COUNT(1)
FROM dbo.CounterData
WHERE CounterValue>75)

SET @TotalCount=(SELECT COUNT(1) FROM dbo.CounterData)

SELECT 
		 cdt.countername,
		MIN(CounterValue) AS MinValue,
        MAX(CounterValue) AS MaxValue,
        AVG(CounterValue) AS AvgValue,
		CAST(@CountAboveThreshold AS DECIMAL(10,2))/CAST(@TotalCount AS DECIMAL (10,2))*100.0 AS 'PercentageAboveThreshold'
FROM    dbo.CounterDetails cdt
        INNER JOIN dbo.CounterData cd ON cdt.CounterID = cd.CounterID
        INNER JOIN dbo.DisplayToID d ON d.GUID = cd.GUID
WHERE  
        --ObjectName in ('LogicalDisk','Processor','SQLServer:SQL Statistics')
        /*AND*/ cdt.CounterName IN( '% Processor Time')
        AND cdt.InstanceName = '_Total'
GROUP BY CounterName



