/*
ROBOCOPY EXAMPLES

source: http://social.technet.microsoft.com/wiki/contents/articles/1073.robocopy-and-a-few-examples.aspx

MAIN EG: Robocopy X:\MSSQL\RCSTSQL56\10.50\00_RCSTSQL56\BACKUPS\FULL_PRESERVE \\na02\sql_backup_sql56\BACKUPS\FULL_PRESERVE /MIR


#1
To copy contents of C:\UserFolder to C:\FolderBackup:
         Robocopy C:\UserFolder C:\FolderBackup
This is the simplest usage for Robocopy

#2
To copy all contents including empty directories of SourceFolder to DestinationFolder:
Robocopy C:\SourceDir C:\DestDir /E

#3
List only files larger than 32 MBytes(33553332 bytes) in size.
            Robocopy.exe c:\sourceFolder d:\targetfolder /min:33553332 /l
List only files less than 32 MBytes(33553332 bytes) in size.
          Robocopy.exe c:\sourceFolder d:\targetfolder /max:33553332 /l
Note: /l - will list files matching the criteria. if /l is omitted, files matching the criteria will be copied to the taget location

#4
Move files over 14 days old (note the MOVE option will fail if any files are open and locked).
ROBOCOPY C:\SourceFoldern D:\DestinationFolder /move /minage:14
Similarly you could use the below switches
/maxage: <N>     Specifies the maximum file age (to exclude files older than N days or date).
/minage: <N>      Specifies the minimum file age (exclude files newer than N days or date).
/maxlad: <N>      Specifies the maximum last access date (excludes files unused since N).
/minlad: <N>       Specifies the minimum last access date (excludes files used since N) If N is less than 1900, N specifies the number of days. Otherwise, N specifies a date in the format YYYYMMDD

#5
/MIR is an option to ROBOCOPY where you mirror a directory tree with all the subfolders including the empty directories and you purge files and folders on the destination server that no longer exists in source.
ROBOCOPY \\sourceserver\share \\destinationserver\share /MIR
Or
ROBOCOPY source-drive:\DIR destination-drive:\DIR /MIR

#6
The following command will mirror the directories using Robocopy:
Robocopy \\SourceServer\Share \\DestinationServer\Share /MIR /FFT /Z /XA:H /W:5
 /MIR specifies that Robocopy should mirror the source directory and the destination directory. Note that this will delete files at the destination if they were deleted at the source.
/FFT uses fat file timing instead of NTFS. This means the granularity is a bit less precise. For across-network share operations this seems to be much more reliable - just don't rely on the file timings to be completely precise to the second.
/Z ensures Robocopy can resume the transfer of a large file in mid-file instead of restarting.
/XA:H makes Robocopy ignore hidden files, usually these will be system files that we're not interested in.
/W:5 reduces the wait time between failures to 5 seconds instead of the 30 second default.

#7
Use Robocopy to copy all changes to files in a directory called c:\data to a directory that contains the date, like data_20091124.  Create a batch file as follows.
@echo off
set day=%date:~0,2%
set month=%date:~3,2%
set year=%date:~6,4%
Robocopy "c:\data" "c:\backup\data\%day%-%month%-%year%\" /MAXAGE:1

#8
To mirror the directory "C:\directory" to "\\server2\directory" excluding \\server2\directory\dir2" from being deleted (since it isn't present in C:\directory) use the following command:
Robocopy "C:\Folder" "\\Machine2\Folder" /MIR /XD  \\server2\ directory\dir2"
Robocopy can be setup as a simply Scheduled Task that runs daily, hourly, weekly etc. Note that Robocopy also contains a switch that will make Robocopy monitor the source for changes and invoke synchronization each time a configurable number of changes has been made. This may work in your scenario, but be aware that Robocopy will not just copy the changes, it will scan the complete directory structure just like a normal mirroring procedure. If there are a lot of files & directories, this may hamper performance.

#9
You have copied the contents from source to destination but now you made changes to the Security permissions at source. You wanted to copy only the permission changes and not data.

ROBOCOPY <Source> <Target> /E /Copy:S /IS /IT

Copy option have the following flags to use:
D     Data 
A     Attributes 
T     Time stamps
S     NTFS access control list (ACL)
O    Owner information
U     Auditing information
The default value for CopyFlags is DAT (data, attributes, and time stamps).
/IS - Includes the same files.
/IT - Includes "tweaked" files.

Sidenote: ROBOCOPY  c:\sourcefolder d:\targetfolder /zb /sec /e /nocopy may give you similar results but useful ONLY when more permissions are added. it will not consider or update the target for permissions removed at the source.

See How to Copy Files Multi-Threaded with Robocopy in Windows 7 This link is external to TechNet Wiki. It will open in a new window. .

Robocopy, short for Robust File Copy, is a command-line directory replication and file copy command utility that was first made available as feature in Windows Vista and Windows Server 2008, although it has been available as part of Windows Resources Kit. In Windows 7 and Windows Server 2008, Robocopy utility is further enhanced with ability to multi-threaded copy operation feature.

Multi-threaded support allows Robocopy to open multiple threads simultaneously, allowing many files to be copied in parallel. With multi-threaded copying, total time required to complete the operation will be drastically reduced and cut, when comparing with with typical copying one file at time in serial sequential order.

As Robocopy is generally a command-line only utility (although a GUI add-on is available for Robocopy), the new multi-threaded operation capability has to be called via a new switch supported by Robocopy. The new multi-threaded copy feature can be enabled and turned on with the following parameter:
/MT[:n]
Where n will instruct Robocopy to do multi-threaded copies with n threads (default 8). The value of n must be at least 1 and not greater than 128 (between 1 to 128), with 1 as single thread. In fact, Robocopy will copy files and folders in multi-threaded operation by default, with 8 threads in one go. Note that /MT[:n] switch is not compatible with the /IPG and /EFSRAW operations.

For example,
Robocopy C:\Folder1 C:\Folder2 /MT:32

#10
To copy a directory tree along with the source timestamps for folders
Robocopy C:\Folder1 C:\Folder2 /MIR /dcopy:T

#11
To copy a directory using /IPG to limit bandwidth usage. General rule of thumb /IPG:750 will use roughly 1Mbps. 

Robocopy /ipg:750 /z /r:3 /w:3 /tee /LOG+:c:\robolog.txt //server1/share //server2/share

*/