declare 
@ACCOUNT_OWNER_ID int,
@REPORT_DATE   smalldatetime, -- внешний параметр, расчетный период отчета
@CURRENT_DATE  smalldatetime -- текущий по базе расчетный период

select
@ACCOUNT_OWNER_ID = 1332001 /*:ACCOUNT_OWNER_ID*/,
@REPORT_DATE      = '2004-10-31'--:pDatEnd

select @CURRENT_DATE = (select top 1 date_calc_end from ProGroups)


-- если отчет выдается за текущий расчетный период
-- тогда оиспользуем запрос из таблиц с текущими данными,
-- иначе из архивов
if @REPORT_DATE = @CURRENT_DATE
begin
  IF EXISTS (SELECT * FROM ProAccounts WHERE ACCOUNT_OWNER_ID=@ACCOUNT_OWNER_ID)
    SELECT
      pa.ACCOUNT_ID,
      AUDIT_PARAM_ID = (CASE WHEN pa.AUDIT_PARAM_ID = 0
                             THEN 0
                             ELSE 1 END),
      POWER_GROUP_ID = (CASE WHEN pa.POWER_GROUP_ID = 1
                             THEN 0
                             ELSE 1 END),
	    pa.ACCOUNT_NAME,
      FACTORY_NUMBER = (CASE WHEN pa.AUDIT_METHOD_ID <> 4
                             THEN ''
                             ELSE pcd.FACTORY_NUMBER END),
	    EDIT_COUNT_BEGIN=(CASE WHEN pa.AUDIT_METHOD_ID = 3
                             THEN 0
                             WHEN pa.AUDIT_METHOD_ID = 9
                             THEN 0
                             ELSE pcd.EDIT_COUNT_BEGIN END),
      EDIT_COUNT     = (CASE WHEN pa.AUDIT_METHOD_ID = 3
                             THEN 0
                             WHEN pa.AUDIT_METHOD_ID = 9
                             THEN 0
                             ELSE pcd.EDIT_COUNT END),
--      DIFFER=(pc.QUANTITY-IsNull(pc.ADD_QUANTITY,0)-IsNull(pc.ADD_HCP,0))/pa.CALC_FACTOR,
      DIFFER=(pcd.CALC_QUANTITY-IsNull(pcd.ADD_QUANTITY,0)-IsNull(pcd.ADD_HCP,0))/(CASE WHEN IsNull(pa.CALC_FACTOR,0)=0 THEN 1 ELSE pa.CALC_FACTOR END),
      pa.CALC_FACTOR,
      MAIN_BILL=pcd.CALC_QUANTITY-IsNull(pcd.ADD_QUANTITY,0)-IsNull(pcd.ADD_HCP,0),
      OVER_BILL=IsNull(pcd.ADD_QUANTITY,0),
      HCP_BILL=IsNull(pcd.ADD_HCP,0),
      QUANTITY=IsNull(pcd.CALC_QUANTITY,0),
      pcd.Tariff_Value,
	    pcd.SUM_CALC
    FROM
      ProAccounts    pa,
      ProCalcs       p,
      ProCalcDetails pcd
    WHERE
      pa.ACCOUNT_OWNER_ID = @ACCOUNT_OWNER_ID 
----------------------------------------------------
      and p.contract_id = pa.contract_id
      and p.date_calc   = @REPORT_DATE
      and pcd.calc_id   = p.calc_id
      and pcd.source_id = pa.account_id
----------------------------------------------------
    ORDER BY
  	  pa.ACCOUNT_ID

  ELSE

    SELECT
    ACCOUNT_ID=@ACCOUNT_OWNER_ID,
    AUDIT_PARAM_ID=0,
    POWER_GROUP_ID=0,
    ACCOUNT_NAME='',
    FACTORY_NUMBER='',
    EDIT_COUNT_BEGIN=0,
    EDIT_COUNT=0,
    DIFFER=0.0000000000,
    CALC_FACTOR=0.00,
    MAIN_BILL=0,
    OVER_BILL=0,
    HCP_BILL=0,
    QUANTITY=0,
    Tariff_Value=0.0000,
    SUM_ALL=0.00

end
else
begin
IF EXISTS (SELECT * FROM ProAccountsArc
           WHERE ACCOUNT_OWNER_ID = @ACCOUNT_OWNER_ID
             and date_begin       = @REPORT_DATE)
    SELECT
      pa.ACCOUNT_ID,
      AUDIT_PARAM_ID = (CASE WHEN pa.AUDIT_PARAM_ID = 0
                             THEN 0
                             ELSE 1 END),
      POWER_GROUP_ID = (CASE WHEN pa.POWER_GROUP_ID = 1
                             THEN 0
                             ELSE 1 END),
	    pa.ACCOUNT_NAME,
      FACTORY_NUMBER = (CASE WHEN pa.AUDIT_METHOD_ID <> 4
                             THEN ''
                             ELSE pcd.FACTORY_NUMBER END),
	    EDIT_COUNT_BEGIN=(CASE WHEN pa.AUDIT_METHOD_ID = 3
                             THEN 0
                             WHEN pa.AUDIT_METHOD_ID = 9
                             THEN 0
                             ELSE pcd.EDIT_COUNT_BEGIN END),
      EDIT_COUNT     = (CASE WHEN pa.AUDIT_METHOD_ID = 3
                             THEN 0
                             WHEN pa.AUDIT_METHOD_ID = 9
                             THEN 0
                             ELSE pcd.EDIT_COUNT END),
--      DIFFER=(pc.QUANTITY-IsNull(pc.ADD_QUANTITY,0)-IsNull(pc.ADD_HCP,0))/pa.CALC_FACTOR,
      DIFFER=(pcd.CALC_QUANTITY-IsNull(pcd.ADD_QUANTITY,0)-IsNull(pcd.ADD_HCP,0))/(CASE WHEN IsNull(pa.CALC_FACTOR,0)=0 THEN 1 ELSE pa.CALC_FACTOR END),
      pa.CALC_FACTOR,
      MAIN_BILL=pcd.CALC_QUANTITY-IsNull(pcd.ADD_QUANTITY,0)-IsNull(pcd.ADD_HCP,0),
      OVER_BILL=IsNull(pcd.ADD_QUANTITY,0),
      HCP_BILL=IsNull(pcd.ADD_HCP,0),
      QUANTITY=IsNull(pcd.CALC_QUANTITY,0),
      pcd.Tariff_Value,
	    pcd.SUM_CALC
    FROM
      ProAccountsArc pa,
      ProCalcs       p,
      ProCalcDetails pcd
    WHERE
      pa.ACCOUNT_OWNER_ID = @ACCOUNT_OWNER_ID 
----------------------------------------------------
      and pa.date_begin = @REPORT_DATE
      and p.contract_id = pa.contract_id
      and p.date_calc   = @REPORT_DATE
      and pcd.calc_id   = p.calc_id
      and pcd.source_id = pa.account_id
----------------------------------------------------
    ORDER BY
  	  pa.ACCOUNT_ID

  ELSE

    SELECT
    ACCOUNT_ID=@ACCOUNT_OWNER_ID,
    AUDIT_PARAM_ID=0,
    POWER_GROUP_ID=0,
    ACCOUNT_NAME='',
    FACTORY_NUMBER='',
    EDIT_COUNT_BEGIN=0,
    EDIT_COUNT=0,
    DIFFER=0.0000000000,
    CALC_FACTOR=0.00,
    MAIN_BILL=0,
    OVER_BILL=0,
    HCP_BILL=0,
    QUANTITY=0,
    Tariff_Value=0.0000,
    SUM_ALL=0.00

end




