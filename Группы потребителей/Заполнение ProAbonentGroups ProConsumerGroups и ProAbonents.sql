-- Заполнение ProAbonentGroups
alter table ProAbonentGroups disable trigger trProAbonentGroupsUpd
alter table ProAbonentGroups disable trigger trProAbonentGroupsIns

update ProAbonentGroups
set abonent_group_name = 'Прочие (удалить)'
where abonent_group_id = 0

update ProAbonentGroups
set abonent_group_name = 'Прочие'
where abonent_group_id = 3

update ProAbonentGroups
set abonent_group_name = 'КСК'
where abonent_group_id = 4

insert into ProAbonentGroups (abonent_group_id,abonent_group_name)
values (1,'Промышл. 750кВа и выше')

insert into ProAbonentGroups (abonent_group_id,abonent_group_name)
values (2,'Промышл. до 750кВа')

insert into ProAbonentGroups (abonent_group_id,abonent_group_name)
values (5,'Республиканский')

insert into ProAbonentGroups (abonent_group_id,abonent_group_name)
values (6,'Областной')

insert into ProAbonentGroups (abonent_group_id,abonent_group_name)
values (7,'Местный')

insert into ProAbonentGroups (abonent_group_id,abonent_group_name)
values (8,'АПК')

insert into ProAbonentGroups (abonent_group_id,abonent_group_name)
values (9,'Энергопул')

alter table ProAbonentGroups enable trigger trProAbonentGroupsIns
alter table ProAbonentGroups enable trigger trProAbonentGroupsUpd
-- Проверка
--select * from ProAbonentGroups

-- Изменение ProConsumerGroups
alter table ProConsumerGroups disable trigger trProConsumerGroupsUpd

update ProConsumerGroups
set top_group_id = 1
where consumer_group_id = 110

update ProConsumerGroups
set top_group_id = 2
where consumer_group_id in (120,129,130,140,150)

update ProConsumerGroups
set top_group_id = 3
where consumer_group_id in (0,220,221,229,240,300)

update ProConsumerGroups
set top_group_id = 4
where consumer_group_id in (230,231,232,233)

update ProConsumerGroups
set top_group_id = 5
where consumer_group_id in (121,124,211,214)

update ProConsumerGroups
set top_group_id = 6
where consumer_group_id in (213,216)

update ProConsumerGroups
set top_group_id = 7
where consumer_group_id in (204,205,206,207,208,209,122,212,215,222,223,224,225,226,227)

update ProConsumerGroups
set top_group_id = 8
where consumer_group_id in (123,250)

update ProConsumerGroups
set top_group_id = 9
where consumer_group_id = 101

alter table ProConsumerGroups enable trigger trProConsumerGroupsUpd

-- Проверка
--select * from ProConsumerGroups

-- Изменение ProContracts
alter table ProContracts disable trigger trProContractsUpd

update ProContracts
set abonent_group_id = 1
where consumer_group_id = 110

update ProContracts
set abonent_group_id = 2
where consumer_group_id in (120,129,130,140,150)

update ProContracts
set abonent_group_id = 3
where consumer_group_id in (0,220,221,229,240,300)

update ProContracts
set abonent_group_id = 4
where consumer_group_id in (230,231,232,233)

update ProContracts
set abonent_group_id = 5
where consumer_group_id in (121,124,211,214)

update ProContracts
set abonent_group_id = 6
where consumer_group_id in (213,216)

update ProContracts
set abonent_group_id = 7
where consumer_group_id in (204,205,206,207,208,209,122,212,215,222,223,224,225,226,227)

update ProContracts
set abonent_group_id = 8
where consumer_group_id in (123,250)

update ProContracts
set abonent_group_id = 9
where consumer_group_id = 101

alter table ProContracts enable trigger trProContractsUpd

 -- Проверка
--select * from ProContracts
--where  abonent_group_id = 8

-- Удаление ненужной записи из ProAbonentGroups
alter table ProAbonentGroups disable trigger trProAbonentGroupsDel

delete ProAbonentGroups
where abonent_group_id = 0

alter table ProAbonentGroups disable trigger trProAbonentGroupsDel