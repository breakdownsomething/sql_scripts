--************************************************
-- Показатели по реализации(декабрь 2004 с РЭС-9)
--************************************************
DECLARE
 @dtCalc SmallDateTime
SELECT
 @dtCalc='2004-01-31'
--**********************************************************************************
--  Секция распределения "Сальдо-Начисления-Оплаты с НДС-20%"
--**********************************************************************************
SELECT 
--Сальдо на начало-------------------------------------------
  BRES= ' РЭС-'+Right(Str(Cs.GROUP_ID),1),
-- 20%
  BSALDO20=Convert(Decimal(15,2),SUM(DS.BSALDO20)),
  BQUANTITY20=Convert(Integer,SUM(DS.BQUANTITY20)),
  BSUM_EE20=Convert(Decimal(15,2),SUM(DS.BSUM_EE20)),
  BSUM_ACT20=Convert(Decimal(15,2),SUM(DS.BSUM_ACT20)),
  BSUM_EXC20=Convert(Decimal(15,2),SUM(DS.BSUM_EXC20)),
--
  BSALDO20DB=Convert(Decimal(15,2),SUM(DS.BSALDO20DB)),
  BQUANTITY20DB=Convert(Integer,SUM(DS.BQUANTITY20DB)),
  BSUM_EE20DB=Convert(Decimal(15,2),SUM(DS.BSUM_EE20DB)),
  BSUM_ACT20DB=Convert(Decimal(15,2),SUM(DS.BSUM_ACT20DB)),
  BSUM_EXC20DB=Convert(Decimal(15,2),SUM(DS.BSUM_EXC20DB)),
--
  BSALDO20CR=Convert(Decimal(15,2),SUM(DS.BSALDO20CR)),
  BQUANTITY20CR=Convert(Integer,SUM(DS.BQUANTITY20CR)),
  BSUM_EE20CR=Convert(Decimal(15,2),SUM(DS.BSUM_EE20CR)),
  BSUM_ACT20CR=Convert(Decimal(15,2),SUM(DS.BSUM_ACT20CR)),
  BSUM_EXC20CR=Convert(Decimal(15,2),SUM(DS.BSUM_EXC20CR)),
--16%
  BSALDO16=Convert(Decimal(15,2),SUM(DS.BSALDO16)),
  BQUANTITY16=Convert(Integer,SUM(DS.BQUANTITY16)),
  BSUM_EE16=Convert(Decimal(15,2),SUM(DS.BSUM_EE16)),
  BSUM_ACT16=Convert(Decimal(15,2),SUM(DS.BSUM_ACT16)),
  BSUM_EXC16=Convert(Decimal(15,2),SUM(DS.BSUM_EXC16)),
--
  BSALDO16DB=Convert(Decimal(15,2),SUM(DS.BSALDO16DB)),
  BQUANTITY16DB=Convert(Integer,SUM(DS.BQUANTITY16DB)),
  BSUM_EE16DB=Convert(Decimal(15,2),SUM(DS.BSUM_EE16DB)),
  BSUM_ACT16DB=Convert(Decimal(15,2),SUM(DS.BSUM_ACT16DB)),
  BSUM_EXC16DB=Convert(Decimal(15,2),SUM(DS.BSUM_EXC16DB)),
--
  BSALDO16CR=Convert(Decimal(15,2),SUM(DS.BSALDO16CR)),
  BQUANTITY16CR=Convert(Integer,SUM(DS.BQUANTITY16CR)),
  BSUM_EE16CR=Convert(Decimal(15,2),SUM(DS.BSUM_EE16CR)),
  BSUM_ACT16CR=Convert(Decimal(15,2),SUM(DS.BSUM_ACT16CR)),
  BSUM_EXC16CR=Convert(Decimal(15,2),SUM(DS.BSUM_EXC16CR)),
--15%
  BSALDO15=Convert(Decimal(15,2),SUM(DS.BSALDO15)),
  BQUANTITY15=Convert(Integer,SUM(DS.BQUANTITY15)),
  BSUM_EE15=Convert(Decimal(15,2),SUM(DS.BSUM_EE15)),
  BSUM_ACT15=Convert(Decimal(15,2),SUM(DS.BSUM_ACT15)),
  BSUM_EXC15=Convert(Decimal(15,2),SUM(DS.BSUM_EXC15)),
--
  BSALDO15DB=Convert(Decimal(15,2),SUM(DS.BSALDO15DB)),
  BQUANTITY15DB=Convert(Integer,SUM(DS.BQUANTITY15DB)),
  BSUM_EE15DB=Convert(Decimal(15,2),SUM(DS.BSUM_EE15DB)),
  BSUM_ACT15DB=Convert(Decimal(15,2),SUM(DS.BSUM_ACT15DB)),
  BSUM_EXC15DB=Convert(Decimal(15,2),SUM(DS.BSUM_EXC15DB)),
--
  BSALDO15CR=Convert(Decimal(15,2),SUM(DS.BSALDO15CR)),
  BQUANTITY15CR=Convert(Integer,SUM(DS.BQUANTITY15CR)),
  BSUM_EE15CR=Convert(Decimal(15,2),SUM(DS.BSUM_EE15CR)),
  BSUM_ACT15CR=Convert(Decimal(15,2),SUM(DS.BSUM_ACT15CR)),
  BSUM_EXC15CR=Convert(Decimal(15,2),SUM(DS.BSUM_EXC15CR)),
--Сводное
  BSALDO=Convert(Decimal(15,2),SUM(DS.BSALDO)),
  BQUANTITY=Convert(Integer,SUM(DS.BQUANTITY)),
  BSUM_EE=Convert(Decimal(15,2),SUM(DS.BSUM_EE)),
  BSUM_ACT=Convert(Decimal(15,2),SUM(DS.BSUM_ACT)),
  BSUM_EXC=Convert(Decimal(15,2),SUM(DS.BSUM_EXC)),
--
  BSALDODB=Convert(Decimal(15,2),SUM(DS.BSALDODB)),
  BQUANTITYDB=Convert(Integer,SUM(DS.BQUANTITYDB)),
  BSUM_EEDB=Convert(Decimal(15,2),SUM(DS.BSUM_EEDB)),
  BSUM_ACTDB=Convert(Decimal(15,2),SUM(DS.BSUM_ACTDB)),
  BSUM_EXCDB=Convert(Decimal(15,2),SUM(DS.BSUM_EXCDB)),
--
  BSALDOCR=Convert(Decimal(15,2),SUM(DS.BSALDOCR)),
  BQUANTITYCR=Convert(Integer,SUM(DS.BQUANTITYCR)),
  BSUM_EECR=Convert(Decimal(15,2),SUM(DS.BSUM_EECR)),
  BSUM_ACTCR=Convert(Decimal(15,2),SUM(DS.BSUM_ACTCR)),
  BSUM_EXCCR=Convert(Decimal(15,2),SUM(DS.BSUM_EXCCR)),

-- Начисления------------------------------------------------
  NRES= ' РЭС-'+Right(Str(Cs.GROUP_ID),1),
--20%
  NACH20=Convert(Decimal(15,2),SUM(DS.NACH20)),
  NQUANTITY20=Convert(Integer,SUM(DS.NQUANTITY20)),
  NSUM_EE20=Convert(Decimal(15,2),SUM(DS.NSUM_EE20)),
  NSUM_NDS20=Convert(Decimal(15,2),SUM(DS.NSUM_NDS20)),
  NSUM_EXC20=Convert(Decimal(15,2),SUM(DS.NSUM_EXC20)),
--
  NACH20DB=Convert(Decimal(15,2),SUM(DS.NACH20DB)),
  NQUANTITY20DB=Convert(Integer,SUM(DS.NQUANTITY20DB)),
  NSUM_EE20DB=Convert(Decimal(15,2),SUM(DS.NSUM_EE20DB)),
  NSUM_NDS20DB=Convert(Decimal(15,2),SUM(DS.NSUM_NDS20DB)),
  NSUM_EXC20DB=Convert(Decimal(15,2),SUM(DS.NSUM_EXC20DB)),
--
  NACH20CR=Convert(Decimal(15,2),SUM(DS.NACH20CR)),
  NQUANTITY20CR=Convert(Integer,SUM(DS.NQUANTITY20CR)),
  NSUM_EE20CR=Convert(Decimal(15,2),SUM(DS.NSUM_EE20CR)),
  NSUM_NDS20CR=Convert(Decimal(15,2),SUM(DS.NSUM_NDS20CR)),
  NSUM_EXC20CR=Convert(Decimal(15,2),SUM(DS.NSUM_EXC20CR)),
--16%
  NACH16=Convert(Decimal(15,2),SUM(DS.NACH16)),
  NQUANTITY16=Convert(Integer,SUM(DS.NQUANTITY16)),
  NSUM_EE16=Convert(Decimal(15,2),SUM(DS.NSUM_EE16)),
  NSUM_NDS16=Convert(Decimal(15,2),SUM(DS.NSUM_NDS16)),
  NSUM_EXC16=Convert(Decimal(15,2),SUM(DS.NSUM_EXC16)),
--
  NACH16DB=Convert(Decimal(15,2),SUM(DS.NACH16DB)),
  NQUANTITY16DB=Convert(Integer,SUM(DS.NQUANTITY16DB)),
  NSUM_EE16DB=Convert(Decimal(15,2),SUM(DS.NSUM_EE16DB)),
  NSUM_NDS16DB=Convert(Decimal(15,2),SUM(DS.NSUM_NDS16DB)),
  NSUM_EXC16DB=Convert(Decimal(15,2),SUM(DS.NSUM_EXC16DB)),
