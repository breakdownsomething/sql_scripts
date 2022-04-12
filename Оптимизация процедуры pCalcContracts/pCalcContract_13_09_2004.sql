SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO



--DROP PROCEDURE pCalcContract  
ALTER   PROCEDURE dbo.pCalcContract
  @iContractId      Int,  --(код контракта=CONTRACT_ID из ProContracts)   
  @siCalcStatus SmallInt, --(статус=0 -расчёт по показаниям, статус=1 -расчет по среднему)
  @siUserId     SmallInt  --(код пользователя=USER_ID из Users)
AS
/****************************************************************************
Наименование:	pCalcContract
Текущая версия:	v 1.008
Назначение:	Расчёт начислений за электроэнергию по договору с юр. лицом 
Дата создания:	21.11.2002 (v 1.007)
Разработал:	Солдатов Владимир Александрович, специалист 1кат. ДРППО
-------------------------------------------------------------------------------------------------------------------
Дата* модификации:	22.01.2003 (v 1.008)
Цель модификации:	Изменение алгоритма расчёта НДС для допсумм текущего периода
Модифицировал:		Солдатов Владимир Александрович, специалист 1кат. ДРППО
-------------------------------------------------------------------------------------------------------------------
Дата модификации:	06.06.2003 (v 1.009)
Цель модификации:	Изменение состава полей запоминаемых в таблице результатов 
                        по договору (ProCalcs(CONTRACT_DATE_PAY, AGREEMENT_DATE_PAY,
                        ADD_COST_TAX, EXCISE_TAX)), расчет акциза и НДС по запоминаемым
                        ставкам 
Модифицировал:		Солдатов Владимир Александрович, специалист 1кат. ДРППО
-----------------------------------------------------------------------------------------------------
Дата модификации:	18.08.2004 (v 1.01)
Цель модификации:	Учет расчета потерь в трансыорматорах из таблицы ProTrancPowerLoss
Модифицировал:		Матесов Д.
-----------------------------------------------------------------------------------------------------
Дата модификации:	23.08.2004 (v 1.011)
Цель модификации:	Частичная оптимизация. Отказ  от конструкций "select ... into"
                  и объединение update-ов таблицы ProCalcs при обработке
                  доп сумм за текущий и др. периоды.
Модифицировал:		Матесов Д.
------------------------------------------------------------------------------------------
Дата модификации:	27.08.2004 (v 1.011)
Цель модификации:	Перенос начала транзакции из начала процедуры к фрагменту,
                  где начинается занесение данных в таблицу ProCalcs. Сдклано 
                  для уменьшения количества блокировок при одновременном
                  запуске процедуры большим кол-вом пользователей.
Модифицировал:		Матесов Д.
-------------------------------------------------------------------------------------------
Дата модификации:	8.09.2004 
Цель модификации:	ИСправление ошибок
Модифицировал:		Матесов Д.
****************************************************************************/

DECLARE   -- Код завершения
  @iRTC            Integer

DECLARE -- рабочие переменные
  @iAbonentId       Int,
  @tiAbonentTypeId  TinyInt,
  @tiAbonentGroupId TinyInt,
  @iAccountId       Integer,
  @iAccountOwnerId  Int,
  @tiActivePowerId  TinyInt,
  @tiActivPDecodeId TinyInt,
  @dfAddCostTax     Decimal(18,2),
  @tiAddDecodeId    TinyInt,
  @iAddHCP          Integer,
  @iAddQnt          Integer,
  @iAddQuantity     Integer,
  @dfAdvance        Decimal(18,2),
  @siAdvanceId      SmallInt,
  @dfAdvanceNew     Decimal(18,2),
  @dfAdvanceOld     Decimal(18,2),
  @sdtAgreementDatePay SmallDateTime,
  @iAllQuantity     Integer,
  @siAuditGroupId   SmallInt,
  @tiAuditMethodId  TinyInt,
  @tiAuditTypeId    TinyInt,
  @tiAuditParamId   TinyInt,
  @iBankId          Integer,
  @tiBurningGroupId TinyInt,
  @dtCalcBegin      SmallDateTime,
  @iCalcDetailId    Int,
  @dtCalcEnd        SmallDateTime,
  @dfCalcFactor     Decimal(18,2),
  @iCalcId          Integer,
  @vcCalcNumber     VarChar(20),
  @iCalcQuantity    Integer,
  @siCalcSign       SmallInt,
  @tiCalcSignFact   TinyInt,
  @tiCalcTypeId     TinyInt,
  @dfCapacity       Decimal(9,2),
  @vcComment        VarChar(40),
  @siConsumerGroupId SmallInt,
  @tiContractDatePay TinyInt,
  @vcContractNumber VarChar(10),
  @siCounterTypeId  SmallInt,
  @tiCountMethodId  TinyInt,
  @siCountPart      SmallInt,
  @siCurDay         SmallInt,
  @dtCurDay         DateTime,
  @dtDateContract   DateTime,
  @dtDateContractClose DateTime,
  @dtDateId         SmallDateTime,
  @dfDayHours       Decimal(4,2),
  @tiDecodeId       TinyInt,
  @tiDistrId        TinyInt,
  @iEditCount       Integer,
  @iEditCountBegin  Integer,
  @dfExciseTax      Decimal(12,2),
  @vcFactoryNumber  VarChar(12),
  @siFirstGroupId   SmallInt,
  @siFreeDay        Smallint,
  @siGroupId        SmallInt,
  @siGroupSign      SmallInt,
  @dfIncrease       Decimal(9,2),
  @dfIncr           Decimal(9,2),
  @vcIndexF24Id     VarChar(5),
  @vcKnotOut        VarChar(10),
  @vcKnotMain       VarChar(5),
  @tiKBtMeasureId   TinyInt,
  @tiKBt_ChMeasureId TinyInt,
  @tiLegalDeviation TinyInt,
  @siLimitId        SmallInt,
  @dfMaxTariffValue Decimal(18,10),
  @tiMeasureId      TinyInt,
  @iMinistryId      Integer,
  @dfMinTariffValue Decimal(18,10),
  @siMonth          SmallInt,
  @siMonthHours     SmallInt,
  @iNodeId          Integer,
  @tiPartMethodId   TinyInt,

  @dfPercent        Decimal(18,2),
  @iPower           Integer,
  @tiPowerGroupId   TinyInt,
  @iPowRea          Integer,
  @iQuaAddSum       Integer,
  @iPQuantity       Integer,
  @iQntRea          Integer,
  @iQPowRea         Integer,
  @iQuantity        Integer,
  @siQuarter        SmallInt,
  @tiReActivePowerId TinyInt,
  @iRemainder       Integer,
  @dfSaldo          Decimal(18,2),
  @dfSaldoPeni      Decimal(18,2),
  @tiSectionId      TinyInt,
  @tiServId         TinyInt,
  @siServId         SmallInt,
  @tiSignLock       TinyInt,
  @siSignLock       SmallInt,
  @bSignNumerationSF Bit,
  @siSignRea        SmallInt,
  @iSourceId        Integer,
  @vcStamp          VarChar(25),
  @tiStatus         TinyInt,
  @tiSubstationTypeId TinyInt,
  @siSubstationId   VarChar(10),
  @iSumAccount      Integer,
  @dfSumAdd         Decimal(18,2),
  @dfSumAddA        Decimal(18,2),
  @dfSumAddB        Decimal(18,2),
  @dfSumAddCostTax  Decimal(18,2),
  @dfSumAddCostTaxA Decimal(18,2),
  @dfSumAddCostTaxB Decimal(18,2),
  @dfSumAddExcise   Decimal(18,2),
  @dfSumAddNDS      Decimal(18,2),
  @dfSumCalc        Decimal(18,2),
  @dfSumCapacity    Decimal(18,2),
  @dfSumCount       Decimal(18,2),
  @dfSumExcise      Decimal(18,2),
  @dfSumFact        Decimal(12,2),
  @dfSumPeni        Decimal(18,2),
  @dfSumPercent     Decimal(12,2),
  @dfSumReactive    Decimal(18,2),
  @dfSumSaldo       Decimal(18,2),
  @iTariffId        Integer,
  @vcTariffGroupId  VarChar(5),
  @dfTariffValue    Decimal(18,10),
  @iTarMaxReaId     Integer,
  @iTarMinReaId     Integer,
  @dfTotalCapacity  Decimal(18,2),
  @siUnionPayerId   SmallInt,
  @iUnitedContractId Integer,
  @vcUseHour        VarChar(5),
  @siWeekDay        SmallInt,
  @iYear            Integer

---
SELECT @iRTC=0
---
SET NOCOUNT ON

SELECT @vcStamp=Convert(VarChar(25),'/'+Right(Str(@siUserId+1000),3)+'/'+Convert(Char(20),GetDate(),113))

Print '*Start*'
-- BEGIN TRANSACTION
-- Начало транзакции перенесено


------------------------------------------------------------
-- Определение значений переменных
------------------------------------------------------------
SELECT
-- ProGroups
  @siGroupId           = G.GROUP_ID,
  @dtCalcBegin         = G.DATE_CALC_BEGIN,
  @dtCalcEnd           = G.DATE_CALC_END,
  @bSignNumerationSF   = G.SIGN_NUMERATION_SF,
-- ProContracts
  @iAbonentId          = Cn.ABONENT_ID,
--  @iContractId=Cn.CONTRACT_ID,
  @vcContractNumber    = Cn.CONTRACT_NUMBER,
  @dtDateContract      = Cn.DATE_CONTRACT,
  @dtDateContractClose = Cn.DATE_CONTRACT_CLOSE,
  @tiAbonentTypeId     = Cn.ABONENT_TYPE_ID,
  @tiAbonentGroupId    = Cn.ABONENT_GROUP_ID,
  @siUnionPayerId      = Cn.UNION_PAYER_ID,
  @siConsumerGroupId   = Cn.CONSUMER_GROUP_ID,
  @siLimitId           = Cn.LIMIT_ID,
  @dfTotalCapacity     = Cn.TOTAL_CAPACITY,
  @dfAddCostTax        = Cn.ADD_COST_TAX,
  @dfAdvance           = Cn.ADVANCE,
  @siAdvanceId         = Cn.ADVANCE_ID,
  @dfSaldo             = Cn.SALDO,
  @dfSumSaldo          = Cn.SUM_SALDO,
  @dfSaldoPeni         = Cn.SALDO_PENI,
  @iUnitedContractId   = Cn.UNITED_CONTRACT_ID,
  @tiContractDatePay   = Cn.CONTRACT_DATE_PAY,
  @sdtAgreementDatePay = Cn.AGREEMENT_DATE_PAY,
  @tiDistrId           = Ab.DISTR_ID,
  @iBankId             = Ab.BANK_ID,
  @iMinistryId         = Ab.MINISTRY_ID
 FROM
  ProContracts Cn (NoLock),
  ProAbonents Ab (NoLock),
  ProGroups G (NoLock)
 WHERE
  Cn.CONTRACT_ID = @iContractId  AND
  Ab.ABONENT_ID  = Cn.ABONENT_ID AND
  G.GROUP_ID     = Cn.GROUP_ID

SELECT
  @siMonth   = DATEPART(Month,@dtCalcBegin),
  @siQuarter = DATEPART(Quarter,@dtCalcBegin),
  @iYear     = DATEPART(Year,@dtCalcBegin),
  @dfCalcFactor = 0

Print '*Month='
Print @siMonth
Print '*Quarter='
Print @siQuarter
Print '*Year='
Print @iYear

SELECT
  @iCalcId = IsNull((SELECT CALC_ID
                     FROM   ProCalcs (NoLock)
                     WHERE  CONTRACT_ID = @iContractId
                        AND DATE_CALC   = @dtCalcEnd),0)
Print '*CALC_ID='
Print @iCalcId

SELECT @tiServId = CONVERT(TinyInt,MIN(SERV_ID))
  FROM ServiceTypes
 WHERE SERV_NAME='Электроэнергия'

Print '*Электроэнергия='
Print @tiServId

SELECT
  @tiAddDecodeId    = (SELECT MAX(DECODE_ID)
                       FROM ProDecode (NoLock)
                       WHERE DECODE_NAME = 'Доп.сумма'),
  @tiActivPDecodeId = (SELECT MAX(DECODE_ID)
                       FROM ProDecode (NoLock)
                       WHERE DECODE_NAME='За активную энергию')

Print '*Доп.сумма='
Print @tiAddDecodeId
Print '*За активную энергию='
Print @tiActivPDecodeId

