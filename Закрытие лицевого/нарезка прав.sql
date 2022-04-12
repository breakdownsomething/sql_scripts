-- Скрипт создания новой формы-действия
-- "(WorkElectric) Удаление/восстановление электрических услуг"

use aspBase2004_07 -- или тот, который последний

-- 1) ActForms
declare
  @act_form_id int 

select @act_form_id = 5003

insert into ActForms (act_form_id,
                      act_form_name,
                      comments)
       values(@act_form_id,
             'KillAccountForm',
             '(WorkElectric) Удаление/восстановление электрических услуг')

-- 2) ActActionForms
 insert into ActActionForms(act_form_id, action_id)
       values (@act_form_id, 1) -- 1 - полный доступ
--3) 
 insert into ActActionCateg (categ_id, act_form_id, action_id)
      values (1/*администраторы*/,5003,1/*полный доступ*/)  





