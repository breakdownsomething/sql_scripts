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
--2 Вар
DECLARE
  @dtCalcBegin  DateTime,
  @dtCalcEnd  DateTime,
  @dtMainCalcEnd  DateTime,
  @siMeasure  SmallInt

SELECT
/*
  @dtCalcBegin   =  :pdtCalcBegin,
  @dtCalcEnd     =  :pdtCalcEnd,
  @dtMainCalcEnd =  :pdtMainCalcEnd

--  @dtCalcBegin='2000-09-01',
--  @dtCalcEnd='2000-09-30'
*/

  @dtCalcBegin   = '2004-11-01',
  @dtCalcEnd     = '2004-11-30',
  @dtMainCalcEnd = '2004-11-30' 

SELECT
  Cn.CONTRACT_ID,
  Cn.CONSUMER_GROUP_ID,
  SALDO=
    CASE
      WHEN @dtMainCalcEnd=@dtCalcEnd THEN
        Cn.SALDO
      ELSE
        C.SALDO
    END
 INTO
  #TmpSald
 FROM
  #TmpPart T (Nolock),
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
  #TmpPart T (Nolock),
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
/*  (Cn.DATE_CONTRACT_CLOSE IS Null OR
   Cn.DATE_CONTRACT_CLOSE>=@dtCalcBegin)AND
  Cn.DATE_CONTRACT<@dtCalcEnd AND
*/
  C.CONTRACT_ID=*Cn.CONTRACT_ID AND
  C.DATE_CALC=@dtCalcEnd AND
  P.CONTRACT_ID=Cn.CONTRACT_ID AND
  S.CONTRACT_ID=Cn.CONTRACT_ID
ALTER TABLE
    #TmpCalcs
 ADD PRIMARY KEY (CONTRACT_ID)
-------------------------------------------------------------------------------------------








-------------------------------------------------------------------------------------------

SELECT
  CONSUMER_GROUP_ID=Convert(SmallInt,0),
  CONSUMER_GROUP_NAME=Convert(VarChar(30),'Потребители'),
  BEG_SALDO_DB=Convert(Decimal(18,2),SUM(C.BEG_SALDO_DB)),
  BEG_SALDO_CR=Convert(Decimal(18,2),SUM(C.BEG_SALDO_CR)),
  BEG_SALDO=Convert(Decimal(18,2),SUM(C.BEG_SALDO)),
  QUANTITY=Convert(Integer,SUM(C.QUANTITY)),
  AVR_TARIF=Convert(Decimal(7,2),SUM(C.SUM_FACT)/SUM(QUANTITY)),
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
 INTO
  #TmpRez
 FROM
  #TmpCalcs C (NoLock)

INSERT
 INTO
  #TmpRez
SELECT
  CONSUMER_GROUP_ID=Convert(SmallInt,10),
  CONSUMER_GROUP_NAME=Convert(VarChar(30),'Население'),
  BEG_SALDO_DB=Convert(Decimal(18,2),SUM(C.BEG_SALDO_DB)),
  BEG_SALDO_CR=Convert(Decimal(18,2),SUM(C.BEG_SALDO_CR)),
  BEG_SALDO=Convert(Decimal(18,2),SUM(C.BEG_SALDO)),
  QUANTITY=Convert(Integer,SUM(C.QUANTITY)),
  AVR_TARIF=Convert(Decimal(7,2),SUM(C.SUM_FACT)/SUM(QUANTITY)),
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
WHERE
-- Население
  C.CONSUMER_GROUP_ID IS NULL

INSERT
 INTO
  #TmpRez
