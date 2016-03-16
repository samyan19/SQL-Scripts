param($stringPath='S:\SQL-Scripts')

#Import-Module sqlps

#Invoke-Sqlcmd -Query "select * from sys.databases"

#Get-ChildItem -Path $stringPath -Recurse -Filter *.sql
 #   Invoke-Sqlcmd -InputFile $f.fullname

foreach ($f in (Get-ChildItem -Path $stringPath -Recurse -Filter *.sql))
{
    Invoke-Sqlcmd -InputFile $f.fullname
}
