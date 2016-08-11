/* https://www.brentozar.com/responder/log-sp_whoisactive-to-a-table/ */ 

DECLARE @destination_table VARCHAR(4000) ;
SET @destination_table = 'WhoIsActive' ;

DECLARE @schema VARCHAR(4000) ;
EXEC sp_WhoIsActive
@get_transaction_info = 1,
@get_plans = 1,
@return_schema = 1,
@schema = @schema OUTPUT ;

SET @schema = REPLACE(@schema, '<table_name>', @destination_table) ;

PRINT @schema
EXEC(@schema) ;
