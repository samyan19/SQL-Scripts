--Find Compressed Tables

SELECT st.name, st.object_id, sp.partition_id, sp.partition_number, sp.data_compression,
sp.data_compression_desc, SP.index_id FROM sys.partitions SP
INNER JOIN sys.tables ST ON
st.object_id = sp.object_id
WHERE data_compression <> 0

--Find Compressed Indexes

SELECT distinct st.name, st.object_id, sp.data_compression_desc FROM sys.partitions SP
INNER JOIN sys.indexes ST ON
ST.object_id = SP.object_id
WHERE data_compression <> 0 and ST.type_desc != 'HEAP'
