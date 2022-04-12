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


--DROP PROCEDURE dbo.pDivPartPay

/*
CREATE PROCEDURE dbo.pDivPartPay
  @iContractId   Integer,
  @dtCalcEnd     DateTime,  -- Расчётный период(конец периода)
  @dtDateBeg     DateTime,  -- Начало хранимых данных(конец периода)
  @dtDateEnd     DateTime   -- Последний период по базе(конец периода)
AS

DECLARE
  @dtCalcBeg     DateTime   -- Расчётный период(начало периода)
*/


Declare
  @iContractId   Integer,
  @dtCalcBeg     DateTime,  -- Расчётный период(начало периода)
  @dtCalcEnd     DateTime,  -- Расчётный период(конец периода)
  @dtDateBeg     DateTime,  -- Начало хранимых данных(конец периода)
  @dtDateEnd     DateTime   -- Последний период по базе(конец периода)
  
SELECT
  @iContractId = 1415,
  @dtCalcEnd   = '2004-01-31',  -- Расчётный период(конец периода)
  @dtDateBeg   = '1998-08-31',  -- Начало хранимых данных(конец периода)
  @dtDateEnd   = '2004-02-29'   -- Последний период по базе(конец периода)(незакрытый)

  
SELECT
  @dtCalcBeg=DateAdd(mm,-1,DateAdd(dd,1,@dtCalcEnd))
  
DECLARE
  @dfSumPayMonth Decimal(12,2),  /**/
  @dfSumNoPay    Decimal(12,2),  /**/
  @dfSumPay      Decimal(12,2),  /*Сумма платежей*/
  @dfRest        Decimal(12,2),  /*Сумма нераспределенных платежей*/
  @dtDolgBeg     DateTime,       /*Дата начала задолжности*/
  @dtPayBeg      DateTime,       /**/
  @dfSumRemPay   Decimal(12,2),  /*Остаток от предыдущего платежа*/
  @dfSaldo       Decimal(12,2),  /*Сальдо (?на начало месяца)*/
  @dfSumEE       Decimal(12,2),  /*Сумма за электроэнергию*/
  @dfSumNDS      Decimal(12,2),  /*Сумма за НДС*/
  @dfSumExc      Decimal(12,2),  /*Сумма за акциз*/
  @dfCurNach     Decimal(12,2),  /*Текущее начисление*/
  @dfCurTaxNDS   Decimal(12,2),  /*Текущий НДС*/
  @dfTaxNDSCR    Decimal(12,2),  /*Ставка НДС для переплаты*/
  @dfCurTaxExc   Decimal(12,2),  /*Текущая ставка акциза*/
  @dfCurTariff   Decimal(18,10), /*Текущий средний тариф*/
  @iKVTBefo      Integer,        /*Киловаты 20%*/
  @iKVTAft       Integer,        /*16%*/
  @iKVT_15       Integer,        /*15%*/
  @iKVT          Integer,        /**/
  @iKVTCR        Integer,        /**/
  @dfWk          Decimal(12,2),  /*служебная переменная*/
  @iWk           Integer,        /*служебная переменная*/
  @siExists      SmallInt,       /*флаг существования (Чего?)*/
  @dfSumPayRasp  Decimal(12,2),  /*сумма распределения платежа*/
  @dfSumSaldoBeg Decimal(12,2),  /*сальдо на начало*/
  @dfSumSaldoEnd Decimal(12,2),  /*сальдо на конкц без учета оплаты */
  @dfSumSaldoOst Decimal(12,2),  /* _                */
  @dfSumEEBefo   Decimal(12,2),  /*  \               */
  @dfSumNDSBefo  Decimal(12,2),  /*  | 20%           */
  @dfSumExcBefo  Decimal(12,2),  /* _/               */
  @dfSumEEAft    Decimal(12,2),  /*  \               */
  @dfSumNDSAft   Decimal(12,2),  /*  |16%            */
  @dfSumExcAft   Decimal(12,2),  /* _/               */
  @dfSumEE_15    Decimal(12,2),  /*  \               */
  @dfSumNDS_15   Decimal(12,2),  /*  |15%  NEW       */
  @dfSumExc_15   Decimal(12,2),  /* _/               */
  @dfSaldoCR     Decimal(12,2),  /*  \               */
  @dfSumEECR     Decimal(12,2),  /*  |               */
  @dfSumNDSCR    Decimal(12,2),  /*  |переплата      */
  @dfSumExcCR    Decimal(12,2),  /* _/               */
  @dfSaldoCrBegM Decimal(12,2),  /**/
  @dfSaldoCrEndM Decimal(12,2),  /**/
  @dfSaldoCrDelta Decimal(12,2), /**/ 
  @DtWk          DateTime,       /*служебная переменная*/
  @siVozvrat     SmallInt        /*флаг наличия отрицательных платежей*/
 
SELECT
  @dfCurNach=0,
  @dfCurTaxNDS=0,
  @dfCurTaxExc=0,
  @dfCurTariff=0
SELECT
  @dfSaldoCR=0,
  @iKVTCR=0,
  @dfSumNDSCR=0,
  @dfSumExcCR=0,
  @dfSumEECR=0
     
