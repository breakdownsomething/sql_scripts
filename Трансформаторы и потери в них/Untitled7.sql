select * from ProAccounts where account_id = 133200102
select * from ProAccounts where contract_id = 215411




select account_id   = convert(char,isnull(pa.account_id,'-нет-'))
      ,account_name = convert(char,isnull(pa.account_name,'-нет-'))
      ,tariff_value = convert(char,isnull(convert(decimal(18,2),pcv.tariff_value),'-нет-'))
      ,tariff_name  = convert(char,isnull(pt.tariff_name,'-нет-'))
      ,quantity     = convert(int,isnull((pcc.quantity + pcc.add_quantity),0))
  from ProAccounts     pa   (nolock)
      ,ProTariffValues pcv  (nolock)
      ,ProTariffs      pt   (nolock)
      ,ProCntCounts    pcc  (nolock)
where  pa.tariff_id = pcv.tariff_id
   and pa.tariff_id = pt.tariff_id 
   and pa.account_id = (select tranc_power_account_id
                                from ProAccounts
                                where account_id = 133200102)
   and pa.account_id = pcc.account_id
   and pcc.date_id   = '2004-02-29'








update ProAccounts set
tranc_power_id = 5,
tranc_power_account_id = 133200101,
tranc_power_method_id = 3
where account_id = 133200102

update ProAccounts set
tranc_power_id = null,
tranc_power_account_id = null,
tranc_power_method_id = null
where account_id = 133200102





select * from TableFields where
table_id =(select table_id from Tables where table_name = 'ProTrancPowerLoss')


select top 10 *  from procntactiondates



select account_id              = convert(char,pa.account_id)
      ,account_name            = convert(char,pa.account_name)
      ,tariff_value            = convert(char,convert(decimal(18,2),ptv.tariff_value))
      ,tariff_name             = convert(char(80),pt.tariff_name)
      ,tranc_power_method_id   = convert(char,pa.tranc_power_method_id)
      ,tranc_power_method_name = convert(char(80),prpm.tranc_power_method_name) 
      ,tranc_power_id          = convert(int,pa.tranc_power_id)
      ,tranc_power_name        = convert(char,prpl.tranc_power_name)
      ,calc_factor             = convert(int,pa.calc_factor)

from ProTariffValues      ptv  (nolock)
    ,ProAccounts          pa   (nolock)
    ,ProTrancPowerList    prpl (nolock)
    ,ProTariffs           pt   (nolock) 
    ,ProTrancPowerMethods prpm (nolock)
where ptv.tariff_id       = pa.tariff_id
  and pt.tariff_id        = pa.tariff_id
  and prpl.tranc_power_id = pa.tranc_power_id
  and pa.tranc_power_method_id = prpm.tranc_power_method_id  
  and pa.account_id       = 133200102 


select existed = case when (select tranc_power_method_id
                            from ProAccounts
                            where account_id = 133200102) is null
                      then 0
                      else 1 end



alter table ProTrancPowerLoss disable trigger trProTrancPowerLossIns
alter table ProTrancPowerLoss disable trigger trProTrancPowerLossDel

declare
  @account_id            int
 ,@date_calc             smalldatetime
 ,@trunc_power_coef      int
 ,@tranc_power_method_id tinyint
 ,@use_days              tinyint
 ,@loss_quantity         int
 ,@comment               char(255)
 ,@cntquantity           int
select
  @account_id            = 133200102
 ,@date_calc             = '2004-03-31'
 ,@use_days              = 21
 ,@loss_quantity         = 1200
 ,@comment               = ''
 ,@cntquantity           = 32000

select
  @tranc_power_method_id = (select tranc_power_method_id
                            from ProAccounts
                            where account_id = @account_id)
 ,@trunc_power_coef      = round(100*@cntquantity/
                                (730 * 0.9 * (select tranc_power_capacity
                                              from ProTrancPowerList
                                              where tranc_power_id = (select tranc_power_id
                                                                      from ProAccounts
                                                                      where account_id = @account_id
                                                                      )
                                              )
                                 )
                               ,0)
 
delete from ProTrancPowerLoss
where account_id = @account_id
  and date_calc  = @date_calc

insert into ProTrancPowerLoss
       (account_id
       ,date_calc
       ,tranc_power_coef
       ,tranc_power_method_id
       ,use_days
       ,loss_quantity
       ,comment) 
values (@account_id
       ,@date_calc
       ,@trunc_power_coef
       ,@tranc_power_method_id
       ,@use_days
       ,@loss_quantity
       ,@comment)

alter table ProTrancPowerLoss enable trigger trProTrancPowerLossIns
alter table ProTrancPowerLoss enable trigger trProTrancPowerLossDel



select * from ProTrancPowerLoss

