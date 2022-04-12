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
         WHERE id = object_id('#TmpPart')
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
  ProAbonents Ab (NoLock)
 WHERE
  Cn.GROUP_ID=@siGroupId
  AND
  Cn.SUBGROUP_ID=@siSubGroupId
  AND
  Ab.ABONENT_ID=Cn.ABONENT_ID
*/


--------------------------------------------------------------
DECLARE
        @DatEnd SmallDateTime,
        @CURRENT_DATE smalldatetime
SELECT
        @DatEnd='2004-09-30'--:pDatEnd

select @CURRENT_DATE = (select top 1 date_calc_end from ProGroups)


  CREATE TABLE #TmpLimit (
	  RES varchar (2) NULL ,
	  ABONENT_NAME varchar (80) NOT NULL ,
	  CONTRACT_ID int NOT NULL ,
	  CONTRACT_NUMBER varchar (10) NOT NULL ,
	  TARIFF_ID int NOT NULL ,
	  TARIFF_VALUE decimal(5, 2) NULL ,
	  QNT1 decimal(12, 2) NOT NULL ,
	  QNT2 decimal(12, 2) NOT NULL ,
	  QNT3 decimal(12, 2) NOT NULL ,
	  QNT4 decimal(12, 2) NOT NULL ,
	  QNT5 decimal(12, 2) NOT NULL ,
	  QNT6 decimal(12, 2) NOT NULL ,
	  QNT7 decimal(12, 2) NOT NULL ,
	  QNT8 decimal(12, 2) NOT NULL ,
	  QNT9 decimal(12, 2) NOT NULL ,
	  QNT10 decimal(12, 2) NOT NULL ,
	  QNT11 decimal(12, 2) NOT NULL ,
	  QNT12 decimal(12, 2) NOT NULL ,
	  SUBGROUP_NAME char (50) NULL )

