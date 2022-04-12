declare
@date_id smalldatetime,
@s_date_id varchar(20),
@contract_number int,
@exists_losses   bit

select
  @contract_number    = 50033,--:contract_number,
  @s_date_id         =  '2004-09-01'--:date_id

select @date_id = dateadd(dd,-1,(dateadd(mm,+1,convert(smalldatetime,@s_date_id))))

if exists
 (select  *
  from  ProTrancPowerLosses
  where date_calc = @date_id and
        account_id in ( select PA.account_id
                      from ProAccounts  PA (nolock),
                           ProContracts PC (nolock)
                      where PA.contract_id = PC.contract_id and
                            PC.contract_number = @contract_number and
                            PA.AUDIT_PARAM_ID = 2) )
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

