SELECT 
  b.database_name 'Database Name', 
  CONVERT (BIGINT, b.backup_size / 1048576 ) 'UnCompressed Backup Size (MB)', 
  CONVERT (BIGINT, b.compressed_backup_size / 1048576 ) 'Compressed Backup Size (MB)', 
  CONVERT (NUMERIC (20,2), (CONVERT (FLOAT, b.backup_size) / 
  CONVERT (FLOAT, b.compressed_backup_size))) 'Compression Ratio', 
  DATEDIFF (SECOND, b.backup_start_date, b.backup_finish_date) 'Backup Elapsed Time (sec)' 
FROM 
  msdb.dbo.backupset b 
WHERE 
  DATEDIFF (SECOND, b.backup_start_date, b.backup_finish_date) > 0 
  AND b.backup_size > 0 
ORDER BY 
  b.backup_finish_date DESC