SELECT
  CONSUMER_GROUP_ID=Convert(SmallInt,20),
  CONSUMER_GROUP_NAME=Convert(VarChar(30),'Промышленность'),
  BEG_SALDO_DB=Convert(Decimal(18,2),SUM(C.BEG_SALDO_DB)),
  BEG_SALDO_CR=Convert(Decimal(18,2),SUM(C.BEG_SALDO_CR)),
  BEG_SALDO=Convert(Decimal(18,2),SUM(C.BEG_SALDO)),
  QUANTITY=Convert(Integer,SUM(C.QUANTITY)),
  AVR_TARIF=Convert(Decimal(7,2),SUM(C.SUM_FACT)/SUM(QUANTITY)),
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
WHERE
-- Промышленность
  C.CONSUMER_GROUP_ID IN (110,120,129,130,140,150)

INSERT
 INTO
  #TmpRez
SELECT
  CONSUMER_GROUP_ID=Convert(SmallInt,30),
  CONSUMER_GROUP_NAME=Convert(VarChar(30),'Бюджетные'),
  BEG_SALDO_DB=Convert(Decimal(18,2),SUM(C.BEG_SALDO_DB)),
  BEG_SALDO_CR=Convert(Decimal(18,2),SUM(C.BEG_SALDO_CR)),
  BEG_SALDO=Convert(Decimal(18,2),SUM(C.BEG_SALDO)),
  QUANTITY=Convert(Integer,SUM(C.QUANTITY)),
  AVR_TARIF=Convert(Decimal(7,2),SUM(C.SUM_FACT)/SUM(QUANTITY)),
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
WHERE
-- Бюджетные
  C.CONSUMER_GROUP_ID IN (121,124,211,214,231,122,204,205,206,207,208,209,212,213,215,216,232,222,223,224,225,226,227)

INSERT
 INTO
  #TmpRez
SELECT
  CONSUMER_GROUP_ID=Convert(SmallInt,31),
  CONSUMER_GROUP_NAME=Convert(VarChar(30),'в т.ч. республиканский'),
  BEG_SALDO_DB=Convert(Decimal(18,2),SUM(C.BEG_SALDO_DB)),
  BEG_SALDO_CR=Convert(Decimal(18,2),SUM(C.BEG_SALDO_CR)),
  BEG_SALDO=Convert(Decimal(18,2),SUM(C.BEG_SALDO)),
  QUANTITY=Convert(Integer,SUM(C.QUANTITY)),
  AVR_TARIF=Convert(Decimal(7,2),SUM(C.SUM_FACT)/SUM(QUANTITY)),
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
WHERE
-- Бюджетные республиканские
  C.CONSUMER_GROUP_ID IN (121,124,211,214,231)

INSERT
 INTO
  #TmpRez
SELECT
  CONSUMER_GROUP_ID=Convert(SmallInt,32),
  CONSUMER_GROUP_NAME=Convert(VarChar(30),'в т.ч. местный'),
  BEG_SALDO_DB=Convert(Decimal(18,2),SUM(C.BEG_SALDO_DB)),
  BEG_SALDO_CR=Convert(Decimal(18,2),SUM(C.BEG_SALDO_CR)),
  BEG_SALDO=Convert(Decimal(18,2),SUM(C.BEG_SALDO)),
  QUANTITY=Convert(Integer,SUM(C.QUANTITY)),
  AVR_TARIF=Convert(Decimal(7,2),SUM(C.SUM_FACT)/SUM(QUANTITY)),
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
WHERE
-- Бюджетные местные
 C.CONSUMER_GROUP_ID IN (122,204,205,206,207,208,209,212,215,232,222,223,224,225,226,227)

INSERT
 INTO
  #TmpRez
SELECT
  CONSUMER_GROUP_ID=Convert(SmallInt,33),
  CONSUMER_GROUP_NAME=Convert(VarChar(30),'в т.ч. областной'),
  BEG_SALDO_DB=Convert(Decimal(18,2),SUM(C.BEG_SALDO_DB)),
  BEG_SALDO_CR=Convert(Decimal(18,2),SUM(C.BEG_SALDO_CR)),
  BEG_SALDO=Convert(Decimal(18,2),SUM(C.BEG_SALDO)),
  QUANTITY=Convert(Integer,SUM(C.QUANTITY)),
  AVR_TARIF=Convert(Decimal(7,2),SUM(C.SUM_FACT)/SUM(QUANTITY)),
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
WHERE
-- Бюджетные областные
  C.CONSUMER_GROUP_ID IN (213,216)

