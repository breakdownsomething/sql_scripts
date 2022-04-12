SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


ALTER  TRIGGER trCntInspectorsToElectricProDel ON CntInspectors
FOR DELETE
AS
DECLARE
	@INSPECTOR_ID	smallint,
	@INSPECTOR_NAME	varchar (40),
	@SUBGROUP_ID	tinyint,
	@RETIRE_SIGN	bit,
	@bErrorPro		bit,
  @bErrorPul		bit,
  @bErrorHeat		bit
SET NOCOUNT ON
--aspElectricPro
SELECT @bErrorPro=1
WHILE @bErrorPro=1
BEGIN
  BEGIN TRAN
  SELECT @INSPECTOR_ID=INSPECTOR_ID FROM Deleted
  IF EXISTS (SELECT	* FROM master..sysdatabases WHERE	name='aspElectricPro')
  BEGIN
    DELETE aspElectricPro..CntInspectors WHERE INSPECTOR_ID=@INSPECTOR_ID
    IF (@@ERROR<>0)
    BEGIN
      ROLLBACK TRANSACTION
	    BREAK
    END
  END
  SELECT @bErrorPro=0
  COMMIT TRAN
END
--aspElectricPul
SELECT @bErrorPul=1
WHILE @bErrorPul=1
BEGIN
  BEGIN TRAN
  SELECT @INSPECTOR_ID=INSPECTOR_ID FROM Deleted
  IF EXISTS (SELECT	* FROM master..sysdatabases WHERE	name='aspElectricPul')
  BEGIN
    DELETE aspElectricPul..CntInspectors WHERE INSPECTOR_ID=@INSPECTOR_ID
    IF (@@ERROR<>0)
    BEGIN
      ROLLBACK TRANSACTION
	    BREAK
    END
  END
  SELECT @bErrorPul=0
  COMMIT TRAN
END
--aspHeat
SELECT @bErrorHeat=1
WHILE @bErrorHeat=1
BEGIN
  BEGIN TRAN
  SELECT @INSPECTOR_ID=INSPECTOR_ID FROM Deleted
  IF EXISTS (SELECT	* FROM master..sysdatabases WHERE	name='aspHeat')
  BEGIN
    DELETE aspHeat..CntInspectors WHERE INSPECTOR_ID=@INSPECTOR_ID
    IF (@@ERROR<>0)
    BEGIN
      ROLLBACK TRANSACTION
	    BREAK
    END
  END
  SELECT @bErrorHeat=0
  COMMIT TRAN
END


SET NOCOUNT OFF


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

