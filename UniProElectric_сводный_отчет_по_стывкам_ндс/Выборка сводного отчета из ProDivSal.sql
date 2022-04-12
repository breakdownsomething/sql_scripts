-- Сей отчет проверен и сходится со старым отчетом,
-- который выбирался из старой таблицы ProDivSaldo (ныне почти покойной)

declare
   @DateCalc datetime
select
   @DateCalc = '2004-02-29'

--- Формирование временной таблицы
if Exists (select * from TempDB..SysObjects
           where id = OBJECT_ID('TempDB..#TmpProDivSal'))
exec('DROP TABLE #TmpProDivSal')

select
  Contract_id = PDS.Contract_id
 ,Nds_tax     = PDS.Nds_tax
-- Сальдо на начало------------------------------------------------------
 ,BQuantity   = convert(int,IsNull(PDS.BQuantity,0))
 ,BSum_ee     = convert(decimal(18,2),IsNull(PDS.BSum_ee,0))
 ,BSum_nds    = convert(decimal(18,2),IsNull(PDS.BSum_nds,0)) 
 ,BSum_exc    = convert(decimal(18,2),IsNull(PDS.BSum_exc,0))
 ,BQuantityDB = case when (select Isnull(sum(P.BSum_ee + P.BSum_nds + P.BSum_exc),0)
                           from ProDivSal P (nolock)
                           where P.Contract_id = PDS.Contract_id
                             and P.date_calc = @DateCalc) > 0
                     then convert(int,IsNull(PDS.BQuantity,0))
                     else convert(int,0) end
 ,BSum_eeDB   = case when (select Isnull(sum(P.BSum_ee + P.BSum_nds + P.BSum_exc),0)
                           from ProDivSal P (nolock)
                           where P.Contract_id = PDS.Contract_id
                             and P.date_calc = @DateCalc) > 0
                     then convert(decimal(18,2),IsNull(PDS.BSum_ee,0))
                     else convert(decimal(18,2),0) end
 ,BSum_ndsDB  = case when (select Isnull(sum(P.BSum_ee + P.BSum_nds + P.BSum_exc),0)
                           from ProDivSal P (nolock)
                           where P.Contract_id = PDS.Contract_id
                             and P.date_calc = @DateCalc) > 0
                     then convert(decimal(18,2),IsNull(PDS.BSum_nds,0))
                     else convert(decimal(18,2),0) end
 ,BSum_excDB  = case when (select Isnull(sum(P.BSum_ee + P.BSum_nds + P.BSum_exc),0)
                           from ProDivSal P (nolock)
                           where P.Contract_id = PDS.Contract_id
                             and P.date_calc = @DateCalc) > 0
                     then convert(decimal(18,2),IsNull(PDS.BSum_exc,0))
                     else convert(decimal(18,2),0) end
 ,BQuantityCR = case when (select Isnull(sum(P.BSum_ee + P.BSum_nds + P.BSum_exc),0)
                           from ProDivSal P (nolock)
                           where P.Contract_id = PDS.Contract_id
                             and P.date_calc = @DateCalc) <= 0
                     then convert(int,IsNull(PDS.BQuantity,0))
                     else convert(int,0) end
 ,BSum_eeCR   = case when (select Isnull(sum(P.BSum_ee + P.BSum_nds + P.BSum_exc),0)
                           from ProDivSal P (nolock)
                           where P.Contract_id = PDS.Contract_id
                             and P.date_calc = @DateCalc) <= 0
                     then convert(decimal(18,2),IsNull(PDS.BSum_ee,0))
                     else convert(decimal(18,2),0) end
 ,BSum_ndsCR  = case when (select Isnull(sum(P.BSum_ee + P.BSum_nds + P.BSum_exc),0)
                           from ProDivSal P (nolock)
                           where P.Contract_id = PDS.Contract_id
                             and P.date_calc = @DateCalc) <= 0
                     then convert(decimal(18,2),IsNull(PDS.BSum_nds,0))
                     else convert(decimal(18,2),0) end
 ,BSum_excCR  = case when (select Isnull(sum(P.BSum_ee + P.BSum_nds + P.BSum_exc),0)
                           from ProDivSal P (nolock)
                           where P.Contract_id = PDS.Contract_id
                             and P.date_calc = @DateCalc) <= 0
                     then convert(decimal(18,2),IsNull(PDS.BSum_exc,0))
                     else convert(decimal(18,2),0) end
