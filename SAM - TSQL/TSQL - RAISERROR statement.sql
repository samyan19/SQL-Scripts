RAISERROR ('DELAY 1 HAS ENDED', 10,1) WITH NOWAIT ;



/* Example where to raiserror in one statement */
DECLARE @count int=0
DECLARE @last_time datetime=getdate()-30
DECLARE @max_count int=(SELECT COUNT(1) FROM [dbDealing].[Logging].[ErrorLog] WHERE TIMESTAMP < @last_time)
DECLARE @msg nvarchar(100)='Date to be deleted from is '+ CAST(@last_time as nvarchar(100)) + ' Record Count is: '+CAST(@max_count as nvarchar(100))

RAISERROR (@msg, 10, 1) WITH NOWAIT ;   