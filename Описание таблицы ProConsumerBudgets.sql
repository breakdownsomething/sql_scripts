declare 
  @max_table_id int 
select @max_table_id = 5 + (select max(table_id)
                            from Tables)

INSERT INTO [aspElectricPro].[dbo].[Tables]
([TABLE_ID],
 [TABLE_NAME],
 [ALG_ID],
 [COMMENTS])
VALUES
(@max_table_id,
 'ProConsumerBudgets',
 1,
 'Справочник категорий потребителей-бюджетников')


INSERT INTO [aspElectricPro].[dbo].[TableFields]
([TABLE_ID],
 [FIELD_ID],
 [FIELD_NAME],
 [COMMENTS])
VALUES
(@max_table_id,
 1,
 'CONSUMER_BUDGET_ID',
 'Код категории')

INSERT INTO [aspElectricPro].[dbo].[TableFields]
([TABLE_ID],
 [FIELD_ID],
 [FIELD_NAME],
 [COMMENTS])
VALUES
(@max_table_id,
 2,
 'CONSUMER_BUDGET_NAME',
 'Наименование категории')


-- Проверка
select * from Tables where table_name = 'ProConsumerBudgets'
select * from TableFields where table_id = 
  (select table_id from Tables where table_name = 'ProConsumerBudgets')




