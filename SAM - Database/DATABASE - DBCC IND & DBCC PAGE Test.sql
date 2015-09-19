Create database Customers2
GO

use TestData
GO


CREATE TABLE Customers
(
   FirstName CHAR(50) NOT NULL,
   LastName CHAR(50) NOT NULL,
   Address CHAR(100) NOT NULL,
   ZipCode CHAR(5) NOT NULL,
   Rating INT NOT NULL,
   ModifiedDate DATETIME NOT NULL,
)
GO

insert into Customers
values
(
'Philip',
'Aschenbrenner',
'Pichlgasse 16/6',
'1220',
1,
CAST('04.02.2010 09:08' as datetime)
)
GO 2


/*
Columns for DBCC IND
--------------------
•PageFID - the file ID of the page
•PagePID - the page number in the file
•IAMFID - the file ID of the IAM page that maps this page (this will be NULL for IAM pages themselves as they're not self-referential)
•IAMPID - the page number in the file of the IAM page that maps this page
•ObjectID - the ID of the object this page is part of
•IndexID - the ID of the index this page is part of
•PartitionNumber - the partition number (as defined by the partitioning scheme for the index) of the partition this page is part of
•PartitionID - the internal ID of the partition this page is part of
•iam_chain_type - see IAM chains and allocation units in SQL Server 2005
•PageType - the page type. Some common ones are:
	◦1 - data page
	◦2 - index page
	◦3 and 4 - text pages
	◦8 - GAM page
	◦9 - SGAM page
	◦10 - IAM page
	◦11 - PFS page
•IndexLevel - what level the page is at in the index (if at all). Remember that index levels go from 0 at the leaf to N at the root page (except in clustered indexes in SQL Server 2000 and 7.0 - where there's a 0 at the leaf level (data pages) and a 0 at the next level up (first level of index pages))
•NextPageFID and NextPagePID - the page ID of the next page in the doubly-linked list of pages at this level of the index
•PrevPageFID and PrevPagePID - the page ID of the previous page in the doubly-linked list of pages at this level of the index
*/

dbcc ind(TestData,Customers,-1)




/*
DBCC TRACEON(3604)
trace flag 3604 enables output from DBCC PAGE

DBCC PAGE (<database name>,<fileid>,<pageid>,<output option>)

NB: output option (3=output to console, 2=summary of offset)
*/

DBCC PAGE (dbccpagetest, 1, 155, 3);

GO