-- Разовый скрипт
-- Добавление в таблицу ProCalcs
-- поля CONSUMER_BUDGET_ID

use aspElectricPro
ALTER TABLE [ProCalcs]
ADD [CONSUMER_BUDGET_ID] [smallint] NULL 
GO

use aspElectricPul
ALTER TABLE [ProCalcs]
ADD [CONSUMER_BUDGET_ID] [smallint] NULL 
GO

