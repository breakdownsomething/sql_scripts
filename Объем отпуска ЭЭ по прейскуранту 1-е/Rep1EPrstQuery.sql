/*
DECLARE
  @siGroupId SmallInt,
  @siSubGroupId SmallInt
SELECT
  @siGroupId=10011,--:psiGroupId,
  @siSubGroupId=1--:psiSubGroupId

IF EXISTS
       (SELECT *
         FROM TempDB..sysobjects
         WHERE id = object_id('tempdb..#TmpPart')
       )
  DROP TABLE
    #TmpPart

SELECT
  Cn.CONTRACT_ID,
  Cn.CONTRACT_NUMBER,
  Ab.ABONENT_NAME
INTO #TmpPart
FROM
  ProContracts Cn (NoLock),
  ProAbonents  Ab (NoLock)
 WHERE
--  Cn.GROUP_ID    = @siGroupId     AND
--  Cn.SUBGROUP_ID = @siSubGroupId  AND
  Ab.ABONENT_ID  = Cn.ABONENT_ID and
  Cn.date_contract_close < '2004-11-16'

*/
---------------------------------------------------------------------------------
DECLARE
  @siTenge      SmallInt,
  @BEGIN_DATE   smalldatetime,
  @END_DATE     smalldatetime

SELECT
  @siTenge  = 0,--:psiTenge
  @END_DATE = '2004-10-31'


select @END_DATE = dateadd(dd,-1,
                   dateadd(mm,-1,
                   dateadd(dd,+1,(select top 1 date_calc_end from ProGroups))))

select @BEGIN_DATE = dateadd(mm,-12,
                     dateadd(dd,+1,@END_DATE))

CREATE Table
  #TmpRows
 (ROW_ID       TinyInt Null,
  MEASURE_ID   TinyInt Null,
  TARIFF_ID    Integer Null,
  TARIFF_VALUE Decimal(9,4) Null,
  GOD          Decimal(12,2) Null,
  QR1          Decimal(12,2) Null,
  MS1          Decimal(12,2) Null,
  MS2          Decimal(12,2) Null,
  MS3          Decimal(12,2) Null,
  QR2          Decimal(12,2) Null,
  MS4          Decimal(12,2) Null,
  MS5          Decimal(12,2) Null,
  MS6          Decimal(12,2) Null,
  QR3          Decimal(12,2) Null,
  MS7          Decimal(12,2) Null,
  MS8          Decimal(12,2) Null,
  MS9          Decimal(12,2) Null,
  QR4          Decimal(12,2) Null,
  MS10         Decimal(12,2) Null,
  MS11         Decimal(12,2) Null,
  MS12         Decimal(12,2) Null)

CREATE Table
  #TmpDetails
 (DATE_CALC       SmallDateTime,
  CONTRACT_ID     Integer,
  CONTRACT_NUMBER VarChar(10),
  CALC_QUANTITY   Integer,
  TARIFF_ID       Integer,
  TARIFF_VALUE    Decimal(9,4),
  MEASURE_ID      Tinyint,
  SUM_CALC        decimal(12,2))

INSERT
  #TmpDetails
 (DATE_CALC,
  CONTRACT_ID,
  CONTRACT_NUMBER,
  CALC_QUANTITY,
  TARIFF_ID,
  TARIFF_VALUE,
  MEASURE_ID,
  SUM_CALC) 
SELECT
  P.DATE_CALC,
  P.CONTRACT_ID,
  P.CONTRACT_NUMBER,
  PD.CALC_QUANTITY,
  PD.TARIFF_ID,
  PD.TARIFF_VALUE,
  PD.MEASURE_ID,
  PD.SUM_CALC
FROM
  ProCalcDetails PD (NoLock),
  ProCalcs       P  (nolock) --,
--  #TmpPart       T (NoLock)
 WHERE
--  P.CONTRACT_ID = T.CONTRACT_ID AND
  (P.DATE_CALC between @BEGIN_DATE  and  @END_DATE) and
  P.CALC_ID = PD.calc_id and
  PD.tariff_id is not null and
  PD.tariff_value is not null
 order by p.contract_id

