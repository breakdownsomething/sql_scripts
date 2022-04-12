SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


--DROP  PROCEDURE pProDivSal
CREATE PROCEDURE dbo.pProDivSal
@dtCurEnd  datetime -- последний день месяца, за который будет производится рвсчет
AS
/******************************************************************************/
-- Последовательность действий такая:
-- 1. Запонение сальдо на начало месяца как сальдо на конец предыдущего месяца
-- 2. Расчет и заполнение сальдо на конец месяца из таблиц ProCalcs и ProContracts
-- 3. Расчет и заполнеине начислений (берется из старого скрипта)
-- 4. Расчет и заполнение платежей как
--      платежи = сальдо на начало - сальдо на конец + начисления 
/******************************************************************************/
declare
  @dtDateEnd           datetime
 ,@dtNextEnd           datetime
 ,@dtCurEnd_loop       DateTime -- служебная переменная

select
  @dtDateEnd =  DateAdd(dd,-1,DateAdd(mm,-1,DateAdd(dd,+1,(select distinct date_calc_end from ProGroups))))
                -- :dtDateEnd, --последний закрытый месяц по базе данных (конец)
 ,@dtNextEnd =   dateadd(dd,-1,dateadd(mm,+1,Dateadd(dd,+1,@dtCurEnd)))
                         -- последний день месяца, следующего после расчетного
--<0>---------------------------------------------------------------------------
-- Создание временной таблицы со структурой, аналогичной ProDivSal.             |
-- Сначала все расчеты выполняются в этой временной таблице, а затем            |
-- результаты переносятся в основную. Если сразу расчитывать в основной         |
-- то это занимает очень много времени, т.к. update-ы на болших таблицах        |
-- работают гораздо медленее. (а update-ов здесь хватает ;) )                   |
--------------------------------------------------------------------------------
if Exists (select * from TempDB..SysObjects
           where id = OBJECT_ID('TempDB..#TmpProDivSal'))
exec('DROP TABLE #TmpProDivSal')

CREATE TABLE #TmpProDivSal (
	[CONTRACT_ID]     [int]        NOT NULL ,--PK
	[DATE_CALC]       [datetime]   NOT NULL ,--PK
  [NDS_TAX]         [int]        NOT NULL ,--PK
-- сальдо на начало месяца--------
	[BQUANTITY]       [int]            NULL ,
	[BSUM_EE]         [decimal](18, 2) NULL ,
	[BSUM_NDS]        [decimal](18, 2) NULL ,
	[BSUM_EXC]        [decimal](18, 2) NULL ,
-- Начисления------------------------
	[NQUANTITY]       [int]            NULL ,
	[NSUM_EE]         [decimal](18, 2) NULL ,
	[NSUM_NDS]        [decimal](18, 2) NULL ,
	[NSUM_EXC]        [decimal](18, 2) NULL ,
-- Платежи--------------------------------
	[PQUANTITY]       [int]            NULL ,
	[PSUM_EE]         [decimal](18, 2) NULL ,
	[PSUM_NDS]        [decimal](18, 2) NULL ,
	[PSUM_EXC]        [decimal](18, 2) NULL ,
-- сальдо на конец-------------------------
	[EQUANTITY]       [int]            NULL ,
	[ESUM_EE]         [decimal](18, 2) NULL ,
	[ESUM_NDS]        [decimal](18, 2) NULL ,
	[ESUM_EXC]        [decimal](18, 2) NULL ,
	PRIMARY KEY ([CONTRACT_ID],[DATE_CALC],[NDS_TAX])
) ON [PRIMARY]

--<1>---------------------------------------------------------------------------
--Запонение сальдо на начало месяца как сальдо на конец предыдущего месяца      |
--------------------------------------------------------------------------------
-- delete from ProDivSal where Date_calc = @dtCurEnd  --!!!!

declare
  @e_contract_id  int
 ,@e_date_calc    datetime
 ,@e_nds_tax      int
 ,@e_quantity     int
 ,@e_sum_ee       decimal(18,2)
 ,@e_sum_nds      decimal(18,2)
 ,@e_sum_exc      decimal(18,2)

