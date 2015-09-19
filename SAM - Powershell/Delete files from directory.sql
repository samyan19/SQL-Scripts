/*


dir E:\backups\test\*.bak |? {$_.LastWriteTime -lt (get-date).AddDays(-14)} | del




*/