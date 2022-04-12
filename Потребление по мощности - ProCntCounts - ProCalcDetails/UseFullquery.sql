DECLARE
  @dtCalcBegin  SmallDateTime,
  @dtCalcEnd    SmallDateTime,
  @dfProc       Decimal(5,2),
  @CURRENT_DATE smalldatetime

SELECT
  @dtCalcBegin = '2004-10-01',--:pdtCalcBeg,
  @dtCalcEnd   = '2004-10-31'--:pdtCalcEnd

select @CURRENT_DATE = (select top 1 date_calc_end from ProGroups)


if @dtCalcEnd = @CURRENT_DATE
begin
  IF EXISTS (SELECT * FROM TempDB..sysobjects
             WHERE id = object_id('TempDB..#TmpPart'))
  begin  
    SELECT
      CONTRACT_NUMBER=RIGHT(space(8)+rtrim(ltrim(Cn.CONTRACT_NUMBER)),8),
      A.ACCOUNT_ID,
      A.ACCOUNT_NAME,
      AUDIT_METHOD_NAME=RIGHT(AM.AUDIT_METHOD_NAME,LEN(AM.AUDIT_METHOD_NAME)-14),
      A.CALC_FACTOR
    FROM
      ProContracts Cn,
      ProAccounts A,
      ProCntCounts CC,
      ProAuditMethods AM,
      #TmpPart P
    WHERE
      Cn.CONTRACT_ID=P.CONTRACT_ID AND
      A.CONTRACT_ID=Cn.CONTRACT_ID AND
      A.AUDIT_METHOD_ID IN (3,9) AND
      AM.AUDIT_METHOD_ID=A.AUDIT_METHOD_ID AND
      CC.ACCOUNT_ID=A.ACCOUNT_ID AND
      CC.DATE_ID BETWEEN @dtCalcBegin AND @dtCalcEnd
    ORDER BY
      RIGHT(space(8)+rtrim(ltrim(Cn.CONTRACT_NUMBER)),8),
      A.ACCOUNT_ID
    end
  ELSE
    begin
    SELECT
      CONTRACT_NUMBER=RIGHT(space(8)+rtrim(ltrim(Cn.CONTRACT_NUMBER)),8),
      A.ACCOUNT_ID,
      A.ACCOUNT_NAME,
      AUDIT_METHOD_NAME=RIGHT(AM.AUDIT_METHOD_NAME,LEN(AM.AUDIT_METHOD_NAME)-14),
      A.CALC_FACTOR
    FROM
      ProContracts Cn,
      ProAccounts A,
      ProCntCounts CC,
      ProAuditMethods AM
    WHERE
      A.CONTRACT_ID=Cn.CONTRACT_ID AND
      A.AUDIT_METHOD_ID IN (3,9) AND
      AM.AUDIT_METHOD_ID=A.AUDIT_METHOD_ID AND
      CC.ACCOUNT_ID=A.ACCOUNT_ID AND
      CC.DATE_ID BETWEEN @dtCalcBegin AND @dtCalcEnd
    ORDER BY
      RIGHT(space(8)+rtrim(ltrim(Cn.CONTRACT_NUMBER)),8),
      A.ACCOUNT_ID
    end
end
else
begin
  IF EXISTS (SELECT * FROM TempDB..sysobjects
             WHERE id = object_id('TempDB..#TmpPart'))
  begin
    SELECT distinct
      CONTRACT_NUMBER=RIGHT(space(8)+rtrim(ltrim(Cn.CONTRACT_NUMBER)),8),
      A.ACCOUNT_ID,
      A.ACCOUNT_NAME,
      AUDIT_METHOD_NAME=RIGHT(AM.AUDIT_METHOD_NAME,LEN(AM.AUDIT_METHOD_NAME)-14),
      A.CALC_FACTOR
    FROM
      ProContractsArc Cn (nolock),
      ProAccountsArc  A  (nolock),
      ProAuditMethods AM (nolock),
      ProCalcs        PC (nolock),
      #TmpPart P
    WHERE
      Cn.CONTRACT_ID=P.CONTRACT_ID AND
      A.CONTRACT_ID=Cn.CONTRACT_ID AND
      A.AUDIT_METHOD_ID IN (3,9) AND
      AM.AUDIT_METHOD_ID=A.AUDIT_METHOD_ID 

     and pc.date_calc   = @dtCalcEnd
     and pc.contract_id = a.contract_id 
     and Cn.date_begin  = pc.date_calc
     and A.date_begin   = pc.date_calc

    ORDER BY
      RIGHT(space(8)+rtrim(ltrim(Cn.CONTRACT_NUMBER)),8),
      A.ACCOUNT_ID 
    /* 
    SELECT
      CONTRACT_NUMBER=RIGHT(space(8)+rtrim(ltrim(Cn.CONTRACT_NUMBER)),8),
      A.ACCOUNT_ID,
      A.ACCOUNT_NAME,
      AUDIT_METHOD_NAME=RIGHT(AM.AUDIT_METHOD_NAME,LEN(AM.AUDIT_METHOD_NAME)-14),
      A.CALC_FACTOR
    FROM
      ProContracts Cn,
      ProAccounts A,
      ProCntCounts CC,
      ProAuditMethods AM,
      #TmpPart P
    WHERE
      Cn.CONTRACT_ID=P.CONTRACT_ID AND
      A.CONTRACT_ID=Cn.CONTRACT_ID AND
      A.AUDIT_METHOD_ID IN (3,9) AND
      AM.AUDIT_METHOD_ID=A.AUDIT_METHOD_ID AND
      CC.ACCOUNT_ID=A.ACCOUNT_ID AND
      CC.DATE_ID BETWEEN @dtCalcBegin AND @dtCalcEnd
    ORDER BY
      RIGHT(space(8)+rtrim(ltrim(Cn.CONTRACT_NUMBER)),8),
      A.ACCOUNT_ID */
    end
  ELSE
    begin
    SELECT distinct
      CONTRACT_NUMBER=RIGHT(space(8)+rtrim(ltrim(Cn.CONTRACT_NUMBER)),8),
      A.ACCOUNT_ID,
      A.ACCOUNT_NAME,
      AUDIT_METHOD_NAME=RIGHT(AM.AUDIT_METHOD_NAME,LEN(AM.AUDIT_METHOD_NAME)-14),
      A.CALC_FACTOR
    FROM
      ProContractsArc Cn (nolock),
      ProAccountsArc  A  (nolock),
      ProAuditMethods AM (nolock),
      ProCalcs        PC (nolock)
    WHERE
      A.CONTRACT_ID=Cn.CONTRACT_ID AND
      A.AUDIT_METHOD_ID IN (3,9) AND
      AM.AUDIT_METHOD_ID=A.AUDIT_METHOD_ID 

     and pc.date_calc   = @dtCalcEnd
     and pc.contract_id = a.contract_id 
     and Cn.date_begin  = pc.date_calc
     and A.date_begin   = pc.date_calc

    ORDER BY
      RIGHT(space(8)+rtrim(ltrim(Cn.CONTRACT_NUMBER)),8),
      A.ACCOUNT_ID
  end
end