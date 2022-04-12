-- 1) Temporary table creation
if exists (select * from tempdb..sysobjects
           where id = OBJECT_ID('tempdb..#TmpCntTypes'))
begin
  drop table #TmpCntTypes
end

CREATE TABLE [#TmpCntTypes] (
	[COUNTER_TYPE_ID] [smallint] NOT NULL ,
	[COUNTER_TYPE_CLASS_ID] [tinyint] NOT NULL ,
	[COUNTER_TYPE_NAME] [varchar] (40) COLLATE SQL_Latin1_General_CP1251_CI_AS NOT NULL ,
	[PREC] [tinyint] NOT NULL ,
	[SCALE] [tinyint] NOT NULL ,
	[CHECK_PERIOD] [smallint] NULL ,
	[REPLACE_TERM] [smallint] NULL ,
	[SPECIFICATIONS] [varchar] (255) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL,
-----------------------------------------------------------
  [significant]     [varchar] (20) null, -- ���������
  [phase_count]     [varchar] (20) null, -- ��������
  [cnt_system]      [varchar] (20) null, -- ������ ��������
  [cnt_current]     [varchar] (20) null, -- ���
  [cnt_voltage]     [varchar] (20) null, -- ����������
  [certified]       [varchar] (20) null, -- ������������ (��/���)
  [rotation_count]  [varchar] (20) null -- ���-�� ��������
-----------------------------------------------------------
	)

--2) Import of original data to temporary table
insert into #TmpCntTypes(
  [COUNTER_TYPE_ID],
	[COUNTER_TYPE_CLASS_ID],
	[COUNTER_TYPE_NAME],
	[PREC],
	[SCALE],
	[CHECK_PERIOD],
	[REPLACE_TERM],
	[SPECIFICATIONS],
  [significant],
  [phase_count],
  [cnt_system],
  [cnt_current],
  [cnt_voltage],
  [certified],
  [rotation_count]
)
select 
  [COUNTER_TYPE_ID],
	[COUNTER_TYPE_CLASS_ID],
	[COUNTER_TYPE_NAME],
	[PREC],
	[SCALE],
	[CHECK_PERIOD],
	[REPLACE_TERM],
	[SPECIFICATIONS],
  null,
  null,
  null,
  null,
  null,
  null,
  null
from CntTypes 

-- 3) Calculating additional fields
declare
@COUNTER_TYPE_ID smallint,
@PREC            tinyint,
@SCALE           tinyint,
@SPECIFICATIONS  varchar(255),
@significant     varchar(20),
@i               int -- internal counter


create table #tmp (col1 varchar(100) default null,
                   col2 varchar(100) default null,
                   col3 varchar(100) default null,
                   col4 varchar(100) default null,
                   col5 varchar(100) default null,
                   col6 varchar(100) default null,
                   col7 varchar(100) default null)

declare curTmpCntTypes cursor static for
select
  [COUNTER_TYPE_ID],
	[PREC],
	[SCALE],
	[SPECIFICATIONS]
from #TmpCntTypes (nolock)

open curTmpCntTypes
fetch first from curTmpCntTypes
into @COUNTER_TYPE_ID,
     @PREC           ,
     @SCALE          ,
     @SPECIFICATIONS 

while (@@FETCH_STATUS <> -1)
  begin
  ---------------------- 
  ---- calculating and updates
  delete from #tmp -- ������� ��������� �������

  -- ����� ��������� ��� �����, ��� � ��������� ��������
  -- ����� ����� � ������� ����������� 5 �������, � � ��������� 6
  -- ������������ �������� - ������ �� ���������.
  if charindex('�������������',@SPECIFICATIONS) = 0 
    begin
    select @SPECIFICATIONS = @SPECIFICATIONS + ';'
    end

  -- ������ �������� ����� � �������� �� ������ ������� � ��������� 
  -- ������� ������ ��������.
  select  @SPECIFICATIONS = '''' + replace(@SPECIFICATIONS,';',''',''')+''''

  exec('
  insert into #tmp(col1,col2,col3,col4,col5,col6,col7)
  values ('+@SPECIFICATIONS+') 
  ')

  -- �������� �������� ��������  @PREC � @SCALE
  -- ��������� ����� ��������
  -- @PREC - ����� ���-�� ������
  -- @SCALE - ���-�� ������ ����� �������
  select @significant = ''
  select @i = 0
  while @i < (@PREC - @SCALE)
  begin
    select @significant = @significant + '0'
    select @i = @i + 1
  end
  
  if @SCALE <> 0
  begin
    select @significant = @significant + ','
  end

  select @i = 0
  while @i < @SCALE
  begin
    select @significant = @significant + '0'
    select @i = @i + 1
  end

  -- ���������� ����������� ���� � �������
  update #TmpCntTypes
  set 
  [significant] = @significant,
  [phase_count] = t.col1,
  [cnt_system]  = t.col2,
  [cnt_current] = t.col3,
  [cnt_voltage] = t.col4,
  [certified]   = t.col6,
  [rotation_count] = t.col5 
  from #tmp t
  where COUNTER_TYPE_ID = @COUNTER_TYPE_ID   

  ----------------------
  fetch next from curTmpCntTypes
  into @COUNTER_TYPE_ID,
     @PREC            ,
     @SCALE           ,
     @SPECIFICATIONS  
  end
close curTmpCntTypes
deallocate curTmpCntTypes

-- 4) Selecting results
select 

 '���'             = [COUNTER_TYPE_ID],
 '���-�� �������'  = [COUNTER_TYPE_CLASS_ID],
 '��������'        = [COUNTER_TYPE_NAME],
 '���������'       = [significant],
 '������ ��������' = [CHECK_PERIOD],
 '������ ������'   = [REPLACE_TERM],
 '��������'        = [phase_count],
 '�������'         = [cnt_system],
 '��� (A)'         = [cnt_current],
 '���������� (�)'  = [cnt_voltage],
 '����� ��������'  = [rotation_count],
 '������������'    = [certified]

from #TmpCntTypes

drop table #tmp
drop table #TmpCntTypes




--select distinct counter_type_class_id from CntTypes






