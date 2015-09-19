--set executionpolicy unrestricted

/*
Function Get-RemoteDiskInformation
{
    <#
    .SYNOPSIS
       Get inventory data for specified computer systems.
    .DESCRIPTION
       Gather inventory data for one or more systems using wmi. Data proccessing utilizes multiple runspaces
       and supports custom timeout parameters in case of wmi problems. You can optionally include 
       drive, memory, and network information in the results. You can view verbose information on each 
       runspace thread in realtime with the -Verbose option.
    .PARAMETER ComputerName
       Specifies the target computer for data query.
    .PARAMETER ThrottleLimit
       Specifies the maximum number of systems to inventory simultaneously 
    .PARAMETER Timeout
       Specifies the maximum time in second command can run in background before terminating this thread.
    .PARAMETER ShowProgress
       Show progress bar information
    .PARAMETER PromptForCredential
       Prompt for remote system credential prior to processing request.
    .PARAMETER Credential
       Accept alternate credential (ignored if the localhost is processed)
    .EXAMPLE
       PS > Get-RemoteDiskInformation -ComputerName test1
     
       Description
       -----------
       Query and display disk related information about test1

    .EXAMPLE
       PS > $cred = Get-Credential
       PS > Get-RemoteDiskInformation -ComputerName Test1 -Credential $cred

    .NOTES
    Author:
    Zachary Loeber
    
    Version Info:
    1.1 - 01/04/2014
        - Added missing computername property to diskelements variable
    1.0 - 12/13/2013
        - Initial release (kind of, this bit of code is modified from a prior function I rolled into an all inclusive system information gathering
          function).
    .LINK 
        http://www.the-little-things.net 
    #>
    [CmdletBinding()]
    PARAM
    (
        [Parameter(ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [ValidateNotNullOrEmpty()]
        [Alias('DNSHostName','PSComputerName')]
        [string[]]
        $ComputerName=$env:computername,

        [Parameter( HelpMessage="Refrain from applying drive space GB/MB/KB pretty formatting.")]
        [switch]
        $RawDriveData,

        [Parameter(HelpMessage="Maximum number of concurrent runspaces.")]
        [ValidateRange(1,65535)]
        [int32]
        $ThrottleLimit = 32,
 
        [Parameter(HelpMessage="Timeout before a runspaces stops trying to gather the information.")]
        [ValidateRange(1,65535)]
        [int32]
        $Timeout = 120,
 
        [Parameter(HelpMessage="Display progress of function.")]
        [switch]
        $ShowProgress,
        
        [Parameter(HelpMessage="Set this if you want the function to prompt for alternate credentials.")]
        [switch]
        $PromptForCredential,
        
        [Parameter(HelpMessage="Set this if you want to provide your own alternate credentials.")]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )

    BEGIN
    {
        # Gather possible local host names and IPs to prevent credential utilization in some cases
        Write-Verbose -Message 'Get-RemoteDiskInformation: Creating local hostname list'
        $IPAddresses = [net.dns]::GetHostAddresses($env:COMPUTERNAME) | Select-Object -ExpandProperty IpAddressToString
        $HostNames = $IPAddresses | ForEach-Object {
            try {
                [net.dns]::GetHostByAddress($_)
            } catch {
                # We do not care about errors here...
            }
        } | Select-Object -ExpandProperty HostName -Unique
        $LocalHost = @('', '.', 'localhost', $env:COMPUTERNAME, '::1', '127.0.0.1') + $IPAddresses + $HostNames
 
        Write-Verbose -Message 'Get-RemoteDiskInformation: Creating initial variables'
        $runspacetimers       = [HashTable]::Synchronized(@{})
        $runspaces            = New-Object -TypeName System.Collections.ArrayList
        $bgRunspaceCounter    = 0
        
        if ($PromptForCredential)
        {
            $Credential = Get-Credential
        }
        
        Write-Verbose -Message 'Get-RemoteDiskInformation: Creating Initial Session State'
        $iss = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()
        foreach ($ExternalVariable in ('runspacetimers', 'Credential', 'LocalHost'))
        {
            Write-Verbose -Message "Get-RemoteDiskInformation: Adding variable $ExternalVariable to initial session state"
            $iss.Variables.Add((New-Object -TypeName System.Management.Automation.Runspaces.SessionStateVariableEntry -ArgumentList $ExternalVariable, (Get-Variable -Name $ExternalVariable -ValueOnly), ''))
        }
        
        Write-Verbose -Message 'Get-RemoteDiskInformation: Creating runspace pool'
        $rp = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspacePool(1, $ThrottleLimit, $iss, $Host)
        $rp.ApartmentState = 'STA'
        $rp.Open()
 
        # This is the actual code called for each computer
        Write-Verbose -Message 'Get-RemoteDiskInformation: Defining background runspaces scriptblock'
        $ScriptBlock = 
        {
            [CmdletBinding()]
            Param
            (
                [Parameter(Position=0)]
                [string]
                $ComputerName,
 
                [Parameter(Position=1)]
                [int]
                $bgRunspaceID,
                
                [Parameter(Position=2)]
                [switch]
                $RawDriveData
            )
            $runspacetimers.$bgRunspaceID = Get-Date
            
            try
            {
                Write-Verbose -Message ('Get-RemoteDiskInformation: Runspace {0}: Start' -f $ComputerName)
                $WMIHast = @{
                    ComputerName = $ComputerName
                    ErrorAction = 'Stop'
                }
                if (($LocalHost -notcontains $ComputerName) -and ($Credential -ne $null))
                {
                    $WMIHast.Credential = $Credential
                }

                Filter ConvertTo-KMG 
                {
                     <#
                     .Synopsis
                      Converts byte counts to Byte\KB\MB\GB\TB\PB format
                     .DESCRIPTION
                      Accepts an [int64] byte count, and converts to Byte\KB\MB\GB\TB\PB format
                      with decimal precision of 2
                     .EXAMPLE
                     3000 | convertto-kmg
                     #>

                     $bytecount = $_
                        switch ([math]::truncate([math]::log($bytecount,1024))) 
                        {
                            0 {"$bytecount Bytes"}
                            1 {"{0:n2} KB" -f ($bytecount / 1kb)}
                            2 {"{0:n2} MB" -f ($bytecount / 1mb)}
                            3 {"{0:n2} GB" -f ($bytecount / 1gb)}
                            4 {"{0:n2} TB" -f ($bytecount / 1tb)}
                            Default {"{0:n2} PB" -f ($bytecount / 1pb)}
                        }
                }
                
                Write-Verbose -Message ('Get-RemoteDiskInformation: Runspace {0}: Disk information' -f $ComputerName)
                $WMI_DiskMountProps   = @('Name','Label','Caption','Capacity','FreeSpace','Compressed','PageFilePresent','SerialNumber')
                
                # WMI data
                $wmi_diskdrives = Get-WmiObject @WMIHast -Class Win32_DiskDrive
                $wmi_mountpoints = Get-WmiObject @WMIHast -Class Win32_Volume -Filter "DriveType=3 AND DriveLetter IS NULL" | 
                                   Select $WMI_DiskMountProps
                
                $AllDisks = @()
                $DiskElements = @('ComputerName','Disk','Model','Partition','Description','PrimaryPartition','VolumeName','Drive','DiskSize','FreeSpace','UsedSpace','PercentFree','PercentUsed','DiskType','SerialNumber')
                foreach ($diskdrive in $wmi_diskdrives) 
                {
                    $partitionquery = "ASSOCIATORS OF {Win32_DiskDrive.DeviceID=`"$($diskdrive.DeviceID.replace('\','\\'))`"} WHERE AssocClass = Win32_DiskDriveToDiskPartition"
                    $partitions = @(Get-WmiObject @WMIHast -Query $partitionquery)
                    foreach ($partition in $partitions)
                    {
                        $logicaldiskquery = "ASSOCIATORS OF {Win32_DiskPartition.DeviceID=`"$($partition.DeviceID)`"} WHERE AssocClass = Win32_LogicalDiskToPartition"
                        $logicaldisks = @(Get-WmiObject @WMIHast -Query $logicaldiskquery)
                        foreach ($logicaldisk in $logicaldisks)
                        {
                            $PercentFree = [math]::round((($logicaldisk.FreeSpace/$logicaldisk.Size)*100), 2)
                            $UsedSpace = ($logicaldisk.Size - $logicaldisk.FreeSpace)
                            $diskprops = @{
                                           ComputerName = $ComputerName
                                           Disk = $diskdrive.Name
                                           Model = $diskdrive.Model
                                           Partition = $partition.Name
                                           Description = $partition.Description
                                           PrimaryPartition = $partition.PrimaryPartition
                                           VolumeName = $logicaldisk.VolumeName
                                           Drive = $logicaldisk.Name
                                           DiskSize = if ($RawDriveData) { $logicaldisk.Size } else { $logicaldisk.Size | ConvertTo-KMG }
                                           FreeSpace = if ($RawDriveData) { $logicaldisk.FreeSpace } else { $logicaldisk.FreeSpace | ConvertTo-KMG }
                                           UsedSpace = if ($RawDriveData) { $UsedSpace } else { $UsedSpace | ConvertTo-KMG }
                                           PercentFree = $PercentFree
                                           PercentUsed = [math]::round((100 - $PercentFree),2)
                                           DiskType = 'Partition'
                                           SerialNumber = $diskdrive.SerialNumber
                                         }
                            Write-Output (New-Object psobject -Property $diskprops | Select $DiskElements)
                        }
                    }
                }
                # Mountpoints are weird so we do them seperate.
                if ($wmi_mountpoints)
                {
                    foreach ($mountpoint in $wmi_mountpoints)
                    {
                        $PercentFree = [math]::round((($mountpoint.FreeSpace/$mountpoint.Capacity)*100), 2)
                        $UsedSpace = ($mountpoint.Capacity - $mountpoint.FreeSpace)
                        $diskprops = @{
                               ComputerName = $ComputerName
                               Disk = $mountpoint.Name
                               Model = ''
                               Partition = ''
                               Description = $mountpoint.Caption
                               PrimaryPartition = ''
                               VolumeName = ''
                               VolumeSerialNumber = ''
                               Drive = [Regex]::Match($mountpoint.Caption, "(^.:)").Value
                               DiskSize = if ($RawDriveData) { $mountpoint.Capacity } else { $mountpoint.Capacity | ConvertTo-KMG }
                               FreeSpace = if ($RawDriveData) { $mountpoint.FreeSpace } else { $mountpoint.FreeSpace | ConvertTo-KMG }
                               UsedSpace = if ($RawDriveData) { $UsedSpace } else { $UsedSpace | ConvertTo-KMG }
                               PercentFree = $PercentFree
                               PercentUsed = [math]::round((100 - $PercentFree),2)
                               DiskType = 'MountPoint'
                               SerialNumber = $mountpoint.SerialNumber
                             }
                        Write-Output (New-Object psobject -Property $diskprops  | Select $DiskElements)
                    }
                }
            }
            catch
            {
                Write-Warning -Message ('Get-RemoteDiskInformation: {0}: {1}' -f $ComputerName, $_.Exception.Message)
            }
            Write-Verbose -Message ('Get-RemoteDiskInformation: Runspace {0}: End' -f $ComputerName)
        }
 
        function Get-Result
        {
            [CmdletBinding()]
            Param 
            (
                [switch]$Wait
            )
            do
            {
                $More = $false
                foreach ($runspace in $runspaces)
                {
                    $StartTime = $runspacetimers[$runspace.ID]
                    if ($runspace.Handle.isCompleted)
                    {
                        Write-Verbose -Message ('Get-RemoteDiskInformation: Thread done for {0}' -f $runspace.IObject)
                        $runspace.PowerShell.EndInvoke($runspace.Handle)
                        $runspace.PowerShell.Dispose()
                        $runspace.PowerShell = $null
                        $runspace.Handle = $null
                    }
                    elseif ($runspace.Handle -ne $null)
                    {
                        $More = $true
                    }
                    if ($Timeout -and $StartTime)
                    {
                        if ((New-TimeSpan -Start $StartTime).TotalSeconds -ge $Timeout -and $runspace.PowerShell)
                        {
                            Write-Warning -Message ('Timeout {0}' -f $runspace.IObject)
                            $runspace.PowerShell.Dispose()
                            $runspace.PowerShell = $null
                            $runspace.Handle = $null
                        }
                    }
                }
                if ($More -and $PSBoundParameters['Wait'])
                {
                    Start-Sleep -Milliseconds 100
                }
                foreach ($threat in $runspaces.Clone())
                {
                    if ( -not $threat.handle)
                    {
                        Write-Verbose -Message ('Get-RemoteDiskInformation: Removing {0} from runspaces' -f $threat.IObject)
                        $runspaces.Remove($threat)
                    }
                }
                if ($ShowProgress)
                {
                    $ProgressSplatting = @{
                        Activity = 'Get-RemoteDiskInformation: Getting asset info'
                        Status = '{0} of {1} total threads done' -f ($bgRunspaceCounter - $runspaces.Count), $bgRunspaceCounter
                        PercentComplete = ($bgRunspaceCounter - $runspaces.Count) / $bgRunspaceCounter * 100
                    }
                    Write-Progress @ProgressSplatting
                }
            }
            while ($More -and $PSBoundParameters['Wait'])
        }
    }
    PROCESS
    {
        foreach ($Computer in $ComputerName)
        {
            $bgRunspaceCounter++
            $psCMD = [System.Management.Automation.PowerShell]::Create().AddScript($ScriptBlock)
            $null = $psCMD.AddParameter('bgRunspaceID',$bgRunspaceCounter)
            $null = $psCMD.AddParameter('ComputerName',$Computer)
            $null = $psCMD.AddParameter('RawDriveData',$RawDriveData)            
            $null = $psCMD.AddParameter('Verbose',$VerbosePreference) # Passthrough the hidden verbose option so write-verbose works within the runspaces
            $psCMD.RunspacePool = $rp
 
            Write-Verbose -Message ('Get-RemoteDiskInformation: Starting {0}' -f $Computer)
            [void]$runspaces.Add(@{
                Handle = $psCMD.BeginInvoke()
                PowerShell = $psCMD
                IObject = $Computer
                ID = $bgRunspaceCounter
                })
           Get-Result
        }
    }
    END
    {
        Get-Result -Wait
        if ($ShowProgress)
        {
            Write-Progress -Activity 'Get-RemoteDiskInformation: Getting asset info' -Status 'Done' -Completed
        }
        Write-Verbose -Message "Get-RemoteDiskInformation: Closing runspace pool"
        $rp.Close()
        $rp.Dispose()
    }
}


Get-RemoteDiskInformation

*/