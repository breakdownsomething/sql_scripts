/*
IF EXISTS (SELECT * FROM TempDB..sysobjects
           WHERE id = object_id('TempDB..#TmpPart') )
begin
 DROP TABLE #TmpPart
end

SELECT Distinct
  Cn.CONTRACT_ID,
  Cn.CONTRACT_NUMBER,
  Ab.ABONENT_NAME
 INTO #TmpPart
 FROM
  ProContracts Cn (Nolock),
  ProAbonents Ab (Nolock)
 WHERE
  Ab.ABONENT_ID=Cn.ABONENT_ID
*/


-------------------------------------------------------------
DECLARE
  @dtCalcBegin    DateTime,
  @dtCalcEnd      DateTime,
  @dtMainCalcEnd  DateTime,
  @siMeasure      SmallInt

SELECT
  @dtCalcBegin   = '2004-11-01', --:pdtCalcBegin,
  @dtCalcEnd     = '2004-11-30', --:pdtCalcEnd,
  @dtMainCalcEnd = '2004-11-30'  --:pdtMainCalcEnd

SELECT
  Cn.CONTRACT_ID,
  Cn.CONSUMER_GROUP_ID,
  SALDO =
    CASE
      WHEN @dtMainCalcEnd=@dtCalcEnd THEN
        Cn.SALDO
      ELSE
        C.SALDO
    END
 INTO
  #TmpSald
 FROM
  #TmpPart T (NoLock),
  ProContracts Cn (NoLock),
  ProCalcs C (NoLock)
 WHERE
  Cn.CONTRACT_ID=T.CONTRACT_ID AND
  C.CONTRACT_ID=*Cn.CONTRACT_ID AND
  C.DATE_CALC=@dtCalcEnd
ALTER TABLE
    #TmpSald
 ADD PRIMARY KEY (CONTRACT_ID)

SELECT
  Cn.CONTRACT_ID,
  SUM_PAY=SUM(IsNull(P.SUM_EE,0)),
  SUM_NDS_PAY=SUM(IsNull(P.SUM_ACT,0)),
  SUM_FINE_PAY=SUM(IsNull(P.SUM_FINE,0)),
  SUM_ALL_PAY=SUM(IsNull(P.SUM_EE,0)+IsNull(P.SUM_ACT,0))
 INTO
  #TmpPays
 FROM
  #TmpPart T (NoLock),
  ProContracts Cn (NoLock),
  ProPayments P (NoLock)
 WHERE
  Cn.CONTRACT_ID=T.CONTRACT_ID AND
  P.CONTRACT_ID=*Cn.CONTRACT_ID AND
  P.DATE_PAY Between @dtCalcBegin AND @dtCalcEnd
 GROUP BY
  Cn.CONTRACT_ID
ALTER TABLE
    #TmpPays
 ADD PRIMARY KEY (CONTRACT_ID)


SELECT
  Cn.CONTRACT_ID,
  S.CONSUMER_GROUP_ID,
  BEG_SALDO_DB=
  (CASE
      WHEN IsNull(S.SALDO,0)>0 THEN
        IsNull(S.SALDO,0)
       ELSE
         0
    END),
  BEG_SALDO_CR=
  (CASE
      WHEN IsNull(S.SALDO,0)<0 THEN
        -IsNull(S.SALDO,0)
       ELSE
         0
    END),
  BEG_SALDO=(IsNull(S.SALDO,0)),
  QUANTITY=(IsNull(C.QNT_ALL,0)),
  AVR_TARIF=Convert(Decimal(9,4),0),
  SUM_FACT=(IsNull(C.SUM_FACT,0)),
  SUM_EXC=(IsNull(C.SUM_EXC,0)),
  SUM_NDS_CALC=(IsNull(C.SUM_NDS,0)),
  SUM_REACTIVE=(IsNull(C.SUM_REACTIVE,0)),
  SUM_ALL_CALC=(IsNull(C.SUM_FACT,0)+IsNull(C.SUM_EXC,0)+IsNull(C.SUM_NDS,0)),
  SUM_PAY=(IsNull(P.SUM_PAY,0)),
  SUM_NDS_PAY=(IsNull(P.SUM_NDS_PAY,0)),
  SUM_FINE_PAY=(IsNull(P.SUM_FINE_PAY,0)),
  SUM_ALL_PAY=(IsNull(P.SUM_ALL_PAY,0)),
  END_SALDO_DB=
   Convert(Decimal(18,2),
    CASE
       WHEN (IsNull(S.SALDO,0)+IsNull(C.SUM_FACT,0)+IsNull(C.SUM_EXC,0)+IsNull(C.SUM_NDS,0)-
               IsNull(P.SUM_ALL_PAY,0))>0 THEN
         (IsNull(S.SALDO,0)+IsNull(C.SUM_FACT,0)+IsNull(C.SUM_EXC,0)+IsNull(C.SUM_NDS,0)-
           IsNull(P.SUM_ALL_PAY,0))
       ELSE
         0
    END),
  END_SALDO_CR=
   Convert(Decimal(18,2),
    CASE
       WHEN (IsNull(S.SALDO,0)+IsNull(C.SUM_FACT,0)+IsNull(C.SUM_EXC,0)+IsNull(C.SUM_NDS,0)-
               IsNull(P.SUM_ALL_PAY,0))<0 THEN
         -(IsNull(S.SALDO,0)+IsNull(C.SUM_FACT,0)+IsNull(C.SUM_EXC,0)+IsNull(C.SUM_NDS,0)-
           IsNull(P.SUM_ALL_PAY,0))
       ELSE
         0
    END),
  END_SALDO=
     Convert(Decimal(18,2),
       IsNull(S.SALDO,0)+IsNull(C.SUM_FACT,0)+IsNull(C.SUM_EXC,0)+IsNull(C.SUM_NDS,0)-
         IsNull(P.SUM_ALL_PAY,0))
 INTO
  #TmpCalcs
 FROM
  #TmpPart Cn (NoLock),
  ProCalcs C (NoLock),
  #TmpPays P (NoLock),
  #TmpSald S (NoLock)
 WHERE
  C.CONTRACT_ID=*Cn.CONTRACT_ID AND
  C.DATE_CALC=@dtCalcEnd AND
  P.CONTRACT_ID=Cn.CONTRACT_ID AND
  S.CONTRACT_ID=Cn.CONTRACT_ID
