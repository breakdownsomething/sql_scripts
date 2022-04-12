use aspElectricPro

-- �������� ������� UnitKorsList
if exists (select * from aspElectricPro..sysobjects where
           ID = object_ID('aspElectricPro..UnitKorsList'))
begin
  drop table aspElectricPro..UnitKorsList
end
   
create table [dbo].[UnitKorsList]
(
  [KORS_ID]          smallint     not null primary key,
  [KORS_CODE]        varchar(5)   not null,
  [KAUKS_CODE]       varchar(4)   not null,
  [KORS_CODE_NAME]   varchar(100) null
) 

-- ���������� ������� UnitKorsList
truncate table [dbo].[UnitKorsList]

insert into [dbo].[UnitKorsList] ([KORS_ID],[KORS_CODE],[KAUKS_CODE],[KORS_CODE_NAME])
values(1,'99900','0000', null)

insert into [dbo].[UnitKorsList] ([KORS_ID],[KORS_CODE],[KAUKS_CODE],[KORS_CODE_NAME])
values (2,'72705','0000','����������')

insert into [dbo].[UnitKorsList] ([KORS_ID],[KORS_CODE],[KAUKS_CODE],[KORS_CODE_NAME])
values (3,'72704','0000', null)

insert into [dbo].[UnitKorsList] ([KORS_ID],[KORS_CODE],[KAUKS_CODE],[KORS_CODE_NAME])
values (4,'72703','0000', null)

insert into [dbo].[UnitKorsList] ([KORS_ID],[KORS_CODE],[KAUKS_CODE],[KORS_CODE_NAME])
values (5,'72402','0000', null)

insert into [dbo].[UnitKorsList] ([KORS_ID],[KORS_CODE],[KAUKS_CODE],[KORS_CODE_NAME])
values (6,'67105','0000', null)

insert into [dbo].[UnitKorsList] ([KORS_ID],[KORS_CODE],[KAUKS_CODE],[KORS_CODE_NAME])
values (7,'64103','0000', null)

insert into [dbo].[UnitKorsList] ([KORS_ID],[KORS_CODE],[KAUKS_CODE],[KORS_CODE_NAME])
values (8,'64102','0000',null)

insert into [dbo].[UnitKorsList] ([KORS_ID],[KORS_CODE],[KAUKS_CODE],[KORS_CODE_NAME])
values (9,'64101','0000',null)

insert into [dbo].[UnitKorsList] ([KORS_ID],[KORS_CODE],[KAUKS_CODE],[KORS_CODE_NAME])
values (10,'45152','0000',null)

insert into [dbo].[UnitKorsList] ([KORS_ID],[KORS_CODE],[KAUKS_CODE],[KORS_CODE_NAME])
values (11,'44111','5200','����. �� ������. ���')

insert into [dbo].[UnitKorsList] ([KORS_ID],[KORS_CODE],[KAUKS_CODE],[KORS_CODE_NAME])
values (12,'44102','0000',null)

insert into [dbo].[UnitKorsList] ([KORS_ID],[KORS_CODE],[KAUKS_CODE],[KORS_CODE_NAME])
values (13,'33403','0000',null)

insert into [dbo].[UnitKorsList] ([KORS_ID],[KORS_CODE],[KAUKS_CODE],[KORS_CODE_NAME])
values (14,'32101','0000',null)

insert into [dbo].[UnitKorsList] ([KORS_ID],[KORS_CODE],[KAUKS_CODE],[KORS_CODE_NAME])
values (15,'30301','0000',null)

insert into [dbo].[UnitKorsList] ([KORS_ID],[KORS_CODE],[KAUKS_CODE],[KORS_CODE_NAME])
values (16,'66204','0000','������������')

insert into [dbo].[UnitKorsList] ([KORS_ID],[KORS_CODE],[KAUKS_CODE],[KORS_CODE_NAME])
values (17,'30101','0000','�/� �����.������')

insert into [dbo].[UnitKorsList] ([KORS_ID],[KORS_CODE],[KAUKS_CODE],[KORS_CODE_NAME])
values (18,'30101','1000','�/� ���������')

insert into [dbo].[UnitKorsList] ([KORS_ID],[KORS_CODE],[KAUKS_CODE],[KORS_CODE_NAME])
values (19,'44109','5201','�������� ������������� ������ �����')

-- ��������
select * from UnitKorsList

-- �������� �������
declare
  @max_table_id int
-- ���� �������� ��� ���� ������� ���
select @max_table_id = isnull(
                       (select table_id
                        from tables
                        where table_name = 'UnitKorsList'),0)
if @max_table_id <> 0 
begin
  delete from tablefields where table_ID = @max_table_ID
  delete from tables where table_ID = @max_table_ID
end
-- ������ ����� ��������
select @max_table_ID = 5 + max(table_ID) from tables

insert into Tables(table_ID,table_name,alg_ID,comments)
values(@max_table_ID,'UnitKorsList',0,'���������� ���������')

insert into TableFields(table_ID,field_ID,field_name,comments)
values(@max_table_ID,1,'KORS_ID','�������������')
insert into TableFields(table_ID,field_ID,field_name,comments)
values(@max_table_ID,2,'KORS_CODE','��������� ��������')
insert into TableFields(table_ID,field_ID,field_name,comments)
values(@max_table_ID,3,'KAUKS_CODE','��� �������������� ����� ���������� �����')
insert into TableFields(table_ID,field_ID,field_name,comments)
values(@max_table_ID,4,'KORS_CODE_NAME','��������')

-- �������� 
select * from tables where table_name = 'UnitKorsList'
select * from tablefields where table_ID =
(select table_ID from tables where table_name = 'UnitKorsList')



       