select * from sys.dm_os_nodes

--memory_node_id 64 is for Dedicated Admin Connection (DAC)
select * from sys.dm_os_memory_nodes

--parent_node_id relates to the memory_node_id in sys.dm_os_memory_nodes
select * from sys.dm_os_schedulers