IF @siTenge=0
BEGIN
  INSERT
    #TmpRows
      (MEASURE_ID,
       TARIFF_ID,
       TARIFF_VALUE,
       GOD,
       QR1,
       MS1,
       MS2,
       MS3,
       QR2,
       MS4,
       MS5,
       MS6,
       QR3,
       MS7,
       MS8,
       MS9,
       QR4,
       MS10,
       MS11,
       MS12)
   SELECT
       MEASURE_ID,
       TARIFF_ID,
       TARIFF_VALUE,
       GOD = ROUND(SUM(CALC_QUANTITY)/CASE WHEN MEASURE_ID = 4 THEN 1 ELSE 12 END,0),
       QR1 = ROUND(SUM(CASE WHEN MONTH(DATE_CALC) IN (1,2,3) THEN CALC_QUANTITY ELSE 0 END)/
                   (CASE WHEN MEASURE_ID = 4 THEN 1 ELSE 3 END),0),
       MS1=SUM(CASE WHEN MONTH(DATE_CALC)=1 THEN CALC_QUANTITY ELSE 0 END),
       MS2=SUM(CASE WHEN MONTH(DATE_CALC)=2 THEN CALC_QUANTITY ELSE 0 END),
       MS3=SUM(CASE WHEN MONTH(DATE_CALC)=3 THEN CALC_QUANTITY ELSE 0 END),
       QR2=ROUND(SUM(CASE WHEN MONTH(DATE_CALC) IN (4,5,6) THEN CALC_QUANTITY ELSE 0 END)/
              (CASE WHEN MEASURE_ID=4 THEN 1 ELSE 3 END),0),
       MS4=SUM(CASE WHEN MONTH(DATE_CALC)=4 THEN CALC_QUANTITY ELSE 0 END),
       MS5=SUM(CASE WHEN MONTH(DATE_CALC)=5 THEN CALC_QUANTITY ELSE 0 END),
       MS6=SUM(CASE WHEN MONTH(DATE_CALC)=6 THEN CALC_QUANTITY ELSE 0 END),
       QR3=ROUND(SUM(CASE WHEN MONTH(DATE_CALC) IN (7,8,9) THEN CALC_QUANTITY ELSE 0 END)/
              (CASE WHEN MEASURE_ID=4 THEN 1 ELSE 3 END),0),
       MS7=SUM(CASE WHEN MONTH(DATE_CALC)=7 THEN CALC_QUANTITY ELSE 0 END),
       MS8=SUM(CASE WHEN MONTH(DATE_CALC)=8 THEN CALC_QUANTITY ELSE 0 END),
       MS9=SUM(CASE WHEN MONTH(DATE_CALC)=9 THEN CALC_QUANTITY ELSE 0 END),
       QR4=ROUND(SUM(CASE WHEN MONTH(DATE_CALC) IN (10,11,12) THEN CALC_QUANTITY ELSE 0 END)/
              (CASE WHEN MEASURE_ID=4 THEN 1 ELSE 3 END),0),
       MS10=SUM(CASE WHEN MONTH(DATE_CALC)=10 THEN CALC_QUANTITY ELSE 0 END),
       MS11=SUM(CASE WHEN MONTH(DATE_CALC)=11 THEN CALC_QUANTITY ELSE 0 END),
       MS12=SUM(CASE WHEN MONTH(DATE_CALC)=12 THEN CALC_QUANTITY ELSE 0 END)
   FROM
       #TmpDetails (NoLock)
   GROUP BY
       MEASURE_ID,
       TARIFF_ID,
       TARIFF_VALUE
