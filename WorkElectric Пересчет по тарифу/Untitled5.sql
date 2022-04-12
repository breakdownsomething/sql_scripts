declare
@iAccountId	  int,
@tiServId     tinyint

select
@iAccountId	 = 11088,
@tiServId    = 13



DECLARE
	@sdtBeginDate		smalldatetime,
	@tiMainServId		tinyint
SELECT
	@sdtBeginDate		=CONVERT(smalldatetime,'08.01.1998'),
	@tiMainServId		=13


IF  EXISTS (select * from Tempdb..sysobjects where id = object_id('Tempdb..#ShowPays') )
    TRUNCATE  table #ShowPays
ELSE
    CREATE TABLE  #ShowPays
(
DATE_ID			smalldatetime,
LABEL_NUMBER		int,
RECIEPT_NUMBER	smallint,
COUNT_PAY		int,
SUM_PAY		decimal(9,2)	NULL,
LAST_COUNT		int		NULL,
PREC			smallint		NULL,
FACTORY_NUMBER	varchar(12)	NULL,
COMMENT		varchar(255)	NULL
)









INSERT INTO
	#ShowPays
SELECT
	DATE_ID=DRP.DATE_ID,
	LABEL_NUMBER=DRP.LABEL_NUMBER,
	RECIEPT_NUMBER=DRP.RECIEPT_NUMBER,
	COUNT_PAY=DRP.COUNT_PAY,
	SUM_PAY=DRP.SUM_PAY,
	LAST_COUNT=RP.LAST_COUNT,
        PREC=NULL,
        FACTORY_NUMBER=NULL,
	SOURCE_PAYS_NAME=CASE
			 WHEN  ((R.LABEL_NUMBER/1000000000)=1) THEN
				(SELECT
					SOURCE_PAYS_NAME
				 FROM
					OutSideSources(NOLOCK)
				 WHERE
					SOURCE_PAYS_ID=CONVERT(smallint,SUBSTRING
				        (CONVERT(varchar(10),R.LABEL_NUMBER),2,4)))
			 WHEN  ((R.LABEL_NUMBER/1000000000)=2) THEN
				(SELECT
					CASE WHEN PATINDEX('%[^0-9 ]%',OSR.COMMENT)<>0 THEN
					OSR.COMMENT
					ELSE 'ПЛАТ.ПОРУЧ.№ ' + OSR.COMMENT
					END
				 FROM
					OutSideRcp OSR(NOLOCK)
				 WHERE
					OSR.YEAR = YEAR(R.DATE_ID)	AND
					OSR.MONTH = MONTH(R.DATE_ID)	AND
					OSR.DAY = DAY(R.DATE_ID)	AND
					OSR.LABEL_NUMBER = R.LABEL_NUMBER - 2*POWER(10,9)	AND
					OSR.RECIEPT_NUMBER = R.RECIEPT_NUMBER--	AND
				)
			ELSE 'АЛСЕКО'
			END
FROM
	Rcp			 R(NOLOCK),
	RcpPays	                 RP(NOLOCK),
	DayRcpPays               DRP(NOLOCK)
WHERE
	R.ACCOUNT_ID=@iAccountId        				AND
	RP.DATE_ID=R.DATE_ID						AND
  	RP.LABEL_NUMBER=R.LABEL_NUMBER				
	AND
	RP.RECIEPT_NUMBER=R.RECIEPT_NUMBER				AND
	RP.SERV_ID=@tiServId						AND
	DRP.DATE_ID=RP.DATE_ID						AND
  	DRP.LABEL_NUMBER=RP.LABEL_NUMBER				AND
	DRP.RECIEPT_NUMBER=RP.RECIEPT_NUMBER				AND
	DRP.SERV_ID=RP.SERV_ID
