declare
   @DateCalc datetime
select
   @DateCalc = '2004-02-29'

--- Формирование временной таблицы
if Exists (select * from TempDB..SysObjects
           where id = OBJECT_ID('TempDB..#TmpProDivSal'))
exec('DROP TABLE #TmpProDivSal')

select
distinct  Contract_id = PDS.Contract_id
-- ,Nds_tax     = PDS.Nds_tax
-- Сальдо на начало------------------------------------------------------
--20%
 ,BQuantity20   = convert(int,0)
 ,BSum_ee20     = convert(decimal(18,2),0)
 ,BSum_nds20    = convert(decimal(18,2),0) 
 ,BSum_exc20    = convert(decimal(18,2),0)
 ,BQuantityDB20 = convert(int,0)
 ,BSum_eeDB20   = convert(decimal(18,2),0)
 ,BSum_ndsDB20  = convert(decimal(18,2),0)
 ,BSum_excDB20  = convert(decimal(18,2),0)
 ,BQuantityCR20 = convert(int,0)
 ,BSum_eeCR20   = convert(decimal(18,2),0)
 ,BSum_ndsCR20  = convert(decimal(18,2),0)
 ,BSum_excCR20  = convert(decimal(18,2),0)
--16%
 ,BQuantity16   = convert(int,0)
 ,BSum_ee16     = convert(decimal(18,2),0)
 ,BSum_nds16    = convert(decimal(18,2),0) 
 ,BSum_exc16    = convert(decimal(18,2),0)
 ,BQuantityDB16 = convert(int,0)
 ,BSum_eeDB16   = convert(decimal(18,2),0)
 ,BSum_ndsDB16  = convert(decimal(18,2),0)
 ,BSum_excDB16  = convert(decimal(18,2),0)
 ,BQuantityCR16 = convert(int,0)
 ,BSum_eeCR16   = convert(decimal(18,2),0)
 ,BSum_ndsCR16  = convert(decimal(18,2),0)
 ,BSum_excCR16  = convert(decimal(18,2),0)
--15%
 ,BQuantity15   = convert(int,0)
 ,BSum_ee15     = convert(decimal(18,2),0)
 ,BSum_nds15    = convert(decimal(18,2),0) 
 ,BSum_exc15    = convert(decimal(18,2),0)
 ,BQuantityDB15 = convert(int,0)
 ,BSum_eeDB15   = convert(decimal(18,2),0)
 ,BSum_ndsDB15  = convert(decimal(18,2),0)
 ,BSum_excDB15  = convert(decimal(18,2),0)
 ,BQuantityCR15 = convert(int,0)
 ,BSum_eeCR15   = convert(decimal(18,2),0)
 ,BSum_ndsCR15  = convert(decimal(18,2),0)
 ,BSum_excCR15  = convert(decimal(18,2),0)
-- Начисления-----------------------------------------------------
--20%
 ,NQuantity20   = convert(int,0)
 ,NSum_ee20     = convert(decimal(18,2),0)
 ,NSum_nds20    = convert(decimal(18,2),0) 
 ,NSum_exc20    = convert(decimal(18,2),0)
 ,NQuantityDB20 = convert(int,0)
 ,NSum_eeDB20   = convert(decimal(18,2),0)
 ,NSum_ndsDB20  = convert(decimal(18,2),0)
 ,NSum_excDB20  = convert(decimal(18,2),0)
 ,NQuantityCR20 = convert(int,0)
 ,NSum_eeCR20   = convert(decimal(18,2),0)
 ,NSum_ndsCR20  = convert(decimal(18,2),0)
 ,NSum_excCR20  = convert(decimal(18,2),0)
--16%
 ,NQuantity16   = convert(int,0)
 ,NSum_ee16     = convert(decimal(18,2),0)
 ,NSum_nds16    = convert(decimal(18,2),0) 
 ,NSum_exc16    = convert(decimal(18,2),0)
 ,NQuantityDB16 = convert(int,0)
 ,NSum_eeDB16   = convert(decimal(18,2),0)
 ,NSum_ndsDB16  = convert(decimal(18,2),0)
 ,NSum_excDB16  = convert(decimal(18,2),0)
 ,NQuantityCR16 = convert(int,0)
 ,NSum_eeCR16   = convert(decimal(18,2),0)
 ,NSum_ndsCR16  = convert(decimal(18,2),0)
 ,NSum_excCR16  = convert(decimal(18,2),0)
--15%
 ,NQuantity15   = convert(int,0)
 ,NSum_ee15     = convert(decimal(18,2),0)
 ,NSum_nds15    = convert(decimal(18,2),0) 
 ,NSum_exc15    = convert(decimal(18,2),0)
 ,NQuantityDB15 = convert(int,0)
 ,NSum_eeDB15   = convert(decimal(18,2),0)
 ,NSum_ndsDB15  = convert(decimal(18,2),0)
 ,NSum_excDB15  = convert(decimal(18,2),0)
 ,NQuantityCR15 = convert(int,0)
 ,NSum_eeCR15   = convert(decimal(18,2),0)
 ,NSum_ndsCR15  = convert(decimal(18,2),0)
 ,NSum_excCR15  = convert(decimal(18,2),0)
--Платежи-----------------------------------------------------------------------
--20%
 ,PQuantity20   = convert(int,0)
 ,PSum_ee20     = convert(decimal(18,2),0)
 ,PSum_nds20    = convert(decimal(18,2),0) 
 ,PSum_exc20    = convert(decimal(18,2),0)
 ,PQuantityDB20 = convert(int,0)
 ,PSum_eeDB20   = convert(decimal(18,2),0)
 ,PSum_ndsDB20  = convert(decimal(18,2),0)
 ,PSum_excDB20  = convert(decimal(18,2),0)
 ,PQuantityCR20 = convert(int,0)
 ,PSum_eeCR20   = convert(decimal(18,2),0)
 ,PSum_ndsCR20  = convert(decimal(18,2),0)
 ,PSum_excCR20  = convert(decimal(18,2),0)
--16%
 ,PQuantity16   = convert(int,0)
 ,PSum_ee16     = convert(decimal(18,2),0)
 ,PSum_nds16    = convert(decimal(18,2),0) 
 ,PSum_exc16    = convert(decimal(18,2),0)
 ,PQuantityDB16 = convert(int,0)
 ,PSum_eeDB16   = convert(decimal(18,2),0)
 ,PSum_ndsDB16  = convert(decimal(18,2),0)
 ,PSum_excDB16  = convert(decimal(18,2),0)
 ,PQuantityCR16 = convert(int,0)
 ,PSum_eeCR16   = convert(decimal(18,2),0)
 ,PSum_ndsCR16  = convert(decimal(18,2),0)
 ,PSum_excCR16  = convert(decimal(18,2),0)
--15%
 ,PQuantity15   = convert(int,0)
 ,PSum_ee15     = convert(decimal(18,2),0)
 ,PSum_nds15    = convert(decimal(18,2),0) 
 ,PSum_exc15    = convert(decimal(18,2),0)
 ,PQuantityDB15 = convert(int,0)
 ,PSum_eeDB15   = convert(decimal(18,2),0)
 ,PSum_ndsDB15  = convert(decimal(18,2),0)
 ,PSum_excDB15  = convert(decimal(18,2),0)
 ,PQuantityCR15 = convert(int,0)
 ,PSum_eeCR15   = convert(decimal(18,2),0)
 ,PSum_ndsCR15  = convert(decimal(18,2),0)
 ,PSum_excCR15  = convert(decimal(18,2),0)
--Сальдо на конец-------------------------------------------
--20%
 ,EQuantity20   = convert(int,0)
 ,ESum_ee20     = convert(decimal(18,2),0)
 ,ESum_nds20    = convert(decimal(18,2),0) 
 ,ESum_exc20    = convert(decimal(18,2),0)
 ,EQuantityDB20 = convert(int,0)
 ,ESum_eeDB20   = convert(decimal(18,2),0)
 ,ESum_ndsDB20  = convert(decimal(18,2),0)
 ,ESum_excDB20  = convert(decimal(18,2),0)
 ,EQuantityCR20 = convert(int,0)
 ,ESum_eeCR20   = convert(decimal(18,2),0)
 ,ESum_ndsCR20  = convert(decimal(18,2),0)
 ,ESum_excCR20  = convert(decimal(18,2),0) 
--16%
 ,EQuantity16   = convert(int,0)
 ,ESum_ee16     = convert(decimal(18,2),0)
 ,ESum_nds16    = convert(decimal(18,2),0) 
 ,ESum_exc16    = convert(decimal(18,2),0)
 ,EQuantityDB16 = convert(int,0)
 ,ESum_eeDB16   = convert(decimal(18,2),0)
 ,ESum_ndsDB16  = convert(decimal(18,2),0)
 ,ESum_excDB16  = convert(decimal(18,2),0)
 ,EQuantityCR16 = convert(int,0)
 ,ESum_eeCR16   = convert(decimal(18,2),0)
 ,ESum_ndsCR16  = convert(decimal(18,2),0)
 ,ESum_excCR16  = convert(decimal(18,2),0) 
--15%
 ,EQuantity15   = convert(int,0)
 ,ESum_ee15     = convert(decimal(18,2),0)
 ,ESum_nds15    = convert(decimal(18,2),0) 
 ,ESum_exc15    = convert(decimal(18,2),0)
 ,EQuantityDB15 = convert(int,0)
 ,ESum_eeDB15   = convert(decimal(18,2),0)
 ,ESum_ndsDB15  = convert(decimal(18,2),0)
 ,ESum_excDB15  = convert(decimal(18,2),0)
 ,EQuantityCR15 = convert(int,0)
 ,ESum_eeCR15   = convert(decimal(18,2),0)
 ,ESum_ndsCR15  = convert(decimal(18,2),0)
 ,ESum_excCR15  = convert(decimal(18,2),0) 
  into #TmpProDivSal
  from ProDivSal PDS (nolock)
  where Date_calc = @DateCalc

  alter table #TmpProDivSal add primary key (Contract_id)

--debug code--------------------------------------
--select count(contract_id) from #TmpProDivSal
--drop table #TmpProDivSal

