DECLARE
	@vcTableName	varchar(35)
SELECT
	@vcTableName='##ShowKeys'

IF OBJECT_ID ('tempdb..##ShowKeys') IS NOT NULL
	DROP TABLE ##ShowKeys
CREATE TABLE
		##ShowKeys
			(
			FIELD_ID	tinyint,
			FIELD_NAME	varchar(80),
			FIELD_VALUE	varchar(80)
			)

-------------------------------------------------------------

DECLARE
	@iAccountId	int
--,	@vcTableName	varchar(35)
SELECT
	@iAccountId	=  10022--:pAccountId
--,	@vcTableName	=:pTableName


IF OBJECT_ID ('tempdb..#CorrectionsReference') IS NOT NULL
	DROP TABLE #CorrectionsReference
create table #CorrectionsReference
(
[WTABLE]     varchar(35)   null,
[TABLE_ID]   int           null,
[DATE]       smalldatetime null,
[USER_NAME]  varchar(80)   null,
[ACTION]     varchar(8)    null,
[TABLE_NAME] varchar(30)   null,
[FIELD_NAME] varchar(20)   null,
[VALUE]      varchar(80)   null,
[KEYS]       varchar(80)   null
)

insert into #CorrectionsReference 
SELECT
	WTABLE    = @vcTableName,
	TABLE_ID  = T.TABLE_ID,
	DATE      = ER.FIX_INPUT,
	USER_NAME = CONVERT(varchar(80),
		          CASE WHEN (U.USER_ID=22)OR(U.USER_ID=1)OR(U.USER_ID=204)
          		     THEN 'Разработчик'
		               ELSE U.FULL_NAME END),

	ACTION    = CONVERT(varchar(8),
		          CASE ER.EDIT_SIGN	WHEN 1 THEN 'Ввод'
                                WHEN 2 THEN 'Редакт-е'
                          			WHEN 3 THEN 'Удаление' END),

	TABLE_NAME = CONVERT(varchar(30),T.COMMENTS),

	FIELD_NAME = CONVERT(varchar(20),TF.COMMENTS),

	VALUE      = CONVERT(varchar(80),
               CASE WHEN SC.type = 50
		                THEN CASE WHEN CONVERT(bit,ER.FIELD_VALUE) = 0
			                        THEN 'Нет'
			                        WHEN CONVERT(bit,ER.FIELD_VALUE) = 1
			                        THEN 'Да'
			                        ELSE 'Обратитесь к разработчику'  END
                    WHEN (SC.type = 111) AND (SC.name = 'DATE_CHECK')
		                THEN CONVERT(varchar(10),
                                 DATEADD(dd,CONVERT(int, ER.FIELD_VALUE),
                                            CONVERT(smalldatetime, '1998-08-01',21)),104)
                    WHEN  (SC.type=58)OR(SC.type=111)
	                  THEN CASE /*Nigmet*/WHEN PATINDEX('%[^0-9]%',ER.FIELD_VALUE)<>0
                                				THEN CONVERT(varchar(10),CONVERT(smalldatetime, ER.FIELD_VALUE),104)
                                 				ELSE CONVERT(varchar(10),DATEADD(dd,CONVERT(int, ER.FIELD_VALUE),
                                              				CONVERT(smalldatetime, '1998-08-01',21)),104)	END
                    WHEN (SC.type=52)OR(SC.type=38)OR(SC.type=48)
		                THEN CASE WHEN SC.name='TYPICAL_CASE_ID'
			                        THEN (SELECT TC.COMMENTS
                        			      FROM TypicalCases TC(NOLOCK)
				                            WHERE	CONVERT(varchar(5),TC.TYPICAL_CASE_ID)=	ER.FIELD_VALUE)
 			                        WHEN  SC.name = 'SUBSTATION_TYPE_ID'
			                        THEN (SELECT	ESTL.SUBSTATION_TYPE_NAME
				                            FROM  	ElectSubstationTypeList ESTL(NOLOCK)
				                            WHERE	CONVERT(varchar(5),	ESTL.SUBSTATION_TYPE_ID) =	ER.FIELD_VALUE)
        			                WHEN  SC.NAME = 'INSPECTOR_ID'
			                        THEN (SELECT	CI.INSPECTOR_NAME
				                            FROM    CntInspectors      CI(NOLOCK)
				                            WHERE	CONVERT(varchar(5),CI.INSPECTOR_ID) =	ER.FIELD_VALUE)
			                        WHEN  SC.NAME = 'COUNTER_TYPE_ID'
			                        THEN (SELECT	CT.COUNTER_TYPE_NAME
				                            FROM  	CntTypes      CT(NOLOCK)
				                            WHERE	CONVERT(varchar(5),CT.COUNTER_TYPE_ID) = ER.FIELD_VALUE)
			                        WHEN  SC.NAME = 'ACCOUNT_TYPE'
			                        THEN (SELECT AT.ACCOUNT_TYPE_NAME
				                            FROM	AccountTypes  AT(NOLOCK)
				                            WHERE	CONVERT(varchar(5),	AT.ACCOUNT_TYPE) = ER.FIELD_VALUE)
                              ELSE	ER.FIELD_VALUE   END
                  WHEN  (SC.type=55)OR(SC.type=106)
		              THEN  CASE  WHEN  SC.name='REAL_HOURS'
			                        THEN CASE  WHEN ER.FIELD_VALUE IS NULL
				                                 THEN 'По ч.г.'
				                                 ELSE ER.FIELD_VALUE END
                              ELSE ER.FIELD_VALUE END
                  ELSE ER.FIELD_VALUE  END),

	KEYS=CONVERT(varchar(80),ER.ADD_KEYS)
