------------------------------------------------------------
-- ������ ���
--<1> �������� � ���������� ���������� ������� ProTrancPowerAcc,
-- ��������������� ��� �������� ����� ����� ����� ��� ������� 
-- ������ � ���������������
-- <2> ���������� � ���������� ���� TRANC_POWER_CHANGE_DATE
-- � �������� ProAccounts � ProAccountsArc
-- <3> �������� ����������� ��������� � ProAccountsArc
-- �� ����� tranc_power_id, tranc_power_account_id, tranc_power_method_id
-- ������� �. 21.09.2004


----------------- �������� ----------------------------------
-------------------------------------------------------------
declare @table_id int,
        @field_id int

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ProTrancPowerAcc]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
begin
  drop table [dbo].[ProTrancPowerAcc]
end

CREATE TABLE [dbo].[ProTrancPowerAcc] (
	[CONTRACT_ID] [int] NOT NULL ,
	[ACCOUNT_ID] [int] NOT NULL ,-- ����� ����� "������"
	[TRANC_POWER_ACCOUNT_ID] [int] NOT NULL ,-- ����� �����, � ������� 
                                           -- ������� ����������� ���
                                           -- ������� ������
	[DATE_CALC_BEG] [smalldatetime] NOT NULL ,-- ���� ��������� ������
	[DATE_CALC_END] [smalldatetime] NULL ,    -- ���� �������� ������
	CONSTRAINT [PK_ProTrancPowerAcc] PRIMARY KEY  CLUSTERED 
	(
		[CONTRACT_ID],
		[ACCOUNT_ID],
		[TRANC_POWER_ACCOUNT_ID],
		[DATE_CALC_BEG]
	)  ON [PRIMARY] 
) ON [PRIMARY]

-- ���� ������� ��� �� ������� ��������� ��
if not exists(select * from Tables where table_name = 'ProTrancPowerAcc')
begin
  select @table_id = max(table_id)+5
  from Tables
 
  insert into Tables(TABLE_ID, TABLE_NAME,        ALG_ID,  COMMENTS)
  values            (@table_id,'ProTrancPowerAcc',0,      '������ ����� ����� ��� ������� ������')

  insert into TableFields(TABLE_ID,  FIELD_ID,FIELD_NAME,    COMMENTS)
  values                 (@table_id, 1,       'CONTRACT_ID', '��� ��������')
  insert into TableFields(TABLE_ID,  FIELD_ID,FIELD_NAME,    COMMENTS)
  values                 (@table_id, 2,       'ACCOUNT_ID', '��� ����� ����� "������"')
  insert into TableFields(TABLE_ID,  FIELD_ID,FIELD_NAME,    COMMENTS)
  values                 (@table_id, 3,       'TRANC_POWER_ACCOUNT_ID', '"��������" �.�. � ������� ������� �����������')
  insert into TableFields(TABLE_ID,  FIELD_ID,FIELD_NAME,    COMMENTS)
  values                 (@table_id, 4,       'DATE_CALC_BEG', '���� ��������� ������')
  insert into TableFields(TABLE_ID,  FIELD_ID,FIELD_NAME,    COMMENTS)
  values                 (@table_id, 5,       'DATE_CALC_END', '���� �������� ������')
end

GO

-- ��������� ������� ProAccounts

declare @table_id int,
        @field_id int

alter table ProAccounts
add TRANC_POWER_CHANGE_DATE smalldatetime null

select @table_id = table_id
from Tables 
where table_name = 'ProAccounts'

select @field_id = max(field_id)+1
from TableFields where table_id = @table_id

insert into TableFields(TABLE_ID,  FIELD_ID,  FIELD_NAME,    COMMENTS)
values                 (@table_id, @field_id, 'TRANC_POWER_CHANGE_DATE', '���� ���������/������ ��������������')


GO

-- ��������� ������� ProAccountsArc
declare @table_id int,
        @field_id int

alter table ProAccountsArc
add TRANC_POWER_CHANGE_DATE smalldatetime null

