/*========================================
Certificate created without password will default to encrypt by DMK

If database is not encrypted by SMK then password will be required to open DMK

If database is encrypted by SMK then opening DMK not required
==========================================*/

open master key
decryption by password = 'password'

--do something

close master key;