USE AdventureworksDW
GO


--Min och maxvärde för varje segment, etc
CREATE OR ALTER PROC GetSegmentAlignment 
@tablename sysname, @columnname sysname = '%'
AS
SELECT
-- OBJECT_NAME(i.object_id) AS TableName
--,i.name AS IndexName
--,i.type_desc AS IndexType
 COL_NAME(ic.object_id, ic.column_id) as ColumnName
--,p.partition_number
,s.segment_id
,s.min_data_id
,s.max_data_id
,s.row_count
,s.on_disk_size
FROM sys.column_store_segments AS s
INNER JOIN sys.partitions AS p ON p.hobt_id = s.hobt_id
INNER JOIN sys.indexes AS i ON   i.object_id = p.object_id AND  i.index_id = p.index_id
LEFT  JOIN sys.index_columns AS ic ON ic.object_id = i.object_id AND  ic.index_id = i.index_id AND  ic.index_column_id = s.column_id
WHERE OBJECT_NAME(p.object_id) = @tablename
AND COL_NAME(ic.object_id, ic.column_id) LIKE @columnname
AND ic.column_id IS NOT NULL
ORDER BY   --TableName, IndexName,
           s.column_id, p.partition_number, s.segment_id
GO

/* Exempel på anrop
EXEC GetSegmentAlignment 'FactResellerSalesXL_CCI'
*/