select @table_id = table_id
from Tables 
where table_name = 'ProAccountsArc'

select @field_id = max(field_id)+1
from TableFields where table_id = @table_id

insert into TableFields(TABLE_ID,  FIELD_ID,  FIELD_NAME,    COMMENTS)
values                 (@table_id, @field_id, 'TRANC_POWER_CHANGE_DATE', '���� ���������/������ ��������������')


GO
-----------------------------------------------------------------------
----------------------����������---------------------------------------
-----------------------------------------------------------------------
if object_id('tempdb..#TmpProAccountsArc') is not null
begin 
drop table #TmpProAccountsArc
end

create table #TmpProAccountsArc
(
date_begin             smalldatetime     null,
contract_id            int           not null,
account_id             int           not null,
tranc_power_id         int               null,
tranc_power_account_id int               null,
tranc_power_method_id  int               null
)

insert into #TmpProAccountsArc
(
date_begin,
contract_id,
account_id,
tranc_power_id,
tranc_power_account_id,
tranc_power_method_id
)
select 
  null,
  contract_id,
  account_id,
  tranc_power_id,
  tranc_power_account_id,
  tranc_power_method_id
from ProAccounts PA (nolock)
where
  tranc_power_id         is not null and
  tranc_power_account_id is not null and
  tranc_power_method_id  is not null 


update #TmpProAccountsArc
set date_begin = PTPL.date_calc
from #TmpProAccountsArc TMP,
     ProTrancPowerLoss  PTPL    
where PTPL.account_id = TMP.account_id
      and PTPL.date_calc = (select min(PTPL1.date_calc)
                            from ProTrancPowerLoss  PTPL1
                            where PTPL1.account_id = TMP.account_id)        

-- ���������� ��� �� ��� ������ �����,
-- �� ������� ������ �� �������
update #TmpProAccountsArc
set date_begin = (select top 1 date_calc_end from ProGroups)
where date_begin is null



-- �������� ��������� � ProAccountsArc
update ProAccountsArc
set
  tranc_power_id         = TMP.tranc_power_id,
  tranc_power_account_id = TMP.tranc_power_account_id,
  tranc_power_method_id  = TMP.tranc_power_method_id,
  TRANC_POWER_CHANGE_DATE = dateadd(mm,-1,dateadd(dd,+1,TMP.date_begin))
from #TmpProAccountsArc TMP,
     ProAccountsArc     PAA
where TMP.date_begin <= PAA.date_begin and
      TMP.contract_id = PAA.contract_id and
      TMP.account_id  = PAA.account_id

update ProAccountsArc
set
  TRANC_POWER_METHOD_ID = TMP.tranc_power_method_id
from #TmpProAccountsArc TMP,
      ProAccountsArc     PAA (nolock)
where TMP.tranc_power_account_id  = PAA.account_id and
      TMP.date_begin <= PAA.date_begin 



-- �������� ��������� � ProAccounts
update ProAccounts
set
  TRANC_POWER_CHANGE_DATE = dateadd(mm,-1,dateadd(dd,+1,TMP.date_begin))
from #TmpProAccountsArc TMP,
      ProAccounts     PAA (nolock)
where TMP.account_id  = PAA.account_id

update ProAccounts
set
  TRANC_POWER_METHOD_ID = TMP.tranc_power_method_id
from #TmpProAccountsArc TMP,
      ProAccounts     PAA (nolock)
where TMP.tranc_power_account_id  = PAA.account_id


-- ���������� ������� ProTrancPowerAcc
insert into ProTrancPowerAcc
(
CONTRACT_ID,
ACCOUNT_ID,
TRANC_POWER_ACCOUNT_ID,
DATE_CALC_BEG,
DATE_CALC_END
)
select
  contract_id,
  account_id,
  tranc_power_account_id,
  DATE_CALC_BEG = date_begin,
  DATE_CALC_END = null 
from
  #TmpProAccountsArc






