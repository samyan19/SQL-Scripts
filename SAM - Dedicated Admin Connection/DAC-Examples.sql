/*===========================

single threaded

1 sysadmin at a time

sysadmin only

admin:<INSTANCE NAME>

close after use

TCP 1434

=============================*/


/* Check DAC connections */
select sch.cpu_id, sch.is_online,sch.status,n.node_state_desc
from sys.dm_os_schedulers as sch
join sys.dm_os_nodes as n on
	sch.parent_node_id=n.node_id and
	n.node_state_desc='ONLINE DAC'


/* 
Enable remote connection 
remote desktop to machine not required
*/
exec sp_configure 'remote admin connections', 1;


/* Check outstanding configuration options which have not been reconfigured */
select name,value,value_in_use
from sys.configurations
where value <> value_in_use


/* Find who is using the DAC */
select s.login_name,e.name
from sys.endpoints e
join sys.dm_exec_sessions s on e.endpoint_id=s.endpoint_id
--where e.name='Dedicated Admin Connection'