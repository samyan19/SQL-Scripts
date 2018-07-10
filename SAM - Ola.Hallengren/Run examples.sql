--** DISCLAIMER - add @LogToTable=Y to be sure it gets logged!! **


--=====================================
--Optimize indexes on all user databases
--=====================================


use msdb
go
EXECUTE dbo.IndexOptimize
@Databases = 'USER_DATABASES',
@FragmentationLow = NULL,
@FragmentationMedium = 'INDEX_REORGANIZE,INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE',
@FragmentationHigh = 'INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE',
@FragmentationLevel1 = 10,
@FragmentationLevel2 = 30,
@LogToTable='Y'


--===================================
--Optimize indexes on specific databases
--=====================================
use master
go
EXECUTE dbo.IndexOptimize
@Databases = 'UAT_CIDA_TDM_STD,UAT_CIDA_TDM_Staging,UAT_CIDA_TDM_FSCS,UAT_CIDA_TDM_TDS',
@FragmentationLow = NULL,
@FragmentationMedium = 'INDEX_REORGANIZE,INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE',
@FragmentationHigh = 'INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE',
@FragmentationLevel1 = 10,
@FragmentationLevel2 = 30,
@LogToTable='Y'




--====================
--Optimize indexes excluding tables
--====================

EXECUTE dbo.IndexOptimize
@Databases = 'dbDealing', --USER_DATABASES
@FragmentationLow = NULL,
@FragmentationMedium = 'INDEX_REORGANIZE,INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE',
@FragmentationHigh = 'INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE',
@FragmentationLevel1 = 5,
@FragmentationLevel2 = 30,
@UpdateStatistics = 'ALL',
@OnlyModifiedStatistics = 'Y',
@Indexes = 'ALL_INDEXES,-dbDealing.Logging.ErrorLog,-dbDealing.Logging.ErrorLogOLD,-dbDealing.Logging.LoggingErrorsLastThirtyDays,-dbDealing.Logging.ErrorFilter';



--======================
--update all statistics
--======================

EXECUTE dbo.IndexOptimize
@Databases = 'USER_DATABASES',
@FragmentationLow = NULL,
@FragmentationMedium = NULL,
@FragmentationHigh = NULL,
@UpdateStatistics = 'ALL'




--======================
--Backup Examples
--=======================

--A. Back up all user databases, using checksums and compression; verify the backup; and delete old backup files

EXECUTE dbo.DatabaseBackup
@Databases = 'USER_DATABASES',
@Directory = 'C:\Backup',
@BackupType = 'FULL',
@Verify = 'Y',
@Compress = 'Y',
@CheckSum = 'Y',
@CleanupTime = 24

--B. Back up all user databases to a network share, and verify the backup

EXECUTE dbo.DatabaseBackup
@Databases = 'USER_DATABASES',
@Directory = '\\Server1\Backup',
@BackupType = 'FULL',
@Verify = 'Y'

--C. Back up all user databases across four network shares, and verify the backup

EXECUTE dbo.DatabaseBackup
@Databases = 'USER_DATABASES',
@Directory = '\\Server1\Backup, \\Server2\Backup, \\Server3\Backup, \\Server4\Backup',
@BackupType = 'FULL',
@Verify = 'Y',
@NumberOfFiles = 4

--D.Back up all user databases to 64 files, using checksums and compression and setting the buffer count and the maximum transfer size

EXECUTE dbo.DatabaseBackup
@Databases = 'USER_DATABASES',
@Directory = 'C:\Backup',
@BackupType = 'FULL',
@Compress = 'Y',
@CheckSum = 'Y',
@BufferCount = 50,
@MaxTransferSize = 4194304,
@NumberOfFiles = 64

--E. Back up read/write filegroups of all user databases

EXECUTE dbo.DatabaseBackup
@Databases = 'USER_DATABASES',
@Directory = 'C:\Backup',
@BackupType = 'FULL',
@ReadWriteFileGroups = 'Y'

--F. Back up the transaction log of all user databases, using the option to change the backup type if a log backup cannot be performed

EXECUTE dbo.DatabaseBackup
@Databases = 'USER_DATABASES',
@Directory = 'C:\Backup',
@BackupType = 'LOG',
@ChangeBackupType = 'Y'

--G. Back up all user databases, using compression, encryption, and a server certificate.

EXECUTE dbo.DatabaseBackup @Databases = 'USER_DATABASES',
@Directory = 'C:\Backup',
@BackupType = 'FULL',
@Compress = 'Y',
@Encrypt = 'Y',
@EncryptionAlgorithm = 'AES_256',
@ServerCertificate = 'MyCertificate'

--H. Back up all user databases, using compression, encryption, and LiteSpeed for SQL Server, and limiting the CPU usage to 10 percent

EXECUTE dbo.DatabaseBackup
@Databases = 'USER_DATABASES',
@Directory = 'C:\Backup',
@BackupType = 'FULL',
@BackupSoftware = 'LITESPEED',
@Compress = 'Y',
@Encrypt = 'Y',
@EncryptionAlgorithm = 'AES_256',
@EncryptionKey = 'MyPassword',
@Throttle = 10

--I. Back up all user databases, using compression, encryption, and Red Gate SQL Backup

EXECUTE dbo.DatabaseBackup
@Databases = 'USER_DATABASES',
@Directory = 'C:\Backup',
@BackupType = 'FULL',
@BackupSoftware = 'SQLBACKUP',
@Compress = 'Y',
@Encrypt = 'Y',
@EncryptionAlgorithm = 'AES_256',
@EncryptionKey = 'MyPassword'

--J. Back up all user databases, using compression, encryption, and Idera SQL safe backup

EXECUTE dbo.DatabaseBackup
@Databases = 'USER_DATABASES',
@Directory = 'C:\Backup',
@BackupType = 'FULL',
@BackupSoftware = 'SQLSAFE',
@Compress = 'Y',
@Encrypt = 'Y',
@EncryptionAlgorithm = 'AES_256',
@EncryptionKey = '8tPyzp4i1uF/ydAN1DqevdXDeVoryWRL'