-- Начисления-----------------------------------------------------
 ,NQuantity   = convert(int,IsNull(PDS.NQuantity,0))
 ,NSum_ee     = convert(decimal(18,2),IsNull(PDS.NSum_ee,0))
 ,NSum_nds    = convert(decimal(18,2),IsNull(PDS.NSum_nds,0)) 
 ,NSum_exc    = convert(decimal(18,2),IsNull(PDS.NSum_exc,0))
 ,NQuantityDB = case when (select Isnull(sum(P.NSum_ee + P.NSum_nds + P.NSum_exc),0)
                           from ProDivSal P (nolock)
                           where P.Contract_id = PDS.Contract_id
                             and P.date_calc = @DateCalc) > 0
                     then convert(int,IsNull(PDS.NQuantity,0))
                     else convert(int,0) end
 ,NSum_eeDB   = case when (select Isnull(sum(P.NSum_ee + P.NSum_nds + P.NSum_exc),0)
                           from ProDivSal P (nolock)
                           where P.Contract_id = PDS.Contract_id
                             and P.date_calc = @DateCalc) > 0
                     then convert(decimal(18,2),IsNull(PDS.NSum_ee,0))
                     else convert(decimal(18,2),0) end
 ,NSum_ndsDB  = case when (select Isnull(sum(P.NSum_ee + P.NSum_nds + P.NSum_exc),0)
                           from ProDivSal P (nolock)
                           where P.Contract_id = PDS.Contract_id
                             and P.date_calc = @DateCalc) > 0
                     then convert(decimal(18,2),IsNull(PDS.NSum_nds,0))
                     else convert(decimal(18,2),0) end
 ,NSum_excDB  = case when (select Isnull(sum(P.NSum_ee + P.NSum_nds + P.NSum_exc),0)
                           from ProDivSal P (nolock)
                           where P.Contract_id = PDS.Contract_id
                             and P.date_calc = @DateCalc) > 0
                     then convert(decimal(18,2),IsNull(PDS.NSum_exc,0))
                     else convert(decimal(18,2),0) end
 ,NQuantityCR = case when (select Isnull(sum(P.NSum_ee + P.NSum_nds + P.NSum_exc),0)
                           from ProDivSal P (nolock)
                           where P.Contract_id = PDS.Contract_id
                             and P.date_calc = @DateCalc) <= 0
                     then convert(int,IsNull(PDS.NQuantity,0))
                     else convert(int,0) end
 ,NSum_eeCR   = case when (select Isnull(sum(P.NSum_ee + P.NSum_nds + P.NSum_exc),0)
                           from ProDivSal P (nolock)
                           where P.Contract_id = PDS.Contract_id
                             and P.date_calc = @DateCalc) <= 0
                     then convert(decimal(18,2),IsNull(PDS.NSum_ee,0))
                     else convert(decimal(18,2),0) end
 ,NSum_ndsCR  = case when (select Isnull(sum(P.NSum_ee + P.NSum_nds + P.NSum_exc),0)
                           from ProDivSal P (nolock)
                           where P.Contract_id = PDS.Contract_id
                             and P.date_calc = @DateCalc) <= 0
                     then convert(decimal(18,2),IsNull(PDS.NSum_nds,0))
                     else convert(decimal(18,2),0) end
 ,NSum_excCR  = case when (select Isnull(sum(P.NSum_ee + P.NSum_nds + P.NSum_exc),0)
                           from ProDivSal P (nolock)
                           where P.Contract_id = PDS.Contract_id
                             and P.date_calc = @DateCalc) <= 0
                     then convert(decimal(18,2),IsNull(PDS.NSum_exc,0))
                     else convert(decimal(18,2),0) end
