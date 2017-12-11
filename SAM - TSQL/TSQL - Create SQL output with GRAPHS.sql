/*
http://sqlservercode.blogspot.co.uk/2017/11/use-t-sql-to-create-caveman-graphs.html
*/
SELECT 
       database_name = DB_NAME(database_id) 
     , total_size_GB = CAST(SUM(size) * 8. / 1024/1024 AS DECIMAL(30,2))
  , percent_size = (CONVERT(decimal(30,4),(SUM(size) /
     (SELECT SUM(CONVERT(decimal(30,4),size))  
     FROM sys.master_files WITH(NOWAIT)))) *100.00)
  , graph = replicate('|',((convert(decimal(30,2),(SUM(size) / 
    (SELECT SUM(CONVERT(decimal(30,2),size))  
     FROM sys.master_files WITH(NOWAIT)))) *100)))
FROM sys.master_files WITH(NOWAIT)
GROUP BY database_id
ORDER BY 3 DESC
