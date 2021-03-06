if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ProTrancPowerAcc]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[ProTrancPowerAcc]
GO

CREATE TABLE [dbo].[ProTrancPowerAcc] (
	[CONTRACT_ID] [int] NOT NULL ,
	[ACCOUNT_ID] [int] NOT NULL ,
	[TRANC_POWER_ACCOUNT_ID] [int] NOT NULL ,
	[DATE_CALC_BEG] [smalldatetime] NOT NULL ,
	[DATE_CALC_END] [smalldatetime] NULL 
) ON [PRIMARY]
GO

