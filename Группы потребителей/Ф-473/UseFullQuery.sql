--************************************************************************
DECLARE
	@ContractId Integer,
	@ContractNumber varchar(10),
	@DatBegYear SmallDateTime,
	@DatGrp SmallDateTime,
	@DatBeg SmallDateTime,
	@DatEnd SmallDateTime

SELECT
	@ContractId = 0, --:pContractId,
  @DatGrp     = '2004-01-31', --:pdtCalcEnd,
  @DatEnd     = '2004-11-30', --:pdtDateEnd,

	@DatBegYear=convert(SmallDateTime,convert(varchar(4),YEAR(@DatGrp))+'-01-31'),
	@DatBeg=DATEADD(mm,-1,DATEADD(dd,1,@DatEnd))
--************************************************************************
 IF @ContractId<>0
 SELECT @ContractNumber=CONTRACT_NUMBER
 FROM ProContracts
 WHERE CONTRACT_ID=@ContractId
--************************************************************************
CREATE TABLE #TmpCalendar (
	DATE_CALC SmallDateTime)
CREATE TABLE #TmpTable1 (
	CONTRACT_ID	int,
	DATE_CALC 	SmallDateTime,
	SALDO		decimal(18,2) DEFAULT 0,
	SROK		SmallInt DEFAULT 0,
	SUM_CALC	decimal(18,2) DEFAULT 0,
	SUM_PAY		decimal(18,2) DEFAULT 0,
	SUM_PAY_DEBT	decimal(18,2) DEFAULT 0,
	SUM_REM_DEBT	decimal(18,2) DEFAULT 0)
CREATE TABLE #TmpTable2 (
	CONTRACT_ID	int,
	DATE_CALC 	SmallDateTime,
	SALDO		decimal(18,2) DEFAULT 0,
	SROK		SmallInt DEFAULT 0,
	SUM_CALC	decimal(18,2) DEFAULT 0,
	SUM_PAY		decimal(18,2) DEFAULT 0,
	SUM_PAY_DEBT	decimal(18,2) DEFAULT 0,
	SUM_REM_DEBT	decimal(18,2) DEFAULT 0)
--************************************************************************
INSERT #TmpCalendar SELECT @DatBegYear
INSERT #TmpCalendar SELECT dateadd(dd,-1,dateadd(mm,1,dateadd(dd,1,@DatBegYear)))
INSERT #TmpCalendar SELECT dateadd(dd,-1,dateadd(mm,2,dateadd(dd,1,@DatBegYear)))
INSERT #TmpCalendar SELECT dateadd(dd,-1,dateadd(mm,3,dateadd(dd,1,@DatBegYear)))
INSERT #TmpCalendar SELECT dateadd(dd,-1,dateadd(mm,4,dateadd(dd,1,@DatBegYear)))
INSERT #TmpCalendar SELECT dateadd(dd,-1,dateadd(mm,5,dateadd(dd,1,@DatBegYear)))
INSERT #TmpCalendar SELECT dateadd(dd,-1,dateadd(mm,6,dateadd(dd,1,@DatBegYear)))
INSERT #TmpCalendar SELECT dateadd(dd,-1,dateadd(mm,7,dateadd(dd,1,@DatBegYear)))
INSERT #TmpCalendar SELECT dateadd(dd,-1,dateadd(mm,8,dateadd(dd,1,@DatBegYear)))
INSERT #TmpCalendar SELECT dateadd(dd,-1,dateadd(mm,9,dateadd(dd,1,@DatBegYear)))
INSERT #TmpCalendar SELECT dateadd(dd,-1,dateadd(mm,10,dateadd(dd,1,@DatBegYear)))
INSERT #TmpCalendar SELECT dateadd(dd,-1,dateadd(mm,11,dateadd(dd,1,@DatBegYear)))
--************************************************************************
IF YEAR(@DatGrp)<YEAR(@DatEnd)
UPDATE #TmpCalendar SET DATE_CALC=dateadd(yy,1,DATE_CALC) WHERE MONTH(DATE_CALC)<=MONTH(@DatEnd)
--************************************************************************
INSERT #TmpTable1
	(CONTRACT_ID,
	DATE_CALC,
	SUM_PAY_DEBT)