SELECT  @tiCountMethodId = (SELECT MAX(AUDIT_METHOD_ID)
                            FROM ProAuditMethods (NoLock)
                            WHERE AUDIT_METHOD_NAME='Учет по счетчику'),
        @tiPartMethodId  = (SELECT MAX(AUDIT_METHOD_ID)
                            FROM ProAuditMethods (NoLock)
                            WHERE AUDIT_METHOD_NAME = 'Долевой учет')

Print '*Учет по счетчику='
Print @tiCountMethodId
Print '*Долевой учет='
Print @tiPartMethodId

SELECT
  @tiActivePowerId   = (SELECT MAX(POWER_GROUP_ID)
                        FROM ProPowerGroups (NoLock)
                        WHERE POWER_GROUP_NAME = 'Активная'),
  @tiReActivePowerId = (SELECT MAX(POWER_GROUP_ID)
                        FROM ProPowerGroups (NoLock)
                        WHERE POWER_GROUP_NAME='Реактивная')

Print '*Активная='
Print @tiActivePowerId
Print '*Реактивная='
Print @tiReActivePowerId

SELECT
    @tiKBtMeasureId    = (SELECT MAX(MEASURE_ID)
                          FROM MeasureItems (NoLock)
                          WHERE MEASURE_NAME = 'кВт'),
    @tiKBt_ChMeasureId = (SELECT MAX(MEASURE_ID)
                          FROM MeasureItems (NoLock)
                          WHERE MEASURE_NAME='кВт.ч')
Print '*кВт='
Print @tiKBtMeasureId
Print '*кВт.ч='
Print @tiKBt_ChMeasureId

-----------------------------------------------------------------
-- Создание и заполнение временных таблиц
-----------------------------------------------------------------
IF Exists (SELECT * FROM TempDB..SysObjects WHERE id = OBJECT_ID('TempDB..#TmpTVal'))
  DROP TABLE #TmpTval
---------------------------------------------------
-- Заменено при оптимизации (Матесов Д, 19.08.2004)
---------------------------------------------------
create table #TmpTVal
(
 [TARIFF_ID]       [int] NOT NULL PRIMARY KEY,
 [TARIFF_NAME]     [varchar] (40) COLLATE SQL_Latin1_General_CP1251_CI_AS NOT NULL ,
 [MEASURE_ID]      [tinyint] NOT NULL ,
 [TARIFF_GROUP_ID] [varchar] (5)  COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
 [TARIFF_VALUE]    decimal(9,4) 
)

insert into #TmpTVal
SELECT
  T.TARIFF_ID,
  T.TARIFF_NAME,
  T.MEASURE_ID,
  T.TARIFF_GROUP_ID,
  TV.TARIFF_VALUE
 FROM
  ProTariffs T (NoLock),
  ProTariffValues TV (NoLock)
 WHERE
  T.SERV_ID    = @tiServId   AND
  TV.SERV_ID   = T.SERV_ID   AND
  TV.TARIFF_ID = T.TARIFF_ID AND
  TV.DATE_CALC = (SELECT MAX(V.DATE_CALC)
                  FROM ProTariffValues V (NoLock)
                  WHERE V.SERV_ID   = @tiServId    AND
                        V.TARIFF_ID = TV.TARIFF_ID AND
                        V.DATE_CALC<= @dtCalcEnd )

-- Старый код
/*
SELECT
  T.TARIFF_ID,
  T.TARIFF_NAME,
  T.MEASURE_ID,
  T.TARIFF_GROUP_ID,
  TV.TARIFF_VALUE
 INTO #TmpTVal
 FROM
  ProTariffs T (NoLock),
  ProTariffValues TV (NoLock)
 WHERE
  T.SERV_ID=@tiServId AND
  TV.SERV_ID=T.SERV_ID AND
  TV.TARIFF_ID=T.TARIFF_ID AND
  TV.DATE_CALC=
   (SELECT MAX(V.DATE_CALC)
     FROM ProTariffValues V (NoLock)
     WHERE
      V.SERV_ID=@tiServId AND
      V.TARIFF_ID=TV.TARIFF_ID AND
      V.DATE_CALC<=@dtCalcEnd)
ALTER TABLE
  #TmpTVal
 ADD PRIMARY KEY (TARIFF_ID)
*/
-----------------------------------------------
IF Exists (SELECT * FROM TempDB..SysObjects WHERE id = OBJECT_ID('TempDB..#TmpPnt'))
  DROP TABLE #TmpPnt
---------------------------------------------------
-- Заменено при оптимизации (Матесов Д, 19.08.2004)
-- пока работает только из аналайзера,
-- из программы выдает ошибку.
---------------------------------------------------
/*
CREATE TABLE #TmpPnt (
	[ACCOUNT_ID] [int] NOT NULL ,
	[CONTRACT_ID] [int] NOT NULL ,
	[ACCOUNT_NAME] [varchar] (40) NULL ,
	[ADDRESS] [varchar] (40) NULL ,
	[AUDIT_TYPE_ID] [tinyint] NOT NULL ,
	[AUDIT_PARAM_ID] [tinyint] NOT NULL ,
	[AUDIT_METHOD_ID] [tinyint] NOT NULL ,
	[POWER_GROUP_ID] [tinyint] NOT NULL ,
	[BURNING_GROUP_ID] [tinyint] NULL ,
	[USE_HOUR] [varchar] (5) NULL ,
	[CALC_FACTOR] [decimal](9, 2) NOT NULL ,
	[LEGAL_DEVIATION] [tinyint] NOT NULL ,
	[ACCOUNT_OWNER_ID] [int] NOT NULL ,
	[TARIFF_ID] [int] NULL ,
	[STREET_ID] [smallint] NULL ,
	[HOUSE_ID] [varchar] (20) NULL ,
	[FLAT_ID] [varchar] (10) NULL ,
	[KNOT_MAIN] [varchar] (5) NULL ,
	[KNOT_OUT] [varchar] (12) NULL ,
	[SUBSTATION_TYPE_ID] [tinyint] NULL ,
	[SUBSTATION_ID] [varchar] (10) NULL ,
	[SECTION_ID] [tinyint] NULL ,
	[INDEX_F24_ID] [varchar] (5) NULL ,
	[CAPACITY] [decimal](9, 2) NULL ,
	[NODEID] [int] NULL ,
	[TRANC_POWER_ID] [int] NULL ,
	[TRANC_POWER_ACCOUNT_ID] [int] NULL ,
	[TRANC_POWER_METHOD_ID] [tinyint] NULL ,
	[AUDIT_METHOD_NAME] [varchar] (40) NOT NULL ,
	[AUDIT_PARAM_NAME] [varchar] (40) NOT NULL ,
	[AUDIT_TYPE_NAME] [varchar] (40) NOT NULL ,
	[FACTORY_NUMBER] [varchar] (12) NOT NULL 
) ON [PRIMARY]

insert into #TmpPnt
 (ACCOUNT_ID,
  CONTRACT_ID, 
  ACCOUNT_NAME,
  ADDRESS,
  AUDIT_TYPE_ID, 
  AUDIT_PARAM_ID, 
  AUDIT_METHOD_ID, 
  POWER_GROUP_ID, 
  BURNING_GROUP_ID, 
  USE_HOUR, 
  CALC_FACTOR, 
  LEGAL_DEVIATION, 
  ACCOUNT_OWNER_ID, 
  TARIFF_ID, 
  STREET_ID, 
  HOUSE_ID, 
  FLAT_ID, 
  KNOT_MAIN, 
  KNOT_OUT, 
  SUBSTATION_TYPE_ID,
  SUBSTATION_ID,
  SECTION_ID,
  INDEX_F24_ID,
  CAPACITY, 
  NODEID, 
  TRANC_POWER_ID,
  TRANC_POWER_ACCOUNT_ID, 
  TRANC_POWER_METHOD_ID, 
  AUDIT_METHOD_NAME, 
  AUDIT_PARAM_NAME, 
  AUDIT_TYPE_NAME, 
  FACTORY_NUMBER
)

SELECT
A.ACCOUNT_ID,
A.CONTRACT_ID,
A.ACCOUNT_NAME,
A.ADDRESS, 
A.AUDIT_TYPE_ID, 
A.AUDIT_PARAM_ID, 
A.AUDIT_METHOD_ID, 
A.POWER_GROUP_ID, 
A.BURNING_GROUP_ID, 
A.USE_HOUR, 
A.CALC_FACTOR, 
A.LEGAL_DEVIATION, 
A.ACCOUNT_OWNER_ID, 
A.TARIFF_ID, 
A.STREET_ID,
A.HOUSE_ID, 
A.FLAT_ID, 
A.KNOT_MAIN, 
A.KNOT_OUT, 
A.SUBSTATION_TYPE_ID, 
A.SUBSTATION_ID, 
A.SECTION_ID, 
A.INDEX_F24_ID, 
A.CAPACITY, 
A.NODEID, 
A.TRANC_POWER_ID, 
A.TRANC_POWER_ACCOUNT_ID, 
A.TRANC_POWER_METHOD_ID, 
AM.AUDIT_METHOD_NAME,
AP.AUDIT_PARAM_NAME,
AT.AUDIT_TYPE_NAME,
FACTORY_NUMBER = ISNULL(CC.FACTORY_NUMBER,' - нет-')
 FROM
  ProAccounts A (NoLock),
  ProCntCounts CC (NoLock),
  ProAuditMethods AM (NoLock),
  ProAuditParams AP (NoLock),
  ProAuditTypes AT (NoLock)
 WHERE
  A.CONTRACT_ID=@iContractId AND
  CC.ACCOUNT_ID=*A.ACCOUNT_ID AND
  CC.DATE_ID=@dtCalcEnd AND
  AM.AUDIT_METHOD_ID=A.AUDIT_METHOD_ID AND
  AP.AUDIT_PARAM_ID=A.AUDIT_PARAM_ID AND
  AT.AUDIT_TYPE_ID=A.AUDIT_TYPE_ID
*/ 

-- Старый код

SELECT
  A.*,
  AM.AUDIT_METHOD_NAME,
  AP.AUDIT_PARAM_NAME,
  AT.AUDIT_TYPE_NAME,
  FACTORY_NUMBER=ISNULL(CC.FACTORY_NUMBER,' - нет-')
 INTO #TmpPnt
 FROM
  ProAccounts A (NoLock),
  ProCntCounts CC (NoLock),
  ProAuditMethods AM (NoLock),
  ProAuditParams AP (NoLock),
  ProAuditTypes AT (NoLock)
 WHERE
  A.CONTRACT_ID=@iContractId AND
  CC.ACCOUNT_ID=*A.ACCOUNT_ID AND
  CC.DATE_ID=@dtCalcEnd AND
  AM.AUDIT_METHOD_ID=A.AUDIT_METHOD_ID AND
  AP.AUDIT_PARAM_ID=A.AUDIT_PARAM_ID AND
  AT.AUDIT_TYPE_ID=A.AUDIT_TYPE_ID
ALTER TABLE
  #TmpPnt
  ADD PRIMARY KEY (ACCOUNT_ID)

-----------------------------------------------------

SELECT @dfIncrease = IsNull((SELECT QUANTITY
                             FROM  ProYearGraph (NoLock)
                             WHERE CONTRACT_ID = @iContractId
                               AND MONTH        = Month(@dtCalcEnd)),1)
---------------------------------------------------------------------------------
-- Создание и заполнение временной таблицы #TmpPQua
---------------------------------------------------------------------------------
IF Exists  (SELECT *  FROM TempDB..SysObjects  WHERE id = OBJECT_ID('TempDB..#TmpPQua') )
  DROP TABLE #TmpPQua

CREATE TABLE #TmpPQua
  (ACCOUNT_ID Integer,
   QUANTITY   Integer)

INSERT INTO #TmpPQua (ACCOUNT_ID, QUANTITY)
 SELECT
   A.ACCOUNT_ID,
   QUANTITY = IsNull(ROUND((ISNULL(CC.QUANTITY,0)*@dfIncrease*
                                  (DATEDIFF(dd,@dtCalcBegin,@dtCalcEnd)+1)/
                                  (DATEDIFF(dd,DATEADD(mm,-1,@dtCalcBegin),DATEADD(dd,-1,@dtCalcBegin))+1))
                                  /A.CALC_FACTOR,0),0)*A.CALC_FACTOR
  FROM
   ProCntCounts CC (NoLock),
   #TmpPnt      A  (NoLock)
  WHERE
   CC.ACCOUNT_ID=*A.ACCOUNT_ID AND
   CC.DATE_ID=DATEADD(dd,-1,@dtCalcBegin)AND
   A.POWER_GROUP_ID=@tiActivePowerId AND
   A.AUDIT_METHOD_ID=@tiCountMethodId