--
  NACH16CR=Convert(Decimal(15,2),SUM(DS.NACH16CR)),
  NQUANTITY16CR=Convert(Integer,SUM(DS.NQUANTITY16CR)),
  NSUM_EE16CR=Convert(Decimal(15,2),SUM(DS.NSUM_EE16CR)),
  NSUM_NDS16CR=Convert(Decimal(15,2),SUM(DS.NSUM_NDS16CR)),
  NSUM_EXC16CR=Convert(Decimal(15,2),SUM(DS.NSUM_EXC16CR)),
--15%
  NACH15=Convert(Decimal(15,2),SUM(DS.NACH15)),
  NQUANTITY15=Convert(Integer,SUM(DS.NQUANTITY15)),
  NSUM_EE15=Convert(Decimal(15,2),SUM(DS.NSUM_EE15)),
  NSUM_NDS15=Convert(Decimal(15,2),SUM(DS.NSUM_NDS15)),
  NSUM_EXC15=Convert(Decimal(15,2),SUM(DS.NSUM_EXC15)),
--
  NACH15DB=Convert(Decimal(15,2),SUM(DS.NACH15DB)),
  NQUANTITY15DB=Convert(Integer,SUM(DS.NQUANTITY15DB)),
  NSUM_EE15DB=Convert(Decimal(15,2),SUM(DS.NSUM_EE15DB)),
  NSUM_NDS15DB=Convert(Decimal(15,2),SUM(DS.NSUM_NDS15DB)),
  NSUM_EXC15DB=Convert(Decimal(15,2),SUM(DS.NSUM_EXC15DB)),
--
  NACH15CR=Convert(Decimal(15,2),SUM(DS.NACH15CR)),
  NQUANTITY15CR=Convert(Integer,SUM(DS.NQUANTITY15CR)),
  NSUM_EE15CR=Convert(Decimal(15,2),SUM(DS.NSUM_EE15CR)),
  NSUM_NDS15CR=Convert(Decimal(15,2),SUM(DS.NSUM_NDS15CR)),
  NSUM_EXC15CR=Convert(Decimal(15,2),SUM(DS.NSUM_EXC15CR)),
--Свод
  NACH=Convert(Decimal(15,2),SUM(DS.NACH)),
  NQUANTITY=Convert(Integer,SUM(DS.NQUANTITY)),
  NSUM_EE=Convert(Decimal(15,2),SUM(DS.NSUM_EE)),
  NSUM_NDS=Convert(Decimal(15,2),SUM(DS.NSUM_NDS)),
  NSUM_EXC=Convert(Decimal(15,2),SUM(DS.NSUM_EXC)),
--
  NACHDB=Convert(Decimal(15,2),SUM(DS.NACHDB)),
  NQUANTITYDB=Convert(Integer,SUM(DS.NQUANTITYDB)),
  NSUM_EEDB=Convert(Decimal(15,2),SUM(DS.NSUM_EEDB)),
  NSUM_NDSDB=Convert(Decimal(15,2),SUM(DS.NSUM_NDSDB)),
  NSUM_EXCDB=Convert(Decimal(15,2),SUM(DS.NSUM_EXCDB)),
--
  NACHCR=Convert(Decimal(15,2),SUM(DS.NACHCR)),
  NQUANTITYCR=Convert(Integer,SUM(DS.NQUANTITYCR)),
  NSUM_EECR=Convert(Decimal(15,2),SUM(DS.NSUM_EECR)),
  NSUM_NDSCR=Convert(Decimal(15,2),SUM(DS.NSUM_NDSCR)),
  NSUM_EXCCR=Convert(Decimal(15,2),SUM(DS.NSUM_EXCCR)),

--Платежи------------------------------------------------------------------------
  PRES= ' РЭС-'+Right(Str(Cs.GROUP_ID),1),
--20%
  PAY20=Convert(Decimal(15,2),SUM(DS.PAY20)),
  PQUANTITY20=Convert(Integer,SUM(DS.PQUANTITY20)),
  PSUM_EE20=Convert(Decimal(15,2),SUM(DS.PSUM_EE20)),
  PSUM_NDS20=Convert(Decimal(15,2),SUM(DS.PSUM_NDS20)),
  PSUM_EXC20=Convert(Decimal(15,2),SUM(DS.PSUM_EXC20)),
--
  PAY20DB=Convert(Decimal(15,2),SUM(DS.PAY20DB)),
  PQUANTITY20DB=Convert(Integer,SUM(DS.PQUANTITY20DB)),
  PSUM_EE20DB=Convert(Decimal(15,2),SUM(DS.PSUM_EE20DB)),
  PSUM_NDS20DB=Convert(Decimal(15,2),SUM(DS.PSUM_NDS20DB)),
  PSUM_EXC20DB=Convert(Decimal(15,2),SUM(DS.PSUM_EXC20DB)),
--
  PAY20CR=Convert(Decimal(15,2),SUM(DS.PAY20CR)),
  PQUANTITY20CR=Convert(Integer,SUM(DS.PQUANTITY20CR)),
  PSUM_EE20CR=Convert(Decimal(15,2),SUM(DS.PSUM_EE20CR)),
  PSUM_NDS20CR=Convert(Decimal(15,2),SUM(DS.PSUM_NDS20CR)),
  PSUM_EXC20CR=Convert(Decimal(15,2),SUM(DS.PSUM_EXC20CR)),
--16%
  PAY16=Convert(Decimal(15,2),SUM(DS.PAY16)),
  PQUANTITY16=Convert(Integer,SUM(DS.PQUANTITY16)),
  PSUM_EE16=Convert(Decimal(15,2),SUM(DS.PSUM_EE16)),
  PSUM_NDS16=Convert(Decimal(15,2),SUM(DS.PSUM_NDS16)),
  PSUM_EXC16=Convert(Decimal(15,2),SUM(DS.PSUM_EXC16)),
--
  PAY16DB=Convert(Decimal(15,2),SUM(DS.PAY16DB)),
  PQUANTITY16DB=Convert(Integer,SUM(DS.PQUANTITY16DB)),
  PSUM_EE16DB=Convert(Decimal(15,2),SUM(DS.PSUM_EE16DB)),
  PSUM_NDS16DB=Convert(Decimal(15,2),SUM(DS.PSUM_NDS16DB)),
  PSUM_EXC16DB=Convert(Decimal(15,2),SUM(DS.PSUM_EXC16DB)),
--
  PAY16CR=Convert(Decimal(15,2),SUM(DS.PAY16CR)),
  PQUANTITY16CR=Convert(Integer,SUM(DS.PQUANTITY16CR)),
  PSUM_EE16CR=Convert(Decimal(15,2),SUM(DS.PSUM_EE16CR)),
  PSUM_NDS16CR=Convert(Decimal(15,2),SUM(DS.PSUM_NDS16CR)),
  PSUM_EXC16CR=Convert(Decimal(15,2),SUM(DS.PSUM_EXC16CR)),
--15%
  PAY15=Convert(Decimal(15,2),SUM(DS.PAY15)),
  PQUANTITY15=Convert(Integer,SUM(DS.PQUANTITY15)),
  PSUM_EE15=Convert(Decimal(15,2),SUM(DS.PSUM_EE15)),
  PSUM_NDS15=Convert(Decimal(15,2),SUM(DS.PSUM_NDS15)),
  PSUM_EXC15=Convert(Decimal(15,2),SUM(DS.PSUM_EXC15)),
--
  PAY15DB=Convert(Decimal(15,2),SUM(DS.PAY15DB)),
  PQUANTITY15DB=Convert(Integer,SUM(DS.PQUANTITY15DB)),
  PSUM_EE15DB=Convert(Decimal(15,2),SUM(DS.PSUM_EE15DB)),
  PSUM_NDS15DB=Convert(Decimal(15,2),SUM(DS.PSUM_NDS15DB)),
  PSUM_EXC15DB=Convert(Decimal(15,2),SUM(DS.PSUM_EXC15DB)),
--
  PAY15CR=Convert(Decimal(15,2),SUM(DS.PAY15CR)),
  PQUANTITY15CR=Convert(Integer,SUM(DS.PQUANTITY15CR)),
  PSUM_EE15CR=Convert(Decimal(15,2),SUM(DS.PSUM_EE15CR)),
  PSUM_NDS15CR=Convert(Decimal(15,2),SUM(DS.PSUM_NDS15CR)),
  PSUM_EXC15CR=Convert(Decimal(15,2),SUM(DS.PSUM_EXC15CR)),
--Свод
  PAY=Convert(Decimal(15,2),SUM(DS.PAY)),
  PQUANTITY=Convert(Integer,SUM(DS.PQUANTITY)),
  PSUM_EE=Convert(Decimal(15,2),SUM(DS.PSUM_EE)),
  PSUM_NDS=Convert(Decimal(15,2),SUM(DS.PSUM_NDS)),
  PSUM_EXC=Convert(Decimal(15,2),SUM(DS.PSUM_EXC)),
--
  PAYDB=Convert(Decimal(15,2),SUM(DS.PAYDB)),
  PQUANTITYDB=Convert(Integer,SUM(DS.PQUANTITYDB)),
  PSUM_EEDB=Convert(Decimal(15,2),SUM(DS.PSUM_EEDB)),
  PSUM_NDSDB=Convert(Decimal(15,2),SUM(DS.PSUM_NDSDB)),
  PSUM_EXCDB=Convert(Decimal(15,2),SUM(DS.PSUM_EXCDB)),
--
  PAYCR=Convert(Decimal(15,2),SUM(DS.PAYCR)),
  PQUANTITYCR=Convert(Integer,SUM(DS.PQUANTITYCR)),
  PSUM_EECR=Convert(Decimal(15,2),SUM(DS.PSUM_EECR)),
  PSUM_NDSCR=Convert(Decimal(15,2),SUM(DS.PSUM_NDSCR)),
  PSUM_EXCCR=Convert(Decimal(15,2),SUM(DS.PSUM_EXCCR)),

--Сальдо на конец---------------------------------------------------------
  ERES= ' РЭС-'+Right(Str(Cs.GROUP_ID),1),
