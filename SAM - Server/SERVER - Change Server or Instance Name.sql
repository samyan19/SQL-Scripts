--To change name for local

sp_dropserver UL3SQLV01
GO
sp_addserver GL3SQLV01,local
GO

--To change name for instance 
sp_addserver GL3SQLV01,<InstanceName>
GO

--To check names on the server
sp_helpserver
select @@servername
select SERVERPROPERTY('servername')


--RESTART REQUIRED!!!!!