/*IF EXISTS(SELECT
		 *
	  FROM
	   	 EditPayCounts(NOLOCK)
	  WHERE
		 ACCOUNT_ID=@iAccountId	AND
		 SERV_ID=@tiServId)*/
  INSERT INTO
	#ShowPays
  SELECT
	DATE_ID=EPC.DATE_ID,-8,-8,
	EDIT_PAY_COUNT=EPC.EDIT_PAY_COUNT,NULL,-8,
        PREC=NULL,
        FACTORY_NUMBER=NULL,
        COMMENT=/*CASE -- (18-05-2004 временно отключил Шибицкий В.)
                    WHEN
                       EXISTS
                       (
                       SELECT
                             	*
                       FROM
                           	EditRecords (NOLOCK)
                       WHERE
                            	ACCOUNT_ID=@iAccountId   		AND
                                TABLE_ID=103000				AND
                                FIELD_ID=5				AND
                                EDIT_SIGN=2				AND
                                ADD_KEYS=CONVERT(varchar(3),@tiServId)
                                +','+
                                CONVERT(varchar(10),
                                DATEDIFF(dd,@sdtBeginDate,EPC.DATE_ID))
                       )
                    THEN
                      '(*)'+U.FULL_NAME+'('+
                      CONVERT(varchar(10),EL.DATE_TIME_BEGIN,104)+
                      ')'+' '+EPC.COMMENTS
                    ELSE*/
                      U.FULL_NAME+'('+
                      CONVERT(varchar(10),EL.DATE_TIME_BEGIN,104)+
                      ')'+' '+EPC.COMMENTS
--                END
FROM
	EditPayCounts	EPC(NOLOCK),
	EditLabels	EL(NOLOCK),
	Users		U(NOLOCK)
WHERE
	EPC.ACCOUNT_ID=@iAccountId		AND
	EPC.SERV_ID=@tiServId                   AND
	EPC.ERROR_SIGN=0			AND
	EPC.LABEL_NUMBER=EL.LABEL_NUMBER	AND
	EL.USER_ID=U.USER_ID
/*ELSE
  INSERT INTO
	#ShowPays
  SELECT
	DATE_ID=CONVERT(smalldatetime,'08.01.1998'),-8,-8,
	EDIT_PAY_COUNT=0,NULL,-8,
        PREC=NULL,
        FACTORY_NUMBER=NULL,
	COMMENT='Начальный ноль'*/
INSERT INTO
	#ShowPays
SELECT
	DATE_ID=CASE
			WHEN CAD.ACTION_ID IN (9,22) THEN CAD.DATE_ID
			ELSE DATEADD(mi, 10, CAD.DATE_ID)
		END,
	0,0,
	COUNT_PAY=CAI.CHECK_COUNT,NULL,
	LAST_COUNT=CASE CAD.ACTION_ID
			WHEN 1  THEN -3
			WHEN 9  THEN -1
			WHEN 10 THEN -5
			WHEN 22 THEN -1
			WHEN 7 THEN -1
		     END,
        PREC=CASE ISNULL(CT.PREC-CT.SCALE,0)
                  WHEN 0  THEN -1
             ELSE
                  (CT.PREC-CT.SCALE)
             END,
        FACTORY_NUMBER=C.FACTORY_NUMBER,
	COMMENT=CASE 
			WHEN CAD.ACTION_ID=1  THEN 'Установка'
			WHEN CAD.ACTION_ID=9  THEN 'Снятие показаний'
			WHEN CAD.ACTION_ID=10 THEN 'Снятие'
			WHEN CAD.ACTION_ID=22 AND CAD.TYPICAL_CASE_ID=52 THEN 'Показания со слов абонента'
			WHEN CAD.ACTION_ID=22 THEN 'Проверка'
			WHEN CAD.ACTION_ID=7 THEN 'Отключение'
		     END
FROM
	CntActionDates		CAD(NOLOCK),
      	CntActionIndications	CAI(NOLOCK),
	Cnt	C (NOLOCK),
	CntTypes	CT(NOLOCK)
