--check databases with TDE enabled
select [name],  is_encrypted
from master.sys.databases
go

--monitor encryption state
SELECT db_name(database_id), encryption_state,   percent_complete, key_algorithm, key_length
FROM sys.dm_database_encryption_keys
