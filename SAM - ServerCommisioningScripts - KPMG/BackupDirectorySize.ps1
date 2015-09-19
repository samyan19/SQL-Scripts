##################################################################################################################################################
#Example values for Variables for the file
#
#$ServerInstance = 'RCSTVMAN07'
#
# 20140109 - IG
#
###################################################################################################################################################
Param (  
[string] $ServerInstance  
)

Import-Module SQLPS -DisableNameChecking

#$InstanceName = 'RCSTVMAN07'
$FullFileLocation = Invoke-Sqlcmd -ServerInstance $ServerInstance -Database 'zzSQLServerAdmin' -Query "SELECT [Value] FROM [zzSQLServerAdmin].[dbo].[tblConfigs] WHERE Name = 'Full_BackupLocation'"
$DiffFileLocation = Invoke-Sqlcmd -ServerInstance $ServerInstance -Database 'zzSQLServerAdmin' -Query "SELECT [Value] FROM [zzSQLServerAdmin].[dbo].[tblConfigs] WHERE Name = 'Diff_BackupLocation'"
$TLogFileLocation = Invoke-Sqlcmd -ServerInstance $ServerInstance -Database 'zzSQLServerAdmin' -Query "SELECT [Value] FROM [zzSQLServerAdmin].[dbo].[tblConfigs] WHERE Name = 'TLog_BackupLocation'"
$FRTFileLocation = Invoke-Sqlcmd -ServerInstance $ServerInstance -Database 'zzSQLServerAdmin' -Query "SELECT [Value] FROM [zzSQLServerAdmin].[dbo].[tblConfigs] WHERE Name = 'Full_Restore_Temp_BackupLocation'"
$FPFileLocation = Invoke-Sqlcmd -ServerInstance $ServerInstance -Database 'zzSQLServerAdmin' -Query "SELECT [Value] FROM [zzSQLServerAdmin].[dbo].[tblConfigs] WHERE Name = 'Full_Preserve_BackupLocation'"

$FullFileLocation = $FullFileLocation | % { $_.value}
$DiffFileLocation = $DiffFileLocation | % { $_.value}
$TLogFileLocation = $TLogFileLocation | % { $_.value}
$FRTFileLocation = $FRTFileLocation | % { $_.value}
$FPFileLocation = $FPFileLocation | % { $_.value}



$FUllFileSize = Get-ChildItem $FullFileLocation -Recurse | Measure-Object -Property Length -Sum
$BackupSizeFULL = [system.math]::ceiling($FUllFileSize.Sum/1000/1024) 

$DiffFileSize = Get-ChildItem $DiffFileLocation -Recurse | Measure-Object -Property Length -Sum
$BackupSizeDIFF = [system.math]::ceiling($DiffFileSize.Sum/1000/1024) 

$TLogFileSize = Get-ChildItem $TLogFileLocation -Recurse | Measure-Object -Property Length -Sum
$BackupSizeTLog = [system.math]::ceiling($TLogFileSize.Sum/1000/1024) 

$FRTFileSize = Get-ChildItem $FRTFileLocation -Recurse | Measure-Object -Property Length -Sum
$BackupSizeFRT = [system.math]::ceiling($FRTFileSize.Sum/1000/1024)

$FPFileSize = Get-ChildItem $FPFileLocation -Recurse | Measure-Object -Property Length -Sum
$BackupSizeFP = [system.math]::ceiling($FPFileSize.Sum/1000/1024)


Invoke-Sqlcmd -ServerInstance $ServerInstance -Database 'zzSQLServerAdmin' -Query "INSERT INTO cp.tblBackupDirectorySize (FULLMB,DIFFMB,TLOGMB,FULL_RESTORE_TEMPMB,FULL_PRESERVEMB) VALUES ($BackupSizeFULL, $BackupSizeDIFF, $BackupSizeTLog, $BackupSizeFRT, $BackupSizeFP)"

