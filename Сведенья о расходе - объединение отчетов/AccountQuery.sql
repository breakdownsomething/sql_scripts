declare
@dtDatEnd         DateTime,
@CURRENT_DATE     datetime,
@ACCOUNT_OWNER_ID int

SELECT
@dtDatEnd         = '2004-10-31',--:pDatEnd,
@ACCOUNT_OWNER_ID = 1208601--:ACCOUNT_OWNER_ID

select @CURRENT_DATE = (select top 1 date_calc_end from ProGroups)

if @dtDatEnd = @CURRENT_DATE
begin
  SELECT
	  pa.ACCOUNT_ID,
    pa.ACCOUNT_OWNER_ID,
	  pa.ACCOUNT_NAME,
    PREC = ct.PREC-ct.SCALE,
    ADDRESS=
     CASE
       WHEN ISnull(pa.STREET_ID,0)<>0 THEN
        (SELECT
           Convert(VarChar(40),
             IsNull(RTrim(T.TOWN_NAME),'')+','+
             IsNull(RTrim(ST.STREET_TYPE_SHORT_NAME),'')+
             IsNull(RTrim(S.STREET_NAME),'')+','+
             IsNull(RTrim(pa.HOUSE_ID),'')+','+
             IsNull(RTrim(pa.FLAT_ID),''))
          FROM
           Streets S,
           StreetTypes ST,
           Towns T
          WHERE
           S.STREET_ID=pa.STREET_ID AND
           ST.STREET_TYPE_ID=*S.STREET_TYPE_ID AND
           T.TOWN_ID=*S.TOWN_ID )
       ELSE
         pa.ADDRESS
       END,
	  pa.CALC_FACTOR,
    FACTORY_NUMBER=(CASE WHEN pa.AUDIT_METHOD_ID<>4 THEN ''
                          ELSE pcd.FACTORY_NUMBER END)
  FROM
  	ProAccounts pa,
    ---------------------
    ProCalcs pc,
    ProCalcDetails pcd,
    CntTypes ct
    ---------------------
  WHERE
          pa.ACCOUNT_OWNER_ID = @ACCOUNT_OWNER_ID AND
          pa.AUDIT_METHOD_ID  > 1                 AND
          pa.POWER_GROUP_ID   <= (CASE WHEN MONTH(@dtDatEnd) in (2,5,8,11)
                                       THEN 1
                                       ELSE 0 END) AND
          pc.contract_id      = pa.contract_id and
          pc.date_calc        = @dtDatEnd and
          pcd.calc_id         = pc.calc_id and
          pcd.source_id       = pa.account_id and
          pcd.counter_type_id *= ct.counter_type_id
  ORDER BY
          pa.ACCOUNT_ID
end
else
begin
  SELECT
	  pa.ACCOUNT_ID,
    pa.ACCOUNT_OWNER_ID,
	  pa.ACCOUNT_NAME,
    PREC = ct.PREC-ct.SCALE,
    ADDRESS=
     CASE
       WHEN ISnull(pa.STREET_ID,0)<>0 THEN
        (SELECT
           Convert(VarChar(40),
             IsNull(RTrim(T.TOWN_NAME),'')+','+
             IsNull(RTrim(ST.STREET_TYPE_SHORT_NAME),'')+
             IsNull(RTrim(S.STREET_NAME),'')+','+
             IsNull(RTrim(pa.HOUSE_ID),'')+','+
             IsNull(RTrim(pa.FLAT_ID),''))
          FROM
           Streets S,
           StreetTypes ST,
           Towns T
          WHERE
           S.STREET_ID=pa.STREET_ID AND
           ST.STREET_TYPE_ID=*S.STREET_TYPE_ID AND
           T.TOWN_ID=*S.TOWN_ID )
       ELSE
         pa.ADDRESS
       END,
	  pa.CALC_FACTOR,
    FACTORY_NUMBER=(CASE WHEN pa.AUDIT_METHOD_ID<>4 THEN ''
                          ELSE pcd.FACTORY_NUMBER END)
  FROM
  	ProAccountsArc pa,
    ---------------------
    ProCalcs pc,
    ProCalcDetails pcd,
    CntTypes ct
    ---------------------
  WHERE
          pa.ACCOUNT_OWNER_ID = @ACCOUNT_OWNER_ID AND
          pa.AUDIT_METHOD_ID  > 1                 AND
          pa.POWER_GROUP_ID   <= (CASE WHEN MONTH(@dtDatEnd) in (2,5,8,11)
                                       THEN 1
                                       ELSE 0 END) AND
          pa.date_begin       = @dtDatEnd and
          pc.contract_id      = pa.contract_id and
          pc.date_calc        = @dtDatEnd and
          pcd.calc_id         = pc.calc_id and
          pcd.source_id       = pa.account_id and
          pcd.counter_type_id *= ct.counter_type_id
  ORDER BY
          pa.ACCOUNT_ID
end