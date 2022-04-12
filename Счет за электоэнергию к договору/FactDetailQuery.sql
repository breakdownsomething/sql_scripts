/*
--select contract_id from ProContracts where contract_number = 1297
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
create table #ContractList (contract_id int not null)

if @bAllContracts = 1 --формируем сводный отчет 
  begin -- определение contract_id - ов входящих в одну группу с выбранным
  insert into #ContractList
  select PC.contract_id
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
  insert into #ContractList(contract_id) values (@iContractId) 
  end


if Exists (select * from TempDB..SysObjects
           where id = OBJECT_ID('TempDB..#TmpCalc'))
begin
DROP TABLE #TmpCalc
end

select calc_id
into #TmpCalc
from ProCalcs
where date_calc = @dtCalcEnd
  and contract_id in (select contract_id from #ContractList)

select * from #ContractList
select * from #TmpCalc
*/
------------------------------------------------------------------
declare
  @cacl_id        int,
  @c_exc_tax      decimal(8,2),
  @c_add_cost_tax decimal(8,2)
select
  @cacl_id        =-479619,
  @c_exc_tax      = 0.00,
  @c_add_cost_tax = 15.00



IF Exists
  (SELECT *
    FROM TempDB..SysObjects
    WHERE id = OBJECT_ID('TempDB..#TmpPrimFacture'))
  EXEC('DROP TABLE  #TmpPrimFacture')

SELECT
  SOURCE_ID = CD.CALC_ID,

  DATE_CALC = (SELECT C.DATE_CALC
               FROM   ProCalcs C (NoLock)
               WHERE  CALC_ID = CD.CALC_ID),

  QUANTITY  = Convert(Integer,SUM(CASE WHEN CD.MEASURE_ID=4
                                       THEN IsNull(CD.CALC_QUANTITY,0)
                                       ELSE 0 END)),

  SUM_CALC  = Convert(Decimal(18,2),SUM(IsNull(CD.SUM_CALC,0))),

  SUM_EXCISE = Convert(Decimal(18,2),0.0),

  SUM_NDS   = Convert(Decimal(18,2),0.0)

 INTO
  #TmpPrimFacture
 FROM
  ProCalcDetails CD (NoLock)
 WHERE
  CD.CALC_ID in (select calc_id from #TmpCalc) and
  CD.CALC_SIGN_FACT=1 AND
  IsNull(convert(int,CD.DECODE_ID),-1)<>0 AND
   (
    IsNull(convert(int,CD.DECODE_ID),-1)<>8 
    OR (IsNull(convert(int,CD.DECODE_ID),-1) = 8 AND CD.SOURCE_ID = CD.CALC_ID)
   )
 GROUP BY
  CD.CALC_ID


UPDATE
  #TmpPrimFacture
 SET
  SUM_EXCISE=ROUND(IsNull(QUANTITY,0)* @c_exc_tax ,2),
  SUM_NDS=ROUND((IsNull(SUM_CALC,0)+ROUND(IsNull(QUANTITY,0) *
                 @c_exc_tax ,2))/100.00* @c_add_cost_tax,2)

SELECT
  source_id = @cacl_id
 ,date_calc = (select date_calc from #TmpPrimFacture where source_id = @cacl_id)
 ,quantity  = sum(quantity)
 ,sum_calc  = sum(sum_calc)
 ,sum_excise = sum(sum_excise)
 ,sum_nds   = sum(sum_nds)
 FROM
  #TmpPrimFacture  (NoLock)





