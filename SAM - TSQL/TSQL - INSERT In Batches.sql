/*

Method 1 - @@ROWCOUNT

*/

DECLARE @BatchSize INT = 10000

WHILE 1 = 1
BEGIN

    INSERT INTO [dbo].[Destination] --WITH (TABLOCK)  -- Uncomment for 2008
    (
        FirstName
        ,LastName
        ,EmailAddress
        ,PhoneNumber
    )
    SELECT TOP(@BatchSize) 
        s.FirstName
        ,s.LastName
        ,s.EmailAddress
        ,s.PhoneNumber
    FROM [dbo].[SOURCE] s
    WHERE NOT EXISTS ( 
        SELECT 1
        FROM dbo.Destination
        WHERE PersonID = s.PersonID
    )

    IF @@ROWCOUNT < @BatchSize BREAK
    
END

/*

Method 2 - defined 

*/

	DECLARE @min int=0
	DECLARE @batchsize int=500000
	DECLARE @max int=(select max(ID) from #ROWS)
	
	WHILE @min<@max
	BEGIN
		INSERT INTO dbo.DataGatheringRuntime (EntityId, DataGatheringTypeId, Name, Value, Version, UpdatedUsername, LastUpdated, DataGatheringCommentID, RootId, DataGatheringId)
		SELECT
		t.EntityId, t.DataGatheringTypeId, t.Name, t.Value, t.Version, 
		t.UpdatedUsername, t.LastUpdated, t.DataGatheringCommentID, t.RootId, t.DataGatheringId
		FROM DataGathering t
		WHERE DataGatheringId IN (select DataGatheringId from #rows where ID>@min and ID<=@min+@batchsize)
		
		SET @min=@min+@batchsize;		
	END




/*

Method 3 - multiple threads

*/

INSERT INTO [dbo].[Destination]
    (
        FirstName
        ,LastName
        ,EmailAddress
        ,PhoneNumber
    )
    SELECT TOP(@BatchSize) 
        s.FirstName
        ,s.LastName
        ,s.EmailAddress
        ,s.PhoneNumber
    FROM [dbo].[SOURCE] s
    WHERE PersonID BETWEEN 1 AND 5000
GO
INSERT INTO [dbo].[Destination]
    (
        FirstName
        ,LastName
        ,EmailAddress
        ,PhoneNumber
    )
    SELECT TOP(@BatchSize) 
        s.FirstName
        ,s.LastName
        ,s.EmailAddress
        ,s.PhoneNumber
    FROM [dbo].[SOURCE] s
    WHERE PersonID BETWEEN 5001 AND 10000

