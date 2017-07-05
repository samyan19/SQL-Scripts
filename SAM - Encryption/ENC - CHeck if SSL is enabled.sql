/*
https://wateroxconsulting.com/archives/quickly-check-if-ssl-for-sql-is-enabled/
*/

SELECT session_id, encrypt_option
FROM sys.dm_exec_connections