INSERT INTO #TmpPQua (ACCOUNT_ID, QUANTITY)
 SELECT
   A.ACCOUNT_ID,
   QUANTITY =IsNull(ROUND((ISNULL(CC.QUANTITY,0)*@dfIncrease)
                         /A.CALC_FACTOR,0),0)*A.CALC_FACTOR
  FROM
   ProCntCounts CC (NoLock),
   #TmpPnt A (NoLock)
  WHERE
   CC.ACCOUNT_ID=*A.ACCOUNT_ID AND
   CC.DATE_ID=DATEADD(dd,-1,(DATEADD(mm,-2,@dtCalcBegin))) AND
   A.POWER_GROUP_ID=@tiReActivePowerId AND
   A.AUDIT_METHOD_ID=@tiCountMethodId

INSERT
 INTO #TmpPQua (ACCOUNT_ID, QUANTITY)
 SELECT
   A.ACCOUNT_ID,
   QUANTITY = ISNULL(CC.QUANTITY,0)*@dfIncrease
  FROM
   ProCntCounts CC (NoLock),
   #TmpPnt A (NoLock)
  WHERE
   CC.ACCOUNT_ID=*A.ACCOUNT_ID AND
   CC.DATE_ID=DATEADD(dd,-1,@dtCalcBegin)AND
   A.AUDIT_METHOD_ID<>@tiCountMethodId

---------------------------------------------------------------------------------
-- Создание временной таблицы #TmpCalc
---------------------------------------------------------------------------------

IF Exists (SELECT * FROM TempDB..SysObjects WHERE id = OBJECT_ID('TempDB..#TmpCalc'))
  DROP TABLE #TmpCalc

CREATE TABLE
  #TmpCalc
  (CALC_NUMBER VarChar(20),
   CALC_TYPE_ID TinyInt Null,
   TARIFF_ID Integer Null,
   TARIFF_VALUE Decimal(9,4) Null,
   CALC_QUANTITY Integer Null,
   SUM_CALC Decimal(12,2) Null,
   MEASURE_ID TinyInt Null,
   CALC_SIGN_FACT TinyInt,
   SOURCE_ID  Integer,
   DECODE_ID TinyInt Null,
   COMMENT VarChar(40) Null,
   TARIFF_GROUP_ID VarChar(5) Null,
   EDIT_COUNT_BEGIN Integer Null,
   EDIT_COUNT Integer Null,
   ADD_QUANTITY Integer Null,
   STATUS TinyInt Null,
   FACTORY_NUMBER VarChar(12) Null,
   COUNTER_TYPE_ID SmallInt Null,
   AUDIT_METHOD_ID TinyInt Null,
   CALC_FACTOR Decimal(9,2)Null,
   CAPACITY Decimal(9,2) Null,
   KNOT_OUT VarChar(10) Null,
   KNOT_MAIN VarChar(5) Null,
   SUBSTATION_TYPE_ID TinyInt Null,
   SUBSTATION_ID VarChar(10) Null,
   SECTION_ID TinyInt Null,
   INDEX_F24_ID VarChar(5) Null,
   ACCOUNT_OVNER_ID Integer Null,
   SERV_ID TinyInt Null,
   SIGN_LOCK Bit Default 0,
   NODEID Integer Null,
   ADD_HCP Integer Null,
   ADD_QNT Integer Null
  )

---------------------------------------------------------------------------------
-- Создание временной таблицы #TmpQRea
---------------------------------------------------------------------------------
IF Exists (SELECT * FROM TempDB..SysObjects WHERE id = OBJECT_ID('TempDB..#TmpQRea'))
  DROP TABLE #TmpQRea

CREATE TABLE
  #TmpQRea
  (ACCOUNT_OWNER_ID Integer,
   SIGN_REA SmallInt,
   DATE_CALC DateTime,
   CALC_TYPE_ID SmallInt,
   TARIFF_ID Integer,
   MIN_TARIFF_VALUE Decimal(9,4),
   MAX_TARIFF_VALUE Decimal(9,4),
   TARIFF_VALUE Decimal(18,10),
   MEASURE_ID SmallInt,
   QNT_REACTIVE Integer,
   POW_REACTIVE Integer,
   SUM_REACTIVE Decimal(18,2)
  )

--№2

-- Курсор по Потребителям --
DECLARE curAbonentAccounts CURSOR FOR
SELECT
  AO.ACCOUNT_OWNER_ID,
  TARIFF_ID           = ISNULL(AO.TARIFF_ACT_ID,-1),
  TARR_MIN            = ISNULL(AO.TARMIN_REA_ID,-1),
  TARR_MAX            = ISNULL(AO.TARMAX_REA_ID,-1),
  CALC_FACTOR         = 0,
  POWER               = ISNULL(OP.QUANTITY,0),
  POWREA              = ISNULL(OPR.QUANTITY,0),
  SIGN_REA            = CONVERT(SmallInt,AO.SIGN_REA)
 FROM
  ProAccountOwners AO (NoLock),
  ProOwnerPower OP (NoLock),
  ProOwnerPowRea OPR (NoLock)
 WHERE
  AO.CONTRACT_ID=@iContractId AND
  OP.ACCOUNT_OWNER_ID=*AO.ACCOUNT_OWNER_ID AND
  OP.MONTH=@siMonth  AND
  OPR.ACCOUNT_OWNER_ID=*AO.ACCOUNT_OWNER_ID AND
  OPR.MONTH=@siQuarter

OPEN curAbonentAccounts
--Print '*Start curAbonentAccounts*'

SELECT @dfSumCapacity=0

FETCH NEXT FROM curAbonentAccounts
 INTO @iAccountOwnerId, @iTariffId, @iTarMinReaId, @iTarMaxReaId,
      @dfCalcFactor   , @iPower,    @iPowRea,      @siSignRea

WHILE(@@FETCH_STATUS <> -1)
BEGIN
  SELECT
    @tiCalcTypeId = Null,
    @iTariffId    = (CASE WHEN @iTariffId = -1
                          THEN Null
                          ELSE @iTariffId END ),
    @tiMeasureId  = @tiKBtMeasureId,
    @tiCalcSignFact = 1,
    @tiDecodeId   = @tiActivPDecodeId,
    @vcComment    = CONVERT(VarChar(10),@iAccountOwnerId) + @vcStamp

  SELECT
    @dfTariffValue   = (SELECT MAX(TV.TARIFF_VALUE)
                        FROM  #TmpTVal TV (NoLock)
                        WHERE TV.TARIFF_ID = @iTariffId),
    @vcTariffGroupId = (SELECT MAX(TV.TARIFF_GROUP_ID)
                        FROM #TmpTVal TV (NoLock)
                        WHERE TV.TARIFF_ID = @iTariffId)

  SELECT @dfSumCalc  = Round(ISNULL(@iPower*@dfTariffValue,0),2)

  IF @dfSumCalc<>0
    INSERT #TmpCalc
     (CALC_NUMBER,
      CALC_TYPE_ID,
      TARIFF_ID,
      TARIFF_VALUE,
      CALC_QUANTITY,
      SUM_CALC,
      MEASURE_ID,
      CALC_SIGN_FACT,
      SOURCE_ID,
      DECODE_ID,
      COMMENT,
      TARIFF_GROUP_ID
     )
     VALUES
     (@vcContractNumber,
      @tiCalcTypeId,
      @iTariffId,
      @dfTariffValue,
      @iPower,
      @dfSumCalc,
      @tiMeasureId,
      @tiCalcSignFact,
      @iAccountOwnerId,
      @tiDecodeId,
      @vcComment,
      @vcTariffGroupId)

  SELECT
    @dfSumCapacity = @dfSumCapacity + @dfSumCalc

  SELECT @tiCalcTypeId = CALC_TYPE_ID
   FROM  ProCalcTypes (NoLock)
   WHERE CALC_TYPE_NAME = 'Надбавка за реактивную энергию'

  Print '*Надбавка за реактивную энергию='
  Print @tiCalcTypeId

  SELECT @iQntRea = SUM(CC.Quantity)
   FROM #TmpPnt A (NoLock),
        ProCntCounts CC (NoLock)
  WHERE A.ACCOUNT_OWNER_ID=@iAccountOwnerId AND
--    A.AUDIT_METHOD_ID=@tiCountMethodId AND
        A.POWER_GROUP_ID=@tiReActivePowerId AND
        CC.ACCOUNT_ID=A.ACCOUNT_ID AND
        CC.DATE_ID=CONVERT(SmallDateTime,@dtCalcEnd) AND
        A.AUDIT_PARAM_ID = (SELECT MAX(AUDIT_PARAM_ID)
                            FROM ProAuditParams (NoLock)
                            WHERE AUDIT_PARAM_NAME = 'Полезный расход')

  SELECT @iQPowRea = CASE WHEN  @siSignRea = 1
                          THEN  @iPowRea*3
                          ELSE  @iPowRea  END

  SELECT @iQPowRea = CASE WHEN  @iQPowRea = 0 
                          THEN  @iQntRea
                          ELSE  @iQPowRea END

  SELECT
    @dfMinTariffValue = MAX(TV.TARIFF_VALUE),
    @tiMeasureId      = MAX(T.MEASURE_ID)
   FROM
    ProTariffs T (NoLock),
    ProTariffValues TV (NoLock)
   WHERE
    T.TARIFF_ID   = @iTarMinReaId AND
    T.SERV_ID     = @tiServId     AND
    TV.SERV_ID    = T.SERV_ID     AND
    TV.TARIFF_ID  = T.TARIFF_ID   AND
    TV.DATE_CALC  = (SELECT MAX(TT.DATE_CALC)
                     FROM ProTariffValues TT (NoLock)
                     WHERE TT.SERV_ID   = TV.SERV_ID   AND
                           TT.TARIFF_ID = TV.TARIFF_ID AND
                           TT.DATE_CALC<= CONVERT(SmallDateTime,@dtCalcEnd)
                     )

  SELECT
    @dfMaxTariffValue = MAX(TV.TARIFF_VALUE)
   FROM
    ProTariffValues TV (NoLock)
   WHERE
    TV.SERV_ID   = @tiServId     AND
    TV.TARIFF_ID = @iTarMaxReaId AND
    TV.DATE_CALC = (SELECT MAX(TT.DATE_CALC)
                    FROM  ProTariffValues TT (NoLock)
                    WHERE TT.SERV_ID   = TV.SERV_ID   AND
                          TT.TARIFF_ID = TV.TARIFF_ID AND
                          TT.DATE_CALC<= CONVERT(SmallDateTime,@dtCalcEnd)
                    ) 

  SELECT @dfTariffValue = CASE When ISNULL(@iQPowRea,0) >= ISNULL(@iQntRea,0)
                               THEN ISNULL(@dfMinTariffValue,0)
                               ELSE CONVERT(Decimal(18,10),
                                (
                                  ISNULL(@iQPowRea,0)*ISNULL(@dfMinTariffValue,0)+
                                  (ISNULL(@iQntRea,0)-ISNULL(@iQPowRea,0))*ISNULL(@dfMaxTariffValue,0)
                                  )/@iQntRea
                                ) END,
         @dfSumReactive = Round(
                               CASE WHEN ISNULL(@iQPowRea,0)>=ISNULL(@iQntRea,0)
                                    THEN CONVERT(Decimal(18,2),ISNULL(@iQntRea,0)*ISNULL(@dfMinTariffValue,0))
                                    ELSE CONVERT (Decimal(18,2),
                                     (
                                       ISNULL(@iQPowRea,0)*ISNULL(@dfMinTariffValue,0)+
                                       (ISNULL(@iQntRea,0)-ISNULL(@iQPowRea,0))*ISNULL(@dfMaxTariffValue,0))
                                     ) END
                              ,2)

  INSERT
    #TmpQRea
    (ACCOUNT_OWNER_ID,
     SIGN_REA,
     DATE_CALC,
     CALC_TYPE_ID,
     TARIFF_ID,
     MIN_TARIFF_VALUE,
     MAX_TARIFF_VALUE,
     TARIFF_VALUE,
     MEASURE_ID,
     QNT_REACTIVE,
     POW_REACTIVE,
     SUM_REACTIVE
    )
    VALUES
    (@iAccountOwnerId,
     @siSignRea,
     CONVERT(SmallDateTime,@dtCalcEnd),
     ISNULL(@tiCalcTypeId,0),
     ISNULL(@iTarMinReaId,0),
     ISNULL(@dfMinTariffValue,0),
     ISNULL(@dfMaxTariffValue,0),
     ISNULL(@dfTariffValue,0),
     ISNULL(@tiMeasureId,0),
     ISNULL(@iQntRea,0),
     ISNULL(@iQPowRea,0),
     ISNULL(Round(@dfSumReactive,2),0)
    )
  FETCH NEXT FROM curAbonentAccounts INTO @iAccountOwnerId,@iTariffId,@iTarMinReaId,
    @iTarMaxReaId,@dfCalcFactor,@iPower,@iPowRea,@siSignRea
