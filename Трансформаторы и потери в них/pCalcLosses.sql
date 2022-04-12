-- Temporary Code
--declare
--@account_id int
--select @account_id = 133200102
---------------------
IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pCalcLosses' 
	   AND 	  type = 'P')
    DROP PROCEDURE pCalcLosses
GO

CREATE PROCEDURE dbo.pCalcLosses
  @account_id int
AS
/*
 Copyright 2004 ЗАО “Алсеко”. All rights reserved.
 Name:                pCalcLosses
 Short Description:   Процедура расчета потерь в трансформаторе
 in parameter  1:     @account_id int - точка учета "потери в трансформаторе"
 Result:              'ERROR' или 'OK'
 Autor:	              Матесов Д.С.
 Date:	   	          27.10.2004
*/
------------------------------- BEGIN ---------------------------------
declare
@RESULT varchar(10) -- Результат выплнения процедуры

if isnull((select AUDIT_PARAM_ID from ProAccounts 
   where account_id = @account_id),0) <> 2 
begin
  select @RESULT = 'ERROR'
end
else
begin
-- <1> - Begin - Расчет потерь на точках  
  declare
  @main_account_id        int,
  @date_calc_end          smalldatetime, -- конец месяца
  @date_calc_beg          smalldatetime, -- начало месяца

  -- служебные переменные
  @last_action_id int -- последние действие по счетчику
 ,@days           int -- кол-во дней работы без счетчика
 ,@CurDate        datetime -- переменная даты для использования в цыкле
 ,@CountFlag      int -- 0 - в этот день счетчик был, 1 - не было

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
  CNT_QUANTITY = convert(int,isnull(( select pcc.quantity - pcc.add_quantity - pcc.add_hcp
                                      from ProCntCounts     PCC  (nolock)
                                      where  PA.account_id = PCC.account_id and
                                             PCC.date_id   = @date_calc_end
                                     ),0)),
  ADD_QUANTITY = convert(int,isnull((select pcc.add_quantity
                                      from ProCntCounts     PCC  (nolock)
                                      where  PA.account_id = PCC.account_id and
                                             PCC.date_id   = @date_calc_end
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
      and date_id          <= @date_calc_end
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
                            then @date_calc_end
                            when @last_action_id in (10,7) -- отключение, снятие
                            then (select max(date_id) from #TmpActions)
                            end
    select @days = 0
    select @last_action_id = 0
    select @CountFlag = 1

    while @CurDate >= @date_calc_beg
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
        NO_CNT_DAYS = (datediff(dd,@date_calc_beg,@date_calc_end)+1) - @days,
        ALL_DAYS    = datediff(dd,@date_calc_beg,@date_calc_end)+1
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
                    then (select CALC_FACTOR
                          from ProAccounts
                          where account_id = @main_account_id)
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
/*
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
*/
-- <1> End -------------

-- <2> Begin - Расчет потерь в трансформаторах
  declare
    @prev_date_calc          smalldatetime, -- конец предыдущего месяца
    @tranc_power_change_date smalldatetime, -- дата замены трансформатора
    @cur_tranc_power_id      int,           -- текущий трансформатор
    @prev_tranc_power_id     int,           -- предыдущий трансформатор
    @year                    smallint,
    @month                   smallint

  select @prev_date_calc =
    dateadd(dd,-1,
    dateadd(mm,-1,
    dateadd(dd,+1,@date_calc_end)))

  select
    @cur_tranc_power_id = tranc_power_id,
    @tranc_power_change_date = tranc_power_change_date
  from ProAccounts
  where account_id = @account_id

  if @tranc_power_change_date < @prev_date_calc
  begin
    select @tranc_power_change_date = dateadd(dd,+1,@prev_date_calc)
  end

  select
    @prev_tranc_power_id = tranc_power_id
  from ProAccountsArc
  where account_id = @account_id and
        date_begin = @prev_date_calc

  if object_id('tempdb..#TmpTrancWorks') is not null
  begin
    drop table #TmpTrancWorks
  end

  create table #TmpTrancWorks
  (
  tranc_power_id int not null,
  tranc_power_name varchar(40) not null,
  tranc_power_work_days int not null,
  tranc_power_work_days_text varchar(80) not null,
  all_month_days int not null,
  part varchar(10) null,
  losses int null,
  load_coeff int null,
  number     int null
  )

  -- Вставка данных по текущему трансформатору
  insert into #TmpTrancWorks  
  (
  tranc_power_id,
  tranc_power_name,
  tranc_power_work_days,
  tranc_power_work_days_text,
  all_month_days,
  part,
  losses,
  load_coeff,
  number 
  )
  select
  tranc_power_id              = @cur_tranc_power_id,
  tranc_power_name            = PTPL.tranc_power_name,
  tranc_power_work_days       = datediff(day,@tranc_power_change_date,
                                       dateadd(dd,+1,@date_calc_end)
                                         ),
  tranc_power_work_days_text  = 'работал с '+
                                 convert(varchar(10),@tranc_power_change_date,104)+
                                ' по '+
                                 convert(varchar(10),dateadd(dd,0,@date_calc_end),104),
  all_month_days              = datediff(day,@prev_date_calc,@date_calc_end),
  part = null,
  losses = null,
  load_coeff = null,
  numbert = 1
  from ProTrancPowerList PTPL (nolock)
  where PTPL.tranc_power_id = @cur_tranc_power_id

  -- Вставка данных по предыдущему трансформатору

  if (@prev_tranc_power_id is not null) and
     (datediff(day,
              dateadd(dd,+1,@prev_date_calc),
              @tranc_power_change_date) > 0)
  begin
    insert into #TmpTrancWorks
    (
    tranc_power_id,
    tranc_power_name,
    tranc_power_work_days,
    tranc_power_work_days_text,
    all_month_days,
    part,
    losses,
    load_coeff,
    number
    )
    select
    tranc_power_id              = @prev_tranc_power_id,
    tranc_power_name            = PTPL.tranc_power_name,
    tranc_power_work_days       = datediff(day,
                                           dateadd(dd,+1,@prev_date_calc),
                                           @tranc_power_change_date),
    tranc_power_work_days_text  = 'работал с '+
                                   convert(varchar(10),
                                           dateadd(dd,+1,@prev_date_calc),
                                           104)+
                                  ' по '+
                                   convert(varchar(10),dateadd(dd,-1,@tranc_power_change_date),104),
    all_month_days              = datediff(day,@prev_date_calc,@date_calc_end),
    part                        = null,
    losses                      = null,
    load_coeff                  = null,
    number                      = 2
    from ProTrancPowerList PTPL (nolock)
    where PTPL.tranc_power_id = @prev_tranc_power_id
  end

  update #TmpTrancWorks
  set
  part = convert(varchar(10),
                convert(decimal(5,1),
                        100.0*(tranc_power_work_days)/(all_month_days))
                )+'%'

  -- расчет коэффициента загрузки и собственно потерь
  declare
  @FACT_QUANTITY  int, -- фактический расход
  @tranc_power_id int,
  @tranc_power_work_days_text  varchar(80),
  @rate           int,
  @losses         decimal(12,2) 

  select @FACT_QUANTITY = sum(SUM_QUANTITY)
  from #TmpTrancAcc
  where TRANC_POWER_METHOD_ID in (1,2)

  declare curTrancs cursor static 
  for
  select
    tranc_power_id,
    tranc_power_work_days_text
  from #TmpTrancWorks

  open curTrancs  

  fetch next from curTrancs
  into @tranc_power_id, @tranc_power_work_days_text
  while (@@fetch_status <> -1)
  begin

  select  @rate =
    convert(int,
    round(100*@FACT_QUANTITY/(730 * 0.9 * (select tranc_power_capacity
                                      from ProTrancPowerList
                                      where tranc_power_id = @tranc_power_id
                                     )
                        )
         ,0)
          )
  if @rate > 100
  select @rate = 100
  
  select @losses = dbo.fn_Tranc_Power_Loss(@tranc_power_id, @FACT_QUANTITY)

  update #TmpTrancWorks
  set losses = round(@losses  * tranc_power_work_days/all_month_days,0),
      load_coeff = @rate
  where tranc_power_work_days_text = @tranc_power_work_days_text

  fetch next from curTrancs
  into @tranc_power_id, @tranc_power_work_days_text
  end
  close curTrancs
  deallocate curTrancs

--select * from #TmpTrancWorks

-- <2> End - Расчет потерь в трансформаторах
-- <3> Begin - Занесение результатов расчетов в ProTrancPowerLosses
  declare
  @all_losses int,  -- общее количество потерь по точке учета
  @first_tranc_power_coef int,
  @first_tranc_power_losses int,
  @second_tranc_power_coef int,
  @second_tranc_power_losses int
    
  select @all_losses = sum(LOSSES)
  from #TmpTrancAcc

  select @all_losses = @all_losses +
                       (select sum(losses)
                        from #TmpTrancWorks)

  select 
    @first_tranc_power_coef   = load_coeff,
    @first_tranc_power_losses = losses
  from #TmpTrancWorks
  where number = 1
  
  select 
    @second_tranc_power_coef   = load_coeff,
    @second_tranc_power_losses = losses
  from #TmpTrancWorks
  where number = 2

  if exists (select * from ProTrancPowerLosses (nolock) where
             account_id = @account_id and
             date_calc  = @date_calc_end)
  begin
    update ProTrancPowerLosses
    set
      ALL_LOSSES                = @all_losses,
      FIRST_TRANC_POWER_COEF    = @first_tranc_power_coef,
      FIRST_TRANC_POWER_LOSSES  = @first_tranc_power_losses,
      SECOND_TRANC_POWER_COEF   = @second_tranc_power_coef,
      SECOND_TRANC_POWER_LOSSES = @second_tranc_power_losses,
      COMMENT                   = 'расчет произведен '+convert(varchar(20),getdate())
    where
       account_id = @account_id and
       date_calc  = @date_calc_end
  end
  else
  begin
    insert into ProTrancPowerLosses
    (
    ACCOUNT_ID,
  	DATE_CALC,
    ALL_LOSSES,
	  FIRST_TRANC_POWER_COEF,
	  FIRST_TRANC_POWER_LOSSES,
	  SECOND_TRANC_POWER_COEF,
	  SECOND_TRANC_POWER_LOSSES,
	  COMMENT
    )
    values
    (
    @account_id,
    @date_calc_end,
    @all_losses,
    @first_tranc_power_coef,
    @first_tranc_power_losses,
    @second_tranc_power_coef,
    @second_tranc_power_losses,
    'расчет произведен '+convert(varchar(20),getdate())
    )
  end

  ----------- Занесение данных о том, что требуется
  ----------- перерасчет начислений
  declare @contract_id int

  select @contract_id = contract_id
  from   ProAccounts
  where account_id = @account_id

  if exists (select * from ProCalcs
             where contract_id = @contract_id and
                   date_calc = @date_calc_end )
  begin
  update ProCalcs
  --------------------------
    set    BILL_NUMBER = ''
  --------------------------
  where contract_id = @contract_id and
        date_calc = @date_calc_end
  end

-- <3> End------------
  select @RESULT = 'OK'
  drop table #TmpTrancAcc
  drop table #TmpTrancWorks
end
------------------------------- END -----------------------------------
select RESULT = @RESULT
GO



