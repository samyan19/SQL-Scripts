xp_msver
SELECT @@VERSION
select SERVERPROPERTY('productlevel'),SERVERPROPERTY('edition'),SERVERPROPERTY('productversion')
exec sp_configure 'default language'