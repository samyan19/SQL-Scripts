DECLARE @clusNodes VARCHAR(MAX)
SELECT @clusNodes = COALESCE(@clusNodes+',' ,'') + NodeName
FROM sys.dm_os_cluster_nodes
SELECT @clusNodes
GO
