Param([int] $numDays, [string] $BackupDir, [string] $FileExtensionToDelete)


##################################################################################################################################################
#Example values for Variables for the file
#
#$numDays = 2  (days worth of files to keep)
#$BackupDir = "Z:\MSSQL\RCSTVSQL2K53-02\9.00\01_ISQL2K502\BACKUPS\FULL\*" (Location of the files needed deleting (* searches all subdirs)
#$FileExtensionToDelete = "bak" (kinda files to delete)
###################################################################################################################################################

$date = (Get-Date).Adddays(- $numDays)
Get-ChildItem $BackupDir -include *.$FileExtensionToDelete -recurse | Where-Object {$_.LastWriteTime -lt $date} | Remove-Item

