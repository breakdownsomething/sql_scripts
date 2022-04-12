if exists (select * from TempDB..sysobjects where id = object_id('TempDB..#ProDivPaymentSum') )
  drop table #ProDivPaymentSum

CREATE TABLE #ProDivPaymentSum (
	[CONTRACT_ID] [int] NOT NULL ,
	[DATE_CALC] [datetime] NOT NULL ,
	[SUM_EE_B] [decimal](18, 2) NULL ,
	[SUM_NDS_B] [decimal](18, 2) NULL ,
	[SUM_EXC_B] [decimal](18, 2) NULL ,
	[QUANTITY_B] [int] NULL ,
	[SUM_EE_A] [decimal](18, 2) NULL ,
	[SUM_NDS_A] [decimal](18, 2) NULL ,
	[SUM_EXC_A] [decimal](18, 2) NULL ,
	[QUANTITY_A] [int] NULL ,
  -------------------------------------
  [SUM_EE_15] [decimal](18, 2) NULL ,
	[SUM_NDS_15] [decimal](18, 2) NULL ,
	[SUM_EXC_15] [decimal](18, 2) NULL ,
	[QUANTITY_15] [int] NULL ,
  -------------------------------------
	[SUM_EE] [decimal](18, 2) NULL ,
	[SUM_NDS] [decimal](18, 2) NULL ,
	[SUM_EXC] [decimal](18, 2) NULL ,
	[QUANTITY] [int] NULL ,
       	[SALDOCR] [decimal](18, 2) NULL ,
       	[SUM_EECR] [decimal](18, 2) NULL ,
	[SUM_NDSCR] [decimal](18, 2) NULL ,
	[SUM_EXCCR] [decimal](18, 2) NULL ,
	[QUANTITYCR] [int] NULL ,
        [SUM_PAY]   [decimal] (18,2) NULL,
	[COMMENT] [varchar] (40) NULL
) ON [PRIMARY]

