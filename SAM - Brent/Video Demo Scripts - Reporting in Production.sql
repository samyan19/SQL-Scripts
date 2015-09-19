/*
Reporting in Production: SQL Server
Demo Scripts for http://www.brentozar.com/sql/reporting-production-sql-server/

Jeremiah Peschka, Brent Ozar Unlimited
v1.0 - 20140128


Obligatory Legal Header:

This file is licensed under cc-wiki with attribution required:
License: http://creativecommons.org/licenses/by-sa/3.0/
Attribution: http://blog.stackoverflow.com/2009/06/attribution-required/


*** OUR DEMO ENVIRONMENT ***
Isn't AdventureWorks boring? Let's work on something a little more exciting.
StackExchange, the people behind StackOverflow.com and DBA.StackExchange.com,
make all of their databases available with a Creative Commons license.

There's a couple of ways you can access this data to play along:

http://data.stackexchange.com/ - Data Explorer, a web-based SQL Server
Management Studio type tool that lets you run queries against a recently
restored copy of Stack's databases. This is a lot of fun, but you can't add
indexes yourself.

Or, download a copy of StackExchange's databases and attach them locally to
your own SQL Server (or MySQL, or whatever). The data exports are available via
BitTorrent, and there are a few community tools that help you turn the XML data
exports into SQL Server databases. This is not for the faint of heart: it
involves command lines, BitTorrent, and hundreds of gigabytes of space.

You can learn more about both methods here:
http://BrentOzar.com/go/querystack

For today's demos, I'll be using a local copy of the StackOverflow database,
but you can play along with a lot of it over on Data.StackExchange.com if you
don't have your own local copy.


Agenda
======
* Describing our queries
* Technology Review
  * Summary Tables
  * Filtered Indexes
  * Indexed Views
  * ColumnStore


Optionally: clear out indexes from the last run
-----------------------------------------------
DROP INDEX dbo.Posts.IX_Posts_CreationDate_RecentPosts;
DROP INDEX summary.PostSummary.IX_PostSummary_Unanswered;
DROP INDEX summary.PostSummary.IX_PostSummary_Answered;



Getting the top 100 posts in the last week.

Don't actually run this, it takes two and a half minutes to execute.
The point is that this is a realistic query that people could want to run
on a regular basis. It's our job to make sure that those people can run
their queries.

This first query isn't fast enough to run against production. It takes over
a minute to execute and performs a total of 635,498 logical reads and
57,273 read aheads.

Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Workfile'. Scan count 38, logical reads 63800, physical reads 6527, read-ahead reads 57273, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Votes'. Scan count 3, logical reads 217980, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Posts'. Scan count 3, logical reads 353718, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.

*/
SET STATISTICS IO ON;

DECLARE @today AS DATETIME = '2013-09-06';


SELECT TOP 100 v.PostId,
       sum(case when VoteTypeId = 2 then 1 else 0 end) - 
       sum(case when VoteTypeId = 3 then 1 else 0 end) AS score
FROM   dbo.Votes v
       INNER JOIN dbo.Posts p ON v.PostId = p.Id
WHERE  v.VoteTypeId IN (2,3)
       AND p.CreationDate > (DATEADD(dd, -7, @today))
GROUP BY v.PostId 
ORDER BY sum(case when VoteTypeId = 2 then 1 else 0 end) - 
         sum(case when VoteTypeId = 3 then 1 else 0 end) DESC;






/* The top 100 posts of all time */
SET STATISTICS IO ON;

SELECT TOP 100 v.PostId,
       sum(case when VoteTypeId = 2 then 1 else 0 end) - 
       sum(case when VoteTypeId = 3 then 1 else 0 end) AS score
FROM   dbo.Votes v
       INNER JOIN dbo.Posts p ON v.PostId = p.Id
WHERE  v.VoteTypeId IN (2,3)
GROUP BY v.PostId 
ORDER BY sum(case when VoteTypeId = 2 then 1 else 0 end) - 
         sum(case when VoteTypeId = 3 then 1 else 0 end) desc ;






/* Questions without an accepted answer */
SELECT TOP 100 v.PostId
FROM   dbo.Votes v
       INNER JOIN dbo.Posts p ON v.PostId = p.Id
