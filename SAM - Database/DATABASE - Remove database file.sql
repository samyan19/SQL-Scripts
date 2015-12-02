/*
Notes:
1. you cannot remove the first file
2. data from empty file is distributed amongst the remaining files in the file group
*/


USE master;
GO
ALTER DATABASE AdventureWorks2012
REMOVE FILE test1dat4;
GO
