DECLARE @id int, @indid int

SET @id = OBJECT_ID('MESSAGING.SEIOvernight')
SELECT @indid = index_id 
FROM sys.indexes
WHERE object_id = @id 
   AND name = 'pkSEIOvernight_SEIOvernight'
   
DBCC SHOWCONTIG (@id, @indid);
GO
--2nd Example
DBCC showcontig ('MESSAGING.SEIOvernight',1) WITH tableresults