WHERE
	CAD.ACCOUNT_ID=@iAccountId					AND
	(CAD.ACTION_ID IN (1,9,10,22,7))	AND
	CAD.DELETE_SIGN=0                                               AND
	CAI.ACCOUNT_ID=CAD.ACCOUNT_ID					AND
	CAI.ACTION_ID=CAD.ACTION_ID					AND
	CAI.DATE_ID=CAD.DATE_ID						AND
	CAI.COUNTER_NUMBER_ID=CAD.COUNTER_NUMBER_ID  			AND
	CAI.SERV_ID=@tiServId                                   AND
	C.ACCOUNT_ID=CAI.ACCOUNT_ID				AND
	C.COUNTER_NUMBER_ID=CAI.COUNTER_NUMBER_ID		AND
	CT.COUNTER_TYPE_ID=*C.COUNTER_TYPE_ID

INSERT INTO
	#ShowPays
SELECT
	DATE_ID=DATEADD(mi, 10, CAD.DATE_ID),
	0,0,
	COUNT_PAY=0,NULL,
	LAST_COUNT=-12,
        PREC=NULL,
        FACTORY_NUMBER=NULL,
	COMMENT='Подключение'
FROM
	CntActionDates		CAD(NOLOCK)
WHERE
	CAD.ACCOUNT_ID=@iAccountId					AND
	CAD.ACTION_ID =8						AND
	CAD.DELETE_SIGN=0
INSERT INTO
	#ShowPays
SELECT
  DATEADD(mi, 10, CAD.DATE_ID),
  0,
  0,
  CAI.CHECK_COUNT,
  NULL,
    LAST_COUNT=
    CASE
	WHEN (SELECT
		MAX(CAD2.COUNTER_NUMBER_ID)
	      FROM
		CntActionDates	CAD2(NOLOCK)
	      WHERE
		CAD2.ACCOUNT_ID=CAD.ACCOUNT_ID			AND
		CAD2.DATE_ID=CAD.DATE_ID			AND
		CAD2.ACTION_ID=CAD.ACTION_ID)=CAD.COUNTER_NUMBER_ID
		THEN -4
		ELSE -6
     END,
  PREC=CASE ISNULL(CT.PREC-CT.SCALE,0)
               WHEN 0  THEN -1
       ELSE
            (CT.PREC-CT.SCALE)
       END,
  FACTORY_NUMBER=C.FACTORY_NUMBER,
  ''
FROM
	CntActionDates	CAD(NOLOCK),
	CntActionIndications  CAI(NOLOCK),
	Cnt		C (NOLOCK),
	CntTypes	CT(NOLOCK)
WHERE
	CAD.ACCOUNT_ID=@iAccountId	AND
	CAD.ACTION_ID=2			AND
	CAD.DELETE_SIGN=0               AND
	CAI.ACCOUNT_ID=CAD.ACCOUNT_ID	AND
	CAI.ACTION_ID=CAD.ACTION_ID	AND
	CAI.COUNTER_NUMBER_ID=CAD.COUNTER_NUMBER_ID AND
	CAI.DATE_ID=CAD.DATE_ID		AND
	CAI.SERV_ID=@tiServId           AND
	C.ACCOUNT_ID=CAI.ACCOUNT_ID				AND
	C.COUNTER_NUMBER_ID=CAI.COUNTER_NUMBER_ID		AND
	CT.COUNTER_TYPE_ID=*C.COUNTER_TYPE_ID
INSERT INTO
	#ShowPays
SELECT
	DATEADD(mi, 10, CAD.DATE_ID),-7,-7,0,NULL,-7,-1,NULL,'Несанкционированное снятие'
FROM
	CntActionDates		CAD (NOLOCK),
	Cnt			C   (NOLOCK),
	CntTypes		CT  (NOLOCK),
	CntTypeClassServices	CTCS(NOLOCK)
