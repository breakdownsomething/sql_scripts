-----------------------------------------------------------------------
-- ������ ���������� ��������� �������� ����� �� ������� ������
-- state:
--       = 1 - �������� ������� (���� ������������� ������ (13,23))
--       = 0 - �������� � ������� ������� ������� (������������� ������
--                 ���� �� ��� �������� ��� ���������)
--       = 2 - ������ ��� ������� ������ �� ������� �������� (�� ��� ������
--                 � �������� ������� ���� ������� �� �����������) 
-- counter:
--       = 1 - ���� ���������� �������
--       = 0 - ��� ����������� �������� ��������       
-----------------------------------------------------------------------
declare
  @mask_ss_delete         int, -- �������� ��������� 'MASK_SS_DELETE'
  @exist_active_services  bit, -- ����/��� �������� ������ �� �������
  @exist_deleted_services bit, -- ����/��� ��������� ������ �� �������
  @exist_counter          bit, -- ����/��� ������� ������ �� �������
  @last_action_id         int, -- ��������� ���������� - ��������� ��������
                               -- ��� ��������� ���������
  @account_id             int

select @account_id = 10049--1767--10014 --2210614 --:pAccointId


select @mask_ss_delete = convert(int,const_value)
from   Const
where  const_name = 'MASK_SS_DELETE'

select @exist_active_services =
       case when exists
                 (select  *
                  from SumServices  (nolock)
                  where account_id = @account_id
                    and serv_signs&@mask_ss_delete = 0
                    and suppl_id = 600
                    and tarif_id <> 0
                    and serv_id in (13,23)
                  )
            then convert(bit,1)
            else convert(bit,0) end

select @exist_deleted_services =
       case when exists
                 (select  *
                  from SumServices  (nolock)
                  where account_id = @account_id
                    and serv_signs&@mask_ss_delete = @mask_ss_delete
                    and suppl_id = 600
                    and tarif_id = 0
                    and serv_id in (13,23)
                  )
             then convert(bit,1)
             else convert(bit,0) end



select @last_action_id = isnull(
(
select top 1 action_id
 from aspElectric..CntActionDates
 where account_id = @account_id
   and delete_sign = 0
   and action_id in (1,10,7,8,2)
   and counter_number_id = isnull( 
                                (Select max(counter_number_id)
                                 from aspElectric..Cnt
                                 where account_id = @account_id)
                               ,0)
 order by date_id desc
),0)

select @exist_counter = case when @last_action_id in (1,8,2) 
                             then convert(bit,1)
                             else convert(bit,0) end

-- action_id = 
-- 2  - ������
-- 1  - ��������� 
-- 10 - ������
-- 8  - �����������
-- 7  - ����������



select state = case when @exist_active_services  = convert(bit,1)
                      then 1
                      when @exist_active_services  = convert(bit,0) and
                           @exist_deleted_services = convert(bit,1)
                      then 0
                      when @exist_active_services  = convert(bit,0) and
                           @exist_deleted_services = convert(bit,0)
                      then 2 end,
       counter = @exist_counter