--Платежи-----------------------------------------------------------------------
 ,PQuantity   = convert(int,IsNull(PDS.PQuantity,0))
 ,PSum_ee     = convert(decimal(18,2),IsNull(PDS.PSum_ee,0))
 ,PSum_nds    = convert(decimal(18,2),IsNull(PDS.PSum_nds,0)) 
 ,PSum_exc    = convert(decimal(18,2),IsNull(PDS.PSum_exc,0))
 ,PQuantityDB = case when (select Isnull(sum(P.PSum_ee + P.PSum_nds + P.PSum_exc),0)
                           from ProDivSal P (nolock)
                           where P.Contract_id = PDS.Contract_id
                             and P.date_calc = @DateCalc) > 0
                     then convert(int,IsNull(PDS.PQuantity,0))
                     else convert(int,0) end
 ,PSum_eeDB   = case when (select Isnull(sum(P.PSum_ee + P.PSum_nds + P.PSum_exc),0)
                           from ProDivSal P (nolock)
                           where P.Contract_id = PDS.Contract_id
                             and P.date_calc = @DateCalc) > 0
                     then convert(decimal(18,2),IsNull(PDS.PSum_ee,0))
                     else convert(decimal(18,2),0) end
 ,PSum_ndsDB  = case when (select Isnull(sum(P.PSum_ee + P.PSum_nds + P.PSum_exc),0)
                           from ProDivSal P (nolock)
                           where P.Contract_id = PDS.Contract_id
                             and P.date_calc = @DateCalc) > 0
                     then convert(decimal(18,2),IsNull(PDS.PSum_nds,0))
                     else convert(decimal(18,2),0) end
 ,PSum_excDB  = case when (select Isnull(sum(P.PSum_ee + P.PSum_nds + P.PSum_exc),0)
                           from ProDivSal P (nolock)
                           where P.Contract_id = PDS.Contract_id
                             and P.date_calc = @DateCalc) > 0
                     then convert(decimal(18,2),IsNull(PDS.PSum_exc,0))
                     else convert(decimal(18,2),0) end
 ,PQuantityCR = case when (select Isnull(sum(P.PSum_ee + P.PSum_nds + P.PSum_exc),0)
                           from ProDivSal P (nolock)
                           where P.Contract_id = PDS.Contract_id
                             and P.date_calc = @DateCalc) <= 0
                     then convert(int,IsNull(PDS.PQuantity,0))
                     else convert(int,0) end
 ,PSum_eeCR   = case when (select Isnull(sum(P.PSum_ee + P.PSum_nds + P.PSum_exc),0)
                           from ProDivSal P (nolock)
                           where P.Contract_id = PDS.Contract_id
                             and P.date_calc = @DateCalc) <= 0
                     then convert(decimal(18,2),IsNull(PDS.PSum_ee,0))
                     else convert(decimal(18,2),0) end
 ,PSum_ndsCR  = case when (select Isnull(sum(P.PSum_ee + P.PSum_nds + P.PSum_exc),0)
                           from ProDivSal P (nolock)
                           where P.Contract_id = PDS.Contract_id
                             and P.date_calc = @DateCalc) <= 0
                     then convert(decimal(18,2),IsNull(PDS.PSum_nds,0))
                     else convert(decimal(18,2),0) end
 ,PSum_excCR  = case when (select Isnull(sum(P.PSum_ee + P.PSum_nds + P.PSum_exc),0)
                           from ProDivSal P (nolock)
                           where P.Contract_id = PDS.Contract_id
                             and P.date_calc = @DateCalc) <= 0
                     then convert(decimal(18,2),IsNull(PDS.PSum_exc,0))
                     else convert(decimal(18,2),0) end

