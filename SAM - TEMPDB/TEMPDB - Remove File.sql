/*
https://www.sqlskills.com/blogs/erin/remove-files-from-tempdb/

1. set in minimal config mode (-f)
2. DIsable all services
3. COnnect with SQLCMDB
4. go to TempDB context (use tempdb)
5.Run below
*/

ALTER DATABASE [tempdb]  REMOVE FILE [logicalname]
GO

/*
6. Remove -f and restart
7. delete files
*/
