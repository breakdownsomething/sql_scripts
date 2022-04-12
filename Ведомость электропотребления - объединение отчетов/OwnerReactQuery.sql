DECLARE
  @ACCOUNT_OWNER_ID	integer,
  @DATE_ID		smalldatetime,
  @CURRENT_DATE  smalldatetime -- текущий по базе расчетный период
SELECT
  @ACCOUNT_OWNER_ID = 5354381/*:ACCOUNT_OWNER_ID*/,
  @DATE_ID          = '2004-10-31'/*:pDatEnd*/

select @CURRENT_DATE = (select top 1 date_calc_end from ProGroups)

if @DATE_ID = @CURRENT_DATE
begin
  Select
    pa.ACCOUNT_OWNER_ID,
    QUANTITY=SUM(pcd.CALC_QUANTITY),
    SUM_ALL=SUM(pcd.SUM_CALC)
  From
    ProAccounts pa,
    ProCalcDetails pcd
  Where
    pa.ACCOUNT_OWNER_ID = @ACCOUNT_OWNER_ID AND
    pa.POWER_GROUP_ID   = 1 AND
    pcd.calc_id   =* (select isnull(p.calc_id,0)
                       from ProCalcs p
                       where contract_id = pa.contract_id and
                             p.date_calc = @DATE_ID) and
    pcd.source_id =* pa.account_id
  GROUP BY
    pa.ACCOUNT_OWNER_ID
end
else
begin
  Select
  pa.ACCOUNT_OWNER_ID,
  QUANTITY=SUM(pcd.CALC_QUANTITY),
  SUM_ALL=SUM(pcd.SUM_CALC)
From
  ProAccountsArc pa,
  ProCalcDetails pcd
Where
  pa.ACCOUNT_OWNER_ID = @ACCOUNT_OWNER_ID AND
  pa.POWER_GROUP_ID   = 1 AND
  pa.date_begin       = @DATE_ID and
  pcd.calc_id   =* (select isnull(p.calc_id,0)
                     from ProCalcs p
                     where contract_id = pa.contract_id and
                           p.date_calc = @DATE_ID) and
  pcd.source_id =* pa.account_id
GROUP BY
  pa.ACCOUNT_OWNER_ID
end

--select top 100 * from proaccounts where power_group_id = 1
--select * from ProAccountOwners where contract_id = 22315