END
CLOSE curAbonentAccounts
DEALLOCATE curAbonentAccounts

--№3


--------------------------------------------------
-- variant 1 
-- BEGIN TRANSACTION
--------------------------------------------------


-- Курсор по Группам --
DECLARE curGroupAccounts CURSOR FOR
 SELECT DISTINCT AUDIT_GROUP_ID = CONVERT(SmallInt,ISNULL(P.KNOT_MAIN,0))
 FROM #TmpPnt P
 ORDER BY AUDIT_GROUP_ID

OPEN curGroupAccounts
FETCH NEXT FROM curGroupAccounts INTO @siAuditGroupId
WHILE(@@FETCH_STATUS <> -1)
BEGIN
  SELECT
    @iSumAccount=0,
    @siCountPart=0,
    @dfSumPercent=0
--   Курсор по точкам учёта №1--
  DECLARE curAccounts CURSOR FOR
  SELECT
-- ProAccounts
    A.ACCOUNT_ID,
    A.AUDIT_METHOD_ID,
    A.AUDIT_TYPE_ID,
    A.AUDIT_PARAM_ID,
    A.POWER_GROUP_ID,
    A.BURNING_GROUP_ID,
    A.USE_HOUR,
    A.CALC_FACTOR,
    A.LEGAL_DEVIATION,
    A.TARIFF_ID,
    A.ACCOUNT_OWNER_ID,
-- AuditGroups
    GROUP_SIGN=CASE
               WHEN CONVERT(SmallInt,SUBSTRING(A.KNOT_OUT,1,3))=@siAuditGroupId OR
                    CONVERT(SmallInt,SUBSTRING(A.KNOT_OUT,4,3))=@siAuditGroupId OR
                    CONVERT(SmallInt,SUBSTRING(A.KNOT_OUT,7,3))=@siAuditGroupId OR
                    CONVERT(SmallInt,SUBSTRING(A.KNOT_OUT,10,3))=@siAuditGroupId OR
                   (CONVERT(SmallInt,KNOT_MAIN)=@siAuditGroupId
                    AND A.AUDIT_METHOD_ID=@tiPartMethodId)THEN
                1
               ELSE
               -1
             END,
    FIRST_GROUP_ID=ISNULL(CONVERT(SmallInt,KNOT_MAIN),0),
-- BurningGroupHours
    BGH.MONTH_HOURS,
    BGH.DAY_HOURS
   FROM
    #TmpPnt A (NoLock)
    ,BurningGroupHours BGH (NoLock)
   WHERE
    (
       (CONVERT(SmallInt,A.KNOT_MAIN)=@siAuditGroupId AND A.AUDIT_METHOD_ID=@tiPartMethodId)
       OR
       (
        (ISNULL(LTRIM(A.KNOT_OUT),'')<>'' AND @siAuditGroupId<>0)AND
         (
           ABS(CONVERT(SmallInt,SUBSTRING(A.KNOT_OUT,1,3)))=@siAuditGroupId OR
           ABS(CONVERT(SmallInt,SUBSTRING(A.KNOT_OUT,4,3)))=@siAuditGroupId OR
           ABS(CONVERT(SmallInt,SUBSTRING(A.KNOT_OUT,7,3)))=@siAuditGroupId OR
           ABS(CONVERT(SmallInt,SUBSTRING(A.KNOT_OUT,10,3)))=@siAuditGroupId
         )
       )
       OR
       (
         Isnull(CONVERT(SmallInt,A.KNOT_MAIN),0)=0 AND
         @siAuditGroupId=0 AND
         ISNULL(LTRIM(A.KNOT_OUT),'')=''
       )
    )
    AND  BGH.BURNING_GROUP_ID=*A.BURNING_GROUP_ID
    AND  BGH.MONTH=DATEPART(Month,@dtCalcBegin)
  OPEN curAccounts
  FETCH NEXT FROM curAccounts INTO @iAccountId,@tiAuditMethodId,@tiAuditTypeId,
    @tiAuditParamId,@tiPowerGroupId,@tiBurningGroupId,@vcUseHour,@dfCalcFactor,
    @tiLegalDeviation,@iTariffId,@iAccountOwnerId,@siGroupSign,@siFirstGroupId,
    @siMonthHours,@dfDayHours
  WHILE(@@FETCH_STATUS <> -1)


  BEGIN
    SELECT @iPQuantity = ISNULL((SELECT MAX(PQ.QUANTITY)
                                 FROM #TmpPQua PQ (NoLock)
                                 WHERE PQ.ACCOUNT_ID = @iAccountId),0)
    IF Exists (SELECT * 
               FROM ProCntCounts CC (NoLock)
               WHERE CC.ACCOUNT_ID = @iAccountId AND
                     CC.DATE_ID    = @dtCalcEnd)
    BEGIN
      SELECT
-- ProCntCounts
        @tiServId        = CC.SERV_ID,
--        @iTariffId=CC.TARIFF_ID,
        @dtDateId        = CC.DATE_ID,
        @iEditCount      = IsNull(CC.EDIT_COUNT,0),
        @iEditCountBegin = IsNull(CC.EDIT_COUNT_BEGIN,0),
        @iAddQuantity    = IsNull(CC.ADD_QUANTITY,0),
        @iQuantity       = ISNULL((CASE WHEN @tiAuditMethodId = @tiPartMethodId
                                        THEN CASE WHEN @siAuditGroupId = @siFirstGroupId
                                                  THEN  0
                                                  ELSE IsNull(CC.QUANTITY,0) END
                                        WHEN (@siCalcStatus=1 OR CC.STATUS=1)
                                          AND @tiAuditMethodId = @tiCountMethodId
                                        THEN @iPQuantity+IsNull(CC.ADD_QUANTITY,0)+IsNull(CC.ADD_HCP,0)
                                        ELSE IsNull(CC.QUANTITY,0) END),0),
        @iAddHCP          = IsNull(CC.ADD_HCP,0),
        @tiStatus         = IsNull(CC.STATUS,0),
        @siSignLock       = CONVERT(SmallInt,CC.SIGN_LOCK),
-- ProCnt
        @siCounterTypeId  = CC.COUNTER_TYPE_ID,
-- ProTariffs
        @tiMeasureId      = CC.MEASURE_ID,
        @dfTariffValue    = CC.TARIFF_VALUE
       FROM
        ProCntCounts CC (NoLock)
       WHERE
        CC.ACCOUNT_ID = @iAccountId AND
        CC.DATE_ID    = @dtCalcEnd

      IF @tiAuditMethodId=@tiPartMethodId AND @siAuditGroupId=@siFirstGroupId AND @dfCalcFactor<>0
        SELECT
          @siCountPart  = @siCountPart+1,
          @dfSumPercent = @dfSumPercent+@dfCalcFactor

--1               Долевой учет
--2               Постоянный расход
--3               Устан.мощность(часы горения)
--4               Учет по счетчику
--9               Устан.мощность(часы использования)
      IF @tiAuditMethodId = 9
      BEGIN SELECT @siWeekDay = CONVERT(Integer,LTRIM(SUBSTRING(@vcUseHour,5,1)))
        SELECT @siMonthHours = 0,
               @dtCurDay  = @dtCalcBegin
        WHILE @dtCurDay  <= @dtCalcEnd
        BEGIN
          SELECT
             @siCurDay = DATEPART(Weekday,@dtCurDay)-1

          IF @siCurDay = 0
            SELECT @siCurDay = 7

          IF(@siCurDay > @siWeekDay OR  Exists(SELECT *
                                               FROM Calendar (NoLock)
                                               WHERE FREEDAY = @dtCurDay AND
                                                     SIGNDAY = 1))
            AND NOT Exists (SELECT *
                            FROM Calendar (NoLock)
                            WHERE FREEDAY = @dtCurDay AND
                                  SIGNDAY = 2)
            SELECT @siMonthHours = @siMonthHours + ISNULL(CONVERT(Integer,LTRIM(SUBSTRING(@vcUseHour,3,2))),0)
          ELSE
            SELECT @siMonthhours = @siMonthHours + ISNULL(CONVERT(Integer,LTRIM(SUBSTRING(@vcUseHour,1,2))),0)

        SELECT @dtCurDay = DATEADD(Day,1,@dtCurDay)
        END
      END

      SELECT
        @iQuantity=
        CASE
-- Матесов Д -------------------------------------------------
-- Учет расчетов потерь в трансформаторах
when exists (select *
             from ProTrancPowerLoss
             where account_id = @iAccountId
               and date_calc = @dtCalcEnd)
then (select sum(LOSS_QUANTITY)
      from ProTrancPowerLoss
      where account_id = @iAccountId
        and date_calc = @dtCalcEnd)
------------------------------------------------------------
          WHEN @tiAuditMethodId = @tiPartMethodId
          THEN @iQuantity
          WHEN @tiAuditMethodId = 2
          THEN CONVERT(Integer,ROUND(@dfCalcFactor,0)+@iAddQuantity+@iAddHCP)
          WHEN @tiAuditMethodId = 3
          THEN CONVERT(Integer,ROUND(@dfCalcFactor*@siMonthHours,0)+@iAddQuantity+@iAddHCP)
          WHEN @tiAuditMethodId = 9
          THEN CONVERT(Integer,ROUND(@dfCalcFactor*@siMonthHours,0)+@iAddQuantity+@iAddHCP)
          ELSE CASE WHEN (@siCalcStatus = 1 OR @tiStatus = 1)
                    THEN @iPQuantity
                    ELSE @iQuantity END
                                        END

      SELECT
        @iQuantity = @iQuantity*@siSignLock

      IF @siAuditGroupId <> @siFirstGroupId
        SELECT @iSumAccount = @iSumAccount + @iQuantity*@siGroupSign

      SELECT
        @dfIncr=Round(
            CASE
              WHEN Abs(@iQuantity-@iPQuantity)<1 THEN
                0
              WHEN @iQuantity>@iPQuantity THEN
                CASE
                  WHEN @iQuantity=0 OR @iPQuantity=0 OR
                       Sign(@iQuantity)<>Sign(@iPQuantity)  OR
                       @iQuantity/@iPQuantity>999 THEN
                    999
                  ELSE
                    CASE
                      WHEN Abs(@iQuantity)>Abs(@iPQuantity) THEN
                        Convert(Decimal(9,2),@iQuantity)/Convert(Decimal(9,2),@iPQuantity)
                      ELSE
                        Convert(Decimal(9,2),@iPQuantity)/Convert(Decimal(9,2),@iQuantity)
                    END
                END
              WHEN @iQuantity<@iPQuantity THEN
                CASE
                  WHEN @iQuantity=0 OR @iPQuantity=0 OR
                       Sign(@iQuantity)<>Sign(@iPQuantity) OR
                       @iPQuantity/@iQuantity>999 THEN
                    -999
                  ELSE
                    CASE
                      WHEN Abs(@iQuantity)>Abs(@iPQuantity) THEN
                        -Convert(Decimal(9,2),@iQuantity)/Convert(Decimal(9,2),@iPQuantity)
                      ELSE
                        -Convert(Decimal(9,2),@iPQuantity)/Convert(Decimal(9,2),@iQuantity)
                      END
                END
            END,2)

---- point 1


      UPDATE
        ProCntCounts
       SET
        QUANTITY   = @iQuantity,
        EDIT_COUNT = CASE  WHEN (@siCalcStatus=1 OR @tiStatus=1) AND @tiAuditMethodId=@tiCountMethodId
                           THEN Convert(Integer,@iEditCountBegin + CASE WHEN @dfCalcFactor = 0
                                                                        THEN 0
                                                                        ELSE @iPQuantity/@dfCalcFactor
                                                                        END)%POWER(10,Isnull(PREC,0)-Isnull(SCALE,0))
                           ELSE EDIT_COUNT END,
          INCREASE  = @dfIncr,
          ERROR_SIGN = Convert(Bit, CASE WHEN (Abs(@dfIncr)-1)*100>@tiLegalDeviation
                                         THEN 1
                                         ELSE 0 END)
       WHERE
        ACCOUNT_ID = @iAccountId AND
        DATE_ID    = @dtCalcEnd
---------------
IF @@ERROR<>0
BEGIN
  ROLLBACK TRANSACTION
  SELECT
    RTC=@iRTC
  RETURN
