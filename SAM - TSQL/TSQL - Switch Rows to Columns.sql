/*****
I have a one row table returned from a query that looks something like this

[Date1] [Date2] [Date3] [Date4] [Date5] [Date6]
and I want all the Dates to stack up like this

[Date1]
[Date2]
[Date3]
[Date4]
[Date5]
[Date6]
How would I go about doing this without a bunch of separate queries and union statements? 
I have tried playing around with the PIVOT function but am confused since there is nothing to aggregate the row on.
******/


SELECT Dates
FROM 
    (SELECT * from yourtable) p
UNPIVOT
    (Dates FOR Seq IN 
        ([Date1], [Date2], [Date3], [Date4], [Date5], [Date6])
) AS unpvt