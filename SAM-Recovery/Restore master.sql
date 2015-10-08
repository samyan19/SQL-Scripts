/*
1. Start instance single user mode (-m)
2. sqlcmd
3. run restore statement
*/

RESTORE DATABASE master FROM DISK = '[Drive]:\Backup_path\MASTER_.bak' WITH REPLACE;

/*
4. Instance will stop
5. Restart multi

http://yrushka.com/index.php/sql-server/database-recovery/sql-server-migration-from-one-server-to-another-detailed-checklist/

NB: When migrating, if the paths are not the same then master cannot be restored as it will be looking for existing paths
i.e. all scripted out
*/
