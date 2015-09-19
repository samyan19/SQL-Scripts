--xp_readerrorlog 1
--DBCC TRACESTATUS(-1)
--DBCC TRACEON (3205,-1)

DECLARE @deadlocks table (data xml);

;WITH SystemHealth
 AS (
 SELECT CAST(target_data as xml) AS TargetData
 FROM sys.dm_xe_session_targets st
 JOIN sys.dm_xe_sessions s
 ON s.address = st.event_session_address
 WHERE name = 'system_health'
 AND st.target_name = 'ring_buffer')
 
 insert INTO @deadlocks 
 SELECT cast (XEventData.XEvent.value('(data/value)[1]','VARCHAR(MAX)') AS XML) AS DeadlockList
 FROM SystemHealth
 CROSS APPLY TargetData.nodes('//RingBufferTarget/event') AS XEventData (XEvent)
 WHERE XEventData.XEvent.value('@name','varchar(4000)') = 'xml_deadlock_report';

SELECT
	data,
   DeadlockList.Graphs.value('(process-list/process[1]/@spid)[1]', 'NVarChar(15)') AS VictimProcessID,
   CAST(REPLACE(DeadlockList.Graphs.value('(process-list/process[1]/@lastbatchstarted)[1]', 'NChar(23)'), N'T', N' ') AS DATETIME) AS VictimLastBatchStarted,
   DeadlockList.Graphs.value('(process-list/process[1]/@lockMode)[1]', 'NVarChar(15)') AS VictimLockMode,
   DeadlockList.Graphs.value('(process-list/process[1]/@xactid)[1]', 'NVarChar(15)') AS VictimXActID,
   DeadlockList.Graphs.value('(process-list/process[1]/@clientapp)[1]', 'NVarChar(50)') AS VictimClientApp,
   --Live
   DeadlockList.Graphs.value('(process-list/process[2]/@spid)[1]', 'NVarChar(15)') AS LiveProcessID,
   CAST(REPLACE(DeadlockList.Graphs.value('(pprocess-list/process[2]/@lastbatchstarted)[1]', 'NChar(23)'), N'T', N' ') AS DATETIME) AS LiveLastBatchStarted,
   DeadlockList.Graphs.value('(process-list/process[2]/@lockMode)[1]', 'NVarChar(15)') AS LiveLockMode,
   DeadlockList.Graphs.value('(process-list/process[2]/@xactid)[1]', 'NVarChar(15)') AS LiveXActID,
   DeadlockList.Graphs.value('(process-list/process[2]/@clientapp)[1]', 'NVarChar(50)') AS LiveClientApp,
   --Live resource.
   DeadlockList.Graphs.value('(resource-list/pagelock[1]/@fileid)[1]', 'NVarChar(15)') AS LiveFileID,
   DeadlockList.Graphs.value('(resource-list/pagelock[1]/@pageid)[1]', 'NVarChar(15)') AS LivePageID,
   DeadlockList.Graphs.value('(resource-list/pagelock[1]/@objectname)[1]', 'NVarChar(50)') AS LiveObjName,
   DeadlockList.Graphs.value('(resource-list/pagelock[1]/@mode)[1]', 'NVarChar(50)') AS LiveLockModeHeld,
   DeadlockList.Graphs.value('(resource-list/pagelock[1]/waiter-list/waiter/@mode)[1]', 'NVarChar(50)') AS VictimLockModeRequest,    
   --Victim resource.
   DeadlockList.Graphs.value('(resource-list/pagelock[2]/@fileid)[1]', 'NVarChar(15)') AS VictimFileID,
   DeadlockList.Graphs.value('(resource-list/pagelock[2]/@pageid)[1]', 'NVarChar(15)') AS VictimPageID,
   DeadlockList.Graphs.value('(resource-list/pagelock[2]/@objectname)[1]', 'NVarChar(50)') AS VictimObjName,
   DeadlockList.Graphs.value('(resource-list/pagelock[2]/@mode)[1]', 'NVarChar(50)') AS VictimLockModeHeld,  
   DeadlockList.Graphs.value('(resource-list/pagelock[2]/waiter-list/waiter/@mode)[1]', 'NVarChar(50)') AS LiveLockModeRequest,
   --Inputbuffers
   DeadlockList.Graphs.value('(process-list/process[1]/executionStack/frame/@procname)[1]', 'NVarChar(100)') AS VictimProcName,
   DeadlockList.Graphs.value('(process-list/process[1]/executionStack/frame)[1]', 'VarChar(max)') AS VictimExecStack,
   DeadlockList.Graphs.value('(process-list/process[2]/executionStack/frame/@procname)[1]', 'NVarChar(max)') AS LiveProcName,
   DeadlockList.Graphs.value('(process-list/process[2]/executionStack/frame)[1]', 'VarChar(max)') AS LiveExecStack,
   RTRIM(LTRIM(REPLACE(DeadlockList.Graphs.value('(process-list/process[1]/inputbuf)[1]', 'NVarChar(2048)'), NCHAR(10), N''))) AS VictimInputBuffer,
   RTrim(LTrim(Replace(DeadlockList.Graphs.value('(process-list/process[2]/inputbuf)[1]', 'NVARCHAR(2048)'), NChar(10), N''))) AS LiveInputBuffer
FROM @deadlocks
cross APPLY data.nodes('deadlock') deadlocklist(Graphs);
