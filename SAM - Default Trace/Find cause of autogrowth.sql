/*
http://nebraskasql.blogspot.co.uk/2016/06/finding-file-growths-with-extended.html
*/

/*
Default Trace AutoGrow Query
Modified from Tibor Karazi
http://sqlblog.com/blogs/tibor_karaszi/archive/2008/06/19/did-we-have-recent-autogrow.aspx
and Feodor Georgiev
https://www.simple-talk.com/sql/database-administration/collecting-the-information-in-the-default-trace/
*/

DECLARE @df bit
SELECT @df = is_default FROM sys.traces WHERE id = 1
IF @df = 0 OR @df IS NULL
BEGIN
  RAISERROR('No default trace running!', 16, 1)
  RETURN
END
SELECT te.name as EventName
, t.DatabaseName
, t.FileName
, t.StartTime
, t.ApplicationName
, HostName
, LoginName
, Duration
, TextData
FROM fn_trace_gettable(
 (SELECT REVERSE(SUBSTRING(REVERSE(path), CHARINDEX('\', REVERSE(path)),256)) + 'log.trc'
 FROM    sys.traces
 WHERE   is_default = 1
 ), DEFAULT) AS t 
INNER JOIN sys.trace_events AS te
ON t.EventClass = te.trace_event_id 
WHERE 1=1
and te.name LIKE '%Auto Grow' 
--and DatabaseName='tempdb'
--and StartTime>'05/27/2014'
ORDER BY StartTime
--
SELECT TOP 1 'Oldest StartTime' as Label, t.StartTime
FROM fn_trace_gettable(
 (SELECT REVERSE(SUBSTRING(REVERSE(path), CHARINDEX('\', REVERSE(path)),256)) + 'log.trc'
 FROM    sys.traces
 WHERE   is_default = 1
 ), DEFAULT) AS t
INNER JOIN sys.trace_events AS te
ON t.EventClass = te.trace_event_id 
ORDER BY StartTime   
