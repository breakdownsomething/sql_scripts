 declare
  @contract_number int,
  @date_id         smalldatetime,
  @s_date_id       varchar(20),
  @account_id      int,

  @main_account_id   varchar(12),
  @main_account_name varchar(40),
  @main_tariff_value varchar(20),
  @main_tariff_name  varchar(65),
  @quantity          int,

  @use_days          tinyint,
  @tranc_power_coef  int,
  @loss_quantity     int

select
  @contract_number =  130652, --:contract_number,
  @s_date_id       =  '2004-09-01'  --:date_id

select @date_id = dateadd(dd,-1,(dateadd(mm,+1,convert(smalldatetime,@s_date_id))))

IF OBJECT_ID('tempdb..#TmpLossAccounts') is not null
  DROP TABLE #TmpLossAccounts

create table #TmpLossAccounts
( -- точка учета потери
 account_id       int     not null,
 account_name     varchar(60) null,
 tariff_value     decimal(8,2) null,
 tariff_name      varchar(80) null,
 use_days         tinyint null,
 tranc_power_coef int     null,
 tranc_power_method_id int null,
 tranc_power_method_name varchar(60) null,
 loss_quantity    int     null,
-- основная точка учета
 main_account_id  int     null,
 main_account_name varchar(60) null,
 main_tariff_name  varchar(80) null,
 main_tariff_value decimal(8,2) null,
 quantity          int          null,
 tranc_power_name  varchar(20)  null
)

insert into #TmpLossAccounts( account_id,
                              account_name,
                              tariff_value,
                              tariff_name,
                              use_days,
                              tranc_power_coef,
                              tranc_power_method_id,
                              tranc_power_method_name,
                              loss_quantity,
                              main_account_id,
                              main_account_name,
                              main_tariff_name,
                              main_tariff_value,
                              quantity,
                              tranc_power_name
                             )
select  PA.account_id,
        null,
        null,
        null,
        null,
        null,
        PA.tranc_power_method_id,  
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        tranc_power_name

from ProAccounts  PA (nolock),
     ProContracts PC (nolock),
     ProTrancPowerList PTPL (nolock)
where PA.contract_id = PC.contract_id and
      PC.contract_number = @contract_number and
      PA.tranc_power_id is not null and
      PA.tranc_power_account_id is not null and
      PA.tranc_power_method_id is not null and
      PA.tranc_power_id = PTPL.tranc_power_id

--select * from #TmpLossAccounts

update #TmpLossAccounts
set
use_days          = PTPL.use_days,
tranc_power_coef  = PTPL.tranc_power_coef,
loss_quantity     = PTPL.loss_quantity,
account_name      = PA.account_name,
tariff_value      = PTV.tariff_value,
tariff_name       = '['+convert(varchar(3),pt.tariff_id)+']'+
                       convert(varchar(60),isnull(pt.tariff_name,'-нет-')),
tranc_power_method_name = prpm.tranc_power_method_name,
main_account_id   = PA.tranc_power_account_id
from ProTrancPowerLoss PTPL (nolock),
     #TmpLossAccounts  TMP  (nolock),
     ProAccounts       PA   (nolock),
     ProTariffs        PT   (nolock),
     ProTariffValues   PTV  (nolock),
     ProTrancPowerMethods prpm (nolock)
where
      PTPL.account_id = TMP.account_id  and
      PTPL.date_calc = @date_id         and
      TMP.account_id = PA.account_id   and
      PT.tariff_id   = PTV.tariff_id  and
      PA.tariff_id = pt.tariff_id     and
      pa.tranc_power_method_id = prpm.tranc_power_method_id


update #TmpLossAccounts
set
main_account_name = PA.account_name,
main_tariff_name  = '['+convert(varchar(3),pt.tariff_id)+']'+
                       convert(varchar(60),isnull(pt.tariff_name,'-нет-')),
main_tariff_value = pcv.tariff_value,

quantity          =        case when (TMP.tranc_power_method_id = 2)
                           then convert(int,isnull((pcc.quantity - pcc.add_hcp),0))
                           else convert(int,isnull((pcc.quantity - pcc.add_quantity - pcc.add_hcp),0)) end
                  
from ProAccounts     pa   (nolock)
    ,ProTariffValues pcv  (nolock)
    ,ProTariffs      pt   (nolock)
    ,ProCntCounts    pcc  (nolock)
    ,#TmpLossAccounts TMP (nolock)
where  pa.tariff_id = pcv.tariff_id
   and pa.tariff_id = pt.tariff_id
   and pa.account_id = TMP.main_account_id
   and pa.account_id = pcc.account_id
   and pcc.date_id   = @date_id


select
account_id   = convert(varchar(12),account_id),
account_name = convert(varchar(40),account_name),
tariff_value = convert(varchar(20),tariff_value),
tariff_name  = tariff_name,
use_days     = use_days,
tranc_power_coef  = convert(varchar(2),tranc_power_coef)+'%',
tranc_power_method_name = convert(varchar(80),tranc_power_method_name),
loss_quantity = loss_quantity,
main_account_id = convert(varchar(12),main_account_id),
main_account_name = convert(varchar(40),isnull(main_account_name,'- нет -')),
main_tariff_name = convert(varchar(40),main_tariff_name),
main_tariff_value = convert(varchar(20),main_tariff_value),
quantity,
tranc_power_name
from #TmpLossAccounts

 