##################################################################################################################################################
#Example values for Variables for the file
#
#$FullBackupsToKeep = 1
#$BackupDir = 'E:\Backups'
#
#$FullBackupsToKeep = 2  (will keep 2 Full backups and any Diffs since oldest full backup)
#$BackupDir = "E:\Backups\" (Location of the files needed deleting 
###################################################################################################################################################
Param (  
[string] $ServerInstance  
)


$QueryBackupDir = "SELECT Value FROM dbo.tblConfigs WHERE name = 'Diff_BackupLocation' AND procedurename = 'ALL'"
$QueryFullBackupsToKeep = "SELECT Value FROM dbo.tblConfigs WHERE name = 'FullBackupsToKeep' AND ProcedureName = 'PowershellScriptForDeletingDiffBackups'"
$BackupDir = Invoke-Sqlcmd -Query $QueryBackupDir -ServerInstance $ServerInstance  -Database 'zzSQLServerAdmin'
$FullBackupsToKeep = Invoke-Sqlcmd -Query $QueryFullBackupsToKeep -ServerInstance $ServerInstance -Database 'zzSQLServerAdmin'


foreach ($dir in Get-ChildItem $BackupDir.Value  | where-object { $_.PSIsContainer -eq 'TRUE'})
{ 
$count =  Get-ChildItem $dir.FullName -Filter "*.bak" | Measure-Object

	IF ($count.Count -gt $FullBackupsToKeep.Value)
		{
		$latest = Get-ChildItem -Path $dir.FullName -Filter "*.bak" | Sort-Object LastWriteTime -Descending  | Select-Object -Index ($FullBackupsToKeep.Value - 1)
		Get-ChildItem -Path $dir.FullName | Where-Object {$_.LastWriteTime -lt $latest.LastWriteTime} | Remove-Item 
 		}
}