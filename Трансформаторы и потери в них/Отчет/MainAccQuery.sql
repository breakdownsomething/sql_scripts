declare
  @account_id             int,
  @main_account_id        int,
  @date_calc_end          smalldatetime, -- конец текущего
                                         -- расчетного периода
  @date_calc_beg          smalldatetime, -- начало текущего
                                         -- расчетного периода

  @report_date_calc_end   smalldatetime, -- конец расчетного периода
                                         -- за который выдается отчет
  @report_date_calc_beg   smalldatetime, -- начало расчетного периода
                                         -- за который выдается отчет
-- служебные переменные
  @last_action_id int -- последние действие по счетчику
 ,@days           int -- кол-во дней работы без счетчика
 ,@CurDate        datetime -- переменная даты для использования в цыкле
 ,@CountFlag      int -- 0 - в этот день счетчик был, 1 - не было


--select * from ProContracts where contract_number = 50033
--select * from ProAccounts where contract_id = 204015


-- Входящий параметр - номер точки учета "потери в трансформаторе"
select @account_id           = 500330106,--:account_id,
-- Входящий параметр - начало расчетного периода за который выдается отчет
       @report_date_calc_beg = convert(smalldatetime,'2004-10-01')--:DATE_CALC)

select @report_date_calc_end = dateadd(dd,-1,dateadd(mm,+1,@report_date_calc_beg))

-- Определение текущего расчетного периода
select @date_calc_beg = (select top 1 date_calc_begin from ProGroups)
select @date_calc_end = (select top 1 date_calc_end from ProGroups)

-- создание временной таблицы, в которой
-- будет храниться итоговый набор данных
if object_id('tempdb..#TmpTrancAcc') is not null
begin
  drop table #TmpTrancAcc
end

create table #TmpTrancAcc
(
ACCOUNT_ID              int not null,
ACCOUNT_NAME            varchar(60) not null,
TARIFF_VALUE            decimal(9,4) null,
TARIFF_NAME             varchar(60) null,
TRANC_POWER_METHOD_ID   int not null,
TRANC_POWER_METHOD_NAME varchar(80) not null,
CNT_QUANTITY            int         null,
ADD_QUANTITY            int         null,
NO_CNT_DAYS             smallint    null,
ALL_DAYS                smallint    null,
SUM_QUANTITY            int         null,
LOSSES                  int         null
)

