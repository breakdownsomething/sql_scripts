

DECLARE
  @iContractId  Integer,
  @dtCalcBegin DateTime,
  @dtCalcEnd DateTime,
  @dtMainCalcEnd DateTime,
  @bAllContracts bit
SELECT
  @iContractId   = 38611 ,       --:piContractId,
  @dtCalcBegin   = '2004-05-01', --:pdtCalcBegin,
  @dtCalcEnd     = '2004-05-31', --:pdtCalcEnd,
  @dtMainCalcEnd = '2004-05-31', --:pdtMainCalcEnd
  @bAllContracts = 1 --:pbAllContracts  


if Exists (select * from TempDB..SysObjects
           where id = OBJECT_ID('TempDB..#ContractList'))
exec('DROP TABLE #ContractList')
create table #ContractList (contract_id int not null,
                            calc_id     int null)

if @bAllContracts = 1 --формируем сводный отчет 
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

update #ContractList
set calc_id = (select PC.calc_id
               from ProCalcs PC (nolock)
               where PC.contract_id = CL.contract_id
                 and PC.date_calc   = '2004-05-31')
from #ContractList CL

--select * from #ContractList
--drop table #TMPCalc
--drop table #ContractList
--===========================================================================================
-- Новый скрипт
declare 
  @calc_id int,
  @contract_id int,
  @i       int

select
  @calc_id = -479619 --:CALC_ID

select
  @contract_id = contract_id
from #ContractList
where calc_id = @calc_id



IF Exists
  (SELECT *
    FROM TempDB..SysObjects
    WHERE id = OBJECT_ID('TempDB..#TmpSecondFacture'))
begin
  DROP TABLE #TmpSecondFacture
end

CREATE Table
  #TmpSecondFacture(CNT       Integer       null,
                    DATE_CALC SmallDateTime null,
                    TAX_EXC   Decimal(9,2)  null,
                    TAX_NDS   Decimal(9,2)  null,
                    QUANTITY  Integer       null,
                    SUM_CALC  Decimal(18,2) null,
                    SUM_EXCISE Decimal(18,2) null, 
                    SUM_NDS   Decimal(18,2) null,
                    SOURCE_ID int           null)

-- сначала определяем даты за которые были доп начисления
insert into #TmpSecondFacture (CNT,
                    DATE_CALC,
                    TAX_EXC,
                    TAX_NDS,
                    QUANTITY,
                    SUM_CALC,
                    SUM_EXCISE, 
                    SUM_NDS,
                    SOURCE_ID)
select distinct
        0
       ,date_calc = PC.date_calc
       ,0
       ,0
       ,0
       ,0
       ,0
       ,0
       ,0
from ProCalcDetails CD (NoLock),
     #ContractList       TC (nolock),
     ProCalcs       PC (nolock)
where CD.calc_id = TC.calc_id and
      CD.source_id = PC.calc_id and
  (CD.CALC_SIGN_FACT = 1 OR CD.SOURCE_ID = 9407015) AND
  IsNull(convert(int,CD.DECODE_ID),-1) = 8 AND
  (CD.SOURCE_ID <> CD.CALC_ID OR CD.SOURCE_ID = 9407015)
order by PC.Date_calc desc

-- теперь ставки акциза и ндс за те периоды к которым относятся доп суммы

select @i = 0

update #TmpSecondFacture
set  @i = cnt = @i + 1
from #TmpSecondFacture


update #TmpSecondFacture
set
--  @i = cnt = @i + 1
 tax_exc = isnull(
                    (select top 1 ProCalcs.excise_tax
                     from ProCalcs       
                         ,ProCalcDetails 
                     where ProCalcs.calc_id = ProCalcDetails.source_id
                       and ProCalcDetails.calc_id = @calc_id
                       and ProCalcs.date_calc = TSF.date_calc
                     ),
                     (select top 1 ProCalcs.excise_tax
                      from ProCalcs       
                          ,ProCalcDetails 
                      where ProCalcs.calc_id = ProCalcDetails.source_id
                        and ProCalcDetails.calc_id in (select calc_id from #ContractList)
                        and ProCalcs.date_calc = TSF.date_calc
                     )
                   )  
 ,tax_nds = isnull(
                    (select top 1 ProCalcs.add_cost_tax
                     from ProCalcs       
                         ,ProCalcDetails 
                     where ProCalcs.calc_id = ProCalcDetails.source_id
                       and ProCalcDetails.calc_id = @calc_id
                       and ProCalcs.date_calc = TSF.date_calc
                     ),
                     (select top 1 ProCalcs.add_cost_tax
                      from ProCalcs       
                          ,ProCalcDetails 
                      where ProCalcs.calc_id = ProCalcDetails.source_id
                        and ProCalcDetails.calc_id in (select calc_id from #ContractList)
                        and ProCalcs.date_calc = TSF.date_calc
                     )
                   )
,source_id = isnull(
                    (select top 1 ProCalcs.calc_id
                     from ProCalcs       
                         ,ProCalcDetails 
                     where ProCalcs.calc_id = ProCalcDetails.source_id
                       and ProCalcDetails.calc_id = @calc_id
                       and ProCalcs.date_calc = TSF.date_calc
                     ),
                     (select top 1 ProCalcs.calc_id
                      from ProCalcs       
                          ,ProCalcDetails 
                      where ProCalcs.calc_id = ProCalcDetails.source_id
                        and ProCalcDetails.calc_id in (select calc_id from #ContractList)
                        and ProCalcs.date_calc = TSF.date_calc
                     )
                   )
 ,quantity = TMP.quantity
 ,sum_calc = TMP.sum_calc
from #TmpSecondFacture TSF,
     (select 
            date_calc = PC.date_calc
           ,quantity = sum(case when CD.MEASURE_ID=4
                       then isNull(CD.CALC_QUANTITY,0)
                       else 0 end)
           ,sum_calc = sum(CD.SUM_CALC)
      from ProCalcDetails CD (NoLock),
           #ContractList  TC (nolock),
           ProCalcs       PC (nolock)
      where CD.calc_id   = TC.calc_id and
            CD.source_id = PC.calc_id and
           (CD.CALC_SIGN_FACT = 1 OR CD.SOURCE_ID = 9407015) AND
           IsNull(convert(int,CD.DECODE_ID),-1) = 8  AND
           (CD.SOURCE_ID <> CD.CALC_ID OR CD.SOURCE_ID = 9407015)
      group by PC.date_calc
      ) TMP
where TMP.date_calc = TSF.date_calc


update #TmpSecondFacture
 set
  SUM_EXCISE = ROUND(IsNull(QUANTITY,0)* TAX_EXC ,2),
  SUM_NDS    = ROUND((IsNull(SUM_CALC,0) + ROUND(
                                                 IsNull((CASE WHEN DATE_CALC < '2000-09-30'
                                                              THEN 0
                                                              ELSE QUANTITY END),0)
                                                 * TAX_EXC ,2))/100.00* TAX_NDS
                                              ,2)


select * from #TmpSecondFacture order by date_calc desc
--drop table #TmpSecondFacture


