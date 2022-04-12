declare
@date_id smalldatetime,
@s_date_id varchar(20),
@contract_number int,
@exists_losses   bit

select 
  @contract_number    = 130652,
  @s_date_id         = '2004-08-01'

select @date_id = dateadd(dd,-1,(dateadd(mm,+1,convert(smalldatetime,@s_date_id))))
 
if exists
 (select  *
  from  ProTrancPowerLoss
  where date_calc = @date_id and 
       account_id = ( select top 1 PA.account_id
                      from ProAccounts  PA (nolock),
                           ProContracts PC (nolock)
                      where PA.contract_id = PC.contract_id and
                            PC.contract_number = @contract_number and
                            PA.tranc_power_id is not null and
                            PA.tranc_power_account_id is not null and
                            PA.tranc_power_method_id is not null)
  )
  begin
  select @exists_losses = convert(bit,1)
  end
else
  begin
  select @exists_losses = convert(bit,0)
  end


select
   abonent = '¹ '+convert(varchar(10),PC.contract_number) +
             ' '+PA.abonent_name,
   exists_losses =  @exists_losses
from ProAbonents       PA   (nolock),
     ProContracts      PC   (nolock)

where  PA.abonent_id = PC.abonent_id and
       PC.contract_number = @contract_number


--select * from ProTrancPowerLoss
--select * from procontracts where contract_number=130652
--select * from ProAbonents where abonent_id = 130652
--select top 10 * from ProGroup

select * from ProAccounts where account_id = 143690102
select * from ProContracts where contract_id = 107411
--(1369)
select 