--Сальдо на конец-------------------------------------------
 ,EQuantity   = convert(int,IsNull(PDS.EQuantity,0))
 ,ESum_ee     = convert(decimal(18,2),IsNull(PDS.ESum_ee,0))
 ,ESum_nds    = convert(decimal(18,2),IsNull(PDS.ESum_nds,0)) 
 ,ESum_exc    = convert(decimal(18,2),IsNull(PDS.ESum_exc,0))
 ,EQuantityDB = case when (select Isnull(sum(P.ESum_ee + P.ESum_nds + P.ESum_exc),0)
                           from ProDivSal P (nolock)
                           where P.Contract_id = PDS.Contract_id
                             and P.date_calc = @DateCalc) > 0
                     then convert(int,IsNull(PDS.EQuantity,0))
                     else convert(int,0) end
 ,ESum_eeDB   = case when (select Isnull(sum(P.ESum_ee + P.ESum_nds + P.ESum_exc),0)
                           from ProDivSal P (nolock)
                           where P.Contract_id = PDS.Contract_id
                             and P.date_calc = @DateCalc) > 0
                     then convert(decimal(18,2),IsNull(PDS.ESum_ee,0))
                     else convert(decimal(18,2),0) end
 ,ESum_ndsDB  = case when (select Isnull(sum(P.ESum_ee + P.ESum_nds + P.ESum_exc),0)
                           from ProDivSal P (nolock)
                           where P.Contract_id = PDS.Contract_id
                             and P.date_calc = @DateCalc) > 0
                     then convert(decimal(18,2),IsNull(PDS.ESum_nds,0))
                     else convert(decimal(18,2),0) end
 ,ESum_excDB  = case when (select Isnull(sum(P.ESum_ee + P.ESum_nds + P.ESum_exc),0)
                           from ProDivSal P (nolock)
                           where P.Contract_id = PDS.Contract_id
                             and P.date_calc = @DateCalc) > 0
                     then convert(decimal(18,2),IsNull(PDS.ESum_exc,0))
                     else convert(decimal(18,2),0) end
 ,EQuantityCR = case when (select Isnull(sum(P.ESum_ee + P.ESum_nds + P.ESum_exc),0)
                           from ProDivSal P (nolock)
                           where P.Contract_id = PDS.Contract_id
                             and P.date_calc = @DateCalc) <= 0
                     then convert(int,IsNull(PDS.EQuantity,0))
                     else convert(int,0) end
 ,ESum_eeCR   = case when (select Isnull(sum(P.ESum_ee + P.ESum_nds + P.ESum_exc),0)
                           from ProDivSal P (nolock)
                           where P.Contract_id = PDS.Contract_id
                             and P.date_calc = @DateCalc) <= 0
                     then convert(decimal(18,2),IsNull(PDS.ESum_ee,0))
                     else convert(decimal(18,2),0) end
 ,ESum_ndsCR  = case when (select Isnull(sum(P.ESum_ee + P.ESum_nds + P.ESum_exc),0)
                           from ProDivSal P (nolock)
                           where P.Contract_id = PDS.Contract_id
                             and P.date_calc = @DateCalc) <= 0
                     then convert(decimal(18,2),IsNull(PDS.ESum_nds,0))
                     else convert(decimal(18,2),0) end
 ,ESum_excCR  = case when (select Isnull(sum(P.ESum_ee + P.ESum_nds + P.ESum_exc),0)
                           from ProDivSal P (nolock)
                           where P.Contract_id = PDS.Contract_id
                             and P.date_calc = @DateCalc) <= 0
                     then convert(decimal(18,2),IsNull(PDS.ESum_exc,0))
                     else convert(decimal(18,2),0) end
  into #TmpProDivSal
  from ProDivSal PDS (nolock)
  where Date_calc = @DateCalc
--   and nds_tax   = 16 

/*
-- debug code
select Contract_id
      ,Nds_tax
      ,Bsum_ee
      ,Bsum_eeDB
      ,Bsum_eeCR
      ,NSum_ee
      ,Nsum_eeDB
      ,Nsum_eeCR
      ,PSum_ee
      ,Psum_eeDB
      ,Psum_eeCR
      ,ESum_ee
      ,Esum_eeDB
      ,Esum_eeCR
from #TmpProDivSal
drop table #TmpProDivSal
*/
-- Основная выборка-----------------------------------------

-- сальдо на начало--------------------------------------
select
  BRes         = ' РЭС-'+Right(Str(Cs.GROUP_ID),1)
 ,BSaldo       = IsNull(sum(DS.BSum_ee + DS.Bsum_nds + DS.BSum_exc),0)
 ,BQuantity    = IsNull(sum(DS.BQuantity),0)
 ,BSum_ee      = IsNull(sum(DS.BSum_ee),0)
 ,BSum_nds     = IsNull(sum(DS.BSum_nds),0)
 ,BSum_exc     = IsNull(sum(DS.BSum_exc),0)
 ,BSaldoDB     = IsNull(sum(DS.BSum_eeDB + DS.Bsum_ndsDB + DS.BSum_excDB),0)
 ,BQuantityDB  = IsNull(sum(DS.BQuantityDB),0)
 ,BSum_eeDB    = IsNull(sum(DS.BSum_eeDB),0)
 ,BSum_ndsDB   = IsNull(sum(DS.BSum_ndsDB),0)
 ,BSum_excDB   = IsNull(sum(DS.BSum_excDB),0)
 ,BSaldoCR     = IsNull(sum(DS.BSum_eeCR + DS.Bsum_ndsCR + DS.BSum_excCR),0)
 ,BQuantityCR  = IsNull(sum(DS.BQuantityCR),0)
 ,BSum_eeCR    = IsNull(sum(DS.BSum_eeCR),0)
 ,BSum_ndsCR   = IsNull(sum(DS.BSum_ndsCR),0)
 ,BSum_excCR   = IsNull(sum(DS.BSum_excCR),0)