-- Ставка НДС в расчётном месяце
SELECT @dfTaxNDSCR = IsNull((SELECT ADD_COST_TAX
                             FROM ProContracts
                             WHERE CONTRACT_ID = @iContractId),0)
-- Сумма оплаты за месяц
SELECT @dfSumPayMonth = Sum(SUM_EE + SUM_ACT)
FROM ProPayments (NOLOCK)
WHERE CONTRACT_ID = @iContractId AND
      DATE_PAY Between @dtCalcBeg AND @dtCalcEnd  
  
SELECT @dfSumPayMonth = IsNull(@dfSumPayMonth,0)
      
-- Дата начала задолженности, остаток от оплаты пред.периода
SELECT @dtDolgBeg = DATE_BEGIN,
       @dfSumRemPay = SUM_PAY
FROM  ProRemainds (NOLOCK)
WHERE CONTRACT_ID = @iContractId AND
      DATE_END = @dtCalcEnd

SELECT @dtPayBeg = IsNull(@dtDolgBeg,@dtCalcEnd)
SELECT @dtDolgBeg = IsNull(@dtDolgBeg,DateAdd(dd,-1,DateAdd(mm,1,DateAdd(dd,1,@dtCalcEnd))))
SELECT @dfSumRemPay = Coalesce(@dfSumRemPay,
                      (CASE WHEN @dtPayBeg = @dtDateBeg
                            THEN CASE WHEN @dtPayBeg = @dtDateEnd
                                      THEN (SELECT SALDO
                                            FROM ProContracts (NOLOCK)
                                            WHERE CONTRACT_ID = @iContractId)
                                      ELSE (SELECT SALDO
                                            FROM ProCalcs (NOLOCK)
                                            WHERE CONTRACT_ID = @iContractId AND
                                                  DATE_CALC = @dtPayBeg)
                                      END
                            ELSE 0
                            END),0)

SELECT
  @dfSumEEBefo=0,
  @dfSumNDSBefo=0,
  @dfSumExcBefo=0,
  @iKVTBefo=0,
  @dfSumEEAft=@dfSumPayMonth,
  @dfSumNDSAft=0,
  @dfSumExcAft=0,
  @iKVTAft=0,

  @iKVT_15=0,
  @dfSumEE_15=0,
  @dfSumNDS_15=0,
  @dfSumExc_15=0,

  @dfSumEE=@dfSumPayMonth,
  @dfSumNDS=0,
  @dfSumExc=0,
  @iKVT=0,
  @dfSumNoPay=0,
  @dfRest=0

SELECT  @dfSumSaldoBeg=IsNull(CASE WHEN @dtPayBeg=@dtDateEnd
                                   THEN (SELECT SALDO
                                         FROM ProContracts (NOLOCK)
                                         WHERE CONTRACT_ID = @iContractId)
                                   ELSE (SELECT SALDO
                                         FROM ProCalcs (NOLOCK)
                                         WHERE CONTRACT_ID = @iContractId AND
                                               DATE_CALC = @dtPayBeg)
                                   END,0)
     
SELECT  @dfSumSaldoEnd=IsNull(CASE WHEN @dtCalcEnd=@dtDateEnd
                                   THEN (SELECT SALDO
                                         FROM ProContracts (NOLOCK)
                                         WHERE CONTRACT_ID = @iContractId)
                                   ELSE (SELECT SALDO
                                         FROM ProCalcs (NOLOCK)
                                         WHERE CONTRACT_ID = @iContractId AND
                                               DATE_CALC = @dtCalcEnd) 
                                   END,0)
                       +IsNull((SELECT (SUM_FACT+SUM_EXC+SUM_NDS)
                                FROM ProCalcs (NOLOCK)
                                WHERE CONTRACT_ID = @iContractId AND
                                      DATE_CALC = @dtCalcEnd AND
                                      (SUM_FACT + SUM_EXC + SUM_NDS) < 0),0)
SELECT @dfSumSaldoOst = @dfSumSaldoEnd

SELECT @dfSumPay = IsNull((SELECT SUM(SUM_EE + SUM_ACT) 
                           FROM ProPayments (NOLOCK)
                           WHERE CONTRACT_ID = @iContractId AND
                                 DATE_PAY Between DateAdd(mm,-1,DateAdd(dd,1,@dtPayBeg)) AND 
                                                  DateAdd(dd,-1,DateAdd(mm,-1,DateAdd(dd,1,@dtCalcEnd)))),0)


IF @dfSumPayMonth>0
--******************************************
BEGIN
-- Пока не обработан весь платёж
---------------------------------------------------
SELECT @dfCurNach = IsNull((SELECT SUM_FACT + SUM_NDS + SUM_EXC
                            FROM ProCalcs (NOLOCK)
                            WHERE CONTRACT_ID = @iContractId AND
                                  DATE_CALC = @dtCalcEnd),0)
------
IF (@dfSumSaldoEnd + CASE WHEN @dfCurNach > 0
                          THEN @dfCurNach
                          ELSE 0
                          END) > 0

