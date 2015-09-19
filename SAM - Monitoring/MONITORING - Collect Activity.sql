EXEC sp_WhoIsActive
@get_transaction_info = 2,
@get_plans = 1,
@destination_table='WhoIsActive'
GO
DELETE FROM 
WhoIsActive
WHERE collection_time<GETDATE()-7;