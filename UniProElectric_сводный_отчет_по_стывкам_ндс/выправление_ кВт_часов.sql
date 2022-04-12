--      платежи = сальдо на начало - сальдо на конец + начисления 
declare
  @dtCurEnd            datetime
 ,@dtPreEnd           datetime
select
  @dtCurEnd  = '2004-03-31'
 ,@dtPreEnd =   dateadd(dd,-1,dateadd(mm,-1,Dateadd(dd,+1,@dtCurEnd)))
----------------------------------------------------------------------------------
/*
delete from aspElectricPro..ProDivSal
where date_calc = @dtCurEnd

insert into aspElectricPro..ProDivSal
select * from tmpWork..ProDivSal
where date_calc = @dtCurEnd
*/
--exec sp_ProDivSalConvert '2004-02-29'


-- #TmpPDmar - копия ProDivSal за март
if Exists (select * from TempDB..SysObjects
           where id = OBJECT_ID('TempDB..#TmpPDmar'))
exec('DROP TABLE #TmpPDmar')
select * 
into #TmpPDmar
from ProDivSal
where date_calc = @dtCurEnd
--------------------------------------------
--- #TmpPDfeb - копия ProDivSal за февраль
if Exists (select * from TempDB..SysObjects
           where id = OBJECT_ID('TempDB..#TmpPDfeb'))
exec('DROP TABLE #TmpPDfeb')
select * 
into #TmpPDfeb
from ProDivSal
where date_calc = @dtPreEnd
--------------------------------------------

declare
  @e_contract_id  int
 ,@e_nds_tax      int
 ,@e_quantity     int
 ,@i              int

declare curExRecFeb cursor for
select  
  contract_id
 ,nds_tax
 ,equantity
from #TmpPDfeb (nolock)
where equantity <> 0

open curExRecFeb
fetch next from curExRecFeb
 into @e_contract_id
     ,@e_nds_tax
     ,@e_quantity

select @i = 0
while (@@FETCH_STATUS <> -1)
begin
  select @i = @i +1
  Print @i
  if exists (select * from #TmpPDmar (nolock) where contract_id = @e_contract_id
                                               and date_calc    = @dtCurEnd
                                               and nds_tax      = @e_nds_tax)
    begin
      update #TmpPDmar
      set BQUANTITY     = @e_quantity
      where contract_id = @e_contract_id
        and date_calc   = @dtCurEnd
        and nds_tax     = @e_nds_tax
    end
  else
    begin 
    insert into #TmpPDmar        (Contract_id   ,date_calc  ,nds_tax
                                ,BQUANTITY     ,BSUM_EE    ,BSUM_NDS    ,BSUM_EXC
                                ,NQUANTITY     ,NSUM_EE    ,NSUM_NDS    ,NSUM_EXC
                                ,PQUANTITY     ,PSUM_EE    ,PSUM_NDS    ,PSUM_EXC
                                ,EQUANTITY     ,ESUM_EE    ,ESUM_NDS    ,ESUM_EXC
                                )
                         values (@e_contract_id ,@dtCurEnd ,@e_nds_tax 
                                ,@e_quantity   ,0           ,0           ,0  
                                ,0             ,0           ,0           ,0 
                                ,0             ,0           ,0           ,0  
                                ,0             ,0           ,0           ,0)
  end
 fetch next from curExRecFeb
 into @e_contract_id
     ,@e_nds_tax
     ,@e_quantity
end
close curExRecFeb

-- теперь проходим еще раз чтобы отловить лишние лицевые
if Exists (select * from TempDB..SysObjects
           where id = OBJECT_ID('TempDB..#TmpPDmar_short'))
exec('DROP TABLE #TmpPDmar_short')
select * 
into #TmpPDmar_short
from #TmpPDmar

open curExRecFeb
fetch next from curExRecFeb
 into @e_contract_id
     ,@e_nds_tax
     ,@e_quantity

select @i = 0
while (@@FETCH_STATUS <> -1)
begin
  select @i = @i +1
  Print @i
  if exists (select * from #TmpPDmar (nolock) where contract_id = @e_contract_id
                                               and date_calc    = @dtCurEnd
                                               and nds_tax      = @e_nds_tax)
    begin
      delete from #TmpPDmar_short
      where contract_id = @e_contract_id
        and date_calc   = @dtCurEnd
        and nds_tax     = @e_nds_tax
    end
 
 fetch next from curExRecFeb
 into @e_contract_id
     ,@e_nds_tax
     ,@e_quantity
end
close curExRecFeb
deallocate curExRecFeb

update #TmpPDmar
set #TmpPDmar.bquantity = 0
from #TmpPDmar       t1,
     #TmpPDmar_short t2 
where t1.contract_id = t2.contract_id
  and t1.nds_tax    = t2.nds_tax
  and t1.date_calc  = t2.date_calc

update #TmpPDmar
set pquantity = IsNull(bquantity,0) - IsNull(equantity,0) + IsNull(nquantity,0) 

-- перенос данных в основную таблицу

delete from ProDivSal where Date_calc = @dtCurEnd 
insert  into ProDivSal
       (CONTRACT_ID
       ,DATE_CALC
       ,NDS_TAX
       ,BQUANTITY ,BSUM_EE ,BSUM_NDS ,BSUM_EXC
       ,NQUANTITY ,NSUM_EE ,NSUM_NDS ,NSUM_EXC
       ,PQUANTITY ,PSUM_EE ,PSUM_NDS ,PSUM_EXC
       ,EQUANTITY ,ESUM_EE ,ESUM_NDS ,ESUM_EXC)
select CONTRACT_ID
       ,DATE_CALC
       ,NDS_TAX
       ,BQUANTITY ,BSUM_EE ,BSUM_NDS ,BSUM_EXC
       ,NQUANTITY ,NSUM_EE ,NSUM_NDS ,NSUM_EXC
       ,PQUANTITY ,PSUM_EE ,PSUM_NDS ,PSUM_EXC
       ,EQUANTITY ,ESUM_EE ,ESUM_NDS ,ESUM_EXC
from  #TmpPDmar
/*
select sum(equantity) from ProDivSal
where date_calc = '2004-02-29'

select sum(bquantity) from ProDivSal
where date_calc = '2004-03-31'

select sum(bquantity) from #TmpPDmar
where date_calc = '2004-03-31'

select sum(bquantity) from #TmpPDmar_short
where date_calc = '2004-03-31'
*/
drop table #TmpPDmar
drop table #TmpPDmar_short
drop table #TmpPDfeb