BEGIN --##########################
SELECT @dfSumEEAft = 0 
WHILE @dfSumPayMonth - @dfRest - CASE WHEN @dfSumSaldoEnd < 0
                                      THEN @dfSumSaldoEnd
                                      ELSE 0
                                      END > 0
BEGIN
  SELECT @siVozvrat = 0  
  
--  Начисление, тариф на реализацию, ставка НДС, ставка акциза обрабатываемого периода
  SELECT @siExists = Convert(SmallInt, CASE WHEN Exists (SELECT *
                                                         FROM ProCalcs (NOLOCK)
                                                         WHERE CONTRACT_ID = @iContractId AND
                                                               DATE_CALC = @dtPayBeg AND
                                                               SUM_FACT + SUM_NDS + SUM_EXC > 0)
                                            THEN 1
                                            ELSE 0
                                            END)
      
  IF @siExists=1 
  BEGIN
   SELECT
      @dfCurNach    = SUM_FACT + SUM_NDS + SUM_EXC,
      @dfCurTariff  = CASE WHEN QNT_ALL <> 0
                           THEN (SUM_FACT + SUM_NDS + SUM_EXC) / QNT_ALL
                           ELSE @dfCurTariff 
                           END,
     @dfCurTaxNDS   = CASE WHEN SUM_FACT <> 0
                           THEN ADD_COST_TAX
                           ELSE @dfCurTaxNDS
                           END,
     @dfCurTaxExc   = Convert(Decimal(12,2),
                      CASE WHEN QNT_ALL <> 0
                           THEN EXCISE_TAX
                           ELSE @dfCurTaxExc 
                           END) 
   FROM ProCalcs (NOLOCK)
   WHERE CONTRACT_ID = @iContractId AND
         DATE_CALC   = @dtPayBeg
      
  END
  ELSE
  BEGIN
    SELECT
      @dfCurNach=0,
      @dfCurTariff=0
      
  END

-----
-- Print 'Текущее начисление,тариф,такса НДС,такса акциза'
-- Print  @dfCurNach
-- Print  @dfCurTariff
-- Print  @dfCurTaxNDS
-- Print  @dfCurTaxExc
  
--  Неоплаченный остаток (первого) обрабатываемого периода
/*
 Print '*3*3*3*3*'
Print @dtPayBeg
Print @dtDateBeg
Print @dfSumSaldoBeg
Print @dfSumPay
Print @dfCurNach
Print @dfSumRemPay
Print @dfSumSaldoEnd
Print @dfSumSaldoOst */

  SELECT @dfSumNoPay = CASE WHEN @dtPayBeg=@dtDateBeg
                            THEN @dfSumSaldoBeg - @dfSumPay + @dfCurNach - @dfSumRemPay 
                            ELSE @dfCurNach - @dfSumRemPay 
                            END 

  SELECT @dfSumRemPay = 0    

  IF  @dfSumNoPay > @dfSumSaldoOst AND
      @siVozvrat = 0 AND
      @dtPayBeg <> @dtcalcEnd 
  BEGIN
    SELECT @dfSumNoPay = @dfSumSaldoOst,
           @siVozvrat = 1
  END
  ELSE
    SELECT @dfSumSaldoOst = @dfSumSaldoOst - @dfSumNoPay 
    SELECT @dfSumPayRasp = @dfSumPayMonth - CASE WHEN @dfSumSaldoEnd < 0
                                                 THEN @dfSumSaldoEnd
                                                 ELSE 0
                                                 END
    
/*
Print 'Неоплаченный остаток'
*/
  IF @dtPayBeg = @dtCalcEnd 
    SELECT @dfRest = @dfSumNoPay - @dfSumPayRasp 
  ELSE
    SELECT @dfRest = 0 
/*
Print @dfRest        
*/
--  Количество КВТ в оплате, всего и за обр.период
  SELECT @iKVT = @iKVT + Round(CASE WHEN @dfCurTariff <> 0
                                    THEN CASE WHEN @dfSumNoPay <= @dfSumPayRasp
                                              THEN @dfSumNoPay / @dfCurTariff
                                              ELSE @dfSumPayRasp / @dfCurTariff 
                                              END 
                                    ELSE 0
                                    END,0),
  @iWk=Round(CASE WHEN @dfCurTariff <> 0
                  THEN CASE WHEN @dfSumNoPay <= @dfSumPayRasp
                            THEN @dfSumNoPay / @dfCurTariff
                            ELSE @dfSumPayRasp / @dfCurTariff 
                            END
                  ELSE 0
                  END,0)

--  Доля НДС в оплате
  SELECT @dfSumNDS = @dfSumNDS + Convert(Decimal(12,2),
      CASE WHEN @dfSumNoPay <= @dfSumPayRasp
           THEN (@dfSumNoPay * @dfCurTaxNDS) / (100.00 + @dfCurTaxNDS)
           ELSE (@dfSumPayRasp * @dfCurTaxNDS) / (100.00 + @dfCurTaxNDS)
           END)
--  Доля акциза в оплате
  SELECT @dfSumExc = @dfSumExc + Sign(@dfSumNoPay) * Round(@iWk * @dfCurTaxExc,2)
