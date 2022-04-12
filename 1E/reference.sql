
select
  PT.tariff_id,
  tariff_name = '['+convert(varchar(4),PT.tariff_id)+'] '+PT.tariff_name,
  group_name = case when S.row_id is null then ''
                    else '['+convert(varchar(4),S.row_id)+'] ' +isnull(S.row_number,'')+' '+S.row_name end,
  S.row_id  
from ProTariffs PT (nolock)
     left outer join
     SOURCE_1E  S  (nolock)
on      
  s.list_codes like '% '+convert(varchar(3),PT.tariff_id)+',%'
order by PT.tariff_id

/*
declare
  @list_codes varchar(8000),
  @tmp        varchar(255),
  @i          int 

declare curSOURCE_1E cursor for
  select list_codes
  from SOURCE_1E
  where list_codes is not null

select @list_codes = '',
       @tmp        = ''
 
open curSOURCE_1E
fetch next from curSOURCE_1E into @tmp
while (@@fetch_status <> -1)
  begin
    select
    @list_codes = @list_codes + @tmp
    fetch next from curSOURCE_1E into @tmp
  end
close curSOURCE_1E
deallocate curSOURCE_1E


create table #Tmp1(tarif_id int)

select @i = 0
while @i <= 1000
  begin
  if @list_codes like '% '+convert(varchar(4),@i)+',%' 
    insert into #Tmp1(tarif_id) values (@i)
  select @i=@i+1
  end

select * from #Tmp1
where tarif_id not in (select tariff_id from ProTariffs)


drop table #Tmp1
*/
--select *
--sum(list_codes)
-- from SOURCE_1E