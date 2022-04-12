SELECT * FROM Tarifs WHERE SERV_ID IN (13,23,24,29,86) AND SUPPL_ID =600
--SELECT * FROM ServiceTypes where SERV_ID IN (13,23,24,29,86)
SELECT * FROM TarifValues WHERE SERV_ID=24 AND SUPPL_ID =600

select * from MeasureItems



select t.tarif_id
      ,t.serv_id
      ,t.suppl_id
      ,t.tarif_name
      ,st.serv_name
      ,m.measure_name
from Tarifs       t  (nolock)
    ,MeasureItems m  (nolock)
    ,ServiceTypes st (nolock)
where t.measure_id = m.measure_id
  and st.serv_id    = t.serv_id
  and t.serv_id in (13,23,24,29,86)
  and t.suppl_id =600
