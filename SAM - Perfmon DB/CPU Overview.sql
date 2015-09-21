/*
An overview of CPU Performance from the zzPermon data

OUTPUT
------
CollectionStartDate
countername
MinValue
MaxValue
AvgValue
PercentageAboveThreshold (percentage of data above 75% CPU utilization. If >10% indicate the need for more CPU)
*/

USE zzPerfMon
GO
DECLARE @CountAboveThreshold INT
DECLARE	@TotalCount INT, 
		@CollectionStartDate char(24)



/* Min Collection Date */
set @CollectionStartDate=(select MIN (CounterDateTime)
from CounterData
where CounterID=1)


/*
select working set
*/
SELECT CounterName,CounterValue
INTO #Dataset
FROM    dbo.CounterDetails cdt
        INNER JOIN dbo.CounterData cd ON cdt.CounterID = cd.CounterID
        INNER JOIN dbo.DisplayToID d ON d.GUID = cd.GUID
WHERE  
        --ObjectName in ('LogicalDisk','Processor','SQLServer:SQL Statistics')
        /*AND*/ cdt.CounterName IN( '% Processor Time')
        AND cdt.InstanceName = '_Total'

/* find total count*/
SET @TotalCount=(SELECT COUNT(1) FROM #Dataset)

/*find count matching criteria*/
SET @CountAboveThreshold=(SELECT COUNT(1) FROM #Dataset WHERE countervalue>75.0)


/*return aggregates and results*/
SELECT
		@CollectionStartDate AS 'CollectionStartDate', 
		countername,
		MIN(CounterValue) AS MinValue,
        MAX(CounterValue) AS MaxValue,
        AVG(CounterValue) AS AvgValue,
		CAST(@CountAboveThreshold AS DECIMAL(10,2))/CAST(@TotalCount AS DECIMAL (10,2))*100.0 AS 'PercentAboveThreshold'
FROM #Dataset
GROUP BY CounterName;


IF  EXISTS (SELECT OBJECT_ID('tempdb..#dataset'))
	DROP TABLE #dataset;


--26:1 DATA SIZE TO MEMORY
--28% above threshold

