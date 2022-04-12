declare
 @s_number     int,
 @s_number_str varchar(7),
 @s_number_beg int,
 @s_number_end int

IF OBJECT_ID('tempdb..#SealNumbers') is not null
  DROP TABLE #SealNumbers
create table #SealNumbers(
                          seal_number varchar(7) not null 
                         )
IF OBJECT_ID('tempdb..#SealNumberLimits') is not null
  DROP TABLE #SealNumberLimits
create table #SealNumberLimits
                         (
                          seal_number_beg int not null,
                          seal_number_end int not null
                         )

insert into #SealNumberLimits(seal_number_beg,seal_number_end)
values(1089701, 1089800)
/*
insert into #SealNumberLimits(seal_number_beg,seal_number_end)
values(1082101, 1082200)
insert into #SealNumberLimits(seal_number_beg,seal_number_end)
values(1061401, 1061500)
insert into #SealNumberLimits(seal_number_beg,seal_number_end)
values(1063801, 1063900)
insert into #SealNumberLimits(seal_number_beg,seal_number_end)
values(1068701, 1068800)
insert into #SealNumberLimits(seal_number_beg,seal_number_end)
values(1082401, 1082500)
insert into #SealNumberLimits(seal_number_beg,seal_number_end)
values(1068401, 1068500)
insert into #SealNumberLimits(seal_number_beg,seal_number_end)
values(1064501, 1064600)
insert into #SealNumberLimits(seal_number_beg,seal_number_end)
values(1064301, 1064400)
insert into #SealNumberLimits(seal_number_beg,seal_number_end)
values(1062401, 1062500)
insert into #SealNumberLimits(seal_number_beg,seal_number_end)
values(1081601, 1081700)
insert into #SealNumberLimits(seal_number_beg,seal_number_end)
values(0162981, 0163000)
insert into #SealNumberLimits(seal_number_beg,seal_number_end)
values(0137201, 0137300)
*/
declare curSealLimits cursor for
select seal_number_beg,
       seal_number_end
from #SealNumberLimits

open curSealLimits

fetch next from curSealLimits
into  @s_number_beg,  @s_number_end

while (@@fetch_status <> -1)
begin
  select @s_number = @s_number_beg
  while @s_number <= @s_number_end
  begin
    insert into #SealNumbers(seal_number)
    values (convert(varchar(7),@s_number))
    select @s_number = @s_number + 1
  end
  fetch next from curSealLimits
  into  @s_number_beg,  @s_number_end
end
close curSealLimits
deallocate curSealLimits


IF OBJECT_ID('tempdb..#CntSeals') is not null
  DROP TABLE #CntSeals
CREATE TABLE #CntSeals (
	[ACCOUNT_ID] [int] NOT NULL ,
	[COUNTER_NUMBER_ID] [smallint] NOT NULL ,
	[DATE_ID] [smalldatetime] NOT NULL ,
	[ACTION_ID] [tinyint] NOT NULL ,
	[SEAL_PLACE_ID] [tinyint] NOT NULL ,
	[SEAL_PLACE_NUMBER_ID] [tinyint] NOT NULL ,
	[SEAL_NUMBER] [varchar] (16) NOT NULL )

declare curSealNumbers cursor for
select seal_number from #SealNumbers
open curSealNumbers
fetch next from curSealNumbers
into @s_number_str
while (@@fetch_status <> -1)
begin
  insert into #CntSeals (ACCOUNT_ID,
                         COUNTER_NUMBER_ID,
                       	 DATE_ID,
                         ACTION_ID,
                         SEAL_PLACE_ID,
                         SEAL_PLACE_NUMBER_ID,
                         SEAL_NUMBER)
  select ACCOUNT_ID,
         COUNTER_NUMBER_ID,
       	 DATE_ID,
         ACTION_ID,
         SEAL_PLACE_ID,
         SEAL_PLACE_NUMBER_ID,
         SEAL_NUMBER
  from CntSeals
  where SEAL_NUMBER like '%'+@s_number_str+'%'

  fetch next from curSealNumbers
  into @s_number_str
end
close curSealNumbers
deallocate curSealNumbers


select 
  RES            = GS.SUBGROUP_RES,
  AREA           = 'Участок №'+convert(varchar(4),ENS.SITE_ID),
  BRIG           = GS.SUBGROUP_NAME,
  TP             = ENTL.SUBSTATION_TYPE_NAME+'-'+convert(varchar(4),CE.NODEID)+
                   '['+convert(varchar(1),EN.SECTION_ID)+']',
  ACCOUNT_ID     = CS1.ACCOUNT_ID,
  ACCOUNT_NAME   = A.ACCOUNT_NAME,
  ADDRESS        = S.STREET_NAME+' д.'+A.HOUSE_ID+
                      case when A.FLAT_NUMBER is not null
                           then ' кв.'+A.FLAT_NUMBER
                           else '' end,
  SEAL_NUMBER    = CS1.SEAL_NUMBER,
  SSEAL_PLACE    = CSP.SEAL_PLACE_NAME,
  INSTALL_DATE   = convert(varchar(20),CS1.DATE_ID,105),
  UNINSTALL_DATE = isnull(
                   (select convert(varchar(20),CS2.DATE_ID,105)
                    from #CntSeals CS2 (nolock)
                    where CS2.ACCOUNT_ID        = CS1.ACCOUNT_ID and
                          CS2.COUNTER_NUMBER_ID = CS1.COUNTER_NUMBER_ID and
                          CS2.ACTION_ID         = 15 and
                          CS2.SEAL_PLACE_ID     = CS1.SEAL_PLACE_ID and
                          CS2.SEAL_PLACE_NUMBER_ID = CS1.SEAL_PLACE_NUMBER_ID and
                          CS2.SEAL_NUMBER       =  CS1.SEAL_NUMBER
                    ),'')
from #CntSeals                     CS1  (nolock),
     aspBase2004_09..Accounts      A    (nolock),
     aspBase2004_09..Streets       S    (nolock),
     aspBase2004_09..AccountGroups AG   (nolock),
     GroupSub                      GS   (nolock),
     CntElectricity                CE   (nolock),
     ElectNodeSites                ENS  (nolock),
     ElectNodes                    EN   (nolock),    
     ElectNodeTypeList             ENTL (nolock),
     CntSealPlaces                 CSP  (nolock)
 
where CS1.ACTION_ID  = 5            and
      CS1.ACCOUNT_ID = A.ACCOUNT_ID and
      A.STREET_ID    = S.STREET_ID  and
      A.ACCOUNT_ID   = AG.ACCOUNT_ID and
      AG.GROUP_ID    = 10001         and
      AG.SUBGROUP_ID = GS.SUBGROUP_ID and
      A.ACCOUNT_ID   = CE.ACCOUNT_ID  and
      
      AG.SUBGROUP_ID = ENS.SUBGROUP_ID and
      CE.NODEID      = ENS.NODEID      and
  
      CE.NODEID      = EN.NODEID       and
      EN.SUBSTATION_TYPE_ID = ENTL.SUBSTATION_TYPE_ID and
      CSP.SEAL_PLACE_ID = CS1.SEAL_PLACE_ID

order by CS1.SEAL_NUMBER  

--drop table #CntSeals   
--drop table #SealNumbers
--drop table #SealNumberLimits