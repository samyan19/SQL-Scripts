DECLARE @TraceFile varchar(max)
SELECT @TraceFile = CONVERT(varchar(max),value) FROM ::fn_trace_getinfo(0) WHERE traceid=1 AND property=2

SELECT 
DatabaseName,count(1) as [GrowthCount]
FROM ::fn_trace_gettable(@TraceFile,0)
     INNER JOIN sys.trace_events e
          ON eventclass = trace_event_id
     INNER JOIN sys.trace_categories AS cat
          ON e.category_id = cat.category_id
WHERE /*databasename = 'TraceDB' AND*/
      e.category_id = 2 AND --category 2 is database
      e.trace_event_id = 92 --93=Log File Auto Grow
group by DatabaseName
