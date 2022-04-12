
--1) перва€ временна€ таблица sFirmTableName - @vcTableName ##TmpTp????
if exists (select * from tempdb..sysobjects where id = object_id('tempdb..##TmpTp1_255'))
  begin
    drop table ##TmpTp1_255
  end 

EXEC
("
  CREATE TABLE ##TmpTp1_255
     (SUBSTATION_TYPE_ID tinyint,
	    SUBSTATION_ID      smallint,
      SECTION_ID         tinyint )
")

DECLARE
  @PP     tinyint,
	@cDate	smalldatetime
SELECT @PP = 1--:pZap

IF @PP = 1
  SELECT @cDate=GETDATE()
ELSE
  SELECT @cDate = convert(smalldatetime, '2004-07-12'/*:pDate*/,21)

EXEC dbo.pInsertNode2 '##TmpTp1_255'/*:pTableName*/
                     ,659--6112/*:pNode*/
                     ,0/*:pMode*/
                     ,@cDate

--select * from ##TmpTp1_255

--2) втора€ временна€ таблица pTableName2 = sPermTableName2 ##Perm?_??

if exists (select * from tempdb..sysobjects where id = object_id('tempdb..##Perm1_255'))
  begin
    drop table ##Perm1_255
  end 

EXEC("
CREATE TABLE ##Perm1_255
(
	GROUP_ID             smallint,
	GROUP_NAME	     varchar(40)
)

IF EXISTS (SELECT *
           FROM aspElectricPro..ProGroupUsers  PGU(NOLOCK)
           WHERE PGU.GROUP_ID = 10010
             AND USER_ID      = 612)

  INSERT INTO ##Perm1_255
  SELECT
    PG.GROUP_ID,
	  PG.GROUP_NAME
  FROM
    aspElectricPro..ProGroups	PG(NOLOCK)
  WHERE
    PG.GROUP_ID > 10010

ELSE

  INSERT INTO ##Perm1_255
  SELECT
	  PG.GROUP_ID,
	  PG.GROUP_NAME
  FROM
	  aspElectricPro..ProGroupUsers  PGU(NOLOCK),
	  aspElectricPro..ProGroups	PG(NOLOCK)
  WHERE
	  PGU.GROUP_ID = PG.GROUP_ID AND
	  USER_ID = 612 ")

--select * from ##Perm1_255






















-- ќсновной скрипт----------------------------------------------------------
----------------------------------------------------------------------------

IF EXISTS
 (SELECT *
   FROM TempDB..sysobjects
   WHERE id = object_id('TempDB..#TmpPro')
 )
  EXEC('DROP TABLE  #TmpPro')

DECLARE
  @vcTableName        varchar(35),
  @vcTableName2       varchar(35),
  @sGroupId           varchar(150),
  @dDatEnd            smalldatetime,
  @sDatEnd            varchar(10),

  @bShowPul           bit,
  @sAddCondition      varchar(50) -- дополнительное условие

SELECT
  @vcTableName  = '##TmpTp1_255',
  @vcTableName2 = '##Perm1_255' ,
  @sGroupId     = '0' ,
  @dDatEnd      = CONVERT(smalldatetime,'2004-05-31'),
  @sDatEnd      = CONVERT(VARCHAR(20),@dDatEnd,120),
  @bShowPul     = convert(bit,1)     -- ѕоказывать с пазделением Pro <-> Pul

IF  @sGroupId = '0'
  SELECT  @sGroupId = 'pct.GROUP_ID IN (SELECT GROUP_ID FROM ' +@vcTableName2 + ') AND'
ELSE
  SELECT  @sGroupId =  'pct.GROUP_ID in (' + @sGroupId + ') AND'

if @bShowPul = convert(bit,1) 
  begin
    select @sAddCondition = 'and pa.ABONENT_ID <> 20002'
  end
else
  begin
    select @sAddCondition = ''
  end



EXEC ("
  CREATE TABLE #TmpPro
         (NODEID          int,
          ABONENT_NAME    varchar(80)  NULL,
          CONTRACT_NUMBER varchar(10)  NULL,
          SOURCE_ID       int NULL,
          CALC_QUANTITY   int  NULL,
          GROUP_ID        int NULL,
          COUNTER_NUMBER  VarChar(20) Null,
          ADD_QNT         Int Null,
          SPM_QNT         Int Null,
          PUL_SIGN        bit null --ѕризнак принадлежности записи
                                   -- к базе aspElectricPul             
         )

  IF object_ID ('tempdb.." + @vcTableName + "S') IS NOT NULL
    DROP TABLE " + @vcTableName + "S

  CREATE TABLE " + @vcTableName + "S
   (tCount	    int NULL,
    tRashod	    int NULL,
    tAddQnt     Int Null,
    tSPMQnt     Int Null)

  INSERT #TmpPro
  SELECT
    es.NODEID,
    pa.ABONENT_NAME,
    pct.CONTRACT_NUMBER,
    pcd.SOURCE_ID,
    CALC_QUANTITY    = IsNull(pcd.CALC_QUANTITY, 0) -
                       IsNull(pcd.ADD_QUANTITY,0) -
                       IsNull(pcd.ADD_HCP,0),
    pct.GROUP_ID,
    COUNTER_NUMBER   = C.FACTORY_NUMBER,
    ADD_QNT          = IsNull(pcd.ADD_QUANTITY,0),
    SPM_QNT          = IsNull(pcd.ADD_HCP,0),
    convert(bit,0) -- PUL_SIGN
   FROM
    aspElectricPro..ProCalcs       pc  (NOLOCK),
    aspElectricPro..ProCalcDetails pcd (NOLOCK),
    " + @vcTableName + "           es  (NOLOCK),
    aspElectricPro..ProAbonents    pa  (NOLOCK),
    aspElectricPro..ProContracts   pct (NOLOCK),
    aspElectricPro..ProCnt         C (NoLock)
   WHERE
    pc.DATE_CALC        = '" + @sDatEnd + "' AND
    pcd.CALC_ID         = pc.CALC_ID         AND
    pcd.NODEID          = es.NODEID          AND
    pcd.MEASURE_ID      = 4                  AND
    pcd.CALC_SIGN_FACT  = 1                  AND
    pcd.DECODE_ID      <> 0                  AND
    " + @sGroupId + "  -- 'pct.GROUP_ID IN (SELECT GROUP_ID FROM ' +@vcTableName2 + ') AND'
    pct.CONTRACT_ID     = pc.CONTRACT_ID     AND
    pa.ABONENT_ID       = pct.ABONENT_ID     AND
    C.ACCOUNT_ID        =* pcd.SOURCE_ID     AND
    C.COUNTER_NUMBER_ID = (SELECT MAX(CC.COUNTER_NUMBER_ID)
                           FROM   aspElectricPro..ProCnt CC (NoLock)
                           WHERE  CC.ACCOUNT_ID = C.ACCOUNT_ID)
---------------------------------------------------------------------------
--  and pa.ABONENT_ID <> 20002 -- договор √Ё–— и јлматы Ёнергоѕул исключаем
   "+@sAddCondition+"
---------------------------------------------------------------------------


-- “еперь вставл€ем записи из aspElectricPul
if  '"+@bShowPul+"' = convert(bit,1)
begin

  INSERT #TmpPro
  SELECT
    es.NODEID,
    pa.ABONENT_NAME,
    pct.CONTRACT_NUMBER,
    pcd.SOURCE_ID,
    CALC_QUANTITY    = IsNull(pcd.CALC_QUANTITY, 0) -
                       IsNull(pcd.ADD_QUANTITY,0) -
                       IsNull(pcd.ADD_HCP,0),
    pct.GROUP_ID,
    COUNTER_NUMBER   = C.FACTORY_NUMBER,
    ADD_QNT          = IsNull(pcd.ADD_QUANTITY,0),
    SPM_QNT          = IsNull(pcd.ADD_HCP,0),
    convert(bit,1)
   FROM
    aspElectricPul..ProCalcs       pc  (NOLOCK),
    aspElectricPul..ProCalcDetails pcd (NOLOCK),
    " + @vcTableName + "           es  (NOLOCK),
    aspElectricPul..ProAbonents    pa  (NOLOCK),
    aspElectricPul..ProContracts   pct (NOLOCK),
    aspElectricPul..ProCnt         C (NoLock)
   WHERE
    pc.DATE_CALC        = '" + @sDatEnd + "' AND
    pcd.CALC_ID         = pc.CALC_ID         AND
    pcd.NODEID          = es.NODEID          AND
    pcd.MEASURE_ID      = 4                  AND
    pcd.CALC_SIGN_FACT  = 1                  AND
    pcd.DECODE_ID      <> 0                  AND
    pct.GROUP_ID        = 10011              and  --городской сектор Ёнергоѕула
    pct.CONTRACT_ID     = pc.CONTRACT_ID     AND
    pa.ABONENT_ID       = pct.ABONENT_ID     AND
    C.ACCOUNT_ID        =* pcd.SOURCE_ID     AND
    C.COUNTER_NUMBER_ID = (SELECT MAX(CC.COUNTER_NUMBER_ID)
                           FROM   aspElectricPro..ProCnt CC (NoLock)
                           WHERE  CC.ACCOUNT_ID = C.ACCOUNT_ID)

end

--- ----------------------------------------------
  DECLARE
    @vCount  int,
    @vSum    int,
    @vAddSum Int,
    @vSPMSum Int

  SELECT  @vCount = COUNT(*)
  FROM    #TmpPro
  WHERE   ABONENT_NAME IS NOT NULL

  SELECT
    @vSum = ISNULL(SUM(CALC_QUANTITY),0),
    @vAddSum = ISNULL(SUM(ADD_QNT),0),
    @vSPMSum = ISNULL(SUM(SPM_QNT),0)
  FROM
    #TmpPro

  INSERT INTO " + @vcTableName + "S
   SELECT
    @vCount,@vSum,@vAddSum,@vSPMSum
------------------------------------------------------


  SELECT
    SNAME = convert(varchar(12),TL.SHORT_NAME + ' ' +
    SUBSTATION_ID + '-' + convert(varchar(10),SECTION_ID)),
    ABONENT_NAME = ISNULL(ABONENT_NAME,''),
    CONTRACT_NUMBER,
    SOURCE_ID,
    CALC_QUANTITY,
    GROUP_ID = case when PUL_SIGN=convert(bit,1) then convert(char(1),(GROUP_ID - 10010))+'-Ёнергоѕул'
                    else convert(char(1),(GROUP_ID - 10010)) end ,
    COMMENT = EN.COMMENT,
    COUNTER_NUMBER,
    ADD_QNT,
    SPM_QNT,
    PUL_SIGN
   FROM
    #TmpPro  T (NOLOCK),
    aspElectric..ElectNodes		EN (NOLOCK),
    aspElectric..ElectNodeTypeList	TL (NOLOCK)
   WHERE
    EN.NODEID = T.NODEID	AND
    TL.SUBSTATION_TYPE_ID = EN.SUBSTATION_TYPE_ID
   UNION SELECT
    SNAME = ' ',
    ABONENT_NAME = ' ',
    CONTRACT_NUMBER = '»того' ,
    SOURCE_ID = Null,
    CALC_QUANTITY = @vSum,
    GROUP_ID = Null,
    COMMENT = Null,
    COUNTER_NUMBER = Null,
    ADD_QNT = @vAddSum,
    SPM_QNT = @vSPMSum,
    PUL_SIGN = null
   ORDER BY
    CONTRACT_NUMBER,
    SOURCE_ID 
")

--DROP TABLE #TmpPro