--20%
  ESALDO20=Convert(Decimal(15,2),SUM(DS.ESALDO20)),
  EQUANTITY20=Convert(Integer,SUM(DS.EQUANTITY20)),
  ESUM_EE20=Convert(Decimal(15,2),SUM(DS.ESUM_EE20)),
  ESUM_ACT20=Convert(Decimal(15,2),SUM(DS.ESUM_ACT20)),
  ESUM_EXC20=Convert(Decimal(15,2),SUM(DS.ESUM_EXC20)),
--
  ESALDO20DB=Convert(Decimal(15,2),SUM(DS.ESALDO20DB)),
  EQUANTITY20DB=Convert(Integer,SUM(DS.EQUANTITY20DB)),
  ESUM_EE20DB=Convert(Decimal(15,2),SUM(DS.ESUM_EE20DB)),
  ESUM_ACT20DB=Convert(Decimal(15,2),SUM(DS.ESUM_ACT20DB)),
  ESUM_EXC20DB=Convert(Decimal(15,2),SUM(DS.ESUM_EXC20DB)),
--
  ESALDO20CR=Convert(Decimal(15,2),SUM(DS.ESALDO20CR)),
  EQUANTITY20CR=Convert(Integer,SUM(DS.EQUANTITY20CR)),
  ESUM_EE20CR=Convert(Decimal(15,2),SUM(DS.ESUM_EE20CR)),
  ESUM_ACT20CR=Convert(Decimal(15,2),SUM(DS.ESUM_ACT20CR)),
  ESUM_EXC20CR=Convert(Decimal(15,2),SUM(DS.ESUM_EXC20CR)),
--16%
  ESALDO16=Convert(Decimal(15,2),SUM(DS.ESALDO16)),
  EQUANTITY16=Convert(Integer,SUM(DS.EQUANTITY16)),
  ESUM_EE16=Convert(Decimal(15,2),SUM(DS.ESUM_EE16)),
  ESUM_ACT16=Convert(Decimal(15,2),SUM(DS.ESUM_ACT16)),
  ESUM_EXC16=Convert(Decimal(15,2),SUM(DS.ESUM_EXC16)),
--
  ESALDO16DB=Convert(Decimal(15,2),SUM(DS.ESALDO16DB)),
  EQUANTITY16DB=Convert(Integer,SUM(DS.EQUANTITY16DB)),
  ESUM_EE16DB=Convert(Decimal(15,2),SUM(DS.ESUM_EE16DB)),
  ESUM_ACT16DB=Convert(Decimal(15,2),SUM(DS.ESUM_ACT16DB)),
  ESUM_EXC16DB=Convert(Decimal(15,2),SUM(DS.ESUM_EXC16DB)),
--
  ESALDO16CR=Convert(Decimal(15,2),SUM(DS.ESALDO16CR)),
  EQUANTITY16CR=Convert(Integer,SUM(DS.EQUANTITY16CR)),
  ESUM_EE16CR=Convert(Decimal(15,2),SUM(DS.ESUM_EE16CR)),
  ESUM_ACT16CR=Convert(Decimal(15,2),SUM(DS.ESUM_ACT16CR)),
  ESUM_EXC16CR=Convert(Decimal(15,2),SUM(DS.ESUM_EXC16CR)),
--15%
  ESALDO15=Convert(Decimal(15,2),SUM(DS.ESALDO15)),
  EQUANTITY15=Convert(Integer,SUM(DS.EQUANTITY15)),
  ESUM_EE15=Convert(Decimal(15,2),SUM(DS.ESUM_EE15)),
  ESUM_ACT15=Convert(Decimal(15,2),SUM(DS.ESUM_ACT15)),
  ESUM_EXC15=Convert(Decimal(15,2),SUM(DS.ESUM_EXC15)),
--
  ESALDO15DB=Convert(Decimal(15,2),SUM(DS.ESALDO15DB)),
  EQUANTITY15DB=Convert(Integer,SUM(DS.EQUANTITY15DB)),
  ESUM_EE15DB=Convert(Decimal(15,2),SUM(DS.ESUM_EE15DB)),
  ESUM_ACT15DB=Convert(Decimal(15,2),SUM(DS.ESUM_ACT15DB)),
  ESUM_EXC15DB=Convert(Decimal(15,2),SUM(DS.ESUM_EXC15DB)),
--
  ESALDO15CR=Convert(Decimal(15,2),SUM(DS.ESALDO15CR)),
  EQUANTITY15CR=Convert(Integer,SUM(DS.EQUANTITY15CR)),
  ESUM_EE15CR=Convert(Decimal(15,2),SUM(DS.ESUM_EE15CR)),
  ESUM_ACT15CR=Convert(Decimal(15,2),SUM(DS.ESUM_ACT15CR)),
  ESUM_EXC15CR=Convert(Decimal(15,2),SUM(DS.ESUM_EXC15CR)),
--свод
  ESALDO=Convert(Decimal(15,2),SUM(DS.ESALDO)),
  EQUANTITY=Convert(Integer,SUM(DS.EQUANTITY)),
  ESUM_EE=Convert(Decimal(15,2),SUM(DS.ESUM_EE)),
  ESUM_ACT=Convert(Decimal(15,2),SUM(DS.ESUM_ACT)),
  ESUM_EXC=Convert(Decimal(15,2),SUM(DS.ESUM_EXC)),
--
  ESALDODB=Convert(Decimal(15,2),SUM(DS.ESALDODB)),
  EQUANTITYDB=Convert(Integer,SUM(DS.EQUANTITYDB)),
  ESUM_EEDB=Convert(Decimal(15,2),SUM(DS.ESUM_EEDB)),
  ESUM_ACTDB=Convert(Decimal(15,2),SUM(DS.ESUM_ACTDB)),
  ESUM_EXCDB=Convert(Decimal(15,2),SUM(DS.ESUM_EXCDB)),
--
  ESALDOCR=Convert(Decimal(15,2),SUM(DS.ESALDOCR)),
  EQUANTITYCR=Convert(Integer,SUM(DS.EQUANTITYCR)),
  ESUM_EECR=Convert(Decimal(15,2),SUM(DS.ESUM_EECR)),
  ESUM_ACTCR=Convert(Decimal(15,2),SUM(DS.ESUM_ACTCR)),
  ESUM_EXCCR=Convert(Decimal(15,2),SUM(DS.ESUM_EXCCR))

 FROM
  ProContracts Cs (NoLock),
  ProDivSaldo DS (NoLock)
 WHERE
  DS.CONTRACT_ID=Cs.CONTRACT_ID AND
  DS.DATE_CALC=@dtCalc
  AND NOT((Cs.GROUP_ID=10011 AND Cs.SUBGROUP_ID=7) OR
    (Cs.GROUP_ID=10012 AND Cs.SUBGROUP_ID=6) OR
    (Cs.GROUP_ID=10014 AND Cs.SUBGROUP_ID=5) OR
    (Cs.GROUP_ID=10015 AND Cs.SUBGROUP_ID=8) OR
    (Cs.GROUP_ID=10017 AND Cs.SUBGROUP_ID=6))
 GROUP BY
  ' РЭС-'+Right(Str(Cs.GROUP_ID),1)
--*************************************************************
 UNION SELECT
--Сальдо на начало--------------------------------------------------------------
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
        ' РЭС-'+Right(Str(Cs.GROUP_ID),1)+' т.ч. б/НДС'
    END,
--20%
  BSALDO20=Convert(Decimal(15,2),SUM(DS.BSALDO20)),
  BQUANTITY20=Convert(Integer,SUM(DS.BQUANTITY20)),
  BSUM_EE20=Convert(Decimal(15,2),SUM(DS.BSUM_EE20)),
  BSUM_ACT20=Convert(Decimal(15,2),SUM(DS.BSUM_ACT20)),
  BSUM_EXC20=Convert(Decimal(15,2),SUM(DS.BSUM_EXC20)),
--
  BSALDO20DB=Convert(Decimal(15,2),SUM(DS.BSALDO20DB)),
  BQUANTITY20DB=Convert(Integer,SUM(DS.BQUANTITY20DB)),
  BSUM_EE20DB=Convert(Decimal(15,2),SUM(DS.BSUM_EE20DB)),
  BSUM_ACT20DB=Convert(Decimal(15,2),SUM(DS.BSUM_ACT20DB)),
  BSUM_EXC20DB=Convert(Decimal(15,2),SUM(DS.BSUM_EXC20DB)),
--
  BSALDO20CR=Convert(Decimal(15,2),SUM(DS.BSALDO20CR)),
  BQUANTITY20CR=Convert(Integer,SUM(DS.BQUANTITY20CR)),
  BSUM_EE20CR=Convert(Decimal(15,2),SUM(DS.BSUM_EE20CR)),
  BSUM_ACT20CR=Convert(Decimal(15,2),SUM(DS.BSUM_ACT20CR)),
  BSUM_EXC20CR=Convert(Decimal(15,2),SUM(DS.BSUM_EXC20CR)),
--16%
  BSALDO16=Convert(Decimal(15,2),SUM(DS.BSALDO16)),
  BQUANTITY16=Convert(Integer,SUM(DS.BQUANTITY16)),
  BSUM_EE16=Convert(Decimal(15,2),SUM(DS.BSUM_EE16)),
  BSUM_ACT16=Convert(Decimal(15,2),SUM(DS.BSUM_ACT16)),
  BSUM_EXC16=Convert(Decimal(15,2),SUM(DS.BSUM_EXC16)),
--
  BSALDO16DB=Convert(Decimal(15,2),SUM(DS.BSALDO16DB)),
  BQUANTITY16DB=Convert(Integer,SUM(DS.BQUANTITY16DB)),
  BSUM_EE16DB=Convert(Decimal(15,2),SUM(DS.BSUM_EE16DB)),
  BSUM_ACT16DB=Convert(Decimal(15,2),SUM(DS.BSUM_ACT16DB)),
  BSUM_EXC16DB=Convert(Decimal(15,2),SUM(DS.BSUM_EXC16DB)),