SELECT
	pgd.CONTRACT_ID,
	tc.DATE_CALC,
	SUM(0)
FROM
	#TmpCalendar tc,
	ProGraphDebt pgd
WHERE
	pgd.DATE_CALC>=@DatGrp
GROUP BY
	pgd.CONTRACT_ID,
	tc.DATE_CALC
--************************************************************************
INSERT #TmpTable1
	(CONTRACT_ID,
	DATE_CALC,
	SUM_PAY_DEBT)
SELECT
	CONTRACT_ID,
	DATE_CALC,
	pgd.SUM_PAY_DEBT
FROM
	ProGraphDebt pgd
WHERE
	pgd.DATE_CALC>=@DatGrp

INSERT #TmpTable2
	(CONTRACT_ID,
	DATE_CALC,
	SUM_PAY_DEBT)
SELECT
	CONTRACT_ID,
	DATE_CALC,
	SUM(SUM_PAY_DEBT)
FROM
	#TmpTable1
GROUP BY
	CONTRACT_ID,
	DATE_CALC
--************************************************************************
TRUNCATE TABLE #TmpTable1
INSERT #TmpTable1
	(CONTRACT_ID,
	DATE_CALC,
	SALDO,
	SROK,
	SUM_CALC,
	SUM_PAY,
	SUM_PAY_DEBT,
	SUM_REM_DEBT)
SELECT
	tt.CONTRACT_ID,
	tt.DATE_CALC,
	ISNull(SUM(pc.SALDO),0),
	ISNull(SROK,0),
	IsNull(SUM(pc.SUM_FACT+pc.SUM_NDS+pc.SUM_EXC),0),
	ISNull(SUM_PAY,0),
	ISNull(SUM_PAY_DEBT,0),
	ISNull(SUM_REM_DEBT,0)
FROM
	#TmpTable2 tt,
	ProCalcs pc
WHERE
	pc.CONTRACT_ID=*tt.CONTRACT_ID	AND
	pc.DATE_CALC<@DatEnd		AND
	pc.DATE_CALC=*tt.DATE_CALC
GROUP BY
	tt.CONTRACT_ID,
	tt.DATE_CALC,
	tt.SROK,
	tt.SUM_PAY,
	tt.SUM_PAY_DEBT,
	tt.SUM_REM_DEBT
--************************************************************************
IF  @DatEnd=(SELECT TOP 1 DATE_CALC_END FROM ProGroups)
UPDATE #TmpTable1 SET SALDO=pc.SALDO
FROM
	#TmpTable1 tt,
	ProContracts pc
WHERE
	pc.CONTRACT_ID=tt.CONTRACT_ID	AND
	tt.DATE_CALC=@DatEnd

--************************************************************************
TRUNCATE TABLE #TmpTable2
INSERT #TmpTable2
	(CONTRACT_ID,
	DATE_CALC,
	SALDO,
	SROK,
	SUM_CALC,
	SUM_PAY,
	SUM_PAY_DEBT,
	SUM_REM_DEBT)
SELECT
	tt.CONTRACT_ID,
	tt.DATE_CALC,
	tt.SALDO,
	IsNull(SUM(DATEDIFF(mm,pr.DATE_BEGIN,pr.DATE_END)),-1),
	tt.SUM_CALC,
	IsNull(tt.SUM_PAY,0),
	tt.SUM_PAY_DEBT,
	tt.SUM_REM_DEBT
FROM
	#TmpTable1 tt,
	ProRemainds pr
WHERE
	pr.CONTRACT_ID=*tt.CONTRACT_ID	AND
	pr.DATE_END=*tt.DATE_CALC
GROUP BY
	tt.CONTRACT_ID,
	tt.DATE_CALC,
	tt.SALDO,
	tt.SUM_CALC,
	tt.SUM_PAY,
	tt.SUM_PAY_DEBT,
	tt.SUM_REM_DEBT