---************
  SELECT
    @dfSaldoCrBegM = 0,
    @dfSaldoCrEndM = 0
  SELECT @dfSaldoCrBegM = CASE WHEN @dtPayBeg = @dtDateEnd
                               THEN IsNull((SELECT SALDO 
                                            FROM ProContracts
                                            WHERE CONTRACT_ID = @iContractId),0)  
                               ELSE IsNull((SELECT SALDO 
                                            FROM ProCalcs  
                                            WHERE DATE_CALC = @dtPayBeg AND
                                                  CONTRACT_ID=@iContractId),0)  
                               END  
  SELECT @dfSaldoCrEndM = CASE WHEN @dtPayBeg = @dtDateEnd
                               THEN IsNull((SELECT SALDO 
                                            FROM ProContracts
                                            WHERE CONTRACT_ID = @iContractId),0)  
                                ELSE IsNull((SELECT SALDO 
                                             FROM ProCalcs  
                                             WHERE DATE_CALC = @dtPayBeg AND
                                                   CONTRACT_ID = @iContractId),0)  
                                END+
                           IsNull((SELECT SUM_FACT + SUM_NDS + SUM_EXC
                                   FROM ProCalcs
                                   WHERE CONTRACT_ID = @iContractId AND
                                          DATE_CALC=@dtPayBeg),0) - IsNull((SELECT SUM(SUM_EE + SUM_ACT)
                                                                            FROM ProPayments
                                                                            WHERE CONTRACT_ID = @iContractId AND
                                                                                  DATE_PAY BETWEEN
                                                                                  DateAdd(mm,-1,DateAdd(dd,1,@dtPayBeg)) AND
                                                                                  @dtPayBeg),0)

/* Распределение по процентам !!!!!=================================================================*/

  SELECT
    @dfSaldoCrDelta = CASE WHEN @dfSaldoCrBegM < 0 THEN @dfSaldoCrBegM ELSE 0 END -
                      CASE WHEN @dfSaldoCrEndM < 0 THEN @dfSaldoCrEndM ELSE 0 END 
/* label 1 ------------------------- 15% - После 2003-01-31----------------------------------------------- */

IF @dtPayBeg > '2003-12-31'
  BEGIN
   SELECT
    @iKVT_15 = @iKVT_15 + Round(CASE WHEN @dfCurTariff <> 0
                                     THEN CASE WHEN @dfSumNoPay <= @dfSumPayRasp
                                               THEN @dfSumNoPay / @dfCurTariff
                                               ELSE @dfSumPayRasp / @dfCurTariff 
                                               END 
                                     ELSE 0
                                     END,0)
   SELECT
      @dfSumNDS_15 = @dfSumNDS_15 + Convert(Decimal(12,2),
      CASE WHEN @dfSumNoPay <= @dfSumPayRasp
           THEN (@dfSumNoPay * @dfCurTaxNDS) / (100.00 + @dfCurTaxNDS)
           ELSE (@dfSumPayRasp * @dfCurTaxNDS) / (100.00 + @dfCurTaxNDS)
           END)

   SELECT @dfSumExc_15 = @dfSumExc_15 + Sign(@dfSumNoPay) * Round(@iWk * @dfCurTaxExc,2)
   SELECT
      @dfSumEE_15 = @dfSumEE_15 + Convert(Decimal(12,2),
      CASE WHEN @dfSumNoPay <= @dfSumPayRasp
           THEN @dfSumNoPay
           ELSE @dfSumPayRasp
           END) + 
      CASE WHEN @dfSaldoCrDelta > 0
           THEN @dfSaldoCrDelta
           ELSE 0
           END 
  END
ELSE
  BEGIN
/*------------------------- 16% - После 2001-07-31----------------------------------------------- */
IF @dtPayBeg BETWEEN '2001-07-31' AND '2003-12-31'
  BEGIN
   SELECT
    @iKVTAft = @iKVTAft + Round(CASE WHEN @dfCurTariff <> 0
                                     THEN CASE WHEN @dfSumNoPay <= @dfSumPayRasp
                                               THEN @dfSumNoPay / @dfCurTariff
                                               ELSE @dfSumPayRasp / @dfCurTariff 
                                               END 
                                     ELSE 0
                                     END,0)
   SELECT
      @dfSumNDSAft = @dfSumNDSAft + Convert(Decimal(12,2),
      CASE WHEN @dfSumNoPay <= @dfSumPayRasp
           THEN (@dfSumNoPay * @dfCurTaxNDS) / (100.00 + @dfCurTaxNDS)
           ELSE (@dfSumPayRasp * @dfCurTaxNDS) / (100.00 + @dfCurTaxNDS)
           END)
   SELECT @dfSumExcAft = @dfSumExcAft + Sign(@dfSumNoPay) * Round(@iWk * @dfCurTaxExc,2)
   SELECT
      @dfSumEEAft = @dfSumEEAft + Convert(Decimal(12,2),
      CASE WHEN @dfSumNoPay <= @dfSumPayRasp
           THEN @dfSumNoPay
           ELSE @dfSumPayRasp
           END) 
  END
 ELSE
  /*------------------------- 20% - До 2001-07-31----------------------------------------------- */
 BEGIN
   SELECT  @iKVTBefo = @iKVTBefo+Round( CASE WHEN @dfCurTariff <> 0
                                             THEN CASE WHEN @dfSumNoPay <= @dfSumPayRasp
                                                       THEN @dfSumNoPay / @dfCurTariff
                                                       ELSE @dfSumPayRasp / @dfCurTariff 
                                                       END 
                                             ELSE 0
                                             END,0)
   SELECT
      @dfSumNDSBefo=@dfSumNDSBefo + Convert(Decimal(12,2),
      CASE WHEN @dfSumNoPay <= @dfSumPayRasp
           THEN (@dfSumNoPay * @dfCurTaxNDS) / (100.00 + @dfCurTaxNDS)
           ELSE (@dfSumPayRasp * @dfCurTaxNDS) / (100.00 + @dfCurTaxNDS)
      END)
   SELECT
      @dfSumExcBefo = @dfSumExcBefo + Sign(@dfSumNoPay) * Round(@iWk * @dfCurTaxExc,2)
   SELECT
      @dfSumEEBefo = @dfSumEEBefo + Convert(Decimal(12,2),
      CASE  WHEN @dfSumNoPay <= @dfSumPayRasp
            THEN @dfSumNoPay 
            ELSE @dfSumPayRasp
            END)
 END 
