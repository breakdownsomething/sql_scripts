-- Скрипт запонения нового поля 'contract_id'
-- в таблице ProEditRecords 
-- Нужно выполнить на базах aspElectricPro и aspElectricPul
-- а также во всех РЭС-ах


/*
 Copyright 2004 ЗАО “Алсеко”. All rights reserved.
 Name:                
 Short Description:   Разовый скрипт
 Autor:	              Матесов Д.С.
 Date:	   	          4.06.2004
 Note:                Работает достаточно долго. 
                      В табличку TimeTrace пишется пошаговая статистика.
*/


create table tempdb..TimeTrace
   (step_number    int not null,
    step_time  datetime not null,
    comment varchar(100) null)

insert into tempdb..TimeTrace (step_number, step_time, comment) values 
                       (0          , getdate(), 'start')
-- group 1---------------------------------------------------------------------------------
-- account_id = convert(int,SUBSTRING ( add_keys, 0, CHARINDEX (',',add_keys)))
update ProEditRecords
set contract_id = PA.contract_id
from  ProAccounts    PA  (nolock)
where PA.account_id = convert(int,SUBSTRING (add_keys, 0, CHARINDEX (',',add_keys))) 
  and table_id in (200000, -- ProCntCounts
                       200700, -- ProCnt
                       200808, -- ProCntActionDates
                       200923) -- ProCntSeals
insert into tempdb..TimeTrace (step_number, step_time, comment) values 
                       (1          , getdate(), 'group 1 - OK')

-- group 2 ---------------------------------------------------------------------------------
-- contract_number = convert(int,add_keys)
insert into tempdb..TimeTrace (step_number, step_time, comment) values 
                       (2          , getdate(), 'group 2 - start')

update ProEditRecords
set contract_id = PC.contract_id
from  ProContracts   PC  (nolock)
where PC.contract_number = convert(int,add_keys)
and table_id = 200100 -- ProCalcs


insert into tempdb..TimeTrace (step_number, step_time, comment) values 
                       (3          , getdate(), 'group 2 - OK')

-- group 3 -----------------------------------------------------------------------------------
-- contract_id = convert(int,add_keys)
insert into tempdb..TimeTrace (step_number, step_time, comment) values 
                       (4          , getdate(), 'group 3 - start')

update ProEditRecords
set contract_id = convert(int,add_keys)
where table_id in (200201, --ProFineSums
                   200400, --ProContracts
                   200843, --ProFine
                   201060) --ProPlanDetails

insert into tempdb..TimeTrace (step_number, step_time, comment) values 
                       (5          , getdate(), 'group 3 - OK')

-- group 4 -----------------------------------------------------------------------------------
-- abonent_id = convert(int,add_keys)
insert into tempdb..TimeTrace (step_number, step_time, comment) values 
                       (6          , getdate(), 'group 4 - start')

update ProEditRecords
set contract_id = PC.contract_id
from  ProContracts   PC  (nolock)
where PC.abonent_id = convert(int,add_keys)
  and table_id = 200300 --ProAbonents

insert into tempdb..TimeTrace (step_number, step_time, comment) values 
                       (7          , getdate(), 'group 4 - OK')

-- group 5 -----------------------------------------------------------------------------------------
-- account_id = convert(int,add_keys)
insert into tempdb..TimeTrace (step_number, step_time, comment) values 
                       (8          , getdate(), 'group 4 - start')

update ProEditRecords
set contract_id = PA.contract_id
from ProAccounts    PA  (nolock)
where PA.account_id = convert(int,add_keys)
  and table_id in (200500, --ProAccounts
                       200839, --ProTransActionDates
                       200846, --ProSPM
                       200925) --ProTransSeals

insert into tempdb..TimeTrace (step_number, step_time, comment) values 
                       (9          , getdate(), 'group 5 - OK')

-- group 6 ----------------------------------------------------------------
-- account_owner_id = convert(int,add_keys)
insert into tempdb..TimeTrace (step_number, step_time, comment) values 
                       (10          , getdate(), 'group 6 - start')

update ProEditRecords
set contract_id = PAO.contract_id
from ProAccountOwners    PAO  (nolock)
where PAO.account_owner_id = convert(int,add_keys)
  and table_id in (200600, --ProAccountOwners
                   200911) --ProOwnerPower

insert into tempdb..TimeTrace (step_number, step_time, comment) values 
                       (11          , getdate(), 'group 6 - OK')

select * from tempdb..TimeTrace
drop table tempdb..TimeTrace
