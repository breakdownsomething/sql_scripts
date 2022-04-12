--***************************************************************************
-- Реестр заполненных договоров к плану потребления на 2005 г. "Форма 1-Е"  
-- Можно также делать выборку по конкретному РЭСу или инженеру-расчетчику
-- Шибицкий В.П.   гл.специалист ДРППО    21-06-04г.
--***************************************************************************
USE aspElectricPro
SELECT
	'РЭС'=RIGHT(pc.GROUP_ID,1),
	'№ дог.'=pc.CONTRACT_NUMBER,
	'Наименование'=pa.ABONENT_NAME,
	'План кВт.ч на 2005г.'=SUM(ppd.CALC_QUANTITY),
	'Инженер-расчетчик'='('+CONVERT(varchar(1),pc.SUBGROUP_ID)+')'++pgs.SUBGROUP_NAME
FROM
	ProAbonents pa,
	ProContracts pc,
	ProPlanDetails ppd,
	ProGroupSub pgs
WHERE
--	pc.GROUP_ID=10019		AND  /* Можно указать конкретный РЭС*/
--	pc.SUBGROUP_ID=2		AND  /* Можно указать конкретную группу договоров*/
	pc.ABONENT_ID=pa.ABONENT_ID	AND
	ppd.CONTRACT_ID=pc.CONTRACT_ID	AND
	pc.CONTRACT_NUMBER = '20002'	AND
	YEAR(ppd.DATE_CALC)=2005	AND
	pgs.GROUP_ID=pc.GROUP_ID	AND
	pgs.SUBGROUP_ID=pc.SUBGROUP_ID  
--        AND ppd.MEASURE_ID=4
and ppd.TARIFF_ID Not In(1,26,106)
GROUP BY
	pc.GROUP_ID,
	pc.SUBGROUP_ID,
	pc.CONTRACT_NUMBER,
	pa.ABONENT_NAME,
	pgs.SUBGROUP_NAME
ORDER BY
	pc.GROUP_ID,
	pc.SUBGROUP_ID,
	pc.CONTRACT_NUMBER


--***************************************************************************
-- Реестр незаполненных договоров к плану потребления на 2005 г. "Форма 1-Е"  
-- Можно также делать выборку по конкретному РЭСу или инженеру-расчетчику
-- Шибицкий В.П.   гл.специалист ДРППО    21-06-03г.
--***************************************************************************
USE aspElectricPro
SELECT
	'РЭС'=RIGHT(pc.GROUP_ID,1),
	'№ дог.'=pc.CONTRACT_NUMBER,
	'Наименование'=pa.ABONENT_NAME,
	'План кВт.ч на 2005г.'=0,
	'Инженер-расчетчик'='('+CONVERT(varchar(1),pc.SUBGROUP_ID)+')'++pgs.SUBGROUP_NAME
FROM
	ProAbonents pa,
	ProContracts pc,
	ProGroupSub pgs
WHERE
--	pc.GROUP_ID=10019		AND  /* Можно указать конкретный РЭС*/
--	pc.SUBGROUP_ID=2		AND  /* Можно указать конкретную группу договоров*/
	pc.ABONENT_ID=pa.ABONENT_ID	AND
--	pc.CONTRACT_NUMBER = '1126'	AND
	pgs.GROUP_ID=pc.GROUP_ID	AND
	pgs.SUBGROUP_ID=pc.SUBGROUP_ID  
--        AND ppd.MEASURE_ID=4
AND NOT EXISTS (SELECT * FROM ProPlanDetails WHERE CONTRACT_ID=pc.CONTRACT_ID AND YEAR(DATE_CALC)=2005)
GROUP BY
	pc.GROUP_ID,
	pc.SUBGROUP_ID,
	pc.CONTRACT_NUMBER,
	pa.ABONENT_NAME,
	pgs.SUBGROUP_NAME
ORDER BY
	pc.GROUP_ID,
	pc.SUBGROUP_ID,
	pc.CONTRACT_NUMBER