if @DatEnd = @CURRENT_DATE
begin
  INSERT INTO #TmpLimit
  SELECT
	  RES=RIGHT(pc.GROUP_ID,1),
	  pa.ABONENT_NAME,
	  pc.CONTRACT_ID,
	  pc.CONTRACT_NUMBER,
    TARIFF_ID=0,
    TARIFF_VALUE=CONVERT(DECIMAL(5,2),0),
  	QNT1=IsNUll(pl1.QUANTITY,0),
	  QNT2=IsNUll(pl2.QUANTITY,0),
	  QNT3=IsNUll(pl3.QUANTITY,0),
	  QNT4=IsNUll(pl4.QUANTITY,0),
	  QNT5=IsNUll(pl5.QUANTITY,0),
	  QNT6=IsNUll(pl6.QUANTITY,0),
	  QNT7=IsNUll(pl7.QUANTITY,0),
	  QNT8=IsNUll(pl8.QUANTITY,0),
	  QNT9=IsNUll(pl9.QUANTITY,0),
	  QNT10=IsNUll(pl10.QUANTITY,0),
	  QNT11=IsNUll(pl11.QUANTITY,0),
	  QNT12=IsNUll(pl12.QUANTITY,0),
	  pgs.SUBGROUP_NAME
  FROM
	  ProAbonents pa,
	  ProContracts pc,
	  ProGroupSub  pgs,
	  #TmpPart  tp,
	  ProLimits pl1,
	  ProLimits pl2,
	  ProLimits pl3,
	  ProLimits pl4,
	  ProLimits pl5,
	  ProLimits pl6,
	  ProLimits pl7,
	  ProLimits pl8,
	  ProLimits pl9,
	  ProLimits pl10,
	  ProLimits pl11,
	  ProLimits pl12
  WHERE
	  pc.ABONENT_ID=pa.ABONENT_ID	AND
	  pgs.GROUP_ID=pc.GROUP_ID	AND
	  pgs.SUBGROUP_ID=pc.SUBGROUP_ID	AND
	  pc.DATE_CONTRACT_CLOSE IS NULL AND
	  pc.CONSUMER_GROUP_ID in (122,204,205,206,207,208,209,212,215,222,223,224,225,226,227)	AND
	  pc.CONTRACT_ID=tp.CONTRACT_ID AND
	  pl1.CONTRACT_ID=*pc.CONTRACT_ID AND
	  pl2.CONTRACT_ID=*pc.CONTRACT_ID AND
	  pl3.CONTRACT_ID=*pc.CONTRACT_ID AND
	  pl4.CONTRACT_ID=*pc.CONTRACT_ID AND
	  pl5.CONTRACT_ID=*pc.CONTRACT_ID AND
	  pl6.CONTRACT_ID=*pc.CONTRACT_ID AND
	  pl7.CONTRACT_ID=*pc.CONTRACT_ID AND
	  pl8.CONTRACT_ID=*pc.CONTRACT_ID AND
	  pl9.CONTRACT_ID=*pc.CONTRACT_ID AND
	  pl10.CONTRACT_ID=*pc.CONTRACT_ID AND
	  pl11.CONTRACT_ID=*pc.CONTRACT_ID AND
	  pl12.CONTRACT_ID=*pc.CONTRACT_ID AND
	  pl1.MONTH=13 AND
	  pl2.MONTH=14 AND
	  pl3.MONTH=15 AND
	  pl4.MONTH=16 AND
	  pl5.MONTH=17 AND
	  pl6.MONTH=18 AND
	  pl7.MONTH=19 AND
	  pl8.MONTH=20 AND
	  pl9.MONTH=21 AND
	  pl10.MONTH=22 AND
	  pl11.MONTH=23 AND
	  pl12.MONTH=24

  UPDATE #TmpLimit SET TARIFF_ID=pcc.TARIFF_ID,TARIFF_VALUE=convert(decimal(5,2),pcc.TARIFF_VALUE)
  FROM
	  #TmpLimit tl,
	  ProAccounts pa,
	  ProCntCounts pcc
  WHERE
	  pa.CONTRACT_ID=tl.CONTRACT_ID	AND
	  pcc.ACCOUNT_ID=pa.ACCOUNT_ID	AND
	  pcc.DATE_ID=@DatEnd	AND
	  pa.ACCOUNT_ID=(SELECT MIN(ACCOUNT_ID) FROM ProAccounts WHERE CONTRACT_ID=tl.CONTRACT_ID)

  INSERT #TmpLimit (
	  RES,
	  ABONENT_NAME,
	  CONTRACT_ID,
	  CONTRACT_NUMBER,
    TARIFF_ID,
    TARIFF_VALUE,
	  QNT1,
	  QNT2,
	  QNT3,
	  QNT4,
	  QNT5,
	  QNT6,
	  QNT7,
	  QNT8,
	  QNT9,
	  QNT10,
	  QNT11,
	  QNT12,
	  SUBGROUP_NAME)
  SELECT
	  99,
	  '',
	  0,
	  'Итого: ',
    0,
    0,
	  IsNull(SUM(QNT1),0),
	  IsNull(SUM(QNT2),0),
	  IsNull(SUM(QNT3),0),
	  IsNull(SUM(QNT4),0),
	  IsNull(SUM(QNT5),0),
	  IsNull(SUM(QNT6),0),
	  IsNull(SUM(QNT7),0),
	  IsNull(SUM(QNT8),0),
	  IsNull(SUM(QNT9),0),
	  IsNull(SUM(QNT10),0),
	  IsNull(SUM(QNT11),0),
	  IsNull(SUM(QNT12),0),
	  ''
  FROM #TmpLimit

  IF (SELECT TOP 1 RES FROM #TmpLimit)=99
  TRUNCATE TABLE 	#TmpLimit

  SELECT
	  'РЭС'=CASE WHEN RES<>99 THEN convert(varchar(3),RES) ELSE NULL END,
	  'Наименование'=convert(varchar(50),ABONENT_NAME),
	  'Договор'=CONTRACT_NUMBER,
    'Код'=CASE WHEN TARIFF_ID<>0 THEN convert(varchar(3),TARIFF_ID) ELSE NULL END,
    'Тариф'=CASE WHEN TARIFF_VALUE<>0 THEN convert(decimal(5,2),TARIFF_VALUE) ELSE NULL END,
	  'Янв.'=QNT1,
	  'Фев.'=QNT2,
	  'Март'=QNT3,
	  'Апр.'=QNT4,
	  'Май '=QNT5,
	  'Июнь'=QNT6,
	  'Июль'=QNT7,
	  'Авг.'=QNT8,
	  'Сен.'=QNT9,
	  'Окт.'=QNT10,
	  'Ноя.'=QNT11,
	  'Дек.'=QNT12,
	  'Инженер'=SUBGROUP_NAME
  FROM
	  #TmpLimit
  ORDER BY
	  RES,
    RIGHT(space(8)+rtrim(ltrim(CONTRACT_NUMBER)),8)

  DROP TABLE #TmpLimit
end
else
--------  За старые периоды выборка дклается из архивных таблиц  -----
begin
  INSERT INTO #TmpLimit
  SELECT
  	RES=RIGHT(pc.GROUP_ID,1),
	  pa.ABONENT_NAME,
	  pc.CONTRACT_ID,
	  pc.CONTRACT_NUMBER,
    TARIFF_ID=0,
    TARIFF_VALUE=CONVERT(DECIMAL(5,2),0),
	  QNT1=IsNUll(pl1.QUANTITY,0),
	  QNT2=IsNUll(pl2.QUANTITY,0),
	  QNT3=IsNUll(pl3.QUANTITY,0),
	  QNT4=IsNUll(pl4.QUANTITY,0),
	  QNT5=IsNUll(pl5.QUANTITY,0),
	  QNT6=IsNUll(pl6.QUANTITY,0),
	  QNT7=IsNUll(pl7.QUANTITY,0),
	  QNT8=IsNUll(pl8.QUANTITY,0),
	  QNT9=IsNUll(pl9.QUANTITY,0),
	  QNT10=IsNUll(pl10.QUANTITY,0),
	  QNT11=IsNUll(pl11.QUANTITY,0),
	  QNT12=IsNUll(pl12.QUANTITY,0),
	  pgs.SUBGROUP_NAME
  FROM
	  ProAbonentsArc pa,
	  ProContractsArc pc,
	  ProGroupSub  pgs,
	  #TmpPart  tp,
	  ProLimits pl1,
	  ProLimits pl2,
	  ProLimits pl3,
	  ProLimits pl4,
	  ProLimits pl5,
	  ProLimits pl6,
	  ProLimits pl7,
	  ProLimits pl8,
	  ProLimits pl9,
	  ProLimits pl10,
	  ProLimits pl11,
	  ProLimits pl12
  WHERE
	  pc.ABONENT_ID=pa.ABONENT_ID	AND
	  pgs.GROUP_ID=pc.GROUP_ID	AND
	  pgs.SUBGROUP_ID=pc.SUBGROUP_ID	AND
	  pc.DATE_CONTRACT_CLOSE IS NULL AND
	  pc.CONSUMER_GROUP_ID in (122,204,205,206,207,208,209,212,215,222,223,224,225,226,227)	AND
	  pc.CONTRACT_ID=tp.CONTRACT_ID AND
	  pl1.CONTRACT_ID=*pc.CONTRACT_ID AND
	  pl2.CONTRACT_ID=*pc.CONTRACT_ID AND
	  pl3.CONTRACT_ID=*pc.CONTRACT_ID AND
	  pl4.CONTRACT_ID=*pc.CONTRACT_ID AND
	  pl5.CONTRACT_ID=*pc.CONTRACT_ID AND
	  pl6.CONTRACT_ID=*pc.CONTRACT_ID AND
	  pl7.CONTRACT_ID=*pc.CONTRACT_ID AND
	  pl8.CONTRACT_ID=*pc.CONTRACT_ID AND
	  pl9.CONTRACT_ID=*pc.CONTRACT_ID AND
	  pl10.CONTRACT_ID=*pc.CONTRACT_ID AND
	  pl11.CONTRACT_ID=*pc.CONTRACT_ID AND
	  pl12.CONTRACT_ID=*pc.CONTRACT_ID AND
	  pl1.MONTH=13 AND
	  pl2.MONTH=14 AND
	  pl3.MONTH=15 AND
	  pl4.MONTH=16 AND
	  pl5.MONTH=17 AND
	  pl6.MONTH=18 AND
	  pl7.MONTH=19 AND
	  pl8.MONTH=20 AND
	  pl9.MONTH=21 AND
	  pl10.MONTH=22 AND
	  pl11.MONTH=23 AND
	  pl12.MONTH=24
    and pa.date_id = @DatEnd
    and pc.date_begin = pa.date_id

  UPDATE #TmpLimit
    SET TARIFF_ID    = pcd.TARIFF_ID,
        TARIFF_VALUE = convert(decimal(5,2),pcd.TARIFF_VALUE)
  FROM
	  #TmpLimit tl,
	  ProAccountsArc pa  (nolock),
    ProCalcs       pc  (nolock),
    ProCalcDetails pcd (nolock)
  WHERE
	  pa.CONTRACT_ID = tl.CONTRACT_ID	AND
	  pa.ACCOUNT_ID=(SELECT MIN(ACCOUNT_ID)
                   FROM ProAccountsArc (nolock)
                   WHERE CONTRACT_ID=tl.CONTRACT_ID
                         and date_begin = @DatEnd)
    and pa.date_begin  = @DatEnd
    and pc.contract_id = tl.CONTRACT_ID
    and pc.date_calc   = pa.date_begin
    and pcd.calc_id    = pc.calc_id
    and pcd.source_id  = pa.account_id

  INSERT #TmpLimit (
 	  RES,
	  ABONENT_NAME,
	  CONTRACT_ID,
	  CONTRACT_NUMBER,
    TARIFF_ID,
    TARIFF_VALUE,
	  QNT1,
	  QNT2,
	  QNT3,
	  QNT4,
	  QNT5,
	  QNT6,
	  QNT7,
	  QNT8,
	  QNT9,
	  QNT10,
	  QNT11,
	  QNT12,
	  SUBGROUP_NAME)
  SELECT
	  99,
	  '',
	  0,
	  'Итого: ',
    0,
    0,
	  IsNull(SUM(QNT1),0),
	  IsNull(SUM(QNT2),0),
	  IsNull(SUM(QNT3),0),
	  IsNull(SUM(QNT4),0),
	  IsNull(SUM(QNT5),0),
	  IsNull(SUM(QNT6),0),
	  IsNull(SUM(QNT7),0),
	  IsNull(SUM(QNT8),0),
	  IsNull(SUM(QNT9),0),
	  IsNull(SUM(QNT10),0),
	  IsNull(SUM(QNT11),0),
	  IsNull(SUM(QNT12),0),
	  ''
  FROM #TmpLimit

  IF (SELECT TOP 1 RES FROM #TmpLimit)=99
  TRUNCATE TABLE 	#TmpLimit

  SELECT
	  'РЭС'=CASE WHEN RES<>99 THEN convert(varchar(3),RES) ELSE NULL END,
	  'Наименование'=convert(varchar(50),ABONENT_NAME),
	  'Договор'=CONTRACT_NUMBER,
    'Код'=CASE WHEN TARIFF_ID<>0 THEN convert(varchar(3),TARIFF_ID) ELSE NULL END,
    'Тариф'=CASE WHEN TARIFF_VALUE<>0 THEN convert(decimal(5,2),TARIFF_VALUE) ELSE NULL END,
	  'Янв.'=QNT1,
	  'Фев.'=QNT2,
	  'Март'=QNT3,
	  'Апр.'=QNT4,
	  'Май '=QNT5,
	  'Июнь'=QNT6,
	  'Июль'=QNT7,
	  'Авг.'=QNT8,
	  'Сен.'=QNT9,
	  'Окт.'=QNT10,
	  'Ноя.'=QNT11,
	  'Дек.'=QNT12,
	  'Инженер'=SUBGROUP_NAME
  FROM
	  #TmpLimit
  ORDER BY
	  RES,
    RIGHT(space(8)+rtrim(ltrim(CONTRACT_NUMBER)),8)

  DROP TABLE #TmpLimit
end