END
/*===========================================================================================*/
-- Остаток оплаты
  SELECT @dfSumPayMonth = CASE WHEN @dfSumPayMonth > @dfSumNoPay
                               THEN @dfSumPayMonth - @dfSumNoPay
                               ELSE 0 
                               END
--  Переход к следующему периоду
  IF @siVozvrat = 1 AND @dtPayBeg < @dtCalcEnd
    SELECT @dtPayBeg = @dtCalcEnd
  ELSE
    SELECT @dtPayBeg = DateAdd(dd,-1,DateAdd(mm,1,DateAdd(dd,1,@dtPayBeg)))


  IF @dtPayBeg>@dtCalcEnd
  BEGIN
/*
-----
Print 'Остаток'
Print @dfRest
-----
*/
    BREAK
  END   
END 
END
END
-------------------------------
ELSE 
IF @dfSumPayMonth<0
BEGIN
SELECT @dfSumEEAft=0
-- Пока не обработан весь платёж
---------------------------------------------------
WHILE @dfSumPayMonth <> 0
BEGIN
--  Начисление, тариф на реализацию, ставка НДС, ставка акциза обрабатываемого периода
  SELECT @siExists = Convert(SmallInt, CASE WHEN Exists (SELECT *
                                                         FROM ProCalcs (NOLOCK)
                                                         WHERE CONTRACT_ID = @iContractId AND
                                                               DATE_CALC = @dtPayBeg)
                                            THEN 1
                                            ELSE 0
                                            END)
  
  IF @siExists = 1
  BEGIN
    SELECT @dfCurNach = CASE WHEN  @dtPayBeg = @dtDolgBeg
                             THEN  0
                             ELSE  SUM_FACT + SUM_NDS + SUM_EXC
                             END,
           @dfCurTariff = CASE WHEN QNT_ALL <> 0
                               THEN (SUM_FACT + SUM_NDS + SUM_EXC) / QNT_ALL
                               ELSE @dfCurTariff 
                               END,
           @dfCurTaxNDS = CASE WHEN (@dtPayBeg > '1999-08-01') AND (@dtPayBeg < '2001-02-01')
                               THEN CASE WHEN SUM_FACT <> 0
                                         THEN ROUND((SUM_NDS * 100) / (SUM_FACT),0)
                                         ELSE @dfCurTaxNDS
                                         END
                               ELSE CASE WHEN SUM_FACT <> 0
                                         THEN ROUND((SUM_NDS * 100) / (SUM_FACT + SUM_EXC),0)
                                         ELSE @dfCurTaxNDS 
                                         END
                               END,
           @dfCurTaxExc = Convert(Decimal(12,2), CASE WHEN QNT_ALL <> 0
                                                      THEN (SUM_EXC / QNT_ALL)
                                                      ELSE @dfCurTaxExc 
                                                      END)
     FROM ProCalcs (NOLOCK)
     WHERE CONTRACT_ID = @iContractId AND
           DATE_CALC = @dtPayBeg
  END
  ELSE
  BEGIN
    SELECT @dfCurNach = 0
  END
/*  
Print 'Текущее начисление,тариф,такса НДС,такса акциза'
*/
--  Неоплаченный остаток (первого) обрабатываемого периода
  SELECT @dfSumNoPay = @dfSumRemPay + CASE WHEN @dtPayBeg >= @dtDolgBeg
                                           THEN 0
                                           ELSE @dfCurNach
                                           END +
                                      CASE WHEN @dfSumSaldoBeg < 0
                                           THEN - @dfSumSaldoBeg
                                           ELSE 0
                                           END  
 
  SELECT @dfSumRemPay = 0