declare curExistsRecords cursor for
select  
  contract_id
 ,date_calc
 ,nds_tax
 ,equantity
 ,esum_ee
 ,esum_nds
 ,esum_exc 
from ProdivSal
where date_calc = DateAdd(dd,-1,DateAdd(mm,-1,DateAdd(dd,+1,@dtCurEnd)))

open curExistsRecords
fetch next from curExistsRecords
 into  
  @e_contract_id  ,@e_date_calc  ,@e_nds_tax  
 ,@e_quantity     ,@e_sum_ee     ,@e_sum_nds  ,@e_sum_exc

while (@@FETCH_STATUS <> -1)
begin
if  @e_sum_ee   <> 0
 or @e_sum_nds  <> 0
 or @e_sum_exc  <> 0
 or @e_quantity <> 0
    insert into #TmpProDivSal (Contract_id    ,date_calc   ,nds_tax
                              ,BQUANTITY      ,BSUM_EE     ,BSUM_NDS    ,BSUM_EXC
                              ,NQUANTITY      ,NSUM_EE     ,NSUM_NDS    ,NSUM_EXC
                              ,PQUANTITY      ,PSUM_EE     ,PSUM_NDS    ,PSUM_EXC
                              ,EQUANTITY      ,ESUM_EE     ,ESUM_NDS    ,ESUM_EXC)
                   values (@e_contract_id ,@dtCurEnd   ,@e_nds_tax
                          ,@e_quantity    ,@e_sum_ee   ,@e_sum_nds  ,@e_sum_exc
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0))      
fetch next from curExistsRecords
 into  
  @e_contract_id  ,@e_date_calc  ,@e_nds_tax  
 ,@e_quantity     ,@e_sum_ee     ,@e_sum_nds  ,@e_sum_exc
end

