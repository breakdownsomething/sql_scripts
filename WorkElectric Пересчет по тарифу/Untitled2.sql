
declare
-- входящие параметры
  @iAccountId     int,           -- Номер абонента
  @tiServId     	tinyint,       -- Номер услуги
  @dtBegin        smalldatetime, -- Дата начала отсчета
  @dtEnd          smalldatetime, -- Дата конца отсчета
-- внутренние переменные
	@Year           smallint,      -- Год
	@Month          tinyint,       -- Месяц
	@BaseName       varchar(15),   -- aspBaseXXXX_XX
	@FileName       varchar(30),   -- aspBaseXXXX_XX..TarifValues
  @Tarif_id       int,           -- Номер тарифа
  @NewTarifValue  decimal(9,4),
  @LastBase       varchar(40)    -- Имя текущего aspBase-а

select
  @iAccountId	    = 210420,--11010,
  @tiServId       = 13, 
  @dtBegin        = convert(smalldatetime,'1998.08.01'),
  @dtEnd          = convert(smalldatetime,'2004.06.01')


  -- проверка корректности полученных значений ---------------------------------------

if @dtBegin < convert(smalldatetime,'1998.08.01') -- начало жизни aspBase
  begin
    select @dtBegin = convert(smalldatetime,'1998.08.01')

  end
if @dtEnd > getdate()
  begin
    select @dtEnd = getdate()
  end

  -- Определение номера тарифа на текущий момент --------------------------------------
if exists (select * from tempdb..sysobjects where id = object_id('tempdb..#Tmp1'))
  begin 
    drop table #Tmp1
  end
create table #Tmp1(tarif_id int,
                   tarif_value decimal(9,4))

select @LastBase = 'aspBase'+ convert(char(4),(SELECT YEAR FROM aspCommon..YearMonth))
                + '_'
                + right(convert(char(3),100 + (SELECT Month FROM aspCommon..YearMonth)),2)

exec('
insert into #Tmp1
select SS.tarif_id,
       TV.tarif_value 
from '+@LastBase+'..SumServices SS (nolock),
     '+@LastBase+'..TarifValues TV (nolock)
where
     SS.account_id   = '+@iAccountId+'
and SS.serv_id   = '+@tiServId+' 
and SS.tarif_id = TV.tarif_id
and SS.serv_id  = TV.serv_id 
and SS.suppl_id = TV.suppl_id
and SS.suppl_id = 600 ')

select @Tarif_id      =  tarif_id,
       @NewTarifValue =  tarif_value
from #Tmp1 
drop table #Tmp1 


--- Создание итоговой таблицы

IF  EXISTS (select * from Tempdb..sysobjects where id = object_id('Tempdb..#ShowPays') )
  begin
   drop table #ShowPays
  end 

CREATE TABLE  #ShowPays(
    date_year       int,
    date_month      int,
    SUM_PAY         decimal(9,2),
    TARIF_ID        int          null,
    OLD_TARIF       decimal(9,4) null,
    NEW_TARIF       decimal(9,4) null,
    OLD_COUNT_PAY   int,
    NEW_COUNT_PAY   int           null,
    DIFF            int           null)

-- Заполнение итоговой таблицы

INSERT INTO
	#ShowPays
SELECT
	date_year      = year(DRP.DATE_ID),
  date_month     = month(DRP.DATE_ID),
	SUM_PAY        = sum(DRP.SUM_PAY),
  null,
  null,
  null,
	OLD_COUNT_PAY  = sum(DRP.COUNT_PAY),
  null,
  null
FROM
	Rcp                      R   (NOLOCK),
	RcpPays	                 RP  (NOLOCK),
	DayRcpPays               DRP (NOLOCK)
WHERE
	R.ACCOUNT_ID       = @iAccountId    	 AND
	RP.DATE_ID         = R.DATE_ID				 AND
  RP.LABEL_NUMBER    = R.LABEL_NUMBER		 AND
	RP.RECIEPT_NUMBER  = R.RECIEPT_NUMBER	 AND
	RP.SERV_ID         = @tiServId				 AND
	DRP.DATE_ID        = RP.DATE_ID				 AND
 	DRP.LABEL_NUMBER   = RP.LABEL_NUMBER	 AND
	DRP.RECIEPT_NUMBER = RP.RECIEPT_NUMBER AND
	DRP.SERV_ID        = RP.SERV_ID        AND
  DRP.DATE_ID        between @dtBegin and @dtEnd

GROUP BY
  month(DRP.DATE_ID), 
  year(DRP.DATE_ID)

-- определение значений тарифа за старые периоды

declare curTarifs cursor static for
select date_year,
       date_month
from #ShowPays
open curTarifs
fetch  next from curTarifs into
 @Year, @Month

while (@@FETCH_STATUS <> -1)
  begin

  select
	@BaseName = 'aspBase'+convert(varchar(4),@Year)+'_'+right(convert(varchar(3),100+@Month),2)

  exec('
       update #ShowPays
       set OLD_TARIF = TV.tarif_value,
           NEW_TARIF = LTV.tarif_value,
           TARIF_ID  = TV.tarif_id

       from '+@BaseName+'..SumServices SS (nolock),
            '+@BaseName+'..TarifValues TV (nolock),
            '+@LastBase+'..TarifValues LTV (nolock)
       where
           SS.account_id   = '+@iAccountId+'
       and SS.serv_id   = '+@tiServId+' 
       and SS.tarif_id = TV.tarif_id
       and SS.serv_id  = TV.serv_id 
       and SS.suppl_id = TV.suppl_id

       and SS.tarif_id = LTV.tarif_id
       and SS.serv_id  = LTV.serv_id 
       and SS.suppl_id = LTV.suppl_id

       and SS.suppl_id = 600
 
       and date_year = '+@Year+'
       and date_month = '+@Month+'
       ')


    fetch  next from curTarifs into
    @Year, @Month
  end

close curTarifs
deallocate curTarifs

update #ShowPays
set NEW_COUNT_PAY = round((SUM_PAY/NEW_TARIF),0),
    DIFF          = OLD_COUNT_PAY - round((SUM_PAY/NEW_TARIF),0) 


select
'date' = right(convert(varchar(3),100 + date_month),2) +'-'+convert(char(4),date_year),
--'month' = right(convert(varchar(3),100 + date_month),2),
--'year'  = convert(char(4),date_year),
sum_pay,
old_tarif,
new_tarif,
old_count_pay,
new_count_pay,
diff
from #ShowPays
order by
  convert(datetime,right(convert(varchar(3),100 + date_month),2)+'-'+convert(char(4),date_year)+'-01')
  desc