-------------------------------------------------------------------------------------------------
-- ������ :  SQLSOFT2000
-- �����  :  ������� �.�.
-- ����   :  �������� ����-������� �13, �����������2
-- ����   :  16.11.2003
-------------------------------------------------------------------------------------------------

select
  r.subgroup_name as ��������_�������,
  t.account_id as �����_��,	
  s.serv_name as ������,
  ���������� = isnull(t.cnt_sum_calc, 0)
from 
  ##tmp_1__64                   t,
  aspBase2003_09..servicetypes  s (nolock),
  aspGas..GroupSub	        r (nolock)
where 
  s.serv_id = t.serv_id         and 
  r.subgroup_id = t.subgroup_id and
  s.serv_id in (37,49,50,51)    and 
  counter_sign = 1              and
  (select sum(case
       when ((lock_sign_current = 0 and lock_sign_prev = 1) or (lock_sign_current = 0 and lock_sign_prev = 0))
       then isnull(sum_saldo, 0)
       else 0 
   end)
   from ##tmp_1__64                  t1
   where t1.account_id = t.account_id) >= 5000 and                 
  t.sector_id = 11000


