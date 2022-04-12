-- Скрипт изменения справочника
-- Source_1E базы данных asElectricPul
-- Матесов Д. 26-07-2004
--

use aspElectricPul

-- 188
insert  into Source_1E 
       (row_id,
        row_number,
        row_name,
        list_codes,
        tariff_value,
        rowguid)

values (91,
       '1.8.',
       'За 1 кВтч потребленной энергии для Железной Дороги',
       '188,',
        4.087,
        newid())


-- 189
update Source_1E
set list_codes = list_codes + '189,'
where row_id = 100
-- 190
update Source_1E
set list_codes = list_codes + '190,'
where row_id = 110
-- 191
update Source_1E
set list_codes = list_codes + '191,'
where row_id = 120
-- 197, 198
update Source_1E
set list_codes = list_codes + '197, 198,'
where row_id = 240
-- 199
update Source_1E
set list_codes = list_codes + '199,'
where row_id = 220
-- 200
update Source_1E
set list_codes = list_codes + '200,'
where row_id = 430
-- 201
update Source_1E
set list_codes = list_codes + '201,'
where row_id = 450
-- 202
update Source_1E
set list_codes = list_codes + '202,'
where row_id = 550
-- 203
update Source_1E
set list_codes = list_codes + '203,'
where row_id = 570
-- 204
update Source_1E
set list_codes = list_codes + '204,'
where row_id = 360
-- 205
update Source_1E
set list_codes = list_codes + '205,'
where row_id = 380


--select * from Source_1E