--
  BSALDO16CR=Convert(Decimal(15,2),SUM(DS.BSALDO16CR)),
  BQUANTITY16CR=Convert(Integer,SUM(DS.BQUANTITY16CR)),
  BSUM_EE16CR=Convert(Decimal(15,2),SUM(DS.BSUM_EE16CR)),
  BSUM_ACT16CR=Convert(Decimal(15,2),SUM(DS.BSUM_ACT16CR)),
  BSUM_EXC16CR=Convert(Decimal(15,2),SUM(DS.BSUM_EXC16CR)),
--15%
  BSALDO15=Convert(Decimal(15,2),SUM(DS.BSALDO15)),
  BQUANTITY15=Convert(Integer,SUM(DS.BQUANTITY15)),
  BSUM_EE15=Convert(Decimal(15,2),SUM(DS.BSUM_EE15)),
  BSUM_ACT15=Convert(Decimal(15,2),SUM(DS.BSUM_ACT15)),
  BSUM_EXC15=Convert(Decimal(15,2),SUM(DS.BSUM_EXC15)),
--
  BSALDO15DB=Convert(Decimal(15,2),SUM(DS.BSALDO15DB)),
  BQUANTITY15DB=Convert(Integer,SUM(DS.BQUANTITY15DB)),
  BSUM_EE15DB=Convert(Decimal(15,2),SUM(DS.BSUM_EE15DB)),
  BSUM_ACT15DB=Convert(Decimal(15,2),SUM(DS.BSUM_ACT15DB)),
  BSUM_EXC15DB=Convert(Decimal(15,2),SUM(DS.BSUM_EXC15DB)),
--
  BSALDO15CR=Convert(Decimal(15,2),SUM(DS.BSALDO15CR)),
  BQUANTITY15CR=Convert(Integer,SUM(DS.BQUANTITY15CR)),
  BSUM_EE15CR=Convert(Decimal(15,2),SUM(DS.BSUM_EE15CR)),
  BSUM_ACT15CR=Convert(Decimal(15,2),SUM(DS.BSUM_ACT15CR)),
  BSUM_EXC15CR=Convert(Decimal(15,2),SUM(DS.BSUM_EXC15CR)),
--свод
  BSALDO=Convert(Decimal(15,2),SUM(DS.BSALDO)),
  BQUANTITY=Convert(Integer,SUM(DS.BQUANTITY)),
  BSUM_EE=Convert(Decimal(15,2),SUM(DS.BSUM_EE)),
  BSUM_ACT=Convert(Decimal(15,2),SUM(DS.BSUM_ACT)),
  BSUM_EXC=Convert(Decimal(15,2),SUM(DS.BSUM_EXC)),
--
  BSALDODB=Convert(Decimal(15,2),SUM(DS.BSALDODB)),
  BQUANTITYDB=Convert(Integer,SUM(DS.BQUANTITYDB)),
  BSUM_EEDB=Convert(Decimal(15,2),SUM(DS.BSUM_EEDB)),
  BSUM_ACTDB=Convert(Decimal(15,2),SUM(DS.BSUM_ACTDB)),
  BSUM_EXCDB=Convert(Decimal(15,2),SUM(DS.BSUM_EXCDB)),
--
  BSALDOCR=Convert(Decimal(15,2),SUM(DS.BSALDOCR)),
  BQUANTITYCR=Convert(Integer,SUM(DS.BQUANTITYCR)),
  BSUM_EECR=Convert(Decimal(15,2),SUM(DS.BSUM_EECR)),
  BSUM_ACTCR=Convert(Decimal(15,2),SUM(DS.BSUM_ACTCR)),
  BSUM_EXCCR=Convert(Decimal(15,2),SUM(DS.BSUM_EXCCR)),
--Начисления------------------------------------------------------
  NRES=
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
        ' РЭС-'+Right(Str(Cs.GROUP_ID),1)+' т.ч. б/НДС'
    END,
--20%
  NACH20=Convert(Decimal(15,2),SUM(DS.NACH20)),
  NQUANTITY20=Convert(Integer,SUM(DS.NQUANTITY20)),
  NSUM_EE20=Convert(Decimal(15,2),SUM(DS.NSUM_EE20)),
  NSUM_NDS20=Convert(Decimal(15,2),SUM(DS.NSUM_NDS20)),
  NSUM_EXC20=Convert(Decimal(15,2),SUM(DS.NSUM_EXC20)),
--
  NACH20DB=Convert(Decimal(15,2),SUM(DS.NACH20DB)),
  NQUANTITY20DB=Convert(Integer,SUM(DS.NQUANTITY20DB)),
  NSUM_EE20DB=Convert(Decimal(15,2),SUM(DS.NSUM_EE20DB)),
  NSUM_NDS20DB=Convert(Decimal(15,2),SUM(DS.NSUM_NDS20DB)),
  NSUM_EXC20DB=Convert(Decimal(15,2),SUM(DS.NSUM_EXC20DB)),
--
  NACH20CR=Convert(Decimal(15,2),SUM(DS.NACH20CR)),
  NQUANTITY20CR=Convert(Integer,SUM(DS.NQUANTITY20CR)),
  NSUM_EE20CR=Convert(Decimal(15,2),SUM(DS.NSUM_EE20CR)),
  NSUM_NDS20CR=Convert(Decimal(15,2),SUM(DS.NSUM_NDS20CR)),
  NSUM_EXC20CR=Convert(Decimal(15,2),SUM(DS.NSUM_EXC20CR)),
--16%
  NACH16=Convert(Decimal(15,2),SUM(DS.NACH16)),
  NQUANTITY16=Convert(Integer,SUM(DS.NQUANTITY16)),
  NSUM_EE16=Convert(Decimal(15,2),SUM(DS.NSUM_EE16)),
  NSUM_NDS16=Convert(Decimal(15,2),SUM(DS.NSUM_NDS16)),
  NSUM_EXC16=Convert(Decimal(15,2),SUM(DS.NSUM_EXC16)),
--
  NACH16DB=Convert(Decimal(15,2),SUM(DS.NACH16DB)),
  NQUANTITY16DB=Convert(Integer,SUM(DS.NQUANTITY16DB)),
  NSUM_EE16DB=Convert(Decimal(15,2),SUM(DS.NSUM_EE16DB)),
  NSUM_NDS16DB=Convert(Decimal(15,2),SUM(DS.NSUM_NDS16DB)),
  NSUM_EXC16DB=Convert(Decimal(15,2),SUM(DS.NSUM_EXC16DB)),
--
  NACH16CR=Convert(Decimal(15,2),SUM(DS.NACH16CR)),
  NQUANTITY16CR=Convert(Integer,SUM(DS.NQUANTITY16CR)),
  NSUM_EE16CR=Convert(Decimal(15,2),SUM(DS.NSUM_EE16CR)),
  NSUM_NDS16CR=Convert(Decimal(15,2),SUM(DS.NSUM_NDS16CR)),
  NSUM_EXC16CR=Convert(Decimal(15,2),SUM(DS.NSUM_EXC16CR)),
--15%
  NACH15=Convert(Decimal(15,2),SUM(DS.NACH15)),
  NQUANTITY15=Convert(Integer,SUM(DS.NQUANTITY15)),
  NSUM_EE15=Convert(Decimal(15,2),SUM(DS.NSUM_EE15)),
  NSUM_NDS15=Convert(Decimal(15,2),SUM(DS.NSUM_NDS15)),
  NSUM_EXC15=Convert(Decimal(15,2),SUM(DS.NSUM_EXC15)),
--
  NACH15DB=Convert(Decimal(15,2),SUM(DS.NACH15DB)),
  NQUANTITY15DB=Convert(Integer,SUM(DS.NQUANTITY15DB)),
  NSUM_EE15DB=Convert(Decimal(15,2),SUM(DS.NSUM_EE15DB)),
  NSUM_NDS15DB=Convert(Decimal(15,2),SUM(DS.NSUM_NDS15DB)),
  NSUM_EXC15DB=Convert(Decimal(15,2),SUM(DS.NSUM_EXC15DB)),
--
  NACH15CR=Convert(Decimal(15,2),SUM(DS.NACH15CR)),
  NQUANTITY15CR=Convert(Integer,SUM(DS.NQUANTITY15CR)),
  NSUM_EE15CR=Convert(Decimal(15,2),SUM(DS.NSUM_EE15CR)),
  NSUM_NDS15CR=Convert(Decimal(15,2),SUM(DS.NSUM_NDS15CR)),
  NSUM_EXC15CR=Convert(Decimal(15,2),SUM(DS.NSUM_EXC15CR)),
--свод
  NACH=Convert(Decimal(15,2),SUM(DS.NACH)),
  NQUANTITY=Convert(Integer,SUM(DS.NQUANTITY)),
  NSUM_EE=Convert(Decimal(15,2),SUM(DS.NSUM_EE)),
  NSUM_NDS=Convert(Decimal(15,2),SUM(DS.NSUM_NDS)),
  NSUM_EXC=Convert(Decimal(15,2),SUM(DS.NSUM_EXC)),
--
  NACHDB=Convert(Decimal(15,2),SUM(DS.NACHDB)),
  NQUANTITYDB=Convert(Integer,SUM(DS.NQUANTITYDB)),
  NSUM_EEDB=Convert(Decimal(15,2),SUM(DS.NSUM_EEDB)),
  NSUM_NDSDB=Convert(Decimal(15,2),SUM(DS.NSUM_NDSDB)),
  NSUM_EXCDB=Convert(Decimal(15,2),SUM(DS.NSUM_EXCDB)),
