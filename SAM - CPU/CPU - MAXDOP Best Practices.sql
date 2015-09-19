/*
• For servers that use more than eight processors, use this configuration: MAXDOP=8. 

• For servers that have eight or less processors, use this configuration where N equals the number of processors: MAXDOP=0 to N. 

• For servers that have NUMA configured, MAXDOP should not exceed the number of CPUs (cores) that are assigned to each NUMA node. 
--To find NUMA
--Windows Resource Monitor
--select * from sys.dm_os_memory_nodes
--select * from sys.dm_os_schedulers

• For servers that have hyper-threading enabled, the MAXDOP value should not exceed the number of physical processors.

http://support.microsoft.com/kb/2806535 
*/
