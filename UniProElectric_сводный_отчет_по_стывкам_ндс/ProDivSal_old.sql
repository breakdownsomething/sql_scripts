-- Сею таблицу нужно создать в базе aspElectricPro !!!
use aspElectricPro

if exists (select * from dbo.sysobjects
           where id = object_id(N'[dbo].[ProDivSal]')
                 and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[ProDivSal]
GO

CREATE TABLE [dbo].[ProDivSal] (
	[CONTRACT_ID]     [int]        NOT NULL ,--PK
	[DATE_CALC]       [datetime]   NOT NULL ,--PK
  [NDS_TAX]         [int]        NOT NULL ,--PK
-- сальдо на начало месяца--------
	[BQUANTITY]       [int]            NULL ,
	[BSUM_EE]         [decimal](18, 2) NULL ,
	[BSUM_NDS]        [decimal](18, 2) NULL ,
	[BSUM_EXC]        [decimal](18, 2) NULL ,
-- Начисления------------------------
	[NQUANTITY]       [int]            NULL ,
	[NSUM_EE]         [decimal](18, 2) NULL ,
	[NSUM_NDS]        [decimal](18, 2) NULL ,
	[NSUM_EXC]        [decimal](18, 2) NULL ,
-- Платежи--------------------------------
	[PQUANTITY]       [int]            NULL ,
	[PSUM_EE]         [decimal](18, 2) NULL ,
	[PSUM_NDS]        [decimal](18, 2) NULL ,
	[PSUM_EXC]        [decimal](18, 2) NULL ,
-- сальдо на конец-------------------------
	[EQUANTITY]       [int]            NULL ,
	[ESUM_EE]         [decimal](18, 2) NULL ,
	[ESUM_NDS]        [decimal](18, 2) NULL ,
	[ESUM_EXC]        [decimal](18, 2) NULL ,

	PRIMARY KEY ([CONTRACT_ID],[DATE_CALC],[NDS_TAX])

) ON [PRIMARY]
GO

