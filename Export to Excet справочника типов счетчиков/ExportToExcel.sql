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
  [significant]     [varchar] (20) null, -- значность
  [phase_count]     [varchar] (20) null, -- фазность
  [cnt_system]      [varchar] (20) null, -- прицип действия
  [cnt_current]     [varchar] (20) null, -- ток
  [cnt_voltage]     [varchar] (20) null, -- напряжение
  [certified]       [varchar] (20) null, -- сертификация (да/нет)
  [rotation_count]  [varchar] (20) null -- кол-во оборотов
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
  delete from #tmp -- очистка временной таблицы

  -- далее обработка той фигни, что в некоторых кортежах
  -- через точку с запятой перечислено 5 величин, а в некоторых 6
  -- Историческое наследие - ничего не поделаешь.
  if charindex('ертифицирован',@SPECIFICATIONS) = 0 
    begin
    select @SPECIFICATIONS = @SPECIFICATIONS + ';'
    end

  -- Теперь заменяем точки с запятыми на просто запятые и вставляем 
  -- ковычки вокруг значений.
  select  @SPECIFICATIONS = '''' + replace(@SPECIFICATIONS,';',''',''')+''''

  exec('
  insert into #tmp(col1,col2,col3,col4,col5,col6,col7)
  values ('+@SPECIFICATIONS+') 
  ')

  -- собираем согласно значений  @PREC и @SCALE
  -- значность шкалы счетчика
  -- @PREC - общее кол-во знаков
  -- @SCALE - кол-во знаков после запятой
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

  -- записываем вычисленные поля в таблицу
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

 'ТИП'             = [COUNTER_TYPE_ID],
 'КОЛ-ВО ТАРИФОВ'  = [COUNTER_TYPE_CLASS_ID],
 'НАЗВАНИЕ'        = [COUNTER_TYPE_NAME],
 'ЗНАЧНОСТЬ'       = [significant],
 'ПЕРИОД ПРОВЕРКИ' = [CHECK_PERIOD],
 'ПЕРИОД ЗАМЕНЫ'   = [REPLACE_TERM],
 'ФАЗНОСТЬ'        = [phase_count],
 'СИСТЕМА'         = [cnt_system],
 'ТОК (A)'         = [cnt_current],
 'НАПРЯЖЕНИЕ (В)'  = [cnt_voltage],
 'ЧИСЛО ОБОРОТОВ'  = [rotation_count],
 'СЕРТИФИКАЦИЯ'    = [certified]

from #TmpCntTypes

drop table #tmp
drop table #TmpCntTypes




--select distinct counter_type_class_id from CntTypes