--
  NACHCR=Convert(Decimal(15,2),SUM(DS.NACHCR)),
  NQUANTITYCR=Convert(Integer,SUM(DS.NQUANTITYCR)),
  NSUM_EECR=Convert(Decimal(15,2),SUM(DS.NSUM_EECR)),
  NSUM_NDSCR=Convert(Decimal(15,2),SUM(DS.NSUM_NDSCR)),
  NSUM_EXCCR=Convert(Decimal(15,2),SUM(DS.NSUM_EXCCR)),

--Платежи--------------------------------------------------------------
  PRES=
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
        ' РЭС-'+Right(Str(Cs.GROUP_ID),1)+' т.ч. б/НДС'
    END,
--20%
  PAY20=Convert(Decimal(15,2),SUM(DS.PAY20)),
  PQUANTITY20=Convert(Integer,SUM(DS.PQUANTITY20)),
  PSUM_EE20=Convert(Decimal(15,2),SUM(DS.PSUM_EE20)),
  PSUM_NDS20=Convert(Decimal(15,2),SUM(DS.PSUM_NDS20)),
  PSUM_EXC20=Convert(Decimal(15,2),SUM(DS.PSUM_EXC20)),
--
  PAY20DB=Convert(Decimal(15,2),SUM(DS.PAY20DB)),
  PQUANTITY20DB=Convert(Integer,SUM(DS.PQUANTITY20DB)),
  PSUM_EE20DB=Convert(Decimal(15,2),SUM(DS.PSUM_EE20DB)),
  PSUM_NDS20DB=Convert(Decimal(15,2),SUM(DS.PSUM_NDS20DB)),
  PSUM_EXC20DB=Convert(Decimal(15,2),SUM(DS.PSUM_EXC20DB)),
--
  PAY20CR=Convert(Decimal(15,2),SUM(DS.PAY20CR)),
  PQUANTITY20CR=Convert(Integer,SUM(DS.PQUANTITY20CR)),
  PSUM_EE20CR=Convert(Decimal(15,2),SUM(DS.PSUM_EE20CR)),
  PSUM_NDS20CR=Convert(Decimal(15,2),SUM(DS.PSUM_NDS20CR)),
  PSUM_EXC20CR=Convert(Decimal(15,2),SUM(DS.PSUM_EXC20CR)),
--16%
  PAY16=Convert(Decimal(15,2),SUM(DS.PAY16)),
  PQUANTITY16=Convert(Integer,SUM(DS.PQUANTITY16)),
  PSUM_EE16=Convert(Decimal(15,2),SUM(DS.PSUM_EE16)),
  PSUM_NDS16=Convert(Decimal(15,2),SUM(DS.PSUM_NDS16)),
  PSUM_EXC16=Convert(Decimal(15,2),SUM(DS.PSUM_EXC16)),
--
  PAY16DB=Convert(Decimal(15,2),SUM(DS.PAY16DB)),
  PQUANTITY16DB=Convert(Integer,SUM(DS.PQUANTITY16DB)),
  PSUM_EE16DB=Convert(Decimal(15,2),SUM(DS.PSUM_EE16DB)),
  PSUM_NDS16DB=Convert(Decimal(15,2),SUM(DS.PSUM_NDS16DB)),
  PSUM_EXC16DB=Convert(Decimal(15,2),SUM(DS.PSUM_EXC16DB)),
--
  PAY16CR=Convert(Decimal(15,2),SUM(DS.PAY16CR)),
  PQUANTITY16CR=Convert(Integer,SUM(DS.PQUANTITY16CR)),
  PSUM_EE16CR=Convert(Decimal(15,2),SUM(DS.PSUM_EE16CR)),
  PSUM_NDS16CR=Convert(Decimal(15,2),SUM(DS.PSUM_NDS16CR)),
  PSUM_EXC16CR=Convert(Decimal(15,2),SUM(DS.PSUM_EXC16CR)),
--15%
  PAY15=Convert(Decimal(15,2),SUM(DS.PAY15)),
  PQUANTITY15=Convert(Integer,SUM(DS.PQUANTITY15)),
  PSUM_EE15=Convert(Decimal(15,2),SUM(DS.PSUM_EE15)),
  PSUM_NDS15=Convert(Decimal(15,2),SUM(DS.PSUM_NDS15)),
  PSUM_EXC15=Convert(Decimal(15,2),SUM(DS.PSUM_EXC15)),
--
  PAY15DB=Convert(Decimal(15,2),SUM(DS.PAY15DB)),
  PQUANTITY15DB=Convert(Integer,SUM(DS.PQUANTITY15DB)),
  PSUM_EE15DB=Convert(Decimal(15,2),SUM(DS.PSUM_EE15DB)),
  PSUM_NDS15DB=Convert(Decimal(15,2),SUM(DS.PSUM_NDS15DB)),
  PSUM_EXC15DB=Convert(Decimal(15,2),SUM(DS.PSUM_EXC15DB)),
--
  PAY15CR=Convert(Decimal(15,2),SUM(DS.PAY15CR)),
  PQUANTITY15CR=Convert(Integer,SUM(DS.PQUANTITY15CR)),
  PSUM_EE15CR=Convert(Decimal(15,2),SUM(DS.PSUM_EE15CR)),
  PSUM_NDS15CR=Convert(Decimal(15,2),SUM(DS.PSUM_NDS15CR)),
  PSUM_EXC15CR=Convert(Decimal(15,2),SUM(DS.PSUM_EXC15CR)),
--свод
  PAY=Convert(Decimal(15,2),SUM(DS.PAY)),
  PQUANTITY=Convert(Integer,SUM(DS.PQUANTITY)),
  PSUM_EE=Convert(Decimal(15,2),SUM(DS.PSUM_EE)),
  PSUM_NDS=Convert(Decimal(15,2),SUM(DS.PSUM_NDS)),
  PSUM_EXC=Convert(Decimal(15,2),SUM(DS.PSUM_EXC)),
--
  PAYDB=Convert(Decimal(15,2),SUM(DS.PAYDB)),
  PQUANTITYDB=Convert(Integer,SUM(DS.PQUANTITYDB)),
  PSUM_EEDB=Convert(Decimal(15,2),SUM(DS.PSUM_EEDB)),
  PSUM_NDSDB=Convert(Decimal(15,2),SUM(DS.PSUM_NDSDB)),
  PSUM_EXCDB=Convert(Decimal(15,2),SUM(DS.PSUM_EXCDB)),
--
  PAYCR=Convert(Decimal(15,2),SUM(DS.PAYCR)),
  PQUANTITYCR=Convert(Integer,SUM(DS.PQUANTITYCR)),
  PSUM_EECR=Convert(Decimal(15,2),SUM(DS.PSUM_EECR)),
  PSUM_NDSCR=Convert(Decimal(15,2),SUM(DS.PSUM_NDSCR)),
  PSUM_EXCCR=Convert(Decimal(15,2),SUM(DS.PSUM_EXCCR)),
--сальдо на конец----------------------------------------------------------------
  ERES=
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
        ' РЭС-'+Right(Str(Cs.GROUP_ID),1)+' т.ч. б/НДС'
    END,    
--20%
  ESALDO20=Convert(Decimal(15,2),SUM(DS.ESALDO20)),
  EQUANTITY20=Convert(Integer,SUM(DS.EQUANTITY20)),
  ESUM_EE20=Convert(Decimal(15,2),SUM(DS.ESUM_EE20)),
  ESUM_ACT20=Convert(Decimal(15,2),SUM(DS.ESUM_ACT20)),
  ESUM_EXC20=Convert(Decimal(15,2),SUM(DS.ESUM_EXC20)),
--
  ESALDO20DB=Convert(Decimal(15,2),SUM(DS.ESALDO20DB)),
  EQUANTITY20DB=Convert(Integer,SUM(DS.EQUANTITY20DB)),
  ESUM_EE20DB=Convert(Decimal(15,2),SUM(DS.ESUM_EE20DB)),
  ESUM_ACT20DB=Convert(Decimal(15,2),SUM(DS.ESUM_ACT20DB)),
  ESUM_EXC20DB=Convert(Decimal(15,2),SUM(DS.ESUM_EXC20DB)),
--
  ESALDO20CR=Convert(Decimal(15,2),SUM(DS.ESALDO20CR)),
  EQUANTITY20CR=Convert(Integer,SUM(DS.EQUANTITY20CR)),
  ESUM_EE20CR=Convert(Decimal(15,2),SUM(DS.ESUM_EE20CR)),
  ESUM_ACT20CR=Convert(Decimal(15,2),SUM(DS.ESUM_ACT20CR)),
  ESUM_EXC20CR=Convert(Decimal(15,2),SUM(DS.ESUM_EXC20CR)),
--16%
  ESALDO16=Convert(Decimal(15,2),SUM(DS.ESALDO16)),
  EQUANTITY16=Convert(Integer,SUM(DS.EQUANTITY16)),
  ESUM_EE16=Convert(Decimal(15,2),SUM(DS.ESUM_EE16)),
  ESUM_ACT16=Convert(Decimal(15,2),SUM(DS.ESUM_ACT16)),
  ESUM_EXC16=Convert(Decimal(15,2),SUM(DS.ESUM_EXC16)),
--
  ESALDO16DB=Convert(Decimal(15,2),SUM(DS.ESALDO16DB)),
  EQUANTITY16DB=Convert(Integer,SUM(DS.EQUANTITY16DB)),
  ESUM_EE16DB=Convert(Decimal(15,2),SUM(DS.ESUM_EE16DB)),
  ESUM_ACT16DB=Convert(Decimal(15,2),SUM(DS.ESUM_ACT16DB)),
  ESUM_EXC16DB=Convert(Decimal(15,2),SUM(DS.ESUM_EXC16DB)),
