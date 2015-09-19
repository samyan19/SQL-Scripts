
SELECT *
FROM   master.dbo.fn_trace_gettable(( SELECT REVERSE(SUBSTRING(REVERSE(path),
                                                          CHARINDEX('\',
                                                              REVERSE(path)),
                                                          256)) + 'log.trc'
                                FROM    sys.traces
                                WHERE   is_default = 1
                              ), DEFAULT) T
        INNER JOIN sys.trace_events TE 
			ON T.EventClass = TE.trace_event_id
        INNER JOIN sys.trace_subclass_values V 
			ON V.trace_event_id = TE.trace_event_id
				AND V.subclass_value = T.EventSubClass