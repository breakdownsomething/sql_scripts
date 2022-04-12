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
	CONSTRAINT [PK_ProEditRecords] PRIMARY KEY  NONCLUSTERED 
	(
		[RECORD_NUMBER],
		[LABEL_NUMBER],
		[FIX_INPUT]
	)  ON [PRIMARY] 
) ON [PRIMARY]
GO


declare
  @contract_id     int
 ,@contract_number int
 ,@abonent_id      int

select @contract_id     = 18017
select @contract_number = (select contract_number
                           from ProContracts (nolock)
                           where contract_id = @contract_id)
select @abonent_id      = (select abonent_id
                           from ProContracts (nolock)
                           where contract_id = @contract_id)

-- group 1--
insert into #TmpProEditRecords
select 
  record_number
 ,label_number
 ,table_id
 ,field_id
 ,edit_sign
 ,add_keys
 ,field_value
 ,fix_input
--,account_id = convert(int,SUBSTRING ( add_keys, 0, CHARINDEX (',',add_keys)))
 from ProEditRecords (nolock)
 where table_id in (200000 --ProCntCounts
                   ,200700 --ProCnt
                   ,200808) --ProCntActionDates
   and add_keys <> '0'
   and convert(int,substring(add_keys,0,charindex(',',add_keys))) in
       (select account_id from ProAccounts (nolock) where contract_id = @contract_id)         

-- group 2 --
--insert into #TmpProEditRecords
union
select 
  record_number
 ,label_number
 ,table_id
 ,field_id
 ,edit_sign
 ,add_keys
 ,field_value
 ,fix_input
 --,contract_number = convert(int,add_keys)
 from ProEditRecords (nolock)
 where table_id = 200100 --ProCalcs
   and add_keys <> '0'
  and convert(int,add_keys) = @contract_number

-- group 3 --
--insert into #TmpProEditRecords
union
select 
  record_number
 ,label_number
 ,table_id
 ,field_id
 ,edit_sign
 ,add_keys
 ,field_value
 ,fix_input
-- ,contract_id = convert(int,add_keys)
 from ProEditRecords (nolock)
 where table_id in (200201 --ProFineSums
                   ,200400 --ProContracts
                   ,200843 --ProFine
                   ,201060)--ProPlanDetails
   and add_keys <> '0'
   and convert(int,add_keys) = @contract_id


-- group 4 --
--insert into #TmpProEditRecords
union
select 
  record_number
 ,label_number
 ,table_id
 ,field_id
 ,edit_sign
 ,add_keys
 ,field_value
 ,fix_input
-- ,abonent_id = convert(int,add_keys)
 from ProEditRecords (nolock)
 where table_id = 200300 --ProAbonents
   and add_keys <> '0'
   and convert(int,add_keys) = @abonent_id

-- group 5 --
--insert into #TmpProEditRecords
union
select 
  record_number
 ,label_number
 ,table_id
 ,field_id
 ,edit_sign
 ,add_keys
 ,field_value
 ,fix_input
-- ,account_id = convert(int,add_keys)
 from ProEditRecords (nolock)
 where table_id in (200500 --ProAccounts
                   ,200839 --ProTransActionDates
                   ,200846 --ProSPM
                   ,200925) --ProTransSeals
   and add_keys <> '0'
   and convert(int,add_keys) in (select account_id from ProAccounts (nolock) where contract_id = @contract_id)         

-- group 6 --
--insert into #TmpProEditRecords
union
select 
  record_number
 ,label_number
 ,table_id
 ,field_id
 ,edit_sign
 ,add_keys
 ,field_value
 ,fix_input
--,account_owner_id = convert(int,add_keys)
 from ProEditRecords (nolock)
 where table_id in (200600 --ProAccountOwners
                   ,200911) --ProOwnerPower
   and add_keys <> '0'
   and convert(int,add_keys) in (select account_owner_id
                                 from ProAccountOwners (nolock) 
                                 where contract_id = @contract_id)         

-- Основная Выборка --
select 
  ChDate      = t.fix_input
 ,UserName    = u.full_name
 ,operation   = case when t.edit_sign = 1 then 'Ввод'
                     when t.edit_sign = 2 then 'Редакт-е'
                     when t.edit_sign = 3 then 'Удаление'
                     else 'неизвестно' end
 ,TableName   = tt.comments
 ,Field       = tf.comments
 ,OldValue    = t.field_value
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

