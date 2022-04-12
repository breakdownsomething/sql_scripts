SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


ALTER  TRIGGER trCntInspectorsToElectricProIns ON CntInspectors FOR INSERT
AS

DECLARE
	@bProError bit
 ,@bPulError bit
 ,@bHeatError bit
SET NOCOUNT ON
-- aspElectricPro --
SELECT @bProError=1
WHILE  @bProError=1
BEGIN
  BEGIN TRAN
    IF EXISTS (SELECT	* FROM master..sysdatabases WHERE	name='aspElectricPro')
    BEGIN
      IF NOT EXISTS (SELECT	C.INSPECTOR_ID
                     FROM	aspElectricPro..CntInspectors		C(NOLOCK) ,
                       		Inserted	                      I(NOLOCK)
	                   WHERE	C.INSPECTOR_ID=I.INSPECTOR_ID)
      BEGIN
	      INSERT aspElectricPro..CntInspectors
            	(INSPECTOR_ID,INSPECTOR_NAME,SUBGROUP_ID,RETIRE_SIGN)
	      SELECT INSPECTOR_ID,INSPECTOR_NAME,SUBGROUP_ID,RETIRE_SIGN		
	      FROM Inserted	(NOLOCK)
      END
      IF	(@@ERROR<>0)
      BEGIN
        ROLLBACK TRANSACTION
        BREAK
      END
    END
    SELECT @bProError=0
    COMMIT TRAN
END

-- aspElectricPul --
SELECT @bPulError=1
WHILE  @bPulError=1
BEGIN
  BEGIN TRAN
    IF EXISTS (SELECT	* FROM master..sysdatabases WHERE	name='aspElectricPul')
    BEGIN
      IF NOT EXISTS (SELECT	C.INSPECTOR_ID
                     FROM	aspElectricPul..CntInspectors		C(NOLOCK) ,
                       		Inserted	                      I(NOLOCK)
	                   WHERE	C.INSPECTOR_ID=I.INSPECTOR_ID)
      BEGIN
	      INSERT aspElectricPul..CntInspectors
            	(INSPECTOR_ID,INSPECTOR_NAME,SUBGROUP_ID,RETIRE_SIGN)
	      SELECT INSPECTOR_ID,INSPECTOR_NAME,SUBGROUP_ID,RETIRE_SIGN		
	      FROM Inserted	(NOLOCK)
      END
      IF	(@@ERROR<>0)
      BEGIN
        ROLLBACK TRANSACTION
        BREAK
      END
    END
    SELECT @bPulError=0
    COMMIT TRAN
END
-- aspHeat --
SELECT @bHeatError=1
WHILE  @bHeatError=1
BEGIN
  BEGIN TRAN
    IF EXISTS (SELECT	* FROM master..sysdatabases WHERE	name='aspHeat')
    BEGIN
      IF NOT EXISTS (SELECT	C.INSPECTOR_ID
                     FROM	aspHeat..CntInspectors		C(NOLOCK) ,
                       		Inserted	                      I(NOLOCK)
	                   WHERE	C.INSPECTOR_ID=I.INSPECTOR_ID)
      BEGIN
	      INSERT aspHeat..CntInspectors
            	(INSPECTOR_ID,INSPECTOR_NAME,SUBGROUP_ID,RETIRE_SIGN)
	      SELECT INSPECTOR_ID,INSPECTOR_NAME,SUBGROUP_ID,RETIRE_SIGN		
	      FROM Inserted	(NOLOCK)
      END
      IF	(@@ERROR<>0)
      BEGIN
        ROLLBACK TRANSACTION
        BREAK
      END
    END
    SELECT @bHeatError=0
    COMMIT TRAN
END



SET NOCOUNT OFF

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

