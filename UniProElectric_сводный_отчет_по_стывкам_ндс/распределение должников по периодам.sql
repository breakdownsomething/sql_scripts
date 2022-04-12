declare
  @dtCurBeg    DateTime,
  @dtCurEnd      DateTime,
  @dtCurEnd_loop       DateTime,
  @dtDateEnd  DateTime

select
/*
  @dtCurBeg=:pdtCalcBegin,
  @dtCurEnd=:pdtCalcEnd,
  @dtDateEnd=:pdtMainCalcEnd
*/

  @dtCurBeg   = '2004-02-01',
  @dtCurEnd   = '2004-02-29',
  @dtDateEnd  = '2004-02-29'

--  Расчёт задолженности --
--===================

if Exists (select * from TempDB..SysObjects
           where id = OBJECT_ID('TempDB..#EndBallance'))
exec('DROP TABLE #EndBallance')

if @dtCurEnd > @dtDateEnd
  begin Print '*Error*' end

else
  begin
  select
    Cn.Contract_Number
   ,Cn.Contract_id
   ,Date_Beg    = @dtCurEnd
   ,Date_End    = @dtCurEnd
   ,Saldo       = Convert(Decimal(18,2),IsNull(
                    case when @dtCurEnd = @dtDateEnd
                         then Cn.Saldo
                         else (select C.Saldo
                               from   ProCalcs C
                               where  C.Contract_id = Cn.Contract_id
                                  and C.DATE_CALC = @dtCurEnd)
                         end,0))
   ,Remaind_Pay = Convert(Decimal(18,2),IsNull(
                    case when @dtCurEnd = @dtDateEnd
                         then Cn.Saldo
                         else (select C.Saldo
                               from ProCalcs C
                               where C.Contract_id = Cn.Contract_id
                                 and C.Date_Calc=@dtCurEnd)
                         end,0))
   ,Term        = Convert(Int,0) -- Счетчик месяцев задолжности
   ,Switch      = Convert(Bit,CASE when Isnull(
                                          case when @dtCurEnd = @dtDateEnd
                                               then Cn.Saldo
                                               else (select C.Saldo
                                                     from ProCalcs C
                                                     where C.Contract_id = Cn.Contract_id
                                                       and C.Date_Calc   = @dtCurEnd)
                                               end,0) <= 0
                                   then 1
                                   else 0 end)
   -- столбцы разделения суммы долга по процентам ндс
   ,sum_ee20    = Convert(Decimal(18,2),0)
   ,sum_nds20   = Convert(Decimal(18,2),0)
   ,sum_exc20   = Convert(Decimal(18,2),0)
   ,quantity20  = Convert(Decimal(18,2),0)
--
   ,sum_ee16    = Convert(Decimal(18,2),0)
   ,sum_nds16   = Convert(Decimal(18,2),0)
   ,sum_exc16   = Convert(Decimal(18,2),0)
   ,quantity16  = Convert(Decimal(18,2),0)
--
   ,sum_ee15    = Convert(Decimal(18,2),0)
   ,sum_nds15   = Convert(Decimal(18,2),0)
   ,sum_exc15   = Convert(Decimal(18,2),0)
   ,quantity15  = Convert(Decimal(18,2),0)
   into
    #EndBallance
   from
    ProContracts Cn (nolock)

