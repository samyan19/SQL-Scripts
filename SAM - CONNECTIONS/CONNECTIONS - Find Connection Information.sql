select 
c.session_id,
CASE transaction_isolation_level 
                        WHEN 0 THEN 'Unspecified' 
                        WHEN 1 THEN 'ReadUncomitted' 
                        WHEN 2 THEN 'Readcomitted' 
                        WHEN 3 THEN 'Repeatable' 
                        WHEN 4 THEN 'Serializable' 
                        WHEN 5 THEN 'Snapshot' 
                  END as isolationlevel,
login_name, 
status,             
connect_time,
net_transport,
protocol_type,
c.endpoint_id,
encrypt_option,auth_scheme,
node_affinity,
num_reads,
num_writes,
last_read,
last_write,
net_packet_size,
client_net_address,
local_net_address,
local_tcp_port,
dbid,
text
FROM sys.dm_exec_connections c
JOIN sys.dm_exec_sessions AS s
    ON c.session_id = s.session_id
CROSS APPLY sys.dm_exec_sql_text(most_recent_sql_handle)


