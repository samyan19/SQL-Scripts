
/* https://www.mssqltips.com/sqlservertip/2191/how-to-check-sql-server-authentication-mode-using-t-sql-and-ssms/ */

SELECT CASE SERVERPROPERTY('IsIntegratedSecurityOnly')   
WHEN 1 THEN 'Windows Authentication'   
WHEN 0 THEN 'Windows and SQL Server Authentication'   
END as [Authentication Mode]  