--************************************************************************
TRUNCATE TABLE #TmpTable1
INSERT #TmpTable1
	(CONTRACT_ID,
	DATE_CALC,
	SALDO,
	SROK,
	SUM_CALC,
	SUM_PAY,
	SUM_PAY_DEBT,
	SUM_REM_DEBT)
SELECT
	tt.CONTRACT_ID,
	tt.DATE_CALC,
	tt.SALDO,
	tt.SROK,
	tt.SUM_CALC,
	IsNull(SUM(pp.SUM_EE+pp.SUM_ACT),0),
	tt.SUM_PAY_DEBT,
	tt.SUM_REM_DEBT
FROM
	#TmpTable2 tt,
	ProPayments pp
WHERE
	pp.CONTRACT_ID=*tt.CONTRACT_ID		AND
	pp.DATE_PAY<DATEADD(mm,-1,DATEADD(dd,1,@DatEnd))	 	AND
	YEAR(pp.DATE_PAY)=*YEAR(tt.DATE_CALC) 	AND
	MONTH(pp.DATE_PAY)=*MONTH(tt.DATE_CALC)
GROUP BY
	tt.CONTRACT_ID,
	tt.DATE_CALC,
	tt.SALDO,
	tt.SROK,
	tt.SUM_CALC,
	tt.SUM_PAY_DEBT,
	tt.SUM_REM_DEBT
--************************************************************************
UPDATE #TmpTable1 SET
	SALDO=IsNull(SALDO,0),
	SROK=IsNull(SROK,0),
	SUM_CALC=IsNull(SUM_CALC,0),
	SUM_PAY=IsNull(SUM_PAY,0),
	SUM_PAY_DEBT=IsNull(SUM_PAY_DEBT,0),
	SUM_REM_DEBT=CASE WHEN IsNull(SUM_PAY_DEBT,0)=0 THEN 0 ELSE IsNull(SALDO,0)+IsNull(SUM_CALC,0)-IsNull(SUM_PAY,0) END
