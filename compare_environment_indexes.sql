create procedure compareEnvironmentIndexes
	@prod_environment	nvarchar(max)
	, @dev_environment	nvarchar(max)
as
begin
	
	-- Create temp tables to store index related data
	create table #dev_indexes	([Table Name] nvarchar(max), [Index Name] nvarchar(max), [Column Name] nvarchar(max), [Index Column] nvarchar(max), [Index Column ID] int, [Index Type] nvarchar(max));
	create table #prod_indexes	([Table Name] nvarchar(max), [Index Name] nvarchar(max), [Column Name] nvarchar(max), [Index Column] nvarchar(max), [Index Column ID] int, [Index Type] nvarchar(max));

	-- Prepare the queries for getting the index data
	declare @getProductionIndexes nvarchar(max) = '
		SELECT st.NAME AS [Table Name]
			, si.NAME AS [Index Name]
			, sc.NAME AS [Column Name]
			, CASE 
				WHEN sic.is_included_column = 1
					THEN ''Included Column''
				ELSE ''Key Column - '' + cast(index_column_id AS VARCHAR(2))
				END AS [Index Column]
			, sic.index_column_id AS [Index Column ID]
			, LEFT(si.type_desc, 1) + LOWER(RIGHT(si.type_desc, LEN(si.type_desc) - 1)) AS [Index Type]
		FROM ' + @prod_environment + '.sys.objects so
		INNER JOIN sys.tables st
			ON so.object_id = st.object_id
		INNER JOIN sys.indexes si
			ON so.object_id = si.object_id
		INNER JOIN sys.index_columns sic
			ON so.object_id = sic.object_id
				AND sic.index_id = si.index_id
		INNER JOIN sys.columns sc
			ON so.object_id = sc.object_id
				AND sc.column_id = sic.column_id';

	declare @getDevelopmentIndexes nvarchar(max) = replace(@getProductionIndexes, @prod_environment, @dev_environment);			-- avoid retyping or explicitly setting the text

	-- Extract index related data from environments
	insert into #prod_indexes ([Table Name], [Index Name], [Column Name], [Index Column], [Index Column ID], [Index Type])
	exec sp_executesql @getProductionIndexes;

	insert into #dev_indexes ([Table Name], [Index Name], [Column Name], [Index Column], [Index Column ID], [Index Type])
	exec sp_executesql @getDevelopmentIndexes;

	-- Compare indexes from Development environment with indexes from production Production and manually identify missing indexes
	select *
	from #dev_indexes
	except
	select *
	from #prod_indexes;

end