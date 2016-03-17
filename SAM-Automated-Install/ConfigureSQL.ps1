param([string]$INSTANCENAME,[string]$localScriptRoot)

#Load SQLPS Module if not exists
IF (!(Get-Module -Name sqlps))
    {
        Write-Host 'Loading SQLPS Module' -ForegroundColor DarkYellow
        Push-Location
        Import-Module sqlps -DisableNameChecking
        Pop-Location
    }
  
#Run configuration scripts  
if($INSTANCENAME -eq "MSSQLSERVER"){$Server="."}else{$Server=".\"+$INSTANCENAME}    

$scripts = Get-ChildItem $localScriptRoot | Where-Object {$_.Extension -eq ".sql"}
  
foreach ($s in $scripts)
    {
        Write-Host "Running Script : " $s.Name -BackgroundColor DarkGreen -ForegroundColor White
        $script = $s.FullName
        Invoke-Sqlcmd -ServerInstance $Server -InputFile $script
    }
