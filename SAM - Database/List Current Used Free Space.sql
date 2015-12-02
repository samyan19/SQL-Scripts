select DB_NAME() as DbName,
name as FileName,
cast(size/128.0 as numeric(10,2)) as CurrentSizeMB,
cast((CAST(FILEPROPERTY(name, 'SpaceUsed') AS INT)/128.0) as numeric(10,2)) AS UsedSpaceMB,
cast((size/128.0 - CAST(FILEPROPERTY(name, 'SpaceUsed') AS INT)/128.0) as numeric(10,2)) AS FreeSpaceMB
FROM sys.database_files
