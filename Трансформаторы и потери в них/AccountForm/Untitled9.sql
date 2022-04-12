
declare 
  @contract_id int,
  @account_id  int,
  @year        smallint,
  @month       smallint

select @contract_id = 247715,
       @account_id  = 535647813

select @year =  [YEAR],
       @month = [MONTH]
from aspCommon..YearMonth

select 
PTPA.CONTRACT_ID,
PTPA.ACCOUNT_ID,
PTPA.TRANC_POWER_ACCOUNT_ID,
PTPA.DATE_CALC_BEG,
PTPA.DATE_CALC_END,
ACCOUNT_NAME ='['+convert(varchar(50),PTPA.TRANC_POWER_ACCOUNT_ID)+'] '+
                PA.account_name
from ProTrancPowerAcc PTPA (nolock),
     ProAccounts      PA   (nolock)
where PTPA.tranc_power_account_id = PA.account_id and
      PTPA.contract_id = @contract_id and 
      PTPA.account_id  = @account_id  and
      (PTPA.date_calc_end is null or
        (YEAR(PTPA.date_calc_end) = @year and
         MONTH(PTPA.date_calc_end) = @month) 
      )
/*
update ProTrancPowerAcc
set date_calc_end = null
where contract_id = 247715
  and account_id  = 535647813
*/