--  Количество КВТ в оплате, всего и за обр.период
  SELECT @iKVT = @iKVT - Round(CASE WHEN @dfCurTariff <> 0
                                    THEN CASE WHEN @dfSumNoPay >= 0
                                              THEN CASE WHEN @dfSumNoPay <= ABS(@dfSumPayMonth)
                                                        THEN @dfSumNoPay / @dfCurTariff
                                                        ELSE ABS(@dfSumPayMonth) / @dfCurTariff 
                                                        END
                                              ELSE @dfSumNoPay / @dfCurTariff
                                              END 
                                    ELSE 0
                                    END,0),
    @iWk = Round(CASE WHEN @dfCurTariff <> 0
                      THEN CASE WHEN @dfSumNoPay >= 0
                                THEN CASE WHEN @dfSumNoPay <= ABS(@dfSumPayMonth)
                                          THEN @dfSumNoPay / @dfCurTariff
                                          ELSE ABS(@dfSumPayMonth) / @dfCurTariff 
                                          END
                                ELSE @dfSumNoPay / @dfCurTariff
                                END 
                      ELSE 0
                      END,0)
  
--  Доля НДС в оплате
  SELECT @dfSumNDS = @dfSumNDS -
                     Round(CASE WHEN @dfSumNoPay >= 0
                                THEN CASE WHEN @dfSumNoPay <= ABS(@dfSumPayMonth)
                                          THEN (@dfSumNoPay / (100 + @dfCurTaxNDS)) * @dfCurTaxNDS
                                          ELSE (ABS(@dfSumPayMonth) / (100 + @dfCurTaxNDS)) * @dfCurTaxNDS 
                                          END
                                ELSE (@dfSumNoPay / (100 + @dfCurTaxNDS)) * @dfCurTaxNDS
                                END,2)
--  Доля акциза в оплате
  SELECT
    @dfSumExc = @dfSumExc - Round(@iWk * @dfCurTaxExc,2)
--**************
/*Распределение по %  label 2 ========================================================================= */
IF @dtPayBeg > '2003-12-31'
BEGIN
  SELECT
    @iKVT_15 = @iKVT_15 - Round(CASE WHEN @dfCurTariff <> 0
                                     THEN CASE WHEN @dfSumNoPay >= 0
                                               THEN CASE WHEN @dfSumNoPay <= ABS(@dfSumPayMonth)
                                                         THEN @dfSumNoPay / @dfCurTariff
                                                         ELSE ABS(@dfSumPayMonth) / @dfCurTariff 
                                                         END
                                               ELSE @dfSumNoPay / @dfCurTariff
                                               END 
                                     ELSE 0
                                     END,0)
  SELECT @dfSumNDS_15 = @dfSumNDS_15 - 
                Round(CASE WHEN @dfSumNoPay >= 0
                           THEN CASE WHEN @dfSumNoPay <= ABS(@dfSumPayMonth)
                                     THEN (@dfSumNoPay / (100+@dfCurTaxNDS)) * @dfCurTaxNDS
                                     ELSE (ABS(@dfSumPayMonth)/(100+@dfCurTaxNDS)) * @dfCurTaxNDS 
                                     END
                           ELSE (@dfSumNoPay/(100+@dfCurTaxNDS))*@dfCurTaxNDS
                           END,2)
  
  SELECT @dfSumExc_15 = @dfSumExc_15 - Round(@iWk * @dfCurTaxExc,2)
  SELECT @dfSumEE_15 = @dfSumEE_15 - Round(CASE WHEN @dfSumNoPay <= ABS(@dfSumPayMonth)
                                                THEN @dfSumNoPay
                                                ELSE ABS(@dfSumPayMonth) 
                                                END,2)

END
ELSE
BEGIN
/*--- 16% ----------------------------------------------------------------------------*/
-- old code [dm] IF @dtPayBeg >= '2001-07-31'
IF @dtPayBeg BETWEEN '2001-07-31' and '2003-12-31'
BEGIN
  SELECT
    @iKVTAft = @iKVTAft - Round(CASE WHEN @dfCurTariff <> 0
                                     THEN CASE WHEN @dfSumNoPay >= 0
                                               THEN CASE WHEN @dfSumNoPay <= ABS(@dfSumPayMonth)
                                                         THEN @dfSumNoPay / @dfCurTariff
                                                         ELSE ABS(@dfSumPayMonth) / @dfCurTariff 
                                                         END
                                               ELSE @dfSumNoPay / @dfCurTariff
                                               END 
                                     ELSE 0
                                     END,0)
  SELECT @dfSumNDSAft = @dfSumNDSAft - 
                Round(CASE WHEN @dfSumNoPay >= 0
                           THEN CASE WHEN @dfSumNoPay <= ABS(@dfSumPayMonth)
                                     THEN (@dfSumNoPay / (100+@dfCurTaxNDS)) * @dfCurTaxNDS
                                     ELSE (ABS(@dfSumPayMonth)/(100+@dfCurTaxNDS)) * @dfCurTaxNDS 
                                     END
                           ELSE (@dfSumNoPay/(100+@dfCurTaxNDS))*@dfCurTaxNDS
                           END,2)
  
  SELECT @dfSumExcAft = @dfSumExcAft - Round(@iWk * @dfCurTaxExc,2)
  SELECT @dfSumEEAft = @dfSumEEAft - Round(CASE WHEN @dfSumNoPay <= ABS(@dfSumPayMonth)
                                                THEN @dfSumNoPay
                                                ELSE ABS(@dfSumPayMonth) 
                                                END,2)

