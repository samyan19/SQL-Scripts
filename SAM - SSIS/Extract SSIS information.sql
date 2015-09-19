SELECT		p.[name] as [PackageName]
			,[description] as [PackageDescription]
			,case [packagetype]
				when 0 then 'Undefined'
				when 1 then 'SQL Server Import and Export Wizard'
				when 2 then 'DTS Designer in SQL Server 2000'
				when 3 then 'SQL Server Replication'
				when 5 then 'SSIS Designer'
				when 6 then 'Maintenance Plan Designer or Wizard'
			end		as [PackageType]
			,case [packageformat]
				when 0 then 'SSIS 2005 version'
				when 1 then 'SSIS 2008 version'
			end as [PackageFormat]
			,l.[name]	as [Creator]
			,p.[createdate]
			,CAST(CAST(packagedata AS VARBINARY(MAX)) AS XML) PackageXML
          FROM      [msdb].[dbo].[sysssispackages]		p
          JOIN		sys.syslogins						l
          ON		p.[ownersid] = l.[sid]