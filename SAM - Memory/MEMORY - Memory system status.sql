SELECT total_physical_memory_kb / ( 1024.0 * 1024 )     total_physical_memory_gb,
       available_physical_memory_kb / ( 1024.0 * 1024 ) available_physical_memory_gb,
       total_page_file_kb / ( 1024.0 * 1024 )           total_page_file_gb,
       available_page_file_kb / ( 1024.0 * 1024 )       available_page_file_gb,
       system_high_memory_signal_state,
       system_low_memory_signal_state,
       system_memory_state_desc
FROM   sys.dm_os_sys_memory