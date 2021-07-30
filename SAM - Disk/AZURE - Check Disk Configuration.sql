/*
https://medium.com/azure-sqldb-managed-instance/file-layout-in-general-purpose-azure-sql-managed-instance-cf21fff9c76c

*/

CREATE SCHEMA mi;
GO
CREATE OR ALTER VIEW mi.master_files
AS
WITH mi_master_files AS
( SELECT *, size_gb = CAST(size * 8. / 1024 / 1024 AS decimal(12,4))
FROM sys.master_files where physical_name LIKE 'https:%')
SELECT *, azure_disk_size_gb = IIF(
database_id <> 2,
CASE WHEN size_gb <= 128 THEN 128
WHEN size_gb > 128 AND size_gb <= 256 THEN 256
WHEN size_gb > 256 AND size_gb <= 512 THEN 512
WHEN size_gb > 512 AND size_gb <= 1024 THEN 1024
WHEN size_gb > 1024 AND size_gb <= 2048 THEN 2048
WHEN size_gb > 2048 AND size_gb <= 4096 THEN 4096
ELSE 8192
END, NULL)
FROM mi_master_files;
GO

--Now we can see the size allocated for the underlying Azure Premium Disks for every database file:
SELECT db = db_name(database_id), name, size_gb, azure_disk_size_gb
FROM mi.master_files;

--Sum of the azure disk sizes should not exceed 35 TB — otherwise you will reach the azure storage limit errors. You can check total allocated azure storage space using the following query:
SELECT storage_size_tb = SUM(azure_disk_size_gb) /1024.
FROM mi.master_files

--Using this information, you can find out how many additional files you can add on a managed instance (assuming that new file will be smaller than 128GB):
SELECT remaining_number_of_128gb_files = 
(35 - ROUND(SUM(azure_disk_size_gb) /1024,0)) * 8
FROM mi.master_files

--This is important check because if this count became zero, you will not be able to add more files of database on the instance.
