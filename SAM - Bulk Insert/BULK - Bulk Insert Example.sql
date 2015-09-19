--Create database
create database TestData
go

--Create table
USE TestData
GO
CREATE TABLE CSVTest
(ID INT,
FirstName VARCHAR(40),
LastName VARCHAR(40),
BirthDate SMALLDATETIME)
GO

/*

2. Create CSV File
-------------------

the file is C:\csvtest.txt

1,James,Smith,19750101
2,Meggie,Smith,19790122
3,Robert,Smith,20071101
4,Alex,Smith,20040202


*/

BULK
INSERT CSVTest
FROM 'c:\csvtest.txt'
WITH
(
FIELDTERMINATOR = ',',
ROWTERMINATOR = '\n'
)
GO

--Check the content of the table.
SELECT *
FROM CSVTest
GO

--Empty the table.
TRUNCATE TABLE CSVTest
GO
