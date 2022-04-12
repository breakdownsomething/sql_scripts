IF EXISTS (SELECT name 
	   FROM   sysobjects
	   WHERE  name = 'sp_ElectNodeCorrectionReference'
	   AND 	  type = 'P')
    DROP PROCEDURE dbo.sp_ElectNodeCorrectionReference
GO

CREATE PROCEDURE dbo.sp_ElectNodeCorrectionReference
	@node_id  int
AS

---------------------------------------------------------------------------------------------\
declare  @table_id     int
        ,@cnt_table_id int

--select  @node_id      = 2612          --5211
select  @table_id     = table_id from tables where table_name = 'ElectNodeCntActionDates'
select  @cnt_table_id = table_id from tables where table_name = 'ElectNodeCnt'
---------------------------------------------------------------------------------------------/

-- Создание временной таблицы с корректировками
-- (Всю EditRecords лопатить не стоит :)

CREATE TABLE #TmpEditRecords (
	[RECORD_NUMBER] [int] /*IDENTITY (1, 1)*/ NOT NULL ,
	[LABEL_NUMBER] [int] NOT NULL ,
	[TABLE_ID] [int] NOT NULL ,
	[FIELD_ID] [tinyint] NOT NULL ,
	[EDIT_SIGN] [tinyint] NOT NULL ,
	[ACCOUNT_ID] [int] NOT NULL ,
	[ADD_KEYS] [varchar] (80) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[FIELD_VALUE] [varchar] (80) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[FIX_INPUT] [smalldatetime] NOT NULL 
------------------------------------------------------------------------
 ,action_date smalldatetime null -- дата действия
 ,action_id   int           null -- номер действия
 ,action_name varchar(50)   null -- имя действия
 ,cnt_id      int           null -- порядковый номер счетчика на узле
 ,cnt_values  varchar(100)  null -- введенные или измененные значения
 ,full_user_name   varchar(30)   null -- имя пользователя
------------------------------------------------------------------------ 
) ON [PRIMARY]


-- Заполнение временной таблицы
-- Шаг 1. Сначала записи, относящиеся к таблице ElectNodeCNTActionDates
insert into
 #TmpEditRecords (RECORD_NUMBER
                 ,LABEL_NUMBER
                 ,TABLE_ID
                 ,FIELD_ID
                 ,EDIT_SIGN
                 ,ACCOUNT_ID
                 ,ADD_KEYS
                 ,FIELD_VALUE
                 ,FIX_INPUT
                 ,action_date
                 ,action_id
                 ,action_name
                 ,cnt_id
                 ,cnt_values
                 ,full_user_name)

select ER.RECORD_NUMBER
      ,ER.LABEL_NUMBER
      ,ER.TABLE_ID
      ,ER.FIELD_ID
      ,ER.EDIT_SIGN
      ,ER.ACCOUNT_ID
      ,ER.ADD_KEYS
      ,ER.FIELD_VALUE
      ,ER.FIX_INPUT 
      ,null -- action_date
      ,convert(int,substring(ER.add_keys,(charindex(';',ER.add_keys)+1),len(ER.add_keys))) -- action_id
      ,case when (ER.field_id = 6 --del_sign
              and ER.edit_sign = 2 --update
              and ER.field_value = 1) --del_sign=1 - действие удалено 
            then 'Отмена действия "'+AL.action_name+'"'
            else AL.action_name end
      ,convert(int,substring(ER.add_keys,0,charindex(';',ER.add_keys))) --cnt_id
      ,null --cnt_values
      ,null --full_user_name
from EditRecords             ER  (nolock)
    ,ElectNodeCNTActionList  AL  (nolock)
  where ER.table_id   = @table_id
    and ER.account_id = @node_id 
    and AL.action_id  = convert(int,substring(ER.add_keys,(charindex(';',ER.add_keys)+1),len(ER.add_keys)))

-- Заполнение action_date для записей  по которым есть действия в ElectNodeCNTEditRecords
update #TmpEditRecords 
set action_date = (select convert(smalldatetime,ter.field_value)
                   from  #TmpEditRecords ter (nolock)
                   where ter.field_id  = 2 --date_id
                     and ter.label_number  = TER1.label_number
                     and ter.table_id      = TER1.table_id
                     and ter.edit_sign     =  1
                     and ter.add_keys     = TER1.add_keys
                     and ter.fix_input     = TER1.fix_input)
FROM #TmpEditRecords TER1

-- Заполнение action_date для записей  по которым НЕТ действия в ElectNodeCNTEditRecords
-- (Удаление действия)
update #TmpEditRecords 
set action_date = isnull(action_date,fix_input)

-- Заполнение cnt_values 
--1) Показания счетчика
update #TmpEditRecords
set cnt_values =  convert(varchar(15),CAD.check_count)+' / '
from #TmpEditRecords        TER
    ,ElectNodeCNTActionDates CAD (nolock)
where 
      CAD.nodeid = TER.account_id
  and CAD.cnt_id  = TER.cnt_id
  and CAD.action_id = TER.action_id
  and CAD.date_id = TER.action_date

update #TmpEditRecords
set cnt_values = isnull(cnt_values,'нет /')

-- 2) Коэффициент трансфомации и  признак головного счетчика
update #TmpEditRecords
set cnt_values = TER.cnt_values
                + ' '+convert(varchar(10),ENC.COEFFICIENT_TRANSF)+' / '
                + case when ENC.PRIMARY_SIGN = 0 then 'локал.'
                       when ENC.PRIMARY_SIGN = 1 then 'главн.'
                       else 'геизв-но' end   
from #TmpEditRecords        TER
    ,ElectNodeCNT           ENC (nolock)
where ENC.nodeid =  TER.account_id
  and ENC.cnt_id =  TER.cnt_id

-- Определение имени пользователя 
update #TmpEditRecords
set full_user_name = U.full_name
from #TmpEditRecords ED 
         ,EditLabels AL (nolock)
         ,Users           U  
where AL.label_number = ED.label_number
  and U.user_id = AL.user_id
  
-- Конечная выборка
select
       ED.action_date -- Дата действия над счетчиком
      ,ED.cnt_id  -- Номер счетчика
      ,ED.action_name  -- Действие
      ,ED.cnt_values  -- Значение: показания; коэф. трансформации; признак головного
      ,EDIT_SIGN = case when ED.edit_sign = 1 then 'Ввод'
                           when ED.edit_sign = 2 then 'Редакт-е'
                           when ED.edit_sign = 3 then 'Удаление'
                           else 'неизвестно' end
      ,ED.full_user_name 
      ,ED.FIX_INPUT
from #TmpEditRecords ED 
where (field_id = 4 and edit_sign = 1)
 or  (field_id = 6  and edit_sign = 2)
order by ED.fix_input desc

DROP TABLE #TmpEditRecords    

GO