close curExistsRecords
deallocate curExistsRecords


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
                                  and C.DATE_CALC = @dtNextEnd) 
                         end,0))
   ,Remaind_Pay = Convert(Decimal(18,2),IsNull(
                    case when @dtCurEnd = @dtDateEnd
                         then Cn.Saldo
                         else (select C.Saldo
                               from ProCalcs C
                               where C.Contract_id = Cn.Contract_id
                                 and C.Date_Calc=@dtNextEnd) 
                         end,0))
   ,Term        = Convert(Int,0) -- Счетчик месяцев задолжности
   ,Switch      = Convert(Bit,CASE when Isnull(
                                          case when @dtCurEnd = @dtDateEnd
                                               then Cn.Saldo
                                               else (select C.Saldo
                                                     from ProCalcs C
                                                     where C.Contract_id = Cn.Contract_id
                                                       and C.Date_Calc   = @dtNextEnd) 
                                               end,0) <= 0 -- saldo <= 0 - переплата 
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

--Разделение должников по периодам задолжности
  select
   @dtCurEnd_loop = @dtCurEnd -- DateAdd(dd,-1,DateAdd(mm,-1,DateAdd(dd,+1,@dtCurEnd)))

  while Exists(select * from ProCalcs     where Date_Calc = @dtCurEnd_loop)
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
        ,quantity20  = case when Remaind_Pay - IsNull((select C.Sum_FACT + C.Sum_NDS + C.Sum_EXC
                                                        from ProCalcs C
                                                        where C.Contract_id = Z.Contract_id
                                                          and C.Date_Calc   = @dtCurEnd_loop),0) <= 0
                    then quantity20 + round( 
                                           (Remaind_Pay
                                            /(IsNull((select C.Sum_FACT + C.Sum_NDS + C.Sum_EXC
                                                        from ProCalcs C
                                                        where C.Contract_id = Z.Contract_id
                                                          and C.Date_Calc   = @dtCurEnd_loop),0) + Remaind_Pay)
                                           )
                                           * Isnull((select C.Qnt_All 
                                                     from  ProCalcs C
                                                     where C.Contract_id = Z.Contract_id 
                                                       and C.Date_Calc   = @dtCurEnd_loop
                                                       and C.Date_Calc   < '2001-07-31'),0)
                                           ,0)
                    else quantity20 + Isnull((select C.Qnt_All 
                                from  ProCalcs C
                                where C.Contract_id = Z.Contract_id 
                                  and C.Date_Calc   = @dtCurEnd_loop
                                  and C.Date_Calc   < '2001-07-31'),0) end




/*         ,quantity20  = quantity20 + Isnull((select C.Qnt_All 
                                             from  ProCalcs C
                                             where C.Contract_id = Z.Contract_id
                                               and C.Date_Calc   = @dtCurEnd_loop
                                               and C.Date_Calc   < '2001-07-31'),0)*/
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
        ,quantity16  = case when Remaind_Pay - IsNull((select C.Sum_FACT + C.Sum_NDS + C.Sum_EXC
                                                        from ProCalcs C
                                                        where C.Contract_id = Z.Contract_id
                                                          and C.Date_Calc   = @dtCurEnd_loop),0) <= 0
                    then quantity16 + round( 
                                           ( Remaind_Pay/
                                                        (IsNull((select C.Sum_FACT + C.Sum_NDS + C.Sum_EXC
                                                        from ProCalcs C
                                                        where C.Contract_id = Z.Contract_id
                                                          and C.Date_Calc   = @dtCurEnd_loop),0)+Remaind_Pay)
                                           )
                                           * Isnull((select C.Qnt_All 
                                                     from  ProCalcs C
                                                     where C.Contract_id = Z.Contract_id 
                                                       and C.Date_Calc   = @dtCurEnd_loop
                                                       and C.Date_Calc   between '2001-07-31' and '2003-12-31'),0)
                                           ,0)
                    else quantity16 + Isnull((select C.Qnt_All 
                                from  ProCalcs C
                                where C.Contract_id = Z.Contract_id 
                                  and C.Date_Calc   = @dtCurEnd_loop
                                  and C.Date_Calc   between '2001-07-31' and '2003-12-31'),0) end


/*         ,quantity16  = quantity16 + Isnull((select C.Qnt_All 
                                             from  ProCalcs C
                                             where C.Contract_id = Z.Contract_id
                                               and C.Date_Calc   = @dtCurEnd_loop
                                               and C.Date_Calc   between '2001-07-31' and '2003-12-31'),0)*/
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


        ,quantity15  = case when Remaind_Pay - IsNull((select C.Sum_FACT + C.Sum_NDS + C.Sum_EXC
                                                        from ProCalcs C
                                                        where C.Contract_id = Z.Contract_id
                                                          and C.Date_Calc   = @dtCurEnd_loop),0) <= 0
                    then quantity15 + round( 
                                           ( Remaind_Pay /(IsNull((select C.Sum_FACT + C.Sum_NDS + C.Sum_EXC
                                                        from ProCalcs C
                                                        where C.Contract_id = Z.Contract_id
                                                          and C.Date_Calc   = @dtCurEnd_loop),0))
                                           )
                                           * Isnull((select C.Qnt_All 
                                                     from  ProCalcs C
                                                     where C.Contract_id = Z.Contract_id 
                                                       and C.Date_Calc   = @dtCurEnd_loop
                                                       and C.Date_Calc   > '2003-12-31'),0)
                                           ,0)
                    else quantity15 + Isnull((select C.Qnt_All 
                                from  ProCalcs C
                                where C.Contract_id = Z.Contract_id 
                                  and C.Date_Calc   = @dtCurEnd_loop
                                  and C.Date_Calc   > '2003-12-31'),0) end



/*         ,quantity15  = quantity15 + Isnull((select C.Qnt_All 
                                from  ProCalcs C
                                where C.Contract_id = Z.Contract_id 
                                  and C.Date_Calc   = @dtCurEnd_loop
                                  and C.Date_Calc   > '2003-12-31'),0)*/


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

------ Занесение результатов вычисление в ProDivSal
--delete from ProDivSal where Date_calc = @dtCurEnd
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
 ,@i             int
declare curExistsContracts cursor for
 select  
  contract_id ,Date_calc = @dtCurEnd
 ,quantity20  ,sum_ee20   ,sum_nds20  ,sum_exc20 
 ,quantity16  ,sum_ee16   ,sum_nds16  ,sum_exc16
 ,quantity15  ,sum_ee15   ,sum_nds15  ,sum_exc15
 from #EndBallance
 order by Contract_id

open curExistsContracts

fetch next from curExistsContracts
 into  
  @contract_id  ,@date_calc  
 ,@equantity20  ,@esum_ee20  ,@esum_act20  ,@esum_exc20
 ,@equantity16  ,@esum_ee16  ,@esum_act16  ,@esum_exc16
 ,@equantity15  ,@esum_ee15  ,@esum_act15  ,@esum_exc15 

select @i = 1

while (@@FETCH_STATUS <> -1)
begin
  if @esum_ee20  <> 0
  or @esum_act20 <> 0
  or @esum_exc20 <> 0
  or @equantity20 <> 0
  begin 
     if exists (select * from #TmpProDivSal
                where contract_id = @contract_id
                  and date_calc   = @date_calc
                  and nds_tax     = 20)
     begin
       update #TmpProDivSal
       set EQUANTITY = @equantity20
          ,ESUM_EE   = @esum_ee20
          ,ESUM_NDS  = @esum_act20
          ,ESUM_EXC  = @esum_exc20          
       where contract_id = @contract_id
         and date_calc   = @date_calc
         and nds_tax     = 20
     end  
     else
     begin
        insert into #TmpProDivSal (Contract_id   ,date_calc  ,nds_tax
                          ,EQUANTITY     ,ESUM_EE    ,ESUM_NDS    ,ESUM_EXC
                          ,NQUANTITY     ,NSUM_EE    ,NSUM_NDS    ,NSUM_EXC
                          ,PQUANTITY     ,PSUM_EE    ,PSUM_NDS    ,PSUM_EXC
                          ,BQUANTITY     ,BSUM_EE    ,BSUM_NDS    ,BSUM_EXC)
                   values (@contract_id  ,@date_calc ,'20' 
                          ,@equantity20  ,@esum_ee20 ,@esum_act20 ,@esum_exc20
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0))  
     end
  end
  if @esum_ee16  <> 0
  or @esum_act16 <> 0
  or @esum_exc16 <> 0
  or @equantity16 <> 0
  begin
     if exists (select * from #TmpProDivSal
                where contract_id = @contract_id
                  and date_calc   = @date_calc
                  and nds_tax     = 16)
     begin
        update #TmpProDivSal
        set EQUANTITY = @equantity16
           ,ESUM_EE   = @esum_ee16
           ,ESUM_NDS  = @esum_act16
           ,ESUM_EXC  = @esum_exc16          
        where contract_id = @contract_id
          and date_calc   = @date_calc
          and nds_tax     = 16
     end
     else
     begin
        insert into #TmpProDivSal (Contract_id   ,date_calc  ,nds_tax
                          ,EQUANTITY     ,ESUM_EE    ,ESUM_NDS    ,ESUM_EXC
                          ,NQUANTITY     ,NSUM_EE    ,NSUM_NDS    ,NSUM_EXC
                          ,PQUANTITY     ,PSUM_EE    ,PSUM_NDS    ,PSUM_EXC
                          ,BQUANTITY     ,BSUM_EE    ,BSUM_NDS    ,BSUM_EXC)
                   values (@contract_id  ,@date_calc ,'16' 
                          ,@equantity16  ,@esum_ee16 ,@esum_act16 ,@esum_exc16
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0))  
     end
  end
  if @esum_ee15  <> 0
  or @esum_act15 <> 0
  or @esum_exc15 <> 0
  or @equantity15 <> 0
  begin
     if exists (select * from #TmpProDivSal
                where contract_id = @contract_id
                  and date_calc   = @date_calc
                  and nds_tax     = 15)
     begin
        update #TmpProDivSal
        set EQUANTITY = @equantity15
           ,ESUM_EE   = @esum_ee15
           ,ESUM_NDS  = @esum_act15
           ,ESUM_EXC  = @esum_exc15          
        where contract_id = @contract_id
          and date_calc   = @date_calc
          and nds_tax     = 15
      end
      else
      begin
        insert into #TmpProDivSal (Contract_id   ,date_calc  ,nds_tax
                          ,EQUANTITY     ,ESUM_EE    ,ESUM_NDS    ,ESUM_EXC
                          ,NQUANTITY     ,NSUM_EE    ,NSUM_NDS    ,NSUM_EXC
                          ,PQUANTITY     ,PSUM_EE    ,PSUM_NDS    ,PSUM_EXC
                          ,BQUANTITY     ,BSUM_EE    ,BSUM_NDS    ,BSUM_EXC)
                   values (@contract_id  ,@date_calc ,'15' 
                          ,@equantity15  ,@esum_ee15 ,@esum_act15 ,@esum_exc15
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0))  
     end
  end
  fetch next from curExistsContracts
    into  
       @contract_id  ,@date_calc  
      ,@equantity20  ,@esum_ee20  ,@esum_act20  ,@esum_exc20
      ,@equantity16  ,@esum_ee16  ,@esum_act16  ,@esum_exc16
      ,@equantity15  ,@esum_ee15  ,@esum_act15  ,@esum_exc15 
