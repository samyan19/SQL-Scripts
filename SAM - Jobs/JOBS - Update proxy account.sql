/*
https://docs.microsoft.com/en-us/sql/relational-databases/system-stored-procedures/sp-update-proxy-transact-sql
*/
USE msdb ;  
GO  

EXEC dbo.sp_update_proxy  
    @proxy_name = 'CLOSEBROTHERSGP_zSvcALMUATProxy_proxy',  
    @credential_name = 'CLOSEBROTHERSGP_zSvcALMUATProxy_credential' 
GO  