--select * from #EndBallance
--drop Table #EndBallance
--end
----------------------------------------------
  select
   @dtCurEnd_loop = DateAdd(dd,-1,DateAdd(mm,-1,DateAdd(dd,+1,@dtCurEnd)))


  while Exists(select * from ProCalcs where Date_Calc = @dtCurEnd_loop)
    and Exists(select * from #EndBallance where Switch    = 0)
  begin

   update #EndBallance
      set Date_Beg    = @dtCurEnd_loop
         ,Remaind_Pay = Remaind_Pay - Isnull((select C.Sum_Fact + C.Sum_NDS + C.Sum_EXC
                                              from   ProCalcs C
                                              where C.Contract_id = Z.Contract_id
                                                and C.Date_Calc   = @dtCurEnd_loop),0)
---------
         ,sum_ee20    = sum_ee20 + Isnull((select C.Sum_Fact 
                                           from  ProCalcs C
                                           where C.Contract_id = Z.Contract_id
                                             and C.Date_Calc   = @dtCurEnd_loop
                                             and C.Date_Calc   < '2001-07-31'),0)
         ,sum_nds20   = sum_nds20 + Isnull((select C.Sum_NDS 
                                            from  ProCalcs C
                                            where C.Contract_id = Z.Contract_id
                                              and C.Date_Calc   = @dtCurEnd_loop
                                              and C.Date_Calc   < '2001-07-31'),0)
         ,sum_exc20   = sum_exc20 + Isnull((select C.Sum_EXC 
                                            from  ProCalcs C
                                            where C.Contract_id = Z.Contract_id
                                              and C.Date_Calc   = @dtCurEnd_loop
                                              and C.Date_Calc   < '2001-07-31'),0)
         ,quantity20  = quantity20 + Isnull((select C.Qnt_All 
                                             from  ProCalcs C
                                             where C.Contract_id = Z.Contract_id
                                               and C.Date_Calc   = @dtCurEnd_loop
                                               and C.Date_Calc   < '2001-07-31'),0)
---------
         ,sum_ee16    = sum_ee16 + Isnull((select C.Sum_Fact 
                                           from  ProCalcs C
                                           where C.Contract_id = Z.Contract_id
                                             and C.Date_Calc   = @dtCurEnd_loop
                                             and C.Date_Calc   between '2001-07-31' and '2003-12-31'),0)
         ,sum_nds16   = sum_nds16 + Isnull((select C.Sum_NDS 
                                            from  ProCalcs C
                                            where C.Contract_id = Z.Contract_id
                                              and C.Date_Calc   = @dtCurEnd_loop
                                              and C.Date_Calc   between '2001-07-31' and '2003-12-31'),0)
         ,sum_exc16   = sum_exc16 + Isnull((select C.Sum_EXC 
                                            from  ProCalcs C
                                            where C.Contract_id = Z.Contract_id
                                              and C.Date_Calc   = @dtCurEnd_loop
                                              and C.Date_Calc   between '2001-07-31' and '2003-12-31'),0)
         ,quantity16  = quantity16 + Isnull((select C.Qnt_All 
                                             from  ProCalcs C
                                             where C.Contract_id = Z.Contract_id
                                               and C.Date_Calc   = @dtCurEnd_loop
                                               and C.Date_Calc   between '2001-07-31' and '2003-12-31'),0)
---------
         ,sum_ee15    = sum_ee15 + Isnull((select C.Sum_Fact 
                                           from  ProCalcs C
                                           where C.Contract_id = Z.Contract_id
                                             and C.Date_Calc   = @dtCurEnd_loop
                                             and C.Date_Calc   > '2003-12-31'),0)
         ,sum_nds15   = sum_nds15 + Isnull((select C.Sum_NDS 
                                            from  ProCalcs C
                                            where C.Contract_id = Z.Contract_id
                                              and C.Date_Calc   = @dtCurEnd_loop
                                              and C.Date_Calc   > '2003-12-31'),0)
         ,sum_exc15   = sum_exc15 + Isnull((select C.Sum_EXC 
                                            from  ProCalcs C
                                            where C.Contract_id = Z.Contract_id
                                              and C.Date_Calc   = @dtCurEnd_loop
                                              and C.Date_Calc   > '2003-12-31'),0)
         ,quantity15  = quantity15 + Isnull((select C.Qnt_All 
                                from  ProCalcs C
                                where C.Contract_id = Z.Contract_id 
                                  and C.Date_Calc   = @dtCurEnd_loop
                                  and C.Date_Calc   > '2003-12-31'),0)

----------
         ,Term        = Term + 1
         ,Switch      = case when Remaind_Pay - IsNull((select C.Sum_FACT + C.Sum_NDS + C.Sum_EXC
                                                        from ProCalcs C
                                                        where C.Contract_id = Z.Contract_id
                                                          and C.Date_Calc   = @dtCurEnd_loop),0) <= 0
                             then 1
                             else 0 end
     from #EndBallance Z
     where SWITCH = 0

    select
      @dtCurEnd_loop = DateAdd(dd,-1,DateAdd(mm,-1,DateAdd(dd,+1,@dtCurEnd_loop)))
  end
end


------------- Разделение по EE, NDS, EXC нераспределенного остатка remaind_pay
--20%--------------------------------------------------------------------------
update #EndBallance
set 
  sum_exc20 = sum_exc20 + remaind_pay * (sum_exc20/(sum_ee20 + sum_nds20 + sum_exc20))
 ,sum_nds20 = sum_nds20 + remaind_pay * (sum_nds20/(sum_ee20 + sum_nds20 + sum_exc20))
 ,sum_ee20  = sum_ee20  + remaind_pay * (1 - (sum_exc20/(sum_ee20 + sum_nds20 + sum_exc20))
                                           - (sum_nds20/(sum_ee20 + sum_nds20 + sum_exc20))) 
from #EndBallance
where sum_ee20 <> 0
-- Исправление ошибок округления
update #EndBallance
set sum_ee20 = sum_ee20 + (saldo - (sum_ee20 + sum_nds20 + sum_exc20 +
                                    sum_ee16 + sum_nds16 + sum_exc16 +
                                    sum_ee15 + sum_nds15 + sum_exc15))
from #EndBallance
where sum_ee20 <> 0

--16%-----------------------------------------------------------------------------
update #EndBallance
set 
  sum_exc16 = sum_exc16 + remaind_pay * (sum_exc16/(sum_ee16 + sum_nds16 + sum_exc16))
 ,sum_nds16 = sum_nds16 + remaind_pay * (sum_nds16/(sum_ee16 + sum_nds16 + sum_exc16))
 ,sum_ee16  = sum_ee16  + remaind_pay * (1 - (sum_exc16/(sum_ee16 + sum_nds16 + sum_exc16))
                                           - (sum_nds16/(sum_ee16 + sum_nds16 + sum_exc16))) 
from #EndBallance
where sum_ee16 <> 0
 and  sum_ee20 = 0
-- Исправление ошибок округления
update #EndBallance
set  sum_ee16 = sum_ee16 + (saldo - (sum_ee20 + sum_nds20 + sum_exc20 +
                                     sum_ee16 + sum_nds16 + sum_exc16 +
                                     sum_ee15 + sum_nds15 + sum_exc15))
from #EndBallance
where sum_ee16 <> 0
 and  sum_ee20 = 0

--15%-------------------------------------------------------------------------------
update #EndBallance
set 
  sum_exc15 = sum_exc15 + remaind_pay * (sum_exc15/(sum_ee15 + sum_nds15 + sum_exc15))
 ,sum_nds15 = sum_nds15 + remaind_pay * (sum_nds15/(sum_ee15 + sum_nds15 + sum_exc15))
 ,sum_ee15  = sum_ee15  + remaind_pay * (1 - (sum_exc15/(sum_ee15 + sum_nds15 + sum_exc15))
                                           - (sum_nds15/(sum_ee15 + sum_nds15 + sum_exc15))) 
from #EndBallance
where sum_ee15 <> 0
 and  sum_ee16 = 0
 and  sum_ee20 = 0
-- Исправление ошибок округления
update #EndBallance
set 
  sum_ee15 = sum_ee15 + (saldo - (sum_ee20 + sum_nds20 + sum_exc20 +
                                     sum_ee16 + sum_nds16 + sum_exc16 +
                                     sum_ee15 + sum_nds15 + sum_exc15))
from #EndBallance
where sum_ee15 <> 0
 and  sum_ee16 = 0
 and  sum_ee20 = 0
------------------------------------------------------------------------------------




 SELECT  
  contract_id
 ,date_beg
 ,saldo
 ,remaind_pay
 ,term
 ,switch
 ,sum20 = sum_ee20 + sum_nds20 + sum_exc20 
 ,sum16 = sum_ee16 + sum_nds16 + sum_exc16
 ,sum15 = sum_ee15 + sum_nds15 + sum_exc15
 ,diff  = saldo - (sum_ee20 + sum_nds20 + sum_exc20 +
                   sum_ee16 + sum_nds16 + sum_exc16 +
                   sum_ee15 + sum_nds15 + sum_exc15)
 FROM #EndBallance
-- where  (sum_ee20 + sum_nds20 + sum_exc20) <> 0
--    or (sum_ee16 + sum_nds16 + sum_exc16)  <> 0
--    or (sum_ee15 + sum_nds15 + sum_exc15)  <> 0

where  saldo - (sum_ee20 + sum_nds20 + sum_exc20 +
                   sum_ee16 + sum_nds16 + sum_exc16 +
                   sum_ee15 + sum_nds15 + sum_exc15) <> 0

order by Switch

drop table #EndBallance
-- Формирование отчёта --





