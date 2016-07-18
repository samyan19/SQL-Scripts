 /* */
 
 select name, is_published, is_subscribed, is_merge_published, is_distributor
  from sys.databases
  where is_published = 1 or is_subscribed = 1 or
  is_merge_published = 1 or is_distributor = 1
  
  
  /* alternatively 
  http://www.mssqlinsider.com/2013/09/check-databases-part-replication/
  */
  
  SELECT 
	name as [Database name],
	CASE is_published 
		WHEN 0 THEN 'No' 
		ELSE 'Yes' 
		END AS [Is Published],
	CASE is_merge_published 
		WHEN 0 THEN 'No' 
		ELSE 'Yes' 
		END AS [Is Merge Published],
	CASE is_distributor 
		WHEN 0 THEN 'No' 
		ELSE 'Yes' 
		END AS [Is Distributor],
	CASE is_subscribed 
		WHEN 0 THEN 'No' 
		ELSE 'Yes' 
		END AS [Is Subscribed]
FROM sys.databases
WHERE database_id > 4