END
/*  20% -----------------------------------------------------------------------------*/
ELSE
BEGIN
  SELECT
    @iKVTBefo = @iKVTBefo - Round(CASE WHEN @dfCurTariff <> 0
                                       THEN CASE WHEN @dfSumNoPay >= 0
                                                 THEN CASE WHEN @dfSumNoPay <= ABS(@dfSumPayMonth)
                                                           THEN @dfSumNoPay / @dfCurTariff
                                                           ELSE ABS(@dfSumPayMonth) / @dfCurTariff 
                                                           END
                                                 ELSE @dfSumNoPay / @dfCurTariff
                                                 END 
                                       ELSE 0
                                       END,0)
  SELECT @dfSumNDSBefo = @dfSumNDSBefo - 
                           Round(CASE WHEN @dfSumNoPay >= 0
                                      THEN CASE WHEN @dfSumNoPay <= ABS(@dfSumPayMonth)
                                                THEN (@dfSumNoPay / (100 + @dfCurTaxNDS)) * @dfCurTaxNDS
                                                ELSE (ABS(@dfSumPayMonth) / (100+@dfCurTaxNDS)) * @dfCurTaxNDS 
                                                END
                                      ELSE (@dfSumNoPay / (100 + @dfCurTaxNDS)) * @dfCurTaxNDS
                                      END,2)
  
  SELECT @dfSumExcBefo = @dfSumExcBefo - Round(@iWk * @dfCurTaxExc,2)
  SELECT @dfSumEEBefo = @dfSumEEBefo - Round(CASE WHEN @dfSumNoPay <= ABS(@dfSumPayMonth)
                                                  THEN @dfSumNoPay
                                                  ELSE ABS(@dfSumPayMonth) 
                                                  END,2)
END
END 
/*==================================================================================================*/
--**************  
-- Остаток оплаты
  SELECT @dfSumPayMonth = CASE WHEN @dfSumNoPay >= 0
                               THEN CASE WHEN ABS(@dfSumPayMonth) > @dfSumNoPay
                                         THEN @dfSumPayMonth + @dfSumNoPay
                                         ELSE 0
                                         END
                               ELSE @dfSumPayMonth + @dfSumNoPay
                               END
  
--  Переход к следующему периоду
  SELECT @dtPayBeg = DateAdd(dd,-1,DateAdd(mm,-1,DateAdd(dd,1,@dtPayBeg)))
  IF @dtPayBeg <= '1998-07-01'
  BEGIN
  BREAK
  END
END 
END
-------------------------------  
--Завершение расчёта 
-------------------------------  
SELECT @dfCurTariff = CASE WHEN  IsNull(@dfCurTariff,0) = 0
                           THEN  3.95
                           ELSE  IsNull(@dfCurTariff,0)
                           END               
SELECT @dfSaldoCR =
      CASE WHEN @dfRest-(CASE WHEN @dfSumSaldoEnd < 0
                              THEN @dfSumSaldoEnd
                              ELSE 0 END) <0
           THEN -(@dfRest-(CASE WHEN @dfSumSaldoEnd < 0
                                THEN @dfSumSaldoEnd
                                ELSE 0
                                END))
           ELSE CASE WHEN @dfSumEE + @dfSumNDS + @dfSumExc = @dfSumEE
                     THEN @dfSumEE
                     ELSE 0  
                     END
           END
SELECT @iKVTCR=Round(CASE WHEN @dfCurTariff <> 0
                          THEN @dfSaldoCR / @dfCurTariff
                          ELSE 0
                          END,0)
SELECT @dfSumNDSCR = CASE WHEN @dfTaxNDSCR <> 0
                          THEN Round((@dfSaldoCR / (100 + @dfTaxNDSCR)) * @dfTaxNDSCR,2)
                          ELSE 0
                          END
SELECT @dfSumExcCR = Round(@iKVTCR * @dfCurTaxExc,2)
SELECT @dfSumEECR = Round(@dfSaldoCR - @dfSumNDSCR - @dfSumExcCR,2)
SELECT @dfSumEE = @dfSumEE - @dfSumNDS - @dfSumExc

--Print '2'
--Print @dfSumEE

/*---------------------------Прверка Итого= --------------------------------------------*/

IF @dfSumEEBefo  = 0 AND
   @dfSumNDSBefo = 0 AND
   @dfSumExcBefo = 0 AND
   @iKVTBefo     = 0 AND

   @dfSumEEAft  = 0 AND
   @dfSumNDSAft = 0 AND
   @dfSumExcAft = 0 AND
   @iKVTAft     = 0
