/*
https://snippets.khromov.se/check-if-column-in-mysql-table-has-duplicate-values/
*/

SELECT my_column, COUNT(*) as count
FROM my_table
GROUP BY my_column
HAVING COUNT(*) > 1
