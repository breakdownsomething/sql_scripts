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
---------------------------------------------------------------------------
DECLARE
	@DatEnd		  SmallDateTime,
  @ACTION_ID int
SELECT
	@DatEnd	='2003-11-30',--:pDatEnd,
  @ACTION_ID = 22 --Проверка

SELECT distinct
  "N дог."           = tp.CONTRACT_NUMBER,
  "Наименование"     = tp.ABONENT_NAME,
	"Код ТУ"           = pa.ACCOUNT_ID,
	"Наименование ТУ"  = convert(varchar(25),pa.ACCOUNT_NAME),
	"№ счетчика"       = pc.FACTORY_NUMBER,
	"Тип счетчика"     = convert(varchar(10),(SELECT COUNTER_TYPE_NAME
                                            FROM CntTypes
                                            WHERE COUNTER_TYPE_ID = pc.COUNTER_TYPE_ID)),
	"Действие"         = convert(varchar(25),(CASE WHEN pcad.DELETE_SIGN = 1
                                                 THEN '(Уд.)'
                                                 ELSE '' END) + cal.ACTION_NAME),
	"Дата"             = convert(varchar(10),pcad.DATE_ID,104),
	"Показания"        = convert(varchar(15),pcai.CHECK_COUNT),
	"№ пломбы"         = convert(varchar(15),pcs.SEAL_NUMBER),
	"Место уст.пломбы" = convert(varchar(15),(SELECT SEAL_PLACE_NAME
                                            FROM CntSealPlaces
                                            WHERE SEAL_PLACE_ID = pcs.SEAL_PLACE_ID)),
	"Ф.И.О.контролера" = convert(varchar(15),(SELECT INSPECTOR_NAME
                                            FROM CntInspectors
                                            WHERE INSPECTOR_ID=pci.INSPECTOR_ID)),
	"Ситуация"         = convert(varchar(25),(SELECT COMMENTS 
                                            FROM TypicalCases
                                            WHERE TYPICAL_CASE_ID=pcad.TYPICAL_CASE_ID))
FROM
  #TmpPart                tp   (nolock),
	ProAccounts             pa   (nolock),
	ProCntActionDates       pcad (nolock),
	CntActionList           cal  (nolock),
	ProCntActionInspectors  pci  (nolock),
	ProCntActionIndications pcai (nolock),
	ProCntSeals             pcs  (nolock),
	ProCnt                  pc   (nolock)
WHERE
	pa.CONTRACT_ID         =  tp.CONTRACT_ID	        and
	pcad.ACCOUNT_ID        =  pa.ACCOUNT_ID	          and
	cal.ACTION_ID          =  pcad.ACTION_ID	        and
	pcai.ACCOUNT_ID        =* pcad.ACCOUNT_ID	        and
	pcai.ACTION_ID         =* pcad.ACTION_ID	        and
	pcai.DATE_ID           =* pcad.DATE_ID	          and
	pcai.COUNTER_NUMBER_ID =* pcad.COUNTER_NUMBER_ID	and
	pci.ACCOUNT_ID         =* pcad.ACCOUNT_ID	        and
	pci.ACTION_ID          =* pcad.ACTION_ID	        and
	pci.DATE_ID            =* pcad.DATE_ID	          and
	pci.COUNTER_NUMBER_ID  =* pcad.COUNTER_NUMBER_ID	and
	pcs.ACCOUNT_ID         =* pcad.ACCOUNT_ID	        and
	pcs.ACTION_ID          =* pcad.ACTION_ID	        and
	pcs.DATE_ID            =* pcad.DATE_ID	          and
	pcs.COUNTER_NUMBER_ID  =* pcad.COUNTER_NUMBER_ID	and
	pc.ACCOUNT_ID          =* pcad.ACCOUNT_ID	        and
	pc.COUNTER_NUMBER_ID   =* pcad.COUNTER_NUMBER_ID	and

  pcad.ACTION_ID          = @ACTION_ID              and
	pcad.DATE_ID            = (select max(date_id)
                             from ProCntActionDates pcad1 (nolock)
                             where  pcad1.account_id = pcad.account_id and
                                    pcad1.action_id = @ACTION_ID
                             ) and
  pcad.DATE_ID            <= @DatEnd

  and  pcad.TYPICAL_CASE_ID = 116