ALTER TABLE [#ProDivPaymentSum] WITH NOCHECK ADD
	PRIMARY KEY  NONCLUSTERED
	(
		[CONTRACT_ID],
		[DATE_CALC]
	)  ON [PRIMARY]

/******************************************************************************/

DECLARE
  @iContractId      Integer,
  @vcContractNumber VarChar(10),
  @dtDatePay        DateTime,
  @dtDateBeg        DateTime,
  @dtDateEnd        DateTime,
  @dtCurBeg         DateTime,
  @dtCurEnd         DateTime,
  @dtCalc           DateTime,
  @dtFirst          DateTime,
  @dtPrev           DateTime,
  @dfTaxExc         Decimal(9,2),
  @dfTaxACTBefo     Decimal(9,2),
  @dfTaxACTAft      Decimal(9,2),
  @dfTaxACTAftAft   Decimal(9,2)

SELECT
-- база 
  @dtDateBeg ='1998-08-31',   -- период начала хранимых данных (конец)
  @dtDateEnd ='2004-02-29',-- :dtDateEnd,    --'2001-08-31', -- последний расчетный период по базе данных (конец)
-- расчет
  @dtCurBeg  ='2004-01-01', --:dtCurBeg,     --'2001-07-01', -- первый период расчета (начало)
  @dtCurEnd  ='2004-01-31', --:dtCurEnd,     --'2001-07-31',  -- последний период расчета (конец)
  @dtFirst   ='2001-07-31',   -- оставить
  @dtCalc    ='2004-01-31' --:dtCurEnd      --'2001-07-31'

SELECT
  @dtPrev    = DateAdd(dd,-1,DateAdd(mm,-1,DateAdd(dd,1,@dtCalc)))

DECLARE curExistsContracts CURSOR FOR
  SELECT Distinct
    Cn.CONTRACT_ID,
    Cn.CONTRACT_NUMBER,
    DATE_PAY=@dtCurEnd
   FROM
    ProContracts Cn (NOLOCK),
    ProPayments P (NOLOCK)
   WHERE
    P.CONTRACT_ID = Cn.CONTRACT_ID AND
    P.DATE_PAY BETWEEN @dtCurBeg AND @dtCurEnd
  UNION SELECT
    C.CONTRACT_ID,
    C.CONTRACT_NUMBER,
    DATE_PAY = C.DATE_CALC
   FROM
    ProCalcs C (NOLOCK)
   WHERE
     C.DATE_CALC = @dtCurEnd
   ORDER BY
    Cn.CONTRACT_NUMBER

OPEN curExistsContracts

FETCH NEXT FROM curExistsContracts
 INTO   @iContractId, @vcContractNumber, @dtDatePay

WHILE (@@FETCH_STATUS <> -1)
BEGIN
-- параметры
-- 1 - код контракта
-- 2 - расчетный период (конец)
-- 3 - период начала хранимых данных (конец)
-- 4 - последний расчетный период по базе (конец)
---------------
  Execute  pDivPartPay_15 @iContractId=@iContractId,--1
                          @dtCalcEnd=@dtDatePay,    --2
                          @dtDateBeg=@dtDateBeg,    --3
                          @dtDateEnd=@dtDateEnd     --4
  IF @@ERROR<>0 BREAK

  FETCH NEXT FROM curExistsContracts
   INTO   @iContractId, @vcContractNumber, @dtDatePay
END

CLOSE curExistsContracts
DEALLOCATE curExistsContracts
--==============================
/*Сей код, по словам Солдатова, фиксил неизвестный баг в процедуре pDivPartPay*/
/*
UPDATE
  #ProDivPaymentSum
 SET
  SUM_EE_B=SUM_EE-SUM_EE_A,
  SUM_NDS_B=SUM_NDS-SUM_NDS_A,
  SUM_EXC_B=SUM_EXC-SUM_EXC_A
 WHERE
  SUM_EE_A+SUM_EE_B<>SUM_EE
*/
--==============================
/******************************************************************************/
IF object_id('TempDB..#BTariff') Is Not Null
  DROP TABLE #BTariff

   SELECT Cs.CONTRACT_ID,
          BTARIFF = IsNull((PS.SUM_FACT + PS.SUM_NDS + PS.SUM_EXC) / PS.QNT_ALL,0)
     INTO #BTariff
     FROM ProCalcs     PS,
          ProContracts Cs
     WHERE PS.CONTRACT_ID=*Cs.CONTRACT_ID AND
           PS.DATE_CALC = (SELECT MAX(PPS.DATE_CALC)
                           FROM ProCalcs PPS
                           WHERE PPS.CONTRACT_ID = PS.CONTRACT_ID AND
                                 PPS.QNT_ALL <> 0 AND
                                (PPS.SUM_FACT + PPS.SUM_NDS + PPS.SUM_EXC) <> 0 AND
                                 PPS.DATE_CALC <= @dtPrev)
/******************************************************************************/
IF object_id('TempDB..#ETariff') Is Not Null
  DROP TABLE #ETariff

   SELECT  Cs.CONTRACT_ID,
           ETARIFF = IsNull((PS.SUM_FACT + PS.SUM_NDS + PS.SUM_EXC) / PS.QNT_ALL,0)
   INTO #ETariff
   FROM ProCalcs     PS,
        ProContracts Cs
   WHERE PS.CONTRACT_ID=*Cs.CONTRACT_ID AND
         PS.DATE_CALC =(SELECT MAX(PPS.DATE_CALC)
                        FROM ProCalcs PPS
                        WHERE PPS.CONTRACT_ID = PS.CONTRACT_ID AND
                              PPS.QNT_ALL <> 0 AND
                             (PPS.SUM_FACT + PPS.SUM_NDS + PPS.SUM_EXC) <> 0 AND
                              PPS.DATE_CALC <= @dtCurEnd)
/******************************************************************************/
/*Распределение платежей по процентам НДС %*/
/*Обозначения:
  EE  - электроэнергия
  EXC - акциз
  ACT - НДС
*/
SELECT
--  @dtCurEnd          =  convert(DateTime,'2004-01-31',21),
  @dfTaxACTBefo      = 0.20,
  @dfTaxACTAft       = 0.16,
  @dfTaxACTAftAft    = 0.15
SELECT
  CONTRACT_ID = C.CONTRACT_ID,
  SALDO       = C.SALDO,
  SUM_NACH    = C.SUM_FACT + C.SUM_NDS + C.SUM_EXC,
  QUANTITY    = C.QNT_ALL,
  SUM_EE      = C.SUM_FACT,
  SUM_ACT     = C.SUM_NDS,
  SUM_EXC     = C.SUM_EXC,
  SUM_ADD     = C.SUM_ADD,
/* Дополнительные начисления за период с НДС 20% */
 /* сумма за электроэнергию*/
 /* SUM_ADD_20 -> SUM_EE_20 */
  SUM_EE_20   = Convert(Decimal(12,2),IsNull(
                   (SELECT SUM(CD.SUM_CALC) 
                    FROM ProCalcDetails CD
                    WHERE CD.CALC_ID = C.CALC_ID AND
                          CD.DECODE_ID = 8 AND
                          (SELECT DATE_CALC
                           FROM ProCalcs
                           WHERE CALC_ID = CD.SOURCE_ID) < '2001-07-31'),0)),
/*Количество кВт*/
  QUANTITY_20 = Convert(Integer,IsNull(
               (SELECT SUM(CD.CALC_QUANTITY)
                FROM ProCalcDetails CD
                WHERE CD.CALC_ID  = C.CALC_ID AND
                      CD.DECODE_ID = 8 AND
                     (SELECT DATE_CALC
                      FROM ProCalcs
                      WHERE CALC_ID=CD.SOURCE_ID)<'2001-07-31'),0)),
/*сумма акциза*/
   SUM_EXC_20   = Convert(Decimal(12,2),IsNull(
                  (SELECT SUM(CD.CALC_QUANTITY*CC.EXCISE_TAX)
                   FROM ProCalcDetails CD,
                        ProCalcs       CC
                   WHERE CC.CALC_ID  = CD.SOURCE_ID AND
                      CD.CALC_ID  = C.CALC_ID AND
                      CD.DECODE_ID = 8 AND
                     (SELECT DATE_CALC
                      FROM ProCalcs
                      WHERE CALC_ID=CD.SOURCE_ID)<'2001-07-31'),0)),
/*сумма НДС*/
   SUM_ACT_20   = Convert(Decimal(12,2),IsNull(
                  (SELECT SUM((CD.SUM_CALC + CD.CALC_QUANTITY*CC.EXCISE_TAX*
                         (CASE WHEN CC.DATE_CALC > '2000-09-30'
                               THEN 1
                               ELSE 0 END)
                   )*CC.ADD_COST_TAX/100)
                 /*Если дата платежа старше 2000-09-30 тогда НДС с акциза не начислять*/
                   FROM ProCalcDetails CD,
                        ProCalcs       CC
                   WHERE CC.CALC_ID  = CD.SOURCE_ID AND
                      CD.CALC_ID  = C.CALC_ID AND
                      CD.DECODE_ID = 8 AND
                     (SELECT DATE_CALC
                      FROM ProCalcs
                      WHERE CALC_ID=CD.SOURCE_ID)<'2001-07-31'),0)),
/*общая сумма*/
   SUM_ADD_20    = Convert(Decimal(12,2),0.00),

/* Дополнительные начисления за период с НДС 16% */
/* SUM_ADD_16 -> SUM_EE_16 */
/*сумма за электроэнергию*/
  SUM_EE_16  = Convert(Decimal(12,2),IsNull(
                  (SELECT SUM(CD.SUM_CALC) 
                   FROM ProCalcDetails CD
                   WHERE CD.CALC_ID = C.CALC_ID AND
                         CD.DECODE_ID = 8 AND
                         (SELECT DATE_CALC
                          FROM ProCalcs
                          WHERE CALC_ID = CD.SOURCE_ID) BETWEEN '2001-07-31' AND '2003-12-31'),0)),
/*Количество кВт*/
  QUANTITY_16 =  Convert(Integer,IsNull(
                (SELECT SUM(CD.CALC_QUANTITY)
                 FROM ProCalcDetails CD
                 WHERE CD.CALC_ID  = C.CALC_ID AND
                       CD.DECODE_ID = 8 AND
                       (SELECT DATE_CALC
                        FROM ProCalcs
                        WHERE CALC_ID=CD.SOURCE_ID) BETWEEN '2001-07-31' AND '2003-12-31'),0)),

/*сумма акциза*/
   SUM_EXC_16   = Convert(Decimal(12,2),IsNull(
                  (SELECT SUM(CD.CALC_QUANTITY*CC.EXCISE_TAX)
                   FROM ProCalcDetails CD,
                        ProCalcs       CC
                   WHERE CC.CALC_ID  = CD.SOURCE_ID AND
                      CD.CALC_ID  = C.CALC_ID AND
                      CD.DECODE_ID = 8 AND
                     (SELECT DATE_CALC
                      FROM ProCalcs
                      WHERE CALC_ID=CD.SOURCE_ID) BETWEEN '2001-07-31' AND '2003-12-31'),0)),

/*сумма НДС*/
   SUM_ACT_16   = Convert(Decimal(12,2),IsNull(
                  (SELECT SUM((CD.SUM_CALC+CD.CALC_QUANTITY*CC.EXCISE_TAX)*CC.ADD_COST_TAX/100)
                   FROM ProCalcDetails CD,
                        ProCalcs       CC
                   WHERE CC.CALC_ID  = CD.SOURCE_ID AND
                      CD.CALC_ID  = C.CALC_ID AND
                      CD.DECODE_ID = 8 AND
                     (SELECT DATE_CALC
                      FROM ProCalcs
                      WHERE CALC_ID=CD.SOURCE_ID) BETWEEN '2001-07-31' AND '2003-12-31'),0)),

/*общая сумма*/
  SUM_ADD_16    = Convert(Decimal(12,2),0.00),
/*Неизвестное покаполе*/
  DELTA_ACT    = Convert(Decimal(12,2),0.00)
 INTO #ProCalcs
 FROM ProCalcs C (NoLock)
 WHERE C.DATE_CALC = @dtCurEnd
ALTER TABLE  #ProCalcs
 ADD PRIMARY KEY (CONTRACT_ID)


UPDATE #ProCalcs
SET
  SUM_NACH   = C.SUM_NACH -(C.SUM_EE_20 + C.SUM_ACT_20 + C.SUM_EXC_20 +
                            C.SUM_EE_16 + C.SUM_ACT_16 + C.SUM_EXC_16),
  /*общая сумма = сумма за электроэнергию + сумма НДС + сумма акциза*/
  SUM_ADD_20 = C.SUM_EE_20 + C.SUM_ACT_20 + C.SUM_EXC_20,
  SUM_ADD_16 = C.SUM_EE_16 + C.SUM_ACT_16 + C.SUM_EXC_16,
  QUANTITY   = C.QUANTITY - C.QUANTITY_20 - C.QUANTITY_16,
  SUM_EE     = C.SUM_EE    - C.SUM_EE_20  - C.SUM_EE_16,
  SUM_ACT    = C.SUM_ACT   - C.SUM_ACT_20 - C.SUM_ACT_16,
  SUM_EXC    = C.SUM_EXC   - C.SUM_EXC_20 - C.SUM_EXC_16
FROM #ProCalcs C (NoLock)
WHERE C.SUM_EE_20 <> 0 OR
      C.SUM_EE_16 <> 0


/* old code [dm]
UPDATE
  #ProCalcs
 SET
  SUM_NACH   = C.SUM_NACH -(C.SUM_ADD_PR + C.SUM_ACT_PR + C.SUM_EXC_PR),
  SUM_ADD_PR = C.SUM_ADD_PR + C.SUM_ACT_PR + C.SUM_EXC_PR,
  QUANTITY   = C.QUANTITY - C.QUANTITY_PR,
  SUM_EE     = C.SUM_EE - C.SUM_EE_PR,
  SUM_ACT    = C.SUM_ACT - C.SUM_ACT_PR,
  SUM_EXC    = C.SUM_EXC - C.SUM_EXC_PR
 FROM
  #ProCalcs C (NoLock)
 WHERE
  C.SUM_ADD_PR <> 0 */
/******************************************************************************/
DELETE
  ProDivSaldo
WHERE
  Date_Calc=@dtCalc

INSERT
  ProDivSaldo
(	[GROUP_ID]  ,
	[CONTRACT_NUMBER] ,
	[DATE_CALC] ,
	[CONTRACT_ID],
--сальдо на начало
-----------------------\
	[BSALDO20] ,       --|
	[BQUANTITY20] ,    --|
	[BSUM_EE20] ,      --|
	[BSUM_ACT20] ,     --|
	[BSUM_EXC20] ,     --|
	[BSALDO20DB] ,     --|
	[BQUANTITY20DB] ,  --|
	[BSUM_EE20DB]  ,   --|  20%
	[BSUM_ACT20DB] ,   --|
	[BSUM_EXC20DB]  ,  --|
	[BSALDO20CR] ,     --| 
	[BQUANTITY20CR] ,  --|
	[BSUM_EE20CR] ,    --|
	[BSUM_ACT20CR] ,   --|
	[BSUM_EXC20CR] ,   --|
----------------------/
	[BSALDO16] ,       --\
	[BQUANTITY16] ,    --|
	[BSUM_EE16] ,      --|
	[BSUM_ACT16] ,     --|
	[BSUM_EXC16] ,     --|
	[BSALDO16DB]  ,    --|
	[BQUANTITY16DB] ,  --|
	[BSUM_EE16DB] ,    --|  16%
	[BSUM_ACT16DB] ,   --|
	[BSUM_EXC16DB] ,   --|
	[BSALDO16CR] ,     --|
	[BQUANTITY16CR],   --|
	[BSUM_EE16CR] ,    --|
	[BSUM_ACT16CR] ,   --|
	[BSUM_EXC16CR] ,   --|
----------------------/
  [BSALDO15],       --\
  [BQUANTITY15],     --|
  [BSUM_EE15],       --|
  [BSUM_ACT15],      --|
  [BSUM_EXC15],      --|
  [BSALDO15DB],      --|
  [BQUANTITY15DB],   --|
  [BSUM_EE15DB],     --| 15%
  [BSUM_ACT15DB],    --|
  [BSUM_EXC15DB],    --|
  [BSALDO15CR],      --|
  [BQUANTITY15CR],   --|
  [BSUM_EE15CR],     --|
  [BSUM_ACT15CR],    --|
  [BSUM_EXC15CR],    --|
----------------------/
	[BSALDO] ,        --\
	[BQUANTITY] ,      --|
	[BSUM_EE] ,        --|
	[BSUM_ACT] ,       --|
	[BSUM_EXC] ,       --|
	[BSALDODB] ,       --|
	[BQUANTITYDB] ,    --|
	[BSUM_EEDB] ,      --|
	[BSUM_ACTDB] ,     --|
	[BSUM_EXCDB] ,     --| общее
	[BSALDOCR]  ,      --|
	[BQUANTITYCR] ,    --|
	[BSUM_EECR] ,      --|
	[BSUM_ACTCR] ,     --|
	[BSUM_EXCCR],      --|
	[BTARIFF] ,        --|
	[ETARIFF] ,        --|
----------------------/
--начисления
----------------------
	[NACH20]  ,       --\
 	[NQUANTITY20] ,   --|
	[NSUM_EE20] ,     --|
	[NSUM_NDS20] ,    --|
	[NSUM_EXC20] ,    --|
	[NACH20DB]  ,     --|
	[NQUANTITY20DB] , --|
	[NSUM_EE20DB]  ,  --|  20%
	[NSUM_NDS20DB] ,  --|
	[NSUM_EXC20DB] ,  --|
	[NACH20CR] ,      --|
	[NQUANTITY20CR] , --|
	[NSUM_EE20CR]  ,  --|
	[NSUM_NDS20CR] ,  --|
	[NSUM_EXC20CR] ,  --|
---------------------/
	[NACH16] ,        --\
	[NQUANTITY16]  ,  --|
	[NSUM_EE16]  ,    --|
	[NSUM_NDS16] ,    --|
	[NSUM_EXC16] ,    --|
	[NACH16DB] ,      --|
	[NQUANTITY16DB],  --|
	[NSUM_EE16DB]  ,  --|  16%
	[NSUM_NDS16DB] ,  --|
	[NSUM_EXC16DB] ,  --|
	[NACH16CR]  ,     --|
	[NQUANTITY16CR] , --|
	[NSUM_EE16CR] ,   --|
	[NSUM_NDS16CR] ,  --|
	[NSUM_EXC16CR],   --|
---------------------/
  [NACH15],        --\
  [NQUANTITY15],    --| 
  [NSUM_EE15],      --|
  [NSUM_NDS15],     --|
  [NSUM_EXC15],     --|
  [NACH15DB],       --|
  [NQUANTITY15DB],  --| 
  [NSUM_EE15DB],    --|  15%
  [NSUM_NDS15DB],   --|
  [NSUM_EXC15DB],   --|
  [NACH15CR],       --|
  [NQUANTITY15CR],  --| 
  [NSUM_EE15CR],    --|
  [NSUM_NDS15CR],   --|
  [NSUM_EXC15CR],   --/
----------------------\
	[NACH],           --|
	[NQUANTITY] ,     --|
	[NSUM_EE]  ,      --|
	[NSUM_NDS],       --|
	[NSUM_EXC] ,      --|
	[NACHDB]  ,       --|
	[NQUANTITYDB]  ,  --|
	[NSUM_EEDB] ,     --|  всего
	[NSUM_NDSDB] ,    --|
	[NSUM_EXCDB] ,    --|
	[NACHCR] ,        --|
	[NQUANTITYCR] ,   --|
	[NSUM_EECR] ,     --|
	[NSUM_NDSCR] ,    --|
	[NSUM_EXCCR],     --|
---------------------/
--платежи
----------------------\
	[PAY20] ,         --|
	[PQUANTITY20] ,   --|
	[PSUM_EE20] ,     --|
	[PSUM_NDS20] ,    --|
	[PSUM_EXC20],     --|
	[PAY20DB] ,       --|
	[PQUANTITY20DB] , --|
	[PSUM_EE20DB] ,   --|  20%
	[PSUM_NDS20DB] ,  --|
	[PSUM_EXC20DB] ,  --|
	[PAY20CR] ,       --|
	[PQUANTITY20CR] , --|
	[PSUM_EE20CR] ,   --|
	[PSUM_NDS20CR] ,  --|
	[PSUM_EXC20CR] ,  --|
---------------------/
	[PAY16] ,         --\
	[PQUANTITY16]  ,  --|
	[PSUM_EE16] ,     --|
	[PSUM_NDS16] ,    --|
	[PSUM_EXC16] ,    --|
	[PAY16DB]  ,      --|
	[PQUANTITY16DB],  --|
	[PSUM_EE16DB] ,   --|  16%
	[PSUM_NDS16DB],   --|
	[PSUM_EXC16DB],   --|
	[PAY16CR] ,       --|
	[PQUANTITY16CR] , --|
	[PSUM_EE16CR] ,   --|
	[PSUM_NDS16CR] ,  --|
	[PSUM_EXC16CR] ,  --|
---------------------/
  [PAY15],         --\
  [PQUANTITY15],    --| 
  [PSUM_EE15],      --|
  [PSUM_NDS15],     --|
  [PSUM_EXC15],     --|
  [PAY15DB],        --|
  [PQUANTITY15DB],  --| 
  [PSUM_EE15DB],    --|  15%
  [PSUM_NDS15DB],   --|
  [PSUM_EXC15DB],   --|
  [PAY15CR],        --|
  [PQUANTITY15CR],  --| 
  [PSUM_EE15CR],    --|
  [PSUM_NDS15CR],   --|
  [PSUM_EXC15CR],   --|
---------------------/
	[PAY] ,          --\
	[PQUANTITY],      --|
	[PSUM_EE],        --|
	[PSUM_NDS] ,      --|
	[PSUM_EXC] ,      --|
	[PAYDB],          --|
	[PQUANTITYDB] ,   --|
	[PSUM_EEDB],      --|
	[PSUM_NDSDB] ,    --|  всего
	[PSUM_EXCDB],     --|
	[PAYCR]  ,        --|
	[PQUANTITYCR] ,   --|
	[PSUM_EECR]  ,    --|
	[PSUM_NDSCR],     --|
	[PSUM_EXCCR] ,    --|
----------------   ---/
--сальдо на конец
----------------------\
	[ESALDO20] ,      --|
	[EQUANTITY20] ,   --|
	[ESUM_EE20] ,     --|
	[ESUM_ACT20] ,    --|
	[ESUM_EXC20] ,    --|
	[ESALDO20DB] ,    --|
	[EQUANTITY20DB],  --|
	[ESUM_EE20DB]  ,  --|  20%
	[ESUM_ACT20DB] ,  --|
	[ESUM_EXC20DB] ,  --|
	[ESALDO20CR]  ,   --|
	[EQUANTITY20CR],  --|
	[ESUM_EE20CR],    --|
	[ESUM_ACT20CR],   --|
	[ESUM_EXC20CR],   --|
---------------------/
	[ESALDO16] ,      --\
	[EQUANTITY16] ,   --|
	[ESUM_EE16] ,     --|
	[ESUM_ACT16],     --|
	[ESUM_EXC16] ,    --|
	[ESALDO16DB] ,    --|
	[EQUANTITY16DB] , --|
	[ESUM_EE16DB]  ,  --|  16%
	[ESUM_ACT16DB],   --|
	[ESUM_EXC16DB] ,  --|
	[ESALDO16CR]  ,   --|
	[EQUANTITY16CR] , --|
	[ESUM_EE16CR] ,   --|
	[ESUM_ACT16CR] ,  --|
	[ESUM_EXC16CR] ,  --|
---------------------/
  [ESALDO15],      --\
  [EQUANTITY15],    --|
  [ESUM_EE15],      --|
  [ESUM_ACT15],     --|
  [ESUM_EXC15],     --|
  [ESALDO15DB],     --|
  [EQUANTITY15DB],  --|
  [ESUM_EE15DB],    --|
  [ESUM_ACT15DB],   --|  15%
  [ESUM_EXC15DB],   --|
  [ESALDO15CR],     --|
  [EQUANTITY15CR],  --|
  [ESUM_EE15CR],    --|
  [ESUM_ACT15CR],   --|
  [ESUM_EXC15CR],   --|
---------------------/
	[ESALDO],        --\
	[EQUANTITY] ,     --|
	[ESUM_EE] ,       --|
	[ESUM_ACT],       --|
	[ESUM_EXC] ,      --|
	[ESALDODB] ,      --|
	[EQUANTITYDB] ,   --|
	[ESUM_EEDB] ,     --|  всего
	[ESUM_ACTDB] ,    --|
	[ESUM_EXCDB] ,    --|
	[ESALDOCR] ,      --|
	[EQUANTITYCR] ,   --|
	[ESUM_EECR] ,     --|
	[ESUM_ACTCR],     --|
	[ESUM_EXCCR]      --|
---------------    --/
)
 SELECT
  Cs.GROUP_ID,
  Cs.CONTRACT_NUMBER,
  DATE_CALC = @dtCalc,
  Cs.CONTRACT_ID,
------ сальдо на начало 20%
 /*Закоментированный здесь и ниже код, относящийся
   к расчету начального сальдо отрабатывал ситуацию, когда данных за прошлый 
   месяц не существовало (@dtCalc = @dtFirst), т.е. когда таблица заполнялась впервые */

  BSALDO20 = IsNull(DS.ESALDO20,0)/* + CASE WHEN @dtCalc = @dtFirst
                                          THEN CASE WHEN IsNull(C.SALDO,0) > 0
                                                    THEN IsNull(C.SALDO,0)
                                                    ELSE 0
                                                    END
                                          ELSE 0
                                          END*/,
  BQUANTITY20 = IsNull(DS.EQUANTITY20,0)/* + CASE WHEN @dtCalc = @dtFirst
                                                THEN CASE WHEN IsNull(C.SALDO,0) > 0
                                                          THEN IsNull(PP.QUANTITY,0)
                                                          ELSE 0
                                                          END
                                                ELSE 0
                                                END*/,
  BSUM_EE20 = IsNull(DS.ESUM_EE20,0)/* + CASE WHEN @dtCalc = @dtFirst
                                            THEN CASE WHEN IsNull(C.SALDO,0) > 0
                                                      THEN IsNull(PP.SUM_EE,0)
                                                      ELSE 0
                                                      END
                                            ELSE 0
                                            END*/,
  BSUM_ACT20 = IsNull(DS.ESUM_ACT20,0)/* + CASE WHEN @dtCalc = @dtFirst
                                              THEN CASE WHEN IsNull(C.SALDO,0) > 0
                                                        THEN IsNull(PP.SUM_ACT,0)
                                                        ELSE 0
                                                        END
                                              ELSE 0
                                              END*/,
  BSUM_EXC20 = IsNull(DS.ESUM_EXC20,0)/* + CASE WHEN @dtCalc = @dtFirst
                                              THEN CASE WHEN IsNull(C.SALDO,0) > 0
                                                        THEN IsNull(PP.SUM_EXC,0)
                                                        ELSE 0
                                                        END
                                              ELSE 0
                                              END*/,
--
  BSALDO20DB=0,
  BQUANTITY20DB=0,
  BSUM_EE20DB=0,
  BSUM_ACT20DB=0,
  BSUM_EXC20DB=0,
--
  BSALDO20CR=0,
  BQUANTITY20CR=0,
  BSUM_EE20CR=0,
  BSUM_ACT20CR=0,
  BSUM_EXC20CR=0,
------ сальдо на начало 16%
/*При переходе на НДС 15%, сальдо на начало 15% заполняется нулями, кроме тех случаев, 
когда сальдо на конец 16% кредитовое (переплата), т.е. меньше нуля, в этом случае сальдо на
конец 16% ложится в сальдо на начало 15%*/
  BSALDO16 = CASE WHEN @dtCalc = '2004-01-31'
                  THEN CASE WHEN IsNull(DS.ESALDO16,0) > 0
                            THEN IsNull(DS.ESALDO16,0)
                            ELSE 0 END
                  ELSE IsNull(DS.ESALDO16,0) END, 
 /*BSALDO16 =IsNull(DS.ESALDO16,0) + CASE WHEN @dtCalc = @dtFirst
                                          THEN CASE WHEN IsNull(C.SALDO,0) <= 0
                                                    THEN IsNull(C.SALDO,0)
                                                    ELSE 0
                                                    END
                                          ELSE 0
                                          END,*/
 
   BQUANTITY16 = CASE WHEN @dtCalc = '2004-01-31'
                      THEN CASE WHEN IsNull(DS.ESALDO16,0) > 0
                                THEN IsNull(DS.EQUANTITY16,0)
                                ELSE 0 END
                      ELSE IsNull(DS.EQUANTITY16,0) END, 
 /* BQUANTITY16 = IsNull(DS.EQUANTITY16,0) + CASE WHEN @dtCalc = @dtFirst
                                                THEN CASE WHEN IsNull(C.SALDO,0) <= 0
                                                          THEN IsNull(PP.QUANTITY,0)
                                                          ELSE 0
                                                          END
                                                ELSE 0
                                                END*/

  BSUM_EE16 = CASE WHEN @dtCalc = '2004-01-31'
                   THEN CASE WHEN IsNull(DS.ESALDO16,0) > 0
                             THEN IsNull(DS.ESUM_EE16,0)
                             ELSE 0 END
                   ELSE IsNull(DS.ESUM_EE16,0) END, 
 /* BSUM_EE16 = IsNull(DS.ESUM_EE16,0) + CASE WHEN @dtCalc = @dtFirst
                                            THEN CASE WHEN IsNull(C.SALDO,0) <= 0 
                                                      THEN IsNull(PP.SUM_EE,0)
                                                      ELSE 0
                                                      END
                                            ELSE 0
                                            END*/

  BSUM_ACT16 = CASE WHEN @dtCalc = '2004-01-31'
                    THEN CASE WHEN IsNull(DS.ESALDO16,0) > 0
                              THEN IsNull(DS.ESUM_ACT16,0)
                              ELSE 0 END
                    ELSE IsNull(DS.ESUM_ACT16,0) END, 
/* BSUM_ACT16 = IsNull(DS.ESUM_ACT16,0) + CASE WHEN @dtCalc = @dtFirst
                                              THEN CASE WHEN IsNull(C.SALDO,0) <= 0
                                                        THEN IsNull(PP.SUM_ACT,0)
                                                        ELSE 0
                                                        END
                                              ELSE 0
                                              END*/

  BSUM_EXC16 = CASE WHEN @dtCalc = '2004-01-31'
                    THEN CASE WHEN IsNull(DS.ESALDO16,0) > 0
                              THEN IsNull(DS.ESUM_EXC16,0)
                              ELSE 0 END
                    ELSE IsNull(DS.ESUM_EXC16,0) END, 
/*  BSUM_EXC16 = IsNull(DS.ESUM_EXC16,0) + CASE WHEN @dtCalc = @dtFirst
                                              THEN CASE WHEN IsNull(C.SALDO,0) <= 0
                                                        THEN IsNull(PP.SUM_EXC,0)
                                                        ELSE 0
                                                        END
                                              ELSE 0
                                              END*/
--
  BSALDO16DB=0,
  BQUANTITY16DB=0,
  BSUM_EE16DB=0,
  BSUM_ACT16DB=0,
  BSUM_EXC16DB=0,
--
  BSALDO16CR=0,
  BQUANTITY16CR=0,
  BSUM_EE16CR=0,
  BSUM_ACT16CR=0,
  BSUM_EXC16CR=0,
------- сальдо на начало 15%

  BSALDO15 = CASE WHEN @dtCalc = '2004-01-31'
                  THEN CASE WHEN IsNull(DS.ESALDO16,0) <= 0 --т.е. сальдо кредитовое
                            THEN IsNull(DS.ESALDO16,0)
                            ELSE 0 END
                    ELSE IsNull(DS.ESALDO15,0) END,

  BQUANTITY15 = CASE WHEN @dtCalc = '2004-01-31'
                     THEN CASE WHEN IsNull(DS.ESALDO16,0) <= 0 
                               THEN IsNull(DS.EQUANTITY16,0)
                               ELSE 0 END
                     ELSE IsNull(DS.EQUANTITY15,0) END,

  BSUM_EE15 = CASE WHEN @dtCalc = '2004-01-31'
                     THEN CASE WHEN IsNull(DS.ESALDO16,0) <= 0 
                               THEN IsNull(DS.ESUM_EE16,0)
                               ELSE 0 END
                     ELSE IsNull(DS.ESUM_EE15,0) END,

  BSUM_ACT15 = CASE WHEN @dtCalc = '2004-01-31'
                    THEN CASE WHEN IsNull(DS.ESALDO16,0) <= 0 
                              THEN IsNull(DS.ESUM_ACT16,0)
                              ELSE 0 END
                    ELSE  IsNull(DS.ESUM_ACT15,0) END,


  BSUM_EXC15 = CASE WHEN @dtCalc = '2004-01-31'
                    THEN CASE WHEN IsNull(DS.ESALDO16,0) <= 0 
                              THEN IsNull(DS.ESUM_EXC16,0)
                              ELSE 0 END
                    ELSE  IsNull(DS.ESUM_EXC15,0) END,
--
  [BSALDO15DB]    = 0,     
  [BQUANTITY15DB] = 0,  
  [BSUM_EE15DB]   = 0,    
  [BSUM_ACT15DB]  = 0,   
  [BSUM_EXC15DB]  = 0,   
--
  [BSALDO15CR]    = 0,     
  [BQUANTITY15CR] = 0,  
  [BSUM_EE15CR]   = 0,    
  [BSUM_ACT15CR]  = 0,   
  [BSUM_EXC15CR]  = 0,   

------ сальдо на начало всего
  BSALDO = IsNull(DS.ESALDO,0),/* + CASE WHEN @dtCalc = @dtFirst
                                      THEN IsNull(C.SALDO,0)
                                      ELSE 0 END,*/
  BQUANTITY = IsNull(DS.EQUANTITY,0),/* + CASE WHEN @dtCalc = @dtFirst
                                            THEN CASE WHEN IsNull(C.SALDO,0) <= 0
                                                      THEN 0 -- IsNull(PP.QUANTITY,0)
                                                      ELSE IsNull(PP.QUANTITY,0) END
                                             ELSE 0 END,*/
  BSUM_EE = IsNull(DS.ESUM_EE,0),/* + CASE WHEN @dtCalc = @dtFirst
                                        THEN CASE  WHEN IsNull(C.SALDO,0) <= 0
                                                   THEN IsNull(PP.SUM_EE,0)
                                                   ELSE IsNull(PP.SUM_EE,0) END
                                        ELSE 0 END,*/
  BSUM_ACT = IsNull(DS.ESUM_ACT,0),/* + CASE WHEN @dtCalc = @dtFirst 
                                          THEN CASE WHEN IsNull(C.SALDO,0) <= 0
                                                    THEN 0 -- IsNull(PP.SUM_ACT,0)
                                                    ELSE IsNull(PP.SUM_ACT,0) END
                                          ELSE 0 END,*/
  BSUM_EXC = IsNull(DS.ESUM_EXC,0),/* + CASE WHEN @dtCalc = @dtFirst
                                          THEN CASE WHEN IsNull(C.SALDO,0) <= 0
                                                    THEN 0 -- IsNull(PP.SUM_EXC,0)
                                                    ELSE IsNull(PP.SUM_EXC,0) END
                                          ELSE 0 END,*/
--
  BSALDODB    = 0,
  BQUANTITYDB = 0,
  BSUM_EEDB   = 0,
  BSUM_ACTDB  = 0,
  BSUM_EXCDB  = 0,
--
  BSALDOCR    = 0,
  BQUANTITYCR = 0,
  BSUM_EECR   = 0,
  BSUM_ACTCR  = 0,
  BSUM_EXCCR  = 0,
  -----
  BTARIFF = BT.BTARIFF,
  ETARIFF = ET.ETARIFF,

------ начисление 20%
  NACH20       = IsNull(C.SUM_ADD_20,0) + IsNull(C.DELTA_ACT,0),
  NQUANTITY20  = IsNull(C.QUANTITY_20,0),
  NSUM_EE20    = IsNull(C.SUM_EE_20,0),  
  NSUM_NDS20   = IsNull(C.SUM_ACT_20,0) + IsNull(C.DELTA_ACT,0),
  NSUM_EXC20   = IsNull(C.SUM_EXC_20,0),
----------дебитовое
  NACH20DB     = CASE WHEN IsNull(C.SUM_NACH,0) + IsNull(C.SUM_ADD_20,0) + IsNull(C.SUM_ADD_16,0) > 0
                      THEN IsNull(C.SUM_ADD_20,0) + IsNull(C.DELTA_ACT,0)
                      ELSE 0 END,
  NQUANTITY20DB = CASE WHEN IsNull(C.SUM_NACH,0) + IsNull(C.SUM_ADD_20,0) + IsNull(C.SUM_ADD_16,0) > 0
                       THEN IsNull(C.QUANTITY_20,0)
                       ELSE 0 END,
  NSUM_EE20DB = CASE WHEN IsNull(C.SUM_NACH,0) + IsNull(C.SUM_ADD_20,0) + IsNull(C.SUM_ADD_16,0) > 0
                     THEN IsNull(C.SUM_EE_20,0)
                     ELSE 0 END,
  NSUM_NDS20DB = CASE WHEN IsNull(C.SUM_NACH,0) + IsNull(C.SUM_ADD_20,0) + IsNull(C.SUM_ADD_16,0) > 0
                      THEN IsNull(C.SUM_ACT_20,0) + IsNull(C.DELTA_ACT,0)
                      ELSE 0 END,
  NSUM_EXC20DB = CASE WHEN IsNull(C.SUM_NACH,0) + IsNull(C.SUM_ADD_20,0) + IsNull(C.SUM_ADD_16,0) > 0
                      THEN IsNull(C.SUM_EXC_20,0)
                      ELSE 0 END,
--------кредитовое
  NACH20CR = CASE WHEN IsNull(C.SUM_NACH,0) + IsNull(C.SUM_ADD_20,0) + IsNull(C.SUM_ADD_16,0)  <= 0
                  THEN IsNull(C.SUM_ADD_20,0) + IsNull(C.DELTA_ACT,0)
                  ELSE 0 END,
  NQUANTITY20CR = CASE WHEN IsNull(C.SUM_NACH,0) + IsNull(C.SUM_ADD_20,0) + IsNull(C.SUM_ADD_16,0) <= 0
                       THEN IsNull(C.QUANTITY_20,0)
                       ELSE 0 END,
  NSUM_EE20CR = CASE WHEN IsNull(C.SUM_NACH,0) + IsNull(C.SUM_ADD_20,0) + IsNull(C.SUM_ADD_16,0) <= 0
                     THEN IsNull(C.SUM_EE_20,0)
                     ELSE 0 END,
  NSUM_NDS20CR = CASE WHEN IsNull(C.SUM_NACH,0) + IsNull(C.SUM_ADD_20,0) + IsNull(C.SUM_ADD_16,0) <= 0 
                      THEN IsNull(C.SUM_ACT_20,0) + IsNull(C.DELTA_ACT,0)
                      ELSE 0 END,
  NSUM_EXC20CR = CASE WHEN IsNull(C.SUM_NACH,0) + IsNull(C.SUM_ADD_20,0) + IsNull(C.SUM_ADD_16,0) <= 0
                      THEN IsNull(C.SUM_EXC_20,0)
                      ELSE 0 END,

------ Начисление 16%
  NACH16      = IsNull(C.SUM_ADD_16,0),
  NQUANTITY16 = IsNull(C.QUANTITY_16,0),
  NSUM_EE16   = IsNull(C.SUM_EE_16,0),
  NSUM_NDS16  = IsNull(C.SUM_ACT_16,0),
  NSUM_EXC16  = IsNull(C.SUM_EXC_16,0),
----- дебитовое
  NACH16DB    = CASE WHEN IsNull(C.SUM_NACH,0) + IsNull(C.SUM_ADD_20,0) + IsNull(C.SUM_ADD_16,0) > 0
                     THEN IsNull(C.SUM_ADD_16,0)
                     ELSE 0 END,
  NQUANTITY16DB = CASE WHEN IsNull(C.SUM_NACH,0) + IsNull(C.SUM_ADD_20,0) + IsNull(C.SUM_ADD_16,0) > 0
                       THEN IsNull(C.QUANTITY_16,0)
                       ELSE 0 END,
  NSUM_EE16DB = CASE WHEN IsNull(C.SUM_NACH,0) + IsNull(C.SUM_ADD_20,0) + IsNull(C.SUM_ADD_16,0) > 0
                     THEN IsNull(C.SUM_EE_16,0)
                     ELSE 0 END,
  NSUM_NDS16DB = CASE WHEN IsNull(C.SUM_NACH,0) + IsNull(C.SUM_ADD_20,0) + IsNull(C.SUM_ADD_16,0) > 0
                      THEN IsNull(C.SUM_ACT_16,0)
                      ELSE 0 END,
  NSUM_EXC16DB = CASE WHEN IsNull(C.SUM_NACH,0) + IsNull(C.SUM_ADD_20,0) + IsNull(C.SUM_ADD_16,0) > 0
                      THEN IsNull(C.SUM_EXC_16,0)
                      ELSE 0 END,
----- кредитовое
  NACH16CR = CASE WHEN IsNull(C.SUM_NACH,0) + IsNull(C.SUM_ADD_20,0) + IsNull(C.SUM_ADD_16,0) <= 0
                  THEN IsNull(C.SUM_ADD_16,0)
                  ELSE 0 END,
  NQUANTITY16CR = CASE WHEN IsNull(C.SUM_NACH,0) + IsNull(C.SUM_ADD_20,0) + IsNull(C.SUM_ADD_16,0) <= 0
                       THEN IsNull(C.QUANTITY_16,0)
                       ELSE 0 END,
  NSUM_EE16CR = CASE WHEN IsNull(C.SUM_NACH,0) + IsNull(C.SUM_ADD_20,0) + IsNull(C.SUM_ADD_16,0) <= 0
                     THEN IsNull(C.SUM_EE_16,0)
                     ELSE 0 END,
  NSUM_NDS16CR = CASE WHEN IsNull(C.SUM_NACH,0) + IsNull(C.SUM_ADD_20,0) + IsNull(C.SUM_ADD_16,0) <= 0
                      THEN IsNull(C.SUM_ACT_16,0)
                      ELSE 0 END,
  NSUM_EXC16CR = CASE WHEN IsNull(C.SUM_NACH,0) + IsNull(C.SUM_ADD_20,0) + IsNull(C.SUM_ADD_16,0) <= 0
                      THEN IsNull(C.SUM_EXC_16,0)
                      ELSE 0 END,

-----Начисление 15%
  NACH15      = IsNull(C.SUM_NACH,0),        
  NQUANTITY15 = IsNull(C.QUANTITY,0),
  NSUM_EE15   = IsNull(C.SUM_EE,0),
  NSUM_NDS15  = IsNull(C.SUM_ACT,0),
  NSUM_EXC15  = IsNull(C.SUM_EXC,0),    
----- дебитовое
  NACH15DB    = CASE WHEN IsNull(C.SUM_NACH,0) + IsNull(C.SUM_ADD_20,0) + IsNull(C.SUM_ADD_16,0) > 0
                     THEN IsNull(C.SUM_NACH,0)
                     ELSE 0 END,
  NQUANTITY15DB = CASE WHEN IsNull(C.SUM_NACH,0) + IsNull(C.SUM_ADD_20,0) + IsNull(C.SUM_ADD_16,0) > 0
                       THEN IsNull(C.QUANTITY,0)
                       ELSE 0 END,
  NSUM_EE15DB = CASE WHEN IsNull(C.SUM_NACH,0) + IsNull(C.SUM_ADD_20,0) + IsNull(C.SUM_ADD_16,0) > 0
                     THEN IsNull(C.SUM_EE,0)
                     ELSE 0 END,
  NSUM_NDS15DB = CASE WHEN IsNull(C.SUM_NACH,0) + IsNull(C.SUM_ADD_20,0) + IsNull(C.SUM_ADD_16,0) > 0
                      THEN IsNull(C.SUM_ACT,0)
                      ELSE 0 END,
  NSUM_EXC15DB = CASE WHEN IsNull(C.SUM_NACH,0) + IsNull(C.SUM_ADD_20,0) + IsNull(C.SUM_ADD_16,0) > 0
                      THEN IsNull(C.SUM_EXC,0)
                      ELSE 0 END,
----- кредитовое
  NACH15CR = CASE WHEN IsNull(C.SUM_NACH,0) + IsNull(C.SUM_ADD_20,0) + IsNull(C.SUM_ADD_16,0) <= 0
                  THEN IsNull(C.SUM_NACH,0)
                  ELSE 0 END,
  NQUANTITY15CR = CASE WHEN IsNull(C.SUM_NACH,0) + IsNull(C.SUM_ADD_20,0) + IsNull(C.SUM_ADD_16,0) <= 0
                       THEN IsNull(C.QUANTITY,0)
                       ELSE 0 END,
  NSUM_EE15CR = CASE WHEN IsNull(C.SUM_NACH,0) + IsNull(C.SUM_ADD_20,0) + IsNull(C.SUM_ADD_16,0) <= 0
                     THEN IsNull(C.SUM_EE,0)
                     ELSE 0 END,
  NSUM_NDS15CR = CASE WHEN IsNull(C.SUM_NACH,0) + IsNull(C.SUM_ADD_20,0) + IsNull(C.SUM_ADD_16,0) <= 0
                      THEN IsNull(C.SUM_ACT,0)
                      ELSE 0 END,
  NSUM_EXC15CR = CASE WHEN IsNull(C.SUM_NACH,0) + IsNull(C.SUM_ADD_20,0) + IsNull(C.SUM_ADD_16,0) <= 0
                      THEN IsNull(C.SUM_EXC,0)
                      ELSE 0 END,

------ Начисление всего                                       Г~~~~~~~~ добавленио при переходе на 15% НДС
  NACH        = IsNull(C.SUM_NACH,0) + IsNull(C.SUM_ADD_20,0)  + IsNull(C.SUM_ADD_16,0),
  NQUANTITY   = IsNull(C.QUANTITY,0) + IsNull(C.QUANTITY_20,0) + IsNull(C.QUANTITY_16,0),
  NSUM_EE     = IsNull(C.SUM_EE,0)   + IsNull(C.SUM_EE_20,0)   + IsNull(C.SUM_EE_16,0),
  NSUM_NDS    = IsNull(C.SUM_ACT,0)  + IsNull(C.SUM_ACT_20,0)  + IsNull(C.SUM_ACT_16,0),
  NSUM_EXC    = IsNull(C.SUM_EXC,0)  + IsNull(C.SUM_EXC_20,0)  + IsNull(C.SUM_EXC_16,0),
--
  NACHDB = CASE WHEN IsNull(C.SUM_NACH,0) + IsNull(C.SUM_ADD_20,0)  + IsNull(C.SUM_ADD_16,0) > 0
                THEN IsNull(C.SUM_NACH,0) + IsNull(C.SUM_ADD_20,0)  + IsNull(C.SUM_ADD_16,0)
                ELSE 0 END,
  NQUANTITYDB = CASE WHEN IsNull(C.SUM_NACH,0) + IsNull(C.SUM_ADD_20,0)  + IsNull(C.SUM_ADD_16,0) > 0
                     THEN IsNull(C.QUANTITY,0) + IsNull(C.QUANTITY_20,0) + IsNull(C.QUANTITY_16,0)
                     ELSE 0 END,
  NSUM_EEDB = CASE WHEN IsNull(C.SUM_NACH,0) + IsNull(C.SUM_ADD_20,0)  + IsNull(C.SUM_ADD_16,0) > 0
                   THEN IsNull(C.SUM_EE,0)   + IsNull(C.SUM_EE_20,0)   + IsNull(C.SUM_EE_16,0)
                   ELSE 0 END,
  NSUM_NDSDB = CASE WHEN IsNull(C.SUM_NACH,0) + IsNull(C.SUM_ADD_20,0)  + IsNull(C.SUM_ADD_16,0) > 0
                    THEN IsNull(C.SUM_ACT,0)  + IsNull(C.SUM_ACT_20,0)  + IsNull(C.SUM_ACT_16,0)
                    ELSE 0 END,
  NSUM_EXCDB = CASE WHEN IsNull(C.SUM_NACH,0) + IsNull(C.SUM_ADD_20,0)  + IsNull(C.SUM_ADD_16,0) > 0
                    THEN IsNull(C.SUM_EXC,0)  + IsNull(C.SUM_EXC_20,0)  + IsNull(C.SUM_EXC_16,0)
                    ELSE 0 END,
  NACHCR = CASE WHEN IsNull(C.SUM_NACH,0) + IsNull(C.SUM_ADD_20,0)  + IsNull(C.SUM_ADD_16,0) <= 0
                THEN IsNull(C.SUM_NACH,0) + IsNull(C.SUM_ADD_20,0)  + IsNull(C.SUM_ADD_16,0)
                ELSE 0  END,
  NQUANTITYCR = CASE WHEN IsNull(C.SUM_NACH,0) + IsNull(C.SUM_ADD_20,0)  + IsNull(C.SUM_ADD_16,0) <= 0
                     THEN IsNull(C.QUANTITY,0) + IsNull(C.QUANTITY_20,0) + IsNull(C.QUANTITY_16,0)
                     ELSE 0 END,
  NSUM_EECR = CASE WHEN IsNull(C.SUM_NACH,0) + IsNull(C.SUM_ADD_20,0)  + IsNull(C.SUM_ADD_16,0) <= 0
                   THEN IsNull(C.SUM_EE,0)   + IsNull(C.SUM_EE_20,0)   + IsNull(C.SUM_EE_16,0)
                   ELSE 0 END,
  NSUM_NDSCR = CASE WHEN IsNull(C.SUM_NACH,0) + IsNull(C.SUM_ADD_20,0)  + IsNull(C.SUM_ADD_16,0) <= 0
                    THEN IsNull(C.SUM_ACT,0) + IsNull(C.SUM_ACT_20,0) + IsNull(C.SUM_ACT_16,0)
                    ELSE 0  END,
  NSUM_EXCCR = CASE WHEN IsNull(C.SUM_NACH,0) + IsNull(C.SUM_ADD_20,0)  + IsNull(C.SUM_ADD_16,0) <= 0
                    THEN IsNull(C.SUM_EXC,0) + IsNull(C.SUM_EXC_20,0)   + IsNull(C.SUM_EXC_16,0)
                    ELSE 0
                    END,


------ Оплата 20%
  PAY20       = IsNull(P.SUM_EE_B,0) + IsNull(P.SUM_NDS_B,0) + IsNull(P.SUM_EXC_B,0),
  PQUANTITY20 = IsNull(P.QUANTITY_B,0),
  PSUM_EE20   = IsNull(P.SUM_EE_B,0),
  PSUM_NDS20  = IsNull(P.SUM_NDS_B,0),
  PSUM_EXC20  = IsNull(P.SUM_EXC_B,0),
---- дебет
  PAY20DB = CASE WHEN IsNull(P.SUM_EE_B,0) + IsNull(P.SUM_NDS_B,0) + IsNull(P.SUM_EXC_B,0) > 0
                 THEN IsNull(P.SUM_EE_B,0) + IsNull(P.SUM_NDS_B,0) + IsNull(P.SUM_EXC_B,0)
                 ELSE 0
                 END,
  PQUANTITY20DB = CASE WHEN IsNull(P.SUM_EE_B,0) + IsNull(P.SUM_NDS_B,0) + IsNull(P.SUM_EXC_B,0) > 0
                       THEN IsNull(P.QUANTITY_B,0)
                       ELSE 0
                       END,
  PSUM_EE20DB = CASE WHEN IsNull(P.SUM_EE_B,0) + IsNull(P.SUM_NDS_B,0) + IsNull(P.SUM_EXC_B,0) > 0
                     THEN IsNull(P.SUM_EE_B,0)
                     ELSE 0
                     END,
  PSUM_NDS20DB = CASE WHEN IsNull(P.SUM_EE_B,0) + IsNull(P.SUM_NDS_B,0) + IsNull(P.SUM_EXC_B,0) > 0
                      THEN IsNull(P.SUM_NDS_B,0)
                      ELSE 0
                      END,
  PSUM_EXC20DB = CASE WHEN IsNull(P.SUM_EE_B,0) + IsNull(P.SUM_NDS_B,0) + IsNull(P.SUM_EXC_B,0) > 0
                      THEN IsNull(P.SUM_EXC_B,0)
                      ELSE 0
                      END,
----кредит
  PAY20CR = CASE WHEN IsNull(P.SUM_EE_B,0) + IsNull(P.SUM_NDS_B,0) + IsNull(P.SUM_EXC_B,0) <= 0
                 THEN IsNull(P.SUM_EE_B,0) + IsNull(P.SUM_NDS_B,0) + IsNull(P.SUM_EXC_B,0)
                 ELSE 0
                 END,
  PQUANTITY20CR = CASE WHEN IsNull(P.SUM_EE_B,0) + IsNull(P.SUM_NDS_B,0) + IsNull(P.SUM_EXC_B,0) <= 0
                       THEN IsNull(P.QUANTITY_B,0)
                       ELSE 0
                       END,
  PSUM_EE20CR = CASE WHEN IsNull(P.SUM_EE_B,0) + IsNull(P.SUM_NDS_B,0) + IsNull(P.SUM_EXC_B,0) <= 0
                     THEN IsNull(P.SUM_EE_B,0)
                     ELSE 0
                     END,
  PSUM_NDS20CR = CASE WHEN IsNull(P.SUM_EE_B,0) + IsNull(P.SUM_NDS_B,0) + IsNull(P.SUM_EXC_B,0) <= 0
                      THEN IsNull(P.SUM_NDS_B,0)
                      ELSE 0
                      END,
  PSUM_EXC20CR = CASE WHEN IsNull(P.SUM_EE_B,0) + IsNull(P.SUM_NDS_B,0) + IsNull(P.SUM_EXC_B,0) <= 0
                      THEN IsNull(P.SUM_EXC_B,0)
                      ELSE 0
                      END,
------ оплата 16%
  PAY16       = IsNull(P.SUM_EE_A,0) + IsNull(P.SUM_NDS_A,0) + IsNull(P.SUM_EXC_A,0),
  PQUANTITY16 = IsNull(P.QUANTITY_A,0),
  PSUM_EE16   = IsNull(P.SUM_EE_A,0),
  PSUM_NDS16  = IsNull(P.SUM_NDS_A,0),
  PSUM_EXC16  = IsNull(P.SUM_EXC_A,0),
  PAY16DB     = CASE WHEN IsNull(P.SUM_EE_A,0) + IsNull(P.SUM_NDS_A,0) + IsNull(P.SUM_EXC_A,0) > 0
                     THEN IsNull(P.SUM_EE_A,0) + IsNull(P.SUM_NDS_A,0) + IsNull(P.SUM_EXC_A,0)
                     ELSE 0
                     END,
  PQUANTITY16DB = CASE WHEN IsNull(P.SUM_EE_A,0) + IsNull(P.SUM_NDS_A,0) + IsNull(P.SUM_EXC_A,0) > 0
                       THEN IsNull(P.QUANTITY_A,0)
                       ELSE 0
                       END,
  PSUM_EE16DB = CASE WHEN IsNull(P.SUM_EE_A,0) + IsNull(P.SUM_NDS_A,0) + IsNull(P.SUM_EXC_A,0) > 0
                     THEN IsNull(P.SUM_EE_A,0)  
                     ELSE 0
                     END,
  PSUM_NDS16DB = CASE WHEN IsNull(P.SUM_EE_A,0) + IsNull(P.SUM_NDS_A,0) + IsNull(P.SUM_EXC_A,0) > 0
                      THEN IsNull(P.SUM_NDS_A,0)  
                      ELSE 0
                      END,
  PSUM_EXC16DB = CASE WHEN IsNull(P.SUM_EE_A,0) + IsNull(P.SUM_NDS_A,0) + IsNull(P.SUM_EXC_A,0) > 0
                      THEN IsNull(P.SUM_EXC_A,0)  
                      ELSE 0
                      END,
  PAY16CR = CASE WHEN IsNull(P.SUM_EE_A,0) + IsNull(P.SUM_NDS_A,0) + IsNull(P.SUM_EXC_A,0) <= 0
                 THEN IsNull(P.SUM_EE_A,0) + IsNull(P.SUM_NDS_A,0) + IsNull(P.SUM_EXC_A,0)
                 ELSE 0
                 END,
  PQUANTITY16CR = CASE WHEN IsNull(P.SUM_EE_A,0) + IsNull(P.SUM_NDS_A,0) + IsNull(P.SUM_EXC_A,0) <= 0
                       THEN IsNull(P.QUANTITY_A,0) 
                       ELSE 0
                       END,
  PSUM_EE16CR = CASE WHEN IsNull(P.SUM_EE_A,0) + IsNull(P.SUM_NDS_A,0) + IsNull(P.SUM_EXC_A,0) <= 0
                     THEN IsNull(P.SUM_EE_A,0) 
                     ELSE 0
                     END,
  PSUM_NDS16CR = CASE WHEN IsNull(P.SUM_EE_A,0) + IsNull(P.SUM_NDS_A,0) + IsNull(P.SUM_EXC_A,0) <= 0
                      THEN IsNull(P.SUM_NDS_A,0) 
                      ELSE 0
                      END,
  PSUM_EXC16CR = CASE WHEN IsNull(P.SUM_EE_A,0) + IsNull(P.SUM_NDS_A,0) + IsNull(P.SUM_EXC_A,0) <= 0
                      THEN IsNull(P.SUM_EXC_A,0)
                      ELSE 0
                      END,
---- оплата 15%
  PAY15       = IsNull(P.SUM_EE_15,0) + IsNull(P.SUM_NDS_15,0) + IsNull(P.SUM_EXC_15,0),
  PQUANTITY15 = IsNull(P.QUANTITY_15,0),
  PSUM_EE15   = IsNull(P.SUM_EE_15,0),
  PSUM_NDS15  = IsNull(P.SUM_NDS_15,0),
  PSUM_EXC15  = IsNull(P.SUM_EXC_15,0),
  PAY15DB     = CASE WHEN IsNull(P.SUM_EE_15,0) + IsNull(P.SUM_NDS_15,0) + IsNull(P.SUM_EXC_15,0) > 0
                     THEN IsNull(P.SUM_EE_15,0) + IsNull(P.SUM_NDS_15,0) + IsNull(P.SUM_EXC_15,0)
                     ELSE 0
                     END,
  PQUANTITY15DB = CASE WHEN IsNull(P.SUM_EE_15,0) + IsNull(P.SUM_NDS_15,0) + IsNull(P.SUM_EXC_15,0) > 0
                       THEN IsNull(P.QUANTITY_15,0)
                       ELSE 0
                       END,
  PSUM_EE15DB = CASE WHEN IsNull(P.SUM_EE_15,0) + IsNull(P.SUM_NDS_15,0) + IsNull(P.SUM_EXC_15,0) > 0
                     THEN IsNull(P.SUM_EE_15,0)  
                     ELSE 0
                     END,
  PSUM_NDS15DB = CASE WHEN IsNull(P.SUM_EE_15,0) + IsNull(P.SUM_NDS_15,0) + IsNull(P.SUM_EXC_15,0) > 0
                      THEN IsNull(P.SUM_NDS_15,0)  
                      ELSE 0
                      END,
  PSUM_EXC15DB = CASE WHEN IsNull(P.SUM_EE_15,0) + IsNull(P.SUM_NDS_15,0) + IsNull(P.SUM_EXC_15,0) > 0
                      THEN IsNull(P.SUM_EXC_15,0)  
                      ELSE 0
                      END,
  PAY15CR = CASE WHEN IsNull(P.SUM_EE_15,0) + IsNull(P.SUM_NDS_15,0) + IsNull(P.SUM_EXC_15,0) <= 0
                 THEN IsNull(P.SUM_EE_15,0) + IsNull(P.SUM_NDS_15,0) + IsNull(P.SUM_EXC_15,0)
                 ELSE 0
                 END,
  PQUANTITY15CR = CASE WHEN IsNull(P.SUM_EE_15,0) + IsNull(P.SUM_NDS_15,0) + IsNull(P.SUM_EXC_15,0) <= 0
                       THEN IsNull(P.QUANTITY_15,0) 
                       ELSE 0
                       END,
  PSUM_EE15CR = CASE WHEN IsNull(P.SUM_EE_15,0) + IsNull(P.SUM_NDS_15,0) + IsNull(P.SUM_EXC_15,0) <= 0
                     THEN IsNull(P.SUM_EE_15,0) 
                     ELSE 0
                     END,
  PSUM_NDS15CR = CASE WHEN IsNull(P.SUM_EE_15,0) + IsNull(P.SUM_NDS_15,0) + IsNull(P.SUM_EXC_15,0) <= 0
                      THEN IsNull(P.SUM_NDS_15,0) 
                      ELSE 0
                      END,
  PSUM_EXC15CR = CASE WHEN IsNull(P.SUM_EE_15,0) + IsNull(P.SUM_NDS_15,0) + IsNull(P.SUM_EXC_15,0) <= 0
                      THEN IsNull(P.SUM_EXC_15,0)
                      ELSE 0
                      END,
------ оплата всего
  PAY = IsNull(P.SUM_EE,0) + IsNull(P.SUM_NDS,0) + IsNull(P.SUM_EXC,0),
  PQUANTITY = IsNull(P.QUANTITY,0),
  PSUM_EE = IsNull(P.SUM_EE,0),
  PSUM_NDS = IsNull(P.SUM_NDS,0),
  PSUM_EXC = IsNull(P.SUM_EXC,0),
--
  PAYDB = CASE WHEN IsNull(P.SUM_EE,0) + IsNull(P.SUM_NDS,0) + IsNull(P.SUM_EXC,0) > 0
               THEN IsNull(P.SUM_EE,0) + IsNull(P.SUM_NDS,0) + IsNull(P.SUM_EXC,0)
               ELSE 0
               END,
  PQUANTITYDB = CASE WHEN IsNull(P.SUM_EE,0) + IsNull(P.SUM_NDS,0) + IsNull(P.SUM_EXC,0) > 0
                     THEN IsNull(P.QUANTITY,0) 
                     ELSE 0
                     END,
  PSUM_EEDB = CASE WHEN IsNull(P.SUM_EE,0) + IsNull(P.SUM_NDS,0) + IsNull(P.SUM_EXC,0) > 0
                   THEN IsNull(P.SUM_EE,0)
                   ELSE 0
                   END,
  PSUM_NDSDB = CASE WHEN IsNull(P.SUM_EE,0) + IsNull(P.SUM_NDS,0) + IsNull(P.SUM_EXC,0) > 0
                    THEN IsNull(P.SUM_NDS,0)
                    ELSE 0
                    END,
  PSUM_EXCDB = CASE WHEN IsNull(P.SUM_EE,0) + IsNull(P.SUM_NDS,0) + IsNull(P.SUM_EXC,0) > 0
                    THEN IsNull(P.SUM_EXC,0)
                    ELSE 0
                    END,
  PAYCR = CASE WHEN IsNull(P.SUM_EE,0) + IsNull(P.SUM_NDS,0) + IsNull(P.SUM_EXC,0) <= 0
               THEN IsNull(P.SUM_EE,0) + IsNull(P.SUM_NDS,0) + IsNull(P.SUM_EXC,0)
               ELSE 0
               END,
  PQUANTITYCR = CASE WHEN IsNull(P.SUM_EE,0) + IsNull(P.SUM_NDS,0) + IsNull(P.SUM_EXC,0) <= 0
                     THEN IsNull(P.QUANTITY,0)
                     ELSE 0
                     END,
  PSUM_EECR = CASE WHEN IsNull(P.SUM_EE,0) + IsNull(P.SUM_NDS,0) + IsNull(P.SUM_EXC,0) <= 0
                   THEN IsNull(P.SUM_EE,0)
                   ELSE 0
                   END,
  PSUM_NDSCR = CASE WHEN IsNull(P.SUM_EE,0) + IsNull(P.SUM_NDS,0) + IsNull(P.SUM_EXC,0) <= 0
                    THEN IsNull(P.SUM_NDS,0)
                    ELSE 0
                    END,
  PSUM_EXCCR = CASE WHEN IsNull(P.SUM_EE,0) + IsNull(P.SUM_NDS,0) + IsNull(P.SUM_EXC,0) <= 0
                    THEN IsNull(P.SUM_EXC,0)
                    ELSE 0
                    END,

------ сальдо на конец 20%
  ESALDO20        = 0,
  EQUANTITY20     = 0,
  ESUM_EE20       = 0,
  ESUM_ACT20      = 0,
  ESUM_EXC20      = 0,
--
  ESALDO20DB      = 0,
  EQUANTITY20DB   = 0,
  ESUM_EE20DB     = 0,
  ESUM_ACT20DB    = 0,
  ESUM_EXC20DB    = 0,
--
  ESALDO20CR      = 0,
  EQUANTITY20CR   = 0,
  ESUM_EE20CR     = 0,
  ESUM_ACT20CR    = 0,
  ESUM_EXC20CR    = 0,
----- сальдо на конец 16%
  ESALDO16        = 0,
  EQUANTITY16     = 0,
  ESUM_EE16       = 0,
  ESUM_ACT16      = 0,
  ESUM_EXC16      = 0,
--
  ESALDO16DB      = 0,
  EQUANTITY16DB   = 0,
  ESUM_EE16DB     = 0,
  ESUM_ACT16DB    = 0,
  ESUM_EXC16DB    = 0,
--
  ESALDO16CR      = 0,
  EQUANTITY16CR   = 0,
  ESUM_EE16CR     = 0,
  ESUM_ACT16CR    = 0,
  ESUM_EXC16CR    = 0,
----- сальдо на конец 15%
  ESALDO15        = 0,
  EQUANTITY15     = 0,
  ESUM_EE15       = 0,
  ESUM_ACT15      = 0,
  ESUM_EXC15      = 0,
--
  ESALDO15DB      = 0,
  EQUANTITY15DB   = 0,
  ESUM_EE15DB     = 0,
  ESUM_ACT15DB    = 0,
  ESUM_EXC15DB    = 0,
--
  ESALDO15CR      = 0,
  EQUANTITY15CR   = 0,
  ESUM_EE15CR     = 0,
  ESUM_ACT15CR    = 0,
  ESUM_EXC15CR    = 0,
------ сальдо на конец всего
  ESALDO          = 0,
  EQUANTITY       = 0,
  ESUM_EE         = 0,
  ESUM_ACT        = 0,
  ESUM_EXC        = 0,
--
  ESALDODB        = 0,
  EQUANTITYDB     = 0,
  ESUM_EEDB       = 0,
  ESUM_ACTDB      = 0,
  ESUM_EXCDB      = 0,
--
  ESALDOCR        = 0,
  EQUANTITYCR     = 0,
  ESUM_EECR       = 0,
  ESUM_ACTCR      = 0,
  ESUM_EXCCR      = 0
------
 FROM
  ProContracts Cs,
  #ProCalcs C,
  #ProDivPaymentSum P,
  ProPartSaldo PP,
  ProDivSaldo DS,
  #BTariff BT,
  #ETariff ET
 WHERE
  C.CONTRACT_ID=*Cs.CONTRACT_ID AND
  P.CONTRACT_ID=*Cs.CONTRACT_ID AND
  PP.CONTRACT_ID=*Cs.CONTRACT_ID AND
  PP.DATE_CALC=@dtCalc AND
  DS.CONTRACT_ID=*Cs.CONTRACT_ID AND
  DS.DATE_CALC=@dtPrev AND
  BT.CONTRACT_ID=Cs.CONTRACT_ID AND
  ET.CONTRACT_ID=Cs.CONTRACT_ID

UPDATE
  ProDivSaldo
 SET
--20%
  BSALDO20DB    = CASE WHEN BSALDO > 0 THEN BSALDO20     ELSE 0 END,
  BQUANTITY20DB = CASE WHEN BSALDO > 0 THEN BQUANTITY20  ELSE 0 END,
  BSUM_EE20DB   = CASE WHEN BSALDO > 0 THEN BSUM_EE20    ELSE 0 END,
  BSUM_ACT20DB  = CASE WHEN BSALDO > 0 THEN BSUM_ACT20   ELSE 0 END,
  BSUM_EXC20DB  = CASE WHEN BSALDO > 0 THEN BSUM_EXC20   ELSE 0 END,
----
  BSALDO20CR    = CASE WHEN BSALDO <= 0 THEN BSALDO20    ELSE 0 END,
  BQUANTITY20CR = CASE WHEN BSALDO <= 0 THEN BQUANTITY20 ELSE 0 END,
  BSUM_EE20CR   = CASE WHEN BSALDO <= 0 THEN BSUM_EE20   ELSE 0 END,
  BSUM_ACT20CR  = CASE WHEN BSALDO <= 0 THEN BSUM_ACT20  ELSE 0 END,
  BSUM_EXC20CR  = CASE WHEN BSALDO <= 0 THEN BSUM_EXC20  ELSE 0 END,
---16%
  BSALDO16DB    = CASE WHEN BSALDO > 0 THEN BSALDO16     ELSE 0 END,
  BQUANTITY16DB = CASE WHEN BSALDO > 0 THEN BQUANTITY16  ELSE 0 END,
  BSUM_EE16DB   = CASE WHEN BSALDO > 0 THEN BSUM_EE16    ELSE 0 END,
  BSUM_ACT16DB  = CASE WHEN BSALDO > 0 THEN BSUM_ACT16   ELSE 0 END,
  BSUM_EXC16DB  = CASE WHEN BSALDO > 0 THEN BSUM_EXC16   ELSE 0 END,
---
  BSALDO16CR    = CASE WHEN BSALDO <= 0 THEN BSALDO16    ELSE 0 END,
  BQUANTITY16CR = CASE WHEN BSALDO <= 0 THEN BQUANTITY16 ELSE 0 END,
  BSUM_EE16CR   = CASE WHEN BSALDO <= 0 THEN BSUM_EE16   ELSE 0 END,
  BSUM_ACT16CR  = CASE WHEN BSALDO <= 0 THEN BSUM_ACT16  ELSE 0 END,
  BSUM_EXC16CR  = CASE WHEN BSALDO <= 0 THEN BSUM_EXC16  ELSE 0 END,
---15%
  BSALDO15DB    = CASE WHEN BSALDO > 0 THEN BSALDO15     ELSE 0 END,
  BQUANTITY15DB = CASE WHEN BSALDO > 0 THEN BQUANTITY15  ELSE 0 END,
  BSUM_EE15DB   = CASE WHEN BSALDO > 0 THEN BSUM_EE15    ELSE 0 END,
  BSUM_ACT15DB  = CASE WHEN BSALDO > 0 THEN BSUM_ACT15   ELSE 0 END,
  BSUM_EXC15DB  = CASE WHEN BSALDO > 0 THEN BSUM_EXC15   ELSE 0 END,
---
  BSALDO15CR    = CASE WHEN BSALDO <= 0 THEN BSALDO15    ELSE 0 END,
  BQUANTITY15CR = CASE WHEN BSALDO <= 0 THEN BQUANTITY15 ELSE 0 END,
  BSUM_EE15CR   = CASE WHEN BSALDO <= 0 THEN BSUM_EE15   ELSE 0 END,
  BSUM_ACT15CR  = CASE WHEN BSALDO <= 0 THEN BSUM_ACT15  ELSE 0 END,
  BSUM_EXC15CR  = CASE WHEN BSALDO <= 0 THEN BSUM_EXC15  ELSE 0 END,
--свего
  BSALDODB      = CASE WHEN BSALDO > 0  THEN BSALDO      ELSE 0 END,
  BQUANTITYDB   = CASE WHEN BSALDO > 0  THEN BQUANTITY   ELSE 0 END,
  BSUM_EEDB     = CASE WHEN BSALDO > 0  THEN BSUM_EE     ELSE 0 END,
  BSUM_ACTDB    = CASE WHEN BSALDO > 0  THEN BSUM_ACT    ELSE 0 END,
  BSUM_EXCDB    = CASE WHEN BSALDO > 0  THEN BSUM_EXC    ELSE 0 END,
---
  BSALDOCR      = CASE WHEN BSALDO <= 0 THEN BSALDO      ELSE 0 END,
  BQUANTITYCR   = CASE WHEN BSALDO <=0  THEN BQUANTITY   ELSE 0 END,
  BSUM_EECR     = CASE WHEN BSALDO <= 0 THEN BSUM_EE     ELSE 0 END,
  BSUM_ACTCR    = CASE WHEN BSALDO <= 0 THEN BSUM_ACT    ELSE 0 END,
  BSUM_EXCCR    = CASE WHEN BSALDO <= 0 THEN BSUM_EXC    ELSE 0 END 
 FROM
  ProDivSaldo DS
 WHERE
  DS.DATE_CALC=@dtCalc

--------------------------------------------------------------------------
UPDATE
  ProDivSaldo 
 SET
  ESALDO20    = BSALDO20 + NACH20 - PAY20,
  EQUANTITY20 = BQUANTITY20 + NQUANTITY20 - PQUANTITY20,
  ESUM_EE20   = BSUM_EE20 + NSUM_EE20 - PSUM_EE20,
  ESUM_ACT20  = BSUM_ACT20 + NSUM_NDS20 - PSUM_NDS20,
  ESUM_EXC20  = BSUM_EXC20 + NSUM_EXC20 - PSUM_EXC20,
---
  ESALDO16    = BSALDO16 + NACH16 - PAY16,
  EQUANTITY16 = BQUANTITY16 + NQUANTITY16 - PQUANTITY16,
  ESUM_EE16   = BSUM_EE16 + NSUM_EE16 - PSUM_EE16,
  ESUM_ACT16  = BSUM_ACT16 + NSUM_NDS16 - PSUM_NDS16,
  ESUM_EXC16  = BSUM_EXC16 + NSUM_EXC16 - PSUM_EXC16,
---
  ESALDO15    = BSALDO15 + NACH15 - PAY15,
  EQUANTITY15 = BQUANTITY15 + NQUANTITY15 - PQUANTITY15,
  ESUM_EE15   = BSUM_EE15 + NSUM_EE15 - PSUM_EE15,
  ESUM_ACT15  = BSUM_ACT15 + NSUM_NDS15 - PSUM_NDS15,
  ESUM_EXC15  = BSUM_EXC15 + NSUM_EXC15 - PSUM_EXC15,
---
  ESALDO      = BSALDO + NACH - PAY,
  EQUANTITY   = BQUANTITY + NQUANTITY - PQUANTITY,
  ESUM_EE     = BSUM_EE20 + BSUM_EE16 + BSUM_EE15 + NSUM_EE - PSUM_EE,
  ESUM_ACT    = BSUM_ACT20 + BSUM_ACT16 + BSUM_ACT15 + NSUM_NDS - PSUM_NDS,
  ESUM_EXC    = BSUM_EXC20 + BSUM_EXC16 + BSUM_EXC15 +  NSUM_EXC - PSUM_EXC
 FROM
  ProDivSaldo DS
 WHERE
  DS.DATE_CALC = @dtCalc


UPDATE
  ProDivSaldo
 SET
---20%
  ESALDO20DB    = CASE WHEN ESALDO > 0  THEN ESALDO20     ELSE 0 END,
  EQUANTITY20DB = CASE WHEN ESALDO > 0  THEN EQUANTITY20  ELSE 0 END,
  ESUM_EE20DB   = CASE WHEN ESALDO > 0  THEN ESUM_EE20    ELSE 0 END,
  ESUM_ACT20DB  = CASE WHEN ESALDO > 0  THEN ESUM_ACT20   ELSE 0 END,
  ESUM_EXC20DB  = CASE WHEN ESALDO > 0  THEN ESUM_EXC20   ELSE 0 END,
---
  ESALDO20CR    = CASE WHEN ESALDO <= 0 THEN ESALDO20     ELSE 0 END,
  EQUANTITY20CR = CASE WHEN ESALDO <= 0 THEN EQUANTITY20  ELSE 0 END,
  ESUM_EE20CR   = CASE WHEN ESALDO <= 0 THEN ESUM_EE20    ELSE 0 END,
  ESUM_ACT20CR  = CASE WHEN ESALDO <= 0 THEN ESUM_ACT20   ELSE 0 END,
  ESUM_EXC20CR  = CASE WHEN ESALDO <= 0 THEN ESUM_EXC20   ELSE 0 END,
---16%
  ESALDO16DB    = CASE WHEN ESALDO > 0  THEN ESALDO16     ELSE 0 END,
  EQUANTITY16DB = CASE WHEN ESALDO > 0  THEN EQUANTITY16  ELSE 0 END,
  ESUM_EE16DB   = CASE WHEN ESALDO > 0  THEN ESUM_EE16    ELSE 0 END,
  ESUM_ACT16DB  = CASE WHEN ESALDO > 0  THEN ESUM_ACT16   ELSE 0 END,
  ESUM_EXC16DB  = CASE WHEN ESALDO > 0  THEN ESUM_EXC16   ELSE 0 END,
---
  ESALDO16CR    = CASE WHEN ESALDO <= 0 THEN ESALDO16     ELSE 0 END,
  EQUANTITY16CR = CASE WHEN ESALDO <= 0 THEN EQUANTITY16  ELSE 0 END,
  ESUM_EE16CR   = CASE WHEN ESALDO <= 0 THEN ESUM_EE16    ELSE 0 END,
  ESUM_ACT16CR  = CASE WHEN ESALDO <= 0 THEN ESUM_ACT16   ELSE 0 END,
  ESUM_EXC16CR  = CASE WHEN ESALDO <= 0 THEN ESUM_EXC16   ELSE 0 END,
--15%
  ESALDO15DB    = CASE WHEN ESALDO > 0  THEN ESALDO15     ELSE 0 END,
  EQUANTITY15DB = CASE WHEN ESALDO > 0  THEN EQUANTITY15  ELSE 0 END,
  ESUM_EE15DB   = CASE WHEN ESALDO > 0  THEN ESUM_EE15    ELSE 0 END,
  ESUM_ACT15DB  = CASE WHEN ESALDO > 0  THEN ESUM_ACT15   ELSE 0 END,
  ESUM_EXC15DB  = CASE WHEN ESALDO > 0  THEN ESUM_EXC15   ELSE 0 END,
---
  ESALDO15CR    = CASE WHEN ESALDO <= 0 THEN ESALDO15     ELSE 0 END,
  EQUANTITY15CR = CASE WHEN ESALDO <= 0 THEN EQUANTITY15  ELSE 0 END,
  ESUM_EE15CR   = CASE WHEN ESALDO <= 0 THEN ESUM_EE15    ELSE 0 END,
  ESUM_ACT15CR  = CASE WHEN ESALDO <= 0 THEN ESUM_ACT15   ELSE 0 END,
  ESUM_EXC15CR  = CASE WHEN ESALDO <= 0 THEN ESUM_EXC15   ELSE 0 END,
---всего
  ESALDODB      = CASE WHEN ESALDO > 0  THEN ESALDO       ELSE 0 END,
  EQUANTITYDB   = CASE WHEN ESALDO > 0  THEN EQUANTITY    ELSE 0 END,
  ESUM_EEDB     = CASE WHEN ESALDO > 0  THEN ESUM_EE      ELSE 0 END,
  ESUM_ACTDB    = CASE WHEN ESALDO > 0  THEN ESUM_ACT     ELSE 0 END,
  ESUM_EXCDB    = CASE WHEN ESALDO > 0  THEN ESUM_EXC     ELSE 0 END,
---
  ESALDOCR      = CASE WHEN ESALDO <= 0 THEN ESALDO       ELSE 0 END,
  EQUANTITYCR   = CASE WHEN ESALDO <= 0 THEN EQUANTITY    ELSE 0 END,
  ESUM_EECR     = CASE WHEN ESALDO <= 0 THEN ESUM_EE      ELSE 0 END,
  ESUM_ACTCR    = CASE WHEN ESALDO <= 0 THEN ESUM_ACT     ELSE 0 END,
  ESUM_EXCCR    = CASE WHEN ESALDO <= 0 THEN ESUM_EXC     ELSE 0 END
  
 FROM
  ProDivSaldo DS
 WHERE
  DS.DATE_CALC=@dtCalc

