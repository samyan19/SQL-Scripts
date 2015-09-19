/*
	Do we have any duplicate indexes?  This query from Adam Machanic checks for
	indexes on exactly the same fields.  You have to run it in each database
	you want to check, and it's extremely fast.
*/
select 
    t.name as tableName,
    p.*
from sys.tables as t
inner join sys.indexes as i1 on
    i1.object_id = t.object_id
cross apply
(
    select top 1
        *
    from sys.indexes as i
    where
        i.object_id = i1.object_id
        and i.index_id > i1.index_id
        and i.type_desc <> 'xml'
    order by
        i.index_id
) as i2 
cross apply
(
    select
        min(a.index_id) as ind1,
        min(b.index_id) as ind2
    from 
    (
        select ic.*
        from sys.index_columns ic
        where
            ic.object_id =  i1.object_id
            and ic.index_id = i1.index_id
            and ic.is_included_column = 0
    ) as a
    full outer join
    (
        select *
        from sys.index_columns as ic
        where
            ic.object_id =  i2.object_id
            and ic.index_id = i2.index_id
            and ic.is_included_column = 0
    ) as b on
        a.index_column_id = b.index_column_id
        and a.column_id = b.column_id
        and a.key_ordinal = b.key_ordinal
    having
        count(case when a.index_id is null then 1 end) = 0
        and count(case when b.index_id is null then 1 end) = 0
        and count(a.index_id) = count(b.index_id)
) as p
where
    i1.type_desc <> 'xml'