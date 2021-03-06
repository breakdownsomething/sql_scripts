--SELECT * FROM ProCalcTYpes
--USE aspElectricPro
SELECT
 Cn.GROUP_ID,
 Cn.CONTRACT_ID,
 Cn.CONTRACT_NUMBER,
 A=IsNull(
  (SELECT
     SUM(IsNull(C.SUM_NDS,0))
    FROM
     ProCalcs C
    WHERE
     C.DATE_CALC='2004-08-31' AND
     C.CONTRACT_ID=Cn.CONTRACT_ID
  ),0),
 B= IsNull(
  (SELECT
     SUM(IsNull(CD.SUM_CALC,0))
    FROM
     ProCalcs C,
     ProCalcDetails CD
    WHERE
     C.DATE_CALC='2004-08-31' AND
     C.CONTRACT_ID=Cn.CONTRACT_ID AND
     CD.CALC_ID=C.CALC_ID AND
     CD.CALC_TYPE_ID=29
--    AND CD.MEASURE_ID=8 
  ),0)
 INTO
  #TmpTab 
 FROM
  ProContracts Cn
-- WHERE
--  Cn.GROUP_ID=10017
 SELECT
 'Сумма в ProCalcs'=   SUM(A),
 'Сумма в ProCalcsDetails'=   SUM(B),
 'Разность'=  SUM(A)-SUM(B)
  FROM 
   #TmpTab

 SELECT
 GROUP_ID,
 CONTRACT_ID,
 CONTRACT_NUMBER,
 'Сумма в ProCalcs'=A,
 'Сумма в ProCalcsDetails'=B
  FROM 
   #TmpTab
  WHERE
   A<>B
ORDER BY
 GROUP_ID,
 CONTRACT_NUMBER



DROP TABLE #TmpTab
