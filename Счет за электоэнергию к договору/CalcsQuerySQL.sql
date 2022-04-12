-- входные параметры
DECLARE
  @iContractId  Integer,
  @dtCalcBegin DateTime,
  @dtCalcEnd DateTime,
  @dtMainCalcEnd DateTime,
  @bAllContracts bit
SELECT
  @iContractId   = 252115,--38611 ,       --:piContractId,
  @dtCalcBegin   = '2004-05-01', --:pdtCalcBegin,
  @dtCalcEnd     = '2004-05-31', --:pdtCalcEnd,
  @dtMainCalcEnd = '2004-05-31', --:pdtMainCalcEnd
  @bAllContracts = 0             --:pbAllContracts  


-- Создание временной таблицы #ContractList.
-- При выборе сводного отчета в не попадают все contract_id
-- входящие в одну группу с выбранным,
-- в противном случае только сам выбранный.
-- Сея временная таблица не убивается после выполнения скрипта,
-- а остается в TempDB для использования другими кверями.
if Exists (select * from TempDB..SysObjects
           where id = OBJECT_ID('TempDB..#ContractList'))
begin
  DROP TABLE #ContractList
end

create table #ContractList (contract_id int not null,
                            calc_id int null)

if (@bAllContracts = 1) --формируем сводный отчет 
  and exists (select nsi_id from ProNsi --существует группа, в которую входит договор
              where nsi_row = (select contract_number
                                  from ProContracts
                                  where contract_id = @iContractId)
                   and nsi_id < 10 )
  begin -- определение contract_id - ов входящих в одну группу с выбранным
    insert into #ContractList
    select PC.contract_id
          ,null
    from ProNsi PN (nolock),
         ProContracts PC (nolock)
    where PN.nsi_row = PC.contract_number
      and PN.nsi_id = (select nsi_id
                       from ProNsi
                       where nsi_row = (select contract_number
                                        from ProContracts
                                        where contract_id = @iContractId)
                         and nsi_id  < 10)-- формальное соглашение о том, что
                                        -- фиксированным группам будут присваиваться
                                        -- id-шники из первой десятки
  end
else
  begin -- формируем отдельный отчет
   insert into #ContractList(contract_id,calc_id) values (@iContractId,null) 
  end
-- Определяем Calc_id соответствующие данному contract_id в выбранном месяце
update #ContractList
set calc_id = (select PC.calc_id
               from ProCalcs PC (nolock)
               where PC.contract_id = CL.contract_id
                 and PC.date_calc   = @dtCalcEnd)
from #ContractList CL

--select * from #ContractList

--------------------- Определение сумм из ProCalcs  -----------------------------------
declare 
  @dSALDO      decimal(12,2),
  @dSALDO_PENI decimal(12,2),
  @dSUM_FACT   decimal(12,2),
  @dSUM_NDS    decimal(12,2),
  @dSUM_EXC    decimal(12,2),
  @dSUM_ALL    decimal(12,2),
  @dADV_OLD    decimal(12,2),
  @dADV_NEW    decimal(12,2),
  @dSUM_PENI   decimal(12,2),
  @dQNT_ALL    int

select
  @dSALDO      = isnull(sum(SALDO),0),
  @dSALDO_PENI = isnull(sum(SALDO_PENI),0),
  @dSUM_FACT   = isnull(sum(SUM_FACT),0),
  @dSUM_NDS    = isnull(sum(SUM_NDS),0),
  @dSUM_EXC    = isnull(sum(SUM_EXC),0),
  @dSUM_ALL    = isnull(sum(SUM_ALL),0),
  @dADV_OLD    = isnull(sum(ADV_OLD),0),
  @dADV_NEW    = isnull(sum(ADV_NEW),0),
  @dSUM_PENI   = isnull(sum(SUM_PENI),0),
  @dQNT_ALL    = isnull(sum(QNT_ALL),0)