--************************************************************************
SELECT
	CONTRACT_ID,
	DATE_CALC=@DatGrp,
	SUM_CALC=SUM(IsNull(SUM_CALC,0)),
	SUM_PAY=SUM(IsNull(SUM_PAY,0)),
	SROK =SUM(CASE WHEN MONTH(tt.DATE_CALC)=MONTH(@DatGrp) THEN tt.SROK ELSE 0 END),
	SALDO_GRP=SUM(CASE WHEN MONTH(tt.DATE_CALC)=MONTH(@DatGrp) THEN tt.SALDO ELSE 0 END),
	SALDO_CUR=SUM(CASE WHEN MONTH(tt.DATE_CALC)=MONTH(@DatEnd) THEN tt.SALDO ELSE 0 END),
	SPD1= SUM(CASE WHEN MONTH(tt.DATE_CALC)=1  THEN tt.SUM_PAY_DEBT ELSE 0 END),
	SPD2= SUM(CASE WHEN MONTH(tt.DATE_CALC)=2  THEN tt.SUM_PAY_DEBT ELSE 0 END),
	SPD3= SUM(CASE WHEN MONTH(tt.DATE_CALC)=3  THEN tt.SUM_PAY_DEBT ELSE 0 END),
	SPD4= SUM(CASE WHEN MONTH(tt.DATE_CALC)=4  THEN tt.SUM_PAY_DEBT ELSE 0 END),
	SPD5= SUM(CASE WHEN MONTH(tt.DATE_CALC)=5  THEN tt.SUM_PAY_DEBT ELSE 0 END),
	SPD6= SUM(CASE WHEN MONTH(tt.DATE_CALC)=6  THEN tt.SUM_PAY_DEBT ELSE 0 END),
	SPD7= SUM(CASE WHEN MONTH(tt.DATE_CALC)=7  THEN tt.SUM_PAY_DEBT ELSE 0 END),
	SPD8= SUM(CASE WHEN MONTH(tt.DATE_CALC)=8  THEN tt.SUM_PAY_DEBT ELSE 0 END),
	SPD9= SUM(CASE WHEN MONTH(tt.DATE_CALC)=9  THEN tt.SUM_PAY_DEBT ELSE 0 END),
	SPD10=SUM(CASE WHEN MONTH(tt.DATE_CALC)=10 THEN tt.SUM_PAY_DEBT ELSE 0 END),
	SPD11=SUM(CASE WHEN MONTH(tt.DATE_CALC)=11 THEN tt.SUM_PAY_DEBT ELSE 0 END),
	SPD12=SUM(CASE WHEN MONTH(tt.DATE_CALC)=12 THEN tt.SUM_PAY_DEBT ELSE 0 END),
	SPD13=SUM(tt.SUM_PAY_DEBT),
	REM1= SUM(CASE WHEN MONTH(tt.DATE_CALC)=1  THEN tt.SUM_REM_DEBT ELSE 0 END),
	REM2= SUM(CASE WHEN MONTH(tt.DATE_CALC)=2  THEN tt.SUM_REM_DEBT ELSE 0 END),
	REM3= SUM(CASE WHEN MONTH(tt.DATE_CALC)=3  THEN tt.SUM_REM_DEBT ELSE 0 END),
	REM4= SUM(CASE WHEN MONTH(tt.DATE_CALC)=4  THEN tt.SUM_REM_DEBT ELSE 0 END),
	REM5= SUM(CASE WHEN MONTH(tt.DATE_CALC)=5  THEN tt.SUM_REM_DEBT ELSE 0 END),
	REM6= SUM(CASE WHEN MONTH(tt.DATE_CALC)=6  THEN tt.SUM_REM_DEBT ELSE 0 END),
	REM7= SUM(CASE WHEN MONTH(tt.DATE_CALC)=7  THEN tt.SUM_REM_DEBT ELSE 0 END),
	REM8= SUM(CASE WHEN MONTH(tt.DATE_CALC)=8  THEN tt.SUM_REM_DEBT ELSE 0 END),
	REM9= SUM(CASE WHEN MONTH(tt.DATE_CALC)=9  THEN tt.SUM_REM_DEBT ELSE 0 END),
	REM10=SUM(CASE WHEN MONTH(tt.DATE_CALC)=10 THEN tt.SUM_REM_DEBT ELSE 0 END),
	REM11=SUM(CASE WHEN MONTH(tt.DATE_CALC)=11 THEN tt.SUM_REM_DEBT ELSE 0 END),
	REM12=SUM(CASE WHEN MONTH(tt.DATE_CALC)=12 THEN tt.SUM_REM_DEBT ELSE 0 END)
INTO #TmpTable3
FROM
	#TmpTable1 tt
GROUP BY
	CONTRACT_ID,
	DATE_CALC
ORDER BY
	CONTRACT_ID
--*************************************************************
UPDATE #TmpTable3 SET	SALDO_CUR=SALDO_GRP+SUM_CALC-SUM_PAY
--*************************************************************
SELECT
	RIGHT(pc.GROUP_ID,1) AS "���",
	pc.CONTRACT_NUMBER AS "� ���.",
        pa.ABONENT_NAME AS "�������",
	CASE WHEN SUM(SROK)>0 THEN SUM(SROK) ELSE 0 END AS "����",
	SUM(tt.SALDO_GRP) AS "������(���)",
	SUM(SPD1) AS "������",
	SUM(SPD2) AS "�������",
	SUM(SPD3) AS "����",
	SUM(SPD4) AS "������",
	SUM(SPD5) AS "���",
	SUM(SPD6) AS "����",
	SUM(SPD7) AS "����",
	SUM(SPD8) AS "������",
	SUM(SPD9) AS "��������",
	SUM(SPD10) AS "�������",
	SUM(SPD11) AS "������",
	SUM(SPD12) AS "�������",
	SUM(SPD13) AS "����� �����",
        SUM(SUM_CALC) AS "���������",
	SUM(SUM_PAY) AS "��������",
        CASE
        WHEN SUM(SUM_PAY)>SUM(SUM_CALC) THEN SUM(SUM_PAY)-SUM(SUM_CALC)
        ELSE 0 END AS "�� ������ �����",
	CASE
        WHEN SUM(IsNull(tt.SALDO_CUR,0))<=0 THEN 0
        WHEN SUM(tt.SPD13)-(SUM(SUM_PAY)-SUM(SUM_CALC))<=0 THEN 0
        WHEN SUM(SUM_PAY)>SUM(SUM_CALC) THEN SUM(tt.SPD13)-(SUM(SUM_PAY)-SUM(SUM_CALC))
        ELSE SUM(tt.SPD13) END AS "������� �����",
	SUM(tt.SALDO_CUR) AS "������(���)",
        CASE
        WHEN SUM(tt.SALDO_CUR)<=0 THEN 100
        WHEN SUM(tt.SPD13)-(SUM(SUM_PAY)-SUM(SUM_CALC))<=0 THEN 100
        WHEN SUM(SUM_PAY)<=SUM(SUM_CALC) THEN 0
        ELSE Convert( integer,(SUM(SUM_PAY)-SUM(SUM_CALC))/SUM(SPD13)*100)
        END AS "% ���������",
	pc.CONSUMER_GROUP_ID  AS "���������",
        UNION_GROUP_ID=0,
        SUM_GROUP_ID=0
