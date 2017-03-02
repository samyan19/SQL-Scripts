Write-Host Running Deploy Actions

Write-Host OriginalDirPath: $OriginalDirPath
Write-Host VersionToDeploy: $VersionToDeploy
Write-Host DeployEnvironment: $DeployEnvironment
$DeployEnvironment="UAT"

switch ($DeployEnvironment)
{
    "DEV" {
		$dbServer="TDC2SQL031"
		$dbInstance="\ALM"
		$ApplicationServer="ddc2app009"
		$dbName="ALM_DEV2_OneSumXFS_fsdb"
        $SQLAgentServiceAccount="TEST\zSvcTDC2SQL031ALMAGT"
        $StagingdbName="ALM_DEV_STAGING"
        $ldmExtractdbName="ST_TDM_ODS"
        $ldmExtractServerName="TDC2SQL031"
        $ldmExtractfscsdbName="ST_TDM_FSCS"
        $ldmExtractfscsServerName="TDC2SQL031"
        $CrmiServerName="UDC2SQL001"
        $CrmidbName="P2_CRMICurrent"
        $SSISEnvironmentName="ONESUMX_DEV"
        $SSISFolderName="ONESUMX"
        $SSISProjectName="OneSumX"
        $AutomationLocation="\\ddc2app009\Automation\"
        $MaestroExportLocation="D:/Temp"
        $OneSumXForRiskDB="ALM_DEV_RP"
        $RPDataRetentionMonths="36"
        $jdbc_connectionstring="jdbc:sqlserver://%SQL_SERVER%.test.closebrothers.com:60896;databaseName=%DATABASE%;integratedSecurity=true;"
        $jtds_connectionstring="jdbc:sqlserver://%SQL_SERVER%.test.closebrothers.com:60896;databaseName=%DATABASE%;integratedSecurity=true;"
        $OneSumXFSname="ALM_DEV2_OneSumXFS"
        $ADGROUPPERMDALMFinancial="CN=PERM-D-ALMFinancial-DEV,OU=ALM,OU=Application,OU=Groups,OU=CloseBrothers,DC=test,DC=closebrothers,DC=com"
        $ADGROUPPERMDALMOperations="CN=PERM-D-ALMOperations-DEV,OU=ALM,OU=Application,OU=Groups,OU=CloseBrothers,DC=test,DC=closebrothers,DC=com"
        $ADGROUPPERMDALMManager="CN=PERM-D-ALMManager-DEV,OU=ALM,OU=Application,OU=Groups,OU=CloseBrothers,DC=test,DC=closebrothers,DC=com"
        $ADGROUPPERMDALMOneSumXAdmins="CN=PERM-D-ALM-OneSumX.DEV-Admins,OU=ALM,OU=Treasury,OU=Application,OU=Groups,OU=CloseBrothers,DC=test,DC=closebrothers,DC=com"
        break
	}
	"TST" {
		$dbServer="TDC2SQL031"
		$dbInstance="\ALM"
		$ApplicationServer="tdc2app030"
		$dbName="ALM_TST_OneSumXFS_fsdb"
        $SQLAgentServiceAccount="TEST\zSvcTDC2SQL031ALMAGT"
        $StagingdbName="ALM_TST_STAGING"
        $ldmExtractdbName="ST_TDM_ODS"
        $ldmExtractServerName="TDC2SQL031"
        $ldmExtractfscsdbName="ST_TDM_FSCS"
        $ldmExtractfscsServerName="TDC2SQL031"
        $CrmiServerName="UDC2SQL001"
        $CrmidbName="P2_CRMICurrent"
        $SSISEnvironmentName="ONESUMX"
        $SSISFolderName="ALM_TST_ONESUMX"
        $SSISProjectName="OneSumX"
        $AutomationLocation="\\TDC2APP030\Automation\"
        $MaestroExportLocation="D:/Temp"
        $OneSumXForRiskDB="ALM_TST_RP"
        $RPDataRetentionMonths="36"
        $jdbc_connectionstring="jdbc:sqlserver://%SQL_SERVER%.test.closebrothers.com:60896;databaseName=%DATABASE%;integratedSecurity=true;"
        $jtds_connectionstring="jdbc:sqlserver://%SQL_SERVER%.test.closebrothers.com:60896;databaseName=%DATABASE%;integratedSecurity=true;"
        $OneSumXFSname="ALM_TST_OneSumXFS"
        $ADGROUPPERMDALMFinancial="CN=PERM-D-ALMFinancial-TST,OU=ALM,OU=Application,OU=Groups,OU=CloseBrothers,DC=test,DC=closebrothers,DC=com"
        $ADGROUPPERMDALMOperations="CN=PERM-D-ALMOperations-TST,OU=ALM,OU=Application,OU=Groups,OU=CloseBrothers,DC=test,DC=closebrothers,DC=com"
        $ADGROUPPERMDALMManager="CN=PERM-D-ALMManager-TST,OU=TST,OU=Application,OU=Groups,OU=CloseBrothers,DC=test,DC=closebrothers,DC=com"
        $ADGROUPPERMDALMOneSumXAdmins="CN=PERM-D-ALM-OneSumX.TST-Admins,OU=ALM,OU=Treasury,OU=Application,OU=Groups,OU=CloseBrothers,DC=test,DC=closebrothers,DC=com"
        break
	}
    "SIT" {
		$dbServer="TDC2SQL031"
		$dbInstance="\ALM"
		$ApplicationServer="tdc2app033"
		$dbName="ALM_SIT_OneSumXFS_fsdb"
        $SQLAgentServiceAccount="TEST\zSvcTDC2SQL031ALMAGT"
        $StagingdbName="ALM_SIT_STAGING"
        $ldmExtractdbName="ST_TDM_ODS"
        $ldmExtractServerName="TDC2SQL031"
        $ldmExtractfscsdbName="ST_TDM_FSCS"
        $ldmExtractfscsServerName="TDC2SQL031"
        $CrmiServerName="UDC2SQL001"
        $CrmidbName="P2_CRMICurrent"
        $SSISEnvironmentName="ALM_SIT_STAGING"
        $SSISFolderName="ALM_SIT_STAGING"
        $SSISProjectName="Staging-ETL"
        $AutomationLocation="\\TDC2APP033\Automation\"
        $MaestroExportLocation="D:/Temp"
        $OneSumXForRiskDB="ALM_SIT_RP"
        $RPDataRetentionMonths="36"
        $jdbc_connectionstring="jdbc:sqlserver://%SQL_SERVER%.test.closebrothers.com:60896;databaseName=%DATABASE%;integratedSecurity=true;"
        $jtds_connectionstring="jdbc:sqlserver://%SQL_SERVER%.test.closebrothers.com:60896;databaseName=%DATABASE%;integratedSecurity=true;"
        $OneSumXFSname="ALM_SIT_OneSumXFS"
        $ADGROUPPERMDALMFinancial="CN=PERM-D-ALMFinancial-SIT,OU=ALM,OU=Application,OU=Groups,OU=CloseBrothers,DC=test,DC=closebrothers,DC=com"
        $ADGROUPPERMDALMOperations="CN=PERM-D-ALMOperations-SIT,OU=ALM,OU=Application,OU=Groups,OU=CloseBrothers,DC=test,DC=closebrothers,DC=com"
        $ADGROUPPERMDALMManager="CN=PERM-D-ALMManager-SIT,OU=ALM,OU=Application,OU=Groups,OU=CloseBrothers,DC=test,DC=closebrothers,DC=com"
        $ADGROUPPERMDALMOneSumXAdmins="CN=PERM-D-ALM-OneSumX.SIT-Admins,OU=ALM,OU=Treasury,OU=Application,OU=Groups,OU=CloseBrothers,DC=test,DC=closebrothers,DC=com"
        break
	}
    "UAT" {
		$dbServer="RDC1SQL011"
		$dbInstance=""
		$ApplicationServer="udc1app014"
		$dbName="ALM_UAT_OneSumXFS_fsdb"
        $SQLAgentServiceAccount="TEST\zSvcDC1SQL011ALMAGT"
        $StagingdbName="ALM_UAT_STAGING"
        $ldmExtractdbName="TDM_ODS"
        $ldmExtractServerName="UDC1SQL003"
        $ldmExtractfscsdbName="TDM_FSCS"
        $ldmExtractfscsServerName="UDC1SQL003"
        $CrmiServerName="UDC2SQL001"
        $CrmidbName="P2_CRMICurrent"
        $SSISEnvironmentName="ALM_UAT_ONESUMX"
        $SSISFolderName="ALM_UAT_ONESUMX"
        $SSISProjectName="Staging-ETL"
        $AutomationLocation="\\UDC1APP014\Automation\"
        $MaestroExportLocation="D:/Temp"
        $OneSumXForRiskDB="ALM_UAT_RP"
        $RPDataRetentionMonths="36"
        $jdbc_connectionstring="jdbc:sqlserver://%SQL_SERVER%.closebrothers.com:60896;databaseName=%DATABASE%;integratedSecurity=true;"
        $jtds_connectionstring="jdbc:sqlserver://%SQL_SERVER%.closebrothers.com:60896;databaseName=%DATABASE%;integratedSecurity=true;"
        $OneSumXFSname="ALM_UAT_OneSumXFS"
        $ADGROUPPERMDALMFinancial="CN=PERM-D-ALMFinancial-UAT,OU=ALM,OU=Application,OU=Groups,OU=CloseBrothers,DC=closebrothers,DC=com"
        $ADGROUPPERMDALMOperations="CN=PERM-D-ALMOperations-UAT,OU=ALM,OU=Application,OU=Groups,OU=CloseBrothers,DC=closebrothers,DC=com"
        $ADGROUPPERMDALMManager="CN=PERM-D-ALMManager-UAT,OU=ALM,OU=Application,OU=Groups,OU=CloseBrothers,DC=closebrothers,DC=com"
        $ADGROUPPERMDALMOneSumXAdmins="CN=PERM-D-ALM-OneSumX.UAT-Admins,OU=ALM,OU=Treasury,OU=Application,OU=Groups,OU=CloseBrothers,DC=closebrothers,DC=com"
        break
	}
    "PP" {
		$dbServer="RDC1SQL011"
		$dbInstance=""
		$ApplicationServer="rdc1app014"
		$dbName="ALM_PRE_OneSumXFS_fsdb"
        $SQLAgentServiceAccount="CLOSEBROTHERSGB\SvcRDC1SQL011ALMAGT"
        $StagingdbName="ALM_PRE_STAGING"
        $ldmExtractdbName="TDM_ODS"
        $ldmExtractServerName="RDC1SQL009"
        $ldmExtractfscsdbName="TDM_FSCS"
        $ldmExtractfscsServerName="RDC1SQL009"
        $CrmiServerName="?"
        $CrmidbName="?"
        $SSISEnvironmentName="ALM_PRE_ONESUMX"
        $SSISFolderName="ALM_PRE_ONESUMX"
        $SSISProjectName="Staging-ETL"
        $AutomationLocation="\\RDC1APP014\Automation\"
        $MaestroExportLocation="D:/Temp"
        $OneSumXForRiskDB="ALM_PRE_RP"
        $RPDataRetentionMonths="36"
        $jdbc_connectionstring="jdbc:sqlserver://%SQL_SERVER%.closebrothers.com:60896;databaseName=%DATABASE%;integratedSecurity=true;"
        $jtds_connectionstring="jdbc:sqlserver://%SQL_SERVER%.closebrothers.com:60896;databaseName=%DATABASE%;integratedSecurity=true;"
        $OneSumXFSname="ALM_PRE_OneSumXFS"
        $ADGROUPPERMDALMFinancial="CN=PERM-D-ALMFinancial-PRE,OU=ALM,OU=Application,OU=Groups,OU=CloseBrothers,DC=closebrothers,DC=com"
        $ADGROUPPERMDALMOperations="CN=PERM-D-ALMOperations-PRE,OU=ALM,OU=Application,OU=Groups,OU=CloseBrothers,DC=closebrothers,DC=com"
        $ADGROUPPERMDALMManager="CN=PERM-D-ALMManager-PRE,OU=ALM,OU=Application,OU=Groups,OU=CloseBrothers,DC=closebrothers,DC=com"
        $ADGROUPPERMDALMOneSumXAdmins="CN=PERM-D-ALM-OneSumX.PRE-Admins,OU=ALM,OU=Treasury,OU=Application,OU=Groups,OU=CloseBrothers,DC=closebrothers,DC=com"
        break
	}
    "PROD" {
		$dbServer="PDC1SQL047"
		$dbInstance=""
		$ApplicationServer="pdc1app048"
		$dbName="ALM_PROD_OneSumXFS_fsdb"
        $SQLAgentServiceAccount="CLOSEBROTHERSGB\SvcPDC1SQL047ALMAGT"
        $StagingdbName="ALM_PROD_STAGING"
        $ldmExtractdbName="TDM_ODS"
        $ldmExtractServerName="PDC1SQL035"
        $ldmExtractfscsdbName="TDM_FSCS"
        $ldmExtractfscsServerName="PDC1SQL035"
        $CrmiServerName="?"
        $CrmidbName="?"
        $SSISEnvironmentName="ALM_PROD_ONESUMX"
        $SSISFolderName="ALM_PROD_ONESUMX"
        $SSISProjectName="Staging-ETL"
        $AutomationLocation="\\PDC1APP048\Automation\"
        $MaestroExportLocation="D:/Temp"
        $OneSumXForRiskDB="ALM_PROD_RP"
        $RPDataRetentionMonths="36"
        $jdbc_connectionstring="jdbc:sqlserver://%SQL_SERVER%.closebrothers.com:60896;databaseName=%DATABASE%;integratedSecurity=true;"
        $jtds_connectionstring="jdbc:sqlserver://%SQL_SERVER%.closebrothers.com:60896;databaseName=%DATABASE%;integratedSecurity=true;"
        $OneSumXFSname="ALM_PROD_OneSumXFS"
        $ADGROUPPERMDALMFinancial="CN=PERM-D-ALMFinancial-PROD,OU=ALM,OU=Application,OU=Groups,OU=CloseBrothers,DC=closebrothers,DC=com"
        $ADGROUPPERMDALMOperations="CN=PERM-D-ALMOperations-PROD,OU=ALM,OU=Application,OU=Groups,OU=CloseBrothers,DC=closebrothers,DC=com"
        $ADGROUPPERMDALMManager="CN=PERM-D-ALMManager-PROD,OU=ALM,OU=Application,OU=Groups,OU=CloseBrothers,DC=closebrothers,DC=com"
        $ADGROUPPERMDALMOneSumXAdmins="CN=PERM-D-ALM-OneSumX.PROD-Admins,OU=ALM,OU=Treasury,OU=Application,OU=Groups,OU=CloseBrothers,DC=closebrothers,DC=com"
        break
	}
    default { 
		Write-Host Unknown Environment: $DeployEnvironment
      exit 1
    }
}

