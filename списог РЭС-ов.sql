if exists (select * from tempdb..sysobjects where id = object_id('tempdb..#TmpRes'))
begin
drop table #TmpRes
end
go

create table #TmpRes
(
subgroup_res tinyint not null,
res_name     varchar(20) not null
)

insert into #TmpRes
(
subgroup_res,
res_name
)
select 
distinct subgroup_res,
res_name = 'ÐÝÑ-'+ convert(varchar(2),subgroup_res)
from aspElectric..GroupSub
where subgroup_res is not null

insert into #TmpRes
(
subgroup_res,
res_name
)
values
(0,'ÃÝÐÑ')

select
subgroup_res,
res_name
from #TmpRes
order by subgroup_res

drop table #TmpRes
