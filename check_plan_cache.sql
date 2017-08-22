create function tvf_StoredProcedureData (@procedure_name nvarchar(max))
	returns @result table
	(
		[Object Name]								[nvarchar](128)			NULL,
		[Object ID]								[int]				NULL,
		[Procedure time]							[numeric](38, 6)		NULL,
		[rank-execution time]							[bigint]			NULL,
		[rank-logical reads]							[bigint]			NULL,
		[rank-worker (CPU) time]						[bigint]			NULL,
		[rank-logical write]							[bigint]			NULL,
		[SQL_Handle]								[varbinary](64)			NOT NULL,
		[Statement_Start_Offset]						[int]				NOT NULL,
		[Statement_End_Offset]							[int]				NOT NULL,
		[Plan_Generation_Num]							[bigint]			NOT NULL,
		[Plan_Handle]								[varbinary](64)			NOT NULL,
		[Creation_Time]								[datetime]			NOT NULL,
		[Last_Execution_Time]							[datetime]			NOT NULL,
		[Execution_Count]							[bigint]			NOT NULL,
		[Total_Worker_Time - CPU]						[numeric](18, 6)		NULL,
		[Last_Worker_Time - CPU]						[numeric](18, 6)		NULL,
		[Min_Worker_Time - CPU]							[numeric](18, 6)		NULL,
		[Max_Worker_Time - CPU]							[numeric](18, 6)		NULL,
		[Total_Physical_Reads - Disk pages read]				[bigint]			NOT NULL,
		[Last_Physical_Reads - Disk pages read]					[bigint]			NOT NULL,
		[Min_Physical_Reads - Disk pages read]					[bigint]			NOT NULL,
		[Max_Physical_Reads - Disk pages read]					[bigint]			NOT NULL,
		[Total_Logical_Writes - Memory (buffer cache) pages written]		[bigint]			NOT NULL,
		[Last_Logical_Writes - Memory pages written]				[bigint]			NOT NULL,
		[Min_Logical_Writes - Memory pages written]				[bigint]			NOT NULL,
		[Max_Logical_Writes - Memory pages written]				[bigint]			NOT NULL,
		[Total_Logical_Reads - Memory (buffer cache) pages read]		[bigint]			NOT NULL,
		[Last_Logical_Reads - Memory pages read]				[bigint]			NOT NULL,
		[Min_Logical_Reads - Memory pages read]					[bigint]			NOT NULL,
		[Max_Logical_Reads - Memory pages read]					[bigint]			NOT NULL,
		[Total_Elapsed_Time]							[numeric](18, 6)		NULL,
		[Last_Elapsed_Time]							[numeric](18, 6)		NULL,
		[Min_Elapsed_Time]							[numeric](18, 6)		NULL,
		[Max_Elapsed_Time]							[numeric](18, 6)		NULL,
		[Query_Hash]								[binary](8)			NOT NULL,
		[Query_Plan_Hash]							[binary](8)			NOT NULL,
		[Total_Rows - in all executions]					[bigint]			NOT NULL,
		[Last_Rows]								[bigint]			NOT NULL,
		[Min_Rows]								[bigint]			NOT NULL,
		[Max_Rows]								[bigint]			NOT NULL,
		[Filtered text]								[nvarchar](max)			NULL,
		[Temp table]								[nvarchar](max)			NULL,
		[Execution plan]							[xml]				NULL		
	)
