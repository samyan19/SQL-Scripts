 /*
 delete rows from table CustomerSales where it does not exist in Customers
 */
 
 DELETE a
             FROM dbo.CustomerSales a
             WHERE NOT EXISTS(
                    SELECT * FROM dbo.Customers b
                    WHERE a.CustomerID = b.CustomerID)
