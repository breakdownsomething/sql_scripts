declare
  @ACCOUNT_OWNER_ID int,
  @REPORT_DATE   smalldatetime, -- внешний параметр, расчетный период отчета
  @CURRENT_DATE  smalldatetime -- текущий по базе расчетный период

select
  @ACCOUNT_OWNER_ID = 1332001,--:ACCOUNT_OWNER_ID,
  @REPORT_DATE = '2004-09-30' --:pDatEnd

select @CURRENT_DATE = (select top 1 date_calc_end from ProGroups)

if @REPORT_DATE = @CURRENT_DATE
begin
  SELECT
	  pa.ACCOUNT_ID,
    pa.ACCOUNT_OWNER_ID,
	  pa.ACCOUNT_NAME,
    [POWER] = CASE WHEN pa.POWER_GROUP_ID = 0
                   THEN 'Актив.'
                   ELSE 'Реакт.' END,
	  pat.AUDIT_TYPE_NAME,
    pcd.TARIFF_VALUE,
	  pap.AUDIT_PARAM_NAME,
	  pam.AUDIT_METHOD_NAME,
	  pa.CALC_FACTOR,
    FACTORY_NUMBER = CASE WHEN pa.AUDIT_METHOD_ID <> 4
                          THEN ''
                          ELSE pcd.FACTORY_NUMBER END,
    COUNTER_TYPE_NAME = CASE WHEN pa.AUDIT_METHOD_ID <> 4
                             THEN ''
                             ELSE ct.COUNTER_TYPE_NAME END,
    KNOT_OUT = SUBSTRING(pa.KNOT_OUT,1,3)+' '+SUBSTRING(pa.KNOT_OUT,4,3)+' '+
               SUBSTRING(pa.KNOT_OUT,7,3)+' '+SUBSTRING(pa.KNOT_OUT,10,3),
    pa.KNOT_MAIN
  FROM
	  ProAccounts pa,
	  ProAuditTypes pat,
  	ProAuditparams pap,
	  ProAuditMethods pam,
	  CntTypes ct,
    ProCalcDetails pcd
  WHERE
    pa.ACCOUNT_OWNER_ID = @ACCOUNT_OWNER_ID     AND
	  pat.AUDIT_TYPE_ID   = pa.AUDIT_TYPE_ID    AND
    pap.AUDIT_PARAM_ID  = pa.AUDIT_PARAM_ID   AND
	  pam.AUDIT_METHOD_ID = pa.AUDIT_METHOD_ID AND
	  ct.COUNTER_TYPE_ID  =* pcd.COUNTER_TYPE_ID AND
    -----------------------------------------
    pcd.source_id       = pa.account_id and
    pcd.calc_id         = isnull((select pc.calc_id from ProCalcs pc
                                   where pc.contract_id = pa.contract_id and
                                         pc.date_calc = @REPORT_DATE),0)
  ORDER BY pa.ACCOUNT_ID
end
else
begin
Print 'Second' 
  SELECT
	  pa.ACCOUNT_ID,
    pa.ACCOUNT_OWNER_ID,
	  pa.ACCOUNT_NAME,
    [POWER] = CASE WHEN pa.POWER_GROUP_ID = 0
                   THEN 'Актив.'
                   ELSE 'Реакт.' END,
	  pat.AUDIT_TYPE_NAME,
    pcd.TARIFF_VALUE,
	  pap.AUDIT_PARAM_NAME,
	  pam.AUDIT_METHOD_NAME,
	  pa.CALC_FACTOR,
    FACTORY_NUMBER = CASE WHEN pa.AUDIT_METHOD_ID <> 4
                          THEN ''
                          ELSE pcd.FACTORY_NUMBER END,
    COUNTER_TYPE_NAME = CASE WHEN pa.AUDIT_METHOD_ID <> 4
                             THEN ''
                             ELSE ct.COUNTER_TYPE_NAME END,
    KNOT_OUT = SUBSTRING(pa.KNOT_OUT,1,3)+' '+SUBSTRING(pa.KNOT_OUT,4,3)+' '+
               SUBSTRING(pa.KNOT_OUT,7,3)+' '+SUBSTRING(pa.KNOT_OUT,10,3),
    pa.KNOT_MAIN
  FROM
	  ProAccountsArc pa,
	  ProAuditTypes pat,
  	ProAuditparams pap,
	  ProAuditMethods pam,
	  CntTypes ct,
    ProCalcDetails pcd
  WHERE
    pa.ACCOUNT_OWNER_ID = @ACCOUNT_OWNER_ID     AND
	  pat.AUDIT_TYPE_ID   = pa.AUDIT_TYPE_ID      AND
    pap.AUDIT_PARAM_ID  = pa.AUDIT_PARAM_ID     AND
	  pam.AUDIT_METHOD_ID = pa.AUDIT_METHOD_ID    AND
	  ct.COUNTER_TYPE_ID  =* pcd.COUNTER_TYPE_ID  AND
    -----------------------------------------
    pcd.source_id       = pa.account_id and
    pcd.calc_id         = isnull((select pc.calc_id from ProCalcs pc
                                   where pc.contract_id = pa.contract_id and
                                         pc.date_calc = @REPORT_DATE),0) and
    -----------------------------------------
    pa.date_begin       = @REPORT_DATE 
  ORDER BY pa.ACCOUNT_ID
end