INTO 	#TmpTable4
FROM
	#TmpTable3 tt,
	ProContracts pc,
	ProAbonents pa--,
--	#TmpPart tp
WHERE
--	tt.CONTRACT_ID=tp.CONTRACT_ID	AND
	pc.CONTRACT_ID=tt.CONTRACT_ID	AND
	pa.ABONENT_ID=pc.ABONENT_ID
GROUP BY
	pc.GROUP_ID,
	pc.CONTRACT_NUMBER,
        pa.ABONENT_NAME,
	pc.CONSUMER_GROUP_ID
ORDER BY
	pc.GROUP_ID,
	RIGHT(SPACE(10)+pc.CONTRACT_NUMBER,10)
--************************************************************************
--DM
-----------------------------------------------
UPDATE #TmpTable4
SET UNION_GROUP_ID = PCG.top_group_id * 10
from ProConsumerGroups PCG (nolock)
where [���������] = PCG.consumer_group_id
------------------------------------------------
/*
UPDATE #TmpTable4 SET UNION_GROUP_ID= CASE
	WHEN [���������] IN (121,124,211,214) THEN 10
	WHEN [���������] IN (122,204,205,206,207,208,209,212,215,222,223,224,225,226,227) THEN 20
	WHEN [���������] IN (213,216) THEN 30
	WHEN [���������] IN (110) THEN 40
	WHEN [���������] IN (120,123,129,130,140,150) THEN 50
	WHEN [���������] IN (0,240,220,221,229,250,300) THEN 60
	WHEN [���������] IN (231,232,230,233) THEN 70
	END
*/
--************************************************************************
INSERT  #TmpTable4
SELECT
	'' AS "���",
	'' AS "� ���.",
	'�����:' AS "�������",
	'' AS "����",
	SUM([������(���)]) AS "������(���)",
	SUM([������]) AS "������",
	SUM([�������]) AS "�������",
	SUM([����]) AS "����",
	SUM([������]) AS "������",
	SUM([���]) AS "���",
	SUM([����]) AS "����",
	SUM([����]) AS "����",
	SUM([������]) AS "������",
	SUM([��������]) AS "��������",
	SUM([�������]) AS "�������",
	SUM([������]) AS "������",
	SUM([�������]) AS "�������",
	SUM([����� �����]) AS "����� �����",
        SUM([���������]) AS "���������",
	SUM([��������]) AS "��������",
	SUM([�� ������ �����])AS "�� ������ �����",
	SUM([������� �����]) AS "������� �����",
	SUM([������(���)]) AS "������(���)",
	AVG([% ���������]) AS "% ���������",
	'' AS "���������",
	1000 AS UNION_GROUP_ID,
        1000 AS SUM_GROUP_ID
FROM  #TmpTable4
--*************************************************************************************
INSERT  #TmpTable4
SELECT
	'' AS "���",
	'' AS "� ���.",