select @i = @i+1
end
Print @i
close curExistsContracts
deallocate curExistsContracts

--<3>------------------------------------------------------------------------
-- Распределение начислений по процентам НДС %                               |
-----------------------------------------------------------------------------
if Exists (select * from TempDB..SysObjects
           where id = OBJECT_ID('TempDB..#Charges'))
exec('DROP TABLE #Charges')

SELECT
  CONTRACT_ID = C.CONTRACT_ID,
  QUANTITY    = C.QNT_ALL,
  SUM_EE      = C.SUM_FACT,
  SUM_ACT     = C.SUM_NDS,
  SUM_EXC     = C.SUM_EXC,

/* Дополнительные начисления за период с НДС 15% */
  QUANTITY_15 = convert(decimal(12,2),0),
  SUM_EE_15   = convert(decimal(12,2),0),
  SUM_ACT_15  = convert(decimal(12,2),0),
  SUM_EXC_15  = convert(decimal(12,2),0),

/* Дополнительные начисления за период с НДС 20% */
 /* сумма за электроэнергию*/
  SUM_EE_20   = Convert(Decimal(12,2),IsNull(
                   (SELECT SUM(CD.SUM_CALC) 
                    FROM ProCalcDetails CD
                    WHERE CD.CALC_ID = C.CALC_ID AND
                          CD.DECODE_ID = 8 AND
                          (SELECT DATE_CALC
                           FROM ProCalcs
                           WHERE CALC_ID = CD.SOURCE_ID) < '2001-07-31'),0)),