END
---------------
    END
    FETCH NEXT FROM curAccounts INTO @iAccountId,@tiAuditMethodId,@tiAuditTypeId,
      @tiAuditParamId,@tiPowerGroupId,@tiBurningGroupId,@vcUseHour,@dfCalcFactor,
      @tiLegalDeviation,@iTariffId,@iAccountOwnerId,@siGroupSign,@siFirstGroupId,
      @siMonthHours,@dfDayHours
  END
--   Конец курсора по точкам учёта №1
  CLOSE curAccounts
  DEALLOCATE curAccounts

--№4


--         { Вторичный расчёт в киловаттах и суммах }
  IF @siCountPart<>0 -- // Есть активные(ненулевые) долевые точки учёта
  BEGIN
    IF @dfSumPercent<>100 -- THEN // Распределяется не 100%
    BEGIN  --   // Подсчёт распределяемых долевых киловатт
      SELECT
        @iSumAccount=ROUND(@iSumAccount*@dfSumPercent/100+0.00001,0)
    END
  END
  SELECT
    @iRemainder=@iSumAccount

--   Курсор по точкам учёта №2--
  DECLARE curAccounts CURSOR FOR
  SELECT
-- ProAccounts
    A.ACCOUNT_ID,
    A.AUDIT_METHOD_ID,
    A.AUDIT_TYPE_ID,
    A.AUDIT_PARAM_ID,
    A.POWER_GROUP_ID,
    A.BURNING_GROUP_ID,
    A.USE_HOUR,
    A.CALC_FACTOR,
    A.LEGAL_DEVIATION,
    A.TARIFF_ID,
    A.ACCOUNT_OWNER_ID,
-- AuditGroups
    GROUP_SIGN=
      CASE
        WHEN CONVERT(SmallInt,SUBSTRING(A.KNOT_OUT,1,3))=@siAuditGroupId OR
         CONVERT(SmallInt,SUBSTRING(A.KNOT_OUT,4,3))=@siAuditGroupId OR
         CONVERT(SmallInt,SUBSTRING(A.KNOT_OUT,7,3))=@siAuditGroupId OR
         CONVERT(SmallInt,SUBSTRING(A.KNOT_OUT,10,3))=@siAuditGroupId OR
         (CONVERT(SmallInt,KNOT_MAIN)=@siAuditGroupId
         AND A.AUDIT_METHOD_ID=@tiPartMethodId)THEN
          1
        ELSE
         -1
      END,
    FIRST_GROUP_ID=ISNULL(CONVERT(SmallInt,KNOT_MAIN),0),
    A.CAPACITY,
    A.KNOT_OUT,
    A.KNOT_MAIN,
    A.SUBSTATION_TYPE_ID,
    A.SUBSTATION_ID,
    A.SECTION_ID,
    A.INDEX_F24_ID,
    A.NODEID,
-- BurningGroupHours
    BGH.MONTH_HOURS,
    BGH.DAY_HOURS
   FROM
    #TmpPnt A (NoLock)
    ,BurningGroupHours BGH (NoLock)
   WHERE
    (
       (CONVERT(SmallInt,A.KNOT_MAIN)=@siAuditGroupId AND A.AUDIT_METHOD_ID=@tiPartMethodId)
       OR
       (
        (ISNULL(LTRIM(A.KNOT_OUT),'')<>'' AND @siAuditGroupId<>0)AND
         (
           ABS(CONVERT(SmallInt,SUBSTRING(A.KNOT_OUT,1,3)))=@siAuditGroupId OR
           ABS(CONVERT(SmallInt,SUBSTRING(A.KNOT_OUT,4,3)))=@siAuditGroupId OR
           ABS(CONVERT(SmallInt,SUBSTRING(A.KNOT_OUT,7,3)))=@siAuditGroupId OR
           ABS(CONVERT(SmallInt,SUBSTRING(A.KNOT_OUT,10,3)))=@siAuditGroupId
         )
       )
       OR
       (
         Isnull(CONVERT(SmallInt,A.KNOT_MAIN),0)=0 AND
         @siAuditGroupId=0 AND
         ISNULL(LTRIM(A.KNOT_OUT),'')=''
       )
    )
    AND  BGH.BURNING_GROUP_ID=*A.BURNING_GROUP_ID
    AND  BGH.MONTH=DATEPART(Month,@dtCalcBegin)
  OPEN curAccounts
  FETCH NEXT FROM curAccounts INTO @iAccountId,@tiAuditMethodId,@tiAuditTypeId,
    @tiAuditParamId,@tiPowerGroupId,@tiBurningGroupId,@vcUseHour,@dfCalcFactor,
    @tiLegalDeviation,@iTariffId,@iAccountOwnerId,@siGroupSign,@siFirstGroupId,
    @dfCapacity,@vcKnotOut,@vcKnotMain,@tiSubstationTypeId,@siSubstationId,
    @tiSectionId,@vcIndexF24Id,@iNodeId,@siMonthHours,@dfDayHours
  WHILE(@@FETCH_STATUS <> -1)
  BEGIN
    SELECT
      @tiDecodeId=@tiAuditParamId

    SELECT
      @iPQuantity=ISNULL(
       (SELECT
          MAX(PQ.QUANTITY)
         FROM
          #TmpPQua PQ (NoLock)
         WHERE
          PQ.ACCOUNT_ID=@iAccountId),0)
    IF Exists
       (SELECT
          *
         FROM
          ProCntCounts CC (NoLock)
         WHERE
          CC.ACCOUNT_ID=@iAccountId AND
          CC.DATE_ID=@dtCalcEnd)
    BEGIN
      SELECT
-- ProCntCounts
        @tiServId=CC.SERV_ID,
--        @iTariffId=CC.TARIFF_ID,
        @dtDateId=CC.DATE_ID,
        @iEditCount=CC.EDIT_COUNT,
        @iAddQuantity=CC.ADD_QUANTITY,
        @iQuantity=
         ISNULL(
         (CASE
            WHEN @tiAuditMethodId=@tiPartMethodId THEN
              CASE
                WHEN @siAuditGroupId=@siFirstGroupId THEN
                  0
                ELSE
                  IsNull(CC.QUANTITY,0)
              END
            WHEN (@siCalcStatus=1 OR CC.STATUS=1) AND @tiAuditMethodId=@tiCountMethodId THEN
              @iPQuantity+IsNull(CC.ADD_QUANTITY,0)+IsNull(CC.ADD_HCP,0)
            ELSE
              IsNull(CC.QUANTITY,0)
          END),0),
        @tiStatus=CC.STATUS,
        @siSignLock=CONVERT(SmallInt,CC.SIGN_LOCK),
-- ProCnt
        @siCounterTypeId=CC.COUNTER_TYPE_ID,
-- ProTariffs
        @tiMeasureId=CC.MEASURE_ID,
        @dfTariffValue=CC.TARIFF_VALUE,
        @vcTariffGroupId=CC.TARIFF_GROUP_ID,
        @iEditCountBegin=CC.EDIT_COUNT_BEGIN,
        @vcFactoryNumber=CC.FACTORY_NUMBER,
        @iAddHCP=CC.ADD_HCP,
        @iAddQnt=CC.ADD_QNT
       FROM
        ProCntCounts CC
       WHERE
        CC.ACCOUNT_ID=@iAccountId AND
        CC.DATE_ID=@dtCalcEnd

      SELECT
        @dfMinTariffValue=0,
        @dfMaxTariffValue=0,
        @iQPowRea=0,
        @iQntRea=0

--1               Долевой учет
--2               Постоянный расход
--3               Устан.мощность(часы горения)
--4               Учет по счетчику
--9               Устан.мощность(часы использования)
      IF @tiAuditMethodId=9
      BEGIN
        SELECT
          @siWeekDay=CONVERT(Integer,LTRIM(SUBSTRING(@vcUseHour,5,1)))
        SELECT
          @siMonthHours=0,
          @dtCurDay=@dtCalcBegin

        WHILE @dtCurDay<=@dtCalcEnd
        BEGIN
          SELECT
            @siCurDay=DATEPART(Weekday,@dtCurDay)-1
          IF @siCurDay=0
            SELECT
              @siCurDay=7
          IF(@siCurDay>@siWeekDay OR
             Exists(
               SELECT
                *
               FROM
                Calendar (NoLock)
               WHERE
                FREEDAY=@dtCurDay AND
                SIGNDAY=1))
             AND
             NOT Exists(
              SELECT
                *
               FROM
                Calendar (NoLock)
               WHERE
                FREEDAY=@dtCurDay AND
                SIGNDAY=2)
            SELECT
              @siMonthHours=
               @siMonthHours+
               ISNULL(CONVERT(Integer,LTRIM(SUBSTRING(@vcUseHour,3,2))),0)
          ELSE
            SELECT
              @siMonthhours=
               @siMonthHours+
               ISNULL(CONVERT(Integer,LTRIM(SUBSTRING(@vcUseHour,1,2))),0)
            SELECT @dtCurDay=DATEADD(Day,1,@dtCurDay)
        END
      END
      SELECT
        @iQuantity=
         (CASE
-- Матесов Д -------------------------------------------------
when exists (select * from ProTrancPowerLoss where account_id = @iAccountId and date_calc = @dtCalcEnd)
then (select sum(LOSS_QUANTITY) from ProTrancPowerLoss where account_id = @iAccountId and date_calc = @dtCalcEnd)
------------------------------------------------------------

            WHEN (@tiAuditMethodId=@tiPartMethodId AND @siAuditGroupId=@siFirstGroupId) THEN
              CASE
                WHEN @dfCalcFactor<>0 AND @siCountPart=1 THEN
                  @iRemainder
                ELSE
                  CONVERT(Integer,ROUND(@iSumAccount*@dfCalcFactor/@dfSumPercent,0))
              END
            ELSE
              @iQuantity
          END)*@siSignLock

      IF (@tiAuditMethodId=@tiPartMethodId AND @siAuditGroupId=@siFirstGroupId AND @dfCalcFactor<>0 AND @siCountPart>0)
      BEGIN
        SELECT
          @iRemainder=@iRemainder-@iQuantity,
          @siCountPart=@siCountPart-1
      END
      IF @tiPowerGroupId=@tiReActivePowerId
      BEGIN
        SELECT
          @iTariffId=TARIFF_ID,
          @dfTariffValue=TARIFF_VALUE,
          @tiMeasureId=MEASURE_ID,
          @iQPowRea=POW_REACTIVE,
          @iQntRea=QNT_REACTIVE,
          @dfMinTariffValue=MIN_TARIFF_VALUE,
          @dfMaxTariffValue=MAX_TARIFF_VALUE
         FROM
          #TmpQRea (NoLock)
         WHERE
          ACCOUNT_OWNER_ID=@iAccountOwnerId

        SELECT
          @dfTariffValue=
            CASE
              WHEN ISNULL(@iQPowRea,0)>=ISNULL(@iQntRea,0) THEN
                ISNULL(@dfMinTariffValue,0)
              ELSE
                CONVERT
                 (Decimal(18,10),
                  (
                   ISNULL(@iQPowRea,0)*ISNULL(@dfMinTariffValue,0)+
                   (ISNULL(@iQntRea,0)-ISNULL(@iQPowRea,0))*ISNULL(@dfMaxTariffValue,0)
                  )/@iQntRea
                 )
            END
      END
      SELECT
        @tiCalcTypeId=Null,
        @dfSumCalc=Round(@iQuantity*ISNULL(@dfTariffValue,0)*SIGN(@tiDecodeId),2),
        @tiCalcSignFact=1,
        @iSourceId=@iAccountId,
        @vcComment=CONVERT(VarChar(40),@iAccountId)+@vcStamp

      IF NOT Exists
       (SELECT
          *
         FROM
          #TmpCalc (NoLock)
         WHERE
          SOURCE_ID=@iSourceId
       )
      BEGIN
        INSERT
          #TmpCalc
          (CALC_NUMBER,
           CALC_TYPE_ID,
           TARIFF_ID,
           TARIFF_VALUE,
           CALC_QUANTITY,
           SUM_CALC,
           MEASURE_ID,
           CALC_SIGN_FACT,
           SOURCE_ID,
           DECODE_ID,
           COMMENT,
           TARIFF_GROUP_ID,
           EDIT_COUNT_BEGIN,
           EDIT_COUNT,
           ADD_QUANTITY,
           STATUS,
           FACTORY_NUMBER,
           COUNTER_TYPE_ID,
           AUDIT_METHOD_ID,
           CALC_FACTOR,
           CAPACITY,
           KNOT_OUT,
           KNOT_MAIN,
           SUBSTATION_TYPE_ID,
           SUBSTATION_ID,
           SECTION_ID,
           INDEX_F24_ID,
           ACCOUNT_OVNER_ID,
           SERV_ID,
           SIGN_LOCK,
           NODEID,
           ADD_HCP,
           ADD_QNT
          )
         VALUES
          (@vcContractNumber,
           @tiCalcTypeId,
           @iTariffId,
           @dfTariffValue,
           @iQuantity,
           @dfSumCalc,
           @tiMeasureId,
           @tiCalcSignFact,
           @iSourceId,
           @tiDecodeId,
           @vcComment,
           @vcTariffGroupId,
           @iEditcountbegin,
           @iEditcount,
           @iAddQuantity,
           @tiStatus,
           @vcFactoryNumber,
           @siCounterTypeId,
           @tiAuditMethodId,
           @dfCalcFactor,
           @dfCapacity,
           @vcKnotOut,
           @vcKnotMain,
           @tiSubstationTypeId,
           @siSubstationId,
           @tiSectionId,
           @vcIndexF24Id,
           @iAccountOwnerId,
           @tiServId,
           IsNull(@siSignLock,0),
           @iNodeId,
           @iAddHCP,
           @iAddQnt
           )
      END
      ELSE
      BEGIN
        UPDATE
          #TmpCalc
         SET
          CALC_QUANTITY=@iQuantity,
          SUM_CALC=@dfSumCalc
         WHERE
          SOURCE_ID=@iSourceId
      END

      SELECT
        @dfIncr=Round(
            CASE
              WHEN Abs(@iQuantity-@iPQuantity)<1 THEN
                0
              WHEN @iQuantity>@iPQuantity THEN
                CASE
                  WHEN @iQuantity=0 OR @iPQuantity=0 OR
                       Sign(@iQuantity)<>Sign(@iPQuantity) OR
                       @iQuantity/@iPQuantity>999 THEN
                    999
                  ELSE
                    CASE
                      WHEN Abs(@iQuantity)>Abs(@iPQuantity) THEN
                        Convert(Decimal(9,2),@iQuantity)/Convert(Decimal(9,2),@iPQuantity)
                      ELSE
                        Convert(Decimal(9,2),@iPQuantity)/Convert(Decimal(9,2),@iQuantity)
                    END
                END
              WHEN @iQuantity<@iPQuantity THEN
                CASE
                  WHEN @iQuantity=0 OR @iPQuantity=0 OR
                       Sign(@iQuantity)<>Sign(@iPQuantity) OR
                       @iPQuantity/@iQuantity>999 THEN
                     -999
                  ELSE
                    CASE
                      WHEN Abs(@iQuantity)>Abs(@iPQuantity) THEN
                        -Convert(Decimal(9,2),@iQuantity)/Convert(Decimal(9,2),@iPQuantity)
                      ELSE

                        -Convert(Decimal(9,2),@iPQuantity)/Convert(Decimal(9,2),@iQuantity)
                      END
                END
            END,2)


      UPDATE
        ProCntCounts
       SET
        QUANTITY=@iQuantity,
        SUM_ALL=@dfSumCalc,
        INCREASE=@dfIncr,
        ERROR_SIGN=Convert(Bit,
          CASE
            WHEN (Abs(@dfIncr)-1)*100>@tiLegalDeviation THEN
              1
            ELSE
              0
          END)
       WHERE
        ACCOUNT_ID=@iAccountId AND
        DATE_ID=@dtCalcEnd
