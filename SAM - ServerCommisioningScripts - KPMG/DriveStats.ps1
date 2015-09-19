Param (  
[string]$computername  , [string]$InstanceName   
)

#####################################################
#
#20140718 - IG - added code to view mountpoints.
#
#####################################################

Add-PSSnapin SqlServerCmdletSnapin100
Add-PSSnapin SqlServerProviderSnapin100
#Import-Module SQLPS -DisableNameChecking


$a = Get-WmiObject Win32_Volume -ComputerName $computername | 
Select-Object Name, DriveType,FileSystem,SystemVolume,
@{name='SizeMB';expr={[int]($_.Capacity/1MB)}}, 
@{name='FreeSpaceMB';expr={[int]($_.FreeSpace/1MB)}}, 
@{name='PercentFreeSpace';expr={"{0:N2}" -f(($_.Freespace/$_.Capacity)*100)}},
Label  | Where-Object {$_.DriveType -eq 3}  



foreach ($z in $a | Where-Object {$_.SystemVolume -ne 'True'})
{
$DeviceID = $z.Name.TrimEnd(":\")
$SizeMB = $z.SizeMB
$FreeSpaceMB = $z.FreeSpaceMB
$PercentFreeNow = $z.PercentFreeSpace
$VolumeName = $z.Label


Invoke-Sqlcmd -ServerInstance $InstanceName  -Database 'zzSQLServerAdmin' -Query "MERGE [dbo].[tblDriveStats] AS Target
USING (SELECT '$DeviceID', '$SizeMB', '$FreeSpaceMB', '$PercentFreeNow', '$VolumeName' ) AS Source (DeviceID, SizeMB, FreeSpaceMB, PercentFreeNow, VolumeName)
ON Target.DriveLetter = DeviceID
WHEN MATCHED THEN 
	UPDATE SET 
		TotalSizeMB = '$SizeMB',
		FreeSpaceMB = '$FreeSpaceMB',
		PercentFreeNow = '$PercentFreeNow',
		VolumeName = '$VolumeName',
		LastUpdate = Current_Timestamp
WHEN NOT MATCHED THEN
	INSERT (ServerName, LastUpdate, DriveLetter, TotalSizeMB, FreeSpaceMB, PercentFreeWarning, PercentFreeCrit, PercentFreeNow, VolumeName)
	VALUES (@@SERVERNAME, Current_Timestamp, '$DeviceID', '$SizeMB', '$FreeSpaceMB', 25, 15, '$PercentFreeNow', '$VolumeName');"
}