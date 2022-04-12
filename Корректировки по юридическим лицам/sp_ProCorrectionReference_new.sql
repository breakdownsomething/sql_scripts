-- !!! Выполнить в двух базах
-- 1. aspElectricPro
-- 2. aspelectricPul



IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = 'sp_ProCorrectionReference' 
	   AND 	  type = 'P')
     exec('DROP PROCEDURE dbo.sp_ProCorrectionReference')
GO
----------------------------------------------------------------------------------\
/*
 Copyright 2004 ЗАО “Алсеко”. All rights reserved.
 Name:                sp_ProCorrectionReference
 Short Description:   Процедура показа корректировок, сделанных
                      инженерами-расчетчиками по данному договору
                      в заданном промежутке времени
 in parameter  1:     @contract_id - выбранный контракт
 in parameter  2:     @begin_date  - начало периода
 in parameter  3:     @end_date    - конец периода
 Result:              Набор данных, отражающий сделанные корректировки
 Autor:	              Матесов Д.С.
 Date:	   	          11.05.2004
 Note:                Работает достаточно долго
*/
----------------------------------------------------------------------------------/
CREATE PROCEDURE dbo.sp_ProCorrectionReference
	@contract_id  int,
  @begin_date   datetime,
  @end_date     datetime
AS
-----------------------------------------------------------------\
-- Создание временной таблицы                                    |
-----------------------------------------------------------------/ 
if Exists (select * from TempDB..SysObjects
           where id = OBJECT_ID('TempDB..#TmpProEditRecords'))
exec('DROP TABLE #TmpProEditRecords')