/*Количество кВт*/
  QUANTITY_20 = Convert(Integer,IsNull(
               (SELECT SUM(CD.CALC_QUANTITY)
                FROM ProCalcDetails CD
                WHERE CD.CALC_ID  = C.CALC_ID AND
                      CD.DECODE_ID = 8 AND
                     (SELECT DATE_CALC
                      FROM ProCalcs
                      WHERE CALC_ID=CD.SOURCE_ID)<'2001-07-31'),0)),
/*сумма акциза*/
   SUM_EXC_20   = Convert(Decimal(12,2),IsNull(
                  (SELECT SUM(CD.CALC_QUANTITY*CC.EXCISE_TAX)
                   FROM ProCalcDetails CD,
                        ProCalcs       CC
                   WHERE CC.CALC_ID  = CD.SOURCE_ID AND
                      CD.CALC_ID  = C.CALC_ID AND
                      CD.DECODE_ID = 8 AND
                     (SELECT DATE_CALC
                      FROM ProCalcs
                      WHERE CALC_ID=CD.SOURCE_ID)<'2001-07-31'),0)),
/*сумма НДС*/
   SUM_ACT_20   = Convert(Decimal(12,2),IsNull(
                  (SELECT SUM((CD.SUM_CALC + CD.CALC_QUANTITY*CC.EXCISE_TAX*
                         (CASE WHEN CC.DATE_CALC > '2000-09-30'
                               THEN 1
                               ELSE 0 END)
                   )*CC.ADD_COST_TAX/100)
                 /*Если дата платежа старше 2000-09-30 тогда НДС с акциза не начислять*/
                   FROM ProCalcDetails CD,
                        ProCalcs       CC
                   WHERE CC.CALC_ID  = CD.SOURCE_ID AND
                      CD.CALC_ID  = C.CALC_ID AND
                      CD.DECODE_ID = 8 AND
                     (SELECT DATE_CALC
                      FROM ProCalcs
                      WHERE CALC_ID=CD.SOURCE_ID)<'2001-07-31'),0)),

