/* 
http://stevestedman.com/2013/06/query-to-simulate-cpu-load/
*/

/*
First create a table with poor design. Using UNIQUEIDENTIFIERS for a primary key and a foreign key (parent_id) is probably ugly enough.
*/

CREATE TABLE SplitThrash
(
 id UNIQUEIDENTIFIER default newid(),
 parent_id UNIQUEIDENTIFIER default newid(),
 name VARCHAR(50) default cast(newid() as varchar(50))
);

/*
Next we fill the table up with lots and lots of rows, specifically 1,000,000 rows, remember here the goal is to simulate CPU load. 
If this isn’t enough I often times run this script several times. Keep in mind the GO statement followed by a number says to 
execute the batch that many times.
*/

SET NOCOUNT ON;
INSERT INTO SplitThrash DEFAULT VALUES;
GO  1000000

/*
Next, this part makes me just feel nasty. Create a CLUSTERED index on the table that we just filled up, 
and cluster on BOTH columns that were UNIQUEIDENTIFIERS.
*/

CREATE CLUSTERED INDEX [ClusteredSplitThrash] ON [dbo].[SplitThrash]
(
 [id] ASC,
 [parent_id] ASC
);

/*
At this point is is a bit ugly, but it still doesn’t use much memory. You are probably wondering why I called the table split thrash. 
I gave it this name so that updating the UNIQUEIDENTIFER would cause as many page splits or new page allocations as possible. 
So we update the parent_id which is part of the clustered index
*/

UPDATE SplitThrash
SET parent_id = newid(), id = newid();
GO 100
This update statement causes chaos in the page structure for the table as updating the unique identifiers causes quite a bit of processor work.

/*
On my wimpy VM for this development environment I need to repeat this entire process creating 4 or 5 tables, and doing the update in 4 
or 5 SSMS windows in order to use up all of the CPU on the database.
*/
