declare 
@table_id int

-- ProTrancPowerCoef
select  @table_id = table_id from tables where table_name = 'ProTrancPowerLoss'

delete from tablefields where table_id = @table_id

insert into tablefields (table_id,    field_id,  field_name,         comments)
                 values (@table_id,   1,        'account_id',       'id точки учета')
insert into tablefields (table_id,    field_id,  field_name,         comments)
                 values (@table_id   ,2,        'date_calc',        'последний день расчетного периода')
insert into tablefields (table_id,    field_id,  field_name,         comments)
                 values (@table_id,   3,        'tranc_power_coef', 'коэффициент загрузки трансформатора в %')
insert into tablefields (table_id,    field_id,  field_name,              comments)
                 values (@table_id,   4,        'tranc_power_method_id', 'метод расчета потерь в трансформаторе')
insert into tablefields (table_id,    field_id,  field_name,       comments)
                 values (@table_id,   5,        'use_days',       'количество дней работы Ѕ≈« счетчика')
insert into tablefields (table_id,    field_id,  field_name,       comments)
                 values (@table_id,   6,        'loss_quantity',  'потери за данный расчетный период')
insert into tablefields (table_id,    field_id,  field_name,       comments)
                 values (@table_id,   7,        'comment',        'комментарий')

--select * from tablefields where table_id  = @table_id


-- ProTrancPowerCoef
select  @table_id = table_id from tables where table_name = 'ProTrancPowerCoef'

delete from tablefields where table_id = @table_id
insert into tablefields (table_id,   field_id, field_name,          comments)
                 values (@table_id,  1,        'tranc_power_id',   'тип трансформатора')
insert into tablefields (table_id,   field_id, field_name,          comments)
                 values (@table_id  ,2,        'tranc_power_coef',  'коэффициент загрузки трансформатора в %')
insert into tablefields (table_id,   field_id, field_name,          comments)
                 values (@table_id,  3,        'tranc_power_loss',  'количество рассе€нных к¬т за мес€ц при данном коэффициенте загрузки')

--select * from tablefields where table_id  = @table_id

-- ProTrancPowerCoef
select  @table_id = table_id from tables where table_name = 'ProTrancPowerList'

delete from tablefields where table_id = @table_id
insert into tablefields (table_id,   field_id, field_name,          comments)
                 values (@table_id,  1,        'tranc_power_id',   'тип трансформатора')
insert into tablefields (table_id,   field_id, field_name,          comments)
                 values (@table_id  ,2,        'tranc_power_name',  'название модели трансформатора')
insert into tablefields (table_id,   field_id, field_name,               comments)
                 values (@table_id,  3,        'tranc_power_capacity',  'номинальна€ мощность')

--select * from tablefields where table_id  = @table_id