/* Дополнительные начисления за период с НДС 16% */
/*сумма за электроэнергию*/
  SUM_EE_16  = Convert(Decimal(12,2),IsNull(
                  (SELECT SUM(CD.SUM_CALC) 
                   FROM ProCalcDetails CD
                   WHERE CD.CALC_ID = C.CALC_ID AND
                         CD.DECODE_ID = 8 AND
                         (SELECT DATE_CALC
                          FROM ProCalcs
                          WHERE CALC_ID = CD.SOURCE_ID) BETWEEN '2001-07-31' AND '2003-12-31'),0)),
/*Количество кВт*/
  QUANTITY_16 =  Convert(Integer,IsNull(
                (SELECT SUM(CD.CALC_QUANTITY)
                 FROM ProCalcDetails CD
                 WHERE CD.CALC_ID  = C.CALC_ID AND
                       CD.DECODE_ID = 8 AND
                       (SELECT DATE_CALC
                        FROM ProCalcs
                        WHERE CALC_ID=CD.SOURCE_ID) BETWEEN '2001-07-31' AND '2003-12-31'),0)),

/*сумма акциза*/
   SUM_EXC_16   = Convert(Decimal(12,2),IsNull(
                  (SELECT SUM(CD.CALC_QUANTITY*CC.EXCISE_TAX)
                   FROM ProCalcDetails CD,
                        ProCalcs       CC
                   WHERE CC.CALC_ID  = CD.SOURCE_ID AND
                      CD.CALC_ID  = C.CALC_ID AND
                      CD.DECODE_ID = 8 AND
                     (SELECT DATE_CALC
                      FROM ProCalcs
                      WHERE CALC_ID=CD.SOURCE_ID) BETWEEN '2001-07-31' AND '2003-12-31'),0)),

/*сумма НДС*/
   SUM_ACT_16   = Convert(Decimal(12,2),IsNull(
                  (SELECT SUM((CD.SUM_CALC+CD.CALC_QUANTITY*CC.EXCISE_TAX)*CC.ADD_COST_TAX/100)
                   FROM ProCalcDetails CD,
                        ProCalcs       CC
                   WHERE CC.CALC_ID  = CD.SOURCE_ID AND
                      CD.CALC_ID  = C.CALC_ID AND
                      CD.DECODE_ID = 8 AND
                     (SELECT DATE_CALC
                      FROM ProCalcs
                      WHERE CALC_ID=CD.SOURCE_ID) BETWEEN '2001-07-31' AND '2003-12-31'),0))

 INTO #Charges
 FROM ProCalcs C (NoLock)
 WHERE C.DATE_CALC = @dtCurEnd
ALTER TABLE  #Charges
 ADD PRIMARY KEY (CONTRACT_ID)

if @dtCurEnd < '2001-07-31'
  begin
  update #Charges
   set
     QUANTITY_20 = QUANTITY
    ,SUM_EE_20   = SUM_EE
    ,SUM_ACT_20  = SUM_ACT 
    ,SUM_EXC_20  = SUM_EXC
  end

if @dtCurEnd BETWEEN '2001-07-31' AND '2003-12-31'
  begin
  update #Charges
    set
      QUANTITY_16 = QUANTITY - QUANTITY_20
     ,SUM_EE_16  = SUM_EE  - SUM_EE_20
     ,SUM_ACT_16 = SUM_ACT - SUM_ACT_20
     ,SUM_EXC_16 = SUM_EXC - SUM_EXC_20 
  end

