declare 
  @CONTRACT_ID   int, -- внешний параметр, номер контракта
  @REPORT_DATE   smalldatetime, -- внешний параметр, расчетный период отчета
  @CURRENT_DATE  smalldatetime -- текущий по базе расчетный период

select
  @CONTRACT_ID = 215411 /*:pContract_Id*/,
  @REPORT_DATE = '2004-09-30'

select @CURRENT_DATE = (select top 1 date_calc_end from ProGroups)

-- если отчет выдается за текущий расчетный период
-- тогда оиспользуем запрос из таблиц с текущими данными,
-- иначе из архивов
if @REPORT_DATE = @CURRENT_DATE
begin
  Select
    pc.CONTRACT_ID,
    pc.ABONENT_ID,
    pc.CONTRACT_NUMBER,
    pc.DATE_CONTRACT,
    pa.ABONENT_NAME,
    ADDRESS=
     CASE
       WHEN ISnull(pa.STREET_ID,0)<>0 THEN
        (SELECT
           Convert(VarChar(50),
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
    pa.PHONE,
    pao.ACCOUNT_OWNER_ID,
    pao.ACCOUNT_OWNER_NAME,
    ADDRESs=
     CASE
       WHEN ISnull(pao.STREET_ID,0)<>0 THEN
        (SELECT
           Convert(VarChar(40),
             IsNull(RTrim(T.TOWN_NAME),'')+','+
             IsNull(RTrim(ST.STREET_TYPE_SHORT_NAME),'')+
             IsNull(RTrim(S.STREET_NAME),'')+','+
             IsNull(RTrim(pao.HOUSE_ID),'')+','+
             IsNull(RTrim(pao.FLAT_ID),''))
          FROM
           Streets S,
           StreetTypes ST,
           Towns T
          WHERE
           S.STREET_ID=pao.STREET_ID AND
           ST.STREET_TYPE_ID=*S.STREET_TYPE_ID AND
           T.TOWN_ID=*S.TOWN_ID )
       ELSE
         pao.ADDRESS
       END,
    pg.GROUP_NAME,
    pg.DATE_CALC_END
  From
    ProContracts pc,
    ProAbonents pa,
    ProAccountOwners pao,
    ProGroups pg
  Where
    pc.CONTRACT_ID=@CONTRACT_ID and
    pa.ABONENT_ID=pc.ABONENT_ID and
    pao.CONTRACT_ID=pc.CONTRACT_ID and
    pg.GROUP_ID=pc.GROUP_ID
  ORDER BY
    pao.ACCOUNT_OWNER_ID
end
else
begin
  Select
    pc.CONTRACT_ID,
    pc.ABONENT_ID,
    pc.CONTRACT_NUMBER,
    pc.DATE_CONTRACT,
    pa.ABONENT_NAME,
    ADDRESS=
     CASE
       WHEN ISnull(pa.STREET_ID,0)<>0 THEN
        (SELECT
           Convert(VarChar(50),
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
    pa.PHONE,
    pao.ACCOUNT_OWNER_ID,
    pao.ACCOUNT_OWNER_NAME,
    ADDRESs=
     CASE
       WHEN ISnull(pao.STREET_ID,0)<>0 THEN
        (SELECT
           Convert(VarChar(40),
             IsNull(RTrim(T.TOWN_NAME),'')+','+
             IsNull(RTrim(ST.STREET_TYPE_SHORT_NAME),'')+
             IsNull(RTrim(S.STREET_NAME),'')+','+
             IsNull(RTrim(pao.HOUSE_ID),'')+','+
             IsNull(RTrim(pao.FLAT_ID),''))
          FROM
           Streets S,
           StreetTypes ST,
           Towns T
          WHERE
           S.STREET_ID=pao.STREET_ID AND
           ST.STREET_TYPE_ID=*S.STREET_TYPE_ID AND
           T.TOWN_ID=*S.TOWN_ID )
       ELSE
         pao.ADDRESS
       END,
    pg.GROUP_NAME,
    pg.DATE_CALC_END
  From
    ProContractsArc pc,
    ProAbonentsArc pa,
    ProAccountOwnersArc pao,
    ProGroupsArc pg
  Where
    pc.CONTRACT_ID=@CONTRACT_ID and
    pa.ABONENT_ID=pc.ABONENT_ID and
    pao.CONTRACT_ID=pc.CONTRACT_ID and
    pg.GROUP_ID=pc.GROUP_ID
    ---------------------
    and pc.date_begin = @REPORT_DATE
    and pa.date_id    = pc.date_begin
    and pao.date_begin = pc.date_begin
    and pg.date_begin  = pc.date_begin
    ---------------------
  ORDER BY
    pao.ACCOUNT_OWNER_ID
end