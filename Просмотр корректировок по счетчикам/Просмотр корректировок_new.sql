-----------------------------------------\
--DROP TABLE #TmpEditRecords               
-------------------------------------- ---/

---------------------------------------------------------------------------------------------\
declare  @node_id      int
        ,@table_id     int
        ,@cnt_table_id int

select  @node_id      = 2612          --5211
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
                     and ter.add_keys     = TER1.add_keys)
FROM #TmpEditRecords TER1

-- Заполнение action_date для записей  по которым НЕТ действия в ElectNodeCNTEditRecords
-- (Удаление действия)
update #TmpEditRecords 
set action_date = isnull(action_date,fix_input)

-- Заполнение cnt_values 
--1) Показания счетчика
update #TmpEditRecords
set cnt_values =  convert(varchar(15),CAD.check_count)+'; '
from #TmpEditRecords        TER
    ,ElectNodeCNTActionDates CAD (nolock)
where 
      CAD.nodeid = TER.account_id
  and CAD.cnt_id  = TER.cnt_id
  and CAD.action_id = TER.action_id
  and CAD.date_id = TER.action_date

update #TmpEditRecords
set cnt_values = isnull(cnt_values,'неизвестно; ')

-- 2) Коэффициент трансфомации и  признак головного счетчика
update #TmpEditRecords
set cnt_values = TER.cnt_values
                + convert(varchar(10),ENC.COEFFICIENT_TRANSF)+'; '
                + case when ENC.PRIMARY_SIGN = 0 then 'Локальный'
                       when ENC.PRIMARY_SIGN = 1 then 'Головной'
                       else 'Неизв-но' end   
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



select * from #TmpEditRecords    
where (field_id = 4 and edit_sign = 1)
 or  (field_id = 6  and edit_sign = 2)

DROP TABLE #TmpEditRecords    




