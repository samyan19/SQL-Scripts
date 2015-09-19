/*

CLUSTER.EXE YourClusterName LOG /GEN /COPY:"C:\Temp\cluster.log"


2008 + cluster log location

%windir%\System32\winevt\logs\

*/

/*

-------------------------- EXAMPLE 1 --------------------------
Command Prompt: C:\PS>
 
Get-ClusterLog 
 
Mode                LastWriteTime     Length Name 
----                -------------     ------ ---- 
-a---          9/4/2008   3:53 PM    2211301 Cluster.log 
-a---          9/4/2008   3:53 PM    1261025 Cluster.log
Description
-----------
This command creates a log file for the local cluster in the cluster reports folder on each node of the cluster (C:\Windows\Cluster\Reports).
 
-------------------------- EXAMPLE 2 --------------------------
Command Prompt: C:\PS>
 
Get-ClusterLog -Destination . 
 
Mode                LastWriteTime     Length Name 
----                -------------     ------ ---- 
-a---          9/4/2008   3:55 PM    2211301 node1_cluster.log 
-a---          9/4/2008   3:55 PM    1261025 node2_cluster.log
Description
-----------
This command creates a log file for each node of the local cluster, and copies all logs to the local folder.
 
-------------------------- EXAMPLE 3 --------------------------
Command Prompt: C:\PS>
 
Get-ClusterLog -TimeSpan 5 
 
Mode                LastWriteTime     Length Name 
----                -------------     ------ ---- 
-a---          9/4/2008   3:58 PM     128299 Cluster.log 
-a---          9/4/2008   3:58 PM     104181 Cluster.log
Description
-----------
This command creates a log file for the local cluster in the cluster reports folder on each node of the cluster. The log covers the last 5 minutes.


------------------------ EXAMPLE 4 -------------------------------

Reminder:  The event log is in local time and the cluster.log is in GMT.  With Windows Server 2012 you can use the Get-ClusterLog –UseLocalTime to generate the Cluster.log in local time.  This will make correlating with the event log easier.

*/