WHERE
	CAD.ACCOUNT_ID=@iAccountId		AND
	C.ACCOUNT_ID=CAD.ACCOUNT_ID	AND
	C.COUNTER_NUMBER_ID=CAD.COUNTER_NUMBER_ID AND
	CT.COUNTER_TYPE_ID=ISNULL(C.COUNTER_TYPE_ID,@tiServId)  AND
	CTCS.COUNTER_TYPE_CLASS_ID=CT.COUNTER_TYPE_CLASS_ID  AND
	CTCS.SERV_ID=@tiServId          AND
	CAD.ACTION_ID=10		AND
        CAD.DELETE_SIGN=0		AND
	NOT EXISTS (SELECT
			*
		   FROM
			aspElectric..CntActionIndications(NOLOCK)
		   WHERE
			ACCOUNT_ID=CAD.ACCOUNT_ID	AND
			DATE_ID=CAD.DATE_ID		AND
			COUNTER_NUMBER_ID=CAD.COUNTER_NUMBER_ID	AND
			ACTION_ID=CAD.ACTION_ID		AND
			SERV_ID=@tiServId)
INSERT INTO
	#ShowPays
SELECT
	RDR.RMV_DATE,RDR.LABEL_NUMBER_OLD,RDR.RECIEPT_NUMBER_OLD,
	RDRP.COUNT_PAY,RDRP.SUM_PAY,-2,
        NULL,NULL,
	COMMENT=CASE
			WHEN ((RDR.LABEL_NUMBER_OLD/1000000000)<1)
			THEN 'Перерасчёт АЛСЕКО('+
			CONVERT(varchar(10),RDRP.DATE_ID,104)+')'
		ELSE
			'Перерасчёт ПАРАСАТ('+
                        CONVERT(varchar(10),RDRP.DATE_ID,104)+')'
	        END
FROM
	RmvDayRcpPays	RDRP(NOLOCK),
	RmvDayRcp	RDR(NOLOCK)
WHERE
	RDRP.ACCOUNT_ID=@iAccountId       AND
	RDRP.SERV_ID=@tiServId  	  AND
	RDRP.DATE_ID=RDR.DATE_ID	  AND
	RDRP.LABEL_NUMBER_OLD=RDR.LABEL_NUMBER_OLD	AND
	RDRP.RECIEPT_NUMBER_OLD=RDR.RECIEPT_NUMBER_OLD  AND
	RDRP.RMV_DATE=RDR.RMV_DATE
IF   @tiServId=@tiMainServId
    BEGIN
          INSERT INTO
	 #ShowPays
          SELECT
	DATE_ID=CSQP.DATE_ID,-10,-10,
	SET_QUANTITY_POWER=CSQP.SET_QUANTITY_POWER,NULL,-10,
                  PREC=NULL,
                  FACTORY_NUMBER=NULL,
                 COMMENT='Начало УМ['+CONVERT(varchar(20),CSQP.SET_QUANTITY_POWER)+
                 ' кВт]'+U.FULL_NAME+'('+
                CONVERT(varchar(10),EL.DATE_TIME_BEGIN,104)+
                ')'+CSQP.COMMENTS
        FROM
	CntSetQuantityPowers	CSQP(NOLOCK),
	EditLabels	        EL(NOLOCK),
	Users		        U(NOLOCK)
       WHERE
	CSQP.ACCOUNT_ID=@iAccountId     	AND
	CSQP.ERROR_SIGN=0			AND
	CSQP.LABEL_NUMBER=EL.LABEL_NUMBER	AND
	EL.USER_ID=U.USER_ID

       INSERT INTO
	#ShowPays
       SELECT
	DATE_END=ISNULL(CSQP.DATE_END,GetDate()),-9,-9,
	SET_QUANTITY_POWER=CSQP.SET_QUANTITY_POWER,NULL,-9,
                  PREC=NULL,
                  FACTORY_NUMBER=NULL,
                 COMMENT='Конец  УМ['+CONVERT(varchar(20),CSQP.SET_QUANTITY_POWER)+
                ' кВт]'+U.FULL_NAME+'('+
                CONVERT(varchar(10),EL.DATE_TIME_BEGIN,104)+
                ')'+CSQP.COMMENTS
      FROM                              
	CntSetQuantityPowers	CSQP(NOLOCK),
	EditLabels	        EL(NOLOCK),
	Users		        U(NOLOCK)
      WHERE
	CSQP.ACCOUNT_ID=@iAccountId     	AND
	CSQP.ERROR_SIGN=0			AND
	CSQP.LABEL_NUMBER=EL.LABEL_NUMBER	AND
	EL.USER_ID=U.USER_ID