-- Заполняется #TmpTrancAcc различными запросами
-- в зависимости в зависимости от того, за какой
-- расчетный период выдается отчет, за текущий
-- или за какой-то прошлый
if  @report_date_calc_beg = @date_calc_beg
begin -- за текущий
  insert into #TmpTrancAcc
  (
  ACCOUNT_ID,
  ACCOUNT_NAME,
  TARIFF_VALUE,
  TARIFF_NAME,
  TRANC_POWER_METHOD_ID,
  TRANC_POWER_METHOD_NAME,
  CNT_QUANTITY,
  ADD_QUANTITY,
  NO_CNT_DAYS,
  ALL_DAYS,
  SUM_QUANTITY,
  LOSSES
  )
  select
    ACCOUNT_ID   = PTPA.TRANC_POWER_ACCOUNT_ID,
    ACCOUNT_NAME = '['+convert(varchar(12),PTPA.TRANC_POWER_ACCOUNT_ID)+'] '+PA.account_name,
    TARIFF_VALUE = PTV.tariff_value,
    TARIFF_NAME  = '['+convert(varchar(5),convert(decimal(6,2),PTV.tariff_value))+'] '
                   +PT.tariff_name,
    TRANC_POWER_METHOD_ID = PA.TRANC_POWER_METHOD_ID,
    TRANC_POWER_METHOD_NAME = PTPM.TRANC_POWER_METHOD_NAME,
    CNT_QUANTITY = convert(int,isnull((
                                    /*  select pcc.quantity - pcc.add_quantity - pcc.add_hcp
                                        from ProCntCounts     PCC  (nolock)
                                        where  PA.account_id = PCC.account_id and
                                               PCC.date_id   = @date_calc_end */
                                        -- Расход можно брать из ProCntCounts или ProCalcDetails
                                        -- Из ProCalcDetails надежнее в смысле сходимости с
                                        -- другими отчетами
                                        select PCD.calc_quantity - PCD.add_quantity - PCD.add_hcp
                                        from ProCalcs       PC   (nolock),
                                             ProCalcDetails PCD  (nolock)
                                        where PC.contract_id = PA.contract_id  and
                                              PC.date_calc   = @date_calc_end  and
                                              PC.calc_id     = PCD.calc_id     and
                                              PCD.source_id  = PA.account_id
                                       ),0)),
    ADD_QUANTITY = convert(int,isnull((
                                     /* select pcc.add_quantity
                                        from ProCntCounts     PCC  (nolock)
                                        where  PA.account_id = PCC.account_id and
                                               PCC.date_id   = @date_calc_end */
                                        select PCD.add_quantity
                                        from ProCalcs       PC   (nolock),
                                             ProCalcDetails PCD  (nolock)
                                        where PC.contract_id = PA.contract_id  and
                                              PC.date_calc   = @date_calc_end  and
                                              PC.calc_id     = PCD.calc_id     and
                                              PCD.source_id  = PA.account_id
                                      ),0)),
    null,
    null,
    null,
    null
  from ProTrancPowerAcc PTPA (nolock),
       ProAccounts      PA   (nolock),
       ProTariffs       PT   (nolock),
       ProTAriffValues  PTV  (nolock),
       ProTrancPowerMethods PTPM (nolock)
  where PTPA.tranc_power_account_id = PA.account_id and
        PTPA.account_id  = @account_id  and
        (PTPA.date_calc_end is null or
         PTPA.date_calc_end = @date_calc_end
        ) and
        PA.tariff_id = PT.tariff_id  and
        PA.tariff_id = PTV.tariff_id and
        PT.serv_id   = PTV.serv_id   and
        PTV.date_calc =(
                        select max(PTV1.date_calc)
                        from ProTariffValues PTV1
                        where
                         PTV1.tariff_id = PA.tariff_id and
                         PTV1.serv_id   = PT.serv_id
                        ) and
        PA.TRANC_POWER_METHOD_ID = PTPM.TRANC_POWER_METHOD_ID