INSERT
 INTO
  #TmpRez
SELECT
  CONSUMER_GROUP_ID=Convert(SmallInt,40),
  CONSUMER_GROUP_NAME=Convert(VarChar(30),'АПК'),
  BEG_SALDO_DB=Convert(Decimal(18,2),SUM(C.BEG_SALDO_DB)),
  BEG_SALDO_CR=Convert(Decimal(18,2),SUM(C.BEG_SALDO_CR)),
  BEG_SALDO=Convert(Decimal(18,2),SUM(C.BEG_SALDO)),
  QUANTITY=Convert(Integer,SUM(C.QUANTITY)),
  AVR_TARIF=Convert(Decimal(7,2),SUM(C.SUM_FACT)/SUM(QUANTITY)),
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
WHERE
-- АПК
  C.CONSUMER_GROUP_ID IN (123,250)

INSERT
 INTO
  #TmpRez
SELECT
  CONSUMER_GROUP_ID=Convert(SmallInt,45),
  CONSUMER_GROUP_NAME=Convert(VarChar(30),'Сельхозпотребители'),
  BEG_SALDO_DB=Convert(Decimal(18,2),SUM(C.BEG_SALDO_DB)),
  BEG_SALDO_CR=Convert(Decimal(18,2),SUM(C.BEG_SALDO_CR)),
  BEG_SALDO=Convert(Decimal(18,2),SUM(C.BEG_SALDO)),
  QUANTITY=Convert(Integer,SUM(C.QUANTITY)),
  AVR_TARIF=Convert(Decimal(7,2),SUM(C.SUM_FACT)/SUM(QUANTITY)),
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
WHERE
-- Сельхозпотребители
  C.CONSUMER_GROUP_ID IN(300)

INSERT
 INTO
  #TmpRez
SELECT
  CONSUMER_GROUP_ID=Convert(SmallInt,50),
  CONSUMER_GROUP_NAME=Convert(VarChar(30),'Прочие'),
  BEG_SALDO_DB=Convert(Decimal(18,2),SUM(C.BEG_SALDO_DB)),
  BEG_SALDO_CR=Convert(Decimal(18,2),SUM(C.BEG_SALDO_CR)),
  BEG_SALDO=Convert(Decimal(18,2),SUM(C.BEG_SALDO)),
  QUANTITY=Convert(Integer,SUM(C.QUANTITY)),
  AVR_TARIF=Convert(Decimal(7,2),SUM(C.SUM_FACT)/SUM(QUANTITY)),
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
WHERE
--Прочие
 C.CONSUMER_GROUP_ID IN (0,221,229,233,240)

INSERT
 INTO
  #TmpRez
SELECT
  CONSUMER_GROUP_ID=Convert(SmallInt,60),
  CONSUMER_GROUP_NAME=Convert(VarChar(30),'Неверно определённые'),
  BEG_SALDO_DB=Convert(Decimal(18,2),SUM(C.BEG_SALDO_DB)),
  BEG_SALDO_CR=Convert(Decimal(18,2),SUM(C.BEG_SALDO_CR)),
  BEG_SALDO=Convert(Decimal(18,2),SUM(C.BEG_SALDO)),
  QUANTITY=Convert(Integer,SUM(C.QUANTITY)),
  AVR_TARIF=Convert(Decimal(7,2),SUM(C.SUM_FACT)/SUM(QUANTITY)),
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
WHERE
-- Неверно определённые
  C.CONSUMER_GROUP_ID
   NOT IN (110,120,129,130,140,150,  121,124,211,214,231,122,204,205,206,207,208,209,212,213,215,216,232,123,250,0,221,229,233,240,300,222,223,224,225,226,227)


SELECT
  *
 FROM
  #TmpRez (NoLock)
 ORDER BY
  CONSUMER_GROUP_ID
