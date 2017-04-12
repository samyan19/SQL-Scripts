Select 'ALTER DATABASE ['+name+'] SET RECOVERY SIMPLE WITH ROLLBACK IMMEDIATE;'
from sys.databases
where recovery_model_desc = 'FULL'
and database_id>4


/* Then take output and run in SSMS*/
