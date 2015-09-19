USE [msdb];
GO

-- of course you are welcome to use a more friendly name than this;
-- just trying to be consistent with the existing syspolicy objects.

CREATE VIEW dbo.syspolicy_management_facet_execution_modes
AS
    SELECT
        management_facet_id,
        facet_name = name,
        friendly_name = CASE name
            WHEN 'ApplicationRole'              THEN 'Application Role'
            WHEN 'AsymmetricKey'                THEN 'Asymmetric Key'
            WHEN 'AvailabilityDatabase'         THEN 'Availability Database'      -- new in Denali
            WHEN 'AvailabilityGroup'            THEN 'Availability Group'         -- new in Denali
            WHEN 'IAvailabilityGroupState'      THEN 'Availability Group State'   -- new in Denali
            WHEN 'AvailabilityReplica'          THEN 'Availability Replica'       -- new in Denali
            WHEN 'BackupDevice'                 THEN 'Backup Device'
            WHEN 'BrokerPriority'               THEN 'Broker Priority'
            WHEN 'BrokerService'                THEN 'Broker Service'
            WHEN 'CryptographicProvider'        THEN 'Cryptographic Provider'
            WHEN 'DataFile'                     THEN 'Data File'
            WHEN 'DatabaseAuditSpecification'   THEN 'Database Audit Specification'
            WHEN 'DatabaseDdlTrigger'           THEN 'Database DDL Trigger'
            WHEN 'IDatabaseMaintenanceFacet'    THEN 'Database Maintenance'
            WHEN 'IDatabaseOptions'             THEN 'Database Options'
            WHEN 'IDatabasePerformanceFacet'    THEN 'Database Performance'
            WHEN 'DatabaseReplicaState'         THEN 'Database Replica State'     -- new in Denali
            WHEN 'DatabaseRole'                 THEN 'Database Role'
            WHEN 'IDatabaseSecurityFacet'       THEN 'Database Security'
            WHEN 'FileGroup'                    THEN 'Filegroup'
            WHEN 'FullTextCatalog'              THEN 'Full Text Catalog'
            WHEN 'FullTextIndex'                THEN 'Full Text Index'
            WHEN 'FullTextStopList'             THEN 'Full Text Stop List'
            WHEN 'LinkedServer'                 THEN 'Linked Server'
            WHEN 'LogFile'                      THEN 'Log File'
            WHEN 'ILoginOptions'                THEN 'Login Options'
            WHEN 'MessageType'                  THEN 'Message Type'
            WHEN 'IMultipartNameFacet'          THEN 'Multipart Name'
            WHEN 'INameFacet'                   THEN 'Name'
            WHEN 'PartitionFunction'            THEN 'Partition Function'
            WHEN 'PartitionScheme'              THEN 'Partition Scheme'
            WHEN 'PlanGuide'                    THEN 'Plan Guide'
            WHEN 'RemoteServiceBinding'         THEN 'Remote Service Binding'
            WHEN 'ResourceGovernor'             THEN 'Resource Governor'
            WHEN 'ResourcePool'                 THEN 'Resource Pool'
            WHEN 'SearchPropertyList'           THEN 'Search Property List'       -- new in Denali
            WHEN 'Sequence'                     THEN 'Sequence'                   -- new in Denali
            WHEN 'IServerAuditFacet'            THEN 'Server Audit'
            WHEN 'ServerAuditSpecification'     THEN 'Server Audit Specification'
            WHEN 'IServerConfigurationFacet'    THEN 'Server Configuration'
            WHEN 'ServerDdlTrigger'             THEN 'Server DDL Trigger'
            WHEN 'IServerInformation'           THEN 'Server Information'
            WHEN 'IServerSetupFacet'            THEN 'Server Installation Settings'
            WHEN 'IServerPerformanceFacet'      THEN 'Server Performance'
            WHEN 'IServerProtocolSettingsFacet' THEN 'Server Protocol Settings'
            WHEN 'ServerRole'                   THEN 'Server Role'                -- new in Denali
            WHEN 'IServerSecurityFacet'         THEN 'Server Security'
            WHEN 'IServerSelectionFacet'        THEN 'Server Selection'
            WHEN 'IServerSettings'              THEN 'Server Settings'
            WHEN 'ServiceContract'              THEN 'Service Contract'
            WHEN 'ServiceQueue'                 THEN 'Service Queue'
            WHEN 'ServiceRoute'                 THEN 'Service Route'
            WHEN 'StoredProcedure'              THEN 'Stored Procedure'
            WHEN 'ISurfaceAreaFacet'            THEN 'Surface Area Configuration'
            WHEN 'ISurfaceAreaConfigurationForAnalysisServer'
                THEN 'Surface Area Configuration For Analysis Services'
            WHEN 'ISurfaceAreaConfigurationForReportingServices'
                THEN 'Surface Area Configuration For Reporting Services'
            WHEN 'SymmetricKey'                 THEN 'Symmetric Key'
            WHEN 'ITableOptions'                THEN 'Table Optioons'
            WHEN 'UserDefinedAggregate'         THEN 'User Defined Aggregate'
            WHEN 'UserDefinedDataType'          THEN 'User Defined Data Type'
            WHEN 'UserDefinedFunction'          THEN 'User Defined Function'
            WHEN 'UserDefinedType'              THEN 'User Defined Type'
            WHEN 'IUserOptions'                 THEN 'User Options'
            WHEN 'UserDefinedTableType'         THEN 'User-Defined Table Type'
            WHEN 'IViewOptions'                 THEN 'View Options'
            WHEN 'WorkloadGroup'                THEN 'Workload Group'
            WHEN 'XmlSchemaCollection'          THEN 'Xml Schema Collection'
            ELSE name
        END,
        On_Demand = 1,
        On_Schedule       = CONVERT(BIT, execution_mode & 4),
        On_Change_Log     = CONVERT(BIT, execution_mode & 2),
        On_Change_Prevent = CONVERT(BIT, execution_mode & 1)
    FROM
        msdb.dbo.syspolicy_management_facets
    WHERE
        -- these do not have corresponding entries in the facet
        -- dropdowns or in Object Explorer, so leave them out:
        name NOT IN
        (
            'Computer',
            'DeployedDac',
            'IDataFilePerformanceFacet',
            'ILogFilePerformanceFacet',
            'Processor',
            'Utility',
            'Volume'
        );
GO

/*
So with that view in place you can run a simple query like this: 
*/


SELECT friendly_name, On_Demand, On_Schedule, On_Change_Log, On_Change_Prevent
    FROM msdb.dbo.syspolicy_management_facet_execution_modes
    ORDER BY friendly_name;

/*
And if you wanted to get only those eligible for, say, "on change : prevent": 
*/


SELECT friendly_name
    FROM msdb.dbo.syspolicy_management_facet_execution_modes
    WHERE On_Change_Prevent = 1
    ORDER BY friendly_name;



Allow triggers to fire others