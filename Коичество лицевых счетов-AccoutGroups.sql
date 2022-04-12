if exists (select * from tempdb..sysobjects where id = object_id('tempdb..#TmpAcc'))
begin
drop table #TmpAcc
end

declare
@RES tinyint, -- ����� ���-� �������� ��������
------------------------------------------------
@all_count   int, -- ����� ���-�� ������� ������
------------------------------------------------
@with_cnt    int, -- ���-�� ������� �� ���������
@without_cnt int, -- ���-�� ������� ��� ��������
------------------------------------------------
@single_service int, -- ��-�� ������� � ����� �������
@double_service int, -- ��-�� ������� � ����� ��������
------------------------------------------------------
@one_phase_cnt   int, -- ��-�� ������� � 1-������� ����������
@three_phase_cnt int, -- ��-�� ������� � 3-������� ����������
@unknown_phase_cnt int,
-------------------------------------------------------------
@multi_flat_house int,-- ��-�� ������� � ��������� "���������������"
@private_house    int,-- ��-�� ������� � ��������� "�������"
---------------------------------------------------------------------
@cooker_with_double_tariff int,-- ��-�� ������� � ��������� "����. ����� � 2-�� �������"
@cooker_with_single_tariff int,-- ��-�� ������� � ��������� "������ ����. �����"
----------------------------------------------------------------------------------------
@mask_ss_delete smallint

--===================
select @RES = 0 --:subgroup_res
--===================


select @mask_ss_delete = const_value
from Const
where const_name = 'MASK_SS_DELETE'

create table #TmpAcc
(
account_id int not null,
has_cnt   bit null,
count_services smallint null,
phases_cnt     smallint null,
big_house      bit      null,
double_cooker  bit      null
)

-- ������� ���� �������, ������� ����� ������������� ������
-- �� ����������� ���������
if  @RES = 0 -- ����� �� ����� ����
  begin
  insert into #TmpAcc
  (
  account_id,
  has_cnt,
  count_services,
  phases_cnt,
  big_house,
  double_cooker
  )
SELECT
  distinct
  account_id = A.ACCOUNT_ID,
  null,--  has_cnt = LCP.SET_SIGN,
  null,
  null,
  null,
  null
  FROM
  AccountGroups AG (NoLock),
  Accounts A (NoLock),
  aspElectric..LastCountPays LCP (NoLock),
  aspElectric..GroupSub GS (NoLock)
  WHERE
  (Exists
    (SELECT
       *
      FROM
       SumServices SS (NoLock)
      WHERE
       SS.ACCOUNT_ID = AG.ACCOUNT_ID AND
       SS.SERV_ID    = LCP.SERV_ID AND
       SS.SUPPL_ID   = 600 AND
       SS.SERV_SIGNS&@mask_ss_delete = 0 and
       SS.SERV_ID in (13,23) )) AND
       A.ACCOUNT_ID = AG.ACCOUNT_ID AND
        AG.GROUP_ID  = 10001 AND 
       LCP.ACCOUNT_ID = AG.ACCOUNT_ID AND
       GS.SUBGROUP_ID = AG.SUBGROUP_ID
end
else --����� �� ���������� ���-�
begin
  insert into #TmpAcc
  (
  account_id,
  has_cnt,
  count_services,
  phases_cnt,
  big_house,
  double_cooker
  )
SELECT
  distinct
  account_id = A.ACCOUNT_ID,
  null, --has_cnt = LCP.SET_SIGN,
  null,
  null,
  null,
  null
  FROM
  AccountGroups AG (NoLock),
  Accounts A (NoLock),
  aspElectric..LastCountPays LCP (NoLock),
  aspElectric..GroupSub GS (NoLock)
  WHERE
  (Exists
    (SELECT
       *
      FROM
       SumServices SS (NoLock)
      WHERE
       SS.ACCOUNT_ID = AG.ACCOUNT_ID AND
       SS.SERV_ID    = LCP.SERV_ID AND
       SS.SUPPL_ID   = 600 AND
       SS.SERV_SIGNS&@mask_ss_delete = 0 and
       SS.SERV_ID in (13,23) )) AND
       A.ACCOUNT_ID = AG.ACCOUNT_ID AND
       AG.GROUP_ID  = 10001 AND
       LCP.ACCOUNT_ID = AG.ACCOUNT_ID AND
       GS.SUBGROUP_ID = AG.SUBGROUP_ID and
       GS.subgroup_res = @RES
end

-- �������/���������� ��������

update #TmpAcc
set has_cnt = LCP.set_sign
from #TmpAcc TMP,
     aspElectric..LastCountPays LCP (nolock)
where
  TMP.account_id = LCP.account_id and
  LCP.serv_id = 13

update #TmpAcc
set has_cnt = LCP.set_sign
from #TmpAcc TMP,
     aspElectric..LastCountPays LCP (nolock)
where
  has_cnt is null and
  TMP.account_id = LCP.account_id and
  LCP.serv_id = 23


