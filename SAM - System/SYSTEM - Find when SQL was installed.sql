/* http://blog.sqlauthority.com/2012/07/05/sql-server-retrieve-sql-server-installation-date-time/ */

SELECT create_date
FROM sys.server_principals
WHERE sid = 0x010100000000000512000000
