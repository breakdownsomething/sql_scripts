SET NOCOUNT ON

CREATE TABLE #MyTable(
		BRIG_ID		int PRIMARY KEY,
		ELECTR		int NULL,
		FAZ1		int NULL,
		FAZ3		int NULL,
		PSCH		int NULL,
		TARIF2		int NULL,
		NOT_IN_TOWN	int NULL,
		TOTAL		int NULL
		)

INSERT INTO #MyTable SELECT 1, 0, 0, 0,0, 0, 0,0
INSERT INTO #MyTable SELECT 2, 0, 0, 0,0, 0, 0,0
INSERT INTO #MyTable SELECT 3, 0, 0, 0,0, 0, 0,0
INSERT INTO #MyTable SELECT 5, 0, 0, 0,0, 0, 0,0
INSERT INTO #MyTable SELECT 6, 0, 0, 0,0, 0, 0,0
INSERT INTO #MyTable SELECT 7, 0, 0, 0,0, 0, 0,0
INSERT INTO #MyTable SELECT 9, 0, 0, 0,0, 0, 0,0

DECLARE
	@iAccountId 	int,
	@iStreetId 	varchar(10),
	@iHouseId 	varchar(10),
	@iBrig  	int,
	@Temp 		int,

	@ELECTR		int,
	@FAZ1		int,
	@FAZ3		int,
	@PSCH		int,
	@TARIF2		int,
	@NOT_IN_TOWN	int,
	@Total 		int,

	@TELECTR	int,
	@TFAZ1		int,
	@TFAZ3		int,
	@TPSCH		int,
	@TTARIF2	int,
	@TNOT_IN_TOWN	int,
	@TTotal		int,

  @counter_type_id  int,
  @specification    varchar(100),

	@CNTName	varchar(50),
	@CNTType	int,
	@CNTTypeId	int,
	@CNTSpec	varchar(100)

SELECT
	@TELECTR	= 0,
	@TFAZ1		= 0,
	@TFAZ3		= 0,
	@TPSCH		= 0,
	@TTARIF2	= 0,
	@TNOT_IN_TOWN	= 0,
	@TTotal		= 0

------------------------------------------------------
if exists (select * from tempdb..sysobjects where id = object_id('tempdb..#TmpAcc'))
begin
  drop table #TmpAcc
end

create table #TmpAcc
(
account_id int not null,
street_id  int null,
house_id   varchar(20) null,
has_cnt    bit null ,
counter_type_id  int null ,
specification    varchar(100) null
)
insert into #TmpAcc
(
account_id,
street_id,
house_id,
has_cnt,
counter_type_id,
specification
)
select distinct
  account_id = A.ACCOUNT_ID,
  street_id  = A.STREET_ID,
  house_id   = A.HOUSE_ID,
  has_cnt    = null,
  counter_type_id  = null ,
  specification   = null
FROM
  AccountGroups AG (NoLock),
  Accounts A (NoLock),
  aspElectric..LastCountPays LCP (NoLock),
  aspElectric..GroupSub GS (NoLock)
WHERE
  (Exists
    (SELECT
       *
      FROM
       SumServices SS (NoLock)
      WHERE
       SS.ACCOUNT_ID = AG.ACCOUNT_ID AND
       SS.SERV_ID    = LCP.SERV_ID AND
       SS.SUPPL_ID   = 600 AND
       SS.SERV_SIGNS&512 = 0 and
       SS.SERV_ID in (13,23) )) AND
  A.ACCOUNT_ID = AG.ACCOUNT_ID AND
  AG.GROUP_ID  = 10001 AND 
  LCP.ACCOUNT_ID = AG.ACCOUNT_ID AND
  GS.SUBGROUP_ID = AG.SUBGROUP_ID

-- наличие/отсутствие счетчика
update #TmpAcc
set has_cnt = LCP.set_sign
from #TmpAcc TMP,
     aspElectric..LastCountPays LCP (nolock)
where
  TMP.account_id = LCP.account_id and
  LCP.serv_id = 13

update #TmpAcc
set has_cnt = LCP.set_sign
from #TmpAcc TMP,
     aspElectric..LastCountPays LCP (nolock)
where
  has_cnt is null and
  TMP.account_id = LCP.account_id and
  LCP.serv_id = 23


update #TmpAcc
set
counter_type_id = CNT.counter_type_id,
specification   = CT.specifications
from aspElectric..Cnt CNT     (nolock),
     aspElectric..CntTypes CT (nolock),
     #TmpAcc               TMP
where TMP.account_id = CNT.account_id and
      CNT.counter_type_id = CT.counter_type_id and
      CNT.counter_number_id = (select max(CNT1.counter_number_id)
                               from aspElectric..Cnt CNT1 (nolock)
                               where CNT1.account_id = TMP.account_id)
     and TMP.has_cnt = 1

------------------------------------------------------

