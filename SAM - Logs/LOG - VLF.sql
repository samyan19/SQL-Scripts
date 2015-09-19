/*========================================

	VLF's
	------------------------------
	* AutoGrowth increments
	<64MB	4 VLFs
	64MB - 1GB	8 VLFs
	>1GB 16 VLF

	* Do not exceed 512 MB per VLF
	* # VLF - Do not exceed 100
	------------------------------

=========================================*/


use TESTCHIKKY
GO
DBCC loginfo