CREATE TABLE [#TmpProEditRecords] (
	[RECORD_NUMBER] [int] NOT NULL ,
	[LABEL_NUMBER] [int] NOT NULL ,
	[TABLE_ID] [int] NOT NULL ,
	[FIELD_ID] [tinyint] NOT NULL ,
	[EDIT_SIGN] [tinyint] NOT NULL ,
	[ADD_KEYS] [varchar] (80) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[FIELD_VALUE] [varchar] (80) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[FIX_INPUT] [smalldatetime] NOT NULL ,
  [OBJECT] [int] NULL ,
	CONSTRAINT [PK_#TmpProEditRecords] PRIMARY KEY  NONCLUSTERED 
	(
		[RECORD_NUMBER],
		[LABEL_NUMBER],
		[FIX_INPUT]
	)  ON [PRIMARY] 
) ON [PRIMARY]

-----------------------------------------------------------------------------\
-- Выборка во временную таблицу записей, соответствующих данному contract_id |
-----------------------------------------------------------------------------/

declare
  @contract_number int
 ,@abonent_id      int

/*
--- Debug Code
--------------------------------------
 ,@contract_id  int
 ,@begin_date   datetime
 ,@end_date     datetime
select @contract_id     = 18017
select @begin_date      = '2001-01-01'
select @end_date        = '2004-05-04' 
--------------------------------------
*/
select @contract_number = contract_number
      ,@abonent_id      = abonent_id
from ProContracts (nolock)
where contract_id = @contract_id

insert into #TmpProEditRecords
select 
  record_number ,label_number ,table_id    ,field_id
 ,edit_sign     ,add_keys     ,field_value ,fix_input,
  null
 from ProEditRecords (nolock)
 where contract_id = @contract_id
     and fix_input between @begin_date and @end_date

-- group 1------------------------------------------------------------------------------------
update #TmpProEditRecords
set object = convert(int,substring(add_keys,0,charindex(',',add_keys)))
where table_id in (200000, -- ProCntCounts
                   200700, -- ProCnt
                   200808, -- ProCntActionDates
                   200923) -- ProCntSeals
-- group 2, 3, 4, 5, 6   ------------------------------------------------------------------
update #TmpProEditRecords
set object = convert(int,add_keys)
where table_id in (200100, -- ProCalcs
                   200201, --ProFineSums
                   200400, --ProContracts
                   200843, --ProFine
                   201060, --ProPlanDetails
                   200300, --ProAbonents
                   200500, --ProAccounts
                   200839, --ProTransActionDates
                   200846, --ProSPM
                   200925, --ProTransSeals
                   200600, --ProAccountOwners
                   200911) --ProOwnerPower

/*
-- group 1--
-- account_id = convert(int,SUBSTRING ( add_keys, 0, CHARINDEX (',',add_keys)))
insert into #TmpProEditRecords
select 
  record_number ,label_number ,table_id    ,field_id
 ,edit_sign     ,add_keys     ,field_value ,fix_input,
  convert(int,substring(add_keys,0,charindex(',',add_keys)))
 from ProEditRecords (nolock)
 where table_id = 200000 --ProCntCounts
   and edit_sign <> 1
   and add_keys <> '0'
   and fix_input between @begin_date and @end_date
   and convert(int,substring(add_keys,0,charindex(',',add_keys))) in
       (select account_id from ProAccounts (nolock) where contract_id = @contract_id)         

insert into #TmpProEditRecords
select 
  record_number ,label_number ,table_id    ,field_id
 ,edit_sign     ,add_keys     ,field_value ,fix_input,
  convert(int,substring(add_keys,0,charindex(',',add_keys)))
 from ProEditRecords (nolock)
 where table_id = 200700 --ProCnt
   and add_keys <> '0'
   and fix_input between @begin_date and @end_date
   and convert(int,substring(add_keys,0,charindex(',',add_keys))) in
       (select account_id from ProAccounts (nolock) where contract_id = @contract_id)         

insert into #TmpProEditRecords
select 
  record_number ,label_number ,table_id    ,field_id
 ,edit_sign     ,add_keys     ,field_value ,fix_input,
  convert(int,substring(add_keys,0,charindex(',',add_keys)))
 from ProEditRecords (nolock)
 where table_id = 200808 --ProCntActionDates
   and add_keys <> '0'
   and fix_input between @begin_date and @end_date
   and convert(int,substring(add_keys,0,charindex(',',add_keys))) in
       (select account_id from ProAccounts (nolock) where contract_id = @contract_id)         


-- group 2 --
-- contract_number = convert(int,add_keys)
insert into #TmpProEditRecords
select 
  record_number ,label_number ,table_id    ,field_id
 ,edit_sign     ,add_keys     ,field_value ,fix_input,
  convert(int,add_keys)
 from ProEditRecords (nolock)
 where table_id = 200100 --ProCalcs
   and add_keys <> '0'
   and fix_input between @begin_date and @end_date
   and convert(int,add_keys) = @contract_number

-- group 3 --
-- contract_id = convert(int,add_keys)
insert into #TmpProEditRecords
select 
  record_number ,label_number ,table_id    ,field_id
 ,edit_sign     ,add_keys     ,field_value ,fix_input,
 @contract_number
 from ProEditRecords (nolock)
 where table_id = 200201 --ProFineSums
   and add_keys <> '0'
   and fix_input between @begin_date and @end_date
   and convert(int,add_keys) = @contract_id

insert into #TmpProEditRecords
select 
  record_number ,label_number ,table_id    ,field_id
 ,edit_sign     ,add_keys     ,field_value ,fix_input,
  @contract_number
 from ProEditRecords (nolock)
 where table_id = 200400 --ProContracts
   and add_keys <> '0'
   and fix_input between @begin_date and @end_date
   and convert(int,add_keys) = @contract_id

insert into #TmpProEditRecords
select 
  record_number ,label_number ,table_id    ,field_id
 ,edit_sign     ,add_keys     ,field_value ,fix_input,
@contract_number
 from ProEditRecords (nolock)
 where table_id = 200843 --ProFine
   and add_keys <> '0'
   and fix_input between @begin_date and @end_date
   and convert(int,add_keys) = @contract_id

insert into #TmpProEditRecords
select 
  record_number ,label_number ,table_id    ,field_id
 ,edit_sign     ,add_keys     ,field_value ,fix_input,
@contract_number
 from ProEditRecords (nolock)
 where table_id = 201060 --ProPlanDetails
   and add_keys <> '0'
   and fix_input between @begin_date and @end_date
   and convert(int,add_keys) = @contract_id

-- group 4 --
-- abonent_id = convert(int,add_keys)
insert into #TmpProEditRecords
select 
  record_number ,label_number ,table_id    ,field_id
 ,edit_sign     ,add_keys     ,field_value ,fix_input,
convert(int,add_keys)
 from ProEditRecords (nolock)
 where table_id = 200300 --ProAbonents
   and add_keys <> '0'
   and fix_input between @begin_date and @end_date
   and convert(int,add_keys) = @abonent_id

-- group 5 --
-- account_id = convert(int,add_keys)
insert into #TmpProEditRecords
select 
  record_number ,label_number ,table_id    ,field_id
 ,edit_sign     ,add_keys     ,field_value ,fix_input,
convert(int,add_keys)
 from ProEditRecords (nolock)
 where table_id = 200500 --ProAccounts
   and add_keys <> '0'
   and fix_input between @begin_date and @end_date
   and convert(int,add_keys) in (select account_id from ProAccounts (nolock) where contract_id = @contract_id)         

insert into #TmpProEditRecords
select 
  record_number ,label_number ,table_id    ,field_id
 ,edit_sign     ,add_keys     ,field_value ,fix_input,
convert(int,add_keys)
 from ProEditRecords (nolock)
 where table_id = 200839 --ProTransActionDates
   and add_keys <> '0'
   and fix_input between @begin_date and @end_date
   and convert(int,add_keys) in (select account_id from ProAccounts (nolock) where contract_id = @contract_id)         

insert into #TmpProEditRecords
select 
  record_number ,label_number ,table_id    ,field_id
 ,edit_sign     ,add_keys     ,field_value ,fix_input,
convert(int,add_keys)
 from ProEditRecords (nolock)
 where table_id = 200846 --ProSPM
   and add_keys <> '0'
   and fix_input between @begin_date and @end_date
   and convert(int,add_keys) in (select account_id from ProAccounts (nolock) where contract_id = @contract_id)         

insert into #TmpProEditRecords
select 
  record_number ,label_number ,table_id    ,field_id
 ,edit_sign     ,add_keys     ,field_value ,fix_input,
convert(int,add_keys)
 from ProEditRecords (nolock)
 where table_id = 200925 --ProTransSeals
   and add_keys <> '0'
   and fix_input between @begin_date and @end_date
   and convert(int,add_keys) in (select account_id from ProAccounts (nolock) where contract_id = @contract_id)         


-- group 6 --
-- account_owner_id = convert(int,add_keys)
insert into #TmpProEditRecords
select 
  record_number ,label_number ,table_id    ,field_id
 ,edit_sign     ,add_keys     ,field_value ,fix_input,
 convert(int,add_keys)
 from ProEditRecords (nolock)
 where table_id = 200600 --ProAccountOwners
   and add_keys <> '0'
   and fix_input between @begin_date and @end_date
   and convert(int,add_keys) in (select account_owner_id
                                 from ProAccountOwners (nolock) 
                                 where contract_id = @contract_id)         
insert into #TmpProEditRecords
select 
  record_number ,label_number ,table_id    ,field_id
 ,edit_sign     ,add_keys     ,field_value ,fix_input,
 convert(int,add_keys)
 from ProEditRecords (nolock)
 where table_id = 200911 --ProOwnerPower
   and add_keys <> '0'
   and fix_input between @begin_date and @end_date
   and convert(int,add_keys) in (select account_owner_id
                                 from ProAccountOwners (nolock) 
                                 where contract_id = @contract_id)         
*/
------------------------------------------------------------------------\
-- Приведение поля Field_Value к читаемому виду                         |
------------------------------------------------------------------------/
-- 1. BancsInfo
update #TmpProEditRecords
set field_value = '['+per.field_value+'] '+bi.bank_name
 from #TmpProEditRecords per (nolock),
      BanksInfo          bi  (nolock)
where ((per.table_id = 200300 and per.field_id = 17)
    or (per.table_id = 200100 and per.field_id = 28))
  and convert(int,per.field_value) = bi.bank_id

-- 2. BurningGroups
update #TmpProEditRecords
set field_value = '['+per.field_value+'] '+bg.burning_group_name
 from #TmpProEditRecords per (nolock),
      BurningGroups      bg  (nolock)
where ((per.table_id = 200500 and per.field_id = 9)
    or (per.table_id = 200846 and per.field_id = 8))
  and convert(int,per.field_value) = bg.burning_group_id

-- 3. CntActionList
update #TmpProEditRecords
set field_value = '['+per.field_value+'] '+cal.action_name
 from #TmpProEditRecords per (nolock),
      CntActionList      cal (nolock)
where ((per.table_id = 200839 and per.field_id = 2)
    or (per.table_id = 200925 and per.field_id = 2))
  and convert(tinyint,per.field_value) = cal.action_id

-- 4. CntTypes
update #TmpProEditRecords
set field_value = '['+per.field_value+'] '+ct.counter_type_name
 from #TmpProEditRecords per (nolock),
      CntTypes           ct  (nolock)
where ((per.table_id = 200700 and per.field_id = 3)
    or (per.table_id = 200000 and per.field_id = 18))
  and convert(smallint,per.field_value) = ct.counter_type_id

-- 5. Didtricts
update #TmpProEditRecords
set field_value = '['+per.field_value+'] '+d.distr_name
 from #TmpProEditRecords per (nolock),
      Districts          d  (nolock)
where (per.table_id = 200100 and per.field_id = 25)
  and convert(tinyint,per.field_value) = d.distr_id

-- 6. ElectNodeTypeList
update #TmpProEditRecords
set field_value = '['+per.field_value+'] '+tl.substation_type_name
 from #TmpProEditRecords per (nolock),
      ElectNodeTypeList  tl  (nolock)
where (per.table_id = 200500 and per.field_id = 20)
  and convert(tinyint,per.field_value) = tl.substation_type_id

-- 7. MeasureItems
update #TmpProEditRecords
set field_value = '['+per.field_value+'] '+mi.measure_name
 from #TmpProEditRecords per (nolock),
      MeasureItems       mi  (nolock)
where (per.table_id = 200000 and per.field_id = 16)
  and convert(tinyint,per.field_value) = mi.measure_id

-- 8. ProAbonentGroups
update #TmpProEditRecords
set field_value =  '['+per.field_value+'] '+pag.abonent_group_name
 from #TmpProEditRecords per (nolock),
      ProAbonentGroups   pag (nolock)
where ((per.table_id = 200100 and per.field_id = 24)
    or (per.table_id = 200400 and per.field_id = 6))
  and convert(tinyint,per.field_value) = pag.abonent_group_id

-- 9. ProAbonentTypes
update #TmpProEditRecords
set field_value = '['+per.field_value+'] '+pat.abonent_type_name
 from #TmpProEditRecords per (nolock),
      ProAbonentTypes    pat (nolock)
where ((per.table_id = 200100 and per.field_id = 23)
    or (per.table_id = 200400 and per.field_id = 5))
  and convert(tinyint,per.field_value) = pat.abonent_type_id

-- 10. ProAdvances
update #TmpProEditRecords
set field_value = '['+per.field_value+'] '+pa.advance_name
 from #TmpProEditRecords per (nolock),
      ProAdvances        pa  (nolock)
where (per.table_id = 200400 and per.field_id = 10)
  and convert(tinyint,per.field_value) = pa.advance_id

-- 11. ProAuditMethods
update #TmpProEditRecords
set field_value = '['+per.field_value+'] '+am.audit_method_name
 from #TmpProEditRecords per (nolock),
      ProAuditMethods    am  (nolock)
where ((per.table_id = 200500 and per.field_id = 7)
    or (per.table_id = 200846 and per.field_id = 6))
  and convert(tinyint,per.field_value) = am.audit_method_id

-- 12. ProAuditParams
update #TmpProEditRecords
set field_value = '['+per.field_value+'] '+pap.audit_param_name
 from #TmpProEditRecords per (nolock),
      ProAuditParams     pap (nolock)
where (per.table_id = 200500 and per.field_id = 6)
  and convert(tinyint,per.field_value) = pap.audit_param_id

-- 13. ProAuditTypes
update #TmpProEditRecords
set field_value = '['+per.field_value+'] '+pat.audit_type_name
 from #TmpProEditRecords per (nolock),
      ProAuditTypes      pat (nolock)
where (per.table_id = 200500 and per.field_id = 5)
  and convert(tinyint,per.field_value) = pat.audit_type_id 

-- 14. ProCalcTypes
update #TmpProEditRecords
set field_value = '['+per.field_value+'] '+pct.calc_type_name
 from #TmpProEditRecords per (nolock),
      ProCalcTypes       pct (nolock)
where (per.table_id = 200201 and per.field_id = 3)
  and convert(tinyint,per.field_value) = pct.calc_type_id

-- 15. ProConsumerGroups
update #TmpProEditRecords
set field_value = '['+per.field_value+'] '+pcg.consumer_group_name
 from #TmpProEditRecords per (nolock),
      ProConsumerGroups  pcg (nolock)
where ((per.table_id = 200100 and per.field_id = 26)
    or (per.table_id = 200400 and per.field_id = 8))
  and convert(smallint,per.field_value) = pcg.consumer_group_id

-- 17. ProLimitCodes
update #TmpProEditRecords
set field_value = '['+per.field_value+'] '+plc.limit_name
 from #TmpProEditRecords per (nolock),
      ProLimitCodes      plc (nolock)
where (per.table_id = 200400 and per.field_id = 9)
  and convert(tinyint,per.field_value) = plc.limit_id

-- 18. ProMinistrys
update #TmpProEditRecords
set field_value = '['+per.field_value+'] '+m.ministry_name
 from #TmpProEditRecords per (nolock),
      ProMinistrys       m   (nolock)
where ((per.table_id = 200300 and per.field_id = 2)
    or (per.table_id = 200100 and per.field_id = 27))
  and convert(int,per.field_value) = m.ministry_id

-- 19. ProPowerGroups
update #TmpProEditRecords
set field_value =  '['+per.field_value+'] '+ppg.power_group_name
 from #TmpProEditRecords per (nolock),
      ProPowerGroups     ppg   (nolock)
where (per.table_id = 200500 and per.field_id = 8)
  and convert(tinyint,per.field_value) = ppg.power_group_id

-- 20. ProTariffs
update #TmpProEditRecords
set field_value = '['+per.field_value+'] '+pt.tariff_name
 from #TmpProEditRecords per (nolock),
      ProTariffs         pt  (nolock)
where (per.table_id = 200500 and per.field_id = 14)
  and convert(int,per.field_value) = pt.tariff_id

-- 21. ProTrancPowerList
update #TmpProEditRecords
set field_value = '['+per.field_value+'] '+pl.tranc_power_name
 from #TmpProEditRecords per (nolock),
      ProTrancPowerList  pl  (nolock)
where (per.table_id = 200500 and per.field_id = 26)
  and convert(int,per.field_value) = pl.tranc_power_id

-- 22. ProTrancPowerMethods
update #TmpProEditRecords
set field_value =  '['+per.field_value+'] '+pm.tranc_power_method_name
 from #TmpProEditRecords   per (nolock),
      ProTrancPowerMethods pm  (nolock)
where (per.table_id = 200500 and per.field_id = 28)
  and convert(int,per.field_value) = pm.tranc_power_method_id

-- 23. ProUnionPayers
update #TmpProEditRecords
set field_value = '['+per.field_value+'] '+pup.union_payer_name
 from #TmpProEditRecords   per (nolock),
      ProUnionPayers       pup (nolock)
where (per.table_id = 200400 and per.field_id = 7)
  and convert(tinyint,per.field_value) = pup.union_payer_id

-- 24. CntSealPlaces
update #TmpProEditRecords
set field_value = '['+per.field_value+'] '+csp.seal_place_name
 from #TmpProEditRecords   per (nolock),
      CntSealPlaces        csp (nolock)
where ((per.table_id = 200923 and per.field_id = 6)
    or (per.table_id = 200925 and per.field_id = 5))
  and convert(tinyint,per.field_value) = csp.seal_place_id
  
-- 25. Streets
update #TmpProEditRecords
set field_value = '['+per.field_value+'] '+s.street_name
 from #TmpProEditRecords   per (nolock),
      Streets              s   (nolock)
where ((per.table_id = 200300 and per.field_id = 9)
    or (per.table_id = 200600 and per.field_id = 11)
    or (per.table_id = 200500 and per.field_id = 15))
  and convert(smallint,per.field_value) = s.street_id

-- 26. TableFields
update #TmpProEditRecords
set field_value = '['+per.field_value+'] '+ 
                     case when convert(smallint,per.field_value) = 0 then 'Норм.'
                          when convert(smallint,per.field_value) = 1 then 'Сред.'
                          when convert(smallint,per.field_value) = 1 then 'Уст.Мощ.'
                          else 'Неизвестно' end
 from #TmpProEditRecords   per (nolock)
where (per.table_id = 200000 and per.field_id = 10)

update #TmpProEditRecords
set field_value = '['+per.field_value+'] '+ 
                     case when convert(smallint,per.field_value) = 0 then 'Блокирован'
                          when convert(smallint,per.field_value) = 1 then 'Разблокирован'
                          else 'Неизвестно' end
 from #TmpProEditRecords   per (nolock)
where (per.table_id = 200000 and per.field_id = 13)

-- 27 TypicalCases
update #TmpProEditRecords
set field_value = '['+per.field_value+'] '+ tc.comments
from #TmpProEditRecords    per (nolock)
     ,TypicalCases         tc  (nolock)
where ((per.table_id = 200808 and per.field_id = 5)
    or (per.table_id = 200839 and per.field_id = 6))
  and convert(smallint,per.field_value) = tc.typical_case_id
  
--------------------------------------------------------------------------\
-- Основная Выборка --                                                    |
--------------------------------------------------------------------------/
select 
  c_date       = t.fix_input
 ,c_user       = u.full_name
 ,c_operation  = case when t.edit_sign = 1 then 'Ввод'
                      when t.edit_sign = 2 then 'Редакт-е'
                      when t.edit_sign = 3 then 'Удаление'
                      else 'неизвестно' end
 ,c_table      = tt.comments
 ,object       = t.OBJECT
 ,c_field      = tf.comments
 ,value    = t.field_value
 from  #TmpProEditRecords t (nolock)
      ,ProEditLabels      l (nolock)
      ,users              u (nolock)
      ,tables             tt(nolock)
      ,tablefields        tf(nolock)
where t.label_number = l.label_number
  and l.user_id      = u.user_id
  and t.table_id     = tt.table_id
  and t.table_id     = tf.table_id
  and t.field_id     = tf.field_id
order by fix_input desc

drop table #TmpProEditRecords

GO


