;WITH switches as (
SELECT CONVERT(XML, BulkColumn) AS BulkColumn
FROM OPENROWSET(BULK 'D:\Deb\ImportXML\GWP_Bestinvest_Out_120_ExchangeTradeStatus_20130618_175100.out', SINGLE_BLOB) AS x
)
SELECT c.d.value('ACCOUNT_NUMBER[1]','varchar(100)') as AccountNumber
	, c.d.value('BUY_SIDE_RETURN_DETAILS[1]/BUY_SIDE_EXCEPTION_MESSAGE[1]','varchar(1000)') as BuySideExceptionMessage
	, c.d.value('SELL_SIDE_RETURN_DETAILS[1]/SELL_SIDE_EXCEPTION_MESSAGE[1]','varchar(1000)') as SellSideExceptionMessage
FROM switches
cross apply BulkColumn.nodes('EXCHANGE_INSTRUCTION_RESPONSE/EXCHANGE_ORDER_RESPONSE')c(d)
