declare
  @contract_id            int,
  @account_id             int,
  @tranc_power_account_id int,
  @date_calc_beg          smalldatetime,
  @year                   smallint,
  @month                  smallint

select 
  @contract_id            = 204015,    --:CONTRACT_ID,
  @account_id             = 500330106, --:ACCOUNT_ID,
  @tranc_power_account_id = 500330103  --:TRANC_POWER_ACCOUNT_ID,

select @year =  [YEAR],
       @month = [MONTH]
from aspCommon..YearMonth

select @date_calc_beg = convert(smalldatetime,
                               convert(varchar(4),@Year)+'-'+
                               right(convert(varchar(3),100+@Month),2)+'-01'
                               )
select @date_calc_beg = dateadd(dd,-1,dateadd(mm,+1,@date_calc_beg))

insert into ProTrancPowerAcc
(
contract_id,
account_id,
tranc_power_account_id,
date_calc_beg,
date_calc_end
)
values
(
@contract_id,
@account_id,
@tranc_power_account_id,
@date_calc_beg,
null
)