---------------
IF @@ERROR<>0
BEGIN
  ROLLBACK TRANSACTION
  SELECT
    RTC=@iRTC
  RETURN
END
---------------

      SELECT
        @dfSumCalc=
         CASE
           WHEN ((@tiAuditMethodId<>@tiPartMethodId) OR (@tiAuditMethodId=@tiPartMethodId AND @siAuditGroupId=@siFirstGroupId))  THEN
             @dfSumCalc
           ELSE
             0
         END,
        @iQuantity=
         CASE
           WHEN  @tiCalcSignFact=1
            AND ((@tiAuditMethodId<>@tiPartMethodId) OR (@tiAuditMethodId=@tiPartMethodId AND @siAuditGroupId=@siFirstGroupId))
            AND @tiMeasureId=@tiKBt_ChMeasureId
            AND  (@dfSumCalc<>0 OR  @iQuantity<>0)
            AND ISNULL(@tiDecodeId,-1)<>0  THEN
             @iQuantity
           ELSE
             0
         END
      IF @tiPowerGroupId=@tiReActivePowerId
        SELECT
          @dfSumReactive=@dfSumReactive+@dfSumCalc
    END
    FETCH NEXT FROM curAccounts INTO @iAccountId,@tiAuditMethodId,@tiAuditTypeId,
      @tiAuditParamId,@tiPowerGroupId,@tiBurningGroupId,@vcUseHour,@dfCalcFactor,
      @tiLegalDeviation,@iTariffId,@iAccountOwnerId,@siGroupSign,@siFirstGroupId,
      @dfCapacity,@vcKnotOut,@vcKnotMain,@tiSubstationTypeId,@siSubstationId,
      @tiSectionId,@vcIndexF24Id,@iNodeId,@siMonthHours,@dfDayHours
  END
--   Конец курсора по точкам учёта №2
  CLOSE curAccounts
  DEALLOCATE curAccounts

  FETCH NEXT FROM curGroupAccounts INTO @siAuditGroupId
END
-- Конец курсора по группам
CLOSE curGroupAccounts
DEALLOCATE curGroupAccounts

--№5
SELECT
  @dfSumAdd=0

SELECT
  @iAllQuantity = IsNull(SUM (CASE WHEN CD.MEASURE_ID = @tiKBt_ChMeasureId
                                   THEN CD.CALC_QUANTITY
                                   ELSE 0  END),0),
  @dfSumCount   = IsNull(SUM (CASE WHEN CD.MEASURE_ID NOT IN(7,8,9)
                                   THEN CD.SUM_CALC
                                   ELSE 0 END),0)
 FROM
  #TmpCalc CD (NoLock)
 WHERE
     CD.DECODE_ID <> 0 
 AND CD.DECODE_ID <> @tiAddDecodeId

--##

SELECT
  @dfTariffValue = AVG(TARIFF_VALUE)
FROM
  #TmpQRea (NoLock)
WHERE
  QNT_REACTIVE <> 0

SELECT
  @iCalcQuantity = SUM(QNT_REACTIVE)
FROM #TmpQRea (NoLock)

SELECT
  @dfSumCalc = SUM(Round(SUM_REACTIVE,2))
FROM #TmpQRea (NoLock)

SELECT
  @dfSumReactive=SUM(Round(SUM_REACTIVE,2))
FROM
  #TmpQRea (NoLock)

INSERT
 #TmpCalc
  (CALC_NUMBER,
   CALC_TYPE_ID,
   TARIFF_ID,
   TARIFF_VALUE,
   CALC_QUANTITY,
   SUM_CALC,
   MEASURE_ID,
   CALC_SIGN_FACT,
   SOURCE_ID,
   DECODE_ID,
   COMMENT
   )
 VALUES
 (@vcContractNumber,
  Convert(TinyInt,17),
  Convert(Integer,100),
  @dfTariffValue,
  @iCalcQuantity,
  @dfSumCalc,
  Convert(TinyInt,8),
  Convert(TinyInt,1),
  CONVERT(Integer,@vcContractNumber),
  Convert(TinyInt,1),
  @vcContractNumber+@vcStamp)

UPDATE
  #TmpCalc
 SET
   DECODE_ID=0,
   CALC_SIGN_FACT=0
 WHERE
  MEASURE_ID=8 AND
  (CALC_TYPE_ID Is Null OR SUM_CALC=0)

SELECT
  @dfExciseTax=0.00

SELECT
  @dfSumExcise=Round(IsNull(IsNull(@iAllQuantity,0)*IsNull(@dfExciseTax,0),0),2)

SELECT
  @dfSumAddCostTax=Round(IsNull((IsNull(@dfSumCount,0)+IsNull(@dfSumReactive,0)+
                    IsNull(@dfSumCapacity,0)+IsNull(@dfSumAdd,0)+
                    IsNull(@dfSumExcise,0))*IsNull(@dfAddCostTax,0)/100,0),2)

SELECT
  @dfSumCalc=IsNull(@dfsumCapacity,0)+IsNull(@dfSumCount,0)+IsNull(@dfSumReactive,0)+
              IsNull(@dfSumExcise,0)+IsNull(@dfSumAddCostTax,0);

SELECT
  @tiCalcTypeId=CALC_TYPE_ID
 FROM
  ProCalcTypes (NoLock)
 WHERE
  CALC_TYPE_NAME='Аванс'
Print '*Аванс='
Print @tiCalcTypeId

SELECT
  @dfAdvanceOld=IsNull(
 (SELECT
    ADV_NEW
   FROM
    ProCalcs (NoLock)
   WHERE
    CONTRACT_ID=@iContractId AND
    DATE_CALC=DateAdd(dd,-1,@dtCalcBegin)),0)

-- 0          Аванс не выставляетс
-- 1          По расходу э/энергии
-- 2          Процент от предыдуще
-- 3          Фиксированная сумма
-- 4          По предыдущему перио
SELECT
  @dfAdvanceNew=IsNull(
    (SELECT
       C.ADV_NEW
      FROM
       ProCalcs C (NoLock)
      WHERE
       C.CALC_ID=@iCalcId),0)

SELECT
  @dfSumPeni=Coalesce(
    (SELECT
       C.SUM_PENI
      FROM
       ProCalcs C (NoLock)
      WHERE
       C.CALC_ID=@iCalcId),
    (SELECT
       FS.SUM_FINE
      FROM
       ProFineSums FS (NoLock)
      WHERE
       FS.CONTRACT_ID=@iContractId AND
       FS.DATE_CALC=@dtCalcEnd),
     0)



-- variant 2 
BEGIN TRANSACTION

-- начало работы с ProCalcs

IF @iCalcId=0  -- расчет производится впервые
BEGIN

--##
Print '*1'
Print     @dfSumCapacity
Print     @dfSumCount
Print     @dfSumReactive
Print     @dfSumAdd
Print     @dfSumAddCostTax
Print     @dfSumExcise

  IF @bSignNumerationSF = 1
    SELECT @vcCalcNumber=CONVERT(varchar(20),1+(SELECT COUNT(*) FROM ProCalcs WHERE  YEAR(DATE_CALC)=@iYear))
  ELSE
    SELECT @vcCalcNumber=Convert(VarChar(20),@iCalcId)

  INSERT
    ProCalcs
    (CALC_ID,
     CONTRACT_ID,
     CALC_NUMBER,
     BILL_NUMBER,
     CONTRACT_NUMBER,
     DATE_CALC,
     SALDO,
     SUM_SALDO,
     SALDO_PENI,
     SUM_FACT,
     SUM_CAPACITY,
     SUM_REACTIVE,
     SUM_COUNT,
     SUM_ADD,
     SUM_NDS,
     SUM_EXC,
     ADV_OLD,
     ADV_NEW,
     SUM_PENI,
     SUM_ALL,
     QNT_ALL,
     SIGN_LOCK,
     ABONENT_TYPE_ID,
     ABONENT_GROUP_ID,
     DISTR_ID,
     CONSUMER_GROUP_ID,
     MINISTRY_ID,
     BANK_ID,
     CONTRACT_DATE_PAY,
     AGREEMENT_DATE_PAY,
     ADD_COST_TAX,
     EXCISE_TAX
    )
   VALUES
    (@iCalcId,
     @iContractId,
     @vcCalcNumber,
     @vcCalcNumber,
     @vcContractNumber,
     @dtCalcEnd,
     IsNull(@dfSaldo,0),
     IsNull(@dfSumSaldo,0),
     IsNull(@dfSaldoPeni,0),
     IsNull(@dfSumCapacity,0)+
      IsNull(@dfSumCount,0)+
      IsNull(@dfSumReactive,0)+
      IsNull(@dfSumAdd,0),
     IsNull(@dfSumCapacity,0),
     IsNull(@dfSumReactive,0),
     IsNull(@dfSumCount,0),
     IsNull(@dfSumAdd,0),
     IsNull(@dfSumAddCostTax,0),
     IsNull(@dfSumExcise,0),
     IsNull(@dfAdvanceOld,0),
     IsNull(@dfAdvanceNew,0),
     IsNull(@dfSumPeni,0),
     IsNull(@dfSumCapacity,0)+
      IsNull(@dfSumCount,0)+
      IsNull(@dfSumReactive,0)+
      IsNull(@dfSumAdd,0)+
      IsNull(@dfSumAddCostTax,0)+
      IsNull(@dfSumExcise,0)-
      IsNull(@dfAdvanceOld,0)+
      IsNull(@dfAdvanceNew,0)+
      IsNull(@dfSumPeni,0),
     IsNull(@iAllQuantity,0),
     0,
     @tiAbonentTypeId,
     @tiAbonentGroupId,
     @tiDistrId,
     @siConsumerGroupId,
     @iMinistryId,
     @iBankId,
     @tiContractDatePay,
     @sdtAgreementDatePay,
     @dfAddCostTax,
     @dfExciseTax
    )
