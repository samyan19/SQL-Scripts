-- Is NUMA enabled
SELECT 
  CASE COUNT(DISTINCT parent_node_id)
     WHEN 1 
         THEN 'NUMA disabled' 
         ELSE 'NUMA enabled'
  END
FROM sys.dm_os_schedulers
WHERE parent_node_id <> 32;