-- ������ �������� ����� �����-��������
-- "(WorkElectric) ��������/�������������� ������������� �����"

use aspBase2004_07 -- ��� ���, ������� ���������

-- 1) ActForms
declare
  @act_form_id int 

select @act_form_id = 5003

insert into ActForms (act_form_id,
                      act_form_name,
                      comments)
       values(@act_form_id,
             'KillAccountForm',
             '(WorkElectric) ��������/�������������� ������������� �����')

-- 2) ActActionForms
 insert into ActActionForms(act_form_id, action_id)
       values (@act_form_id, 1) -- 1 - ������ ������
--3) 
 insert into ActActionCateg (categ_id, act_form_id, action_id)
      values (1/*��������������*/,5003,1/*������ ������*/)  