END
INSERT INTO
	#ShowPays
  SELECT
	DATE_ID=RE.DATE_ID,-11,-11,
	0,NULL,-11,
        PREC=NULL,
        FACTORY_NUMBER=NULL,
        COMMENT='Печать счёта ('+F.FORM_NAME+')'
FROM
	RcpExposed	RE(NOLOCK),
	Forms	                    F(NOLOCK)
WHERE
	RE.ACCOUNT_ID=@iAccountId	AND
        RE.SERV_ID=@tiServId            AND
	F.FORM_ID=RE.FORM_ID
INSERT INTO
	#ShowPays
SELECT
	DATE_ID=CN.DATE_ID,-12,-12,
	EDIT_PAY_COUNT=0,NULL,-12,
        PREC=NULL,
        FACTORY_NUMBER=NULL,
        COMMENT=CN.COMMENTS+'('+U.FULL_NAME+'-'+
                CONVERT(varchar(10),EL.DATE_TIME_BEGIN,104)+')'
FROM
	ConsumerNotes	CN(NOLOCK),
	EditLabels	EL(NOLOCK),
	Users		U(NOLOCK)
WHERE
	CN.ACCOUNT_ID=@iAccountId		AND
	CN.ERROR_SIGN=0		         	AND
	EL.LABEL_NUMBER=CN.LABEL_NUMBER	        AND
	U.USER_ID=EL.USER_ID

INSERT INTO
	#ShowPays
SELECT
	DATE_ID=AAD.DATE_ID,-12,-12,
	EDIT_PAY_COUNT=0,NULL,-12,
        PREC=NULL,
        FACTORY_NUMBER=NULL,
        COMMENT=AL.ELECTRICIAN_ACTION_NAME + ' (АПК РКТ ' +
	U.FULL_NAME+')'
FROM
	aspHeat..AdviceActionDates	AAD(NOLOCK),
	aspHeat..HeatElectricianActionList AL(NOLOCK),
	aspHeat..Users U(NOLOCK)
WHERE
	AAD.ACCOUNT_ID = @iAccountId	AND
	AAD.DELETE_SIGN = 0	AND
	AL.ELECTRICIAN_ACTION_ID = AAD.ELECTRICIAN_ACTION_ID	AND
	U.USER_ID=AAD.USER_ID

INSERT INTO #ShowPays
SELECT
	CASE YEAR(DATE_ID)
	WHEN YEAR(GETDATE()) THEN convert(smalldatetime,GETDATE())
	ELSE convert(smalldatetime,convert(varchar(4),YEAR(DATE_ID))+'-12-31',21) END,
	-13,-13, SUM(COUNT_PAY), SUM(SUM_PAY),-13,
        PREC=NULL,
        FACTORY_NUMBER=NULL,
        COMMENT='Итого за '+convert(varchar(4),YEAR(DATE_ID))+' г.'
FROM
	#ShowPays	SP(NOLOCK)
WHERE
	LAST_COUNT >= 0	OR
	LAST_COUNT = -2
GROUP BY
	YEAR(DATE_ID),
	'Итого за '+convert(varchar(4),YEAR(DATE_ID))+' г.',
	CASE YEAR(DATE_ID)
	WHEN YEAR(GETDATE()) THEN convert(smalldatetime,GETDATE())
	ELSE convert(smalldatetime,convert(varchar(4),YEAR(DATE_ID))+'-12-31',21) END
--DATE_ID LABEL_NUMBER RECIEPT_NUMBER COUNT_PAY SUM_PAY LAST_COUNT PREC FACTORY_NUMBER COMMENT

select * from #ShowPays
order by date_id desc