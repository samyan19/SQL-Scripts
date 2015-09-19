--Replacement for master.dbo.sysprocesses

SELECT r.session_id -- new column for SPID

,r.database_id

,r.user_id

,r.status

,st.text

,r.wait_type

,r.wait_time

,r.last_wait_type

,r.command

,es.host_name

,es.program_name

,es.nt_domain

,es.nt_user_name

,es.login_name

,mg.dop --Degree of parallelism

,mg.request_time  --Date and time when this query requested the memory grant.

,mg.grant_time --NULL means memory has not been granted

,mg.requested_memory_kb --Total requested amount of memory in kilobytes

,mg.granted_memory_kb --Total amount of memory actually granted in kilobytes. NULL if not granted

,mg.required_memory_kb --Minimum memory required to run this query in kilobytes.

,mg.query_cost --Estimated query cost.

,mg.timeout_sec --Time-out in seconds before this query gives up the memory grant request.

,mg.resource_semaphore_id --Nonunique ID of the resource semaphore on which this query is waiting.

,mg.wait_time_ms --Wait time in milliseconds. NULL if the memory is already granted.

,CASE mg.is_next_candidate --Is this process the next candidate for a memory grant

      WHEN 1 THEN 'Yes'

      WHEN 0 THEN 'No'

      ELSE 'Memory has been granted'

      END AS 'Next Candidate for Memory Grant'

,rs.target_memory_kb --Grant usage target in kilobytes.

,rs.max_target_memory_kb --Maximum potential target in kilobytes. NULL for the small-query resource semaphore.

,rs.total_memory_kb --Memory held by the resource semaphore in kilobytes.

,rs.available_memory_kb --Memory available for a new grant in kilobytes.

,rs.granted_memory_kb  --Total granted memory in kilobytes.

,rs.used_memory_kb --Physically used part of granted memory in kilobytes.

,rs.grantee_count --Number of active queries that have their grants satisfied.

,rs.waiter_count --Number of queries waiting for grants to be satisfied.

,rs.timeout_error_count --Total number of time-out errors since server startup. NULL for the small-query resource semaphore.

,rs.forced_grant_count --Total number of forced minimum-memory grants since server startup. NULL for the small-query resource semaphore.

FROM sys.dm_exec_requests r

INNER JOIN sys.dm_exec_sessions es

ON r.session_id = es.session_id

INNER JOIN sys.dm_exec_query_memory_grants mg

ON r.session_id = mg.session_id

INNER JOIN sys.dm_exec_query_resource_semaphores rs

ON mg.resource_semaphore_id = rs.resource_semaphore_id

CROSS APPLY sys.dm_exec_sql_text(r.sql_handle)st

 

--Is anything timing out

SELECT * FROM sys.dm_exec_query_optimizer_info

WHERE counter = 'timeout'