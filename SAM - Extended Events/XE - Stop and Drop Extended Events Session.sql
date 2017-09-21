ALTER EVENT SESSION DB_File_size_Changed 
ON SERVER STATE = START -- START/STOP to start and stop the event session


DROP EVENT SESSION DB_File_size_Changed ON SERVER;
