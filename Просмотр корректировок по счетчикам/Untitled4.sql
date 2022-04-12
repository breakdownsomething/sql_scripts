if Exists (select * from TempDB..SysObjects
           where id = OBJECT_ID('#TmpEditRecords'))
exec('DROP TABLE #TmpEditRecords')

if Exists (select * from TempDB..SysObjects
           where id = OBJECT_ID('#TMPElectNodeCntActionDates'))
exec('DROP TABLE #TMPElectNodeCntActionDates')


declare
  @node_id  int,
  @table_id int

select  @node_id  = 5211

select  @table_id = table_id
  from  tables
  where table_name = 'ElectNodeCntActionDates'

-- Создание временной таблицы с корректировками
-- (Всю EditRecords лопатить не стоит :)
select *
into #TmpEditRecords
from EditRecords
where table_id   = @table_id
  and account_id = @node_id 


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
 and AD.nodeid    = @node_id

--select * from #TMPElectNodeCntActionDates



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

  and ED1.account_id = ED2.account_id
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

select * from  #TMPElectNodeCntActionDates