--
  ESALDO16CR=Convert(Decimal(15,2),SUM(DS.ESALDO16CR)),
  EQUANTITY16CR=Convert(Integer,SUM(DS.EQUANTITY16CR)),
  ESUM_EE16CR=Convert(Decimal(15,2),SUM(DS.ESUM_EE16CR)),
  ESUM_ACT16CR=Convert(Decimal(15,2),SUM(DS.ESUM_ACT16CR)),
  ESUM_EXC16CR=Convert(Decimal(15,2),SUM(DS.ESUM_EXC16CR)),
--15%
  ESALDO15=Convert(Decimal(15,2),SUM(DS.ESALDO15)),
  EQUANTITY15=Convert(Integer,SUM(DS.EQUANTITY15)),
  ESUM_EE15=Convert(Decimal(15,2),SUM(DS.ESUM_EE15)),
  ESUM_ACT15=Convert(Decimal(15,2),SUM(DS.ESUM_ACT15)),
  ESUM_EXC15=Convert(Decimal(15,2),SUM(DS.ESUM_EXC15)),
--
  ESALDO15DB=Convert(Decimal(15,2),SUM(DS.ESALDO15DB)),
  EQUANTITY15DB=Convert(Integer,SUM(DS.EQUANTITY15DB)),
  ESUM_EE15DB=Convert(Decimal(15,2),SUM(DS.ESUM_EE15DB)),
  ESUM_ACT15DB=Convert(Decimal(15,2),SUM(DS.ESUM_ACT15DB)),
  ESUM_EXC15DB=Convert(Decimal(15,2),SUM(DS.ESUM_EXC15DB)),
--
  ESALDO15CR=Convert(Decimal(15,2),SUM(DS.ESALDO15CR)),
  EQUANTITY15CR=Convert(Integer,SUM(DS.EQUANTITY15CR)),
  ESUM_EE15CR=Convert(Decimal(15,2),SUM(DS.ESUM_EE15CR)),
  ESUM_ACT15CR=Convert(Decimal(15,2),SUM(DS.ESUM_ACT15CR)),
  ESUM_EXC15CR=Convert(Decimal(15,2),SUM(DS.ESUM_EXC15CR)),
--свод
  ESALDO=Convert(Decimal(15,2),SUM(DS.ESALDO)),
  EQUANTITY=Convert(Integer,SUM(DS.EQUANTITY)),
  ESUM_EE=Convert(Decimal(15,2),SUM(DS.ESUM_EE)),
  ESUM_ACT=Convert(Decimal(15,2),SUM(DS.ESUM_ACT)),
  ESUM_EXC=Convert(Decimal(15,2),SUM(DS.ESUM_EXC)),
--
  ESALDODB=Convert(Decimal(15,2),SUM(DS.ESALDODB)),
  EQUANTITYDB=Convert(Integer,SUM(DS.EQUANTITYDB)),
  ESUM_EEDB=Convert(Decimal(15,2),SUM(DS.ESUM_EEDB)),
  ESUM_ACTDB=Convert(Decimal(15,2),SUM(DS.ESUM_ACTDB)),
  ESUM_EXCDB=Convert(Decimal(15,2),SUM(DS.ESUM_EXCDB)),
--
  ESALDOCR=Convert(Decimal(15,2),SUM(DS.ESALDOCR)),
  EQUANTITYCR=Convert(Integer,SUM(DS.EQUANTITYCR)),
  ESUM_EECR=Convert(Decimal(15,2),SUM(DS.ESUM_EECR)),
  ESUM_ACTCR=Convert(Decimal(15,2),SUM(DS.ESUM_ACTCR)),
  ESUM_EXCCR=Convert(Decimal(15,2),SUM(DS.ESUM_EXCCR))

 FROM
  ProContracts Cs (NoLock),
  ProDivSaldo DS (NoLock)
 WHERE
  DS.CONTRACT_ID=Cs.CONTRACT_ID AND
  DS.DATE_CALC=@dtCalc AND
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
      ' РЭС-'+Right(Str(Cs.GROUP_ID),1)+' т.ч. б/НДС'
  END    
--********************************************

 UNION SELECT
--Итоговое сальдо на начало---------------------------------------------------
  BRES='ИТОГО:',
--20%
  BSALDO20=Convert(Decimal(15,2),SUM(DS.BSALDO20)),
  BQUANTITY20=Convert(Integer,SUM(DS.BQUANTITY20)),
  BSUM_EE20=Convert(Decimal(15,2),SUM(DS.BSUM_EE20)),
  BSUM_ACT20=Convert(Decimal(15,2),SUM(DS.BSUM_ACT20)),
  BSUM_EXC20=Convert(Decimal(15,2),SUM(DS.BSUM_EXC20)),
--
  BSALDO20DB=Convert(Decimal(15,2),SUM(DS.BSALDO20DB)),
  BQUANTITY20DB=Convert(Integer,SUM(DS.BQUANTITY20DB)),
  BSUM_EE20DB=Convert(Decimal(15,2),SUM(DS.BSUM_EE20DB)),
  BSUM_ACT20DB=Convert(Decimal(15,2),SUM(DS.BSUM_ACT20DB)),
  BSUM_EXC20DB=Convert(Decimal(15,2),SUM(DS.BSUM_EXC20DB)),
--
  BSALDO20CR=Convert(Decimal(15,2),SUM(DS.BSALDO20CR)),
  BQUANTITY20CR=Convert(Integer,SUM(DS.BQUANTITY20CR)),
  BSUM_EE20CR=Convert(Decimal(15,2),SUM(DS.BSUM_EE20CR)),
  BSUM_ACT20CR=Convert(Decimal(15,2),SUM(DS.BSUM_ACT20CR)),
  BSUM_EXC20CR=Convert(Decimal(15,2),SUM(DS.BSUM_EXC20CR)),
--16%
  BSALDO16=Convert(Decimal(15,2),SUM(DS.BSALDO16)),
  BQUANTITY16=Convert(Integer,SUM(DS.BQUANTITY16)),
  BSUM_EE16=Convert(Decimal(15,2),SUM(DS.BSUM_EE16)),
  BSUM_ACT16=Convert(Decimal(15,2),SUM(DS.BSUM_ACT16)),
  BSUM_EXC16=Convert(Decimal(15,2),SUM(DS.BSUM_EXC16)),
--
  BSALDO16DB=Convert(Decimal(15,2),SUM(DS.BSALDO16DB)),
  BQUANTITY16DB=Convert(Integer,SUM(DS.BQUANTITY16DB)),
  BSUM_EE16DB=Convert(Decimal(15,2),SUM(DS.BSUM_EE16DB)),
  BSUM_ACT16DB=Convert(Decimal(15,2),SUM(DS.BSUM_ACT16DB)),
  BSUM_EXC16DB=Convert(Decimal(15,2),SUM(DS.BSUM_EXC16DB)),
--
  BSALDO16CR=Convert(Decimal(15,2),SUM(DS.BSALDO16CR)),
  BQUANTITY16CR=Convert(Integer,SUM(DS.BQUANTITY16CR)),
  BSUM_EE16CR=Convert(Decimal(15,2),SUM(DS.BSUM_EE16CR)),
  BSUM_ACT16CR=Convert(Decimal(15,2),SUM(DS.BSUM_ACT16CR)),
  BSUM_EXC16CR=Convert(Decimal(15,2),SUM(DS.BSUM_EXC16CR)),
--15%
  BSALDO15=Convert(Decimal(15,2),SUM(DS.BSALDO15)),
  BQUANTITY15=Convert(Integer,SUM(DS.BQUANTITY15)),
  BSUM_EE15=Convert(Decimal(15,2),SUM(DS.BSUM_EE15)),
  BSUM_ACT15=Convert(Decimal(15,2),SUM(DS.BSUM_ACT15)),
  BSUM_EXC15=Convert(Decimal(15,2),SUM(DS.BSUM_EXC15)),
--
  BSALDO15DB=Convert(Decimal(15,2),SUM(DS.BSALDO15DB)),
  BQUANTITY15DB=Convert(Integer,SUM(DS.BQUANTITY15DB)),
  BSUM_EE15DB=Convert(Decimal(15,2),SUM(DS.BSUM_EE15DB)),
  BSUM_ACT15DB=Convert(Decimal(15,2),SUM(DS.BSUM_ACT15DB)),
  BSUM_EXC15DB=Convert(Decimal(15,2),SUM(DS.BSUM_EXC15DB)),
--
  BSALDO15CR=Convert(Decimal(15,2),SUM(DS.BSALDO15CR)),
  BQUANTITY15CR=Convert(Integer,SUM(DS.BQUANTITY15CR)),
  BSUM_EE15CR=Convert(Decimal(15,2),SUM(DS.BSUM_EE15CR)),
  BSUM_ACT15CR=Convert(Decimal(15,2),SUM(DS.BSUM_ACT15CR)),
  BSUM_EXC15CR=Convert(Decimal(15,2),SUM(DS.BSUM_EXC15CR)),
--свод
  BSALDO=Convert(Decimal(15,2),SUM(DS.BSALDO)),
  BQUANTITY=Convert(Integer,SUM(DS.BQUANTITY)),
  BSUM_EE=Convert(Decimal(15,2),SUM(DS.BSUM_EE)),
  BSUM_ACT=Convert(Decimal(15,2),SUM(DS.BSUM_ACT)),
  BSUM_EXC=Convert(Decimal(15,2),SUM(DS.BSUM_EXC)),
--
  BSALDODB=Convert(Decimal(15,2),SUM(DS.BSALDODB)),
  BQUANTITYDB=Convert(Integer,SUM(DS.BQUANTITYDB)),
  BSUM_EEDB=Convert(Decimal(15,2),SUM(DS.BSUM_EEDB)),
  BSUM_ACTDB=Convert(Decimal(15,2),SUM(DS.BSUM_ACTDB)),
  BSUM_EXCDB=Convert(Decimal(15,2),SUM(DS.BSUM_EXCDB)),