-- ���������� �����
/*
update #TmpAcc
set count_services = (select count(*)
                      from SumServices SS (nolock)
                      where TMP.account_id = SS.account_id   and
                            SS.suppl_id  = 600               and
                            SS.serv_id   in (13,23) and
                            SS.tarif_id  <> 0                and
                            SS.serv_signs & @mask_ss_delete = 0
                       )
from #TmpAcc TMP
*/
-- ���������� ��� ���������� ��������
update #TmpAcc
set
/*
  phases_cnt = case when substring(CT.specifications,0,
                                 patindex('%;%',CT.specifications)) = '1-��������'
                         then 1
                         when substring(CT.specifications,0,
                                 patindex('%;%',CT.specifications)) = '3-�������'
                         then 3
                         else 0 end*/
phases_cnt = case when CT.specifications like '%1-��������%'
                  then 1
                  when CT.specifications like '%3-�������%'
                  then 3
                  else 0 end,
count_services = CT.counter_type_class_id
from aspElectric..Cnt CNT     (nolock),
     aspElectric..CntTypes CT (nolock),
     #TmpAcc               TMP
where TMP.account_id = CNT.account_id and
      CNT.counter_type_id = CT.counter_type_id and
      CNT.counter_number_id = (select max(CNT1.counter_number_id)
                               from aspElectric..Cnt CNT1 (nolock)
                               where CNT1.account_id = TMP.account_id)
     and TMP.has_cnt = 1
/*
update #TmpAcc
set has_cnt = convert(bit,1)
where phases_cnt is not null and
has_cnt is null

update #TmpAcc
set has_cnt = convert(bit,0)
where phases_cnt is null and
      has_cnt is null
*/
-- ���������������/������� ���
update #TmpAcc
set
  big_house = H.big_house
from
#TmpAcc TMP,
Accounts A (nolock),
Houses   H (nolock)
where TMP.account_id = A.account_id and
      A.house_id     = H.house_id   and
      A.street_id    = H.street_id

update #TmpAcc
set
  big_house = convert(bit,0)
where big_house is null

-- ������������
update #TmpAcc
set
  double_cooker = case when SS.tarif_id = 2
                       then convert(bit,0)
                       when SS.tarif_id = 18
                       then convert(bit,1) end
from #TmpAcc TMP,
     SumServices SS (nolock)
where TMP.account_id = SS.account_id and
      SS.suppl_id    = 600          and
      SS.serv_id     = 13           and
      SS.tarif_id    in (2,18)      and
      SS.serv_signs & @mask_ss_delete = 0

----------- �������-------------------------
select @all_count = count(*)
from #TmpAcc

-- �������/���������� ��������
select @with_cnt = count(*)
from #TmpAcc
where has_cnt = convert(bit,1)
select @without_cnt = count(*)
from #TmpAcc
where has_cnt = convert(bit,0)

-- ����/��� ������
select @single_service = count(*)
from #TmpAcc
where count_services = 1
select @double_service = count(*)
from #TmpAcc
where count_services = 2

--�������� ���������
select @one_phase_cnt = count(*)
from #TmpAcc
where phases_cnt = 1
and has_cnt = convert(bit,1)
select @three_phase_cnt = count(*)
from #TmpAcc
where phases_cnt = 3
and has_cnt = convert(bit,1)
select @unknown_phase_cnt = count(*)
from #TmpAcc
where
 (phases_cnt is null
  or phases_cnt = 0)
and has_cnt = convert(bit,1)

-- ���������������/�������
select @multi_flat_house = count(*)
from #TmpAcc
where big_house = convert(bit,1)
select @private_house = count(*)
from #TmpAcc
where big_house = convert(bit,0)

-- ������������
select @cooker_with_double_tariff = count(*)
from #TmpAcc
where double_cooker = convert(bit,1)

select @cooker_with_single_tariff = count(*)
from #TmpAcc
where double_cooker = convert(bit,0)

--- ����� ������
select
all_count = @all_count, -- ����� ���-�� ������� ������
------------------------------------------------
with_cnt = @with_cnt, -- ���-�� ������� �� ���������
without_cnt = @without_cnt, -- ���-�� ������� ��� ��������
------------------------------------------------
single_service = @single_service, -- ��-�� ������� � ����� �������
double_service = @double_service, -- ��-�� ������� � ����� ��������
------------------------------------------------------
one_phase_cnt = @one_phase_cnt, -- ��-�� ������� � 1-������� ����������
three_phase_cnt = @three_phase_cnt, -- ��-�� ������� � 3-������� ����������
unknown_phase_cnt = @unknown_phase_cnt,
-------------------------------------------------------------
multi_flat_house = @multi_flat_house,-- ��-�� ������� � ��������� "���������������"
private_house = @private_house,-- ��-�� ������� � ��������� "�������"
---------------------------------------------------------------------
cooker_with_double_tariff = @cooker_with_double_tariff,-- ��-�� ������� � ��������� "����. ����� � 2-�� �������"
cooker_with_single_tariff = @cooker_with_single_tariff-- ��-�� ������� � ��������� "������ ����. �����"


drop table #TmpAcc

