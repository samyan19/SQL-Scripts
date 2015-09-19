/*Pick up the name of the file*/
declare @filepath varchar(100)='GWP_Bestinvest_Out_120_ExchangeTradeStatus_20130618_175100.out'
set @filepath = 'D:\Deb\ImportXML\'+@filepath

/*Create dynamic SQL*/
DECLARE @sql varchar(4000);

SET @sql=';WITH switches as (
SELECT CONVERT(XML, BulkColumn) AS BulkColumn
FROM OPENROWSET(BULK '''+ @filepath+ ''', SINGLE_BLOB) AS x
)
SELECT c.d.value(''ACCOUNT_NUMBER[1]'',''varchar(100)'') as AccountNumber
	, c.d.value(''BUY_SIDE_RETURN_DETAILS[1]/BUY_SIDE_EXCEPTION_MESSAGE[1]'',''varchar(1000)'') as BuySideExceptionMessage
	, c.d.value(''SELL_SIDE_RETURN_DETAILS[1]/SELL_SIDE_EXCEPTION_MESSAGE[1]'',''varchar(1000)'') as SellSideExceptionMessage
FROM switches
cross apply BulkColumn.nodes(''EXCHANGE_INSTRUCTION_RESPONSE/EXCHANGE_ORDER_RESPONSE'')c(d)'

/*Execute SQL*/
EXEC(@sql)