DECLARE
  @dtCalcBegin  SmallDateTime,
  @dtCalcEnd    SmallDateTime,
  @dfProc       Decimal(5,2),
  @CURRENT_DATE smalldatetime

SELECT
  @dtCalcBegin = '2004-10-01',-- :pdtCalcBeg,
  @dtCalcEnd   = '2004-10-31'-- :pdtCalcEnd

select @CURRENT_DATE = (select top 1 date_calc_end from ProGroups)


if @dtCalcEnd = @CURRENT_DATE
begin
  IF EXISTS  (SELECT * FROM TempDB..sysobjects
              WHERE id = object_id('TempDB..#TmpPart'))
  begin
    SELECT
      CONTRACT_NUMBER=RIGHT(space(8)+rtrim(ltrim(Cn.CONTRACT_NUMBER)),8),
      Ab.ABONENT_NAME,
      SUM(A.CALC_FACTOR)
    FROM
      ProContracts Cn,
      ProAbonents Ab,
      ProAccounts A,
      ProCntCounts CC,
      #TmpPart P
    WHERE
      Cn.CONTRACT_ID=P.CONTRACT_ID AND
      Ab.ABONENT_ID=Cn.ABONENT_ID AND
      A.CONTRACT_ID=Cn.CONTRACT_ID AND
      A.AUDIT_METHOD_ID IN (3,9) AND
      CC.ACCOUNT_ID=A.ACCOUNT_ID AND
      CC.DATE_ID BETWEEN @dtCalcBegin AND @dtCalcEnd
    GROUP BY
      RIGHT(space(8)+rtrim(ltrim(Cn.CONTRACT_NUMBER)),8),
      Ab.ABONENT_NAME
    ORDER BY
      RIGHT(space(8)+rtrim(ltrim(Cn.CONTRACT_NUMBER)),8)
  end
  ELSE
  begin
    SELECT
      CONTRACT_NUMBER=RIGHT(space(8)+rtrim(ltrim(Cn.CONTRACT_NUMBER)),8),
      Ab.ABONENT_NAME,
      SUM(A.CALC_FACTOR)
    FROM
      ProContracts Cn (nolock),
      ProAbonents  Ab (nolock),
      ProAccounts  A  (nolock),
      ProCntCounts CC (nolock)
    WHERE
      Ab.ABONENT_ID = Cn.ABONENT_ID  AND
      A.CONTRACT_ID = Cn.CONTRACT_ID AND
      A.AUDIT_METHOD_ID IN (3,9)     AND
      CC.ACCOUNT_ID = A.ACCOUNT_ID   AND
      CC.DATE_ID  BETWEEN @dtCalcBegin AND @dtCalcEnd
    GROUP BY
      RIGHT(space(8)+rtrim(ltrim(Cn.CONTRACT_NUMBER)),8),
      Ab.ABONENT_NAME
    ORDER BY
      RIGHT(space(8)+rtrim(ltrim(Cn.CONTRACT_NUMBER)),8)
  end
end
else
begin
IF EXISTS  (SELECT * FROM TempDB..sysobjects
              WHERE id = object_id('TempDB..#TmpPart'))
  begin
  SELECT 
      CONTRACT_NUMBER=RIGHT(space(8)+rtrim(ltrim(Cn.CONTRACT_NUMBER)),8),
      Ab.ABONENT_NAME,
      SUM(A.CALC_FACTOR)
    FROM
      ProContracts    Cn (nolock),
      ProAbonentsArc  Ab (nolock),
      ProAccountsArc  A  (nolock),
      ProCalcs        P  (nolock),
      #TmpPart        TMP
    WHERE
      Cn.CONTRACT_ID = TMP.CONTRACT_ID AND
      Ab.ABONENT_ID = Cn.ABONENT_ID  AND
      A.CONTRACT_ID = Cn.CONTRACT_ID AND
      A.AUDIT_METHOD_ID IN (3,9)     AND
      
          P.contract_id = Cn.contract_id
      and p.date_calc   = @dtCalcEnd
      and Ab.date_id    = p.date_calc
      and A.date_begin  = p.date_calc
    GROUP BY
      RIGHT(space(8)+rtrim(ltrim(Cn.CONTRACT_NUMBER)),8),
      Ab.ABONENT_NAME
    ORDER BY
      RIGHT(space(8)+rtrim(ltrim(Cn.CONTRACT_NUMBER)),8)
  end
  ELSE
  begin
    SELECT 
      CONTRACT_NUMBER=RIGHT(space(8)+rtrim(ltrim(Cn.CONTRACT_NUMBER)),8),
      Ab.ABONENT_NAME,
      SUM(A.CALC_FACTOR)
    FROM
      ProContracts    Cn (nolock),
      ProAbonentsArc  Ab (nolock),
      ProAccountsArc  A  (nolock),
      ProCalcs        P  (nolock)
    WHERE
      Ab.ABONENT_ID = Cn.ABONENT_ID  AND
      A.CONTRACT_ID = Cn.CONTRACT_ID AND
      A.AUDIT_METHOD_ID IN (3,9)     AND
      
          P.contract_id = Cn.contract_id
      and p.date_calc   = @dtCalcEnd
      and Ab.date_id    = p.date_calc
      and A.date_begin  = p.date_calc
    GROUP BY
      RIGHT(space(8)+rtrim(ltrim(Cn.CONTRACT_NUMBER)),8),
      Ab.ABONENT_NAME
    ORDER BY
      RIGHT(space(8)+rtrim(ltrim(Cn.CONTRACT_NUMBER)),8)
  end
end
