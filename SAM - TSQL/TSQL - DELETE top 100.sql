--delete TOP (100)
--from [Logging].[ErrorLog] 
--where Timestamp>GETDATE()-30




DECLARE @BatchSize INT
SET @BatchSize = 100000

WHILE @BatchSize <> 0
BEGIN
    DELETE TOP (@BatchSize)
    FROM [dbo].[UnknownTable]
    SET @BatchSize = @@rowcount
END  





--declare @batchstart int=1;
--declare @batchend int=50000;

--while @batchstart<=744248
--begin
--	insert into Logging.ErrorLog
--	select *
--	from Logging.ErrorLogOLD
--	where HandlingInstanceId in 
--	(
--		select HandlingInstanceId
--		from Logging.LoggingErrorsLastThirtyDays
--		where id>=@batchstart and id<@batchend
--	);
	
	
--	set @batchstart=@batchstart+50000;
--	set @batchend=@batchend+50000;
--end