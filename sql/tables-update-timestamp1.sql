
SELECT OBJECT_NAME(OBJECT_ID) AS DatabaseName, last_user_update,*
FROM sys.dm_db_index_usage_stats
WHERE database_id = DB_ID( 'equity7uat')
--AND OBJECT_ID=OBJECT_ID('ca_trans')
order by 2 desc 



select * from INV_AppRuntime  --19
select * from INV_APP -- 8 