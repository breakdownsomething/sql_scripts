DECLARE
  @dtCalcBegin  SmallDateTime,
  @dtCalcEnd  SmallDateTime,
  @dfProc Decimal(5,2),
  @CURRENT_DATE smalldatetime

SELECT
  @dtCalcBegin ='2004-10-01',--:pdtCalcBeg,
  @dtCalcEnd   ='2004-10-31'--:pdtCalcEnd

select @CURRENT_DATE = (select top 1 date_calc_end from ProGroups)


if @dtCalcEnd = @CURRENT_DATE
begin
  IF EXISTS (SELECT * FROM TempDB..sysobjects
             WHERE id = object_id('TempDB..#TmpPart'))
  begin
    SELECT
      COUNT(Cn.CONTRACT_NUMBER),
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
  end
  ELSE
  begin
    SELECT
      COUNT(Cn.CONTRACT_NUMBER),
      SUM(A.CALC_FACTOR)
    FROM
      ProContracts Cn,
      ProAbonents Ab,
      ProAccounts A,
      ProCntCounts CC
    WHERE
      Ab.ABONENT_ID=Cn.ABONENT_ID AND
      A.CONTRACT_ID=Cn.CONTRACT_ID AND
      A.AUDIT_METHOD_ID IN (3,9) AND
      CC.ACCOUNT_ID=A.ACCOUNT_ID AND
      CC.DATE_ID BETWEEN @dtCalcBegin AND @dtCalcEnd
  end
end
else
begin
  IF EXISTS (SELECT * FROM TempDB..sysobjects
             WHERE id = object_id('TempDB..#TmpPart'))
  begin
    SELECT
      COUNT(Cn.CONTRACT_NUMBER),
      SUM(A.CALC_FACTOR)
    FROM
      ProContractsArc Cn (nolock),
      ProAbonentsArc  Ab (nolock),
      ProAccountsArc  A  (nolock),
      ProCalcs     PC (nolock),
      #TmpPart P
    WHERE
      Cn.CONTRACT_ID=P.CONTRACT_ID AND
      Ab.ABONENT_ID=Cn.ABONENT_ID AND
      A.CONTRACT_ID=Cn.CONTRACT_ID AND
      A.AUDIT_METHOD_ID IN (3,9) 
  and PC.contract_id = A.contract_id
  and PC.date_calc   = @dtCalcEnd
  and Cn.date_begin  = PC.date_calc
  and Ab.date_id     = PC.date_calc
  and A.date_begin   = PC.date_calc
  end
  ELSE
  begin
    SELECT
      COUNT(Cn.CONTRACT_NUMBER),
      SUM(A.CALC_FACTOR)
    FROM
      ProContractsArc Cn (nolock),
      ProAbonentsArc  Ab (nolock),
      ProAccountsArc  A  (nolock),
      ProCalcs     PC (nolock)
    WHERE
      Ab.ABONENT_ID=Cn.ABONENT_ID AND
      A.CONTRACT_ID=Cn.CONTRACT_ID AND
      A.AUDIT_METHOD_ID IN (3,9) 
  and PC.contract_id = A.contract_id
  and PC.date_calc   = @dtCalcEnd
  and Cn.date_begin  = PC.date_calc
  and Ab.date_id     = PC.date_calc
  and A.date_begin   = PC.date_calc
  end
end