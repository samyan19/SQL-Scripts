-- reassign DTS package in SQL 2005/2008

EXEC msdb..sp_reassign_dtspackageowner, packagename, packageid, owner

EXEC msdb..sp_reassign_dtspackageowner 'TargetImportToContracts','9AA9559F-7FC5-4B34-A259-D295E28F6127',[UK\3rdxansa10]




select * FROM sysdtspackages