/*
List database properties 
*/

select
sysDB.database_id,
sysDB.Name as 'database_name',
suser_sname(sysDB.owner_sid) as 'database_owner',
sysDB.state_desc,
sysDB.recovery_model_desc,
sysDB.collation_name,
sysDB.user_access_desc,
sysDB.compatibility_level,
sysDB.is_read_only,
sysDB.is_auto_close_on,
sysDB.is_auto_shrink_on,
sysDB.is_auto_create_stats_on,
sysDB.is_auto_update_stats_on,
sysDB.is_fulltext_enabled,
sysDB.is_trustworthy_on,
sysDB.is_quoted_identifier_on
from sys.databases sysDB