---------------
IF @@ERROR<>0
BEGIN
  ROLLBACK TRANSACTION
  SELECT
    RTC=@iRTC
  RETURN
END
---------------
  SELECT
    @iCalcId=CALC_ID
   FROM
    ProCalcs (NoLock)
   WHERE
    CONTRACT_ID=@iContractId
    AND DATE_CALC=@dtCalcEnd

-- Первый update ProCalcs

  IF @bSignNumerationSF = 1
    UPDATE
      ProCalcs
     SET
--    CALC_NUMBER=Convert(VarChar(20),CALC_ID),
      BILL_NUMBER=CALC_NUMBER
     WHERE
      CALC_ID=@iCalcId
  ELSE
    UPDATE
      ProCalcs
     SET
      CALC_NUMBER=Convert(VarChar(20),CALC_ID),
      BILL_NUMBER=Convert(VarChar(20),CALC_ID)
     WHERE
      CALC_ID=@iCalcId
---------------
IF @@ERROR<>0
BEGIN
  ROLLBACK TRANSACTION
  SELECT
    RTC=@iRTC
  RETURN
END
---------------
END -- расчет производится впервые @iCalcId=0

ELSE

BEGIN

--##
Print '*2'
Print     @dfSumCapacity
Print     @dfSumCount
Print     @dfSumReactive
Print     @dfSumAdd
Print     @dfSumAddCostTax
Print     @dfSumExcise


-- Второй update ProCalcs
  UPDATE
    ProCalcs
   SET
--    CALC_ID,
--    CONTRACT_ID,
--    CALC_NUMBER,
    BILL_NUMBER=CALC_NUMBER,
--    DATE_CALC=@dtCalcEnd,
    SALDO=IsNull(@dfSaldo,0),
    SUM_SALDO=IsNull(@dfSumSaldo,0),
    SALDO_PENI=IsNull(@dfSaldoPeni,0),
    SUM_FACT=IsNull(@dfSumCapacity,0)+
     IsNull(@dfSumCount,0)+
     IsNull(@dfSumReactive,0)+
     IsNull(@dfSumAdd,0),
    SUM_CAPACITY=IsNull(@dfSumCapacity,0),
    SUM_REACTIVE=IsNull(@dfSumReactive,0),
    SUM_COUNT=IsNull(@dfSumCount,0),
    SUM_ADD=IsNull(@dfSumAdd,0),
    SUM_NDS=IsNull(@dfSumAddCostTax,0),
    SUM_EXC=IsNull(@dfSumExcise,0),
    ADV_OLD=IsNull(@dfAdvanceOld,0),
    ADV_NEW=IsNull(@dfAdvanceNew,0),
    SUM_ALL=IsNull(@dfSumCapacity,0)+
     IsNull(@dfSumCount,0)+
     IsNull(@dfSumReactive,0)+
     IsNull(@dfSumAdd,0)+
     IsNull(@dfSumAddCostTax,0)+
     IsNull(@dfSumExcise,0)-
     IsNull(@dfAdvanceOld,0)+
     IsNull(@dfAdvanceNew,0)+
     IsNull(@dfSumPeni,0),
    QNT_ALL=IsNull(@iAllQuantity,0),
    SIGN_LOCK=0,
    ABONENT_TYPE_ID=@tiAbonentTypeId,
    ABONENT_GROUP_ID=@tiAbonentGroupId,
    DISTR_ID=@tiDistrId,
    CONSUMER_GROUP_ID=@siConsumerGroupId,
    MINISTRY_ID=@iMinistryId,
    BANK_ID=@iBankId,
    CONTRACT_DATE_PAY=@tiContractDatePay,
    AGREEMENT_DATE_PAY=@sdtAgreementDatePay,
    ADD_COST_TAX=@dfAddCostTax,
    EXCISE_TAX=@dfExciseTax
   WHERE
    CALC_ID=@iCalcId
--##

Print '*iCalcId='
Print @iCalcId
---------------
IF @@ERROR<>0
BEGIN
  ROLLBACK TRANSACTION
  SELECT
    RTC=@iRTC
  RETURN
END
---------------
END -- Расчет производится не впервые



SELECT
  @dfSumFact=IsNull(@dfSumCapacity,0)+IsNull(@dfSumCount,0)+
              IsNull(@dfSumReactive,0)+IsNull(@dfSumAdd,0)

DELETE
  ProCalcDetails
 WHERE
  CALC_ID=@iCalcId AND
  (COMMENT is Null
    OR
   ((DECODE_ID Is Null
     OR
     DECODE_ID<>@tiAddDecodeId) AND 
    Substring(COMMENT,1,5)<>'Аванс' ))

IF @@ERROR<>0
BEGIN
  ROLLBACK TRANSACTION
  SELECT
    RTC=@iRTC
  RETURN
END

-- Курсор по #TmpCalc --
DECLARE curTmpCalc CURSOR FOR
 SELECT
   CALC_TYPE_ID,
   TARIFF_ID,
   TARIFF_VALUE,
   CALC_QUANTITY,
   SUM_CALC,
   MEASURE_ID,
   CALC_SIGN_FACT,
   SOURCE_ID,
   DECODE_ID,
   COMMENT,
   TARIFF_GROUP_ID,
   EDIT_COUNT_BEGIN,
   EDIT_COUNT,
   ADD_QUANTITY,
   STATUS,
   FACTORY_NUMBER,
   COUNTER_TYPE_ID,
   AUDIT_METHOD_ID,
   CALC_FACTOR,
   CAPACITY,
   KNOT_OUT,
   KNOT_MAIN,
   SUBSTATION_TYPE_ID,
   SUBSTATION_ID,
   SECTION_ID,
   INDEX_F24_ID,
   ACCOUNT_OVNER_ID,
   SERV_ID,
   Convert(SmallInt,SIGN_LOCK),
   NODEID,
   ADD_HCP,
   ADD_QNT
  FROM
   #TmpCalc (NoLock)

OPEN curTmpCalc

SELECT
  @iCalcDetailId=
  IsNull(
    (SELECT
       MAX(CALC_DETAIL_ID)
      FROM
       ProCalcDetails (NoLock)
      WHERE
       CALC_ID=@iCalcId),0)

FETCH NEXT FROM curTmpCalc INTO   @tiCalcTypeId, @iTariffId, @dfTariffValue,
  @iCalcQuantity, @dfSumCalc, @tiMeasureId, @tiCalcSignFact, @iSourceId,
  @tiDecodeId, @vcComment, @vcTariffGroupId, @iEditcountbegin, @iEditcount,
  @iAddQuantity, @tiStatus, @vcFactoryNumber, @siCounterTypeId,
  @tiAuditMethodId, @dfCalcFactor, @dfCapacity, @vcKnotOut, @vcKnotMain,
  @tiSubstationTypeId, @siSubstationId, @tiSectionId, @vcIndexF24Id,
  @iAccountOwnerId,@tiServId,@siSignLock,@iNodeId,@iAddHCP,@iAddQnt
-- Пока не конец курсора...
WHILE(@@FETCH_STATUS <> -1)
BEGIN
  SELECT @iCalcDetailId=@iCalcDetailId+1

  INSERT
   ProCalcDetails
   (CALC_ID,
    CALC_DETAIL_ID,
    CALC_TYPE_ID,
    TARIFF_ID,
    TARIFF_VALUE,
    CALC_QUANTITY,
    SUM_CALC,
    MEASURE_ID,
    CALC_SIGN_FACT,
    SOURCE_ID,
    DECODE_ID,
    COMMENT,
    TARIFF_GROUP_ID,
    EDIT_COUNT_BEGIN,
    EDIT_COUNT,
    ADD_QUANTITY,
    STATUS,
    FACTORY_NUMBER,
    COUNTER_TYPE_ID,
    AUDIT_METHOD_ID,
    CALC_FACTOR,
    CAPACITY,
    KNOT_OUT,
    KNOT_MAIN,
    SUBSTATION_TYPE_ID,
    SUBSTATION_ID,
    SECTION_ID,
    INDEX_F24_ID,
    ACCOUNT_OWNER_ID,
    SERV_ID,
    SIGN_LOCK,
    NODEID,
    ADD_HCP,
    ADD_QNT
    )
   VALUES
   (@iCalcId,
    @iCalcDetailId,
    @tiCalcTypeId,
    @iTariffId,
    @dfTariffValue,
    @iCalcQuantity,
    IsNull(@dfSumCalc,0),
    @tiMeasureId,
    @tiCalcSignFact,
    @iSourceId,
    @tiDecodeId,
    @vcComment,
    @vcTariffGroupId,
    @iEditcountbegin,
    @iEditcount,
    @iAddQuantity,
    @tiStatus,
    @vcFactoryNumber,
    @siCounterTypeId,
    @tiAuditMethodId,
    @dfCalcFactor,
    @dfCapacity,
    @vcKnotOut,
    @vcKnotMain,
    @tiSubstationTypeId,
    @siSubstationId,
    @tiSectionId,
    @vcIndexF24Id,
    @iAccountOwnerId,
    @tiServId,
    @siSignLock,
    @iNodeId,
    @iAddHCP,
    @iAddQnt
    )
---------------
IF @@ERROR<>0
BEGIN
  ROLLBACK TRANSACTION
  SELECT
    RTC=@iRTC
  RETURN
END
---------------

  FETCH NEXT FROM curTmpCalc  INTO   @tiCalcTypeId, @iTariffId, @dfTariffValue,
  @iCalcQuantity, @dfSumCalc, @tiMeasureId, @tiCalcSignFact, @iSourceId,
  @tiDecodeId, @vcComment, @vcTariffGroupId, @iEditcountbegin, @iEditcount,
  @iAddQuantity, @tiStatus, @vcFactoryNumber, @siCounterTypeId,
  @tiAuditMethodId, @dfCalcFactor, @dfCapacity, @vcKnotOut, @vcKnotMain,
  @tiSubstationTypeId, @siSubstationId, @tiSectionId, @vcIndexF24Id,
  @iAccountOwnerId,@tiServId,@siSignLock,@iNodeId,@iAddHCP,@iAddQnt
END
CLOSE curTmpCalc
DEALLOCATE curTmpCalc



--  Обработка ДопСумм текущего периода
SELECT
  @dfSumAdd     = Convert(Decimal(18,2),IsNull(SUM(CD.SUM_CALC),0)),
  @iAddQuantity = Convert(Integer,IsNull(SUM(CD.CALC_QUANTITY),0))
FROM
  ProCalcDetails CD (NoLock)
WHERE
  CD.CALC_ID    =  @iCalcId AND
  CD.DECODE_ID  = @tiAddDecodeId AND
  CD.SOURCE_ID  <> 0 AND
  CD.SOURCE_ID  = @iCalcId

SELECT
  @dfSumExcise=Round(IsNull((IsNull(@iAllQuantity,0)+IsNull(@iAddQuantity,0))*
                IsNull(@dfExciseTax,0),0),2)
SELECT
  @dfSumAddCostTax=Round(IsNull((IsNull(@dfSumCount,0)+IsNull(@dfSumReactive,0)+
                    IsNull(@dfSumCapacity,0)+IsNull(@dfSumAdd,0)+IsNull(@dfSumExcise,0))*
                    IsNull(@dfAddCostTax,0)/100,0),2)

-- Третий update ProCalcs
--  Закоментировано при оптимизации
-- для объединения update-ов ProCalcs рпи
-- обработке доп. сумм текущего и др. периодов

UPDATE
  ProCalcs
 SET
  SUM_FACT=IsNull(@dfSumCapacity,0)+
   IsNull(@dfSumCount,0)+
   IsNull(@dfSumReactive,0)+
   IsNull(@dfSumAdd,0),
  SUM_ADD=IsNull(@dfSumAdd,0),
  SUM_NDS=@dfSumAddCostTax,
  SUM_EXC=@dfSumExcise,
  SUM_ALL=IsNull(@dfSumCapacity,0)+
   IsNull(@dfSumCount,0)+
   IsNull(@dfSumReactive,0)+
   IsNull(@dfSumAdd,0)+
   IsNull(@dfSumAddCostTax,0)+
   IsNull(@dfSumExcise,0)-
   IsNull(@dfAdvanceOld,0)+
   IsNull(@dfAdvanceNew,0)+
   IsNull(@dfSumPeni,0),
  QNT_ALL=IsNull(@iAllQuantity,0)+IsNull(@iAddQuantity,0),
  ADD_COST_TAX=IsNull(@dfAddCostTax,0),
  EXCISE_TAX=IsNull(@dfExciseTax,0)
 WHERE
  CALC_ID=@iCalcId