if @dtCurEnd > '2003-12-31'
  begin
  update #Charges
    set
      QUANTITY_15 = QUANTITY - QUANTITY_20 - QUANTITY_16
     ,SUM_EE_15  = SUM_EE  - SUM_EE_20 - SUM_EE_16
     ,SUM_ACT_15 = SUM_ACT - SUM_ACT_20 - SUM_ACT_16
     ,SUM_EXC_15 = SUM_EXC - SUM_EXC_20 - SUM_EXC_16
  end

-- Заполнение сумм начислений...---------------------------
declare
  @nquantity20   int
 ,@nsum_ee20     decimal(18,2)
 ,@nsum_act20    decimal(18,2)
 ,@nsum_exc20    decimal(18,2)
 ,@nquantity16   int
 ,@nsum_ee16     decimal(18,2)
 ,@nsum_act16    decimal(18,2)
 ,@nsum_exc16    decimal(18,2)
 ,@nquantity15   int
 ,@nsum_ee15     decimal(18,2)
 ,@nsum_act15    decimal(18,2)
 ,@nsum_exc15    decimal(18,2)
declare curExistsNach cursor for
 select  
  contract_id ,Date_calc = @dtCurEnd
 ,quantity_20  ,sum_ee_20   ,sum_act_20  ,sum_exc_20 
 ,quantity_16  ,sum_ee_16   ,sum_act_16  ,sum_exc_16
 ,quantity_15  ,sum_ee_15   ,sum_act_15  ,sum_exc_15
 from #Charges
 order by Contract_id

open curExistsNach

fetch next from curExistsNach
 into  
  @contract_id  ,@date_calc  
 ,@nquantity20  ,@nsum_ee20  ,@nsum_act20  ,@nsum_exc20
 ,@nquantity16  ,@nsum_ee16  ,@nsum_act16  ,@nsum_exc16
 ,@nquantity15  ,@nsum_ee15  ,@nsum_act15  ,@nsum_exc15 
