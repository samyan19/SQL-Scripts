:: Sam Yanzu  -  21/11/2014

sqlio.exe -kW -s30 -frandom -t8 -o8 -b8 -BH -LS -Fparam.txt timeout /T 60 >> "C:\Program Files\SQLIO\out.txt"
sqlio.exe -kW -s30 -frandom -t8 -o8 -b64 -BH -LS -Fparam.txt timeout /T 60 >> "C:\Program Files\SQLIO\out.txt"
sqlio.exe -kW -s30 -frandom -t8 -o8 -b128 -BH -LS -Fparam.txt timeout /T 60 >> "C:\Program Files\SQLIO\out.txt"
sqlio.exe -kW -s30 -frandom -t8 -o8 -b256 -BH -LS -Fparam.txt timeout /T 60 >> "C:\Program Files\SQLIO\out.txt"
sqlio.exe -kW -s30 -fsequential -t8 -o8 -b8 -BH -LS -Fparam.txt timeout /T 60 >> "C:\Program Files\SQLIO\out.txt"
sqlio.exe -kW -s30 -fsequential -t8 -o8 -b64 -BH -LS -Fparam.txt timeout /T 60 >> "C:\Program Files\SQLIO\out.txt"
sqlio.exe -kW -s30 -fsequential -t8 -o8 -b128 -BH -LS -Fparam.txt timeout /T 60 >> "C:\Program Files\SQLIO\out.txt"
sqlio.exe -kW -s30 -fsequential -t8 -o8 -b256 -BH -LS -Fparam.txt timeout /T 60 >> "C:\Program Files\SQLIO\out.txt"
sqlio.exe -kR -s30 -frandom -t8 -o8 -b8 -BH -LS -Fparam.txt timeout /T 60 >> "C:\Program Files\SQLIO\out.txt"
sqlio.exe -kR -s30 -frandom -t8 -o8 -b64 -BH -LS -Fparam.txt timeout /T 60 >> "C:\Program Files\SQLIO\out.txt"
sqlio.exe -kR -s30 -frandom -t8 -o8 -b128 -BH -LS -Fparam.txt timeout /T 60 >> "C:\Program Files\SQLIO\out.txt"
sqlio.exe -kR -s30 -frandom -t8 -o8 -b256 -BH -LS -Fparam.txt timeout /T 60 >> "C:\Program Files\SQLIO\out.txt"
sqlio.exe -kR -s30 -fsequential -t8 -o8 -b8 -BH -LS -Fparam.txt timeout /T 60 >> "C:\Program Files\SQLIO\out.txt"
sqlio.exe -kR -s30 -fsequential -t8 -o8 -b64 -BH -LS -Fparam.txt timeout /T 60 >> "C:\Program Files\SQLIO\out.txt"
sqlio.exe -kR -s30 -fsequential -t8 -o8 -b128 -BH -LS -Fparam.txt timeout /T 60 >> "C:\Program Files\SQLIO\out.txt"
sqlio.exe -kR -s30 -fsequential -t8 -o8 -b256 -BH -LS -Fparam.txt timeout /T 60 >> "C:\Program Files\SQLIO\out.txt"

:: f:\testfile.dat 4 0x0 8000


/*
 
 --Threads (-t) switch the same number as CPUs

 --[Note: Smallest size 8kb, Extent - 64kb]

 --Checkpoint runs - 256Kb writes

 --Eager writes (minimally logged) - 8kb,64kb

 --reads - 8kb, extent reads 64kb, read-ahead-512kb

 --TLOg - 8kb writes


*/