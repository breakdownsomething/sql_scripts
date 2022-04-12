-- sp_ProCorrectionReference
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_ProCorrectionReference]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_ProCorrectionReference]
GO
-- sp_ProDivSal
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_ProDivSal]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_ProDivSal]
GO
-- sp_ProDivSalConvert
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_ProDivSalConvert]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_ProDivSalConvert]
GO