A. Back up all user databases, using checksums and compression; verify the backup; and delete old backup files

EXECUTE dbo.DatabaseBackup
@Databases = 'USER_DATABASES',
@Directory = 'C:\Backup',
@BackupType = 'FULL',
@Verify = 'Y',
@Compress = 'Y',
@CheckSum = 'Y',
@CleanupTime = 24

B. Back up all user databases to a network share, and verify the backup

EXECUTE dbo.DatabaseBackup
@Databases = 'USER_DATABASES',
@Directory = '\\Server1\Backup',
@BackupType = 'FULL',
@Verify = 'Y'

C. Back up all user databases across four network shares, and verify the backup

EXECUTE dbo.DatabaseBackup
@Databases = 'USER_DATABASES',
@Directory = '\\Server1\Backup, \\Server2\Backup, \\Server3\Backup, \\Server4\Backup',
@BackupType = 'FULL',
@Verify = 'Y',
@NumberOfFiles = 4

D. Back up all user databases to 64 files, using checksums and compression and setting the buffer count and the maximum transfer size

EXECUTE dbo.DatabaseBackup
@Databases = 'USER_DATABASES',
@Directory = 'C:\Backup',
@BackupType = 'FULL',
@Compress = 'Y',
@CheckSum = 'Y',
@BufferCount = 50,
@MaxTransferSize = 4194304,
@NumberOfFiles = 64

E. Back up all user databases to Azure Blob Storage, using compression

EXECUTE dbo.DatabaseBackup
@Databases = 'USER_DATABASES',
@URL = 'https://myaccount.blob.core.windows.net/mycontainer',
@Credential = 'MyCredential',
@BackupType = 'FULL',
@Compress = 'Y',
@Verify = 'Y'

F. Back up the transaction log of all user databases, using the option to change the backup type if a log backup cannot be performed

EXECUTE dbo.DatabaseBackup
@Databases = 'USER_DATABASES',
@Directory = 'C:\Backup',
@BackupType = 'LOG',
@ChangeBackupType = 'Y'

G. Back up all user databases, using compression, encryption, and a server certificate.

EXECUTE dbo.DatabaseBackup @Databases = 'USER_DATABASES',
@Directory = 'C:\Backup',
@BackupType = 'FULL',
@Compress = 'Y',
@Encrypt = 'Y',
@EncryptionAlgorithm = 'AES_256',
@ServerCertificate = 'MyCertificate'

H. Back up all user databases, using compression, encryption, and LiteSpeed for SQL Server, and limiting the CPU usage to 10 percent

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

I. Back up all user databases, using compression, encryption, and Red Gate SQL Backup Pro

EXECUTE dbo.DatabaseBackup
@Databases = 'USER_DATABASES',
@Directory = 'C:\Backup',
@BackupType = 'FULL',
@BackupSoftware = 'SQLBACKUP',
@Compress = 'Y',
@Encrypt = 'Y',
@EncryptionAlgorithm = 'AES_256',
@EncryptionKey = 'MyPassword'

J. Back up all user databases, using compression, encryption, and Idera SQL Safe Backup

EXECUTE dbo.DatabaseBackup
@Databases = 'USER_DATABASES',
@Directory = 'C:\Backup',
@BackupType = 'FULL',
@BackupSoftware = 'SQLSAFE',
@Compress = 'Y',
@Encrypt = 'Y',
@EncryptionAlgorithm = 'AES_256',
@EncryptionKey = '8tPyzp4i1uF/ydAN1DqevdXDeVoryWRL'
