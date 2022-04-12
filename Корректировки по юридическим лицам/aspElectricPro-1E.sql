-- Скрипт изменения справочника
-- Source_1E базы данных asElectricPro
-- Матесов Д. 11-08-2004
--

use aspElectricPro

-- 530
update Source_1E
set list_codes = ' 27, 125, 174,'
where row_id = 530
-- 560
update Source_1E
set list_codes = ' 8,'
where row_id = 560

select * from Source_1E