Print '*3'
Print     @dfSumCapacity
Print     @dfSumCount
Print     @dfSumReactive
Print     @dfSumAdd
Print     @dfSumAddCostTax
Print     @dfSumExcise

-- Обработка ДопСумм других периодов
IF Exists
  (SELECT *
    FROM TempDB..SysObjects
    WHERE id = OBJECT_ID('TempDB..#TmpAddCalcs')
  )
  DROP TABLE
    #TmpAddCalcs

----------------------------------------------------
-- Заменено при оптимизации (Матесов Д., 19.08.2004)
----------------------------------------------------

create table #TmpAddCalcs
(
 [SOURCE_ID] VarChar(20),
 [DATE_CALC] datetime not null,
 [SUM_ADD]   Decimal(18,2) null,
 [SUM_NDS]   Decimal(18,2) null,
 [SUM_EXC]   Decimal(18,2) null,
 [QNT_ALL]   Integer null,
 [ADD_COST_TAX] decimal(9,2) null,
 [EXCISE_TAX] decimal(9,2) null
)

insert into #TmpAddCalcs
SELECT
  SOURCE_ID = Convert(VarChar(20),CD.SOURCE_ID),
  DATE_CALC = (SELECT C.DATE_CALC
               FROM   ProCalcs C (NoLock)
               WHERE  C.CALC_ID = CD.SOURCE_ID),
  SUM_ADD   = Convert(Decimal(18,2),IsNull(SUM(CD.SUM_CALC),0)),
  SUM_NDS   = Convert(Decimal(18,2),0),
  SUM_EXC   = Convert(Decimal(18,2),0),
  QNT_ALL   = Convert(Integer,IsNull(SUM(CD.CALC_QUANTITY),0)),
  ADD_COST_TAX = (SELECT CA.ADD_COST_TAX
                  FROM   ProCalcs CA (NoLock)
                  WHERE  CA.CALC_ID = CD.SOURCE_ID),
  EXCISE_TAX = (SELECT CE.EXCISE_TAX
                FROM ProCalcs CE (NoLock)
                WHERE CE.CALC_ID = CD.SOURCE_ID) 
 FROM
  ProCalcDetails CD (NoLock)
 WHERE
  CD.CALC_ID   = @iCalcId       AND
  CD.DECODE_ID = @tiAddDecodeId AND
  CD.SOURCE_ID <> 0             AND
  CD.SOURCE_ID <> @iCalcId
 GROUP BY
  CD.SOURCE_ID

-- Старый код
/*
SELECT
  SOURCE_ID=Convert(VarChar(20),CD.SOURCE_ID),
  DATE_CALC=
   (SELECT
     C.DATE_CALC
    FROM
     ProCalcs C (NoLock)
    WHERE
     C.CALC_ID=CD.SOURCE_ID),
  SUM_ADD=Convert(Decimal(18,2),IsNull(SUM(CD.SUM_CALC),0)),
  SUM_NDS=Convert(Decimal(18,2),0),
  SUM_EXC=Convert(Decimal(18,2),0),
  QNT_ALL=Convert(Integer,IsNull(SUM(CD.CALC_QUANTITY),0)),
  ADD_COST_TAX=
    (SELECT
       CA.ADD_COST_TAX
      FROM
       ProCalcs CA (NoLock)
      WHERE
       CA.CALC_ID=CD.SOURCE_ID),
  EXCISE_TAX=
    (SELECT
       CE.EXCISE_TAX
      FROM
       ProCalcs CE (NoLock)
      WHERE
       CE.CALC_ID=CD.SOURCE_ID) 
 INTO
  #TmpAddCalcs
 FROM
  ProCalcDetails CD (NoLock)
 WHERE
  CD.CALC_ID=@iCalcId AND
  CD.DECODE_ID=@tiAddDecodeId AND
  CD.SOURCE_ID<>0 AND
  CD.SOURCE_ID<>@iCalcId
 GROUP BY
  CD.SOURCE_ID
*/
--------------------------------------------------


UPDATE
  #TmpAddCalcs
 SET
  SUM_EXC=Round(T.QNT_ALL*T.EXCISE_TAX,2),
  SUM_NDS=Round(((T.SUM_ADD+
   Round((CASE WHEN T.DATE_CALC<'2000-09-01' THEN 0 ELSE T.QNT_ALL END)*T.EXCISE_TAX,2))/
   100.00)*T.ADD_COST_TAX,2)
 FROM
  #TmpAddCalcs T

---------------
IF @@ERROR<>0
BEGIN
  ROLLBACK TRANSACTION
  SELECT
    RTC=@iRTC
  RETURN
END
---------------
-- объявляем дополнительные переменные
-- для объединения update-ов ProCalcs рпи
-- обработке доп. сумм текущего и др. периодов
------------------------------------------------
/*
declare
  @dfSumAdd1       Decimal(18,2),
  @dfsumAddNDS1    Decimal(18,2),
  @dfSumAddExcise1 Decimal(18,2),
  @iAddQuantity1   int 
*/
SELECT
  @dfSumAdd       = SUM(SUM_ADD),
  @dfsumAddNDS    = SUM(SUM_NDS),
  @dfSumAddExcise = SUM(SUM_EXC),
  @iAddQuantity   = SUM(QNT_ALL)
 FROM
  #TmpAddCalcs (NoLock)

SELECT
  @tiCalcTypeId=CALC_TYPE_ID
 FROM
  ProCalcTypes (NoLock)
 WHERE
  CALC_TYPE_NAME='А к ц и з'
Print '*А к ц и з='
Print @tiCalcTypeId

SELECT
  @iAllQuantity=@iAllQuantity+IsNull(@iAddQuantity,0),
  @dfSumExcise=@dfSumExcise+IsNull(@dfSumAddExcise,0)
--  @iAllQuantity=@iAllQuantity+IsNull(@iAddQuantity1,0),
--  @dfSumExcise=@dfSumExcise+IsNull(@dfSumAddExcise1,0)


SELECT @iCalcDetailId=@iCalcDetailId+1
INSERT
  ProCalcDetails
  (CALC_ID,
   CALC_DETAIL_ID,
   CALC_TYPE_ID,
   TARIFF_ID,
   TARIFF_VALUE,
   CALC_QUANTITY,
   SUM_CALC,
   MEASURE_ID,
   CALC_SIGN_FACT,
   SOURCE_ID,
   DECODE_ID,
   COMMENT)
 VALUES
  (@iCalcId,
   @iCalcDetailId,
   @tiCalcTypeId,
   Null,
   IsNull(@dfExciseTax,0),
   IsNull(@iAllQuantity,0),
   @dfSumExcise,
   Null,
   0,
   @iContractId,
   Null,
   'Акциз'+@vcStamp)

--   *****************************

SELECT
  @tiCalcTypeId=CALC_TYPE_ID
 FROM
  ProCalcTypes (NoLock)
 WHERE
  CALC_TYPE_NAME='НДС'
Print '*НДС='
Print @tiCalcTypeId

SELECT
  @dfSumAddCostTax=@dfSumAddCostTax+IsNull(@dfsumAddNDS,0)
--  @dfSumAddCostTax=@dfSumAddCostTax+IsNull(@dfsumAddNDS1,0)

SELECT @iCalcDetailId=@iCalcDetailId+1
INSERT
  ProCalcDetails
  (CALC_ID,
   CALC_DETAIL_ID,
   CALC_TYPE_ID,
   TARIFF_ID,
   TARIFF_VALUE,
   CALC_QUANTITY,
   SUM_CALC,
   MEASURE_ID,
   CALC_SIGN_FACT,
   SOURCE_ID,
   DECODE_ID,
   COMMENT)
 VALUES
  (@iCalcId,
   @iCalcDetailId,
   @tiCalcTypeId,
   Null,
   Null,
   Null,
   @dfSumAddCostTax,
   Null,
   0,
   @iContractId,
   Null,
   'НДС'+@vcStamp)

Print '*4'
Print     @dfSumCapacity
Print     @dfSumCount
Print     @dfSumReactive
Print     @dfSumAdd
Print     @dfSumAddCostTax
Print     @dfSumExcise


-- Четвертый update ProCalcs

UPDATE
  ProCalcs
 SET
  SUM_FACT=SUM_FACT+IsNull(@dfSumAdd,0),
  SUM_ADD=IsNull(@dfSumAdd,0),
  SUM_NDS=SUM_NDS+IsNull(@dfSumAddNDS,0),
  SUM_EXC=SUM_EXC+IsNull(@dfSumAddExcise,0),
  SUM_ALL=SUM_ALL+
   IsNull(@dfSumAdd,0)+
   IsNull(@dfSumAddNDS,0)+
   IsNull(@dfSumAddExcise,0),
  QNT_ALL=QNT_ALL+IsNull(@iAddQuantity,0)
 WHERE
  CALC_ID=@iCalcId

/*
-- Объединенные четвертый и третий Updatet-ы ProCalcs

UPDATE
  ProCalcs
 SET
  SUM_FACT = IsNull(@dfSumCapacity,0)+
             IsNull(@dfSumCount,0)+
             IsNull(@dfSumReactive,0)+
             IsNull(@dfSumAdd,0) +
             --------------------------|
             IsNull(@dfSumAdd1,0),   --| -- доп суммы др. периодов
             --------------------------|
  SUM_ADD  = IsNull(@dfSumAdd,0) +
             --------------------------|
             IsNull(@dfSumAdd1,0),   --| 
             --------------------------|
  SUM_NDS  = @dfSumAddCostTax + 
             --------------------------|
             IsNull(@dfSumAddNDS1,0),--|
             --------------------------|
  SUM_EXC  = @dfSumExcise +
             -----------------------------| 
             IsNull(@dfSumAddExcise1,0),--|
             -----------------------------|
  SUM_ALL  = IsNull(@dfSumCapacity,0)+
             IsNull(@dfSumCount,0)+
             IsNull(@dfSumReactive,0)+
             IsNull(@dfSumAdd,0)+
             IsNull(@dfSumAddCostTax,0)+
             IsNull(@dfSumExcise,0)-
             IsNull(@dfAdvanceOld,0)+
             IsNull(@dfAdvanceNew,0)+
             IsNull(@dfSumPeni,0)+
             ------------------------------|
             IsNull(@dfSumAdd1,0)+       --|
             IsNull(@dfSumAddNDS1,0)+    --|
             IsNull(@dfSumAddExcise1,0), --|
             ------------------------------|
  QNT_ALL  = IsNull(@iAllQuantity,0)+
             IsNull(@iAddQuantity,0)+
             ------------------------------|
             IsNull(@iAddQuantity1,0),   --|
             ------------------------------|
  ADD_COST_TAX=IsNull(@dfAddCostTax,0),
  EXCISE_TAX=IsNull(@dfExciseTax,0)
 WHERE
  CALC_ID=@iCalcId

*/
---------------
IF @@ERROR<>0
BEGIN
  ROLLBACK TRANSACTION
  SELECT
    RTC=@iRTC
  RETURN
END
---------------
SET NOCOUNT OFF
Print '*End*'

COMMIT TRANSACTION

SELECT @iRTC=1

------------------------------
-- Удаление временных таблиц 
-- Матесов Д.
IF Exists (SELECT * FROM TempDB..SysObjects WHERE id = OBJECT_ID('TempDB..#TmpTval'))
  DROP TABLE #TmpTval

IF Exists (SELECT * FROM TempDB..SysObjects WHERE id = OBJECT_ID('TempDB..#TmpPnt'))
  DROP TABLE #TmpPnt

IF Exists (SELECT * FROM TempDB..SysObjects WHERE id = OBJECT_ID('TempDB..#TmpPQua'))
  DROP TABLE #TmpPQua

IF Exists (SELECT * FROM TempDB..SysObjects WHERE id = OBJECT_ID('TempDB..#TmpCalc'))
  DROP TABLE #TmpCalc

IF Exists (SELECT * FROM TempDB..SysObjects WHERE id = OBJECT_ID('TempDB..#TmpQRea'))
  DROP TABLE #TmpQRea

IF Exists (SELECT * FROM TempDB..SysObjects WHERE id = OBJECT_ID('TempDB..#TmpAddCalcs'))
  DROP TABLE #TmpAddCalcs

------------------------------
SELECT
  RTC=@iRTC


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

