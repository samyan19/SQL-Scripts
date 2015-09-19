--xp_readerrorlog 1

--drop table DeadlockReports


DECLARE @deadlocks table (DeadlockID INT IDENTITY (1,1) PRIMARY KEY CLUSTERED,
							TIME datetime,
							DATA xml);

;WITH SystemHealth
AS (
SELECT CAST(target_data AS xml) AS SessionXML
FROM sys.dm_xe_session_targets st
INNER JOIN sys.dm_xe_sessions s ON s.address = st.event_session_address
WHERE name = 'system_health'
)
 
INSERT INTO @deadlocks 
SELECT Deadlock.value('@timestamp', 'datetime') AS DeadlockDateTime
,CAST(Deadlock.value('(data/value)[1]', 'varchar(max)') as xml) as DeadlockGraph
FROM SystemHealth s 
CROSS APPLY SessionXML.nodes ('//RingBufferTarget/event') AS t (Deadlock)
WHERE Deadlock.value('@name', 'nvarchar(128)') = 'xml_deadlock_report';

;WITH a AS (
SELECT distinct
	DEADLOCKID,
	--data,
	--time,
	deadlocklist.Graphs.value('@clientapp','varchar(100)') as 'clientapp',
	deadlocklist.Graphs.value('@hostname','varchar(100)') as 'hostname',
	deadlocklist.Graphs.value('@isolationlevel','varchar(100)') as 'isolationlevel',
	db_name(deadlocklist.Graphs.value('@currentdb','int')) as [DATABASE]
FROM @deadlocks
cross APPLY data.nodes('/deadlock/process-list/process') deadlocklist(Graphs)
)
--insert into DeadlockReport
SELECT d.TIME,d.DATA, a.[DATABASE],a.clientapp,a.hostname,a.isolationlevel
--into DeadlockReports
FROM a
JOIN @deadlocks d ON a.DeadlockID=d.DeadlockID
order by time DESC