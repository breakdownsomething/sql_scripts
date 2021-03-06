CREATE TABLE [dbo].[EditRecords] (
	[RECORD_NUMBER] [int] IDENTITY (1, 1) NOT NULL ,
	[LABEL_NUMBER] [int] NOT NULL ,
	[TABLE_ID] [int] NOT NULL ,
	[FIELD_ID] [tinyint] NOT NULL ,
	[EDIT_SIGN] [tinyint] NOT NULL ,
	[ACCOUNT_ID] [int] NOT NULL ,
	[ADD_KEYS] [varchar] (80) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[FIELD_VALUE] [varchar] (80) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[FIX_INPUT] [smalldatetime] NOT NULL 
) ON [PRIMARY]
GO

