--***************************************************************************
-- ������ ����������� ��������� � ����� ����������� �� 2005 �. "����� 1-�"  
-- ����� ����� ������ ������� �� ����������� ���� ��� ��������-����������
-- �������� �.�.   ��.���������� �����    21-06-04�.
--***************************************************************************
USE aspElectricPro
SELECT
	'���'=RIGHT(pc.GROUP_ID,1),
	'� ���.'=pc.CONTRACT_NUMBER,
	'������������'=pa.ABONENT_NAME,
	'���� ���.� �� 2005�.'=SUM(ppd.CALC_QUANTITY),
	'�������-���������'='('+CONVERT(varchar(1),pc.SUBGROUP_ID)+')'++pgs.SUBGROUP_NAME
FROM
	ProAbonents pa,
	ProContracts pc,
	ProPlanDetails ppd,
	ProGroupSub pgs
WHERE
--	pc.GROUP_ID=10019		AND  /* ����� ������� ���������� ���*/
--	pc.SUBGROUP_ID=2		AND  /* ����� ������� ���������� ������ ���������*/
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
-- ������ ������������� ��������� � ����� ����������� �� 2005 �. "����� 1-�"  
-- ����� ����� ������ ������� �� ����������� ���� ��� ��������-����������
-- �������� �.�.   ��.���������� �����    21-06-03�.
--***************************************************************************
USE aspElectricPro
SELECT
	'���'=RIGHT(pc.GROUP_ID,1),
	'� ���.'=pc.CONTRACT_NUMBER,
	'������������'=pa.ABONENT_NAME,
	'���� ���.� �� 2005�.'=0,
	'�������-���������'='('+CONVERT(varchar(1),pc.SUBGROUP_ID)+')'++pgs.SUBGROUP_NAME
FROM
	ProAbonents pa,
	ProContracts pc,
	ProGroupSub pgs
WHERE
--	pc.GROUP_ID=10019		AND  /* ����� ������� ���������� ���*/
--	pc.SUBGROUP_ID=2		AND  /* ����� ������� ���������� ������ ���������*/
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