WHERE  p.PostTypeId = 1 AND
       p.AnswerCount = 0
GROUP BY p.Id
ORDER BY SUM(CASE WHEN v.VoteTypeId = 2 THEN 1 ELSE 0 END) -
         SUM(CASE WHEN v.VoteTypeId = 3 THEN 1 ELSE 0 END) DESC ;












/*
Let's tackle summary tables first.

Summary tables provide a number of benefits:

* Represent a snapshot of data at a specific time. There's no contention
  with live tables once data is loaded. 
* Denormalization at load time means we have little to no dependencies on
  existing tables in the system.
* Can be indexed separately from other tables. 
* Data is written the way it will be read.
* Additional summaries can be staged from an initial table.

The downsides are:

* Data rapidly becomes stale.
* Summaries may not be useful for many queries.
* Each summary table requires additional storage.

*/

CREATE SCHEMA summary;
GO

CREATE TABLE summary.PostSummary
(
    Id INT NOT NULL,
    AcceptedAnswerId INT NOT NULL,
    AnswerCount INT NOT NULL,
    CreationDate DATETIME NOT NULL,
    UpVotes INT NOT NULL,
    DownVotes INT NOT NULL,
    TotalVotes AS (UpVotes + DownVotes) PERSISTED,
    Score AS (UpVotes - DownVotes) PERSISTED,
    Controversial AS (CASE WHEN (DownVotes > (UpVotes * 0.5) THEN 1
                           ELSE 0 END) PERSISTED
);

CREATE UNIQUE CLUSTERED INDEX CX_summary$PostSummary 
    ON summary.PostSummary(Id);
GO






/*
Loading this table does a lot of work. But, by doing that work in advance
we can avoid a lot of work down the road when we're querying the table.

Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Workfile'. Scan count 26, logical reads 60224, physical reads 6102, read-ahead reads 54122, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Votes'. Scan count 3, logical reads 217980, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Posts'. Scan count 3, logical reads 348203, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.

*/
DBCC TRACEON(610);

DECLARE @today AS DATETIME = '2013-09-06';

INSERT INTO summary.PostSummary WITH(TABLOCK)
SELECT p.Id,
       p.AcceptedAnswerId,
       p.AnswerCount,
       p.CreationDate,
       sum(case when v.VoteTypeId = 2 then 1 else 0 end),
       sum(case when v.VoteTypeId = 3 then 1 else 0 end)
FROM   dbo.Posts p
       INNER JOIN dbo.Votes v ON p.Id = v.PostId
WHERE  v.VoteTypeId IN (2,3)
GROUP BY p.Id,
       p.AcceptedAnswerId,
       p.AnswerCount,
       p.CreationDate;

DBCC TRACEOFF(610);











/*
Now that we've written all of our data to a summary table, let's check out
what the queries look like.

Our three queries from earlier change dramatically:



Top 100 posts in the last 7 days

Table 'PostSummary'. Scan count 3, logical reads 61478, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
*/

DECLARE @today AS DATETIME = '2013-09-06';

SELECT TOP 100
       Id,
       Score
FROM   summary.PostSummary
WHERE  CreationDate >= DATEADD(dd, -7, @today)
       AND CreationDate < DATEADD(dd, 1, @today)
ORDER BY Score DESC;


       
/*
Top 100 posts of all time, sorted by score.
This takes ~2 seconds to execute.

Table 'PostSummary'. Scan count 1, logical reads 61084, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
*/
SELECT TOP 100 
       Id, 
       Score
FROM   summary.PostSummary
ORDER BY Score DESC;



/*
Questions without an accepted answer

Table 'PostSummary'. Scan count 1, logical reads 3, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.

*/
SELECT TOP 100
       Id
FROM   summary.PostSummary
WHERE  AnswerCount = 0
ORDER BY Score DESC;










/*
Summary of activity by day.

This table only requires 61190 logical reads to build since it is being build
from the previous PostSummary. We still scan PostSummary a total of three times, but that's a lot less I/O than if we had
performed all of our reads against the main table.
*/
CREATE TABLE summary.DailyActivity
(
    [Date] DATE,
    PostCount INT,
    VoteCount INT,
    UnansweredQuestionCount INT
);
GO

DBCC TRACEON(610);

INSERT INTO summary.DailyActivity WITH(TABLOCK)
SELECT CAST(CreationDate AS DATE) AS [Date],
       COUNT(*) AS PostCount,
       SUM(UpVotes + DownVotes) AS VoteCount ,
       SUM(CASE WHEN AnswerCount = 0 THEN 1 ELSE 0 END) AS UnasweredQuestionCount
FROM   summary.PostSummary
GROUP BY CAST(CreationDate AS DATE);

DBCC TRACEOFF(610);






SELECT TOP 100 * 
FROM   summary.DailyActivity 
ORDER BY [Date] ASC;

















/*
Filtered Indexes

Filtered indexes are nothing more than indexes with a WHERE clause. The upside
of a filtered index is that you're pushing the search predicate from query
execution time to data write time. Even in write-heavy OLTP systems, writes
typically occur at a rate of 1 write per 20 reads.

A filtered index will be considered by the query optimizer whenever a new plan
is compiled, just like any other index. If the query's predicate matches the
filtering predicate on the index, SQL Server may opt to use the filtered
index. One advantage that filtered indexes have is that they may require
significantly less I/O than a regular index.
*/

CREATE INDEX IX_PostSummary_Unanswered
       ON summary.PostSummary (CreationDate)
       INCLUDE (Id) WHERE (AnswerCount = 0);

CREATE INDEX IX_PostSummary_Answered
       ON summary.PostSummary (CreationDate)
       INCLUDE (Id) WHERE (AnswerCount > 0);










/*
This query performs a "scan" on the IX_PostSummary_Unanswered filtered index.

Checking in on the I/O stats, this only performs 3 logical reads on the
filtered index, as opposed to 61234 logical reads against the underlying
clustered index if the filtered index wasn't present.

This query does a relatively small amount of reads - even with the join,
SQL Server is able to use 

Table 'Posts'. Scan count 0, logical reads 1751, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'PostSummary'. Scan count 1, logical reads 4, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.

*/
SET STATISTICS IO ON;

SELECT TOP 100
       ps.Id ,
       p.Title
FROM   summary.PostSummary ps -- WITH(INDEX(1)) /* force the clustered index */
       INNER JOIN dbo.Posts p ON ps.Id = p.Id
WHERE  ps.AnswerCount = 0
       AND p.Title IS NOT NULL
ORDER BY ps.CreationDate DESC;

















/*
We can even create a sliding filtered index for our "last 7 days" query.

The difficulty is that the filter condition needs to be a literal condition.
It isn't possible to create a filtering condition based on the result of an
expression that could change as time passes.

The solution is to create new indexes on a regular basis and drop old indexes.
This requires some scripting and automation sophistication, but it does mean
that you can keep your index footprint to a minimum.

The creates only take 14 seconds on our hardware.
*/

CREATE INDEX IX_Posts_CreationDate_RecentPosts
       ON dbo.Posts (Id, CreationDate)
       INCLUDE (Title)
       WHERE (CreationDate >= CAST('2013-08-28' AS DATE));

-- TODO: Add drop for all these filtered indexes


/*
Pop Quiz:

Which of these queries will use the filtered index?
*/
DECLARE @today AS DATETIME = '2013-09-06';

SELECT p.Id,
       p.Title
FROM   dbo.Posts AS p
WHERE  p.CreationDate > DATEADD(dd, -7, @today);


SELECT p.Id,
       p.Title
FROM   dbo.Posts AS p 
WHERE  p.CreationDate >= '2013-08-30' ;


SELECT p.Id,
       p.Title
FROM   dbo.Posts AS p
       JOIN summary.PostSummary AS ps ON p.Id = ps.Id
WHERE  ps.CreationDate >= '2013-08-30'
       AND ps.AnswerCount = 0;


SELECT p.Id,
       p.Title
FROM   dbo.Posts AS p WITH(INDEX(IX_Posts_CreationDate_RecentPosts))
       JOIN summary.PostSummary AS ps ON p.Id = ps.Id
WHERE  ps.CreationDate >= '2013-08-30'
       AND ps.AnswerCount = 0;       


SELECT p.Id,
       p.Title
FROM   dbo.Posts AS p
       JOIN summary.PostSummary AS ps ON p.Id = ps.Id
WHERE  ps.CreationDate >= '2013-08-30'
       AND p.CreationDate >= '2013-08-30'
       AND ps.AnswerCount = 0;
















/*
Only queries 2 and 5 will use the filtered index.

In the first query, there's no constant value to compare against, and SQL
Server won't peek inside the variable to see if it can use the filtered index.

In the third query, you might think that SQL Server would be able to use
statistics or a query rewrite rule or something to figure out that it can use
the filtered index. Unfortunately, you'd be wrong.

In the fourth query, we supplied a hint that seems like it would work, to a
human. Unfortunately the optimizer doesn't see it that way. Even though the
index can be used, optimizer rules won't allow this query to execute because
we haven't specified a valid predicate on the Posts table.

If you want to use a filtered index, you need to make sure that you explicitly
reference the filtered column using a literal value.



Filtered indexes work well in a few different scenarios:

1. Reports have common criteria (last 90 days of data, unanswered posts).
2. Searches are performed using literal values. Forced parameterization and
   auto-parameterization can ruin this. As can parameterizing values passed
   in through dynamic SQL or an ORM.

However, filterd indexes may not be useful in all scenarios.

1. Specific SET options are required that might not be supported by legacy
   applications.
2. Some level of query re-writing is usually required.
3. Hints may not help - see above.

Filtered indexes are a powerful tool, but they require some tricks.
*/























/* Let's talk about indexed views! */
CREATE VIEW dbo.vwPostVotes WITH SCHEMABINDING AS
SELECT v.PostId, 
       p.CreationDate,
       up = sum(case when VoteTypeId = 2 then 1 else 0 end), 
       down = sum(case when VoteTypeId = 3 then 1 else 0 end),
       totalvotes = COUNT_BIG(*)
FROM   dbo.Votes v
       INNER JOIN dbo.Posts p ON v.PostId = p.Id
WHERE  v.VoteTypeId in (2,3)
       AND p.CommunityOwnedDate IS NULL
       AND p.ClosedDate IS NULL
GROUP BY v.PostId, p.CreationDate;
GO

CREATE UNIQUE CLUSTERED INDEX CL_PostId ON dbo.vwPostVotes (PostId);
GO






/* 
Our queries could use the indexes, if we'd written them in a way that
matched with the indexed view definition. Sometimes, though, life doesn't
work that way. 

Let's look at what we can do:

Table 'vwPostVotes'. Scan count 3, logical reads 44238, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
*/
DECLARE @today AS DATETIME = '2013-09-06';

SELECT TOP 100
       PostId,
       up - down
FROM   dbo.vwPostVotes
WHERE  CreationDate >= DATEADD(dd, -7, @today)
       AND CreationDate < DATEADD(dd, 1, @today)
ORDER BY (up - down) DESC;















/* 
Maybe we can create a filtered index on the indexed view... 

No dice, I'm afraid. This will fail with a message that you should 
create an indexed view with the appropriate filter condition instead.

Indexed views have a lot of rules associated with them:

* They require specific SET options.
* You can't use outer joins
* They require a unique primary key
* COUNT_BIG() must be used.

When you can use indexed views, they're a great way to reduce I/O and 
still have live data in your summary tables. They carry a significant
cost: 

* Writes to tables suddenly have an additional I/O overhead
* Queries may need complex re-writes
* Queries may need hinting using WITH(NOEXPAND)

*/
CREATE INDEX IX_vwPostVotes_Filtered
       ON dbo.vwPostVotes(CreationDate)
	   INCLUDE (PostId, up, down)
       WHERE (CreationDate >= CAST('2013-08-28' AS DATE)); 




















/*
I promised you some ColumnStore magic. Let's do it!
*/
CREATE TABLE dbo.cc_Votes(
	Id int NOT NULL,
	PostId int NOT NULL,
	UserId int NULL,
	BountyAmount int NULL,
	VoteTypeId int NOT NULL,
	CreationDate datetime NOT NULL
) ;
GO

CREATE CLUSTERED COLUMNSTORE INDEX [PK_Votes] ON [dbo].[cc_Votes] ;
GO


DBCC TRACEON(610)

INSERT INTO dbo.cc_Votes WITH (TABLOCK)
SELECT Id
       , PostId
       , UserId
       , BountyAmount
       , VoteTypeId
       , CreationDate
FROM   dbo.Votes ;

DBCC TRACEOFF(610);







/*
Let's change the top popular posts to use the clustered column store tables.
Both of these queries produce similar looking plans.

There's no benefit to ordering the data and there's no clear benefit if we're
joining to other tables. ColumnStore is best used when you can do all of the
aggregation in one place - the CS table.

This query takes a long time to run. 
*/
SET STATISTICS IO ON;

SELECT TOP 100 v.PostId
FROM   dbo.cc_Votes v
       INNER JOIN dbo.Posts p ON v.PostId = p.Id
WHERE  p.PostTypeId = 1 AND
       p.AnswerCount = 0
GROUP BY v.PostId
ORDER BY SUM(CASE WHEN v.VoteTypeId = 2 THEN 1 ELSE 0 END) -
         SUM(CASE WHEN v.VoteTypeId = 3 THEN 1 ELSE 0 END) DESC ;














/*
Let's try a different sort of query that we haven't looked at yet - analytics.

I'm not going to run this because these queries out and out stink. They take
over three minutes to run but only require a few reads:

Table 'cc_Votes'. Scan count 2, logical reads 66823, physical reads 0, read-ahead reads 181848, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Workfile'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.

The granularity is too fine. This is an effective use of ColumnStore,
it's just not something that we can use live.
*/
SELECT v.PostId,
       SUM(CASE WHEN v.VoteTypeId = 2 THEN 1 ELSE 0 END) AS UpVotes,
       SUM(CASE WHEN v.VoteTypeId = 3 THEN 1 ELSE 0 END) AS DownVotes
FROM   dbo.cc_Votes v
GROUP BY v.PostId
ORDER BY SUM(CASE WHEN v.VoteTypeId = 2 THEN 1 ELSE 0 END) -
         SUM(CASE WHEN v.VoteTypeId = 3 THEN 1 ELSE 0 END) DESC 











/*
Clearly columnstore isn't fast enough to use for live querying...

Or is it? This query only takes ~20ms. 

Table 'cc_Votes'. Scan count 2, logical reads 38, physical reads 2, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Workfile'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
*/
SELECT CAST(CreationDate AS DATE) AS [Vote Date] , 
       SUM(CASE WHEN v.VoteTypeId = 2 THEN 1 ELSE 0 END) As UpVotes,
       SUM(CASE WHEN v.VoteTypeId = 3 THEN 1 ELSE 0 END) AS DownVotes
FROM   dbo.cc_Votes v
--WHERE  CreationDate >= '2013-08-30'
GROUP BY CAST(CreationDate AS DATE) ;











/*
We could even run this query live across the entire data set in less than one
second. ColumnStore makes it possible to get high speed aggregation.

There are a few downsides of this approach, though.

* SQL Server 2012 ColumnStore is read only.
  You can get around this by using views and a delta table.
* There can be no foreign key to the clustered ColumnStore index.
* Best used with a minimum of 10,000,000 rows and ~10GB of data.

Starting in SQL Server 2014 we get clustered ColumnStore indexes:

* Writeable ColumnStore indexes. Incoming data is stored in a b-tree deltastore.
  * This can result in poor performance over time.
  * Ideally, you'll be using partitioning with writeable columnstore so you can
    rebuild partitions and manage data loads.
  * These new rows have to be moved into place with triggered by internal
    metrics. You better be writing 1,000,000 rows at a time on a regular basis.
* Clustered ColumnStore indexes cannot be combined with any other index.

There are nuances to both approaches and ColumnStore is not for the faint of
heart. It certainly doesn't solve our problem of being able to effectively
"report in production", though.

ColumnStore, and even clustered ColumnStore, are more a way to alleviate the
need for moving to SSAS or make it easier to deal with ad hoc queries and
supporting indexes for ad hoc queries.

TL;DR - Clustered ColumnStore is not a cure all, you need good design.

To learn more about how SQL Server ColumnStore indexes can help you, check out
the SQL Server ColumnStore Index FAQ:

http://social.technet.microsoft.com/wiki/contents/articles/3540.sql-server-columnstore-index-faq-en-us.aspx

*/

