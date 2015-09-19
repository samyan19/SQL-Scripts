CREATE EVENT NOTIFICATION data_file_autogrow_notifier
ON DATABASE
FOR DATA_FILE_AUTO_GROW
TO SERVICE 'NotifyAutogrow', 'current database' ;
or for the log file:

CREATE EVENT NOTIFICATION log_file_autogrow_notifier
ON DATABASE
FOR LOG_FILE_AUTO_GROW
TO SERVICE 'NotifyAutogrow', 'current database' ;