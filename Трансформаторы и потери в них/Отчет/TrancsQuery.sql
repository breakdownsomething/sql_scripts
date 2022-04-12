declare
  @account_id              int,
  @cur_date_calc           smalldatetime, -- конец расчетного периода,
                                          -- за который выдается отчет
  @prev_date_calc          smalldatetime, -- конец расчетного периода,
                                          -- предшествовавшего отчетному
  @base_date_calc          smalldatetime, -- текущий расчетный период 
                                          -- по базе
  @tranc_power_change_date smalldatetime, -- дата замены трансформатора
  @cur_tranc_power_id      int,           -- текущий трансформатор
  @prev_tranc_power_id     int,           -- предыдущий трансформатор
  @year                    smallint,
  @month                   smallint


select @account_id = 500330106, -- :ACCOUNT_ID
       @cur_date_calc = convert(smalldatetime,'2004-09-01') -- :DATE_ID     
select @cur_date_calc = dateadd(dd,-1,dateadd(mm,+1,@cur_date_calc))

select @base_date_calc = '2004-10-31'--(select top 1 date_calc_end from ProGroups)

select @prev_date_calc =
dateadd(dd,-1,
dateadd(mm,-1,
dateadd(dd,+1,@cur_date_calc)))


if @cur_date_calc = @base_date_calc
-- если отчет выдается за текущий расчетный период
-- тогда данные по трансформаторам берем из ProAccounts
-- если за прошедший то из ProAccountsArc
begin
  select
  @cur_tranc_power_id = tranc_power_id,
  @tranc_power_change_date = tranc_power_change_date
  from ProAccounts
  where account_id = @account_id
end
else
begin
  select
  @cur_tranc_power_id = tranc_power_id,
  @tranc_power_change_date = tranc_power_change_date
  from ProAccountsArc
  where account_id = @account_id
    and date_begin = @cur_date_calc
end


if @tranc_power_change_date < @prev_date_calc
begin
select @tranc_power_change_date = @prev_date_calc
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
                                       dateadd(dd,+1,@cur_date_calc)
                                       ),
tranc_power_work_days_text  = 'работал с '+
                               convert(varchar(10),@tranc_power_change_date,104)+
                              ' по '+
                               convert(varchar(10),dateadd(dd,0,@cur_date_calc),104),
all_month_days              = datediff(day,@prev_date_calc,@cur_date_calc),
part = null,
losses = PL.first_tranc_power_losses,
load_coeff = PL.first_tranc_power_coef,
numbert = 1
from ProTrancPowerList PTPL (nolock),
     ProTrancPowerLosses PL (nolock)
where PTPL.tranc_power_id = @cur_tranc_power_id and
      PL.account_id = @account_id and
      PL.date_calc  = @cur_date_calc

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
  all_month_days              = datediff(day,@prev_date_calc,@cur_date_calc),
  part                        = null,
  losses = PL.second_tranc_power_losses,
  load_coeff = PL.second_tranc_power_coef,
  number                      = 2
  from ProTrancPowerList PTPL (nolock),
       ProTrancPowerLosses PL (nolock)
  where PTPL.tranc_power_id = @prev_tranc_power_id and
        PL.account_id = @account_id and
        PL.date_calc  = @cur_date_calc
end

update #TmpTrancWorks
set
part = convert(varchar(10),
              convert(decimal(5,1),
                      100.0*(tranc_power_work_days)/(all_month_days))
              )+'%'

select * from #TmpTrancWorks
order by number


--select * from ProTrancPowerLosses where account_id = 500330106
--select * from ProAccountsArc where account_id = 500330106