--
  BSALDOCR=Convert(Decimal(15,2),SUM(DS.BSALDOCR)),
  BQUANTITYCR=Convert(Integer,SUM(DS.BQUANTITYCR)),
  BSUM_EECR=Convert(Decimal(15,2),SUM(DS.BSUM_EECR)),
  BSUM_ACTCR=Convert(Decimal(15,2),SUM(DS.BSUM_ACTCR)),
  BSUM_EXCCR=Convert(Decimal(15,2),SUM(DS.BSUM_EXCCR)),

-- Итоговое анчисление-------------------------------------------------------
  NRES='ИТОГО:',
--20%
  NACH20=Convert(Decimal(15,2),SUM(DS.NACH20)),
  NQUANTITY20=Convert(Integer,SUM(DS.NQUANTITY20)),
  NSUM_EE20=Convert(Decimal(15,2),SUM(DS.NSUM_EE20)),
  NSUM_NDS20=Convert(Decimal(15,2),SUM(DS.NSUM_NDS20)),
  NSUM_EXC20=Convert(Decimal(15,2),SUM(DS.NSUM_EXC20)),
--
  NACH20DB=Convert(Decimal(15,2),SUM(DS.NACH20DB)),
  NQUANTITY20DB=Convert(Integer,SUM(DS.NQUANTITY20DB)),
  NSUM_EE20DB=Convert(Decimal(15,2),SUM(DS.NSUM_EE20DB)),
  NSUM_NDS20DB=Convert(Decimal(15,2),SUM(DS.NSUM_NDS20DB)),
  NSUM_EXC20DB=Convert(Decimal(15,2),SUM(DS.NSUM_EXC20DB)),
--
  NACH20CR=Convert(Decimal(15,2),SUM(DS.NACH20CR)),
  NQUANTITY20CR=Convert(Integer,SUM(DS.NQUANTITY20CR)),
  NSUM_EE20CR=Convert(Decimal(15,2),SUM(DS.NSUM_EE20CR)),
  NSUM_NDS20CR=Convert(Decimal(15,2),SUM(DS.NSUM_NDS20CR)),
  NSUM_EXC20CR=Convert(Decimal(15,2),SUM(DS.NSUM_EXC20CR)),
--16%
  NACH16=Convert(Decimal(15,2),SUM(DS.NACH16)),
  NQUANTITY16=Convert(Integer,SUM(DS.NQUANTITY16)),
  NSUM_EE16=Convert(Decimal(15,2),SUM(DS.NSUM_EE16)),
  NSUM_NDS16=Convert(Decimal(15,2),SUM(DS.NSUM_NDS16)),
  NSUM_EXC16=Convert(Decimal(15,2),SUM(DS.NSUM_EXC16)),
--
  NACH16DB=Convert(Decimal(15,2),SUM(DS.NACH16DB)),
  NQUANTITY16DB=Convert(Integer,SUM(DS.NQUANTITY16DB)),
  NSUM_EE16DB=Convert(Decimal(15,2),SUM(DS.NSUM_EE16DB)),
  NSUM_NDS16DB=Convert(Decimal(15,2),SUM(DS.NSUM_NDS16DB)),
  NSUM_EXC16DB=Convert(Decimal(15,2),SUM(DS.NSUM_EXC16DB)),
--
  NACH16CR=Convert(Decimal(15,2),SUM(DS.NACH16CR)),
  NQUANTITY16CR=Convert(Integer,SUM(DS.NQUANTITY16CR)),
  NSUM_EE16CR=Convert(Decimal(15,2),SUM(DS.NSUM_EE16CR)),
  NSUM_NDS16CR=Convert(Decimal(15,2),SUM(DS.NSUM_NDS16CR)),
  NSUM_EXC16CR=Convert(Decimal(15,2),SUM(DS.NSUM_EXC16CR)),
--15%
  NACH15=Convert(Decimal(15,2),SUM(DS.NACH15)),
  NQUANTITY15=Convert(Integer,SUM(DS.NQUANTITY15)),
  NSUM_EE15=Convert(Decimal(15,2),SUM(DS.NSUM_EE15)),
  NSUM_NDS15=Convert(Decimal(15,2),SUM(DS.NSUM_NDS15)),
  NSUM_EXC15=Convert(Decimal(15,2),SUM(DS.NSUM_EXC15)),
--
  NACH15DB=Convert(Decimal(15,2),SUM(DS.NACH15DB)),
  NQUANTITY15DB=Convert(Integer,SUM(DS.NQUANTITY15DB)),
  NSUM_EE15DB=Convert(Decimal(15,2),SUM(DS.NSUM_EE15DB)),
  NSUM_NDS15DB=Convert(Decimal(15,2),SUM(DS.NSUM_NDS15DB)),
  NSUM_EXC15DB=Convert(Decimal(15,2),SUM(DS.NSUM_EXC15DB)),
--
  NACH15CR=Convert(Decimal(15,2),SUM(DS.NACH15CR)),
  NQUANTITY15CR=Convert(Integer,SUM(DS.NQUANTITY15CR)),
  NSUM_EE15CR=Convert(Decimal(15,2),SUM(DS.NSUM_EE15CR)),
  NSUM_NDS15CR=Convert(Decimal(15,2),SUM(DS.NSUM_NDS15CR)),
  NSUM_EXC15CR=Convert(Decimal(15,2),SUM(DS.NSUM_EXC15CR)),
--свод
  NACH=Convert(Decimal(15,2),SUM(DS.NACH)),
  NQUANTITY=Convert(Integer,SUM(DS.NQUANTITY)),
  NSUM_EE=Convert(Decimal(15,2),SUM(DS.NSUM_EE)),
  NSUM_NDS=Convert(Decimal(15,2),SUM(DS.NSUM_NDS)),
  NSUM_EXC=Convert(Decimal(15,2),SUM(DS.NSUM_EXC)),
--
  NACHDB=Convert(Decimal(15,2),SUM(DS.NACHDB)),
  NQUANTITYDB=Convert(Integer,SUM(DS.NQUANTITYDB)),
  NSUM_EEDB=Convert(Decimal(15,2),SUM(DS.NSUM_EEDB)),
  NSUM_NDSDB=Convert(Decimal(15,2),SUM(DS.NSUM_NDSDB)),
  NSUM_EXCDB=Convert(Decimal(15,2),SUM(DS.NSUM_EXCDB)),
--
  NACHCR=Convert(Decimal(15,2),SUM(DS.NACHCR)),
  NQUANTITYCR=Convert(Integer,SUM(DS.NQUANTITYCR)),
  NSUM_EECR=Convert(Decimal(15,2),SUM(DS.NSUM_EECR)),
  NSUM_NDSCR=Convert(Decimal(15,2),SUM(DS.NSUM_NDSCR)),
  NSUM_EXCCR=Convert(Decimal(15,2),SUM(DS.NSUM_EXCCR)),

-- Итоговые платежи ------------------------------------------------------------
  PRES='ИТОГО:',
--20%
  PAY20=Convert(Decimal(15,2),SUM(DS.PAY20)),
  PQUANTITY20=Convert(Integer,SUM(DS.PQUANTITY20)),
  PSUM_EE20=Convert(Decimal(15,2),SUM(DS.PSUM_EE20)),
  PSUM_NDS20=Convert(Decimal(15,2),SUM(DS.PSUM_NDS20)),
  PSUM_EXC20=Convert(Decimal(15,2),SUM(DS.PSUM_EXC20)),
--
  PAY20DB=Convert(Decimal(15,2),SUM(DS.PAY20DB)),
  PQUANTITY20DB=Convert(Integer,SUM(DS.PQUANTITY20DB)),
  PSUM_EE20DB=Convert(Decimal(15,2),SUM(DS.PSUM_EE20DB)),
  PSUM_NDS20DB=Convert(Decimal(15,2),SUM(DS.PSUM_NDS20DB)),
  PSUM_EXC20DB=Convert(Decimal(15,2),SUM(DS.PSUM_EXC20DB)),
--
  PAY20CR=Convert(Decimal(15,2),SUM(DS.PAY20CR)),
  PQUANTITY20CR=Convert(Integer,SUM(DS.PQUANTITY20CR)),
  PSUM_EE20CR=Convert(Decimal(15,2),SUM(DS.PSUM_EE20CR)),
  PSUM_NDS20CR=Convert(Decimal(15,2),SUM(DS.PSUM_NDS20CR)),
  PSUM_EXC20CR=Convert(Decimal(15,2),SUM(DS.PSUM_EXC20CR)),
--16%
  PAY16=Convert(Decimal(15,2),SUM(DS.PAY16)),
  PQUANTITY16=Convert(Integer,SUM(DS.PQUANTITY16)),
  PSUM_EE16=Convert(Decimal(15,2),SUM(DS.PSUM_EE16)),
  PSUM_NDS16=Convert(Decimal(15,2),SUM(DS.PSUM_NDS16)),
  PSUM_EXC16=Convert(Decimal(15,2),SUM(DS.PSUM_EXC16)),
--
  PAY16DB=Convert(Decimal(15,2),SUM(DS.PAY16DB)),
  PQUANTITY16DB=Convert(Integer,SUM(DS.PQUANTITY16DB)),
  PSUM_EE16DB=Convert(Decimal(15,2),SUM(DS.PSUM_EE16DB)),
  PSUM_NDS16DB=Convert(Decimal(15,2),SUM(DS.PSUM_NDS16DB)),
  PSUM_EXC16DB=Convert(Decimal(15,2),SUM(DS.PSUM_EXC16DB)),
--
  PAY16CR=Convert(Decimal(15,2),SUM(DS.PAY16CR)),
  PQUANTITY16CR=Convert(Integer,SUM(DS.PQUANTITY16CR)),
  PSUM_EE16CR=Convert(Decimal(15,2),SUM(DS.PSUM_EE16CR)),
  PSUM_NDS16CR=Convert(Decimal(15,2),SUM(DS.PSUM_NDS16CR)),
  PSUM_EXC16CR=Convert(Decimal(15,2),SUM(DS.PSUM_EXC16CR)),
