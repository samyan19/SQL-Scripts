/****all trace events****/
SELECT * from sys.trace_events
order by name asc


/****Default trace events****/
DECLARE @TraceID INT;

SELECT @TraceID = id FROM sys.traces WHERE is_default = 1;

SELECT c.name, e.name as Event_Description
  FROM sys.fn_trace_geteventinfo(@TraceID) t
  JOIN sys.trace_events e ON t.eventID = e.trace_event_id
  join sys.trace_categories c on e.category_id=c.category_id
  GROUP BY c.name, e.name
