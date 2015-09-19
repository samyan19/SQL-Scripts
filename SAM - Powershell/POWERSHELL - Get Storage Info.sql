/*--
--Run powershell script to return storage type for LUN
--*/

/*
function Get-StorageInfo{
$DiskDrives = Get-WmiObject Win32_DiskDrive | select Caption,DeviceID, InterfaceType

foreach ($DiskDrive in $DiskDrives) {

    $Query = "ASSOCIATORS OF {Win32_DiskDrive.DeviceID='" + $DiskDrive.DeviceID + "'} WHERE AssocClass = Win32_DiskDriveToDiskPartition"
    $DiskPartitions = Get-WmiObject -Query $Query

    foreach ($DiskPartition in $DiskPartitions) {
        $Query = "ASSOCIATORS OF {Win32_DiskPartition.DeviceID='" + $DiskPartition.DeviceID + "'} WHERE AssocClass = Win32_LogicalDiskToPartition"
        $LogicalDisks = Get-WmiObject -Query $Query

        foreach ($LogicalDisk in $LogicalDisks) {
            Write-Output "Caption: $($DiskDrive.Caption)"
            Write-Output "Device ID: $($DiskDrive.DeviceID)"
            Write-Output "Disk Partition: $($DiskPartition.DeviceID)"
            Write-Output "Drive Letter: $($LogicalDisk.DeviceID)"
            Write-Output "InterfaceTypeID: $($DiskDrives.InterfaceType)"
            Write-Output ""
        }
    }
}
}

Get-StorageInfo
*/