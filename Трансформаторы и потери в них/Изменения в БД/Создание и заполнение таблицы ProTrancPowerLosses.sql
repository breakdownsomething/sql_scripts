-----------------------------------------------------------------
-- �������� � ���������� ������� ProTrancPowerLosses
-- - ���������� ProtrancPowerLoss
-----------------------------------------------------------------
--<1>------ ��������---------------------------------------------
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ProTrancPowerLosses]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
begin
  drop table [dbo].[ProTrancPowerLosses]
end

CREATE TABLE [ProTrancPowerLosses] (
	[ACCOUNT_ID] [int] NOT NULL ,
	[DATE_CALC] [smalldatetime] NOT NULL ,
  [ALL_LOSSES] [int] NOT NULL,
	[FIRST_TRANC_POWER_COEF] [int] NOT NULL ,
	[FIRST_TRANC_POWER_LOSSES] [int] NOT NULL ,
	[SECOND_TRANC_POWER_COEF] [int] NULL ,
	[SECOND_TRANC_POWER_LOSSES] [int] NULL ,
  [COMMENT] [varchar] (255) NULL ,
	CONSTRAINT [PK_ProTrancPowerLosses] PRIMARY KEY  CLUSTERED 
	(
		[ACCOUNT_ID],
		[DATE_CALC]
	)  ON [PRIMARY] 
) ON [PRIMARY]

--<2>-------- �������� ------------------------------------------

if not exists (select * from Tables where table_name = 'ProTrancPowerLosses')
begin
--------------------------
/*
delete from TableFields
where table_id = (select table_id from Tables 
                  where table_name = 'ProTrancPowerLosses')
delete from Tables where table_name = 'ProTrancPowerLosses'
*/
-------------------------
  declare @table_id int
  select @table_id = max(table_id)+5 
  from Tables

  insert into Tables(TABLE_ID, TABLE_NAME,           ALG_ID,  COMMENTS)
  values            (@table_id,'ProTrancPowerLosses',0,      '������ ����� ����� ��� ������� ������')
  insert into TableFields(TABLE_ID,  FIELD_ID,FIELD_NAME,    COMMENTS)
  values                 (@table_id, 1,       'ACCOUNT_ID', '��� ����� �����')
  insert into TableFields(TABLE_ID,  FIELD_ID,FIELD_NAME,  COMMENTS)
  values                 (@table_id, 2,       'DATE_CALC', '���� �������')
  insert into TableFields(TABLE_ID,  FIELD_ID,FIELD_NAME,    COMMENTS)
  values                 (@table_id, 3,       'ALL_LOSSES', '����� ���������� ������')
  insert into TableFields(TABLE_ID,  FIELD_ID,FIELD_NAME,    COMMENTS)
  values                 (@table_id, 4,       'FIRST_TRANC_POWER_COEF', '��������� �������� ������� ��������������')
  insert into TableFields(TABLE_ID,  FIELD_ID,FIELD_NAME,    COMMENTS)
  values                 (@table_id, 5,       'FIRST_TRANC_POWER_LOSSES', '������ � ������ ��������������')
  insert into TableFields(TABLE_ID,  FIELD_ID,FIELD_NAME,    COMMENTS)
  values                 (@table_id, 6,       'SECOND_TRANC_POWER_COEF', '��������� �������� ������� ��������������')
  insert into TableFields(TABLE_ID,  FIELD_ID,FIELD_NAME,    COMMENTS)
  values                 (@table_id, 7,       'SECOND_TRANC_POWER_LOSSLOSSES', '������ �� ������ ��������������')
  insert into TableFields(TABLE_ID,  FIELD_ID,FIELD_NAME,    COMMENTS)
  values                 (@table_id, 8,       'COMMENT', '�����������')
end

--<3>----------- ���������� ----------------------------------------------
insert into ProTrancPowerLosses
(
ACCOUNT_ID,
DATE_CALC,
ALL_LOSSES,
FIRST_TRANC_POWER_COEF,
FIRST_TRANC_POWER_LOSSES,
SECOND_TRANC_POWER_COEF,
SECOND_TRANC_POWER_LOSSES,
COMMENT
)
select 
ACCOUNT_ID                       = PTPL.ACCOUNT_ID,
DATE_CALC                        = PTPL.DATE_CALC,
ALL_LOSSES                       = PTPL.LOSS_QUANTITY,
FIRST_TRANC_POWER_COEF           = PTPL.TRANC_POWER_COEF,
FIRST_TRANC_POWER_LOSSES         = PTPL.LOSS_QUANTITY,
SECOND_TRANC_POWER_COEF          = null,
SECOND_TRANC_POWER_LOSSES        = null,
COMMENT                          = PTPL.COMMENT
from ProTrancPowerLoss PTPL (nolock)

select * from ProTrancPowerLosses