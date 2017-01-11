$a = "<style>"
#$a = $a + "BODY{background-color:peachpuff;}"
$a = $a + "TABLE{border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}"
$a = $a + "TH{border-width: 1px;padding: 0px;border-style: solid;border-color: black;background-color:lightskyblue}"
$a = $a + "TD{border-width: 1px;padding: 0px;border-style: solid;border-color: black;background-color:lightyellow}"
$a = $a + "</style>"
gwmi win32_service -comp (gc D:\TreasuryServers.txt) -filter " name like '%sql%'" | select __SERVER,name,startmode,state,status,StartName | ConvertTo-HTML -head $a | Out-File D:\TreasuryServers_Services.htm

#gwmi win32_service -comp (gc D:\TreasuryServers.txt) -filter " name like '%sql%'" | select __SERVER,name,startmode,state,status,StartName | format-list| out-file D:\services.txt 
