 select  replica_server_name as servername,db_name(database_id) as database_name,
is_local,cs.is_failover_ready,
synchronization_health_desc,database_state_desc,last_sent_time,last_received_time,
last_hardened_time,last_redone_time,log_send_queue_size,log_send_rate,redo_queue_size,
redo_rate,end_of_log_lsn,last_commit_time,last_commit_lsn,low_water_mark_for_ghosts ,
is_suspended,suspend_reason_desc,rep_state.recovery_lsn,
rep_state.truncation_lsn,last_sent_lsn,last_received_lsn,last_hardened_lsn,last_redone_lsn
from 
sys.dm_hadr_database_replica_states rep_state,sys.availability_replicas ar,
sys.dm_hadr_database_replica_cluster_states as cs
where rep_state.replica_id=ar.replica_id
and rep_state.group_id = ar.group_id
and cs.replica_id = ar.replica_id
and cs.group_database_id = rep_state.group_database_id