-- Начисления---------------------------------------------
 ,NRes        = ' РЭС-'+Right(Str(Cs.GROUP_ID),1)
 ,Nach        = IsNull(sum(DS.NSum_ee + DS.NSum_nds + DS.NSum_exc),0)
 ,NQuantity   = IsNull(sum(DS.NQUANTITY),0)
 ,NSum_ee     = IsNull(sum(DS.NSum_ee),0)
 ,NSum_nds    = IsNull(sum(DS.NSum_nds),0)
 ,NSUM_exc    = IsNull(sum(DS.NSum_exc),0)
 ,NachDB      = IsNull(sum(DS.NSum_eeDB + DS.NSum_ndsDB + DS.NSum_excDB),0)
 ,NQuantityDB = IsNull(sum(DS.NQuantityDB),0)
 ,NSum_eeDB   = IsNull(sum(DS.NSum_eeDB),0)
 ,NSum_ndsDB  = IsNull(sum(DS.NSum_ndsDB),0)
 ,NSUM_excDB  = IsNull(sum(DS.NSum_excDB),0)
 ,NachCR      = IsNull(sum(DS.NSum_eeCR + DS.NSum_ndsCR + DS.NSum_excCR),0)
 ,NQuantityCR = IsNull(sum(DS.NQuantityCR),0)
 ,NSum_eeCR   = IsNull(sum(DS.NSum_eeCR),0)
 ,NSum_ndsCR  = IsNull(sum(DS.NSum_ndsCR),0)
 ,NSUM_excCR  = IsNull(sum(DS.NSum_excCR),0)
--Платежи
 ,PRes        = ' РЭС-'+Right(Str(Cs.GROUP_ID),1)    
 ,Pay         = IsNull(sum(DS.PSum_ee + DS.PSum_nds + DS.PSum_exc),0)
 ,PQuantity   = IsNull(sum(DS.PQuantity),0)
 ,PSum_ee     = IsNull(sum(DS.PSum_ee),0)
 ,PSum_nds    = IsNull(sum(DS.PSum_nds),0)
 ,PSum_exc    = IsNull(sum(DS.PSum_exc),0)
 ,PayDB       = IsNull(sum(DS.PSum_eeDB + DS.PSum_ndsDB + DS.PSum_excDB),0)
 ,PQuantityDB = IsNull(sum(DS.PQuantityDB),0)
 ,PSum_eeDB   = IsNull(sum(DS.PSum_eeDB),0)
 ,PSum_ndsDB  = IsNull(sum(DS.PSum_ndsDB),0)
 ,PSum_excDB  = IsNull(sum(DS.PSum_excDB),0)
 ,PayCR       = IsNull(sum(DS.PSum_eeCR + DS.PSum_ndsCR + DS.PSum_excCR),0)
 ,PQuantityCR = IsNull(sum(DS.PQuantityCR),0)
 ,PSum_eeCR   = IsNull(sum(DS.PSum_eeCR),0)
 ,PSum_ndsCR  = IsNull(sum(DS.PSum_ndsCR),0)
 ,PSum_excCR  = IsNull(sum(DS.PSum_excCR),0)
