--use aspElectricPro
go
alter table [dbo].[UnitKorsList] add
[KORS_GROUP_SIGN] bit not null default 0
go
declare @table_id int,
        @field_id int

  select @table_id = table_id
  from Tables
  where table_name = 'UnitKorsList'

  select @field_id = max(field_id)+1
  from TableFields
  where table_id = @table_id
         

insert into TableFields(table_ID,field_ID,field_name,comments)
values(@table_id,@field_id,'KORS_GROUP_SIGN','Признак группировки по коррсчету (в отчете)')

--select * from TableFields where table_id = (
--select table_id from tables where table_name = 'UnitKorsList')

update UnitKorsList
set KORS_CODE_NAME = 'Касса ГЭРС',
    KORS_GROUP_SIGN = convert(bit,1)
where KORS_CODE = '45152' and
      KAUKS_CODE = '0000'
    
declare @max_kors_id int
select @max_kors_id = max(kors_id) from UnitKorsList

insert UnitKorsList(KORS_ID,KORS_CODE,KAUKS_CODE,KORS_CODE_NAME,KORS_GROUP_SIGN)
values (@max_kors_id+1,'45152','0001','Касса РЭС-1',convert(bit,1))

insert UnitKorsList(KORS_ID,KORS_CODE,KAUKS_CODE,KORS_CODE_NAME,KORS_GROUP_SIGN)
values (@max_kors_id+2,'45152','0004','Касса РЭС-4',convert(bit,1))

insert UnitKorsList(KORS_ID,KORS_CODE,KAUKS_CODE,KORS_CODE_NAME,KORS_GROUP_SIGN)
values (@max_kors_id+3,'45152','0005','Касса РЭС-5',convert(bit,1))

insert UnitKorsList(KORS_ID,KORS_CODE,KAUKS_CODE,KORS_CODE_NAME,KORS_GROUP_SIGN)
values (@max_kors_id+4,'45152','0007','Касса РЭС-7',convert(bit,1))


 