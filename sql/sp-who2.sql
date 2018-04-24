
create table #wh2
(SPID	int , [Status] varchar(200),	[Login] varchar(100), 	HostName varchar(300),
BlkBy varchar(300), 	DBName varchar(100) , 
Command varchar(4000),	CPUTime numeric(15,2),
DiskIO int,	LastBatch varchar(100),	ProgramName	 varchar(2000) , [SPID1] int , 	REQUESTID int
)

insert into #wh2
exec sp_who2


select * from #wh2  
where dbname like '%equity7test%'
order by cputime desc

--kill 74
--
 drop table #wh2

 kill 221
kill 269
kill 271
kill 97