--Сальдо на конец
 ,ERes        = ' РЭС-'+Right(Str(Cs.GROUP_ID),1)
 ,ESaldo      = IsNull(sum(DS.ESum_ee + DS.ESum_nds + DS.ESum_exc),0)
 ,EQuantity   = IsNull(sum(DS.EQuantity),0)
 ,ESum_ee     = IsNull(sum(DS.ESum_ee),0)
 ,ESum_nds    = IsNull(sum(DS.ESum_nds),0)
 ,ESum_exc    = IsNull(sum(DS.ESum_exc),0)
 ,ESaldoDB    = IsNull(sum(DS.ESum_eeDB + DS.ESum_ndsDB + DS.ESum_excDB),0)
 ,EQuantityDB = IsNull(sum(DS.EQuantityDB),0)
 ,ESum_eeDB   = IsNull(sum(DS.ESum_eeDB),0)
 ,ESum_ndsDB  = IsNull(sum(DS.ESum_ndsDB),0)
 ,ESum_excDB  = IsNull(sum(DS.ESum_excDB),0)
 ,ESaldoCR    = IsNull(sum(DS.ESum_eeCR + DS.ESum_ndsCR + DS.ESum_excCR),0)
 ,EQuantityCR = IsNull(sum(DS.EQuantityCR),0)
 ,ESum_eeCR   = IsNull(sum(DS.ESum_eeCR),0)
 ,ESum_ndsCR  = IsNull(sum(DS.ESum_ndsCR),0)
 ,ESum_excCR  = IsNull(sum(DS.ESum_excCR),0)
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
 ,BSaldo       = IsNull(sum(DS.BSum_ee + DS.Bsum_nds + DS.BSum_exc),0)
 ,BQuantity    = IsNull(sum(DS.BQuantity),0)
 ,BSum_ee      = IsNull(sum(DS.BSum_ee),0)
 ,BSum_nds     = IsNull(sum(DS.BSum_nds),0)
 ,BSum_exc     = IsNull(sum(DS.BSum_exc),0)
 ,BSaldoDB     = IsNull(sum(DS.BSum_eeDB + DS.Bsum_ndsDB + DS.BSum_excDB),0)
 ,BQuantityDB  = IsNull(sum(DS.BQuantityDB),0)
 ,BSum_eeDB    = IsNull(sum(DS.BSum_eeDB),0)
 ,BSum_ndsDB   = IsNull(sum(DS.BSum_ndsDB),0)
 ,BSum_excDB   = IsNull(sum(DS.BSum_excDB),0)
 ,BSaldoCR     = IsNull(sum(DS.BSum_eeCR + DS.Bsum_ndsCR + DS.BSum_excCR),0)
 ,BQuantityCR  = IsNull(sum(DS.BQuantityCR),0)
 ,BSum_eeCR    = IsNull(sum(DS.BSum_eeCR),0)
 ,BSum_ndsCR   = IsNull(sum(DS.BSum_ndsCR),0)
 ,BSum_excCR   = IsNull(sum(DS.BSum_excCR),0)

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
 ,Nach        = IsNull(sum(DS.NSum_ee + DS.NSum_nds + DS.NSum_exc),0)
 ,NQuantity   = IsNull(sum(DS.NQUANTITY),0)
 ,NSum_ee     = IsNull(sum(DS.NSum_ee),0)
 ,NSum_nds    = IsNull(sum(DS.NSum_nds),0)
 ,NSUM_exc    = IsNull(sum(DS.NSum_exc),0)
 ,NachDB      = IsNull(sum(DS.NSum_eeDB + DS.NSum_ndsDB + DS.NSum_excDB),0)
 ,NQuantityDB = IsNull(sum(DS.NQuantityDB),0)
 ,NSum_eeDB   = IsNull(sum(DS.NSum_eeDB),0)
 ,NSum_ndsDB  = IsNull(sum(DS.NSum_ndsDB),0)
 ,NSUM_excDB  = IsNull(sum(DS.NSum_excDB),0)
 ,NachCR      = IsNull(sum(DS.NSum_eeCR + DS.NSum_ndsCR + DS.NSum_excCR),0)
 ,NQuantityCR = IsNull(sum(DS.NQuantityCR),0)
 ,NSum_eeCR   = IsNull(sum(DS.NSum_eeCR),0)
 ,NSum_ndsCR  = IsNull(sum(DS.NSum_ndsCR),0)
 ,NSUM_excCR  = IsNull(sum(DS.NSum_excCR),0)

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
 ,Pay         = IsNull(sum(DS.PSum_ee + DS.PSum_nds + DS.PSum_exc),0)
 ,PQuantity   = IsNull(sum(DS.PQuantity),0)
 ,PSum_ee     = IsNull(sum(DS.PSum_ee),0)
 ,PSum_nds    = IsNull(sum(DS.PSum_nds),0)
 ,PSum_exc    = IsNull(sum(DS.PSum_exc),0)
 ,PayDB       = IsNull(sum(DS.PSum_eeDB + DS.PSum_ndsDB + DS.PSum_excDB),0)
 ,PQuantityDB = IsNull(sum(DS.PQuantityDB),0)
 ,PSum_eeDB   = IsNull(sum(DS.PSum_eeDB),0)
 ,PSum_ndsDB  = IsNull(sum(DS.PSum_ndsDB),0)
 ,PSum_excDB  = IsNull(sum(DS.PSum_excDB),0)
 ,PayCR       = IsNull(sum(DS.PSum_eeCR + DS.PSum_ndsCR + DS.PSum_excCR),0)
 ,PQuantityCR = IsNull(sum(DS.PQuantityCR),0)
 ,PSum_eeCR   = IsNull(sum(DS.PSum_eeCR),0)
 ,PSum_ndsCR  = IsNull(sum(DS.PSum_ndsCR),0)
 ,PSum_excCR  = IsNull(sum(DS.PSum_excCR),0)

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
 ,ESaldo      = IsNull(sum(DS.ESum_ee + DS.ESum_nds + DS.ESum_exc),0)
 ,EQuantity   = IsNull(sum(DS.EQuantity),0)
 ,ESum_ee     = IsNull(sum(DS.ESum_ee),0)
 ,ESum_nds    = IsNull(sum(DS.ESum_nds),0)
 ,ESum_exc    = IsNull(sum(DS.ESum_exc),0)
 ,ESaldoDB    = IsNull(sum(DS.ESum_eeDB + DS.ESum_ndsDB + DS.ESum_excDB),0)
 ,EQuantityDB = IsNull(sum(DS.EQuantityDB),0)
 ,ESum_eeDB   = IsNull(sum(DS.ESum_eeDB),0)
 ,ESum_ndsDB  = IsNull(sum(DS.ESum_ndsDB),0)
 ,ESum_excDB  = IsNull(sum(DS.ESum_excDB),0)
 ,ESaldoCR    = IsNull(sum(DS.ESum_eeCR + DS.ESum_ndsCR + DS.ESum_excCR),0)
 ,EQuantityCR = IsNull(sum(DS.EQuantityCR),0)
 ,ESum_eeCR   = IsNull(sum(DS.ESum_eeCR),0)
 ,ESum_ndsCR  = IsNull(sum(DS.ESum_ndsCR),0)
 ,ESum_excCR  = IsNull(sum(DS.ESum_excCR),0)

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
 ,BSaldo       = IsNull(sum(DS.BSum_ee + DS.Bsum_nds + DS.BSum_exc),0)
 ,BQuantity    = IsNull(sum(DS.BQuantity),0)
 ,BSum_ee      = IsNull(sum(DS.BSum_ee),0)
 ,BSum_nds     = IsNull(sum(DS.BSum_nds),0)
 ,BSum_exc     = IsNull(sum(DS.BSum_exc),0)
 ,BSaldoDB     = IsNull(sum(DS.BSum_eeDB + DS.Bsum_ndsDB + DS.BSum_excDB),0)
 ,BQuantityDB  = IsNull(sum(DS.BQuantityDB),0)
 ,BSum_eeDB    = IsNull(sum(DS.BSum_eeDB),0)
 ,BSum_ndsDB   = IsNull(sum(DS.BSum_ndsDB),0)
 ,BSum_excDB   = IsNull(sum(DS.BSum_excDB),0)
 ,BSaldoCR     = IsNull(sum(DS.BSum_eeCR + DS.Bsum_ndsCR + DS.BSum_excCR),0)
 ,BQuantityCR  = IsNull(sum(DS.BQuantityCR),0)
 ,BSum_eeCR    = IsNull(sum(DS.BSum_eeCR),0)
 ,BSum_ndsCR   = IsNull(sum(DS.BSum_ndsCR),0)
 ,BSum_excCR   = IsNull(sum(DS.BSum_excCR),0)

 ,NRES='ИТОГО:'
 ,Nach        = IsNull(sum(DS.NSum_ee + DS.NSum_nds + DS.NSum_exc),0)
 ,NQuantity   = IsNull(sum(DS.NQUANTITY),0)
 ,NSum_ee     = IsNull(sum(DS.NSum_ee),0)
 ,NSum_nds    = IsNull(sum(DS.NSum_nds),0)
 ,NSUM_exc    = IsNull(sum(DS.NSum_exc),0)
 ,NachDB      = IsNull(sum(DS.NSum_eeDB + DS.NSum_ndsDB + DS.NSum_excDB),0)
 ,NQuantityDB = IsNull(sum(DS.NQuantityDB),0)
 ,NSum_eeDB   = IsNull(sum(DS.NSum_eeDB),0)
 ,NSum_ndsDB  = IsNull(sum(DS.NSum_ndsDB),0)
 ,NSUM_excDB  = IsNull(sum(DS.NSum_excDB),0)
 ,NachCR      = IsNull(sum(DS.NSum_eeCR + DS.NSum_ndsCR + DS.NSum_excCR),0)
 ,NQuantityCR = IsNull(sum(DS.NQuantityCR),0)
 ,NSum_eeCR   = IsNull(sum(DS.NSum_eeCR),0)
 ,NSum_ndsCR  = IsNull(sum(DS.NSum_ndsCR),0)
 ,NSUM_excCR  = IsNull(sum(DS.NSum_excCR),0)

 ,PRES='ИТОГО:'
 ,Pay         = IsNull(sum(DS.PSum_ee + DS.PSum_nds + DS.PSum_exc),0)
 ,PQuantity   = IsNull(sum(DS.PQuantity),0)
 ,PSum_ee     = IsNull(sum(DS.PSum_ee),0)
 ,PSum_nds    = IsNull(sum(DS.PSum_nds),0)
 ,PSum_exc    = IsNull(sum(DS.PSum_exc),0)
 ,PayDB       = IsNull(sum(DS.PSum_eeDB + DS.PSum_ndsDB + DS.PSum_excDB),0)
 ,PQuantityDB = IsNull(sum(DS.PQuantityDB),0)
 ,PSum_eeDB   = IsNull(sum(DS.PSum_eeDB),0)
 ,PSum_ndsDB  = IsNull(sum(DS.PSum_ndsDB),0)
 ,PSum_excDB  = IsNull(sum(DS.PSum_excDB),0)
 ,PayCR       = IsNull(sum(DS.PSum_eeCR + DS.PSum_ndsCR + DS.PSum_excCR),0)
 ,PQuantityCR = IsNull(sum(DS.PQuantityCR),0)
 ,PSum_eeCR   = IsNull(sum(DS.PSum_eeCR),0)
 ,PSum_ndsCR  = IsNull(sum(DS.PSum_ndsCR),0)
 ,PSum_excCR  = IsNull(sum(DS.PSum_excCR),0)

 ,ERES='ИТОГО:'
 ,ESaldo      = IsNull(sum(DS.ESum_ee + DS.ESum_nds + DS.ESum_exc),0)
 ,EQuantity   = IsNull(sum(DS.EQuantity),0)
 ,ESum_ee     = IsNull(sum(DS.ESum_ee),0)
 ,ESum_nds    = IsNull(sum(DS.ESum_nds),0)
 ,ESum_exc    = IsNull(sum(DS.ESum_exc),0)
 ,ESaldoDB    = IsNull(sum(DS.ESum_eeDB + DS.ESum_ndsDB + DS.ESum_excDB),0)
 ,EQuantityDB = IsNull(sum(DS.EQuantityDB),0)
 ,ESum_eeDB   = IsNull(sum(DS.ESum_eeDB),0)
 ,ESum_ndsDB  = IsNull(sum(DS.ESum_ndsDB),0)
 ,ESum_excDB  = IsNull(sum(DS.ESum_excDB),0)
 ,ESaldoCR    = IsNull(sum(DS.ESum_eeCR + DS.ESum_ndsCR + DS.ESum_excCR),0)
 ,EQuantityCR = IsNull(sum(DS.EQuantityCR),0)
 ,ESum_eeCR   = IsNull(sum(DS.ESum_eeCR),0)
 ,ESum_ndsCR  = IsNull(sum(DS.ESum_ndsCR),0)
 ,ESum_excCR  = IsNull(sum(DS.ESum_excCR),0)

 FROM
  ProContracts  Cs (NoLock),
  #TmpProDivSal DS (NoLock)
 WHERE
  DS.CONTRACT_ID=Cs.CONTRACT_ID 
 ORDER BY
  BRES

drop table #TmpProDivSal

/*
select Sum_add,sum_nds,Sum_exc from ProCalcs
where
   contract_id in (select Contract_id
                     from ProDivSal
                     where Bsum_ee  < 0
                       and bsum_exc > 0)
 and date_calc = '2004-01-31'

select Contract_id
      ,Bquantity
      ,bsum_ee
      ,bsum_nds
      ,bsum_exc
from ProDivSal
 where
        Bsum_ee  < 0
    and bsum_exc > 0 
 */

