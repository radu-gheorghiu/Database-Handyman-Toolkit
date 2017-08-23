create view vLockingSessions as
select 
	s_tst.session_id
	, s_es.login_name						as [Login Name]
	, db_name(s_tdt.database_id)					as [Database Name]
	, s_tdt.database_transaction_begin_time				as [Begin Time]
	, s_tdt.database_transaction_log_bytes_used			as [Log Bytes Used]
	, s_tdt.database_transaction_log_bytes_reserved			as [Log Bytes Reserved]
	, s_est.text							as [T-SQL query]
	, s_eqp.query_plan						as [Execution Plan]
from sys.dm_tran_database_transactions s_tdt
	inner join sys.dm_tran_session_transactions s_tst
		on s_tdt.transaction_id = s_tst.transaction_id
	inner join sys.dm_exec_sessions s_es
		on s_es.session_id = s_tst.session_id
	inner join sys.dm_exec_connections s_ec
		on s_ec.session_id = s_tst.session_id
	left join sys.dm_exec_requests s_er
		on s_er.session_id = s_tst.session_id
	cross apply sys.dm_exec_sql_text (s_ec.most_recent_sql_handle) as s_est
	outer apply sys.dm_exec_query_plan (s_er.plan_handle) as s_eqp;
