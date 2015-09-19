CREATE DATABASE PhotoLibrary
 ON PRIMARY
  (NAME = PhotoLibrary_data, 
   FILENAME = 'C:\Demo\PhotoLibrary\PhotoLibrary_data.mdf'),
 FILEGROUP FileStreamGroup1 CONTAINS FILESTREAM
  (NAME = PhotoLibrary_group2, 
   FILENAME = 'C:\Demo\PhotoLibrary\Photos')
 LOG ON 
  (NAME = PhotoLibrary_log,
   FILENAME = 'C:\Demo\PhotoLibrary\PhotoLibrary_log.ldf')
GO