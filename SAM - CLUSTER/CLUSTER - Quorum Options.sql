/*=========================================

Node Majority 
------------------------------------------
Partition with majority maintains quorum
REC: odd number of nodes
FAILURES: 1/2 #Nodes (rounding up) -1


Node & Disk Majority
-------------------
REC: even number of nodes
Disk witness
failover between nodes
FAILURES: 
	DSW = 1/2 #Nodes (rounding up)  
	NO DSW = 1/2 #Nodes (rounding up) -1



Node & File Share Majority
--------------------------
REC: multi site clusters (2 Node site A, 2 node site B).even number nodes
REC: For AG as no shared storage

FSW File share witness
files share can be placed on clustered fileshare for HA
files share placed independent of cluster
files server can host FSW multiple clusters


=============================================*/


