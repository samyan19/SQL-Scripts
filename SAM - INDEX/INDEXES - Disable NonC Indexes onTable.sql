select 'ALTER INDEX ' + I.name + ' ON ' + T.name + ' DISABLE' 
from sys.indexes I
inner join sys.tables T on I.object_id = T.object_id
where I.type_desc = 'NONCLUSTERED'
and I.name is not null
AND t.name='PortfolioAsset'