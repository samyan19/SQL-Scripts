/*======================================================
 - Run in 2 sessions 
 - execute each statement one at a time
=======================================================*/

/* 
QUERY A
*/

SET TRANSACTION ISOLATION LEVEL REPEATABLE READ
GO
 
BEGIN TRANSACTION
 
SELECT * FROM Person.Person
WHERE ModifiedDate = '20030208'
 
UPDATE Person.Person
SET FirstName = '...'
WHERE ModifiedDate = '20030208'
 
ROLLBACK
GO

/* QUERY B */

SET TRANSACTION ISOLATION LEVEL REPEATABLE READ
GO
 
BEGIN TRANSACTION
 
SELECT * FROM Person.Person
WHERE ModifiedDate = '20030208'
 
UPDATE Person.Person
SET FirstName = '...'
WHERE ModifiedDate = '20030208'
 
ROLLBACK
GO