end
else
begin -- за прошлый расчетный период
  insert into #TmpTrancAcc
  (
  ACCOUNT_ID,
  ACCOUNT_NAME,
  TARIFF_VALUE,
  TARIFF_NAME,
  TRANC_POWER_METHOD_ID,
  TRANC_POWER_METHOD_NAME,
  CNT_QUANTITY,
  ADD_QUANTITY,
  NO_CNT_DAYS,
  ALL_DAYS,
  SUM_QUANTITY,
  LOSSES
  )
  select
    ACCOUNT_ID   = PTPA.TRANC_POWER_ACCOUNT_ID,
    ACCOUNT_NAME = '['+convert(varchar(12),PTPA.TRANC_POWER_ACCOUNT_ID)+'] '+PA.account_name,
    TARIFF_VALUE = PTV.tariff_value,
    TARIFF_NAME  = '['+convert(varchar(5),convert(decimal(6,2),PTV.tariff_value))+'] '
                   +PT.tariff_name,
    TRANC_POWER_METHOD_ID = PA.TRANC_POWER_METHOD_ID,
    TRANC_POWER_METHOD_NAME = PTPM.TRANC_POWER_METHOD_NAME,
    CNT_QUANTITY = convert(int,isnull((/* select pcc.quantity - pcc.add_quantity - pcc.add_hcp
                                        from ProCntCounts     PCC  (nolock)
                                        where  PA.account_id = PCC.account_id and
                                               PCC.date_id   = @report_date_calc_end
                                        */
                                        select PCD.calc_quantity - PCD.add_quantity - PCD.add_hcp
                                        from ProCalcs       PC   (nolock),
                                             ProCalcDetails PCD  (nolock)
                                        where PC.contract_id = PA.contract_id  and
                                              PC.date_calc   = @date_calc_end  and
                                              PC.calc_id     = PCD.calc_id     and
                                              PCD.source_id  = PA.account_id
                                       ),0)),
    ADD_QUANTITY = convert(int,isnull(( /*
                                        select pcc.add_quantity
                                        from ProCntCounts     PCC  (nolock)
                                        where  PA.account_id = PCC.account_id and
                                               PCC.date_id   = @report_date_calc_end
                                         */
                                         select PCD.add_quantity
                                        from ProCalcs       PC   (nolock),
                                             ProCalcDetails PCD  (nolock)
                                        where PC.contract_id = PA.contract_id  and
                                              PC.date_calc   = @date_calc_end  and
                                              PC.calc_id     = PCD.calc_id     and
                                              PCD.source_id  = PA.account_id
                                      ),0)),
    null,
    null,
    null,
    null
  from ProTrancPowerAcc PTPA (nolock),
       ProAccountsArc   PA   (nolock),
       ProTariffs       PT   (nolock),
       ProTAriffValues  PTV  (nolock),
       ProTrancPowerMethods PTPM (nolock)
  where PTPA.tranc_power_account_id = PA.account_id and
        PTPA.account_id  = @account_id  and
        PA.date_begin    = @report_date_calc_end and
         -- время жизни ссылки содержит расчетный период,
         -- за который выдается отчет
         (PTPA.date_calc_beg <= @report_date_calc_end and
         (PTPA.date_calc_end is null or
          PTPA.date_calc_end >= @report_date_calc_end)) and

--select contract_id from ProContracts where contract_number = 5372
--select * from ProTrancPowerAcc where contract_id = 17915
--delete from ProTrancPowerAcc where date_calc_beg = '2004-10-31'

        PA.tariff_id = PT.tariff_id  and
        PA.tariff_id = PTV.tariff_id and
        PT.serv_id   = PTV.serv_id   and
        PTV.date_calc =(
                        select max(PTV1.date_calc)
                        from ProTariffValues PTV1
                        where
                         PTV1.tariff_id = PA.tariff_id and
                         PTV1.serv_id   = PT.serv_id and
                         PTV1.date_calc <= @report_date_calc_end
                        ) and
        PA.TRANC_POWER_METHOD_ID = PTPM.TRANC_POWER_METHOD_ID
end


-- Расчет количества дней работы
-- без счетчика для каждой точки учета

declare curTmpTrancAcc cursor static for
select ACCOUNT_ID
from #TmpTrancAcc

-- создаем табличку в которую будут заносится
-- все действия отключения/подключения, снятие/установка  и замена
-- по отдельной точке учета
if OBJECT_ID('TempDB..#TmpActions') is not null
begin
  drop table #TmpActions
end
create table #TmpActions
(
date_id     smalldatetime not null,
action_id   int           not null,
action_name varchar(40)   null
)

