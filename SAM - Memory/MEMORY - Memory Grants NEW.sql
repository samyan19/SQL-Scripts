/*** sp_whoisactive ***/
EXEC sp_whoisactive @get_plans=1
 

/**** Is anything timing out ***/
SELECT * FROM sys.dm_exec_query_optimizer_info
WHERE counter = 'timeout'

/*** Memory Grants ***/
SELECT 
mg.session_id
,mg.wait_time_ms --Wait time in milliseconds. NULL if the memory is already granted.
,CASE mg.is_next_candidate --Is this process the next candidate for a memory grant
      WHEN 1 THEN 'Yes'
      WHEN 0 THEN 'No'
      ELSE 'Memory has been granted'
      END AS 'Next Candidate for Memory Grant',
mg.dop --Degree of parallelism
,mg.request_time  --Date and time when this query requested the memory grant.
,mg.grant_time --NULL means memory has not been granted
,mg.requested_memory_kb --Total requested amount of memory in kilobytes
,mg.granted_memory_kb --Total amount of memory actually granted in kilobytes. NULL if not granted
,mg.required_memory_kb --Minimum memory required to run this query in kilobytes.
,mg.query_cost --Estimated query cost.
,mg.timeout_sec --Time-out in seconds before this query gives up the memory grant request.
,mg.resource_semaphore_id --Nonunique ID of the resource semaphore on which this query is waiting.
FROM sys.dm_exec_query_memory_grants mg