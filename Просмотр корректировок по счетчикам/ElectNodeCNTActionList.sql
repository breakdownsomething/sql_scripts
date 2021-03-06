if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ElectNodeCntActionDates]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[ElectNodeCntActionDates]
GO

CREATE TABLE [dbo].[ElectNodeCntActionDates] (
	[NODEID] [int] NOT NULL ,
	[CNT_ID] [smallint] NOT NULL ,
	[ACTION_ID] [tinyint] NOT NULL ,
	[DATE_ID] [smalldatetime] NOT NULL ,
	[DEL_SIGN] [tinyint] NOT NULL ,
	[CHECK_COUNT] [int] NULL 
) ON [PRIMARY]
GO

