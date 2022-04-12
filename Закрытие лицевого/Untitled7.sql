select
      field_id,
      add_keys,
      field_value
into #TmpEdits
from
      EditRecords
where
 label_number = 5469    --@label_number
 and table_id = 4600    --@TableId
 and field_id in (4,5)  -- 4 - tarif_if, 5 serv_signs
 and account_id = 10014 --@account_id
 and convert(int,add_keys) in (13,23)

select * from #TmpEdits

update #TmpEdits
set field_value = case TMP.field_id when 5
                                    then SS.serv_signs
                                    when 4
                                    then SS.tarif_id end
from SumServices SS (nolock),
     #TmpEdits   TMP
where SS.account_id = 10014
  and SS.suppl_id   = 600
  and SS.serv_id    = convert(int,add_keys)





select * from #TmpEdits
select * 
from SumServices
where account_id = 10014
  and serv_id in (13,23)
  and suppl_id = 600



--select * from tablefields where table_id = 4600

