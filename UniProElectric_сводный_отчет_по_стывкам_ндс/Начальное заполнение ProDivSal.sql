-- Заполнение таблицы ProDivSaldo новым методом 
------------------------------------------------------

-- Последовательность действий такая:
-- 1. Запонение сальдо на начало месяца как сальдо на конец предыдущего месяца
-- 2. Расчет и заполнение сальдо на конец месяца из таблиц ProCalcs и ProContracts
-- 3. Расчет и заполнеине начислений (берется из старого скрипта)
-- 4. Расчет и заполнение платежей как
--      платежи = сальдо на начало - сальдо на конец + начисления 

/******************************************************************************/
/*Обозначения:
  EE  - электроэнергия
  EXC - акциз
  ACT - НДС
*/

declare
  @dtDateBeg           datetime
 ,@dtDateEnd           datetime
 ,@dtCurBeg            datetime
 ,@dtCurEnd            datetime
 ,@dtCurEnd_loop       DateTime -- служебная переменная

select
  @dtDateBeg = '1998-08-31'   -- период начала хранимых данных (конец)
 ,@dtDateEnd = '2004-03-31'   -- :dtDateEnd, --последний расчетный период по базе данных (конец)
 ,@dtCurBeg  = '2003-10-01'   --:dtCurBeg,  -- первый период расчета (начало)
 ,@dtCurEnd  = DateAdd(dd,-1,DateAdd(mm,+1,@dtCurBeg))   --:dtCurEnd,  -- последний период расчета (конец)
 
 
--<1>----------------------------------------------------------------------
--Запонение сальдо на начало месяца как сальдо на конец предыдущего месяца |
---------------------------------------------------------------------------


--<2>--------------------------------------------------------------------------
-- Расчет и заполнение сальдо на конец месяца из таблиц ProCalcs и ProContracts|
-------------------------------------------------------------------------------

if Exists (select * from TempDB..SysObjects
           where id = OBJECT_ID('TempDB..#EndBallance'))
exec('DROP TABLE #EndBallance')

if @dtCurEnd > @dtDateEnd
  begin Print '*Error*' end

else
  begin
  select
    Cn.Contract_id
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
                                               end,0) <= 0 /* saldo <= 0 - переплата */
                                   then 1
                                   else 0 end)  
   -- столбцы разделения суммы по процентам ндс
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
--!!!--------------------------------------------------
-- удаляем из рассмотрения те договора,
-- по которым не ведется начисление (не активны в данный момент)
delete from #EndBallance
where Contract_id not in (select contract_id
                          from ProCalcs
                          where date_calc = @dtCurEnd)
-------------------------------------------------------
--debug code------------------- 
--select * from #EndBallance
--drop Table #EndBallance
--end
--
--Разделение должников по периодам задолжности
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

-- Разделение суммы переплаты
-- Всю переплату пишем в сумму за электроэнергию
update #EndBallance  
set
   sum_ee20 = case when @dtCurEnd < '2001-07-31'
                          then saldo
                          else 0 end  
  ,sum_ee16 = case when @dtCurEnd between '2001-07-31' and '2003-12-31'
                          then saldo
                          else 0 end  
  ,sum_ee15 = case when @dtCurEnd > '2003-12-31'
                          then saldo
                          else 0 end  
where term = 0

------------------------------------------------------------------------------------
  
-- debug code

delete from ProDivSal where Date_calc = @dtCurEnd

declare
  @contract_id   int
 ,@date_calc     datetime
 ,@nds_tax       int

 ,@equantity20   int
 ,@esum_ee20     decimal(18,2)
 ,@esum_act20    decimal(18,2)
 ,@esum_exc20    decimal(18,2)

 ,@equantity16   int
 ,@esum_ee16     decimal(18,2)
 ,@esum_act16    decimal(18,2)
 ,@esum_exc16    decimal(18,2)

 ,@equantity15   int
 ,@esum_ee15     decimal(18,2)
 ,@esum_act15    decimal(18,2)
 ,@esum_exc15    decimal(18,2)

declare curExistsContracts cursor for
 select  
  contract_id
 ,Date_calc = @dtCurEnd

 ,quantity20
 ,sum_ee20
 ,sum_nds20
 ,sum_exc20 

 ,quantity16
 ,sum_ee16
 ,sum_nds16
 ,sum_exc16

 ,quantity15
 ,sum_ee15
 ,sum_nds15
 ,sum_exc15
 
 from #EndBallance
 order by Contract_id

open curExistsContracts

FETCH NEXT FROM curExistsContracts
 INTO  
  @contract_id  ,@date_calc  
 ,@equantity20  ,@esum_ee20  ,@esum_act20  ,@esum_exc20
 ,@equantity16  ,@esum_ee16  ,@esum_act16  ,@esum_exc16
 ,@equantity15  ,@esum_ee15  ,@esum_act15  ,@esum_exc15 

WHILE (@@FETCH_STATUS <> -1)
BEGIN
  if @esum_ee20 <> 0
    insert into ProdivSal (Contract_id   ,date_calc  ,nds_tax
                          ,EQUANTITY     ,ESUM_EE    ,ESUM_NDS    ,ESUM_EXC)
                   values (@contract_id  ,@date_calc ,'20' 
                          ,@equantity20  ,@esum_ee20 ,@esum_act20 ,@esum_exc20)  

if @esum_ee16 <> 0
    insert into ProdivSal (Contract_id   ,date_calc  ,nds_tax
                          ,EQUANTITY     ,ESUM_EE    ,ESUM_NDS    ,ESUM_EXC)
                   values (@contract_id  ,@date_calc ,'16' 
                          ,@equantity16  ,@esum_ee16 ,@esum_act16 ,@esum_exc16)  

if @esum_ee15 <> 0
    insert into ProdivSal (Contract_id   ,date_calc  ,nds_tax
                          ,EQUANTITY     ,ESUM_EE    ,ESUM_NDS    ,ESUM_EXC)
                   values (@contract_id  ,@date_calc ,'15' 
                          ,@equantity15  ,@esum_ee15 ,@esum_act15 ,@esum_exc15)  



  FETCH NEXT FROM curExistsContracts
    INTO  
       @contract_id  ,@date_calc  
      ,@equantity20  ,@esum_ee20  ,@esum_act20  ,@esum_exc20
      ,@equantity16  ,@esum_ee16  ,@esum_act16  ,@esum_exc16
      ,@equantity15  ,@esum_ee15  ,@esum_act15  ,@esum_exc15 
END

CLOSE curExistsContracts
DEALLOCATE curExistsContracts


select * from ProDivSal where date_calc = @dtCurEnd

DROP TABLE #EndBallance

