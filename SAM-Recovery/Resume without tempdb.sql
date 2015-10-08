/*
http://www.xtivia.com/start-sql-server-lost-tempdb-data-files/

start in minimal configuration mode (-f)

open sql cmd
*/

1> USE MASTER
2> GO
3> ALTER DATABASE tempdb MODIFY FILE
4> (NAME = tempdev, FILENAME = 'C:\NEWPATH\datatempdb.mdf')
5> GO
6> quit