--15%
  PAY15=Convert(Decimal(15,2),SUM(DS.PAY15)),
  PQUANTITY15=Convert(Integer,SUM(DS.PQUANTITY15)),
  PSUM_EE15=Convert(Decimal(15,2),SUM(DS.PSUM_EE15)),
  PSUM_NDS15=Convert(Decimal(15,2),SUM(DS.PSUM_NDS15)),
  PSUM_EXC15=Convert(Decimal(15,2),SUM(DS.PSUM_EXC15)),
--
  PAY15DB=Convert(Decimal(15,2),SUM(DS.PAY15DB)),
  PQUANTITY15DB=Convert(Integer,SUM(DS.PQUANTITY15DB)),
  PSUM_EE15DB=Convert(Decimal(15,2),SUM(DS.PSUM_EE15DB)),
  PSUM_NDS15DB=Convert(Decimal(15,2),SUM(DS.PSUM_NDS15DB)),
  PSUM_EXC15DB=Convert(Decimal(15,2),SUM(DS.PSUM_EXC15DB)),
--
  PAY15CR=Convert(Decimal(15,2),SUM(DS.PAY15CR)),
  PQUANTITY15CR=Convert(Integer,SUM(DS.PQUANTITY15CR)),
  PSUM_EE15CR=Convert(Decimal(15,2),SUM(DS.PSUM_EE15CR)),
  PSUM_NDS15CR=Convert(Decimal(15,2),SUM(DS.PSUM_NDS15CR)),
  PSUM_EXC15CR=Convert(Decimal(15,2),SUM(DS.PSUM_EXC15CR)),
--свод
  PAY=Convert(Decimal(15,2),SUM(DS.PAY)),
  PQUANTITY=Convert(Integer,SUM(DS.PQUANTITY)),
  PSUM_EE=Convert(Decimal(15,2),SUM(DS.PSUM_EE)),
  PSUM_NDS=Convert(Decimal(15,2),SUM(DS.PSUM_NDS)),
  PSUM_EXC=Convert(Decimal(15,2),SUM(DS.PSUM_EXC)),
--
  PAYDB=Convert(Decimal(15,2),SUM(DS.PAYDB)),
  PQUANTITYDB=Convert(Integer,SUM(DS.PQUANTITYDB)),
  PSUM_EEDB=Convert(Decimal(15,2),SUM(DS.PSUM_EEDB)),
  PSUM_NDSDB=Convert(Decimal(15,2),SUM(DS.PSUM_NDSDB)),
  PSUM_EXCDB=Convert(Decimal(15,2),SUM(DS.PSUM_EXCDB)),
--
  PAYCR=Convert(Decimal(15,2),SUM(DS.PAYCR)),
  PQUANTITYCR=Convert(Integer,SUM(DS.PQUANTITYCR)),
  PSUM_EECR=Convert(Decimal(15,2),SUM(DS.PSUM_EECR)),
  PSUM_NDSCR=Convert(Decimal(15,2),SUM(DS.PSUM_NDSCR)),
  PSUM_EXCCR=Convert(Decimal(15,2),SUM(DS.PSUM_EXCCR)),

-- Итоговое конечное сальдо----------------------------------------------
  ERES='ИТОГО:',
--20%
  ESALDO20=Convert(Decimal(15,2),SUM(DS.ESALDO20)),
  EQUANTITY20=Convert(Integer,SUM(DS.EQUANTITY20)),
  ESUM_EE20=Convert(Decimal(15,2),SUM(DS.ESUM_EE20)),
  ESUM_ACT20=Convert(Decimal(15,2),SUM(DS.ESUM_ACT20)),
  ESUM_EXC20=Convert(Decimal(15,2),SUM(DS.ESUM_EXC20)),
--
  ESALDO20DB=Convert(Decimal(15,2),SUM(DS.ESALDO20DB)),
  EQUANTITY20DB=Convert(Integer,SUM(DS.EQUANTITY20DB)),
  ESUM_EE20DB=Convert(Decimal(15,2),SUM(DS.ESUM_EE20DB)),
  ESUM_ACT20DB=Convert(Decimal(15,2),SUM(DS.ESUM_ACT20DB)),
  ESUM_EXC20DB=Convert(Decimal(15,2),SUM(DS.ESUM_EXC20DB)),
--
  ESALDO20CR=Convert(Decimal(15,2),SUM(DS.ESALDO20CR)),
  EQUANTITY20CR=Convert(Integer,SUM(DS.EQUANTITY20CR)),
  ESUM_EE20CR=Convert(Decimal(15,2),SUM(DS.ESUM_EE20CR)),
  ESUM_ACT20CR=Convert(Decimal(15,2),SUM(DS.ESUM_ACT20CR)),
  ESUM_EXC20CR=Convert(Decimal(15,2),SUM(DS.ESUM_EXC20CR)),
--16%
  ESALDO16=Convert(Decimal(15,2),SUM(DS.ESALDO16)),
  EQUANTITY16=Convert(Integer,SUM(DS.EQUANTITY16)),
  ESUM_EE16=Convert(Decimal(15,2),SUM(DS.ESUM_EE16)),
  ESUM_ACT16=Convert(Decimal(15,2),SUM(DS.ESUM_ACT16)),
  ESUM_EXC16=Convert(Decimal(15,2),SUM(DS.ESUM_EXC16)),
--
  ESALDO16DB=Convert(Decimal(15,2),SUM(DS.ESALDO16DB)),
  EQUANTITY16DB=Convert(Integer,SUM(DS.EQUANTITY16DB)),
  ESUM_EE16DB=Convert(Decimal(15,2),SUM(DS.ESUM_EE16DB)),
  ESUM_ACT16DB=Convert(Decimal(15,2),SUM(DS.ESUM_ACT16DB)),
  ESUM_EXC16DB=Convert(Decimal(15,2),SUM(DS.ESUM_EXC16DB)),
--
  ESALDO16CR=Convert(Decimal(15,2),SUM(DS.ESALDO16CR)),
  EQUANTITY16CR=Convert(Integer,SUM(DS.EQUANTITY16CR)),
  ESUM_EE16CR=Convert(Decimal(15,2),SUM(DS.ESUM_EE16CR)),
  ESUM_ACT16CR=Convert(Decimal(15,2),SUM(DS.ESUM_ACT16CR)),
  ESUM_EXC16CR=Convert(Decimal(15,2),SUM(DS.ESUM_EXC16CR)),
--15%
--
  ESALDO15=Convert(Decimal(15,2),SUM(DS.ESALDO15)),
  EQUANTITY15=Convert(Integer,SUM(DS.EQUANTITY15)),
  ESUM_EE15=Convert(Decimal(15,2),SUM(DS.ESUM_EE15)),
  ESUM_ACT15=Convert(Decimal(15,2),SUM(DS.ESUM_ACT15)),
  ESUM_EXC15=Convert(Decimal(15,2),SUM(DS.ESUM_EXC15)),
--
  ESALDO15DB=Convert(Decimal(15,2),SUM(DS.ESALDO15DB)),
  EQUANTITY15DB=Convert(Integer,SUM(DS.EQUANTITY15DB)),
  ESUM_EE15DB=Convert(Decimal(15,2),SUM(DS.ESUM_EE15DB)),
  ESUM_ACT15DB=Convert(Decimal(15,2),SUM(DS.ESUM_ACT15DB)),
  ESUM_EXC15DB=Convert(Decimal(15,2),SUM(DS.ESUM_EXC15DB)),
--
  ESALDO15CR=Convert(Decimal(15,2),SUM(DS.ESALDO15CR)),
  EQUANTITY15CR=Convert(Integer,SUM(DS.EQUANTITY15CR)),
  ESUM_EE15CR=Convert(Decimal(15,2),SUM(DS.ESUM_EE15CR)),
  ESUM_ACT15CR=Convert(Decimal(15,2),SUM(DS.ESUM_ACT15CR)),
  ESUM_EXC15CR=Convert(Decimal(15,2),SUM(DS.ESUM_EXC15CR)),
--свод
  ESALDO=Convert(Decimal(15,2),SUM(DS.ESALDO)),
  EQUANTITY=Convert(Integer,SUM(DS.EQUANTITY)),
  ESUM_EE=Convert(Decimal(15,2),SUM(DS.ESUM_EE)),
  ESUM_ACT=Convert(Decimal(15,2),SUM(DS.ESUM_ACT)),
  ESUM_EXC=Convert(Decimal(15,2),SUM(DS.ESUM_EXC)),
--
  ESALDODB=Convert(Decimal(15,2),SUM(DS.ESALDODB)),
  EQUANTITYDB=Convert(Integer,SUM(DS.EQUANTITYDB)),
  ESUM_EEDB=Convert(Decimal(15,2),SUM(DS.ESUM_EEDB)),
  ESUM_ACTDB=Convert(Decimal(15,2),SUM(DS.ESUM_ACTDB)),
  ESUM_EXCDB=Convert(Decimal(15,2),SUM(DS.ESUM_EXCDB)),
--
  ESALDOCR=Convert(Decimal(15,2),SUM(DS.ESALDOCR)),
  EQUANTITYCR=Convert(Integer,SUM(DS.EQUANTITYCR)),
  ESUM_EECR=Convert(Decimal(15,2),SUM(DS.ESUM_EECR)),
  ESUM_ACTCR=Convert(Decimal(15,2),SUM(DS.ESUM_ACTCR)),
  ESUM_EXCCR=Convert(Decimal(15,2),SUM(DS.ESUM_EXCCR))
 FROM
  ProContracts Cs (NoLock),
  ProDivSaldo DS (NoLock)
 WHERE
  DS.CONTRACT_ID=Cs.CONTRACT_ID AND
  DS.DATE_CALC=@dtCalc
 ORDER BY
  BRES
