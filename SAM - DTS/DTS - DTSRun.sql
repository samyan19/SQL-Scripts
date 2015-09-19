/********************************

command to run a dts package

**********************************/


DTSrun /S euoxf-sqgn001p /E /N LoadSMEAccountManagerDetails



/**********************************

command to deploy a dtsx package

***********************************/



dtutil /file "c:\packages\SSIS_BGSQA_OldTables_To_TAMI.dtsx" /encrypt sql;"QAMS\SSIS_BGSQA_OldTables_To_TAMI";5 /destserver cnwp0222 /quiet