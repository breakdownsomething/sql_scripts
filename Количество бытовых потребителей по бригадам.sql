CREATE TABLE #MyTable1(
		BRIG_ID    		int PRIMARY KEY,
		BIG_HOUSE   	int NULL,
		SMALL_HOUSE	  int NULL,
		NOT_IN_TOWN 	int NULL,
		TOTAL	      	int NULL
		)

/*
SELECT
	SUBGROUP_ID=IsNUll(AG.SUBGROUP_ID,0),
	BIG_HOUSE=CASE WHEN S.TOWN_ID>0 THEN 2
			ELSE H.BIG_HOUSE END,
	COUNT_ACC=COUNT(*)
INTO #Tmp3
FROM
	Accounts	A(NOLOCK),
	AccountGroups AG (NOLOCK),
	Streets S (NOLOCK),
	Houses H(NOLOCK),
	SumServices SST(NOLOCK)
WHERE
	A.ACCOUNT_ID = SST.ACCOUNT_ID AND
	S.STREET_ID = A.STREET_ID AND
	H.STREET_ID = A.STREET_ID AND
  H.HOUSE_ID = A.HOUSE_ID AND
	SST.SERV_ID=13 AND
  SST.SUPPL_ID=600	AND
	A.ACCOUNT_ID = AG.ACCOUNT_ID AND
	AG.GROUP_ID = 10001
GROUP BY
	S.TOWN_ID,
	AG.SUBGROUP_ID,
	BIG_HOUSE
ORDER BY
	AG.SUBGROUP_ID,
	BIG_HOUSE
*/

SELECT
  SUBGROUP_ID = isnull(AG.SUBGROUP_ID,0),
  BIG_HOUSE    =CASE WHEN S.TOWN_ID > 0 THEN 2 
			                ELSE isnull(H.BIG_HOUSE,0) END ,
  COUNT_ACC = count(distinct A.ACCOUNT_ID)
INTO #Tmp3
FROM
  AccountGroups AG (NoLock),
  Accounts A (NoLock),
  aspElectric..LastCountPays LCP (NoLock),
  aspElectric..GroupSub GS (NoLock),
  Streets     S (nolock),
  Houses      H (nolock)
WHERE
  (Exists (SELECT * FROM SumServices SS (NoLock)
           WHERE SS.ACCOUNT_ID = AG.ACCOUNT_ID AND
                 SS.SERV_ID    = LCP.SERV_ID AND
                 SS.SUPPL_ID   = 600 AND
                 SS.SERV_SIGNS&512 = 0 and
                 SS.SERV_ID in (13,23) ))

   AND  A.ACCOUNT_ID = AG.ACCOUNT_ID
   AND  AG.GROUP_ID  = 10001
   AND  LCP.ACCOUNT_ID = AG.ACCOUNT_ID
   AND  GS.SUBGROUP_ID = AG.SUBGROUP_ID

   and	S.STREET_ID = A.STREET_ID 
   and	H.STREET_ID =* A.STREET_ID
   AND  H.HOUSE_ID  =* A.HOUSE_ID 

GROUP BY
	S.TOWN_ID,
	AG.SUBGROUP_ID,
	BIG_HOUSE
ORDER BY
	AG.SUBGROUP_ID,
	BIG_HOUSE


DECLARE
	@i int
SELECT
	@i = 0

WHILE @i <= (SELECT MAX(SUBGROUP_ID) FROM #Tmp3)
BEGIN
  INSERT INTO #MyTable1 SELECT @i,
     BIG_HOUSE = ISNULL((SELECT SUM(COUNT_ACC)
                          FROM #Tmp3
                          WHERE SUBGROUP_ID = @i AND
                                BIG_HOUSE = 1),0),
      SMALL_HOUSE = ISNULL((SELECT SUM(COUNT_ACC)
                            FROM #Tmp3
                            WHERE SUBGROUP_ID = @i AND
                                  BIG_HOUSE = 0),0),
  		NOT_IN_TOWN	= ISNULL((SELECT SUM(COUNT_ACC)
                            FROM #Tmp3
                            WHERE SUBGROUP_ID = @i AND
                                  BIG_HOUSE = 2),0),
	  	TOTAL	= ISNULL((SELECT SUM(COUNT_ACC)
                      FROM #Tmp3
                      WHERE SUBGROUP_ID = @i),0)
  SELECT @i = @i +1
END
--????-----------------------------------------------
INSERT INTO #MyTable1 SELECT 1000,
     BIG_HOUSE = ISNULL((SELECT SUM(COUNT_ACC)
                          FROM #Tmp3
                          WHERE BIG_HOUSE = 1),0),
      SMALL_HOUSE = ISNULL((SELECT SUM(COUNT_ACC)
                            FROM #Tmp3
                            WHERE BIG_HOUSE = 0),0),
  		NOT_IN_TOWN	= ISNULL((SELECT SUM(COUNT_ACC)
                            FROM #Tmp3
                            WHERE BIG_HOUSE = 2),0),
	  	TOTAL	= ISNULL((SELECT SUM(COUNT_ACC)
                      FROM #Tmp3),0)
-------------------------------------------------------
SELECT
	CASE WHEN BRIG_ID = 1000 THEN 'ГЭРС'
	    	ELSE 'Бригада №' + CONVERT(varchar, BRIG_ID)END as NAME,
	BIG_HOUSE,
	SMALL_HOUSE,
	NOT_IN_TOWN,
	TOTAL
FROM #MyTable1

drop table #Tmp3
drop table #MyTable1
