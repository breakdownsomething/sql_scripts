declare 
@table_id int

-- ProTrancPowerCoef
select  @table_id = table_id from tables where table_name = 'ProTrancPowerLoss'

delete from tablefields where table_id = @table_id

insert into tablefields (table_id,    field_id,  field_name,         comments)
                 values (@table_id,   1,        'account_id',       'id ����� �����')
insert into tablefields (table_id,    field_id,  field_name,         comments)
                 values (@table_id   ,2,        'date_calc',        '��������� ���� ���������� �������')
insert into tablefields (table_id,    field_id,  field_name,         comments)
                 values (@table_id,   3,        'tranc_power_coef', '����������� �������� �������������� � %')
insert into tablefields (table_id,    field_id,  field_name,              comments)
                 values (@table_id,   4,        'tranc_power_method_id', '����� ������� ������ � ��������������')
insert into tablefields (table_id,    field_id,  field_name,       comments)
                 values (@table_id,   5,        'use_days',       '���������� ���� ������ ��� ��������')
insert into tablefields (table_id,    field_id,  field_name,       comments)
                 values (@table_id,   6,        'loss_quantity',  '������ �� ������ ��������� ������')
insert into tablefields (table_id,    field_id,  field_name,       comments)
                 values (@table_id,   7,        'comment',        '�����������')

--select * from tablefields where table_id  = @table_id


-- ProTrancPowerCoef
select  @table_id = table_id from tables where table_name = 'ProTrancPowerCoef'

delete from tablefields where table_id = @table_id
insert into tablefields (table_id,   field_id, field_name,          comments)
                 values (@table_id,  1,        'tranc_power_id',   '��� ��������������')
insert into tablefields (table_id,   field_id, field_name,          comments)
                 values (@table_id  ,2,        'tranc_power_coef',  '����������� �������� �������������� � %')
insert into tablefields (table_id,   field_id, field_name,          comments)
                 values (@table_id,  3,        'tranc_power_loss',  '���������� ���������� ��� �� ����� ��� ������ ������������ ��������')

--select * from tablefields where table_id  = @table_id

-- ProTrancPowerCoef
select  @table_id = table_id from tables where table_name = 'ProTrancPowerList'

delete from tablefields where table_id = @table_id
insert into tablefields (table_id,   field_id, field_name,          comments)
                 values (@table_id,  1,        'tranc_power_id',   '��� ��������������')
insert into tablefields (table_id,   field_id, field_name,          comments)
                 values (@table_id  ,2,        'tranc_power_name',  '�������� ������ ��������������')
insert into tablefields (table_id,   field_id, field_name,               comments)
                 values (@table_id,  3,        'tranc_power_capacity',  '����������� ��������')

--select * from tablefields where table_id  = @table_id