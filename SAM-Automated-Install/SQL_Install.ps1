#------------Set user variables-------------------
#Default variables - do not amend
$CONFIGURATIONFILE="D:\ConfigurationFile.ini"
$SETUPPATH="E:\Setup.exe"
$localScriptRoot="D:\SQL-Scripts"

#Set folder locations
$SQLUSERDBDIR="D:\SQLData"
$SQLUSERDBLOGDIR="D:\SQLLogs"
$SQLTEMPDBDIR="D:\SQLTempDB"
$SQLBACKUPDIR="D:\SQLBackups"
$SQLARCHIVEDBACKUPS="D:\ArchivedBackups\SystemDatabases"

#Set instance name
$INSTANCENAME="MSSQLSERVER"
$INSTANCEID=$INSTANCENAME

#Set service accounts
$SQLSVCACCOUNT="SQLTEST\Administrator"
$SQLSVCPASSWORD="London01"
$AGTSVCACCOUNT="SQLTEST\Administrator"
$AGTSVCPASSWORD="London01"
$ISSVCACCOUNT="SQLTEST\Administrator"
$ISSVCPASSWORD="London01"

#Set sql settings
$SQLSYSADMINACCOUNTS="SQLTEST\Administrator"
$SQLCOLLATION="Latin1_General_CI_AS"
#------------end setting user variables------------------

#create sql folders
Write-Host "Creating SQL directories..."
New-Item -ItemType directory -Path $SQLUSERDBDIR
New-Item -ItemType directory -Path $SQLUSERDBLOGDIR
New-Item -ItemType directory -Path $SQLTEMPDBDIR
New-Item -ItemType directory -Path $SQLBACKUPDIR
New-Item -ItemType directory -Path $SQLARCHIVEDBACKUPS

#Start installation
Write-Host "Starting SQL install..."
$process=(Start-Process -Verb runas -FilePath $SETUPPATH -ArgumentList  "/CONFIGURATIONFILE=$CONFIGURATIONFILE /INSTANCENAME=$INSTANCENAME /INSTANCEID=$INSTANCEID /SQLSVCACCOUNT=$SQLSVCACCOUNT /SQLSVCPASSWORD=$SQLSVCPASSWORD /AGTSVCACCOUNT=$AGTSVCACCOUNT /AGTSVCPASSWORD=$AGTSVCPASSWORD /ISSVCACCOUNT=$ISSVCACCOUNT /ISSVCPASSWORD=$ISSVCPASSWORD /SQLUSERDBDIR=$SQLUSERDBDIR /SQLUSERDBLOGDIR=$SQLUSERDBLOGDIR /SQLBACKUPDIR=$SQLBACKUPDIR /SQLTEMPDBDIR=$SQLTEMPDBDIR /ISSVCPASSWORD=$ISSVCPASSWORD /SQLSYSADMINACCOUNTS=$SQLSYSADMINACCOUNTS /SQLCOLLATION=$SQLCOLLATION /IACCEPTSQLSERVERLICENSETERMS /QS /TCPENABLED=1" -Wait -PassThru)

#configure SQL if build successful
if($process.ExitCode -eq 0)
{
    Write-Host "SQL install successful..."
    Write-Host "Configuring scripts..."
    Invoke-Expression "D:\ConfigureSQL.ps1 $INSTANCENAME $localScriptRoot"
    Write-Host "SQL Build complete"
}
else
{
    Write-Host "SQL install failed. Please check Summary.txt for further information. Exit code:" $process.ExitCode
}

