-- �������� ����� �� KOA ������ �� ���� aspElectricPro
-- ������� ������ ������������� ��������� ������ � ������� ProDivSal
-- �� ���-�� �� '2004-04-30'. ������������� �����
-- ��� ��������� ������� ������ � ������� �����������.


-- 1) �������� ��������� ������� � ������� �������������
create table #TmpCorrections
( res_name   varchar(10)   not null -- ��� ���-�
 ,group_id   int           not null -- ��. ������� ProContracts
 ,quantity   int           not null -- ������������� ���*� 
 ,sum_ee     decimal(18,2) not null -- ������������� ����� �� ����. �������
 ,sum_nds    decimal(18,2) not null -- ������������� ����� �� ���
 ,sum_exc    decimal(18,2) not null -- ������������� ����� �� �����
 ,nds        int           not null -- ������ ���
 ,contract_id int          null     -- contract_id �� ������� �������� �������������
)
-- 2) �� ����������
------------------------------------ 20% -----------------------------------------------------------
insert into #TmpCorrections(res_name,group_id,quantity,sum_ee,sum_nds,sum_exc,nds,contract_id)
                    values ('���-1'	,	10011	,	-12625630	,	9338445.39	,	1873459.46	,	71808.28	,	20, null)
insert into #TmpCorrections(res_name,group_id,quantity,sum_ee,sum_nds,sum_exc,nds,contract_id)
                    values ('���-2'	,	10012	,	189126	  ,	5203301.90	,	1043524.40	,	35150.64	,	20, null)
insert into #TmpCorrections(res_name,group_id,quantity,sum_ee,sum_nds,sum_exc,nds,contract_id)
                    values ('���-4'	,	10014	,	3450170	  ,	1125539.96	,	225955.99	  ,	7211.68	  ,	20, null)
insert into #TmpCorrections(res_name,group_id,quantity,sum_ee,sum_nds,sum_exc,nds,contract_id)
                    values ('���-5'	,	10015	,	239625	  ,	8072506.10	,	1622754.58	,	62160.90	,	20, null)
insert into #TmpCorrections(res_name,group_id,quantity,sum_ee,sum_nds,sum_exc,nds,contract_id)
                    values ('���-7'	,	10017	,	-4923595	,	1338896.52	,	269073.42	  ,	8815.39	  ,	20, null)
insert into #TmpCorrections(res_name,group_id,quantity,sum_ee,sum_nds,sum_exc,nds,contract_id)
                    values ('���-9'	,	10019	,	-1224822	,	-7142232.56	,	-1431818.51	,	-55694.76	,	20, null)
-------------------------------------- 16% -----------------------------------------------------------
insert into #TmpCorrections(res_name,group_id,quantity,sum_ee,sum_nds,sum_exc,nds,contract_id)
                    values ('���-1'	,	10011	,	37342892	,	-40096459.77	,	-6056283.13 	,	-78240.23	,	16, null)
insert into #TmpCorrections(res_name,group_id,quantity,sum_ee,sum_nds,sum_exc,nds,contract_id)
                    values ('���-2'	,	10012	,	39128580	,	-76140767.09	,	-12187952.34	,	-53016.32	,	16, null)
insert into #TmpCorrections(res_name,group_id,quantity,sum_ee,sum_nds,sum_exc,nds,contract_id)
                    values ('���-4'	,	10014	,	6351959 	,	-21518973.90	,	-3432556.78 	,	-12608.95	,	16, null)
insert into #TmpCorrections(res_name,group_id,quantity,sum_ee,sum_nds,sum_exc,nds,contract_id)
                    values ('���-5'	,	10015	,	36770064	,	-68149874.36	,	-10915414.03	,	-86834.20	,	16, null)
insert into #TmpCorrections(res_name,group_id,quantity,sum_ee,sum_nds,sum_exc,nds,contract_id)
                    values ('���-7'	,	10017	,	21574463	,	-36176616.46	,	-5730905.59 	,	349086.87	,	16, null)
insert into #TmpCorrections(res_name,group_id,quantity,sum_ee,sum_nds,sum_exc,nds,contract_id)
                    values ('���-9'	,	10019	,	39628449	,	-30725133.65	,	-4921068.23 	,	-2267.40	,	16, null)
-----------------------------------------15%--------------------------------------------------------------
insert into #TmpCorrections(res_name,group_id,quantity,sum_ee,sum_nds,sum_exc,nds,contract_id)
                    values ('���-1'	,	10011	,	5086882	,	-106877360.73	,	142162076.29	,	0.00	,	15, null)
insert into #TmpCorrections(res_name,group_id,quantity,sum_ee,sum_nds,sum_exc,nds,contract_id)
                    values ('���-2'	,	10012	,	9905657	,	91516116.45 	,	-9416357.65	  ,	0.00	,	15, null)
insert into #TmpCorrections(res_name,group_id,quantity,sum_ee,sum_nds,sum_exc,nds,contract_id)
                    values ('���-4'	,	10014	,	2440475	,	-97318099.82	,	120923531.82	,	0.00	,	15, null)
insert into #TmpCorrections(res_name,group_id,quantity,sum_ee,sum_nds,sum_exc,nds,contract_id)
                    values ('���-5' ,	10015	,	7876120	,	108484526.15	,	-39089825.14	,	0.00	,	15, null)
insert into #TmpCorrections(res_name,group_id,quantity,sum_ee,sum_nds,sum_exc,nds,contract_id)
                    values ('���-7'	,	10017	,	5301521	,	50638098.85	  ,	-10696520.29	,	0.00	,	15, null)
insert into #TmpCorrections(res_name,group_id,quantity,sum_ee,sum_nds,sum_exc,nds,contract_id)
                    values ('���-9'	,	10019	,	19257542	,	33586040.35	,	8730592.72	  ,	0.00	,	15, null)

--3) ������������� �������� �� ������ ���������� �������
-- � ����� ���-� � � ������ �������� ������������
update #TmpCorrections
set contract_id = (select top 1 PDS.contract_id
                   from ProDivSal    PDS (nolock)
                       ,ProContracts PC  (nolock)
                   where PDS.date_calc = '2004-04-30'
                     and PDS.nds_tax = TMP.nds
                     and PDS.contract_id = PC.contract_id
                     and PC.group_id = TMP.group_id
                     and PDS.contract_id <> 78515)
from #TmpCorrections TMP 

--4) ���������� �������� ���������
update ProDivSal
set 
  EQUANTITY = P.equantity + TMP.quantity
 ,ESUM_EE   = P.esum_ee   + TMP.sum_ee
 ,ESUM_NDS  = P.esum_nds  + TMP.sum_nds
 ,ESUM_EXC  = P.esum_exc  + TMP.sum_exc
from ProDivSal P
    ,#TmpCorrections TMP
where
      P.date_calc   = '2004-04-30'
  and P.contract_id = TMP.contract_id
  and P.nds_tax     = TMP.nds   


drop table #TmpCorrections


/*
select top 1
       PDS.contract_id
      ,PDS.equantity
      ,PDS.esum_ee
      ,PDS.esum_nds
      ,PDS.esum_exc
      ,PC.group_id
from ProDivSal    PDS (nolock)
    ,ProContracts PC  (nolock)
where PDS.date_calc = '2004-04-30'
  and PDS.nds_tax = 15
 -------------------------
  and PDS.contract_id = PC.contract_id
  and PC.group_id = 10014
  and PDS.contract_id <> 78515
*/

