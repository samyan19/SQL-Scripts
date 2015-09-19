/*

This is if you want take a part of a string and make into another column

Example - sp_whoisactive wait_info column

(4ms)HADR_CLUSAPI_CALL
to 
HADR_CLUSAPI_CALL

Remove the text after the ')' to make a seperate column

http://basitaalishan.com/2014/02/23/removing-part-of-string-before-and-after-specific-character-using-transact-sql-string-functions/

*/


/*
* wait_info=name of the column
* )=delimiting character
*/

REPLACE(SUBSTRING([wait_info], CHARINDEX(')', [wait_info]), LEN([wait_info])), ')', '')