BEGIN
  IF @dfSumNDS <> @dfSumNDS_15 + @dfSumNDSAft + @dfSumNDSBefo
  BEGIN
    Print '###'
    SELECT @dfSumNDS_15 = @dfSumNDS 
  END
  IF @dfSumExc <> @dfSumExc_15 + @dfSumExcAft + @dfSumexcBefo
  BEGIN
    Print '###'
    SELECT @dfSumExc_15 = @dfSumExc 
  END
  IF @dfSumEE <> @dfSumEE_15 + @dfSumEEAft + @dfSumEEBefo
  BEGIN
--    Print '@dfSumEE = '
--    Print @dfSumEE
--    Print '@dfSumEE_15 = '
--    Print @dfSumEE_15
    Print '###'  
    SELECT @dfSumEE_15 = @dfSumEE + @dfSumNDS_15 + @dfSumExc_15
  END
END
/*--------------------------------------------------------------------------------------*/
IF Exists
 (SELECT
    *
   FROM #ProDivPaymentSum (NOLOCK)
   WHERE CONTRACT_ID = @iContractId AND
         DATE_CALC = @dtCalcEnd)
  UPDATE #ProDivPaymentSum
   SET
    SUM_EE_B    = @dfSumEEBefo-@dfSumNDSBefo-@dfSumExcBefo,
    SUM_NDS_B   = @dfSumNDSBefo,
    SUM_EXC_B   = @dfSumExcBefo,
    QUANTITY_B  = @iKVTBefo,
    SUM_EE_A    = @dfSumEEAft-@dfSumNDSAft-@dfSumExcAft,
    SUM_NDS_A   = @dfSumNDSAft,
    SUM_EXC_A   = @dfSumExcAft,
    QUANTITY_A  = @iKVTAft,
    ------------------------------------------------
    SUM_EE_15   = @dfSumEE_15-@dfSumNDS_15-@dfSumExc_15,
    SUM_NDS_15  = @dfSumNDS_15,
    SUM_EXC_15  = @dfSumExc_15,
    QUANTITY_15 = @iKVT_15,
    ------------------------------------------------
    SUM_EE      = @dfSumEE,
    SUM_NDS     = @dfSumNDS,
    SUM_EXC     = @dfSumExc,
    QUANTITY    = @iKVT,
    SALDOCR     = @dfSaldoCR,
    SUM_EECR    = @dfSumEECR,
    SUM_NDSCR   = @dfSumNDSCR,
    SUM_EXCCR   = @dfSumExcCR,
    QUANTITYCR  = @iKVTCR,
    SUM_PAY     = @dfSumEE+@dfSumNDS+@dfSumExc,
    COMMENT     = Convert(VarChar(10),@dtPayBeg,120)+'/'+Convert(VarChar(15),@dfSumEE+@dfSumNDS+@dfSumExc)
   WHERE
    CONTRACT_ID = @iContractId AND
    DATE_CALC   = @dtCalcEnd  
ELSE
  INSERT
    #ProDivPaymentSum
   (CONTRACT_ID,
    DATE_CALC,
    SUM_EE_B,
    SUM_NDS_B,
    SUM_EXC_B,
    QUANTITY_B,
    SUM_EE_A,
    SUM_NDS_A,
    SUM_EXC_A,
    QUANTITY_A,
    -----------------------------
    SUM_EE_15,
    SUM_NDS_15,
    SUM_EXC_15,
    QUANTITY_15,
    -----------------------------
    SUM_EE,
    SUM_NDS,
    SUM_EXC,
    QUANTITY,
    SALDOCR,
    SUM_EECR,
    SUM_NDSCR,
    SUM_EXCCR,
    QUANTITYCR,
    SUM_PAY,
    COMMENT)
   VALUES
   (@iContractId,
    @dtCalcEnd,
    @dfSumEEBefo-@dfSumNDSBefo-@dfSumExcBefo,
    @dfSumNDSBefo,
    @dfSumExcBefo,
    @iKVTBefo,
    @dfSumEEAft-@dfSumNDSAft-@dfSumExcAft,
    @dfSumNDSAft,
    @dfSumExcAft,
    @iKVTAft,
    -------------------
    @dfSumEE_15-@dfSumNDS_15-@dfSumExc_15,
    @dfSumNDS_15,
    @dfSumExc_15,
    @iKVT_15,
    -------------------
    @dfSumEE,
    @dfSumNDS,
    @dfSumExc,
    @iKVT,
    @dfSaldoCR,
    @dfSumEECR,
    @dfSumNDSCR,
    @dfSumExcCR,
    @iKVTCR,
    (@dfSumEE+@dfSumNDS+@dfSumExc),
    Convert(VarChar(10),@dtPayBeg,120)+'/'+Convert(VarChar(15),@dfSumEE+@dfSumNDS+@dfSumExc))
    
RETURN
GO

select *
/*SUM_EE_B,
    SUM_NDS_B,
    SUM_EXC_B,
    QUANTITY_B,
    SUM_EE_A,
    SUM_NDS_A,
    SUM_EXC_A,
    QUANTITY_A,
    SUM_EE_15,
    SUM_NDS_15,
    SUM_EXC_15,
    QUANTITY_15,
    SUM_EE,
    SUM_NDS,
    SUM_EXC,
    QUANTITY */
 from  #ProDivPaymentSum

drop table #ProDivPaymentSum