/*
	CASE
	WHEN UNION_GROUP_ID=10 THEN "��������������� ������"
	WHEN UNION_GROUP_ID=20 THEN "������� ������"
	WHEN UNION_GROUP_ID=30 THEN "��������� ������"
	WHEN UNION_GROUP_ID=40 THEN "������������ 750 ��� � ����"
	WHEN UNION_GROUP_ID=50 THEN "������������ �� 750 ���"
	WHEN UNION_GROUP_ID=60 THEN "������"
	WHEN UNION_GROUP_ID=70 THEN "���"
	END  AS "�������",
*/
--DM
---------------------------------------------------------------
  (select '����� '+PAG.abonent_group_name
   from ProAbonentGroups PAG (nolock)
   where PAG.abonent_group_id = round(UNION_GROUP_ID/10,0) ) as "�������",
----------------------------------------------------------------
	'' AS "����",
	SUM([������(���)]) AS "������(���)",
	SUM([������]) AS "������",
	SUM([�������]) AS "�������",
	SUM([����]) AS "����",
	SUM([������]) AS "������",
	SUM([���]) AS "���",
	SUM([����]) AS "����",
	SUM([����]) AS "����",
	SUM([������]) AS "������",
	SUM([��������]) AS "��������",
	SUM([�������]) AS "�������",
	SUM([������]) AS "������",
	SUM([�������]) AS "�������",
	SUM([����� �����]) AS "����� �����",
        SUM([���������]) AS "���������",
	SUM([��������]) AS "��������",
	SUM([�� ������ �����])AS "�� ������ �����",
	SUM([������� �����]) AS "������� �����",
	SUM([������(���)]) AS "������(���)",
	AVG([% ���������]) AS "% ���������",
	'' AS "���������",
/*
	CASE
	WHEN UNION_GROUP_ID=10 THEN 15
	WHEN UNION_GROUP_ID=20 THEN 25
	WHEN UNION_GROUP_ID=30 THEN 35
	WHEN UNION_GROUP_ID=40 THEN 45
	WHEN UNION_GROUP_ID=50 THEN 55
	WHEN UNION_GROUP_ID=60 THEN 65
	WHEN UNION_GROUP_ID=70 THEN 75
  else 0
	END  AS UNION_GROUP_ID,
*/
  --DM
  --------------------------------------
  UNION_GROUP_ID = (UNION_GROUP_ID + 5),
  --------------------------------------
	0 AS SUM_GROUP_ID
FROM  #TmpTable4
WHERE UNION_GROUP_ID<1000
GROUP BY
	UNION_GROUP_ID