Write-Host Deploying to $DeployEnvironment environment
Write-Host "Using dbName=${dbName} $(Get-Date -format 'u')"
Write-Host "Using dbServer=${dbServer} $(Get-Date -format 'u')"


$original_fileConfigs = '.\Scripts\config_script.sql'
$modified_fileConfigs =  ".\Scripts\config_script_ready.sql"

Write-Host "Running token replacement configurations $(Get-Date -format 'u')"
(get-content $original_fileConfigs) | Foreach-Object {
    $_ -replace '#{environment}', $DeployEnvironment `
       -replace '#{OneSumXFSdbName}', $dbName `
       -replace '#{AppServer}', $ApplicationServer `
       -replace '#{StagingdbName}', $StagingdbName `
       -replace '#{ldmExtractdbName}', $ldmExtractdbName `
       -replace '#{ldmExtractServerName}', $ldmExtractServerName `
       -replace '#{ldmExtractfscsdbName}', $ldmExtractfscsdbName `
       -replace '#{ldmExtractfscsServerName}', $ldmExtractfscsServerName `
       -replace '#{CrmidbName}', $CrmidbName `
       -replace '#{CrmiServerName}', $CrmiServerName `
       -replace '#{SSISEnvironmentName}', $SSISEnvironmentName `
       -replace '#{SSISFolderName}', $SSISFolderName `
       -replace '#{SSISProjectName}', $SSISProjectName `
       -replace '#{AutomationLocation}', $AutomationLocation `
       -replace '#{MaestroExportLocation}', $MaestroExportLocation `
       -replace '#{OneSumXForRiskDB}', $OneSumXForRiskDB `
       -replace '#{RPDataRetentionMonths}', $RPDataRetentionMonths `
       -replace '#{SQLAgentServiceAccount}', $SQLAgentServiceAccount `
       -replace '#{jdbc_connectionstring}', $jdbc_connectionstring `
       -replace '#{jtds_connectionstring}', $jtds_connectionstring `
       -replace '#{OneSumXFSname}', $OneSumXFSname `
       -replace '#{ADGROUPPERMDALMFinancial}', $ADGROUPPERMDALMFinancial `
       -replace '#{ADGROUPPERMDALMOperations}', $ADGROUPPERMDALMOperations `
       -replace '#{ADGROUPPERMDALMManager}', $ADGROUPPERMDALMManager `
       -replace '#{ADGROUPPERMDALMOneSumXAdmins}', $ADGROUPPERMDALMOneSumXAdmins `       
    } | Set-Content $modified_fileConfigs
    
 
Write-Host "Running database update $(Get-Date -format 'u')"
Write-Host "& sqlcmd -S ${dbServer}${dbInstance} -U ${DatabaseUser} -i ${modified_fileConfigs}"
