-- Get System Manufacturer and model number from
-- SQL Server Error log. This query might take a few seconds
-- if you have not recycled your error log recently
EXEC xp_readerrorlog 0,1,"Manufacturer"; 

-- Get processor description from Windows Registry
-- (Uncomment query to make it work)
--EXEC xp_instance_regread
--'HKEY_LOCAL_MACHINE',
--'HARDWARE\DESCRIPTION\System\CentralProcessor',
--'ProcessorNameString';