ALTER TABLE
    #TmpCalcs
 ADD PRIMARY KEY (CONTRACT_ID)

----------------------------------------------------------------------------------------

 SELECT
  CONSUMER_GROUP_ID    = PAG.abonent_group_id,
  CONSUMER_GROUP_NAME  = PAG.abonent_group_name,
  BEG_SALDO_DB         = Convert(Decimal(18,2),SUM(C.BEG_SALDO_DB)),
  BEG_SALDO_CR         = Convert(Decimal(18,2),SUM(C.BEG_SALDO_CR)),
  BEG_SALDO            = Convert(Decimal(18,2),SUM(C.BEG_SALDO)),
  QUANTITY             = Convert(Integer,SUM(C.QUANTITY)),
  AVR_TARIF            = case when isnull(SUM(QUANTITY),0) <> 0
                              then Convert(Decimal(7,2),SUM(C.SUM_FACT)/SUM(QUANTITY))
                              else 0 end,
  SUM_FACT             = Convert(Decimal(18,2),SUM(C.SUM_FACT)),
  SUM_EXC              = Convert(Decimal(18,2),SUM(C.SUM_EXC)),
  SUM_NDS_CALC         = Convert(Decimal(18,2),SUM(C.SUM_NDS_CALC)),
  SUM_REACTIVE         = Convert(Decimal(18,2),SUM(C.SUM_REACTIVE)),
  SUM_ALL_CALC         = Convert(Decimal(18,2),SUM(C.SUM_ALL_CALC)),
  SUM_PAY              = Convert(Decimal(18,2),SUM(C.SUM_PAY)),
  SUM_NDS_PAY          = Convert(Decimal(18,2),SUM(C.SUM_NDS_PAY)),
  SUM_FINE_PAY         = Convert(Decimal(18,2),SUM(C.SUM_FINE_PAY)),
  SUM_ALL_PAY          = Convert(Decimal(18,2),SUM(C.SUM_ALL_PAY)),
  END_SALDO_DB         = Convert(Decimal(18,2),SUM(C.END_SALDO_DB)),
  END_SALDO_CR         = Convert(Decimal(18,2),SUM(C.END_SALDO_CR)),
  END_SALDO            = Convert(Decimal(18,2),SUM(C.END_SALDO))
 INTO #TmpRez
 FROM
  #TmpCalcs         C   (NoLock),
  ProConsumerGroups PCG (nolock),
  ProAbonentGroups  PAG (nolock)
 WHERE
  C.CONSUMER_GROUP_ID = PCG.CONSUMER_GROUP_ID and
  PAG.abonent_group_id = PCG.top_group_id
 group by
  PAG.abonent_group_id,
  PAG.abonent_group_name


INSERT
 INTO
  #TmpRez
 SELECT
  CONSUMER_GROUP_ID=Convert(SmallInt,100),
  CONSUMER_GROUP_NAME=Convert(VarChar(30),'хрнцн:'),
  BEG_SALDO_DB=Convert(Decimal(18,2),SUM(C.BEG_SALDO_DB)),
  BEG_SALDO_CR=Convert(Decimal(18,2),SUM(C.BEG_SALDO_CR)),
  BEG_SALDO=Convert(Decimal(18,2),SUM(C.BEG_SALDO)),
  QUANTITY=Convert(Integer,SUM(C.QUANTITY)),
  AVR_TARIF            = case when isnull(SUM(QUANTITY),0) <> 0
                              then Convert(Decimal(7,2),SUM(C.SUM_FACT)/SUM(QUANTITY))
                              else 0 end,
  SUM_FACT=Convert(Decimal(18,2),SUM(C.SUM_FACT)),
  SUM_EXC=Convert(Decimal(18,2),SUM(C.SUM_EXC)),
  SUM_NDS_CALC=Convert(Decimal(18,2),SUM(C.SUM_NDS_CALC)),
  SUM_REACTIVE=Convert(Decimal(18,2),SUM(C.SUM_REACTIVE)),
  SUM_ALL_CALC=Convert(Decimal(18,2),SUM(C.SUM_ALL_CALC)),
  SUM_PAY=Convert(Decimal(18,2),SUM(C.SUM_PAY)),
  SUM_NDS_PAY=Convert(Decimal(18,2),SUM(C.SUM_NDS_PAY)),
  SUM_FINE_PAY=Convert(Decimal(18,2),SUM(C.SUM_FINE_PAY)),
  SUM_ALL_PAY=Convert(Decimal(18,2),SUM(C.SUM_ALL_PAY)),
  END_SALDO_DB=Convert(Decimal(18,2),SUM(C.END_SALDO_DB)),
  END_SALDO_CR=Convert(Decimal(18,2),SUM(C.END_SALDO_CR)),
  END_SALDO=Convert(Decimal(18,2),SUM(C.END_SALDO))
 FROM
  #TmpCalcs C (NoLock)

-----------------------------------------------------------------------------------------

SELECT
  *
 FROM
  #TmpRez (NoLock)
 ORDER BY
  CONSUMER_GROUP_ID


drop table #TmpSald
drop table #TmpPays
drop table #TmpCalcs
drop table #TmpRez



