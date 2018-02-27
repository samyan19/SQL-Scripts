/*


declare @TraceIDToReview int
declare @path varchar(255)
DECLARE @DatabaseName = 'Test' -- make this the database you're interested in.

SET @TraceIDToReview = 1 --this is the trace you want to review!
SELECT @path = path from sys.traces WHERE id = @TraceIDToReview
SELECT 
  TE.name As EventClassDescrip,
  v.subclass_name As EventSubClassDescrip,
T.*
FROM sys.fn_trace_gettable(@path, default) T
LEFT OUTER JOIN sys.trace_events TE ON T.EventClass = TE.trace_event_id
           LEFT OUTER JOIN sys.trace_subclass_values V
             ON T.EventClass = V.trace_event_id AND  T.EventSubClass = V.subclass_value
             WHERE DatabaseName = @DatabaseName 
