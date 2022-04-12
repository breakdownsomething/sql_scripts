DECLARE
  @dtCurEnd            DateTime,
  @dfTaxACTBefo        Decimal(9,2),
  @dfTaxACTAft         Decimal(9,2),
  @dfTaxACTAftAft      Decimal(9,2)

SELECT
  @dtCurEnd          =  convert(DateTime,'2004-01-31',21),
  @dfTaxACTBefo      = 0.20,
  @dfTaxACTAft       = 0.16,
  @dfTaxACTAftAft    = 0.15


SELECT
  CONTRACT_ID = C.CONTRACT_ID,
  SALDO       = C.SALDO,
  SUM_NACH    = C.SUM_FACT+C.SUM_NDS+C.SUM_EXC,
  QUANTITY    = C.QNT_ALL,
  SUM_EE      = C.SUM_FACT,
  SUM_ACT     = C.SUM_NDS,
  SUM_EXC     = C.SUM_EXC,
  SUM_ADD     = C.SUM_ADD,
/* Дополнительные начисления за период с НДС 20% */
 /*Щбщая сумма, она же в будующем сумма за электроэнергию*/
  SUM_ADD_20  = Convert(Decimal(12,2),IsNull(
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

/*сумма за электроэнергию*/
   SUM_EE_20    = Convert(Decimal(12,2),0.00),


/* Дополнительные начисления за период с НДС 16% */
/**/
  SUM_ADD_16  = Convert(Decimal(12,2),IsNull(
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

/*сумма за электроэнергию*/
   SUM_EE_16    = Convert(Decimal(12,2),0.00),

/**/
  DELTA_ACT    = Convert(Decimal(12,2),0.00)

 INTO
  #ProCalcs
 FROM
  ProCalcs C (NoLock)
 WHERE
  C.DATE_CALC=@dtCurEnd
 /* {For Tests} AND C.CONTRACT_NUMBER = 5010*/ 
ALTER TABLE
  #ProCalcs
 ADD PRIMARY KEY (CONTRACT_ID)


SELECT * FROM #ProCalcs

DROP TABLE #ProCalcs






