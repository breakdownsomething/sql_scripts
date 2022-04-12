-- Скрипт изменения справочника
-- Source_1E базы данных asElectricPro
-- Матесов Д. 26-07-2004
--

use aspElectricPro

-- 171
update Source_1E
set list_codes = list_codes + '171,'
where row_id = 340
-- 174
update Source_1E
set list_codes = list_codes + '174,'
where row_id = 530
-- 177
update Source_1E
set list_codes = list_codes + '177,'
where row_id = 680


--select * from Source_1E