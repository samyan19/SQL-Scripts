SELECT  db_name(l.resource_database_id) as databasename,c.session_id, t.text,
            QUOTENAME(OBJECT_SCHEMA_NAME(t.objectid, t.dbid)) + '.'
            + QUOTENAME(OBJECT_NAME(t.objectid, t.dbid)) proc_name,
            c.connect_time,
            s.last_request_start_time,
            s.last_request_end_time,
            s.status,
            s.login_name,
            l.resource_database_id,
            l.request_mode,
            c.client_net_address,
            c.net_packet_size
    FROM    sys.dm_exec_connections c
    join	sys.dm_tran_locks l on c.session_id=l.request_session_id
    JOIN    sys.dm_exec_sessions s
            ON c.session_id = s.session_id
    CROSS APPLY sys.dm_exec_sql_text(c.most_recent_sql_handle) t