DECLARE curAccount CURSOR FAST_FORWARD FOR
/*
------------------------------------------------------
SELECT
	DISTINCT A.ACCOUNT_ID,
	A.STREET_ID,
	A.HOUSE_ID
FROM
	Accounts		A (NoLock),
	SumServices		SS (NoLock)
WHERE
	A.ACCOUNT_ID = SS.ACCOUNT_ID AND
	SS.SERV_ID IN (13,23)
-------------------------------------------------------
*/
select
  account_id,
  street_id,
  house_id,
  counter_type_id,
  specification
from
  #TmpAcc
where
  has_cnt = convert(bit,1)


OPEN  curAccount

FETCH curAccount INTO @iAccountId, @iStreetId, @iHouseId,
                      @CNTTypeId, @CNTSpec


WHILE @@FETCH_STATUS=0
BEGIN
  SELECT
	@iBrig 		= (SELECT SUBGROUP_ID FROM AccountGroups AG (NoLock) WHERE AG.GROUP_ID = 10001 AND AG.ACCOUNT_ID = @iAccountId),
	@ELECTR		= 0,
	@FAZ1		= 0,
	@FAZ3		= 0,
	@PSCH		= 0,
	@TARIF2		= 0,
	@NOT_IN_TOWN	= 0

  SELECT
	@Temp = (SELECT TOWN_ID FROM Streets S (NoLock) WHERE S.STREET_ID = @iStreetId),
  ---------------------------------------------------------------------------------
/*
	@CNTTypeId = (SELECT TOP 1 COUNTER_TYPE_ID
                FROM aspElectric..CNT C (NoLock)
                WHERE C.ACCOUNT_ID = @iAccountId
                ORDER BY C.COUNTER_NUMBER_ID DESC),
*/
	@CNTName = (SELECT COUNTER_TYPE_NAME
              FROM aspElectric..CntTypes CT (NoLock)
              WHERE CT.COUNTER_TYPE_ID = @CNTTypeId),

	@CNTType = (SELECT COUNTER_TYPE_CLASS_ID
              FROM aspElectric..CntTypes CT (NoLock)
              WHERE CT.COUNTER_TYPE_ID = @CNTTypeId)--,
/*
	@CNTSpec = (SELECT SPECIFICATIONS
              FROM aspElectric..CntTypes CT (NoLock)
              WHERE CT.COUNTER_TYPE_ID = @CNTTypeId)
*/
  ----------------------------------------------------------------------------------

  SELECT
	@ELECTR		= CASE
				WHEN @CNTSpec LIKE '%Электронный%' THEN 1
				ELSE 0
			  END,
	@FAZ1		= CASE
				WHEN @CNTSpec LIKE '%1-нофазный%' THEN 1
				ELSE 0
			  END,
	@FAZ3		= CASE
				WHEN @CNTSpec LIKE '%3-хфазный%' THEN 1
				ELSE 0
			  END,
	@PSCH		= CASE
				WHEN @CNTName LIKE '%ПСЧ%' THEN 1
				ELSE 0
			  END,
	@TARIF2		= CASE
				WHEN @CNTType = 2 THEN 1
				ELSE 0
			  END,
	@NOT_IN_TOWN	= CASE
				WHEN @Temp = 0 THEN 0
				ELSE 1
			  END
  UPDATE
	#MyTable
  SET
	ELECTR		= ELECTR + @ELECTR,
	FAZ1		= FAZ1 + @FAZ1,
	FAZ3		= FAZ3 + @FAZ3,
	PSCH		= PSCH + @PSCH,
	TARIF2		= TARIF2 + @TARIF2,
	NOT_IN_TOWN	= NOT_IN_TOWN + @NOT_IN_TOWN,
	TOTAL 		= TOTAL + 1
  WHERE
	BRIG_ID = @iBrig

  SELECT
	@TELECTR	= @TELECTR + @ELECTR,
	@TFAZ1		= @TFAZ1 + @FAZ1,
	@TFAZ3		= @TFAZ3 + @FAZ3,
	@TPSCH		= @TPSCH + @PSCH,
	@TTARIF2	= @TTARIF2 + @TARIF2,
	@TNOT_IN_TOWN	= @TNOT_IN_TOWN + @NOT_IN_TOWN,
	@TTOTAL 	= @TTOTAL + 1

  FETCH curAccount INTO @iAccountId, @iStreetId, @iHouseId, 
                        @CNTTypeId, @CNTSpec
END

CLOSE  curAccount
DEALLOCATE curAccount

INSERT INTO
	#MyTable
SELECT
	1000		,
	@TELECTR	,
	@TFAZ1		,
	@TFAZ3		,
	@TPSCH		,
	@TTARIF2	,
	@TNOT_IN_TOWN	,
	@TTOTAL

SELECT
	CASE
		WHEN BRIG_ID = 1000 THEN 'ГЭРС'
		ELSE 'Бригада №' + CONVERT(varchar, BRIG_ID)
	END as NAME,
	ELECTR,
	FAZ1,
	FAZ3,
	PSCH,
	TARIF2,
	NOT_IN_TOWN	,
	TOTAL
FROM
	#MyTable
ORDER BY
        BRIG_ID

DROP TABLE #MyTable
DROP TABLE #TmpAcc





