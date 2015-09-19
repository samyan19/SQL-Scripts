/****** Object:  Endpoint [Mirroring]    Script Date: 03/28/2012 16:42:12 ******/
IF  EXISTS (SELECT * FROM sys.endpoints e WHERE e.name = N'Mirroring') 
DROP ENDPOINT [Mirroring]
GO

CREATE ENDPOINT Mirroring
AUTHORIZATION [sa]
STATE=STARTED
AS TCP (LISTENER_PORT=5022,LISTENER_IP=(10.217.111.15))
FOR DATABASE_MIRRORING (ROLE=PARTNER)


ALTER DATABASE Legion SET PARTNER = N'TCP://WYCWSQLP004-mir.uk.centricaplc.com:5022'

--ALTER DATABASE Legion SET PARTNER OFF 

select name,type_desc,state_desc,port,is_dynamic_port,ip_address from sys.tcp_endpoints

go

select database_id,mirroring_state_desc,mirroring_role_desc,mirroring_partner_name,mirroring_partner_instance from sys.database_mirroring


sp_cycle_errorlog