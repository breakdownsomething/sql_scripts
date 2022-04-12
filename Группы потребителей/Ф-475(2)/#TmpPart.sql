IF EXISTS (SELECT * FROM TempDB..sysobjects
           WHERE id = object_id('TempDB..#TmpPart') )
begin
 DROP TABLE #TmpPart
end

SELECT Distinct
  Cn.CONTRACT_ID,
  Cn.CONTRACT_NUMBER,
  Ab.ABONENT_NAME
 INTO #TmpPart
 FROM
  ProContracts Cn (Nolock),
  ProAbonents Ab (Nolock)
 WHERE
  Ab.ABONENT_ID=Cn.ABONENT_ID