END
ELSE
BEGIN

  UPDATE
    #TmpDetails
  SET
    TARIFF_VALUE=E.TARIFF_VALUE
  FROM
    #TmpDetails D  (NoLock),
    Source_1E E (NoLock)
  WHERE
    PatIndex('% '+LTrim(RTrim(Str(D.TARIFF_ID)))+',%',E.LIST_CODES)>0 AND
    E.ROW_ID NOT IN (100,110,120)

  INSERT
    #TmpRows
      (MEASURE_ID,
       TARIFF_ID,
       TARIFF_VALUE,
       GOD,
       QR1,
       MS1,
       MS2,
       MS3,
       QR2,
       MS4,
       MS5,
       MS6,
       QR3,
       MS7,
       MS8,
       MS9,
       QR4,
       MS10,
       MS11,
       MS12)
   SELECT
       MEASURE_ID,
       TARIFF_ID,
       TARIFF_VALUE,
       GOD = Convert(Decimal(12,2),
                    (CASE WHEN MEASURE_ID=7 THEN 1 ELSE 12 END)
                        --*TARIFF_VALUE * ROUND(SUM(CALC_QUANTITY)
                          *sum(SUM_CALC) 
                               /
                    (CASE WHEN MEASURE_ID=7 THEN 1 ELSE 12 END)
                    ),

       QR1 = Convert(Decimal(12,2),
                    (CASE WHEN MEASURE_ID=7 THEN 1 ELSE 3 END)
--                     *TARIFF_VALUE*ROUND(SUM(CASE WHEN MONTH(DATE_CALC) IN (1,2,3) THEN CALC_QUANTITY ELSE 0 END)
                       *sum(CASE WHEN MONTH(DATE_CALC) IN (1,2,3) THEN SUM_CALC ELSE 0 END)
                               /
                    (CASE WHEN MEASURE_ID=7 THEN 1 ELSE 3 END)),

       MS1 = Convert(Decimal(12,2),
--                     TARIFF_VALUE*SUM(CASE WHEN MONTH(DATE_CALC)=1 THEN CALC_QUANTITY ELSE 0 END)
                     SUM(CASE WHEN MONTH(DATE_CALC)=1 THEN SUM_CALC ELSE 0 END)
                     ),

       MS2 = Convert(Decimal(12,2),
--                     TARIFF_VALUE*SUM(CASE WHEN MONTH(DATE_CALC)=2 THEN CALC_QUANTITY ELSE 0 END)
                    SUM(CASE WHEN MONTH(DATE_CALC)=2 THEN SUM_CALC ELSE 0 END)  
                     ),

       MS3 = Convert(Decimal(12,2),
--                     TARIFF_VALUE*SUM(CASE WHEN MONTH(DATE_CALC)=3 THEN CALC_QUANTITY ELSE 0 END)
                     SUM(CASE WHEN MONTH(DATE_CALC)=3 THEN SUM_CALC ELSE 0 END)),

       QR2 = Convert(Decimal(12,2),
                    (CASE WHEN MEASURE_ID=7 THEN 1 ELSE 3 END)
--                    *TARIFF_VALUE * ROUND(SUM(CASE WHEN MONTH(DATE_CALC) IN (4,5,6) THEN CALC_QUANTITY ELSE 0 END)
                    *SUM(CASE WHEN MONTH(DATE_CALC) IN (4,5,6) THEN SUM_CALC ELSE 0 END)
                          /
                    (CASE WHEN MEASURE_ID=7 THEN 1 ELSE 3 END)),

       MS4 = Convert(Decimal(12,2),
--                     TARIFF_VALUE*SUM(CASE WHEN MONTH(DATE_CALC)=4 THEN CALC_QUANTITY ELSE 0 END)
                     SUM(CASE WHEN MONTH(DATE_CALC)=4 THEN SUM_CALC ELSE 0 END) 
                     ),

       MS5 = Convert(Decimal(12,2),
--                     TARIFF_VALUE*SUM(CASE WHEN MONTH(DATE_CALC)=5 THEN CALC_QUANTITY ELSE 0 END)
                     SUM(CASE WHEN MONTH(DATE_CALC)=5 THEN SUM_CALC ELSE 0 END)
                     ),

       MS6 = Convert(Decimal(12,2),
--                     TARIFF_VALUE*SUM(CASE WHEN MONTH(DATE_CALC)=6 THEN CALC_QUANTITY ELSE 0 END)
                     SUM(CASE WHEN MONTH(DATE_CALC)=6 THEN SUM_CALC ELSE 0 END)    
                     ),

       QR3 = Convert(Decimal(12,2),
                    (CASE WHEN MEASURE_ID=7 THEN 1 ELSE 3 END)
--                    *TARIFF_VALUE*ROUND(SUM(CASE WHEN MONTH(DATE_CALC) IN (7,8,9) THEN CALC_QUANTITY ELSE 0 END)
                    * SUM(CASE WHEN MONTH(DATE_CALC) IN (7,8,9) THEN SUM_CALC ELSE 0 END)
                           /
                    (CASE WHEN MEASURE_ID=7 THEN 1 ELSE 3 END)),

       MS7 = Convert(Decimal(12,2),
--                    TARIFF_VALUE*SUM(CASE WHEN MONTH(DATE_CALC)=7 THEN CALC_QUANTITY ELSE 0 END)
                    SUM(CASE WHEN MONTH(DATE_CALC)=7 THEN SUM_CALC ELSE 0 END)
                    ),

       MS8 = Convert(Decimal(12,2),
--                     TARIFF_VALUE *SUM(CASE WHEN MONTH(DATE_CALC)=8 THEN CALC_QUANTITY ELSE 0 END)
                     SUM(CASE WHEN MONTH(DATE_CALC)=8 THEN SUM_CALC ELSE 0 END)
                     ),

       MS9 = Convert(Decimal(12,2),
--                     TARIFF_VALUE*SUM(CASE WHEN MONTH(DATE_CALC)=9 THEN CALC_QUANTITY ELSE 0 END)
                     SUM(CASE WHEN MONTH(DATE_CALC)=9 THEN SUM_CALC ELSE 0 END)
                     ),

       QR4 = Convert(Decimal(12,2),
                    (CASE WHEN MEASURE_ID=7 THEN 1 ELSE 3 END)
--                   *TARIFF_VALUE*ROUND(SUM(CASE WHEN MONTH(DATE_CALC) IN (10,11,12) THEN CALC_QUANTITY ELSE 0 END)
                    *SUM(CASE WHEN MONTH(DATE_CALC) IN (10,11,12) THEN SUM_CALC ELSE 0 END)    
                            /
                    (CASE WHEN MEASURE_ID=7 THEN 1 ELSE 3 END)),

       MS10 = Convert(Decimal(12,2),
--                    TARIFF_VALUE*SUM(CASE WHEN MONTH(DATE_CALC)=10 THEN CALC_QUANTITY ELSE 0 END)
                     SUM(CASE WHEN MONTH(DATE_CALC)=10 THEN SUM_CALC ELSE 0 END)
                      ),

       MS11 = Convert(Decimal(12,2),
--                      TARIFF_VALUE*SUM(CASE WHEN MONTH(DATE_CALC)=11 THEN CALC_QUANTITY ELSE 0 END)
                      SUM(CASE WHEN MONTH(DATE_CALC)=11 THEN SUM_CALC ELSE 0 END)
                      ),

       MS12 = Convert(Decimal(12,2),
--                      TARIFF_VALUE*SUM(CASE WHEN MONTH(DATE_CALC)=12 THEN CALC_QUANTITY ELSE 0 END)
                     SUM(CASE WHEN MONTH(DATE_CALC)=12 THEN SUM_CALC ELSE 0 END)
                     )
  FROM
       #TmpDetails (NoLock)
  GROUP BY
       MEASURE_ID,
       TARIFF_ID,
       TARIFF_VALUE
END -- if Tenge


SELECT
  E.ROW_ID,
  E.ROW_NUMBER,
  E.ROW_NAME,
  MEASURE_ID=R.MEASURE_ID,
  E.TARIFF_VALUE,
  E.LIST_CODES,
  GOD=SUM(R.GOD),
  QR1=SUM(R.QR1),
  MS1=SUM(R.MS1),
  MS2=SUM(R.MS2),
  MS3=SUM(R.MS3),
  QR2=SUM(R.QR2),
  MS4=SUM(R.MS4),
  MS5=SUM(R.MS5),
  MS6=SUM(R.MS6),
  QR3=SUM(R.QR3),
  MS7=SUM(R.MS7),
  MS8=SUM(R.MS8),
  MS9=SUM(R.MS9),
  QR4=SUM(R.QR4),
  MS10=SUM(R.MS10),
  MS11=SUM(R.MS11),
  MS12=SUM(R.MS12)
 INTO
  #TmpRez
 FROM
  Source_1E E (NoLock),
  #TmpRows  R (NoLock)
 WHERE
  PatIndex('% '+LTrim(RTrim(Str(R.TARIFF_ID)))+',%',E.LIST_CODES)>0
 GROUP BY
  E.ROW_ID,
  E.ROW_NUMBER,
  E.ROW_NAME,
  R.MEASURE_ID,
  E.TARIFF_VALUE,
  E.LIST_CODES

------------------------------------------------------------------------
-- Непонятно------------------------------------------------------------
INSERT
  #TmpRez
 (ROW_ID,
  ROW_NUMBER,
  ROW_NAME,
  MEASURE_ID,
  TARIFF_VALUE,
  LIST_CODES,
  GOD,
  QR1,
  MS1,
  MS2,
  MS3,
  QR2,
  MS4,
  MS5,
  MS6,
  QR3,
  MS7,
  MS8,
  MS9,
  QR4,
  MS10,
  MS11,
  MS12)
SELECT
  ROW_ID=310,
  ROW_NUMBER=Null,
  ROW_NAME=E.ROW_NAME,
  MEASURE_ID=4,
  TARIFF_VALUE=Null,
  LIST_CODES=' 4#0: 4#300',
  GOD=SUM(R.GOD),
  QR1=SUM(R.QR1),
  MS1=SUM(R.MS1),
  MS2=SUM(R.MS2),
  MS3=SUM(R.MS3),
  QR2=SUM(R.QR2),
  MS4=SUM(R.MS4),
  MS5=SUM(R.MS5),
  MS6=SUM(R.MS6),
  QR3=SUM(R.QR3),
  MS7=SUM(R.MS7),
  MS8=SUM(R.MS8),
  MS9=SUM(R.MS9),
  QR4=SUM(R.QR4),
  MS10=SUM(R.MS10),
  MS11=SUM(R.MS11),
  MS12=SUM(R.MS12)
 FROM
  Source_1E E (NoLock),
  #TmpRez R (NoLock)
 WHERE
  E.ROW_ID=310 AND
  R.ROW_ID<E.ROW_ID AND
  R.MEASURE_ID=4
 GROUP BY
  E.ROW_NAME


INSERT
  #TmpRez
 (ROW_ID,
  ROW_NUMBER,
  ROW_NAME,
  MEASURE_ID,
  TARIFF_VALUE,
  LIST_CODES,
  GOD,
  QR1,
  MS1,
  MS2,
  MS3,
  QR2,
  MS4,
  MS5,
  MS6,
  QR3,
  MS7,
  MS8,
  MS9,
  QR4,
  MS10,
  MS11,
  MS12)
 SELECT
  ROW_ID=730,
  ROW_NUMBER=Null,
  ROW_NAME=E.ROW_NAME,
  MEASURE_ID=7,
  TARIFF_VALUE=Null,
  LIST_CODES=' 4#0: 4#720',
  GOD=SUM(R.GOD),
  QR1=SUM(R.QR1),
  MS1=SUM(R.MS1),
  MS2=SUM(R.MS2),
  MS3=SUM(R.MS3),
  QR2=SUM(R.QR2),
  MS4=SUM(R.MS4),
  MS5=SUM(R.MS5),
  MS6=SUM(R.MS6),
  QR3=SUM(R.QR3),
  MS7=SUM(R.MS7),
  MS8=SUM(R.MS8),
  MS9=SUM(R.MS9),
  QR4=SUM(R.QR4),
  MS10=SUM(R.MS10),
  MS11=SUM(R.MS11),
  MS12=SUM(R.MS12)
 FROM
  Source_1E E (NoLock),
  #TmpRez R (NoLock)
 WHERE
  E.ROW_ID=730 AND
  R.ROW_ID <>310 AND
  R.ROW_ID<E.ROW_ID AND
  R.MEASURE_ID=7
 GROUP BY
  E.ROW_NAME


INSERT
  #TmpRez
 (ROW_ID,
  ROW_NUMBER,
  ROW_NAME,
  MEASURE_ID,
  TARIFF_VALUE,
  LIST_CODES,
  GOD,
  QR1,
  MS1,
  MS2,
  MS3,
  QR2,
  MS4,
  MS5,
  MS6,
  QR3,
  MS7,
  MS8,
  MS9,
  QR4,
  MS10,
  MS11,
  MS12)
 SELECT
  ROW_ID=740,
  ROW_NUMBER=Null,
  ROW_NAME=E.ROW_NAME,
  MEASURE_ID=4,
  TARIFF_VALUE=Null,
  LIST_CODES=' 4#0: 4#730',
  GOD=SUM(R.GOD),
  QR1=SUM(R.QR1),
  MS1=SUM(R.MS1),
  MS2=SUM(R.MS2),
  MS3=SUM(R.MS3),
  QR2=SUM(R.QR2),
  MS4=SUM(R.MS4),
  MS5=SUM(R.MS5),
  MS6=SUM(R.MS6),
  QR3=SUM(R.QR3),
  MS7=SUM(R.MS7),
  MS8=SUM(R.MS8),
  MS9=SUM(R.MS9),
  QR4=SUM(R.QR4),
  MS10=SUM(R.MS10),
  MS11=SUM(R.MS11),
  MS12=SUM(R.MS12)
 FROM
  Source_1E E (NoLock),
  #TmpRez R (NoLock)
 WHERE
  E.ROW_ID=740 AND
  R.ROW_ID <>310 AND
  R.ROW_ID<E.ROW_ID AND
  R.MEASURE_ID=4
 GROUP BY
  E.ROW_NAME


IF @siTenge=1
INSERT
  #TmpRez
 (ROW_ID,
  ROW_NUMBER,
  ROW_NAME,
  MEASURE_ID,
  TARIFF_VALUE,
  LIST_CODES,
  GOD,
  QR1,
  MS1,
  MS2,
  MS3,
  QR2,
  MS4,
  MS5,
  MS6,
  QR3,
  MS7,
  MS8,
  MS9,
  QR4,
  MS10,
  MS11,
  MS12)
 SELECT
  ROW_ID=750,
  ROW_NUMBER=Null,
  ROW_NAME=E.ROW_NAME,
  MEASURE_ID=4,
  TARIFF_VALUE=Null,
  LIST_CODES=' 4#730: 4#740',
  GOD=SUM(R.GOD),
  QR1=SUM(R.QR1),
  MS1=SUM(R.MS1),
  MS2=SUM(R.MS2),
  MS3=SUM(R.MS3),
  QR2=SUM(R.QR2),
  MS4=SUM(R.MS4),
  MS5=SUM(R.MS5),
  MS6=SUM(R.MS6),
  QR3=SUM(R.QR3),
  MS7=SUM(R.MS7),
  MS8=SUM(R.MS8),
  MS9=SUM(R.MS9),
  QR4=SUM(R.QR4),
  MS10=SUM(R.MS10),
  MS11=SUM(R.MS11),
  MS12=SUM(R.MS12)
 FROM
  Source_1E E (NoLock),
  #TmpRez R (NoLock)
 WHERE
  E.ROW_ID=750 AND
 (R.ROW_ID=730 OR R.ROW_ID=740) AND
  R.ROW_ID<E.ROW_ID
 GROUP BY
  E.ROW_NAME



SELECT
  E.ROW_ID,
  E.ROW_NUMBER,
  E.ROW_NAME,
--  R.MEASURE_ID,
--  LIST_CODES=IsNull(E.LIST_CODES,R.LIST_CODES),
  E.TARIFF_VALUE,
  R.GOD,
  R.QR1,
  R.QR2,
  R.QR3,
  R.QR4,
  R.MS1,
  R.MS2,
  R.MS3,
  R.MS4,
  R.MS5,
  R.MS6,
  R.MS7,
  R.MS8,
  R.MS9,
  R.MS10,
  R.MS11,
  R.MS12
 FROM
  #TmpRez R (NoLock),
  Source_1E E (NoLock)
 WHERE
  R.ROW_ID=*E.ROW_ID
ORDER BY
  E.ROW_ID


DROP Table #TmpRows
DROP Table #TmpDetails
DROP Table #TmpRez