as
begin
	insert into @result
	select
		[Object Name]
		, [Object ID]
		, [Procedure time]
		, [rank-execution time]
		, [rank-logical reads]
		, [rank-worker (CPU) time]
		, [rank-logical write]
		, [SQL_Handle]
		, [Statement_Start_Offset]
		, [Statement_End_Offset]
		, [Plan_Generation_Num]
		, [Plan_Handle]
		, [Creation_Time]
		, [Last_Execution_Time]
		, [Execution_Count]
		, [Total_Worker_Time - CPU]
		, [Last_Worker_Time - CPU]
		, [Min_Worker_Time - CPU]
		, [Max_Worker_Time - CPU]
		, [Total_Physical_Reads - Disk pages read]
		, [Last_Physical_Reads - Disk pages read]
		, [Min_Physical_Reads - Disk pages read]
		, [Max_Physical_Reads - Disk pages read]
		, [Total_Logical_Writes - Memory (buffer cache) pages written]
		, [Last_Logical_Writes - Memory pages written]
		, [Min_Logical_Writes - Memory pages written]
		, [Max_Logical_Writes - Memory pages written]
		, [Total_Logical_Reads - Memory (buffer cache) pages read]
		, [Last_Logical_Reads - Memory pages read]
		, [Min_Logical_Reads - Memory pages read]
		, [Max_Logical_Reads - Memory pages read]
		, [Total_Elapsed_Time]
		, [Last_Elapsed_Time]
		, [Min_Elapsed_Time]
		, [Max_Elapsed_Time]
		, [Query_Hash]
		, [Query_Plan_Hash]
		, [Total_Rows - in all executions]
		, [Last_Rows]
		, [Min_Rows]
		, [Max_Rows]
		, [Filtered text]
		, CASE 
			WHEN CHARINDEX('into #', [Filtered text]) > 0 AND (LEN(REPLACE([Filtered text], 'INSERT INTO #', '')) = LEN([Filtered text]))
				THEN
					LTRIM(REPLACE(
						REPLACE(
							SUBSTRING(
								[Filtered text]
								, CHARINDEX('into #', [Filtered text])
								, CHARINDEX(' ', [Filtered text], CHARINDEX('into #', [Filtered text]) + 6) - CHARINDEX('into #', [Filtered text])
								), 'FROM', ''), 'INTO', ''))
				ELSE ''
			END	[Temp table]
		, [Execution plan]
	from
	(select
		sum(cast(qs.last_elapsed_time * 1.0 / power(10,6) as numeric(18,6))) over ()	[Procedure time]
		
		, dense_rank() over (order by qs.last_elapsed_time desc)			[rank-execution time]
		, dense_rank() over (order by qs.last_logical_reads desc)			[rank-logical reads]
		, dense_rank() over (order by qs.last_worker_time desc)				[rank-worker (CPU) time]
		, dense_rank() over (order by qs.last_logical_writes desc)			[rank-logical write]

		, qs.sql_handle																	[SQL_Handle]
		, qs.statement_start_offset														[Statement_Start_Offset]
		, qs.statement_end_offset														[Statement_End_Offset]
		, qs.plan_generation_num														[Plan_Generation_Num]
		, qs.plan_handle																[Plan_Handle]
		, qs.creation_time																[Creation_Time]
		, qs.last_execution_time														[Last_Execution_Time]
		, qs.execution_count															[Execution_Count]

		, cast(qs.total_worker_time * 1.0 / power(10,6) as numeric(18,6))		[Total_Worker_Time - CPU]										-- Total amount of CPU time that was consumed by executions of this plan since it was compiled (in seconds)
		, cast(qs.last_worker_time * 1.0 / power(10,6) as numeric(18,6))		[Last_Worker_Time - CPU]										-- CPU time that was consumed the last time the plan was executed
		, cast(qs.min_worker_time * 1.0 / power(10,6) as numeric(18,6))			[Min_Worker_Time - CPU]											-- CPU time that this plan has ever consumed during a single execution
		, cast(qs.max_worker_time * 1.0 / power(10,6) as numeric(18,6))			[Max_Worker_Time - CPU]											-- Maximum CPU time that this plan has ever consumed during a single execution
		
		, qs.total_physical_reads														[Total_Physical_Reads - Disk pages read]						-- Total number of physical reads performed by executions of this plan since it was compiled - (Will always be 0 querying a memory-optimized table)
		, qs.last_physical_reads														[Last_Physical_Reads - Disk pages read]							-- Number of physical reads performed the last time the plan was executed
		, qs.min_physical_reads															[Min_Physical_Reads - Disk pages read]							-- Minimum number of physical reads that this plan has ever performed during a single execution
		, qs.max_physical_reads															[Max_Physical_Reads - Disk pages read]							-- Maximum number of physical reads that this plan has ever performed during a single execution

		, qs.total_logical_writes														[Total_Logical_Writes - Memory (buffer cache) pages written]	-- Total number of logical writes performed by executions of this plan since it was compiled - (Will always be 0 querying a memory-optimized table)
		, qs.last_logical_writes														[Last_Logical_Writes - Memory pages written]					-- Number of the number of buffer pool pages dirtied the last time the plan was executed. If a page is already dirty (modified) no writes are counted
		, qs.min_logical_writes															[Min_Logical_Writes - Memory pages written]						-- Minimum number of logical writes that this plan has ever performed during a single execution
		, qs.max_logical_writes															[Max_Logical_Writes - Memory pages written]						-- Maximum number of logical writes that this plan has ever performed during a single execution

		-- logical reads are reads of 8k pages that came from memory or from disk
		, qs.total_logical_reads														[Total_Logical_Reads - Memory (buffer cache) pages read]		-- Total number of logical reads performed by executions of this plan since it was compiled - (Will always be 0 querying a memory-optimized table)
		, qs.last_logical_reads															[Last_Logical_Reads - Memory pages read]						-- Number of logical reads performed the last time the plan was executed
		, qs.min_logical_reads															[Min_Logical_Reads - Memory pages read]							-- Minimum number of logical reads that this plan has ever performed during a single execution
		, qs.max_logical_reads															[Max_Logical_Reads - Memory pages read]							-- Maximum number of logical reads that this plan has ever performed during a single execution

		, cast(qs.total_elapsed_time * 1.0 / power(10,6) as numeric(18,6))		[Total_Elapsed_Time]											-- Total elapsed time for completed executions of this plan (in seconds)
		, cast(qs.last_elapsed_time * 1.0 / power(10,6) as numeric(18,6))		[Last_Elapsed_Time]												-- Elapsed time for the most recently completed execution of this plan
		, cast(qs.min_elapsed_time * 1.0 / power(10,6) as numeric(18,6))		[Min_Elapsed_Time]												-- Minimum elapsed time for any completed execution of this plan
		, cast(qs.max_elapsed_time * 1.0 / power(10,6) as numeric(18,6))		[Max_Elapsed_Time]												-- Maximum elapsed time for any completed execution of this plan

		, qs.query_hash																	[Query_Hash]													-- Binary hash value calculated on the query and used to identify queries with similar logic. You can use the query hash to determine the aggregate resource usage for queries that differ only by literal values.
		, qs.query_plan_hash															[Query_Plan_Hash]												-- Binary hash value calculated on the query execution plan and used to identify similar query execution plans - (Will always be 0x000 when a natively compiled stored procedure queries a memory-optimized table)

		, qs.total_rows																	[Total_Rows - in all executions]								-- Total number of rows returned by the query - (Will always be 0 when a natively compiled stored procedure queries a memory-optimized table)
		, qs.last_rows																	[Last_Rows]														-- Number of rows returned by the last execution of the query
		, qs.min_rows																	[Min_Rows]														-- Minimum number of rows returned by the query over the number of times that the plan has been executed since it was last compiled
		, qs.max_rows																	[Max_Rows]														-- Maximum number of rows returned by the query over the number of times that the plan has been executed since it was last compiled

		, substring(st.text, (qs.statement_start_offset/2)+1,
			((case qs.statement_end_offset
				when -1
					then datalength(st.text)
				else
					qs.statement_end_offset
				end - qs.statement_start_offset) / 2 + 1)) as 			[Filtered text]
		, cast(qp.query_plan as xml) 													[Execution plan]
		, qp.query_plan 																[Execution plan - Plan Explorer version]
		, st.objectid																	[Object ID]
		, object_name(st.objectid)														[Object Name]
	from sys.dm_exec_query_stats as qs
		cross apply sys.dm_exec_sql_text (qs.sql_handle) as st
		cross apply sys.dm_exec_text_query_plan (qs.plan_handle, qs.statement_start_offset, qs.statement_end_offset) as qp
	where st.objectid = object_id (@procedure_name)
		) result
	order by [rank-execution time]
		, [rank-logical reads]
		, [rank-logical write] desc
	option (recompile);
	
	return;
end