FROM
	EditRecords	ER(NOLOCK),
	EditLabels	EL(NOLOCK),
	Users		    U (NOLOCK),
	Tables		  T (NOLOCK),
	TableFields	TF(NOLOCK),
	SysColumns	SC(NOLOCK),
	SysObjects	SO(NOLOCK)
WHERE
	ER.ACCOUNT_ID   = @iAccountId	    AND
	ER.LABEL_NUMBER = EL.LABEL_NUMBER	AND
	ER.TABLE_ID     = T.TABLE_ID		  AND
	ER.FIELD_ID     = TF.FIELD_ID		  AND
	EL.USER_ID      = U.USER_ID		    AND
	T.TABLE_ID      = TF.TABLE_ID		  AND
	SO.NAME         = T.TABLE_NAME		AND
	SC.NAME         = TF.FIELD_NAME		AND
	SO.id           = SC.id
ORDER BY  ER.FIX_INPUT  DESC

-----------------------------------------------------------------------
-- Для корректировок таблицы SumServices (table_id = 4600) сделан
-- отдельный запрос потому, что в базе aspElectric она не существует
-- и соответственно сведенья о ней отсутствуют в системных таблицах
-- sysobjects и syscolumns. Поэтому основной запрос эти корректировки
-- не вытаскивает. (Матесов Д. 09.08.2004)

insert into #CorrectionsReference
select 
     WTABLE      = @vcTableName,
     TABLE_ID    = T.table_id,
     [DATE]      = ER.FIX_INPUT,
     [USER_NAME] = U.FULL_NAME,
     [ACTION]    = CONVERT(varchar(8),
		               CASE ER.EDIT_SIGN	WHEN 1 THEN 'Ввод'
                                      WHEN 2 THEN 'Редакт-е'
                                			WHEN 3 THEN 'Удаление' END),
	   TABLE_NAME  = CONVERT(varchar(30),T.COMMENTS),
	   FIELD_NAME  = CONVERT(varchar(20),TF.COMMENTS),
     VALUE       = ER.FIELD_VALUE,
     KEYS        = CONVERT(varchar(80),ER.ADD_KEYS)  
from
     EditRecords	ER  (NOLOCK),
     EditLabels	  EL  (NOLOCK),
     Users		    U   (NOLOCK),
     Tables		    T   (NOLOCK),
     TableFields	TF  (NOLOCK)
where
     ER.ACCOUNT_ID   = @iAccountId	    AND
	   ER.LABEL_NUMBER = EL.LABEL_NUMBER	AND
	   ER.TABLE_ID     = T.TABLE_ID		    AND
	   ER.FIELD_ID     = TF.FIELD_ID		  AND
	   EL.USER_ID      = U.USER_ID		    AND
	   T.TABLE_ID      = TF.TABLE_ID		  AND
     T.TABLE_ID      = 4600    -- таблица SumServices
-----------------------------------------------------------     

select * from #CorrectionsReference
ORDER BY [DATE] DESC

drop table #CorrectionsReference