select @i = 1
while (@@FETCH_STATUS <> -1)
begin
  if @nsum_ee20   <> 0
  or @nsum_act20  <> 0
  or @nsum_exc20  <> 0
  or @nquantity20 <> 0
  begin 
     if exists (select * from #TmpProDivSal
                where contract_id = @contract_id
                  and date_calc   = @date_calc
                  and nds_tax     = 20)
     begin
       update #TmpProDivSal
       set nQUANTITY = @nquantity20
          ,nSUM_EE   = @nsum_ee20
          ,nSUM_NDS  = @nsum_act20
          ,nSUM_EXC  = @nsum_exc20          
       where contract_id = @contract_id
         and date_calc   = @date_calc
         and nds_tax     = 20
     end  
     else
     begin
        insert into #TmpProDivSal (Contract_id   ,date_calc  ,nds_tax
                          ,EQUANTITY     ,ESUM_EE    ,ESUM_NDS    ,ESUM_EXC
                          ,NQUANTITY     ,NSUM_EE    ,NSUM_NDS    ,NSUM_EXC
                          ,PQUANTITY     ,PSUM_EE    ,PSUM_NDS    ,PSUM_EXC
                          ,BQUANTITY     ,BSUM_EE    ,BSUM_NDS    ,BSUM_EXC)
                   values (@contract_id  ,@date_calc ,'20' 
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,@nquantity20  ,@nsum_ee20 ,@nsum_act20 ,@nsum_exc20
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0))  
     end
  end
  if @nsum_ee16   <> 0
  or @nsum_act16  <> 0
  or @nsum_exc16  <> 0
  or @nquantity16 <> 0
  begin
     if exists (select * from #TmpProDivSal
                where contract_id = @contract_id
                  and date_calc   = @date_calc
                  and nds_tax     = 16)
     begin
        update #TmpProDivSal
        set nQUANTITY = @nquantity16
           ,nSUM_EE   = @nsum_ee16
           ,nSUM_NDS  = @nsum_act16
           ,nSUM_EXC  = @nsum_exc16          
        where contract_id = @contract_id
          and date_calc   = @date_calc
          and nds_tax     = 16
     end
     else
     begin
        insert into #TmpProDivSal (Contract_id   ,date_calc  ,nds_tax
                          ,EQUANTITY     ,ESUM_EE    ,ESUM_NDS    ,ESUM_EXC
                          ,NQUANTITY     ,NSUM_EE    ,NSUM_NDS    ,NSUM_EXC
                          ,PQUANTITY     ,PSUM_EE    ,PSUM_NDS    ,PSUM_EXC
                          ,BQUANTITY     ,BSUM_EE    ,BSUM_NDS    ,BSUM_EXC)
                   values (@contract_id  ,@date_calc ,'16' 
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,@nquantity16  ,@nsum_ee16 ,@nsum_act16 ,@nsum_exc16
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)

                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0))  
     end
  end
  if @nsum_ee15   <> 0
  or @nsum_act15  <> 0
  or @nsum_exc15  <> 0
  or @nquantity15 <> 0
  begin
     if exists (select * from #TmpProDivSal
                where contract_id = @contract_id
                  and date_calc   = @date_calc
                  and nds_tax     = 15)
     begin
        update #TmpProDivSal
        set nQUANTITY = @nquantity15
           ,nSUM_EE   = @nsum_ee15
           ,nSUM_NDS  = @nsum_act15
           ,nSUM_EXC  = @nsum_exc15          
        where contract_id = @contract_id
          and date_calc   = @date_calc
          and nds_tax     = 15
      end
      else
      begin
        insert into #TmpProDivSal (Contract_id   ,date_calc  ,nds_tax
                          ,EQUANTITY     ,ESUM_EE    ,ESUM_NDS    ,ESUM_EXC
                          ,NQUANTITY     ,NSUM_EE    ,NSUM_NDS    ,NSUM_EXC
                          ,PQUANTITY     ,PSUM_EE    ,PSUM_NDS    ,PSUM_EXC
                          ,BQUANTITY     ,BSUM_EE    ,BSUM_NDS    ,BSUM_EXC)
                   values (@contract_id  ,@date_calc ,'15' 
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,@nquantity15  ,@nsum_ee15 ,@nsum_act15 ,@nsum_exc15
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0))  
     end
  end
  fetch next from curExistsNach
    into  
       @contract_id  ,@date_calc  
      ,@nquantity20  ,@nsum_ee20  ,@nsum_act20  ,@nsum_exc20
      ,@nquantity16  ,@nsum_ee16  ,@nsum_act16  ,@nsum_exc16
      ,@nquantity15  ,@nsum_ee15  ,@nsum_act15  ,@nsum_exc15 
select @i = @i+1
end
Print @i
close curExistsNach
deallocate curExistsNach


--------------------------------------------------------------------------------------------------
-- 4. Расчет и заполнение платежей как                                                            |
--      платежи = сальдо на начало - сальдо на конец + начисления                                 |
--------------------------------------------------------------------------------------------------
update #TmpProDivSal
set
  pquantity = IsNull(bquantity,0) - IsNull(equantity,0) + IsNull(nquantity,0) 
 ,psum_ee   = IsNull(bsum_ee,0)   - IsNull(esum_ee,0)   + IsNull(nsum_ee,0)
 ,psum_nds  = IsNull(bsum_nds,0)  - IsNull(esum_nds,0)  + IsNull(nsum_nds,0)
 ,psum_exc  = IsNull(bsum_exc,0)  - IsNull(esum_exc,0)  + IsNull(nsum_exc,0)
where
Date_calc = @dtCurEnd

--------------------------------------------------------------------------------------------------
--Занесение результатов в основную таблицу                                                        |
--------------------------------------------------------------------------------------------------

delete from ProDivSal where Date_calc = @dtCurEnd  --!!!!
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
from  #TmpProDivSal

-- Удаление временных таблиц
drop table #EndBallance   -- сальдо на конец месяца
drop table #Charges       -- начисления
drop table #TmpProDivSal  -- временная таблица общего расчета	




GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