/*
-- Создание временной таблицы с действиями по счетчикам

CREATE TABLE #TMPElectNodeCntActionDates (
	NODEID      int           NOT NULL ,
	CNT_ID      smallint      NOT NULL ,
	ACTION_ID   tinyint       NOT NULL ,
	DATE_ID     smalldatetime NOT NULL ,
	DEL_SIGN    tinyint       NOT NULL ,
	CHECK_COUNT int           NULL,
----------------------------------------
  action_name varchar(20)   NULL, --Вид корректировки (Снятие, Установка, Замена счетчика)
  value       int           NULL, --Показания счетчика / коэффициент трансформации
--------------
  act         varchar(10)   NULL, --Вид действия (редактирование, вставка, удаление)
  username    varchar(30)   NULL, --Пользователь, проделавший данное действие
  date_input  datetime      NULL  --Дата действия
----------------------------------------
) ON [PRIMARY]


insert into #TMPElectNodeCntActionDates (NODEID,
                                         CNT_ID,
                                         ACTION_ID,
                                         DATE_ID,
                                         DEL_SIGN,
                                         CHECK_COUNT,
                                         action_name,
                                         value,
                                         act, 
                                         username,
                                         date_input)
select
       AD.nodeid
      ,AD.cnt_id
      ,AD.action_id
      ,AD.date_id
      ,AD.del_sign
      ,AD.check_count

      ,AL.action_name 
      ,value = round(AD.check_count/CNT.coefficient_transf,0)
      ,null
      ,null
      ,null
from ElectNodeCNTActionDates AD  (nolock)
    ,ElectNodeCNTActionList  AL  (nolock)
    ,ElectNodeCNT            CNT (nolock)
where
     AD.action_id = AL.action_id
 and AD.cnt_id    = CNT.cnt_id 
 and AD.nodeid    = CNT.nodeid  
 and AD.nodeid    = @node_id


--select * from #TMPElectNodeCntActionDates
--order by date_id desc


--select * from #TmpEditRecords
--order by fix_input desc


declare
  @nodeid        int
 ,@cnt_id        int
 ,@action_id     tinyint
 ,@date_id       smalldatetime
 ,@del_sign      tinyint
 ,@check_count   int
 ,@act            varchar(10)
 ,@user_name      varchar(30)
 ,@date_input     datetime


declare curCntActionDates cursor static
      for
      select NODEID,
             CNT_ID,
             ACTION_ID,
             DATE_ID,
             DEL_SIGN,
             CHECK_COUNT
      from #TMPElectNodeCntActionDates

open curCntActionDates

fetch next from curCntActionDates
 into @nodeid
     ,@cnt_id
     ,@action_id
     ,@date_id
     ,@del_sign
     ,@check_count

--close curCntActionDates
--deallocate curCntActionDates

while (@@FETCH_STATUS <> -1)
  begin
  ---------------------------------
  select distinct
   @act                = case  when ED1.edit_sign = 1 then 'Ввод'
                             when ED1.edit_sign = 2 then 'Редакт-е'
                             when ED1.edit_sign = 3 then 'Удаление'
                             else 'неизвестно' end
  ,@user_name         = U.full_name
  ,@date_input        = ED1.fix_input
*/
/*
  ,ED1_record_number = ED1.record_number
  ,ED1_label_number  = ED1.label_number
  ,ED1_table_id      = ED1.table_id
  ,ED1_field_id      = ED1.field_id
  ,ED1_edit_sign     = ED1.edit_sign
  ,ED1_account_id    = ED1.account_id
  ,ED1_field_value   = ED1.field_value
  ,ED1_fix_input     = ED1.fix_input

--  ,ED2_record_number = ED2.record_number
  ,ED2_label_number  = ED2.label_number
  ,ED2_table_id      = ED2.table_id
  ,ED2_field_id      = ED2.field_id
  ,ED2_edit_sign     = ED2.edit_sign
  ,ED2_account_id    = ED2.account_id
  ,ED2_field_value   = ED2.field_value
  ,ED2_fix_input     = ED2.fix_input
   
--  ,ED3_record_number = ED3.record_number
  ,ED3_label_number  = ED3.label_number
  ,ED3_table_id      = ED3.table_id
  ,ED3_field_id      = ED3.field_id
  ,ED3_edit_sign     = ED3.edit_sign
  ,ED3_account_id    = ED3.account_id
  ,ED3_field_value   = ED3.field_value
  ,ED3_fix_input     = ED3.fix_input

--  ,ED4_record_number = ED4.record_number
  ,ED4_label_number  = ED4.label_number
  ,ED4_table_id      = ED4.table_id
  ,ED4_field_id      = ED4.field_id
  ,ED4_edit_sign     = ED4.edit_sign
  ,ED4_account_id    = ED4.account_id
  ,ED4_field_value   = ED4.field_value
  ,ED4_fix_input     = ED4.fix_input
*/
/*
 from #TmpEditRecords ED1 (nolock)
     ,#TmpEditRecords ED2 (nolock)
     ,#TmpEditRecords ED3 (nolock)
     ,#TmpEditRecords ED4 (nolock)
     ,Users           U   (nolock)
     ,EditLabels      EL  (nolock)

where
---------------------------------------------
      ED1.label_number = EL.label_number
  and EL.user_id      = U.user_id
-----------------------------------
  and ED1.table_id = @table_id
  and ED1.field_id = 4 -- Action_id
  and convert(int,ED1.field_value) = @action_id
-----------------------------------------
  and ED2.table_id = @table_id
  and ED2.field_id = 2  -- Date_id
  and convert(datetime,ED2.field_value) = @date_id
-----------------------------------------
  and ED3.table_id = @table_id
  and ED3.field_id = 5  -- check_count
  and convert(int,isnull(ED3.field_value,0)) = @check_count
-----------------------------------------
  and ED4.table_id = @table_id
  and ED4.field_id = 1  -- cnt_id
  and convert(int,ED4.field_value) = @cnt_id
-----------------------------------------

  and ED1.account_id = ED2.account_id -- node_id
  and ED1.account_id = ED3.account_id
  and ED1.account_id = ED4.account_id

  and ED1.fix_input  = ED2.fix_input
  and ED1.fix_input  = ED3.fix_input
  and ED1.fix_input  = ED4.fix_input
-------------------------------------------
  and ED1.account_id = @nodeid 


update #TMPElectNodeCntActionDates
set  act        = @act
    ,username  = @user_name
    ,date_input = @date_input
where
     NODEID      = @nodeid
and  CNT_ID      = @cnt_id
and  ACTION_ID   = @action_id
and  DATE_ID     = @date_id
and  DEL_SIGN    = @del_sign
and  CHECK_COUNT = @check_count


-----------------------------------
fetch next from curCntActionDates
  into @nodeid
      ,@cnt_id
      ,@action_id
      ,@date_id
      ,@del_sign
      ,@check_count
  end

close curCntActionDates
deallocate curCntActionDates

select
  date_id
 ,action_name
 ,value
 ,act
 ,username
 ,date_input
from  #TMPElectNodeCntActionDates
order by date_id desc
*/