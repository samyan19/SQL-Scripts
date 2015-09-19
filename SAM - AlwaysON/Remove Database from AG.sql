--Remove primary database from AG
ALTER AVAILABILITY GROUP MyAG REMOVE DATABASE db6

--Remover secondary database from AG
ALTER DATABASE db6 SET HADR OFF