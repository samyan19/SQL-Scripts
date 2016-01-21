/*
Symptoms
========
Taking longer to replicate data.
High CPU on Distributor server
High Disk IO on Distributor server
High growth rate on Distribution database

https://www.mssqltips.com/sqlservertip/1823/troubleshooting-slow-sql-server-replication-issue-due-to-distributor-database-growth/
*/

use distribution 
go
set transaction isolation level read uncommitted
select distinct 
srv.srvname publication_server 
, a.publisher_db
, p.publication publication_name
, p.retention
, ss.srvname subscription_server
, s.subscriber_db
from MSArticles a 
join MSpublications p on a.publication_id = p.publication_id
join MSsubscriptions s on p.publication_id = s.publication_id
join master..sysservers ss on s.subscriber_id = ss.srvid
join master..sysservers srv on srv.srvid = p.publisher_id
join MSdistribution_agents da on da.publisher_id = p.publisher_id 
and da.subscriber_id = s.subscriber_id
ORDER BY p.retention 
