declare
  @contract_number int,           -- номер контракта, внешний параметр
  @contract_id     int,           -- код контракта
  @date_id         smalldatetime, -- расчетный период,
                                  -- за который выдается отчет
  @cur_calc_period smalldatetime, -- текущий расчетный период
  @s_date_id       varchar(20)    -- расчетный период,
                                  -- за который выдается отчет 
                                  -- в текстовом виде, внешний параметр 
  
select
  @contract_number =  5372, --:contract_number,
  @s_date_id       = '2004-09-01'--:date_id

select @date_id = dateadd(dd,-1,(dateadd(mm,+1,convert(smalldatetime,@s_date_id))))
select @cur_calc_period = (select top 1 date_calc_end from ProGroups)

select @contract_id = contract_id
from ProContracts where contract_number = @contract_number

if @date_id = @cur_calc_period -- отчет выдается за текущий расчетный период
begin
  select PA.account_id,
         account_name = '['+convert(varchar(12),PA.account_id)+'] '+PA.account_name,
         tariff_name = '['+ convert(varchar(12),convert(decimal(8,2),PTV.tariff_value))+'] '+
                        PT.tariff_name,
         PT.tariff_id,
         PTV.tariff_value,
         PTPL.all_losses,
         PTPL.first_tranc_power_coef,
         PTPL.first_tranc_power_losses,
         PTPL.second_tranc_power_coef,
         PTPL.second_tranc_power_losses
  from ProAccounts      PA  (nolock),
       ProTariffs       PT  (nolock),
       ProTariffValues  PTV (nolock),
       ProTrancPowerLosses PTPL (nolock)
  where PA.contract_id = @contract_id  and
        PA.AUDIT_PARAM_ID = 2             and
        PA.account_id = PTPL.account_id and
        PTPL.date_calc = @date_id      and
        PA.tariff_id   = PT.tariff_id  and
        PA.tariff_id   = PTV.tariff_id and
        PTV.date_calc = (select max(PTV1.date_calc)
                         from ProTariffValues PTV1 (nolock)
                         where PTV1.tariff_id = PA.tariff_id)
end

else

begin
  select PAA.account_id,
         account_name = '['+convert(varchar(12),PAA.account_id)+'] '+PAA.account_name,
         tariff_name = '['+ convert(varchar(12),convert(decimal(8,2),PTV.tariff_value))+'] '+
                        PT.tariff_name,
         PTV.tariff_value,
         PTPL.all_losses,
         PTPL.first_tranc_power_coef,
         PTPL.first_tranc_power_losses,
         PTPL.second_tranc_power_coef,
         PTPL.second_tranc_power_losses
  from ProAccountsArc  PAA (nolock),
       ProTariffs      PT  (nolock),
       ProTariffValues PTV (nolock),
       ProTrancPowerLosses PTPL (nolock)
  where PAA.contract_id = @contract_id and
        PAA.audit_param_id = 2 and
        PAA.date_begin  = @date_id and
        PAA.account_id = PTPL.account_id and
        PTPL.date_calc = @date_id      and
        PT.tariff_id = PAA.tariff_id and
        PTV.tariff_id = PAA.tariff_id and
        PTV.date_calc = (select max(PTV1.date_calc)
                         from ProTariffValues PTV1 (nolock)
                         where PTV1.tariff_id = PAA.tariff_id
                               and PTV1.date_calc <= @date_id)
end


--select * from ProAccounts where contract_id = 17915


--select * from ProTrancPowerLosses

--select * from ProAccountsArc where substation_type_id  is not null

--------------------------------------------------------------------------------------
      


