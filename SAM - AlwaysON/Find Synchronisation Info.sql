SELECT ar.replica_server_name as ServerName,
 drs.synchronization_state_desc as SyncState,
 drs.last_hardened_lsn, drs.last_redone_lsn
FROM sys.dm_hadr_database_replica_states drs
LEFT JOIN sys.availability_replicas ar 
 ON drs.replica_id = ar.replica_id
ORDER BY ServerName