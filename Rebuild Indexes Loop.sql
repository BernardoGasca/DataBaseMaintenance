
declare @Command varchar (500)
declare @Table varchar(100)
declare @index varchar(100)
declare @Fragmentation int

Declare FragmentedIndexes cursor for 

 SELECT OBJECT_NAME(ind.OBJECT_ID) AS TableName, 
ind.name AS IndexName, 
cast(indexstats.avg_fragmentation_in_percent as int)  as Fragmentation
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, NULL) indexstats 
INNER JOIN sys.indexes ind  
ON ind.object_id = indexstats.object_id 
AND ind.index_id = indexstats.index_id 
WHERE indexstats.avg_fragmentation_in_percent  > 5
ORDER BY indexstats.avg_fragmentation_in_percent DESC

open  FragmentedIndexes
fetch next from  FragmentedIndexes into @Table,@index,@Fragmentation

while (@@FETCH_STATUS=0)
begin
        
		if(@Fragmentation>25)
		begin
				set @Command = 'ALTER INDEX [' + @index + '] ON ['+ @Table + '] REBUILD'
		end
		else 
		begin
		         set @Command = 'ALTER INDEX [' + @index + '] ON ['+ @Table + '] REORGANIZE'       
		end

		print @Command
		EXEC (@Command);
		fetch next from  FragmentedIndexes into @Table,@index,@Fragmentation
end 

close FragmentedIndexes
deallocate FragmentedIndexes


