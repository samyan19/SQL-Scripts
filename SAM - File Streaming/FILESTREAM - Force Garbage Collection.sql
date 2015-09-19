/*===============================================

in FULL recovery mode the files will not be marked 
for deletion until a full database backup has occurred

================================================*/

exec sp_filestream_force_garbage_collection