-- Individual File Size query
/*======================= OLD ==================================================================


SELECT name AS 'File Name' , physical_name AS 'Physical Name', size/128 AS 'Total Size in MB',

size/128.0 - CAST(FILEPROPERTY(name, 'SpaceUsed') AS int)/128.0 AS 'Available Space In MB'--,*

FROM sys.database_files;


===============================================================================================*/


select DB_NAME() as DbName,
name as FileName,
size as NumberOfPages,
size/128.0 as CurrentSizeMB,
size/128.0 - CAST(FILEPROPERTY(name, 'SpaceUsed') AS INT)/128.0 AS FreeSpaceMB,
size*8 - CAST(FILEPROPERTY(name, 'SpaceUsed') AS INT)*8 AS FreeSpaceKB,
size- CAST(FILEPROPERTY(name, 'SpaceUsed') AS INT) AS NumberOfFreePages
FROM sys.database_files


--Trace flag causes both files to grow together
DBCC TRACEON(1117) 