open curTmpTrancAcc
fetch next from curTmpTrancAcc into @main_account_id
while (@@fetch_status <> -1)
  begin
  --<1>---------------------------------------------------
  -- заполняем табличку с действиями
  truncate table #TmpActions

  insert into #TmpActions(date_id, action_id, action_name)
  select date_id     = pcad.date_id
        ,action_id   = pcad.action_id
        ,action_name = cal.action_name
  from  ProCntActionDates pcad (nolock)
       ,CntActionList     cal  (nolock)
       ,ProCnt            pc   (nolock)
  where pcad.action_id    = cal.action_id
    and pcad.account_id   = @main_account_id
    and pcad.delete_sign  = 0
    and pcad.action_id   in (1,10,7,8,2)
    and date_id          <= @report_date_calc_end
    and pcad.account_id   = pc.account_id
    and pcad.counter_number_id = pc.counter_number_id
  order by pcad.date_id

  --<2>----------------------------------------------
  -- определяем каким было последние действие
  select @last_action_id = action_id
  from #TmpActions
  where date_id = (select max(date_id) from #TmpActions)
  -- если на конец месяца счетчик снят или отключен начинаем
  -- считать дни с той даты когда его сняли/отключили т.е до этого
  -- момента счетчик был и работал
  select @CurDate  = case when @last_action_id in (1,8,2) -- подключение, установка
                          then @report_date_calc_end
                          when @last_action_id in (10,7) -- отключение, снятие
                          then (select max(date_id) from #TmpActions)
                          end
  select @days = 0
  select @last_action_id = 0
  select @CountFlag = 1

  while @CurDate >= @report_date_calc_beg
    begin
    select @last_action_id =isnull((select action_id
                                    from #TmpActions
                                    where date_id = @CurDate),@last_action_id)
    select
    @CountFlag = case when @last_action_id in (1,8,2)  then 0
                      when @last_action_id in (10,7) then 1
                      else @CountFlag end
    select @days = case when @CountFlag = 1 then @days + 1
                        when @CountFlag = 0 then @days end
    select @CurDate = dateadd(dd,-1,@CurDate)
    end

    update #TmpTrancAcc
    set
      NO_CNT_DAYS = (datediff(dd,@report_date_calc_beg,@report_date_calc_end)+1) - @days,
      ALL_DAYS    = datediff(dd,@report_date_calc_beg,@report_date_calc_end)+1
    where ACCOUNT_ID = @main_account_id

    ---------------- Расчет фактического расхода за месяц ---------------
    ---------------используемого для расчета потерь в тр-ре--------------
    update #TmpTrancAcc
    set
      SUM_QUANTITY = case when TRANC_POWER_METHOD_ID = 3 -- по фиксированному
                                                         -- потреблению
                          then 0
                          when TRANC_POWER_METHOD_ID in (1, 4)
                          then CNT_QUANTITY
                          when TRANC_POWER_METHOD_ID in (2, 5)
                          then case when (ADD_QUANTITY = 0)
                                    then case when (ALL_DAYS = NO_CNT_DAYS)
                                              then CNT_QUANTITY
                                              else CNT_QUANTITY + CNT_QUANTITY
                                                   * NO_CNT_DAYS/(ALL_DAYS-NO_CNT_DAYS)
                                                    end
                                    else CNT_QUANTITY + ADD_QUANTITY end
                          end

    where ACCOUNT_ID = @main_account_id
    ---------------------------------------------------------------------

    ----------------- Расчет потерь-------------------------------------
    update #TmpTrancAcc
    set
    LOSSES = case when TRANC_POWER_METHOD_ID = 3
                  then case when (@report_date_calc_end = @date_calc_end)
                            then (select CALC_FACTOR
                                  from ProAccounts
                                  where account_id = @main_account_id)
                            else (select CALC_FACTOR
                                  from ProAccountsArc
                                  where account_id = @main_account_id and
                                        date_begin = @report_date_calc_end)
                            end
                  when TRANC_POWER_METHOD_ID in (4,5)
                  then round((SUM_QUANTITY * 0.025),0)
                  else 0 -- для первого и второго методов расчет потерь
                         -- берется из справочника потерь в трансформаторах
                  end
    where ACCOUNT_ID = @main_account_id
    -----------------------------------------------------------------------

  fetch next from curTmpTrancAcc into @main_account_id
  end
close curTmpTrancAcc
deallocate curTmpTrancAcc

drop table #TmpActions

select
ACCOUNT_ID,
ACCOUNT_NAME,
TARIFF_VALUE,
TARIFF_NAME,
TRANC_POWER_METHOD_ID,
TRANC_POWER_METHOD_NAME,
CNT_QUANTITY,
ADD_QUANTITY,
NO_CNT_DAYS,
ALL_DAYS,
SUM_QUANTITY,
LOSSES
from
 #TmpTrancAcc
order by account_id
drop table #TmpTrancAcc