from ProCalcs  
where 
      contract_id in (select contract_id from #ContractList)    
 and  date_calc   =  @dtCalcEnd
------------------------------------------------------------------
--select * from #tmpProAbonents
--update #tmpProGroups set address = 'ул. Папанина 94', street_id = null
--drop table #tmpProAbonents
/*

if Exists (select * from TempDB..SysObjects
           where id = OBJECT_ID('TempDB..#tmpProGroups'))
begin
  drop table #tmpProGroups
end

select distinct 
bank_id,bank_name
from banksinfo where bank_id = 724

CREATE TABLE #tmpProGroups (
	[GROUP_ID] [smallint] NOT NULL ,
	[GROUP_NAME] [varchar] (40) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[BOSS_POST] [varchar] (50) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[BOSS_NAME] [varchar] (50) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[BOOKKEEPER_POST] [varchar] (50) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[BOOKKEEPER_NAME] [varchar] (50) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[ADDRESS] [varchar] (50) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[STREET_ID] [smallint] NULL ,
	[HOUSE_ID] [varchar] (20) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[POST_INDEX] [varchar] (6) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[PHONE] [varchar] (20) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[FAX] [varchar] (20) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[EMAIL] [varchar] (30) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[RNN] [varchar] (12) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[BANK_ID] [int] NULL ,
	[BRANCH_ID] [int] NULL ,
	[CALC_ACCOUNT] [varchar] (18) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[ADD_COST_TAX] [decimal](9, 2) NULL ,
	[DATE_CALC_BEGIN] [smalldatetime] NOT NULL ,
	[DATE_CALC_END] [smalldatetime] NOT NULL ,
	[RESIDENT_SECTOR] [tinyint] NULL CONSTRAINT [DF_ProGroups_RESIDENT_SECTOR] DEFAULT (17),
	[YEAR_GRAPH] [varchar] (40) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[SIGN_NUMERATION_SF] [bit] NULL ,
	[CERTIFICATE_DATE] [smalldatetime] NULL ,
	[CERTIFICATE_NUMBER] [varchar] (20) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[CERTIFICATE_SERIES] [varchar] (20) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[CERTIFICATE_AGENCY] [varchar] (80) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[CERTIFICATE_AGENCY_RNN] [varchar] (12) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[COMMENTS] [varchar] (250) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[PAYMENT_CODE] [smallint] NULL )

if @dtCalcEnd = @dtMainCalcEnd -- отчет за текущий месяц
begin
  insert into #tmpProGroups(
         [GROUP_ID], [GROUP_NAME], [BOSS_POST], [BOSS_NAME],
 [BOOKKEEPER_POST], [BOOKKEEPER_NAME], [ADDRESS], [STREET_ID],
 [HOUSE_ID], [POST_INDEX], [PHONE], [FAX], [EMAIL], [RNN],
 [BANK_ID], [BRANCH_ID], [CALC_ACCOUNT], [ADD_COST_TAX],
 [DATE_CALC_BEGIN], [DATE_CALC_END], [RESIDENT_SECTOR],
 [YEAR_GRAPH], [SIGN_NUMERATION_SF], [CERTIFICATE_DATE],
 [CERTIFICATE_NUMBER], [CERTIFICATE_SERIES], [CERTIFICATE_AGENCY],
 [CERTIFICATE_AGENCY_RNN], [COMMENTS], [PAYMENT_CODE]
         )
  select 
   [GROUP_ID], [GROUP_NAME], [BOSS_POST], [BOSS_NAME],
   [BOOKKEEPER_POST], [BOOKKEEPER_NAME], [ADDRESS], [STREET_ID],
   [HOUSE_ID], [POST_INDEX], [PHONE], [FAX], [EMAIL], [RNN],
   [BANK_ID], [BRANCH_ID], [CALC_ACCOUNT], [ADD_COST_TAX],
   [DATE_CALC_BEGIN], [DATE_CALC_END], [RESIDENT_SECTOR],
   [YEAR_GRAPH], [SIGN_NUMERATION_SF], [CERTIFICATE_DATE],
   [CERTIFICATE_NUMBER], [CERTIFICATE_SERIES], [CERTIFICATE_AGENCY],
   [CERTIFICATE_AGENCY_RNN], [COMMENTS], [PAYMENT_CODE]
  from ProGroups
  where group_id = case when @bAllContracts = 1 then 10010
                        else (select group_id
                              from ProContracts
                              where contract_id = @iContractId) end
end 
else
begin
  insert into #tmpProGroups(
         [GROUP_ID], [GROUP_NAME], [BOSS_POST], [BOSS_NAME],
 [BOOKKEEPER_POST], [BOOKKEEPER_NAME], [ADDRESS], [STREET_ID],
 [HOUSE_ID], [POST_INDEX], [PHONE], [FAX], [EMAIL], [RNN],
 [BANK_ID], [BRANCH_ID], [CALC_ACCOUNT], [ADD_COST_TAX],
 [DATE_CALC_BEGIN], [DATE_CALC_END], [RESIDENT_SECTOR],
 [YEAR_GRAPH], [SIGN_NUMERATION_SF], [CERTIFICATE_DATE],
 [CERTIFICATE_NUMBER], [CERTIFICATE_SERIES], [CERTIFICATE_AGENCY],
 [CERTIFICATE_AGENCY_RNN], [COMMENTS], [PAYMENT_CODE])
  select
 [GROUP_ID], [GROUP_NAME], [BOSS_POST], [BOSS_NAME],
 [BOOKKEEPER_POST], [BOOKKEEPER_NAME], [ADDRESS], [STREET_ID],
 [HOUSE_ID], [POST_INDEX], [PHONE], [FAX], [EMAIL], [RNN],
 [BANK_ID], [BRANCH_ID], [CALC_ACCOUNT], [ADD_COST_TAX],
 [DATE_CALC_BEGIN], [DATE_CALC_END], [RESIDENT_SECTOR],
 [YEAR_GRAPH], [SIGN_NUMERATION_SF], [CERTIFICATE_DATE],
 [CERTIFICATE_NUMBER], [CERTIFICATE_SERIES], [CERTIFICATE_AGENCY],
 [CERTIFICATE_AGENCY_RNN], [COMMENTS], [PAYMENT_CODE]
 from ProGroupsArc
  where date_begin    = @dtCalcEnd     
      and group_id = case when @bAllContracts = 1 then 10010
                          else (select group_id
                                from ProContracts
                                where contract_id = @iContractId) end
end
--select * from  #tmpProGroups
*/
-------------------------------------------------------------------
if Exists (select * from TempDB..SysObjects
           where id = OBJECT_ID('TempDB..#ProContracts'))
begin
  drop table #ProContracts
end

SELECT * INTO #ProContracts
FROM ProContracts
WHERE CONTRACT_ID = @iContractId

if Exists (select * from TempDB..SysObjects
           where id = OBJECT_ID('TempDB..#ProContractsArc'))
begin
  drop table #ProContractsArc
end

SELECT * INTO #ProContractsArc
FROM ProContractsArc
WHERE CONTRACT_ID = @iContractId AND
      DATE_BEGIN  = @dtCalcEnd

                                                          
------------ При выдаче сводного отчета поставщиком всегда является-----------
------------- АО АЛМАТЫ ПАУЭР КОНСАЛИДЕЙТИД ----------------------------------
if @bAllContracts = 1
  begin
   UPDATE #ProContracts SET GROUP_ID=10010
   UPDATE #ProContractsArc SET GROUP_ID=10010
  end
------------------- тайна, покрытая мраком    ----------------------------------
IF @iContractId=-212 AND EXISTS (SELECT * FROM ProGroups WHERE GROUP_ID=10000)
UPDATE #ProContracts SET GROUP_ID=10000
IF @iContractId=-212 AND EXISTS (SELECT * FROM ProGroupsArc WHERE DATE_BEGIN=@dtCalcEnd AND GROUP_ID=10000)
UPDATE #ProContractsArc SET GROUP_ID=10000
---------------------------------------------------------------------------------

IF @dtCalcEnd = @dtMainCalcEnd -- отчет формируется за последний (незакрытый) месяц

  SELECT
    CALC_ID         = C.CALC_ID,
    BILL_NUMBER     = CONVERT(VarChar(10),rtrim(ltrim(C.BILL_NUMBER))),
    CONTRACT_ID     = C.CONTRACT_ID,
    CALC_NUMBER     = C.CALC_NUMBER,
    DATE_CALC       = C.DATE_CALC,
    SIGN_LOCK       = Convert(SmallInt,C.SIGN_LOCK),
    DATE_CALC_BEGIN = @dtCalcBegin,
    DATE_CALC_END   = @dtCalcEnd,
    ABONENT_ID      = Cn.ABONENT_ID,
    CONTRACT_NUMBER = Cn.CONTRACT_NUMBER,
    DATE_CONTRACT   = Cn.DATE_CONTRACT,
    ADVANCE_ID      = Cn.ADVANCE_ID,
    ADVANCE         = Cn.ADVANCE,

    SALDO           = @dSALDO,
    SALDO_PENI      = @dSALDO_PENI,
    SUM_FACT        = @dSUM_FACT,
    SUM_NDS         = @dSUM_NDS,
    SUM_EXC         = @dSUM_EXC,
    SUM_ALL         = @dSUM_ALL,
    ADV_OLD         = @dADV_OLD,
    ADV_NEW         = @dADV_NEW,
    SUM_PENI        = @dSUM_PENI,
    QNT_ALL         = @dQNT_ALL,

    NEXT_DATE_BEG   = CONVERT(SmallDateTime,DATEADD(mm,+1,@dtCalcBegin)),
    NEXT_DATE_END   = CONVERT(SmallDateTime,DATEADD(dd,-1,DATEADD(mm,+2,@dtCalcBegin))),
    DATE_CONTRACT_CLOSE = Cn.DATE_CONTRACT_CLOSE,
    ADD_COST_TAX    = Cn.ADD_COST_TAX,
    GROUP_ID        = Cn.GROUP_ID,
    GROUP_NAME      = G.GROUP_NAME,
    G_BOSS_POST     = G.BOSS_POST,
    G_BOSS_NAME     = G.BOSS_NAME,
    G_BOOKKEEPER_POST = G.BOOKKEEPER_POST,
    G_BOOKKEEPER_NAME = G.BOOKKEEPER_NAME,
    G_ADDRESS       = CASE WHEN ISnull(G.STREET_ID,0) <> 0
                           THEN (SELECT Convert(VarChar(50),
                                        IsNull(RTrim(T.TOWN_NAME),'')+','+
                                        IsNull(RTrim(ST.STREET_TYPE_SHORT_NAME),'')+
                                        IsNull(RTrim(S.STREET_NAME),'')+','+
                                        IsNull(RTrim(G.HOUSE_ID),''))
                                 FROM   Streets     S,
                                        StreetTypes ST,
                                        Towns       T
                                 WHERE S.STREET_ID = G.STREET_ID AND
                                       ST.STREET_TYPE_ID=*S.STREET_TYPE_ID AND
                                       T.TOWN_ID=*S.TOWN_ID)
                           ELSE G.ADDRESS END,
    G_STREET_ID     = G.STREET_ID,
    G_HOUSE_ID      = G.HOUSE_ID,
    G_POST_INDEX    = G.POST_INDEX,
    G_PHONE         = G.PHONE,
    G_RNN           = G.RNN,
    G_BANK_ID       = RIGHT(STR(G.BANK_ID +1000000000,10),3),
    G_BRANCH_ID     = G.BRANCH_ID,
    G_CALC_ACCOUNT  = G.CALC_ACCOUNT,
    G_BANK_NAME     = (SELECT DISTINCT BANK_NAME
                       FROM  BanksInfo
                       WHERE BANK_ID = G.BANK_ID) ,
    G_MFO           = (SELECT DISTINCT MFO
                       FROM BanksInfo
                       WHERE BANK_ID = G.BANK_ID),
    ABONENT_NAME    = A.ABONENT_NAME,
    A_ADDRESS       = CASE WHEN ISnull(A.STREET_ID,0) <> 0
                           THEN (SELECT Convert(VarChar(50),
                                        IsNull(RTrim(T.TOWN_NAME),'')+','+
                                        IsNull(RTrim(ST.STREET_TYPE_SHORT_NAME),'')+
                                        IsNull(RTrim(S.STREET_NAME),'')+','+
                                        IsNull(RTrim(A.HOUSE_ID),'')+','+
                                        IsNull(RTrim(A.FLAT_ID),''))
                                 FROM  Streets      S,
                                       StreetTypes  ST,
                                       Towns        T
                                 WHERE S.STREET_ID=A.STREET_ID             AND
                                       ST.STREET_TYPE_ID=*S.STREET_TYPE_ID AND
                                       T.TOWN_ID=*S.TOWN_ID)
                           ELSE A.ADDRESS  END,
    A_STREET_ID     = A.STREET_ID,
    A_HOUSE_ID      = A.HOUSE_ID,
    A_POST_INDEX    = A.POST_INDEX,
    A_PHONE         = A.PHONE,
    A_RNN           = A.RNN,
    A_BANK_ID       = RIGHT(STR(A.BANK_ID +1000000000,10),3),
    A_BRANCH_ID     = A.BRANCH_ID,
    A_CALC_ACCOUNT  = A.CALC_ACCOUNT,
    A_MFO           = (SELECT DISTINCT LEFT(LTRIM(STR(MFO)),6)
                       FROM BanksInfo
                       WHERE BANK_ID = A.BANK_ID),
    A_BANK_NAME     = (SELECT DISTINCT BANK_NAME
                       FROM BanksInfo
                       WHERE BANK_ID = A.BANK_ID),
    C_ADD_COST_TAX  = Convert(Decimal(9,2),C.ADD_COST_TAX),
    C_EXC_TAX       = Convert(Decimal(9,2),C.EXCISE_TAX),
   G_RESIDENT_SECTOR        = G.RESIDENT_SECTOR,
   A_RESIDENT_SECTOR        = A.RESIDENT_SECTOR,
   A_CERTIFICATE_DATE       = A.CERTIFICATE_DATE,
   A_CERTIFICATE_NUMBER     = A.CERTIFICATE_NUMBER,
   A_CERTIFICATE_SERIES     = A.CERTIFICATE_SERIES,
   A_CERTIFICATE_AGENCY     = A.CERTIFICATE_AGENCY,
   A_CERTIFICATE_AGENCY_RNN = A.CERTIFICATE_AGENCY_RNN,
   A_PAYMENT_CODE           = A.PAYMENT_CODE,
   MAIN_PAYMENT_CODE        = G.PAYMENT_CODE,
   MAIN_GROUP_NAME          = G.GROUP_NAME,
   MAIN_CERTIFICATE_DATE    = G.CERTIFICATE_DATE,
   MAIN_CERTIFICATE_NUMBER  = G.CERTIFICATE_NUMBER,
   MAIN_CERTIFICATE_SERIES  = G.CERTIFICATE_SERIES,
   MAIN_CERTIFICATE_AGENCY  = G.CERTIFICATE_AGENCY,
   MAIN_CERTIFICATE_AGENCY_RNN = G.CERTIFICATE_AGENCY_RNN
   FROM
    ProCalcs      C  (NoLock),
    #ProContracts Cn (NoLock),
    ProAbonents   A  (NoLock),
    #tmpProGroups G  (nolock)
--    ProGroups     G  (NoLock)
   WHERE
    Cn.CONTRACT_ID = @iContractId   AND
    A.ABONENT_ID   = Cn.ABONENT_ID  AND
    G.GROUP_ID     = Cn.GROUP_ID    AND
    C.CONTRACT_ID  = Cn.CONTRACT_ID AND
    C.DATE_CALC    = @dtCalcEnd
   ORDER BY
    Cn.GROUP_ID,
    C.CONTRACT_ID

ELSE -- счет выдается за старые периоды - данные берутся из архивных таблиц

  SELECT
    CALC_ID          = C.CALC_ID,
    BILL_NUMBER      = CONVERT(VarChar(10),rtrim(ltrim(C.BILL_NUMBER))),
    CONTRACT_ID      = C.CONTRACT_ID,
    CALC_NUMBER      = C.CALC_NUMBER,
    DATE_CALC        = C.DATE_CALC,
    SIGN_LOCK        = Convert(SmallInt,C.SIGN_LOCK),
    DATE_CALC_BEGIN  = @dtCalcBegin,
    DATE_CALC_END    = @dtCalcEnd,
    ABONENT_ID       = Cn.ABONENT_ID,
    CONTRACT_NUMBER  = Cn.CONTRACT_NUMBER,
    DATE_CONTRACT    = Cn.DATE_CONTRACT,
    ADVANCE_ID       = Cn.ADVANCE_ID,
    ADVANCE          = Cn.ADVANCE,

    SALDO            = @dSALDO,
    SALDO_PENI       = @dSALDO_PENI,
    SUM_FACT         = @dSUM_FACT,
    SUM_NDS          = @dSUM_NDS,
    SUM_EXC          = @dSUM_EXC,
    SUM_ALL          = @dSUM_ALL,
    ADV_OLD          = @dADV_OLD,
    ADV_NEW          = @dADV_NEW,
    SUM_PENI         = @dSUM_PENI,
    QNT_ALL          = @dQNT_ALL,

    NEXT_DATE_BEG    = CONVERT(SmallDateTime,DATEADD(mm,+1,@dtCalcBegin)),
    NEXT_DATE_END    = CONVERT(SmallDateTime,DATEADD(dd,-1,DATEADD(mm,+2,@dtCalcBegin))),
    DATE_CONTRACT_CLOSE = Cn.DATE_CONTRACT_CLOSE,
    ADD_COST_TAX     = Cn.ADD_COST_TAX,
    GROUP_ID         = Cn.GROUP_ID,
    GROUP_NAME       = G.GROUP_NAME,
    G_BOSS_POST      = G.BOSS_POST,
    G_BOSS_NAME      = G.BOSS_NAME,
    G_BOOKKEEPER_POST = G.BOOKKEEPER_POST,
    G_BOOKKEEPER_NAME = G.BOOKKEEPER_NAME,
    G_ADDRESS        = CASE WHEN ISnull(G.STREET_ID,0) <> 0
                            THEN (SELECT Convert(VarChar(50),
                                         IsNull(RTrim(T.TOWN_NAME),'')+','+
                                         IsNull(RTrim(ST.STREET_TYPE_SHORT_NAME),'')+
                                         IsNull(RTrim(S.STREET_NAME),'')+','+
                                         IsNull(RTrim(G.HOUSE_ID),''))
                                  FROM   Streets     S,
                                         StreetTypes ST,
                                         Towns       T
                                  WHERE  S.STREET_ID=G.STREET_ID             AND
                                         ST.STREET_TYPE_ID=*S.STREET_TYPE_ID AND
                                         T.TOWN_ID=*S.TOWN_ID )
                            ELSE G.ADDRESS END,
    G_STREET_ID      = G.STREET_ID,
    G_HOUSE_ID       = G.HOUSE_ID,
    G_POST_INDEX     = G.POST_INDEX,
    G_PHONE          = G.PHONE,
    G_RNN            = G.RNN,
    G_BANK_ID        = RIGHT(STR(G.BANK_ID +1000000000,10),3),
    G_BRANCH_ID      = G.BRANCH_ID,
    G_CALC_ACCOUNT   = G.CALC_ACCOUNT,
    G_BANK_NAME      = (SELECT DISTINCT BANK_NAME
                        FROM BanksInfo
                        WHERE BANK_ID = G.BANK_ID) ,
    G_MFO            = (SELECT DISTINCT MFO
                        FROM BanksInfo
                        WHERE BANK_ID = G.BANK_ID),
    ABONENT_NAME     = A.ABONENT_NAME,
    A_ADDRESS        = CASE WHEN ISnull(A.STREET_ID,0) <> 0
                            THEN (SELECT Convert(VarChar(50),
                                         IsNull(RTrim(T.TOWN_NAME),'')+','+
                                         IsNull(RTrim(ST.STREET_TYPE_SHORT_NAME),'')+
                                         IsNull(RTrim(S.STREET_NAME),'')+','+
                                         IsNull(RTrim(A.HOUSE_ID),'')+','+
                                         IsNull(RTrim(A.FLAT_ID),''))
                                  FROM   Streets S,
                                         StreetTypes ST,
                                         Towns T
                                  WHERE  S.STREET_ID=A.STREET_ID             AND
                                         ST.STREET_TYPE_ID=*S.STREET_TYPE_ID AND
                                         T.TOWN_ID=*S.TOWN_ID )
                             ELSE A.ADDRESS END,
    A_STREET_ID      = A.STREET_ID,
    A_HOUSE_ID       = A.HOUSE_ID,
    A_POST_INDEX     = A.POST_INDEX,
    A_PHONE          = A.PHONE,
    A_RNN            = A.RNN,
    A_BANK_ID        = RIGHT(STR(A.BANK_ID +1000000000,10),3),
    A_BRANCH_ID      = A.BRANCH_ID,
    A_CALC_ACCOUNT   = A.CALC_ACCOUNT,
    A_MFO            = (SELECT DISTINCT LEFT(LTRIM(STR(MFO)),6)
                        FROM BanksInfo
                        WHERE BANK_ID = A.BANK_ID),
    A_BANK_NAME      = (SELECT DISTINCT BANK_NAME
                        FROM BanksInfo
                        WHERE BANK_ID = A.BANK_ID),
    C_ADD_COST_TAX   = Convert(Decimal(9,2),C.ADD_COST_TAX),
    C_EXC_TAX        = Convert(Decimal(9,2),C.EXCISE_TAX),
   G_RESIDENT_SECTOR = G.RESIDENT_SECTOR,
   A_RESIDENT_SECTOR = A.RESIDENT_SECTOR,
   A_CERTIFICATE_DATE       = A.CERTIFICATE_DATE,
   A_CERTIFICATE_NUMBER     = A.CERTIFICATE_NUMBER,
   A_CERTIFICATE_SERIES     = A.CERTIFICATE_SERIES,
   A_CERTIFICATE_AGENCY     = A.CERTIFICATE_AGENCY,
   A_CERTIFICATE_AGENCY_RNN = A.CERTIFICATE_AGENCY_RNN,
   A_PAYMENT_CODE           = A.PAYMENT_CODE,
   MAIN_PAYMENT_CODE        = G.PAYMENT_CODE,
   MAIN_GROUP_NAME          = G.GROUP_NAME,
   MAIN_CERTIFICATE_DATE    = G.CERTIFICATE_DATE,
   MAIN_CERTIFICATE_NUMBER  = G.CERTIFICATE_NUMBER,
   MAIN_CERTIFICATE_SERIES  = G.CERTIFICATE_SERIES,
   MAIN_CERTIFICATE_AGENCY  = G.CERTIFICATE_AGENCY,
   MAIN_CERTIFICATE_AGENCY_RNN = G.CERTIFICATE_AGENCY_RNN
   FROM
    ProCalcs          C  (NoLock),
    #ProContractsArc  Cn (NoLock),
    ProAbonentsArc    A  (NoLock),
--    ProGroupsArc      G  (NoLock)
   #tmpProGroups       G (nolock)
   WHERE
    Cn.CONTRACT_ID = @iContractId   AND
    A.ABONENT_ID   = Cn.ABONENT_ID  AND
    G.GROUP_ID     = Cn.GROUP_ID    AND
    C.CONTRACT_ID  = Cn.CONTRACT_ID AND
    C.DATE_CALC    = @dtCalcEnd     AND
    Cn.DATE_BEGIN  = @dtCalcEnd     AND
    A.DATE_ID      = @dtCalcEnd
--   AND  G.DATE_BEGIN   = @dtCalcEnd
   ORDER BY
    Cn.GROUP_ID,
    C.CONTRACT_ID

DROP TABLE #ProContracts
DROP TABLE #ProContractsArc