--20%
update #TmpProDivSal 
set 
  BQuantity20   = convert(int,IsNull(PDS.BQuantity,0))
 ,BSum_ee20     = convert(decimal(18,2),IsNull(PDS.BSum_ee,0))
 ,BSum_nds20    = convert(decimal(18,2),IsNull(PDS.BSum_nds,0)) 
 ,BSum_exc20    = convert(decimal(18,2),IsNull(PDS.BSum_exc,0))
 ,BQuantityDB20 = case when (select Isnull(sum(P.BSum_ee + P.BSum_nds + P.BSum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) > 0
                     then convert(int,IsNull(PDS.BQuantity,0))
                     else convert(int,0) end
 ,BSum_eeDB20   = case when (select Isnull(sum(P.BSum_ee + P.BSum_nds + P.BSum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) > 0
                     then convert(decimal(18,2),IsNull(PDS.BSum_ee,0))
                     else convert(decimal(18,2),0) end
 ,BSum_ndsDB20  = case when (select Isnull(sum(P.BSum_ee + P.BSum_nds + P.BSum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) > 0
                     then convert(decimal(18,2),IsNull(PDS.BSum_nds,0))
                     else convert(decimal(18,2),0) end
 ,BSum_excDB20  = case when (select Isnull(sum(P.BSum_ee + P.BSum_nds + P.BSum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) > 0
                     then convert(decimal(18,2),IsNull(PDS.BSum_exc,0))
                     else convert(decimal(18,2),0) end
 ,BQuantityCR20 = case when (select Isnull(sum(P.BSum_ee + P.BSum_nds + P.BSum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) <= 0
                     then convert(int,IsNull(PDS.BQuantity,0))
                     else convert(int,0) end
 ,BSum_eeCR20   = case when (select Isnull(sum(P.BSum_ee + P.BSum_nds + P.BSum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) <= 0
                     then convert(decimal(18,2),IsNull(PDS.BSum_ee,0))
                     else convert(decimal(18,2),0) end
 ,BSum_ndsCR20  = case when (select Isnull(sum(P.BSum_ee + P.BSum_nds + P.BSum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) <= 0
                     then convert(decimal(18,2),IsNull(PDS.BSum_nds,0))
                     else convert(decimal(18,2),0) end
 ,BSum_excCR20  = case when (select Isnull(sum(P.BSum_ee + P.BSum_nds + P.BSum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) <= 0
                     then convert(decimal(18,2),IsNull(PDS.BSum_exc,0))
                     else convert(decimal(18,2),0) end
-- Начисления-----------------------------------------------------
 ,NQuantity20   = convert(int,IsNull(PDS.NQuantity,0))
 ,NSum_ee20     = convert(decimal(18,2),IsNull(PDS.NSum_ee,0))
 ,NSum_nds20    = convert(decimal(18,2),IsNull(PDS.NSum_nds,0)) 
 ,NSum_exc20    = convert(decimal(18,2),IsNull(PDS.NSum_exc,0))
 ,NQuantityDB20 = case when (select Isnull(sum(P.NSum_ee + P.NSum_nds + P.NSum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) > 0
                     then convert(int,IsNull(PDS.NQuantity,0))
                     else convert(int,0) end
 ,NSum_eeDB20   = case when (select Isnull(sum(P.NSum_ee + P.NSum_nds + P.NSum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) > 0
                     then convert(decimal(18,2),IsNull(PDS.NSum_ee,0))
                     else convert(decimal(18,2),0) end
 ,NSum_ndsDB20  = case when (select Isnull(sum(P.NSum_ee + P.NSum_nds + P.NSum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) > 0
                     then convert(decimal(18,2),IsNull(PDS.NSum_nds,0))
                     else convert(decimal(18,2),0) end
 ,NSum_excDB20  = case when (select Isnull(sum(P.NSum_ee + P.NSum_nds + P.NSum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) > 0
                     then convert(decimal(18,2),IsNull(PDS.NSum_exc,0))
                     else convert(decimal(18,2),0) end
 ,NQuantityCR20 = case when (select Isnull(sum(P.NSum_ee + P.NSum_nds + P.NSum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) <= 0
                     then convert(int,IsNull(PDS.NQuantity,0))
                     else convert(int,0) end
 ,NSum_eeCR20   = case when (select Isnull(sum(P.NSum_ee + P.NSum_nds + P.NSum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) <= 0
                     then convert(decimal(18,2),IsNull(PDS.NSum_ee,0))
                     else convert(decimal(18,2),0) end
 ,NSum_ndsCR20  = case when (select Isnull(sum(P.NSum_ee + P.NSum_nds + P.NSum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) <= 0
                     then convert(decimal(18,2),IsNull(PDS.NSum_nds,0))
                     else convert(decimal(18,2),0) end
 ,NSum_excCR20  = case when (select Isnull(sum(P.NSum_ee + P.NSum_nds + P.NSum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) <= 0
                     then convert(decimal(18,2),IsNull(PDS.NSum_exc,0))
                     else convert(decimal(18,2),0) end
--Платежи-----------------------------------------------------------------------
 ,PQuantity20   = convert(int,IsNull(PDS.PQuantity,0))
 ,PSum_ee20     = convert(decimal(18,2),IsNull(PDS.PSum_ee,0))
 ,PSum_nds20    = convert(decimal(18,2),IsNull(PDS.PSum_nds,0)) 
 ,PSum_exc20    = convert(decimal(18,2),IsNull(PDS.PSum_exc,0))
 ,PQuantityDB20 = case when (select Isnull(sum(P.PSum_ee + P.PSum_nds + P.PSum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) > 0
                     then convert(int,IsNull(PDS.PQuantity,0))
                     else convert(int,0) end
 ,PSum_eeDB20   = case when (select Isnull(sum(P.PSum_ee + P.PSum_nds + P.PSum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) > 0
                     then convert(decimal(18,2),IsNull(PDS.PSum_ee,0))
                     else convert(decimal(18,2),0) end
 ,PSum_ndsDB20  = case when (select Isnull(sum(P.PSum_ee + P.PSum_nds + P.PSum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) > 0
                     then convert(decimal(18,2),IsNull(PDS.PSum_nds,0))
                     else convert(decimal(18,2),0) end
 ,PSum_excDB20  = case when (select Isnull(sum(P.PSum_ee + P.PSum_nds + P.PSum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) > 0
                     then convert(decimal(18,2),IsNull(PDS.PSum_exc,0))
                     else convert(decimal(18,2),0) end
 ,PQuantityCR20 = case when (select Isnull(sum(P.PSum_ee + P.PSum_nds + P.PSum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) <= 0
                     then convert(int,IsNull(PDS.PQuantity,0))
                     else convert(int,0) end
 ,PSum_eeCR20   = case when (select Isnull(sum(P.PSum_ee + P.PSum_nds + P.PSum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) <= 0
                     then convert(decimal(18,2),IsNull(PDS.PSum_ee,0))
                     else convert(decimal(18,2),0) end
 ,PSum_ndsCR20  = case when (select Isnull(sum(P.PSum_ee + P.PSum_nds + P.PSum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) <= 0
                     then convert(decimal(18,2),IsNull(PDS.PSum_nds,0))
                     else convert(decimal(18,2),0) end
 ,PSum_excCR20  = case when (select Isnull(sum(P.PSum_ee + P.PSum_nds + P.PSum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) <= 0
                     then convert(decimal(18,2),IsNull(PDS.PSum_exc,0))
                     else convert(decimal(18,2),0) end
--Сальдо на конец-------------------------------------------
 ,EQuantity20   = convert(int,IsNull(PDS.EQuantity,0))
 ,ESum_ee20     = convert(decimal(18,2),IsNull(PDS.ESum_ee,0))
 ,ESum_nds20    = convert(decimal(18,2),IsNull(PDS.ESum_nds,0)) 
 ,ESum_exc20    = convert(decimal(18,2),IsNull(PDS.ESum_exc,0))
 ,EQuantityDB20 = case when (select Isnull(sum(P.ESum_ee + P.ESum_nds + P.ESum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) > 0
                     then convert(int,IsNull(PDS.EQuantity,0))
                     else convert(int,0) end
 ,ESum_eeDB20   = case when (select Isnull(sum(P.ESum_ee + P.ESum_nds + P.ESum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) > 0
                     then convert(decimal(18,2),IsNull(PDS.ESum_ee,0))
                     else convert(decimal(18,2),0) end
 ,ESum_ndsDB20  = case when (select Isnull(sum(P.ESum_ee + P.ESum_nds + P.ESum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) > 0
                     then convert(decimal(18,2),IsNull(PDS.ESum_nds,0))
                     else convert(decimal(18,2),0) end
 ,ESum_excDB20  = case when (select Isnull(sum(P.ESum_ee + P.ESum_nds + P.ESum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) > 0
                     then convert(decimal(18,2),IsNull(PDS.ESum_exc,0))
                     else convert(decimal(18,2),0) end
 ,EQuantityCR20 = case when (select Isnull(sum(P.ESum_ee + P.ESum_nds + P.ESum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) <= 0
                     then convert(int,IsNull(PDS.EQuantity,0))
                     else convert(int,0) end
 ,ESum_eeCR20   = case when (select Isnull(sum(P.ESum_ee + P.ESum_nds + P.ESum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) <= 0
                     then convert(decimal(18,2),IsNull(PDS.ESum_ee,0))
                     else convert(decimal(18,2),0) end
 ,ESum_ndsCR20  = case when (select Isnull(sum(P.ESum_ee + P.ESum_nds + P.ESum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) <= 0
                     then convert(decimal(18,2),IsNull(PDS.ESum_nds,0))
                     else convert(decimal(18,2),0) end
 ,ESum_excCR20  = case when (select Isnull(sum(P.ESum_ee + P.ESum_nds + P.ESum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) <= 0
                     then convert(decimal(18,2),IsNull(PDS.ESum_exc,0))
                     else convert(decimal(18,2),0) end
from ProDivSal PDS (nolock)
    ,#TmpProDivSal TMP
where TMP.Contract_id = PDS.Contract_id
  and PDS.Nds_tax = 20
  and PDS.Date_calc = @DateCalc

--16%
update #TmpProDivSal 
set 
  BQuantity16   = convert(int,IsNull(PDS.BQuantity,0))
 ,BSum_ee16     = convert(decimal(18,2),IsNull(PDS.BSum_ee,0))
 ,BSum_nds16    = convert(decimal(18,2),IsNull(PDS.BSum_nds,0)) 
 ,BSum_exc16    = convert(decimal(18,2),IsNull(PDS.BSum_exc,0))
 ,BQuantityDB16 = case when (select Isnull(sum(P.BSum_ee + P.BSum_nds + P.BSum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) > 0
                     then convert(int,IsNull(PDS.BQuantity,0))
                     else convert(int,0) end
 ,BSum_eeDB16   = case when (select Isnull(sum(P.BSum_ee + P.BSum_nds + P.BSum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) > 0
                     then convert(decimal(18,2),IsNull(PDS.BSum_ee,0))
                     else convert(decimal(18,2),0) end
 ,BSum_ndsDB16  = case when (select Isnull(sum(P.BSum_ee + P.BSum_nds + P.BSum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) > 0
                     then convert(decimal(18,2),IsNull(PDS.BSum_nds,0))
                     else convert(decimal(18,2),0) end
 ,BSum_excDB16  = case when (select Isnull(sum(P.BSum_ee + P.BSum_nds + P.BSum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) > 0
                     then convert(decimal(18,2),IsNull(PDS.BSum_exc,0))
                     else convert(decimal(18,2),0) end
 ,BQuantityCR16 = case when (select Isnull(sum(P.BSum_ee + P.BSum_nds + P.BSum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) <= 0
                     then convert(int,IsNull(PDS.BQuantity,0))
                     else convert(int,0) end
 ,BSum_eeCR16   = case when (select Isnull(sum(P.BSum_ee + P.BSum_nds + P.BSum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) <= 0
                     then convert(decimal(18,2),IsNull(PDS.BSum_ee,0))
                     else convert(decimal(18,2),0) end
 ,BSum_ndsCR16  = case when (select Isnull(sum(P.BSum_ee + P.BSum_nds + P.BSum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) <= 0
                     then convert(decimal(18,2),IsNull(PDS.BSum_nds,0))
                     else convert(decimal(18,2),0) end
 ,BSum_excCR16  = case when (select Isnull(sum(P.BSum_ee + P.BSum_nds + P.BSum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) <= 0
                     then convert(decimal(18,2),IsNull(PDS.BSum_exc,0))
                     else convert(decimal(18,2),0) end
-- Начисления-----------------------------------------------------
 ,NQuantity16   = convert(int,IsNull(PDS.NQuantity,0))
 ,NSum_ee16     = convert(decimal(18,2),IsNull(PDS.NSum_ee,0))
 ,NSum_nds16    = convert(decimal(18,2),IsNull(PDS.NSum_nds,0)) 
 ,NSum_exc16    = convert(decimal(18,2),IsNull(PDS.NSum_exc,0))
 ,NQuantityDB16 = case when (select Isnull(sum(P.NSum_ee + P.NSum_nds + P.NSum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) > 0
                     then convert(int,IsNull(PDS.NQuantity,0))
                     else convert(int,0) end
 ,NSum_eeDB16   = case when (select Isnull(sum(P.NSum_ee + P.NSum_nds + P.NSum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) > 0
                     then convert(decimal(18,2),IsNull(PDS.NSum_ee,0))
                     else convert(decimal(18,2),0) end
 ,NSum_ndsDB16  = case when (select Isnull(sum(P.NSum_ee + P.NSum_nds + P.NSum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) > 0
                     then convert(decimal(18,2),IsNull(PDS.NSum_nds,0))
                     else convert(decimal(18,2),0) end
 ,NSum_excDB16  = case when (select Isnull(sum(P.NSum_ee + P.NSum_nds + P.NSum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) > 0
                     then convert(decimal(18,2),IsNull(PDS.NSum_exc,0))
                     else convert(decimal(18,2),0) end
 ,NQuantityCR16 = case when (select Isnull(sum(P.NSum_ee + P.NSum_nds + P.NSum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) <= 0
                     then convert(int,IsNull(PDS.NQuantity,0))
                     else convert(int,0) end
 ,NSum_eeCR16   = case when (select Isnull(sum(P.NSum_ee + P.NSum_nds + P.NSum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) <= 0
                     then convert(decimal(18,2),IsNull(PDS.NSum_ee,0))
                     else convert(decimal(18,2),0) end
 ,NSum_ndsCR16  = case when (select Isnull(sum(P.NSum_ee + P.NSum_nds + P.NSum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) <= 0
                     then convert(decimal(18,2),IsNull(PDS.NSum_nds,0))
                     else convert(decimal(18,2),0) end
 ,NSum_excCR16  = case when (select Isnull(sum(P.NSum_ee + P.NSum_nds + P.NSum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) <= 0
                     then convert(decimal(18,2),IsNull(PDS.NSum_exc,0))
                     else convert(decimal(18,2),0) end
--Платежи-----------------------------------------------------------------------
 ,PQuantity16   = convert(int,IsNull(PDS.PQuantity,0))
 ,PSum_ee16     = convert(decimal(18,2),IsNull(PDS.PSum_ee,0))
 ,PSum_nds16    = convert(decimal(18,2),IsNull(PDS.PSum_nds,0)) 
 ,PSum_exc16    = convert(decimal(18,2),IsNull(PDS.PSum_exc,0))
 ,PQuantityDB16 = case when (select Isnull(sum(P.PSum_ee + P.PSum_nds + P.PSum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) > 0
                     then convert(int,IsNull(PDS.PQuantity,0))
                     else convert(int,0) end
 ,PSum_eeDB16   = case when (select Isnull(sum(P.PSum_ee + P.PSum_nds + P.PSum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) > 0
                     then convert(decimal(18,2),IsNull(PDS.PSum_ee,0))
                     else convert(decimal(18,2),0) end
 ,PSum_ndsDB16  = case when (select Isnull(sum(P.PSum_ee + P.PSum_nds + P.PSum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) > 0
                     then convert(decimal(18,2),IsNull(PDS.PSum_nds,0))
                     else convert(decimal(18,2),0) end
 ,PSum_excDB16  = case when (select Isnull(sum(P.PSum_ee + P.PSum_nds + P.PSum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) > 0
                     then convert(decimal(18,2),IsNull(PDS.PSum_exc,0))
                     else convert(decimal(18,2),0) end
 ,PQuantityCR16 = case when (select Isnull(sum(P.PSum_ee + P.PSum_nds + P.PSum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) <= 0
                     then convert(int,IsNull(PDS.PQuantity,0))
                     else convert(int,0) end
 ,PSum_eeCR16   = case when (select Isnull(sum(P.PSum_ee + P.PSum_nds + P.PSum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) <= 0
                     then convert(decimal(18,2),IsNull(PDS.PSum_ee,0))
                     else convert(decimal(18,2),0) end
 ,PSum_ndsCR16  = case when (select Isnull(sum(P.PSum_ee + P.PSum_nds + P.PSum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) <= 0
                     then convert(decimal(18,2),IsNull(PDS.PSum_nds,0))
                     else convert(decimal(18,2),0) end
 ,PSum_excCR16  = case when (select Isnull(sum(P.PSum_ee + P.PSum_nds + P.PSum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) <= 0
                     then convert(decimal(18,2),IsNull(PDS.PSum_exc,0))
                     else convert(decimal(18,2),0) end
--Сальдо на конец-------------------------------------------
 ,EQuantity16   = convert(int,IsNull(PDS.EQuantity,0))
 ,ESum_ee16     = convert(decimal(18,2),IsNull(PDS.ESum_ee,0))
 ,ESum_nds16    = convert(decimal(18,2),IsNull(PDS.ESum_nds,0)) 
 ,ESum_exc16    = convert(decimal(18,2),IsNull(PDS.ESum_exc,0))
 ,EQuantityDB16 = case when (select Isnull(sum(P.ESum_ee + P.ESum_nds + P.ESum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) > 0
                     then convert(int,IsNull(PDS.EQuantity,0))
                     else convert(int,0) end
 ,ESum_eeDB16   = case when (select Isnull(sum(P.ESum_ee + P.ESum_nds + P.ESum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) > 0
                     then convert(decimal(18,2),IsNull(PDS.ESum_ee,0))
                     else convert(decimal(18,2),0) end
 ,ESum_ndsDB16  = case when (select Isnull(sum(P.ESum_ee + P.ESum_nds + P.ESum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) > 0
                     then convert(decimal(18,2),IsNull(PDS.ESum_nds,0))
                     else convert(decimal(18,2),0) end
 ,ESum_excDB16  = case when (select Isnull(sum(P.ESum_ee + P.ESum_nds + P.ESum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) > 0
                     then convert(decimal(18,2),IsNull(PDS.ESum_exc,0))
                     else convert(decimal(18,2),0) end
 ,EQuantityCR16 = case when (select Isnull(sum(P.ESum_ee + P.ESum_nds + P.ESum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) <= 0
                     then convert(int,IsNull(PDS.EQuantity,0))
                     else convert(int,0) end
 ,ESum_eeCR16   = case when (select Isnull(sum(P.ESum_ee + P.ESum_nds + P.ESum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) <= 0
                     then convert(decimal(18,2),IsNull(PDS.ESum_ee,0))
                     else convert(decimal(18,2),0) end
 ,ESum_ndsCR16  = case when (select Isnull(sum(P.ESum_ee + P.ESum_nds + P.ESum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) <= 0
                     then convert(decimal(18,2),IsNull(PDS.ESum_nds,0))
                     else convert(decimal(18,2),0) end
 ,ESum_excCR16  = case when (select Isnull(sum(P.ESum_ee + P.ESum_nds + P.ESum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) <= 0
                     then convert(decimal(18,2),IsNull(PDS.ESum_exc,0))
                     else convert(decimal(18,2),0) end
from ProDivSal PDS (nolock)
    ,#TmpProDivSal TMP
where TMP.Contract_id = PDS.Contract_id
  and PDS.Nds_tax = 16
  and PDS.Date_calc = @DateCalc

--15%
update #TmpProDivSal 
set 
  BQuantity15   = convert(int,IsNull(PDS.BQuantity,0))
 ,BSum_ee15     = convert(decimal(18,2),IsNull(PDS.BSum_ee,0))
 ,BSum_nds15    = convert(decimal(18,2),IsNull(PDS.BSum_nds,0)) 
 ,BSum_exc15    = convert(decimal(18,2),IsNull(PDS.BSum_exc,0))
 ,BQuantityDB15 = case when (select Isnull(sum(P.BSum_ee + P.BSum_nds + P.BSum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) > 0
                     then convert(int,IsNull(PDS.BQuantity,0))
                     else convert(int,0) end
 ,BSum_eeDB15   = case when (select Isnull(sum(P.BSum_ee + P.BSum_nds + P.BSum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) > 0
                     then convert(decimal(18,2),IsNull(PDS.BSum_ee,0))
                     else convert(decimal(18,2),0) end
 ,BSum_ndsDB15  = case when (select Isnull(sum(P.BSum_ee + P.BSum_nds + P.BSum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) > 0
                     then convert(decimal(18,2),IsNull(PDS.BSum_nds,0))
                     else convert(decimal(18,2),0) end
 ,BSum_excDB15  = case when (select Isnull(sum(P.BSum_ee + P.BSum_nds + P.BSum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) > 0
                     then convert(decimal(18,2),IsNull(PDS.BSum_exc,0))
                     else convert(decimal(18,2),0) end
 ,BQuantityCR15 = case when (select Isnull(sum(P.BSum_ee + P.BSum_nds + P.BSum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) <= 0
                     then convert(int,IsNull(PDS.BQuantity,0))
                     else convert(int,0) end
 ,BSum_eeCR15   = case when (select Isnull(sum(P.BSum_ee + P.BSum_nds + P.BSum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) <= 0
                     then convert(decimal(18,2),IsNull(PDS.BSum_ee,0))
                     else convert(decimal(18,2),0) end
 ,BSum_ndsCR15  = case when (select Isnull(sum(P.BSum_ee + P.BSum_nds + P.BSum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) <= 0
                     then convert(decimal(18,2),IsNull(PDS.BSum_nds,0))
                     else convert(decimal(18,2),0) end
 ,BSum_excCR15  = case when (select Isnull(sum(P.BSum_ee + P.BSum_nds + P.BSum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) <= 0
                     then convert(decimal(18,2),IsNull(PDS.BSum_exc,0))
                     else convert(decimal(18,2),0) end
-- Начисления-----------------------------------------------------
 ,NQuantity15   = convert(int,IsNull(PDS.NQuantity,0))
 ,NSum_ee15     = convert(decimal(18,2),IsNull(PDS.NSum_ee,0))
 ,NSum_nds15    = convert(decimal(18,2),IsNull(PDS.NSum_nds,0)) 
 ,NSum_exc15    = convert(decimal(18,2),IsNull(PDS.NSum_exc,0))
 ,NQuantityDB15 = case when (select Isnull(sum(P.NSum_ee + P.NSum_nds + P.NSum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) > 0
                     then convert(int,IsNull(PDS.NQuantity,0))
                     else convert(int,0) end
 ,NSum_eeDB15   = case when (select Isnull(sum(P.NSum_ee + P.NSum_nds + P.NSum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) > 0
                     then convert(decimal(18,2),IsNull(PDS.NSum_ee,0))
                     else convert(decimal(18,2),0) end
 ,NSum_ndsDB15  = case when (select Isnull(sum(P.NSum_ee + P.NSum_nds + P.NSum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) > 0
                     then convert(decimal(18,2),IsNull(PDS.NSum_nds,0))
                     else convert(decimal(18,2),0) end
 ,NSum_excDB15  = case when (select Isnull(sum(P.NSum_ee + P.NSum_nds + P.NSum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) > 0
                     then convert(decimal(18,2),IsNull(PDS.NSum_exc,0))
                     else convert(decimal(18,2),0) end
 ,NQuantityCR15 = case when (select Isnull(sum(P.NSum_ee + P.NSum_nds + P.NSum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) <= 0
                     then convert(int,IsNull(PDS.NQuantity,0))
                     else convert(int,0) end
 ,NSum_eeCR15   = case when (select Isnull(sum(P.NSum_ee + P.NSum_nds + P.NSum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) <= 0
                     then convert(decimal(18,2),IsNull(PDS.NSum_ee,0))
                     else convert(decimal(18,2),0) end
 ,NSum_ndsCR15  = case when (select Isnull(sum(P.NSum_ee + P.NSum_nds + P.NSum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) <= 0
                     then convert(decimal(18,2),IsNull(PDS.NSum_nds,0))
                     else convert(decimal(18,2),0) end
 ,NSum_excCR15  = case when (select Isnull(sum(P.NSum_ee + P.NSum_nds + P.NSum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) <= 0
                     then convert(decimal(18,2),IsNull(PDS.NSum_exc,0))
                     else convert(decimal(18,2),0) end
--Платежи-----------------------------------------------------------------------
 ,PQuantity15   = convert(int,IsNull(PDS.PQuantity,0))
 ,PSum_ee15     = convert(decimal(18,2),IsNull(PDS.PSum_ee,0))
 ,PSum_nds15    = convert(decimal(18,2),IsNull(PDS.PSum_nds,0)) 
 ,PSum_exc15    = convert(decimal(18,2),IsNull(PDS.PSum_exc,0))
 ,PQuantityDB15 = case when (select Isnull(sum(P.PSum_ee + P.PSum_nds + P.PSum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) > 0
                     then convert(int,IsNull(PDS.PQuantity,0))
                     else convert(int,0) end
 ,PSum_eeDB15   = case when (select Isnull(sum(P.PSum_ee + P.PSum_nds + P.PSum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) > 0
                     then convert(decimal(18,2),IsNull(PDS.PSum_ee,0))
                     else convert(decimal(18,2),0) end
 ,PSum_ndsDB15  = case when (select Isnull(sum(P.PSum_ee + P.PSum_nds + P.PSum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) > 0
                     then convert(decimal(18,2),IsNull(PDS.PSum_nds,0))
                     else convert(decimal(18,2),0) end
 ,PSum_excDB15  = case when (select Isnull(sum(P.PSum_ee + P.PSum_nds + P.PSum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) > 0
                     then convert(decimal(18,2),IsNull(PDS.PSum_exc,0))
                     else convert(decimal(18,2),0) end
 ,PQuantityCR15 = case when (select Isnull(sum(P.PSum_ee + P.PSum_nds + P.PSum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) <= 0
                     then convert(int,IsNull(PDS.PQuantity,0))
                     else convert(int,0) end
 ,PSum_eeCR15   = case when (select Isnull(sum(P.PSum_ee + P.PSum_nds + P.PSum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) <= 0
                     then convert(decimal(18,2),IsNull(PDS.PSum_ee,0))
                     else convert(decimal(18,2),0) end
 ,PSum_ndsCR15  = case when (select Isnull(sum(P.PSum_ee + P.PSum_nds + P.PSum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) <= 0
                     then convert(decimal(18,2),IsNull(PDS.PSum_nds,0))
                     else convert(decimal(18,2),0) end
 ,PSum_excCR15  = case when (select Isnull(sum(P.PSum_ee + P.PSum_nds + P.PSum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) <= 0
                     then convert(decimal(18,2),IsNull(PDS.PSum_exc,0))
                     else convert(decimal(18,2),0) end
--Сальдо на конец-------------------------------------------
 ,EQuantity15   = convert(int,IsNull(PDS.EQuantity,0))
 ,ESum_ee15     = convert(decimal(18,2),IsNull(PDS.ESum_ee,0))
 ,ESum_nds15    = convert(decimal(18,2),IsNull(PDS.ESum_nds,0)) 
 ,ESum_exc15    = convert(decimal(18,2),IsNull(PDS.ESum_exc,0))
 ,EQuantityDB15 = case when (select Isnull(sum(P.ESum_ee + P.ESum_nds + P.ESum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) > 0
                     then convert(int,IsNull(PDS.EQuantity,0))
                     else convert(int,0) end
 ,ESum_eeDB15   = case when (select Isnull(sum(P.ESum_ee + P.ESum_nds + P.ESum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) > 0
                     then convert(decimal(18,2),IsNull(PDS.ESum_ee,0))
                     else convert(decimal(18,2),0) end
 ,ESum_ndsDB15  = case when (select Isnull(sum(P.ESum_ee + P.ESum_nds + P.ESum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) > 0
                     then convert(decimal(18,2),IsNull(PDS.ESum_nds,0))
                     else convert(decimal(18,2),0) end
 ,ESum_excDB15  = case when (select Isnull(sum(P.ESum_ee + P.ESum_nds + P.ESum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) > 0
                     then convert(decimal(18,2),IsNull(PDS.ESum_exc,0))
                     else convert(decimal(18,2),0) end
 ,EQuantityCR15 = case when (select Isnull(sum(P.ESum_ee + P.ESum_nds + P.ESum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) <= 0
                     then convert(int,IsNull(PDS.EQuantity,0))
                     else convert(int,0) end
 ,ESum_eeCR15   = case when (select Isnull(sum(P.ESum_ee + P.ESum_nds + P.ESum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) <= 0
                     then convert(decimal(18,2),IsNull(PDS.ESum_ee,0))
                     else convert(decimal(18,2),0) end
 ,ESum_ndsCR15  = case when (select Isnull(sum(P.ESum_ee + P.ESum_nds + P.ESum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) <= 0
                     then convert(decimal(18,2),IsNull(PDS.ESum_nds,0))
                     else convert(decimal(18,2),0) end
 ,ESum_excCR15  = case when (select Isnull(sum(P.ESum_ee + P.ESum_nds + P.ESum_exc),0)
                             from ProDivSal P (nolock)
                             where P.Contract_id = PDS.Contract_id
                               and P.date_calc   = @DateCalc) <= 0
                     then convert(decimal(18,2),IsNull(PDS.ESum_exc,0))
                     else convert(decimal(18,2),0) end
from ProDivSal PDS (nolock)
    ,#TmpProDivSal TMP
where TMP.Contract_id = PDS.Contract_id
  and PDS.Nds_tax = 15
  and PDS.Date_calc = @DateCalc



-------------------------------------------------------------
-- Основная выборка------------------------------------------
-- сальдо на начало------------------------------------------
select
  BRes         = ' РЭС-'+Right(Str(Cs.GROUP_ID),1)
--20%
 ,BSaldo20       = sum(DS.BSum_ee20 + DS.Bsum_nds20 + DS.BSum_exc20)
 ,BQuantity20    = sum(DS.BQuantity20)
 ,BSum_ee20      = sum(DS.BSum_ee20)
 ,BSum_nds20     = sum(DS.BSum_nds20)
 ,BSum_exc20     = sum(DS.BSum_exc20)
 ,BSaldoDB20     = sum(DS.BSum_eeDB20 + DS.Bsum_ndsDB20 + DS.BSum_excDB20)
 ,BQuantityDB20  = sum(DS.BQuantityDB20)
 ,BSum_eeDB20    = sum(DS.BSum_eeDB20)
 ,BSum_ndsDB20   = sum(DS.BSum_ndsDB20)
 ,BSum_excDB20   = sum(DS.BSum_excDB20)
 ,BSaldoCR20     = sum(DS.BSum_eeCR20 + DS.Bsum_ndsCR20 + DS.BSum_excCR20)
 ,BQuantityCR20  = sum(DS.BQuantityCR20)
 ,BSum_eeCR20    = sum(DS.BSum_eeCR20)
 ,BSum_ndsCR20   = sum(DS.BSum_ndsCR20)
 ,BSum_excCR20   = sum(DS.BSum_excCR20)
--16%
 ,BSaldo16       = sum(DS.BSum_ee16 + DS.Bsum_nds16 + DS.BSum_exc16)
 ,BQuantity16    = sum(DS.BQuantity16)
 ,BSum_ee16      = sum(DS.BSum_ee16)
 ,BSum_nds16     = sum(DS.BSum_nds16)
 ,BSum_exc16     = sum(DS.BSum_exc16)
 ,BSaldoDB16     = sum(DS.BSum_eeDB16 + DS.Bsum_ndsDB16 + DS.BSum_excDB16)
 ,BQuantityDB16  = sum(DS.BQuantityDB16)
 ,BSum_eeDB16    = sum(DS.BSum_eeDB16)
 ,BSum_ndsDB16   = sum(DS.BSum_ndsDB16)
 ,BSum_excDB16   = sum(DS.BSum_excDB16)
 ,BSaldoCR16     = sum(DS.BSum_eeCR16 + DS.Bsum_ndsCR16 + DS.BSum_excCR16)
 ,BQuantityCR16  = sum(DS.BQuantityCR16)
 ,BSum_eeCR16    = sum(DS.BSum_eeCR16)
 ,BSum_ndsCR16   = sum(DS.BSum_ndsCR16)
 ,BSum_excCR16   = sum(DS.BSum_excCR16)
--15%
 ,BSaldo15       = sum(DS.BSum_ee15 + DS.Bsum_nds15 + DS.BSum_exc15)
 ,BQuantity15    = sum(DS.BQuantity15)
 ,BSum_ee15      = sum(DS.BSum_ee15)
 ,BSum_nds15     = sum(DS.BSum_nds15)
 ,BSum_exc15     = sum(DS.BSum_exc15)
 ,BSaldoDB15     = sum(DS.BSum_eeDB15 + DS.Bsum_ndsDB15 + DS.BSum_excDB15)
 ,BQuantityDB15  = sum(DS.BQuantityDB15)
 ,BSum_eeDB15    = sum(DS.BSum_eeDB15)
 ,BSum_ndsDB15   = sum(DS.BSum_ndsDB15)
 ,BSum_excDB15   = sum(DS.BSum_excDB15)
 ,BSaldoCR15     = sum(DS.BSum_eeCR15 + DS.Bsum_ndsCR15 + DS.BSum_excCR15)
 ,BQuantityCR15  = sum(DS.BQuantityCR15)
 ,BSum_eeCR15    = sum(DS.BSum_eeCR15)
 ,BSum_ndsCR15   = sum(DS.BSum_ndsCR15)
 ,BSum_excCR15  = sum(DS.BSum_excCR15)
-- Начисления---------------------------------------------
 ,NRes        = ' РЭС-'+Right(Str(Cs.GROUP_ID),1)
--20%
 ,Nach20        = sum(DS.NSum_ee20 + DS.NSum_nds20 + DS.NSum_exc20)
 ,NQuantity20   = sum(DS.NQUANTITY20)
 ,NSum_ee20     = sum(DS.NSum_ee20)
 ,NSum_nds20    = sum(DS.NSum_nds20)
 ,NSUM_exc20    = sum(DS.NSum_exc20)
 ,NachDB20      = sum(DS.NSum_eeDB20 + DS.NSum_ndsDB20 + DS.NSum_excDB20)
 ,NQuantityDB20 = sum(DS.NQuantityDB20)
 ,NSum_eeDB20   = sum(DS.NSum_eeDB20)
 ,NSum_ndsDB20  = sum(DS.NSum_ndsDB20)
 ,NSUM_excDB20  = sum(DS.NSum_excDB20)
 ,NachCR20      = sum(DS.NSum_eeCR20 + DS.NSum_ndsCR20 + DS.NSum_excCR20)
 ,NQuantityCR20 = sum(DS.NQuantityCR20)
 ,NSum_eeCR20   = sum(DS.NSum_eeCR20)
 ,NSum_ndsCR20  = sum(DS.NSum_ndsCR20)
 ,NSUM_excCR20  = sum(DS.NSum_excCR20)
--16%
 ,Nach16        = sum(DS.NSum_ee16 + DS.NSum_nds16 + DS.NSum_exc16)
 ,NQuantity16   = sum(DS.NQUANTITY16)
 ,NSum_ee16     = sum(DS.NSum_ee16)
 ,NSum_nds16    = sum(DS.NSum_nds16)
 ,NSUM_exc16    = sum(DS.NSum_exc16)
 ,NachDB16      = sum(DS.NSum_eeDB16 + DS.NSum_ndsDB16 + DS.NSum_excDB16)
 ,NQuantityDB16 = sum(DS.NQuantityDB16)
 ,NSum_eeDB16   = sum(DS.NSum_eeDB16)
 ,NSum_ndsDB16  = sum(DS.NSum_ndsDB16)
 ,NSUM_excDB16  = sum(DS.NSum_excDB16)
 ,NachCR16      = sum(DS.NSum_eeCR16 + DS.NSum_ndsCR16 + DS.NSum_excCR16)
 ,NQuantityCR16 = sum(DS.NQuantityCR16)
 ,NSum_eeCR16   = sum(DS.NSum_eeCR16)
 ,NSum_ndsCR16  = sum(DS.NSum_ndsCR16)
 ,NSUM_excCR16  = sum(DS.NSum_excCR16)
--15%
 ,Nach15        = sum(DS.NSum_ee15 + DS.NSum_nds15 + DS.NSum_exc15)
 ,NQuantity15   = sum(DS.NQUANTITY15)
 ,NSum_ee15     = sum(DS.NSum_ee15)
 ,NSum_nds15    = sum(DS.NSum_nds15)
 ,NSUM_exc15    = sum(DS.NSum_exc15)
 ,NachDB15      = sum(DS.NSum_eeDB15 + DS.NSum_ndsDB15 + DS.NSum_excDB15)
 ,NQuantityDB15 = sum(DS.NQuantityDB15)
 ,NSum_eeDB15   = sum(DS.NSum_eeDB15)
 ,NSum_ndsDB15  = sum(DS.NSum_ndsDB15)
 ,NSUM_excDB15  = sum(DS.NSum_excDB15)
 ,NachCR15      = sum(DS.NSum_eeCR15 + DS.NSum_ndsCR15 + DS.NSum_excCR15)
 ,NQuantityCR15 = sum(DS.NQuantityCR15)
 ,NSum_eeCR15   = sum(DS.NSum_eeCR15)
 ,NSum_ndsCR15  = sum(DS.NSum_ndsCR15)
 ,NSUM_excCR15  = sum(DS.NSum_excCR15)

--Платежи
 ,PRes        = ' РЭС-'+Right(Str(Cs.GROUP_ID),1)    
--20%
 ,Pay20         = sum(DS.PSum_ee20 + DS.PSum_nds20 + DS.PSum_exc20)
 ,PQuantity20   = sum(DS.PQuantity20)
 ,PSum_ee20     = sum(DS.PSum_ee20)
 ,PSum_nds20    = sum(DS.PSum_nds20)
 ,PSum_exc20    = sum(DS.PSum_exc20)
 ,PayDB20       = sum(DS.PSum_eeDB20 + DS.PSum_ndsDB20 + DS.PSum_excDB20)
 ,PQuantityDB20 = sum(DS.PQuantityDB20)
 ,PSum_eeDB20   = sum(DS.PSum_eeDB20)
 ,PSum_ndsDB20  = sum(DS.PSum_ndsDB20)
 ,PSum_excDB20  = sum(DS.PSum_excDB20)
 ,PayCR20       = sum(DS.PSum_eeCR20 + DS.PSum_ndsCR20 + DS.PSum_excCR20)
 ,PQuantityCR20 = sum(DS.PQuantityCR20)
 ,PSum_eeCR20   = sum(DS.PSum_eeCR20)
 ,PSum_ndsCR20  = sum(DS.PSum_ndsCR20)
 ,PSum_excCR20  = sum(DS.PSum_excCR20)
--16%
 ,Pay16         = sum(DS.PSum_ee16 + DS.PSum_nds16 + DS.PSum_exc16)
 ,PQuantity16   = sum(DS.PQuantity16)
 ,PSum_ee16     = sum(DS.PSum_ee16)
 ,PSum_nds16    = sum(DS.PSum_nds16)
 ,PSum_exc16    = sum(DS.PSum_exc16)
 ,PayDB16       = sum(DS.PSum_eeDB16 + DS.PSum_ndsDB16 + DS.PSum_excDB16)
 ,PQuantityDB16 = sum(DS.PQuantityDB16)
 ,PSum_eeDB16   = sum(DS.PSum_eeDB16)
 ,PSum_ndsDB16  = sum(DS.PSum_ndsDB16)
 ,PSum_excDB16  = sum(DS.PSum_excDB16)
 ,PayCR16       = sum(DS.PSum_eeCR16 + DS.PSum_ndsCR16 + DS.PSum_excCR16)
 ,PQuantityCR16 = sum(DS.PQuantityCR16)
 ,PSum_eeCR16   = sum(DS.PSum_eeCR16)
 ,PSum_ndsCR16  = sum(DS.PSum_ndsCR16)
 ,PSum_excCR16  = sum(DS.PSum_excCR16)
--15%
 ,Pay15         = sum(DS.PSum_ee15 + DS.PSum_nds15 + DS.PSum_exc15)
 ,PQuantity15   = sum(DS.PQuantity15)
 ,PSum_ee15     = sum(DS.PSum_ee15)
 ,PSum_nds15    = sum(DS.PSum_nds15)
 ,PSum_exc15    = sum(DS.PSum_exc15)
 ,PayDB15       = sum(DS.PSum_eeDB15 + DS.PSum_ndsDB15 + DS.PSum_excDB15)
 ,PQuantityDB15 = sum(DS.PQuantityDB15)
 ,PSum_eeDB15   = sum(DS.PSum_eeDB15)
 ,PSum_ndsDB15  = sum(DS.PSum_ndsDB15)
 ,PSum_excDB15  = sum(DS.PSum_excDB15)
 ,PayCR15       = sum(DS.PSum_eeCR15 + DS.PSum_ndsCR15 + DS.PSum_excCR15)
 ,PQuantityCR15 = sum(DS.PQuantityCR15)
 ,PSum_eeCR15   = sum(DS.PSum_eeCR15)
 ,PSum_ndsCR15  = sum(DS.PSum_ndsCR15)
 ,PSum_excCR15  = sum(DS.PSum_excCR15)

--Сальдо на конец
 ,ERes        = ' РЭС-'+Right(Str(Cs.GROUP_ID),1)
--20%
 ,ESaldo20      = sum(DS.ESum_ee20 + DS.ESum_nds20 + DS.ESum_exc20)
 ,EQuantity20   = sum(DS.EQuantity20)
 ,ESum_ee20     = sum(DS.ESum_ee20)
 ,ESum_nds20    = sum(DS.ESum_nds20)
 ,ESum_exc20    = sum(DS.ESum_exc20)
 ,ESaldoDB20    = sum(DS.ESum_eeDB20 + DS.ESum_ndsDB20 + DS.ESum_excDB20)
 ,EQuantityDB20 = sum(DS.EQuantityDB20)
 ,ESum_eeDB20   = sum(DS.ESum_eeDB20)
 ,ESum_ndsDB20  = sum(DS.ESum_ndsDB20)
 ,ESum_excDB20  = sum(DS.ESum_excDB20)
 ,ESaldoCR20    = sum(DS.ESum_eeCR20 + DS.ESum_ndsCR20 + DS.ESum_excCR20)
 ,EQuantityCR20 = sum(DS.EQuantityCR20)
 ,ESum_eeCR20   = sum(DS.ESum_eeCR20)
 ,ESum_ndsCR20  = sum(DS.ESum_ndsCR20)
 ,ESum_excCR20  = sum(DS.ESum_excCR20)
--16%
 ,ESaldo16      = sum(DS.ESum_ee16 + DS.ESum_nds16 + DS.ESum_exc16)
 ,EQuantity16   = sum(DS.EQuantity16)
 ,ESum_ee16     = sum(DS.ESum_ee16)
 ,ESum_nds16    = sum(DS.ESum_nds16)
 ,ESum_exc16    = sum(DS.ESum_exc16)
 ,ESaldoDB16    = sum(DS.ESum_eeDB16 + DS.ESum_ndsDB16 + DS.ESum_excDB16)
 ,EQuantityDB16 = sum(DS.EQuantityDB16)
 ,ESum_eeDB16   = sum(DS.ESum_eeDB16)
 ,ESum_ndsDB16  = sum(DS.ESum_ndsDB16)
 ,ESum_excDB16  = sum(DS.ESum_excDB16)
 ,ESaldoCR16    = sum(DS.ESum_eeCR16 + DS.ESum_ndsCR16 + DS.ESum_excCR16)
 ,EQuantityCR16 = sum(DS.EQuantityCR16)
 ,ESum_eeCR16   = sum(DS.ESum_eeCR16)
 ,ESum_ndsCR16  = sum(DS.ESum_ndsCR16)
 ,ESum_excCR16  = sum(DS.ESum_excCR16)
--15%
 ,ESaldo15      = sum(DS.ESum_ee15 + DS.ESum_nds15 + DS.ESum_exc15)
 ,EQuantity15   = sum(DS.EQuantity15)
 ,ESum_ee15     = sum(DS.ESum_ee15)
 ,ESum_nds15    = sum(DS.ESum_nds15)
 ,ESum_exc15    = sum(DS.ESum_exc15)
 ,ESaldoDB15    = sum(DS.ESum_eeDB15 + DS.ESum_ndsDB15 + DS.ESum_excDB15)
 ,EQuantityDB15 = sum(DS.EQuantityDB15)
 ,ESum_eeDB15   = sum(DS.ESum_eeDB15)
 ,ESum_ndsDB15  = sum(DS.ESum_ndsDB15)
 ,ESum_excDB15  = sum(DS.ESum_excDB15)
 ,ESaldoCR15    = sum(DS.ESum_eeCR15 + DS.ESum_ndsCR15 + DS.ESum_excCR15)
 ,EQuantityCR15 = sum(DS.EQuantityCR15)
 ,ESum_eeCR15   = sum(DS.ESum_eeCR15)
 ,ESum_ndsCR15  = sum(DS.ESum_ndsCR15)
 ,ESum_excCR15  = sum(DS.ESum_excCR15)
 from
   ProContracts    Cs (NoLock)
  ,#TmpProDivSal   DS (NoLock)
 where
      DS.CONTRACT_ID = Cs.CONTRACT_ID
  and not ((Cs.GROUP_ID=10011 AND Cs.SUBGROUP_ID=7) OR 
           (Cs.GROUP_ID=10012 AND Cs.SUBGROUP_ID=6) OR 
           (Cs.GROUP_ID=10014 AND Cs.SUBGROUP_ID=5) OR
           (Cs.GROUP_ID=10015 AND Cs.SUBGROUP_ID=8) OR 
           (Cs.GROUP_ID=10017 AND Cs.SUBGROUP_ID=6))
 group by
' РЭС-'+Right(Str(Cs.GROUP_ID),1)

------------------------------ UNION 1 ------------------------
 UNION 
 SELECT
  BRES=
    CASE
      WHEN (Cs.GROUP_ID=10011 AND Cs.SUBGROUP_ID=9) THEN
        ' РЭС-'+Right(Str(Cs.GROUP_ID),1)+' в т.ч. РП-41'
      WHEN (Cs.GROUP_ID=10011 AND Cs.SUBGROUP_ID=7) OR
           (Cs.GROUP_ID=10012 AND Cs.SUBGROUP_ID=6) OR 
           (Cs.GROUP_ID=10014 AND Cs.SUBGROUP_ID=5) OR 
           (Cs.GROUP_ID=10015 AND Cs.SUBGROUP_ID=8) OR
           (Cs.GROUP_ID=10017 AND Cs.SUBGROUP_ID=6) THEN
        'Всего СЭПУ'
      WHEN Cs.GROUP_ID=10015 AND Cs.ADD_COST_TAX=0 THEN
        ' РЭС-'+Right(Str(Cs.GROUP_ID),1)+' в т.ч. б/НДС'
    END

--20%
 ,BSaldo20       = sum(DS.BSum_ee20 + DS.Bsum_nds20 + DS.BSum_exc20)
 ,BQuantity20    = sum(DS.BQuantity20)
 ,BSum_ee20      = sum(DS.BSum_ee20)
 ,BSum_nds20     = sum(DS.BSum_nds20)
 ,BSum_exc20     = sum(DS.BSum_exc20)
 ,BSaldoDB20     = sum(DS.BSum_eeDB20 + DS.Bsum_ndsDB20 + DS.BSum_excDB20)
 ,BQuantityDB20  = sum(DS.BQuantityDB20)
 ,BSum_eeDB20    = sum(DS.BSum_eeDB20)
 ,BSum_ndsDB20   = sum(DS.BSum_ndsDB20)
 ,BSum_excDB20   = sum(DS.BSum_excDB20)
 ,BSaldoCR20     = sum(DS.BSum_eeCR20 + DS.Bsum_ndsCR20 + DS.BSum_excCR20)
 ,BQuantityCR20  = sum(DS.BQuantityCR20)
 ,BSum_eeCR20    = sum(DS.BSum_eeCR20)
 ,BSum_ndsCR20   = sum(DS.BSum_ndsCR20)
 ,BSum_excCR20   = sum(DS.BSum_excCR20)
--16%
 ,BSaldo16       = sum(DS.BSum_ee16 + DS.Bsum_nds16 + DS.BSum_exc16)
 ,BQuantity16    = sum(DS.BQuantity16)
 ,BSum_ee16      = sum(DS.BSum_ee16)
 ,BSum_nds16     = sum(DS.BSum_nds16)
 ,BSum_exc16     = sum(DS.BSum_exc16)
 ,BSaldoDB16     = sum(DS.BSum_eeDB16 + DS.Bsum_ndsDB16 + DS.BSum_excDB16)
 ,BQuantityDB16  = sum(DS.BQuantityDB16)
 ,BSum_eeDB16    = sum(DS.BSum_eeDB16)
 ,BSum_ndsDB16   = sum(DS.BSum_ndsDB16)
 ,BSum_excDB16   = sum(DS.BSum_excDB16)
 ,BSaldoCR16     = sum(DS.BSum_eeCR16 + DS.Bsum_ndsCR16 + DS.BSum_excCR16)
 ,BQuantityCR16  = sum(DS.BQuantityCR16)
 ,BSum_eeCR16    = sum(DS.BSum_eeCR16)
 ,BSum_ndsCR16   = sum(DS.BSum_ndsCR16)
 ,BSum_excCR16   = sum(DS.BSum_excCR16)
--15%
 ,BSaldo15       = sum(DS.BSum_ee15 + DS.Bsum_nds15 + DS.BSum_exc15)
 ,BQuantity15    = sum(DS.BQuantity15)
 ,BSum_ee15      = sum(DS.BSum_ee15)
 ,BSum_nds15     = sum(DS.BSum_nds15)
 ,BSum_exc15     = sum(DS.BSum_exc15)
 ,BSaldoDB15     = sum(DS.BSum_eeDB15 + DS.Bsum_ndsDB15 + DS.BSum_excDB15)
 ,BQuantityDB15  = sum(DS.BQuantityDB15)
 ,BSum_eeDB15    = sum(DS.BSum_eeDB15)
 ,BSum_ndsDB15   = sum(DS.BSum_ndsDB15)
 ,BSum_excDB15   = sum(DS.BSum_excDB15)
 ,BSaldoCR15     = sum(DS.BSum_eeCR15 + DS.Bsum_ndsCR15 + DS.BSum_excCR15)
 ,BQuantityCR15  = sum(DS.BQuantityCR15)
 ,BSum_eeCR15    = sum(DS.BSum_eeCR15)
 ,BSum_ndsCR15   = sum(DS.BSum_ndsCR15)
 ,BSum_excCR15  = sum(DS.BSum_excCR15)

 ,NRES=
    CASE
      WHEN (Cs.GROUP_ID=10011 AND Cs.SUBGROUP_ID=9) THEN
        ' РЭС-'+Right(Str(Cs.GROUP_ID),1)+' в т.ч. РП-41'
      WHEN (Cs.GROUP_ID=10011 AND Cs.SUBGROUP_ID=7) OR
           (Cs.GROUP_ID=10012 AND Cs.SUBGROUP_ID=6) OR 
           (Cs.GROUP_ID=10014 AND Cs.SUBGROUP_ID=5) OR 
           (Cs.GROUP_ID=10015 AND Cs.SUBGROUP_ID=8) OR
           (Cs.GROUP_ID=10017 AND Cs.SUBGROUP_ID=6) THEN
        'Всего СЭПУ'
      WHEN Cs.GROUP_ID=10015 AND Cs.ADD_COST_TAX=0 THEN
        ' РЭС-'+Right(Str(Cs.GROUP_ID),1)+' в т.ч. б/НДС'
    END
 ,Nach20        = sum(DS.NSum_ee20 + DS.NSum_nds20 + DS.NSum_exc20)
 ,NQuantity20   = sum(DS.NQUANTITY20)
 ,NSum_ee20     = sum(DS.NSum_ee20)
 ,NSum_nds20    = sum(DS.NSum_nds20)
 ,NSUM_exc20    = sum(DS.NSum_exc20)
 ,NachDB20      = sum(DS.NSum_eeDB20 + DS.NSum_ndsDB20 + DS.NSum_excDB20)
 ,NQuantityDB20 = sum(DS.NQuantityDB20)
 ,NSum_eeDB20   = sum(DS.NSum_eeDB20)
 ,NSum_ndsDB20  = sum(DS.NSum_ndsDB20)
 ,NSUM_excDB20  = sum(DS.NSum_excDB20)
 ,NachCR20      = sum(DS.NSum_eeCR20 + DS.NSum_ndsCR20 + DS.NSum_excCR20)
 ,NQuantityCR20 = sum(DS.NQuantityCR20)
 ,NSum_eeCR20   = sum(DS.NSum_eeCR20)
 ,NSum_ndsCR20  = sum(DS.NSum_ndsCR20)
 ,NSUM_excCR20  = sum(DS.NSum_excCR20)
--16%
 ,Nach16        = sum(DS.NSum_ee16 + DS.NSum_nds16 + DS.NSum_exc16)
 ,NQuantity16   = sum(DS.NQUANTITY16)
 ,NSum_ee16     = sum(DS.NSum_ee16)
 ,NSum_nds16    = sum(DS.NSum_nds16)
 ,NSUM_exc16    = sum(DS.NSum_exc16)
 ,NachDB16      = sum(DS.NSum_eeDB16 + DS.NSum_ndsDB16 + DS.NSum_excDB16)
 ,NQuantityDB16 = sum(DS.NQuantityDB16)
 ,NSum_eeDB16   = sum(DS.NSum_eeDB16)
 ,NSum_ndsDB16  = sum(DS.NSum_ndsDB16)
 ,NSUM_excDB16  = sum(DS.NSum_excDB16)
 ,NachCR16      = sum(DS.NSum_eeCR16 + DS.NSum_ndsCR16 + DS.NSum_excCR16)
 ,NQuantityCR16 = sum(DS.NQuantityCR16)
 ,NSum_eeCR16   = sum(DS.NSum_eeCR16)
 ,NSum_ndsCR16  = sum(DS.NSum_ndsCR16)
 ,NSUM_excCR16  = sum(DS.NSum_excCR16)
--15%
 ,Nach15        = sum(DS.NSum_ee15 + DS.NSum_nds15 + DS.NSum_exc15)
 ,NQuantity15   = sum(DS.NQUANTITY15)
 ,NSum_ee15     = sum(DS.NSum_ee15)
 ,NSum_nds15    = sum(DS.NSum_nds15)
 ,NSUM_exc15    = sum(DS.NSum_exc15)
 ,NachDB15      = sum(DS.NSum_eeDB15 + DS.NSum_ndsDB15 + DS.NSum_excDB15)
 ,NQuantityDB15 = sum(DS.NQuantityDB15)
 ,NSum_eeDB15   = sum(DS.NSum_eeDB15)
 ,NSum_ndsDB15  = sum(DS.NSum_ndsDB15)
 ,NSUM_excDB15  = sum(DS.NSum_excDB15)
 ,NachCR15      = sum(DS.NSum_eeCR15 + DS.NSum_ndsCR15 + DS.NSum_excCR15)
 ,NQuantityCR15 = sum(DS.NQuantityCR15)
 ,NSum_eeCR15   = sum(DS.NSum_eeCR15)
 ,NSum_ndsCR15  = sum(DS.NSum_ndsCR15)
 ,NSUM_excCR15  = sum(DS.NSum_excCR15)

 ,PRES=
    CASE
      WHEN (Cs.GROUP_ID=10011 AND Cs.SUBGROUP_ID=9) THEN
        ' РЭС-'+Right(Str(Cs.GROUP_ID),1)+' в т.ч. РП-41'
      WHEN (Cs.GROUP_ID=10011 AND Cs.SUBGROUP_ID=7) OR 
           (Cs.GROUP_ID=10012 AND Cs.SUBGROUP_ID=6) OR 
           (Cs.GROUP_ID=10014 AND Cs.SUBGROUP_ID=5) OR
           (Cs.GROUP_ID=10015 AND Cs.SUBGROUP_ID=8) OR 
           (Cs.GROUP_ID=10017 AND Cs.SUBGROUP_ID=6) THEN
        'Всего СЭПУ'
      WHEN Cs.GROUP_ID=10015 AND Cs.ADD_COST_TAX=0 THEN
        ' РЭС-'+Right(Str(Cs.GROUP_ID),1)+' в т.ч. б/НДС'
    END
 ,Pay20         = sum(DS.PSum_ee20 + DS.PSum_nds20 + DS.PSum_exc20)
 ,PQuantity20   = sum(DS.PQuantity20)
 ,PSum_ee20     = sum(DS.PSum_ee20)
 ,PSum_nds20    = sum(DS.PSum_nds20)
 ,PSum_exc20    = sum(DS.PSum_exc20)
 ,PayDB20       = sum(DS.PSum_eeDB20 + DS.PSum_ndsDB20 + DS.PSum_excDB20)
 ,PQuantityDB20 = sum(DS.PQuantityDB20)
 ,PSum_eeDB20   = sum(DS.PSum_eeDB20)
 ,PSum_ndsDB20  = sum(DS.PSum_ndsDB20)
 ,PSum_excDB20  = sum(DS.PSum_excDB20)
 ,PayCR20       = sum(DS.PSum_eeCR20 + DS.PSum_ndsCR20 + DS.PSum_excCR20)
 ,PQuantityCR20 = sum(DS.PQuantityCR20)
 ,PSum_eeCR20   = sum(DS.PSum_eeCR20)
 ,PSum_ndsCR20  = sum(DS.PSum_ndsCR20)
 ,PSum_excCR20  = sum(DS.PSum_excCR20)
--16%
 ,Pay16         = sum(DS.PSum_ee16 + DS.PSum_nds16 + DS.PSum_exc16)
 ,PQuantity16   = sum(DS.PQuantity16)
 ,PSum_ee16     = sum(DS.PSum_ee16)
 ,PSum_nds16    = sum(DS.PSum_nds16)
 ,PSum_exc16    = sum(DS.PSum_exc16)
 ,PayDB16       = sum(DS.PSum_eeDB16 + DS.PSum_ndsDB16 + DS.PSum_excDB16)
 ,PQuantityDB16 = sum(DS.PQuantityDB16)
 ,PSum_eeDB16   = sum(DS.PSum_eeDB16)
 ,PSum_ndsDB16  = sum(DS.PSum_ndsDB16)
 ,PSum_excDB16  = sum(DS.PSum_excDB16)
 ,PayCR16       = sum(DS.PSum_eeCR16 + DS.PSum_ndsCR16 + DS.PSum_excCR16)
 ,PQuantityCR16 = sum(DS.PQuantityCR16)
 ,PSum_eeCR16   = sum(DS.PSum_eeCR16)
 ,PSum_ndsCR16  = sum(DS.PSum_ndsCR16)
 ,PSum_excCR16  = sum(DS.PSum_excCR16)
--15%
 ,Pay15         = sum(DS.PSum_ee15 + DS.PSum_nds15 + DS.PSum_exc15)
 ,PQuantity15   = sum(DS.PQuantity15)
 ,PSum_ee15     = sum(DS.PSum_ee15)
 ,PSum_nds15    = sum(DS.PSum_nds15)
 ,PSum_exc15    = sum(DS.PSum_exc15)
 ,PayDB15       = sum(DS.PSum_eeDB15 + DS.PSum_ndsDB15 + DS.PSum_excDB15)
 ,PQuantityDB15 = sum(DS.PQuantityDB15)
 ,PSum_eeDB15   = sum(DS.PSum_eeDB15)
 ,PSum_ndsDB15  = sum(DS.PSum_ndsDB15)
 ,PSum_excDB15  = sum(DS.PSum_excDB15)
 ,PayCR15       = sum(DS.PSum_eeCR15 + DS.PSum_ndsCR15 + DS.PSum_excCR15)
 ,PQuantityCR15 = sum(DS.PQuantityCR15)
 ,PSum_eeCR15   = sum(DS.PSum_eeCR15)
 ,PSum_ndsCR15  = sum(DS.PSum_ndsCR15)
 ,PSum_excCR15  = sum(DS.PSum_excCR15)

 ,ERES=
    CASE
      WHEN (Cs.GROUP_ID=10011 AND Cs.SUBGROUP_ID=9) THEN
        ' РЭС-'+Right(Str(Cs.GROUP_ID),1)+' в т.ч. РП-41'
      WHEN (Cs.GROUP_ID=10011 AND Cs.SUBGROUP_ID=7) OR 
           (Cs.GROUP_ID=10012 AND Cs.SUBGROUP_ID=6) OR
           (Cs.GROUP_ID=10014 AND Cs.SUBGROUP_ID=5) OR 
           (Cs.GROUP_ID=10015 AND Cs.SUBGROUP_ID=8) OR 
           (Cs.GROUP_ID=10017 AND Cs.SUBGROUP_ID=6) THEN
        'Всего СЭПУ'
      WHEN Cs.GROUP_ID=10015 AND Cs.ADD_COST_TAX=0 THEN
        ' РЭС-'+Right(Str(Cs.GROUP_ID),1)+' в т.ч. б/НДС'
    END
 ,ESaldo20      = sum(DS.ESum_ee20 + DS.ESum_nds20 + DS.ESum_exc20)
 ,EQuantity20   = sum(DS.EQuantity20)
 ,ESum_ee20     = sum(DS.ESum_ee20)
 ,ESum_nds20    = sum(DS.ESum_nds20)
 ,ESum_exc20    = sum(DS.ESum_exc20)
 ,ESaldoDB20    = sum(DS.ESum_eeDB20 + DS.ESum_ndsDB20 + DS.ESum_excDB20)
 ,EQuantityDB20 = sum(DS.EQuantityDB20)
 ,ESum_eeDB20   = sum(DS.ESum_eeDB20)
 ,ESum_ndsDB20  = sum(DS.ESum_ndsDB20)
 ,ESum_excDB20  = sum(DS.ESum_excDB20)
 ,ESaldoCR20    = sum(DS.ESum_eeCR20 + DS.ESum_ndsCR20 + DS.ESum_excCR20)
 ,EQuantityCR20 = sum(DS.EQuantityCR20)
 ,ESum_eeCR20   = sum(DS.ESum_eeCR20)
 ,ESum_ndsCR20  = sum(DS.ESum_ndsCR20)
 ,ESum_excCR20  = sum(DS.ESum_excCR20)
--16%
 ,ESaldo16      = sum(DS.ESum_ee16 + DS.ESum_nds16 + DS.ESum_exc16)
 ,EQuantity16   = sum(DS.EQuantity16)
 ,ESum_ee16     = sum(DS.ESum_ee16)
 ,ESum_nds16    = sum(DS.ESum_nds16)
 ,ESum_exc16    = sum(DS.ESum_exc16)
 ,ESaldoDB16    = sum(DS.ESum_eeDB16 + DS.ESum_ndsDB16 + DS.ESum_excDB16)
 ,EQuantityDB16 = sum(DS.EQuantityDB16)
 ,ESum_eeDB16   = sum(DS.ESum_eeDB16)
 ,ESum_ndsDB16  = sum(DS.ESum_ndsDB16)
 ,ESum_excDB16  = sum(DS.ESum_excDB16)
 ,ESaldoCR16    = sum(DS.ESum_eeCR16 + DS.ESum_ndsCR16 + DS.ESum_excCR16)
 ,EQuantityCR16 = sum(DS.EQuantityCR16)
 ,ESum_eeCR16   = sum(DS.ESum_eeCR16)
 ,ESum_ndsCR16  = sum(DS.ESum_ndsCR16)
 ,ESum_excCR16  = sum(DS.ESum_excCR16)
--15%
 ,ESaldo15      = sum(DS.ESum_ee15 + DS.ESum_nds15 + DS.ESum_exc15)
 ,EQuantity15   = sum(DS.EQuantity15)
 ,ESum_ee15     = sum(DS.ESum_ee15)
 ,ESum_nds15    = sum(DS.ESum_nds15)
 ,ESum_exc15    = sum(DS.ESum_exc15)
 ,ESaldoDB15    = sum(DS.ESum_eeDB15 + DS.ESum_ndsDB15 + DS.ESum_excDB15)
 ,EQuantityDB15 = sum(DS.EQuantityDB15)
 ,ESum_eeDB15   = sum(DS.ESum_eeDB15)
 ,ESum_ndsDB15  = sum(DS.ESum_ndsDB15)
 ,ESum_excDB15  = sum(DS.ESum_excDB15)
 ,ESaldoCR15    = sum(DS.ESum_eeCR15 + DS.ESum_ndsCR15 + DS.ESum_excCR15)
 ,EQuantityCR15 = sum(DS.EQuantityCR15)
 ,ESum_eeCR15   = sum(DS.ESum_eeCR15)
 ,ESum_ndsCR15  = sum(DS.ESum_ndsCR15)
 ,ESum_excCR15  = sum(DS.ESum_excCR15)

 FROM
  ProContracts     Cs (NoLock),
  #TmpProDivSal    DS (NoLock)
 WHERE
  DS.CONTRACT_ID=Cs.CONTRACT_ID AND
  (((Cs.GROUP_ID=10011 AND Cs.SUBGROUP_ID=7) OR 
    (Cs.GROUP_ID=10012 AND Cs.SUBGROUP_ID=6) OR
    (Cs.GROUP_ID=10014 AND Cs.SUBGROUP_ID=5) OR 
    (Cs.GROUP_ID=10015 AND Cs.SUBGROUP_ID=8) OR 
    (Cs.GROUP_ID=10017 AND Cs.SUBGROUP_ID=6)) OR
   (Cs.GROUP_ID=10015 AND Cs.ADD_COST_TAX=0) OR
   (Cs.GROUP_ID=10011 AND Cs.SUBGROUP_ID=9))
 GROUP BY
  CASE
    WHEN (Cs.GROUP_ID=10011 AND Cs.SUBGROUP_ID=9) THEN
        ' РЭС-'+Right(Str(Cs.GROUP_ID),1)+' в т.ч. РП-41'
    WHEN (Cs.GROUP_ID=10011 AND Cs.SUBGROUP_ID=7) OR 
         (Cs.GROUP_ID=10012 AND Cs.SUBGROUP_ID=6) OR
         (Cs.GROUP_ID=10014 AND Cs.SUBGROUP_ID=5) OR 
         (Cs.GROUP_ID=10015 AND Cs.SUBGROUP_ID=8) OR 
         (Cs.GROUP_ID=10017 AND Cs.SUBGROUP_ID=6) THEN
      'Всего СЭПУ'
    WHEN Cs.GROUP_ID=10015 AND Cs.ADD_COST_TAX=0 THEN
      ' РЭС-'+Right(Str(Cs.GROUP_ID),1)+' в т.ч. б/НДС'
  END    

------------------------------------UNION 2 --------------------------------
 UNION SELECT
  BRES='ИТОГО:'
--20%
 ,BSaldo20       = sum(DS.BSum_ee20 + DS.Bsum_nds20 + DS.BSum_exc20)
 ,BQuantity20    = sum(DS.BQuantity20)
 ,BSum_ee20      = sum(DS.BSum_ee20)
 ,BSum_nds20     = sum(DS.BSum_nds20)
 ,BSum_exc20     = sum(DS.BSum_exc20)
 ,BSaldoDB20     = sum(DS.BSum_eeDB20 + DS.Bsum_ndsDB20 + DS.BSum_excDB20)
 ,BQuantityDB20  = sum(DS.BQuantityDB20)
 ,BSum_eeDB20    = sum(DS.BSum_eeDB20)
 ,BSum_ndsDB20   = sum(DS.BSum_ndsDB20)
 ,BSum_excDB20   = sum(DS.BSum_excDB20)
 ,BSaldoCR20     = sum(DS.BSum_eeCR20 + DS.Bsum_ndsCR20 + DS.BSum_excCR20)
 ,BQuantityCR20  = sum(DS.BQuantityCR20)
 ,BSum_eeCR20    = sum(DS.BSum_eeCR20)
 ,BSum_ndsCR20   = sum(DS.BSum_ndsCR20)
 ,BSum_excCR20   = sum(DS.BSum_excCR20)
--16%
 ,BSaldo16       = sum(DS.BSum_ee16 + DS.Bsum_nds16 + DS.BSum_exc16)
 ,BQuantity16    = sum(DS.BQuantity16)
 ,BSum_ee16      = sum(DS.BSum_ee16)
 ,BSum_nds16     = sum(DS.BSum_nds16)
 ,BSum_exc16     = sum(DS.BSum_exc16)
 ,BSaldoDB16     = sum(DS.BSum_eeDB16 + DS.Bsum_ndsDB16 + DS.BSum_excDB16)
 ,BQuantityDB16  = sum(DS.BQuantityDB16)
 ,BSum_eeDB16    = sum(DS.BSum_eeDB16)
 ,BSum_ndsDB16   = sum(DS.BSum_ndsDB16)
 ,BSum_excDB16   = sum(DS.BSum_excDB16)
 ,BSaldoCR16     = sum(DS.BSum_eeCR16 + DS.Bsum_ndsCR16 + DS.BSum_excCR16)
 ,BQuantityCR16  = sum(DS.BQuantityCR16)
 ,BSum_eeCR16    = sum(DS.BSum_eeCR16)
 ,BSum_ndsCR16   = sum(DS.BSum_ndsCR16)
 ,BSum_excCR16   = sum(DS.BSum_excCR16)
--15%
 ,BSaldo15       = sum(DS.BSum_ee15 + DS.Bsum_nds15 + DS.BSum_exc15)
 ,BQuantity15    = sum(DS.BQuantity15)
 ,BSum_ee15      = sum(DS.BSum_ee15)
 ,BSum_nds15     = sum(DS.BSum_nds15)
 ,BSum_exc15     = sum(DS.BSum_exc15)
 ,BSaldoDB15     = sum(DS.BSum_eeDB15 + DS.Bsum_ndsDB15 + DS.BSum_excDB15)
 ,BQuantityDB15  = sum(DS.BQuantityDB15)
 ,BSum_eeDB15    = sum(DS.BSum_eeDB15)
 ,BSum_ndsDB15   = sum(DS.BSum_ndsDB15)
 ,BSum_excDB15   = sum(DS.BSum_excDB15)
 ,BSaldoCR15     = sum(DS.BSum_eeCR15 + DS.Bsum_ndsCR15 + DS.BSum_excCR15)
 ,BQuantityCR15  = sum(DS.BQuantityCR15)
 ,BSum_eeCR15    = sum(DS.BSum_eeCR15)
 ,BSum_ndsCR15   = sum(DS.BSum_ndsCR15)
 ,BSum_excCR15  = sum(DS.BSum_excCR15)

 ,NRES='ИТОГО:'
 ,Nach20        = sum(DS.NSum_ee20 + DS.NSum_nds20 + DS.NSum_exc20)
 ,NQuantity20   = sum(DS.NQUANTITY20)
 ,NSum_ee20     = sum(DS.NSum_ee20)
 ,NSum_nds20    = sum(DS.NSum_nds20)
 ,NSUM_exc20    = sum(DS.NSum_exc20)
 ,NachDB20      = sum(DS.NSum_eeDB20 + DS.NSum_ndsDB20 + DS.NSum_excDB20)
 ,NQuantityDB20 = sum(DS.NQuantityDB20)
 ,NSum_eeDB20   = sum(DS.NSum_eeDB20)
 ,NSum_ndsDB20  = sum(DS.NSum_ndsDB20)
 ,NSUM_excDB20  = sum(DS.NSum_excDB20)
 ,NachCR20      = sum(DS.NSum_eeCR20 + DS.NSum_ndsCR20 + DS.NSum_excCR20)
 ,NQuantityCR20 = sum(DS.NQuantityCR20)
 ,NSum_eeCR20   = sum(DS.NSum_eeCR20)
 ,NSum_ndsCR20  = sum(DS.NSum_ndsCR20)
 ,NSUM_excCR20  = sum(DS.NSum_excCR20)
--16%
 ,Nach16        = sum(DS.NSum_ee16 + DS.NSum_nds16 + DS.NSum_exc16)
 ,NQuantity16   = sum(DS.NQUANTITY16)
 ,NSum_ee16     = sum(DS.NSum_ee16)
 ,NSum_nds16    = sum(DS.NSum_nds16)
 ,NSUM_exc16    = sum(DS.NSum_exc16)
 ,NachDB16      = sum(DS.NSum_eeDB16 + DS.NSum_ndsDB16 + DS.NSum_excDB16)
 ,NQuantityDB16 = sum(DS.NQuantityDB16)
 ,NSum_eeDB16   = sum(DS.NSum_eeDB16)
 ,NSum_ndsDB16  = sum(DS.NSum_ndsDB16)
 ,NSUM_excDB16  = sum(DS.NSum_excDB16)
 ,NachCR16      = sum(DS.NSum_eeCR16 + DS.NSum_ndsCR16 + DS.NSum_excCR16)
 ,NQuantityCR16 = sum(DS.NQuantityCR16)
 ,NSum_eeCR16   = sum(DS.NSum_eeCR16)
 ,NSum_ndsCR16  = sum(DS.NSum_ndsCR16)
 ,NSUM_excCR16  = sum(DS.NSum_excCR16)
--15%
 ,Nach15        = sum(DS.NSum_ee15 + DS.NSum_nds15 + DS.NSum_exc15)
 ,NQuantity15   = sum(DS.NQUANTITY15)
 ,NSum_ee15     = sum(DS.NSum_ee15)
 ,NSum_nds15    = sum(DS.NSum_nds15)
 ,NSUM_exc15    = sum(DS.NSum_exc15)
 ,NachDB15      = sum(DS.NSum_eeDB15 + DS.NSum_ndsDB15 + DS.NSum_excDB15)
 ,NQuantityDB15 = sum(DS.NQuantityDB15)
 ,NSum_eeDB15   = sum(DS.NSum_eeDB15)
 ,NSum_ndsDB15  = sum(DS.NSum_ndsDB15)
 ,NSUM_excDB15  = sum(DS.NSum_excDB15)
 ,NachCR15      = sum(DS.NSum_eeCR15 + DS.NSum_ndsCR15 + DS.NSum_excCR15)
 ,NQuantityCR15 = sum(DS.NQuantityCR15)
 ,NSum_eeCR15   = sum(DS.NSum_eeCR15)
 ,NSum_ndsCR15  = sum(DS.NSum_ndsCR15)
 ,NSUM_excCR15  = sum(DS.NSum_excCR15)

 ,PRES='ИТОГО:'
 ,Pay20         = sum(DS.PSum_ee20 + DS.PSum_nds20 + DS.PSum_exc20)
 ,PQuantity20   = sum(DS.PQuantity20)
 ,PSum_ee20     = sum(DS.PSum_ee20)
 ,PSum_nds20    = sum(DS.PSum_nds20)
 ,PSum_exc20    = sum(DS.PSum_exc20)
 ,PayDB20       = sum(DS.PSum_eeDB20 + DS.PSum_ndsDB20 + DS.PSum_excDB20)
 ,PQuantityDB20 = sum(DS.PQuantityDB20)
 ,PSum_eeDB20   = sum(DS.PSum_eeDB20)
 ,PSum_ndsDB20  = sum(DS.PSum_ndsDB20)
 ,PSum_excDB20  = sum(DS.PSum_excDB20)
 ,PayCR20       = sum(DS.PSum_eeCR20 + DS.PSum_ndsCR20 + DS.PSum_excCR20)
 ,PQuantityCR20 = sum(DS.PQuantityCR20)
 ,PSum_eeCR20   = sum(DS.PSum_eeCR20)
 ,PSum_ndsCR20  = sum(DS.PSum_ndsCR20)
 ,PSum_excCR20  = sum(DS.PSum_excCR20)
--16%
 ,Pay16         = sum(DS.PSum_ee16 + DS.PSum_nds16 + DS.PSum_exc16)
 ,PQuantity16   = sum(DS.PQuantity16)
 ,PSum_ee16     = sum(DS.PSum_ee16)
 ,PSum_nds16    = sum(DS.PSum_nds16)
 ,PSum_exc16    = sum(DS.PSum_exc16)
 ,PayDB16       = sum(DS.PSum_eeDB16 + DS.PSum_ndsDB16 + DS.PSum_excDB16)
 ,PQuantityDB16 = sum(DS.PQuantityDB16)
 ,PSum_eeDB16   = sum(DS.PSum_eeDB16)
 ,PSum_ndsDB16  = sum(DS.PSum_ndsDB16)
 ,PSum_excDB16  = sum(DS.PSum_excDB16)
 ,PayCR16       = sum(DS.PSum_eeCR16 + DS.PSum_ndsCR16 + DS.PSum_excCR16)
 ,PQuantityCR16 = sum(DS.PQuantityCR16)
 ,PSum_eeCR16   = sum(DS.PSum_eeCR16)
 ,PSum_ndsCR16  = sum(DS.PSum_ndsCR16)
 ,PSum_excCR16  = sum(DS.PSum_excCR16)
--15%
 ,Pay15         = sum(DS.PSum_ee15 + DS.PSum_nds15 + DS.PSum_exc15)
 ,PQuantity15   = sum(DS.PQuantity15)
 ,PSum_ee15     = sum(DS.PSum_ee15)
 ,PSum_nds15    = sum(DS.PSum_nds15)
 ,PSum_exc15    = sum(DS.PSum_exc15)
 ,PayDB15       = sum(DS.PSum_eeDB15 + DS.PSum_ndsDB15 + DS.PSum_excDB15)
 ,PQuantityDB15 = sum(DS.PQuantityDB15)
 ,PSum_eeDB15   = sum(DS.PSum_eeDB15)
 ,PSum_ndsDB15  = sum(DS.PSum_ndsDB15)
 ,PSum_excDB15  = sum(DS.PSum_excDB15)
 ,PayCR15       = sum(DS.PSum_eeCR15 + DS.PSum_ndsCR15 + DS.PSum_excCR15)
 ,PQuantityCR15 = sum(DS.PQuantityCR15)
 ,PSum_eeCR15   = sum(DS.PSum_eeCR15)
 ,PSum_ndsCR15  = sum(DS.PSum_ndsCR15)
 ,PSum_excCR15  = sum(DS.PSum_excCR15)

 ,ERES='ИТОГО:'
 ,ESaldo20      = sum(DS.ESum_ee20 + DS.ESum_nds20 + DS.ESum_exc20)
 ,EQuantity20   = sum(DS.EQuantity20)
 ,ESum_ee20     = sum(DS.ESum_ee20)
 ,ESum_nds20    = sum(DS.ESum_nds20)
 ,ESum_exc20    = sum(DS.ESum_exc20)
 ,ESaldoDB20    = sum(DS.ESum_eeDB20 + DS.ESum_ndsDB20 + DS.ESum_excDB20)
 ,EQuantityDB20 = sum(DS.EQuantityDB20)
 ,ESum_eeDB20   = sum(DS.ESum_eeDB20)
 ,ESum_ndsDB20  = sum(DS.ESum_ndsDB20)
 ,ESum_excDB20  = sum(DS.ESum_excDB20)
 ,ESaldoCR20    = sum(DS.ESum_eeCR20 + DS.ESum_ndsCR20 + DS.ESum_excCR20)
 ,EQuantityCR20 = sum(DS.EQuantityCR20)
 ,ESum_eeCR20   = sum(DS.ESum_eeCR20)
 ,ESum_ndsCR20  = sum(DS.ESum_ndsCR20)
 ,ESum_excCR20  = sum(DS.ESum_excCR20)
--16%
 ,ESaldo16      = sum(DS.ESum_ee16 + DS.ESum_nds16 + DS.ESum_exc16)
 ,EQuantity16   = sum(DS.EQuantity16)
 ,ESum_ee16     = sum(DS.ESum_ee16)
 ,ESum_nds16    = sum(DS.ESum_nds16)
 ,ESum_exc16    = sum(DS.ESum_exc16)
 ,ESaldoDB16    = sum(DS.ESum_eeDB16 + DS.ESum_ndsDB16 + DS.ESum_excDB16)
 ,EQuantityDB16 = sum(DS.EQuantityDB16)
 ,ESum_eeDB16   = sum(DS.ESum_eeDB16)
 ,ESum_ndsDB16  = sum(DS.ESum_ndsDB16)
 ,ESum_excDB16  = sum(DS.ESum_excDB16)
 ,ESaldoCR16    = sum(DS.ESum_eeCR16 + DS.ESum_ndsCR16 + DS.ESum_excCR16)
 ,EQuantityCR16 = sum(DS.EQuantityCR16)
 ,ESum_eeCR16   = sum(DS.ESum_eeCR16)
 ,ESum_ndsCR16  = sum(DS.ESum_ndsCR16)
 ,ESum_excCR16  = sum(DS.ESum_excCR16)
--15%
 ,ESaldo15      = sum(DS.ESum_ee15 + DS.ESum_nds15 + DS.ESum_exc15)
 ,EQuantity15   = sum(DS.EQuantity15)
 ,ESum_ee15     = sum(DS.ESum_ee15)
 ,ESum_nds15    = sum(DS.ESum_nds15)
 ,ESum_exc15    = sum(DS.ESum_exc15)
 ,ESaldoDB15    = sum(DS.ESum_eeDB15 + DS.ESum_ndsDB15 + DS.ESum_excDB15)
 ,EQuantityDB15 = sum(DS.EQuantityDB15)
 ,ESum_eeDB15   = sum(DS.ESum_eeDB15)
 ,ESum_ndsDB15  = sum(DS.ESum_ndsDB15)
 ,ESum_excDB15  = sum(DS.ESum_excDB15)
 ,ESaldoCR15    = sum(DS.ESum_eeCR15 + DS.ESum_ndsCR15 + DS.ESum_excCR15)
 ,EQuantityCR15 = sum(DS.EQuantityCR15)
 ,ESum_eeCR15   = sum(DS.ESum_eeCR15)
 ,ESum_ndsCR15  = sum(DS.ESum_ndsCR15)
 ,ESum_excCR15  = sum(DS.ESum_excCR15)

 FROM
  ProContracts  Cs (NoLock),
  #TmpProDivSal DS (NoLock)
 WHERE
  DS.CONTRACT_ID=Cs.CONTRACT_ID 
 ORDER BY
  BRES

drop table #TmpProDivSal

