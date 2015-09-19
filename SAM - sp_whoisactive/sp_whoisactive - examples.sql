/* Standard check */

exec sp_whoisactive 
@get_task_info=2, 
@get_plans=1,
--@get_outer_command = 1,
--@get_locks=1,
@get_transaction_info=1


/* Save to log table */

EXEC sp_WhoIsActive
@get_transaction_info = 2,
@get_plans = 1,
@destination_table='WhoIsActive'
GO
DELETE FROM 
WhoIsActive
WHERE collection_time<GETDATE()-7;