/*
--*************************************************************************************

UPDATE #TmpTable4 SET SUM_GROUP_ID= CASE
	WHEN UNION_GROUP_ID IN (15,25,35) THEN 37
	WHEN UNION_GROUP_ID IN (45,55) THEN 57
	WHEN UNION_GROUP_ID IN (65,75) THEN 77
	WHEN UNION_GROUP_ID IN (45,55,65,75) THEN 79
	END
WHERE UNION_GROUP_ID IN (15,25,35,45,55,65,75)

--************************************************************************
INSERT  #TmpTable4
SELECT
	'' AS "���",
	'' AS "� ���.",
	CASE
	WHEN SUM_GROUP_ID=37 THEN "����� ������"
	WHEN SUM_GROUP_ID=57 THEN "����� ������������"
	WHEN SUM_GROUP_ID=77 THEN "����� ������ � ���"
	END  AS "�������",
	'' AS "����",
	SUM([������(���)]) AS "������(���)",
	SUM([������]) AS "������",
	SUM([�������]) AS "�������",
	SUM([����]) AS "����",
	SUM([������]) AS "������",
	SUM([���]) AS "���",
	SUM([����]) AS "����",
	SUM([����]) AS "����",
	SUM([������]) AS "������",
	SUM([��������]) AS "��������",
	SUM([�������]) AS "�������",
	SUM([������]) AS "������",
	SUM([�������]) AS "�������",
	SUM([����� �����]) AS "����� �����",
        SUM([���������]) AS "���������",
	SUM([��������]) AS "��������",
	SUM([�� ������ �����])AS "�� ������ �����",
	SUM([������� �����]) AS "������� �����",
	SUM([������(���)]) AS "������(���)",
	AVG([% ���������]) AS "% ���������",
	'' AS "���������",
	CASE
	WHEN SUM_GROUP_ID=37 THEN 37
	WHEN SUM_GROUP_ID=57 THEN 57
	WHEN SUM_GROUP_ID=77 THEN 77
        END AS UNION_GROUP_ID,
	CASE
	WHEN SUM_GROUP_ID=37 THEN 37
	WHEN SUM_GROUP_ID=57 THEN 57
	WHEN SUM_GROUP_ID=77 THEN 77
        END AS SUM_GROUP_ID
FROM  #TmpTable4
WHERE SUM_GROUP_ID IN (37,57,77)
GROUP BY SUM_GROUP_ID
--************************************************************************
UPDATE #TmpTable4 SET SUM_GROUP_ID=79
WHERE UNION_GROUP_ID IN (45,55,65,75)
--************************************************************************
INSERT  #TmpTable4
SELECT
	'' AS "���",
	'' AS "� ���.",
	"����� ������������ � ������ � ���" AS "�������",
	'' AS "����",
	SUM([������(���)]) AS "������(���)",
	SUM([������]) AS "������",
	SUM([�������]) AS "�������",
	SUM([����]) AS "����",
	SUM([������]) AS "������",
	SUM([���]) AS "���",
	SUM([����]) AS "����",
	SUM([����]) AS "����",
	SUM([������]) AS "������",
	SUM([��������]) AS "��������",
	SUM([�������]) AS "�������",
	SUM([������]) AS "������",
	SUM([�������]) AS "�������",
	SUM([����� �����]) AS "����� �����",
        SUM([���������]) AS "���������",
	SUM([��������]) AS "��������",
	SUM([�� ������ �����])AS "�� ������ �����",
	SUM([������� �����]) AS "������� �����",
	SUM([������(���)]) AS "������(���)",
	AVG([% ���������]) AS "% ���������",
	'' AS "���������",
	79 AS UNION_GROUP_ID,
	79 AS SUM_GROUP_ID
FROM  #TmpTable4
WHERE SUM_GROUP_ID=79
GROUP BY SUM_GROUP_ID

*/

--************************************************************************
IF @ContractId<>0
BEGIN

DELETE #TmpTable4 WHERE [���������]=0

SELECT
        [���],
	[� ���.],
	[�������],
	[������(���)],
	"����"=CASE WHEN [����]=0 THEN '' ELSE CONVERT(varchar(3),[����]) END,
	[������],
	[�������],
	[����],
	[������],
	[���],
	[����],
	[����],
	[������],
	[��������],
	[�������],
	[������],
	[�������],
	[����� �����],
        [���������],
	[��������],
	[�� ������ �����],
	[������� �����],
	[������(���)],
	[% ���������],
	"���������"=CASE WHEN [���������]=0 THEN '' ELSE CONVERT(varchar(5),[���������]) END,
	UNION_GROUP_ID,
	SUM_GROUP_ID
FROM  #TmpTable4
WHERE
        [����� �����]<>0 AND
	[� ���.]=@ContractNumber
END
--************************************************************************
ELSE
--************************************************************************
SELECT
        [���],
	[� ���.],
	[�������],
	"����"=CASE WHEN [����]=0 THEN '' ELSE CONVERT(varchar(3),[����]) END,
	[������(���)],
	[������],
	[�������],
	[����],
	[������],
	[���],
	[����],
	[����],
	[������],
	[��������],
	[�������],
	[������],
	[�������],
	[����� �����],
        [���������],
	[��������],
	[�� ������ �����],
	[������� �����],
	[������(���)],
	[% ���������],
	"���������"=CASE WHEN [���������]=0 THEN '' ELSE CONVERT(varchar(5),[���������]) END,
	UNION_GROUP_ID,
	SUM_GROUP_ID
FROM  #TmpTable4
WHERE [����� �����]<>0
ORDER BY
	UNION_GROUP_ID,
	[���],
	[� ���.]
--************************************************************************
DROP TABLE #TmpTable1
DROP TABLE #TmpTable2
DROP TABLE #TmpTable3
DROP TABLE #TmpTable4
DROP TABLE #TmpCalendar





