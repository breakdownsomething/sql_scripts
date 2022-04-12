DECLARE
        @pCalcExists integer,
        @pACCOUNT_ID integer,
        @pDatEnd     smalldatetime
SELECT
        @pCalcExists = 1,--:pCalcExists,
        @pACCOUNT_ID = 133200101,--:ACCOUNT_ID,
        @pDatEnd     = '2004-10-31'--:pDatEnd


  SELECT
  	pcd.SOURCE_ID,
          EDIT_COUNT=(CASE WHEN pcd.AUDIT_METHOD_ID=3 THEN 0
                           WHEN pcd.AUDIT_METHOD_ID=9 THEN 0
                           ELSE pcd.EDIT_COUNT END),
          QUANTITY=pcd.CALC_QUANTITY,
          (CASE WHEN pcd.STATUS=1
                THEN 'Ср.суточн.'
                WHEN (pcd.AUDIT_METHOD_ID=3 OR pcd.AUDIT_METHOD_ID=9 OR pcd.STATUS=2)
                THEN 'Устн.мощн.'
                ELSE '' END) AS STATUS
  FROM
	  ProCalcs    pc,
	  ProCalcDetails  pcd
  WHERE
          pc.DATE_CALC=@pDatEnd   AND
          pcd.CALC_ID=pc.CALC_ID   AND
          pcd.SOURCE_ID=@pACCOUNT_ID
/*
IF @pCalcExists =0
SELECT
	pc.ACCOUNT_ID,
  EDIT_COUNT=(CASE WHEN pa.AUDIT_METHOD_ID=3 THEN 0
                   WHEN pa.AUDIT_METHOD_ID=9 THEN 0
                   ELSE pc.EDIT_COUNT_BEGIN END),
  pc.QUANTITY,
  (CASE WHEN pc.STATUS=1
        THEN 'Ср.суточн.'
        WHEN pc.SIGN_LOCK=0
        THEN 'Блокировка'
        WHEN (pa.AUDIT_METHOD_ID=3 OR pa.AUDIT_METHOD_ID=9 OR pc.STATUS=2)
        THEN 'Устн.мощн.'
        ELSE '' END) AS STATUS
FROM
        ProAccounts   pa,
	      ProCntCounts  pc
WHERE
        pc.ACCOUNT_ID=@pACCOUNT_ID AND
        pa.ACCOUNT_ID=pc.ACCOUNT_ID AND
        pc.DATE_ID=@pDatEnd
ELSE
SELECT
	pcd.SOURCE_ID,
        EDIT_COUNT=(CASE WHEN pcd.AUDIT_METHOD_ID=3 THEN 0
                         WHEN pcd.AUDIT_METHOD_ID=9 THEN 0
                         ELSE pcd.EDIT_COUNT END),
        QUANTITY=pcd.CALC_QUANTITY,
        (CASE WHEN pcd.STATUS=1
              THEN 'Ср.суточн.'
--              WHEN pcd.SIGN_LOCK=0
--              THEN 'Блокировка'
              WHEN (pcd.AUDIT_METHOD_ID=3 OR pcd.AUDIT_METHOD_ID=9 OR pcd.STATUS=2)
              THEN 'Устн.мощн.'
              ELSE '' END) AS STATUS
FROM
	ProCalcs    pc,
	ProCalcDetails  pcd
WHERE
        pc.DATE_CALC=@pDatEnd   AND
        pcd.CALC_ID=pc.CALC_ID   AND
        pcd.SOURCE_ID=@pACCOUNT_ID

*/